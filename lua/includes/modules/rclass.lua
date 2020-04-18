/*
*   @package        : rlib
*   @module         : rclass
*   @author         : Richard [http://steamcommunity.com/profiles/76561198135875727]
*   @copyright      : (C) 2020 - 2020
*   @since          : 3.0.0
*   @website        : https://rlib.io
*   @docs           : https://docs.rlib.io
* 
*   MIT License
*
*   THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT 
*   LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. 
*   IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
*   LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION 
*   WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

rclass              = { }
local VERSION       = "0.1.0"

local base
local assert        = assert
local type          = type
local rawget        = rawget
local rawset        = rawset
local gmt           = getmetatable
local smt           = setmetatable
local sf            = string.format
local insert        = table.insert
local rm            = table.remove
local Utils         = { }

/*
*   utils :: extend
*
*   Copy key/values from one table to another. will deep copy any 
*   value from first table which is itself a table.
*/

function Utils.extend( fromTable, toTable )

    if not fromTable or not toTable then
        error( "table can't be nil" )
    end

    function _extend( fT, tT )
        for k,v in pairs( fT ) do

            if type( fT[ k ] ) == "table" and
                type( tT[ k ] ) == "table" then

                tT[ k ] = _extend( fT[ k ], tT[ k ] )

            elseif type( fT[ k ] ) == "table" then
                tT[ k ] = _extend( fT[ k ], { } )

            else
                tT[ k ] = v
            end
        end

        return tT
    end

    return _extend( fromTable, toTable )
end

/*
*   registerCtorName
*/

local function registerCtorName( name, class )
    class = class or base

    assert( type( name ) == 'string', 'ctor name should be string' )
    assert( class.is_class, 'Class is not is_class' )

    class[ name ] = class.__ctor__

    return class[ name ]
end

/*
*   registerDtorName
*
*	add names for the destructor
*/

local function registerDtorName( name, class )
    class = class or base
    --==--
    assert( type( name ) == 'string', 'dtor name should be string' )
    assert( class.is_class, 'Class is not is_class' )

    class[ name ] = class.__dtor__

    return class[ name ]
end

/*
*   superCall
*
*	function to intelligently find methods in object hierarchy
*/

local function superCall( self, ... )
    local args      = { ... }
    local arg1      = args[ 1 ]

    assert( type(arg1) == 'table' or type(arg1) == 'string', "superCall arg not table or string" )

    local parent_lock, method, params

    if type( arg1 ) == 'table' then
        parent_lock = rm( args, 1 )
        method = rm( args, 1 )
    else
        method = rm( args, 1 )
    end

    params = args

    local self_dmc_super    = self.__dmc_super
    local super_flag        = ( self_dmc_super ~= nil )
    local result            = nil

    local function findMethod( classes, name, lock )
        if not classes then return end -- when using mixins, etc
        local cls = nil
        for _, class in ipairs( classes ) do
            if not lock or class == lock then
                if rawget( class, name ) then
                    cls = class
                    break
                else
                    -- check parents for method
                    cls = findMethod( class.__parents, name )
                    if cls then break end
                end
            end
        end
        return cls
    end

    local c, s  -- class, super

    if self_dmc_super == nil then
        self.__dmc_super    = { }
        self_dmc_super      = self.__dmc_super

        s = findMethod( { self.__class }, method )
        insert( self_dmc_super, s )
    end

    -- pull Class from stack and search for method on Supers
    -- look for method on supers
    -- call method if found
    --
    c = self_dmc_super[ # self_dmc_super ]
    s = findMethod( c.__parents, method, parent_lock )

    if s then
        insert( self_dmc_super, s )
        result = s[method]( self, unpack( args ) )
        rm( self_dmc_super, # self_dmc_super )
    end

    -- this is the first iteration and last
    -- so clean up callstack, etc
    --
    if super_flag == false then
        parent_lock = nil
        rm( self_dmc_super, # self_dmc_super )
        self.__dmc_super = nil
    end

    return result
end

/*
*   initializeObject
*
*	this is the beginning of object initialization either Class or Instance
*   this is what calls the parent constructors, eg new( )
*   called from rClass( ), __create__( ), __call( )
*/

local function initializeObject( obj, params )
    params = params or { }

    assert( params.set_isClass ~= nil, "initializeObject requires paramter 'set_isClass'" )

    local is_class  = params.set_isClass
    local args      = params.data or { }
    obj.__is_class  = params.set_isClass

    local parents = obj.__parents
    for i = #parents, 1, -1 do
        local parent = parents[i]
        assert( parent, "Lua Objects: parent is nil, check parent list" )

        rawset( obj, '__parent_lock', parent )
        if parent.__new__ then
            parent.__new__( obj, unpack( args ) )
        end

    end
    rawset( obj, '__parent_lock', nil )

    return obj
end

/*
*   newindexFunc
*
*	override the normal Lua lookup functionality to allow
*   property setter functions
*/

local function newindexFunc( t, k, v )
    local o, f
    o   = rawget( t, '__setters' ) or { }
    f   = o[ k ]
    if f then
        f( t, v )
    else
        rawset( t, k, v )
    end
end

/*
*   multiindexFunc
*
*	override the normal Lua lookup functionality to allow
*   property getter functions
*/

local function multiindexFunc( t, k )
    local o, val

    o = rawget( t, '__getters' ) or { }
    if o[k] then return o[ k ]( t ) end

    val = rawget( t, k )
    if val ~= nil then return val end

    o = rawget( t, '__parent_lock' )
    if o then
        if o then val = o[ k ] end
        if val ~= nil then return val end
    else
        local par = rawget( t, '__parents' )
        for _, o in ipairs( par ) do
            if o[ k ] ~= nil then
                val = o[ k ]
                break
            end
        end
        if val ~= nil then return val end
    end

    return nil
end

/*
*   blessObject
*
*	create new object, setup with Lua OO aspects, dmc-style aspects
*/

local function blessObject( inheritance, params )
    params              = params or { }
    params.object       = params.object or { }
    params.set_isClass  = params.set_isClass == true and true or false

    local o 	        = params.object
    local o_id 	        = tostring(o)
    local mt 	        =
    {
        __index 		= multiindexFunc,
        __newindex 		= newindexFunc,
        __tostring 		= function( obj )
            return obj:__tostring__( o_id )
        end,
        __call = function( cls, ... )
            return cls:__ctor__( ... )
        end
    }
    smt( o, mt )

    o.__parents     = inheritance
    o.__is_dmc      = true

    o.__setters     = { }
    o.__getters     = { }

    -- copy down all getters/setters of parents
    -- do in reverse order, to match order of property lookup
    for i = #inheritance, 1, -1 do
        local cls = inheritance[i]
        if cls.__getters then
            o.__getters = Utils.extend( cls.__getters, o.__getters )
        end
        if cls.__setters then
            o.__setters = Utils.extend( cls.__setters, o.__setters )
        end
    end

    return o
end

/*
*   unblessObject
*/

local function unblessObject( o )
    smt( o, nil )
    o.__parents     = nil
    o.__is_dmc      = nil
    o.__setters     = nil
    o.__getters     = nil
end

/*
*   rClass
*/

local function rClass( inheritance, params )
    inheritance         = inheritance or { }
    params              = params or { }
    params.set_isClass  = true
    params.name         = params.name or '<unnamed class>'
    --==--
    assert( type( inheritance ) == 'table', 'first parameter should be nil, class, or a set of classes' )

    -- wrap single-class into table list
    -- testing for DMC-Style objects
    if inheritance.is_class == true then
        inheritance = { inheritance }
    elseif base and #inheritance == 0 then
        insert( inheritance, base )
    end

    local o = blessObject( inheritance, { } )
    initializeObject( o, params )

    o.__class = o
    o.__name = params.name

    return o
end

/*
*   inheritsFrom
*
*   backwards compatibility
*/

local function inheritsFrom( baseClass, options, constructor )
    baseClass = baseClass == nil and baseClass or { baseClass }
    return rClass( baseClass, options )
end

/*
*   base class
*/

base = rClass( nil, { name = 'Base Class' } )

/*
*   ctor
*/

function base:__ctor__( ... )
    local params =
    {
        data            = { ... },
        set_isClass     = false
    }
    --==--
    local o = blessObject( { self.__class }, params )
    initializeObject( o, params )

    return o
end

/*
*   dtor
*/

function base:__dtor__( )
    self:__destroy__( )
end

/*
*   new
*/

function base:__new__( ... )
    return self
end

/*
*   tostring
*/

function base:__tostring__( id )
    return sf( '%s (%s)', self.NAME, id ) -- '
end

/*
*   destroy
*/

function base:__destroy__( ) end

/*
*   getters :: name
*/

function base.__getters:NAME( )
    return self.__name
end

/*
*   setters :: class
*/

function base.__getters:class( )
    return self.__class
end

/*
*   getters :: supers
*/

function base.__getters:supers( )
    return self.__parents
end

/*
*   getters :: __is_class
*/

function base.__getters:is_class( )
    return self.__is_class
end

/*
*   getters :: is_instance
*/

function base.__getters:is_instance( )
    return not self.__is_class
end

/*
*   getters :: version
*/

function base.__getters:version( )
    return self.__version
end

/*
*   base :: isa
*/

function base:isa( the_class )
    local isa = false
    local cur_class = self.class

    -- test self
    if cur_class == the_class then
        isa = true

    -- test parents
    else
        local parents = self.__parents
        for i = 1, #parents do
            local parent = parents[i]
            if parent.isa then
                isa = parent:isa( the_class )
            end
            if isa == true then break end
        end
    end

    return isa
end

/*
*   base :: optimize
*
*   move super class methods to object
*/

function base:optimize( )

    function _optimize( obj, inheritance )

        if not inheritance or #inheritance == 0 then return end

        for i = #inheritance, 1, -1 do
            local parent = inheritance[ i ]

            -- climb up the hierarchy
            _optimize( obj, parent.__parents )

            -- make local references to all functions
            for k, v in pairs( parent ) do
                if type( v ) == 'function' then
                    obj[ k ] = v
                end
            end
        end

    end

    _optimize( self, { self.__class } )
end

/*
*   base :: deoptimize
*/

function base:deoptimize( )
    for k, v in pairs( self ) do
        if type( v ) == 'function' then
            self[ k ] = nil
        end
    end
end

/*
*  register
*/

registerCtorName        ( 'new',        base )
registerDtorName        ( 'destroy',    base )
base.superCall          = superCall

/*
*   Class_CreateGlobal
*
*   modifies the global namespace with rClass( )
*/

local function Class_CreateGlobal( is_global )
    is_global = is_global ~= nil and is_global or true
    if _G.rClass ~= nil then
        print( "WARNING: rClass exists in global namespace" )
    elseif is_global == true then
        _G.rClass = rClass
    else
        _G.rClass = nil
    end
end

/*
*   Class_CreateGlobal
*/

Class_CreateGlobal( )

/*
*   return
*/

return
{
    __version           = VERSION,
    __superCall         = superCall, -- for testing
    setNewClassGlobal   = Class_CreateGlobal,
    registerCtorName    = registerCtorName,
    registerDtorName    = registerDtorName,
    inheritsFrom        = inheritsFrom, -- backwards compatibility
    rClass              = rClass,
    Class               = base
}