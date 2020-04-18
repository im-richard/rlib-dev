/*
*   @package        : rlib
*   @module         : promises
*   @author         : Richard [http://steamcommunity.com/profiles/76561198135875727]
*   @copyright      : (C) 2020 - 2020
*   @since          : 1.0.0
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

/*
*   @package        : promises
*   @author         : Lex Robinson
*   @copyright      : (C) 2013
* 
*   MIT License
*
*   THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT 
*   LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. 
*   IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
*   LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION 
*   WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

/*
*   standard tables and localization
*/

rlib                    = rlib or { }
local base              = rlib
local mf                = base.manifest
local pf                = mf.prefix
local script            = mf.name

/*
*   lib includes
*/

local access            = base.a
local helper            = base.h

/*
*   localizations
*/

local smt               = setmetatable
local table             = table
local pairs             = pairs
local ipairs            = ipairs
local error             = error
local ErrNoHalt         = ErrorNoHalt or print
local isfunction        = isfunction
local istable           = istable
local unpack            = unpack
local pause             = timex and isfunction( timex.simple ) and timex.simple or timer.Simple
local sf                = string.format

/*
*   simplifiy funcs
*/

local function con( ... ) base:console( ... ) end
local function log( ... ) base:log( ... ) end

/*
*	prefix :: create id
*/

local function pref( id, suffix )
    local affix = istable( suffix ) and suffix.id or isstring( suffix ) and suffix or prefix
    affix       = affix:sub( -1 ) ~= '.' and sf( '%s.', affix ) or affix

    id          = isstring( id ) and id or 'noname'
    id          = id:gsub( '[%c%s]', '.' )

    return sf( '%s%s', affix, id )
end

/*
*	prefix :: handle
*/

local function pid( str, suffix )
    local state = ( isstring( suffix ) and suffix ) or ( base and mf.prefix ) or false
    return pref( str, state )
end

/*
*   define module
*/

module( 'promise', package.seeall )

/*
*   local declarations
*/

local pkg           = promise
local pkg_name      = _NAME or 'promise'

/*
*   pkg declarations
*/

local manifest =
{
    author      = 'richard',
    desc        = 'a+ promises',
    build       = 040420,
    version     = { 1, 0, 0 },
}

/*
*   new
*/

local function new( tab, ... )
    local ret = smt( { }, { __index = tab } )
    ret:Initialize( ... )

    return ret
end

/*
*   bind
*/

local function bind( obj, context )
    return function( ... )
        if context then
            return obj( context, ... )
        else
            return obj( ... )
        end
    end
end

/*
*   pbind
*/

local function pbind( func )
    if not isfunction( func ) then
        debug.Trace( )
    end
    return function( ... )
        func( ... )
    end
end

/*
*   promise
*/

local Instance =
{
    _bIsPromise = true,
    Then = function( self, succ, fail, prog )
        local def = Deferred( )
        if isfunction( succ ) then
            local s = succ
            succ = function( ... )
                local ret = { true, s( ... ) }
                if not ret[ 1 ] then
                    print( 'WARNING: Lua Error - ' .. ret[ 2 ] )
                    def:Reject( ret[ 2 ] )

                    return
                end
                if istable( ret[ 2 ] ) and ret[ 2 ]._bIsPromise then
                    local r     = ret[ 2 ]
                    r:Progress  ( bind( def.Notify,     def ),  true )
                    r:Done      ( bind( def.Resolve,    def ),  true )
                    r:Fail      ( bind( def.Reject,     def ),  true )
                else
                    def:Resolve( unpack( ret, 2 ) )
                end
            end
        else
            succ = bind( def.Resolve, def )
        end
        if isfunction( fail ) then
            local f = fail
            fail = function( ... )

                local ret = { true, f( ... ) }

                if not ret[ 1 ] then
                    print( 'WARNING: Lua Error - ' .. ret[ 2 ] )
                    def:Reject( ret[ 2 ] )

                    return
                end

                if istable( ret[ 2 ] ) and ret[ 2 ]._bIsPromise then
                    local r     = ret[ 2 ]
                    r:Progress  ( bind( def.Notify,     def ),  true )
                    r:Done      ( bind( def.Resolve,    def ),  true )
                    r:Fail      ( bind( def.Reject,     def ),  true )
                else
                    def:Resolve( unpack( ret, 2 ) )
                end
            end
        else
            fail = bind( def.Reject, def )
        end

        if isfunction( prog ) then
            local p = prog
            prog = function( ... )
                local ret = { true, s( ... ) }
                if not ret[ 1 ] then
                    ErrNoHalt( 'Progress handler failed: ', ret[ 2 ], '\n' )
                    def:Notify( ... )
                else
                    def:Notify( unpack( ret, 2 ) )
                end
            end
        else
            prog = bind( def.Notify, def )
        end

        self:Progress   ( prog, true )
        self:Done       ( succ, true )
        self:Fail       ( fail, true )

        return def:Promise( )
    end,

    /*
    *   done
    */

    Done = function( self, succ, nobind )
        if not nobind then
            succ = pbind( succ )
        end

        if self._state == 'done' then
            succ( unpack( self._res ) )
        else
            table.insert( self._succs, succ )
        end

        return self
    end,

    /*
    *   fail
    */

    Fail = function( self, fail, nobind )
        if not nobind then
            fail = pbind( fail )
        end

        if self._state == 'fail' then
            fail( unpack( self._res ) )
        else
            table.insert( self._fails, fail )
        end

        return self
    end,

    /*
    *   progress
    */

    Progress = function( self, prog, nobind )
        if not nobind then
            prog = pbind( prog )
        end

        table.insert( self._progs, prog )

        if self._progd then
            for _, d in ipairs( self._progd ) do
                prog( unpack( d ) )
            end
        end

        return self
    end,

    /*
    *   always
    */

    Always = function( self, alwy, nobind )
        if not nobind then
            alwy = pbind( alwy )
        end

        if self._state ~= 'pending' then
            alwy( unpack( self._res ) )
        else
            table.insert( self._alwys, alwy )
        end

        return self
    end,

    /*
    *   Initialize
    */

    Initialize = function( self )
        self._state = 'pending'
        self._succs = { }
        self._fails = { }
        self._progs = { }
        self._alwys = { }
    end
}

/*
*   deferred
*/

local deferred =
{
    _IsDeferred = true,

    /*
    *   resolve
    */

    Resolve = function( self, ... )
        local p = self._promise
        if p._state ~= 'pending' then
            error( 'Tried to resolve an already ' .. ( state == 'done' and 'resolved' or 'rejected' ) .. ' deferred!', 2 )
        end

        p._state    = 'done'
        p._res      = { ... }

        for _, f in pairs( p._succs ) do
            f( ... )
        end

        for _, f in pairs( p._alwys ) do
            f( ... )
        end

        return self
    end,

    /*
    *   reject
    */

    Reject = function( self, ... )
        local p = self._promise
        if p._state ~= 'pending' then
            error( 'Tried to reject an already ' .. ( state == 'done' and 'resolved' or 'rejected' ) .. ' deferred!', 2 )
        end

        p._state    = 'fail'
        p._res      = { ... }

        if #p._fails == 0 then
            print( 'Failure: uncaught error' )
            print( ... )
        end

        for _, f in pairs( p._fails ) do
            f( ... )
        end

        for _, f in pairs( p._alwys ) do
            f( ... )
        end

        return self
    end,

    /*
    *   notify
    */

    Notify = function( self, ... )
        local p = self._promise
        if p._state ~= 'pending' then
            error( 'Tried to notify an already ' .. ( state == 'done' and 'resolved' or 'rejected' ) .. ' deferred!', 2 )
        end

        p._progd = p._progd or { }
        table.insert( p._progd, { ... } )

        for _, f in pairs( p._progs ) do
            f( ... )
        end

        return self
    end,

    /*
    *   Initialize
    */

    Initialize = function( self )
        self._promise = new( Instance )
    end,

    /*
    *   Promise
    */

    Promise = function( self )
        return self._promise
    end,

    /*
    *   bool :: IsPromise
    */

    _bIsPromise = true,

    /*
    *   then
    */

    Then = function( self, ... )
        return self._promise:Then( ... )
    end,

    /*
    *   done
    */

    Done = function( self, ... )
        self._promise:Done( ... )
        return self
    end,

    /*
    *   fail
    */

    Fail = function( self, ... )
        self._promise:Fail( ... )
        return self
    end,

    /*
    *   progress
    */

    Progress = function( self, ... )
        self._promise:Progress( ... )
        return self
    end,

    /*
    *   always
    */

    Always = function( self, ... )
        self._promise:Always( ... )
        return self
    end,
}

/*
*   deferred
*/

function Deferred( )
    return new( deferred )
end

/*
*   promise :: get state
*/

function GetState( pr )
    if pr and pr._IsDeferred then
        return pr._promise._state
    elseif pr and ( pr._bIsPromise or pr._promise ) then
        return pr._state
    else
        debug.Trace( )
        error( 'Bad obj passed to getPromiseState(expected deferred/promise got ' .. type( pr ) .. ')' )
    end
end

/*
*   OnComplete
*/

-- Waits for all promises to be finished, when one errors it rejects, else it returns the results in order
function OnComplete( lst_promises, options )
    local def       = Deferred( )
    local results   = { }
    local opts      = options or { }

    if #lst_promises == 0 then
        def:Resolve( )
        return def:Promise( )
    end

    for k, v in pairs( lst_promises ) do
        v:Done( function( ... )
            local args = { ... }
            if #args > 1 then
                results[ k ] = args
            else
                results[ k ] = args[ 1 ]
            end
        end )
    end

    for k, v in pairs( lst_promises ) do

        v:Done( function( )
            if def._promise._state == 'fail' or def._promise._state == 'done' then return end

            local bIsDone = true
            for _, item in pairs( lst_promises ) do
                if item == v then continue end
                if item._state == 'pending' then
                    bIsDone = false
                end
            end

            if bIsDone then
                if opts.noUnpack then
                    def:Resolve( results )
                else
                    def:Resolve( unpack( results ) )
                end
            end
        end )

        v:Fail( function( ... )
            if def._promise._state == 'pending' then
                def:Reject( ... )
            end
        end )

    end

    return def:Promise( ), def
end

/*
*   promise :: reject
*/

function Reject( ... )
    local def = Deferred( )
    def:Reject( ... )

    return def:Promise( )
end

/*
*   promise :: valid
*/

function Valid( val )
    return val and istable( val ) and ( val._IsDeferred or val._bIsPromise )
end

/*
*   promise :: map
*
*   maps promises to result and resolves to the map
*   when completed
*/

function Map( tbl, fn )
    local opts      = opts or { }
    local promises  = { }
    for k, v in pairs( tbl ) do
        local item = Resolve( )
        :Then( function( )
            if Valid( v ) then
                return v:Then( fn )
            end
            return fn( v )
        end )

        table.insert( promises, item )
    end

    return OnComplete( promises, { noUnpack = true } )
end

/*
*   promise :: resolve
*/

function Resolve( ... )
    local def = Deferred( )
    def:Resolve( ... )

    return def:Promise( )
end

/*
*   promise :: delay
*
*   delay calling func or resolving a value through promise.
*/

function Delay( delay, fnVal )
    local def = Deferred( )
    pause( delay, function( )
        if isfunction( fnVal ) then
            -- CAll the function and forward results. If the function returns a promise wait for completion and handle resolve and reject
            local results = { fnVal( ) }
            if #results == 1 and Valid( results[ 1 ] ) then
                results[ 1 ]:Then( function( ... )
                    def:Resolve( ... )
                end, function( ... )
                    def:Reject( ... )
                end )
            end
            def:Resolve( unpack( results ) )
        else
            def:Resolve( fnVal )
        end
    end )

    return def:Promise( )
end

/*
*   rcc :: base command
*
*   base package command
*/

function rcc.call:Promise( ply, cmd, args )

    /*
    *   permissions
    */

    local ccmd = base.calls:get( 'commands', 'promise' )

    if ( ccmd.scope == 1 and not base.con:Is( ply ) ) then
        access:deny_consoleonly( ply, script, ccmd.id )
        return
    end

    if not access:bIsRoot( ply ) then
        access:deny_permission( ply, script, ccmd.id )
        return
    end

    /*
    *   output
    */

    con( pl, 1 )
    con( pl, 0 )
    con( pl, Color( 255, 255, 0 ), sf( 'Manifest » %s', pkg_name ) )
    con( pl, 0 )
    con( pl, manifest.desc )
    con( pl, 1 )

    local a1_l              = sf( '%-20s',  'Version'   )
    local a2_l              = sf( '%-5s',  '»'   )
    local a3_l              = sf( '%-35s',  sf( 'v%s build-%s', rlib.get:ver2str( manifest.version ), manifest.build )   )

    con( pl, Color( 255, 255, 0 ), a1_l, Color( 255, 255, 255 ), a2_l, a3_l )

    local b1_l              = sf( '%-20s',  'Author'    )
    local b2_l              = sf( '%-5s',  '»'          )
    local b3_l              = sf( '%-35s',  sf( '%s', manifest.author ) )

    con( pl, Color( 255, 255, 0 ), b1_l, Color( 255, 255, 255 ), b2_l, b3_l )

    con( pl, 2 )

end

/*
*   register new commands
*/

local function register_commands( )
    local pkg_commands =
    {
        [ pkg_name ] =
        {
            enabled     = true,
            warn        = true,
            id          = pkg_name,
            name        = pkg_name,
            desc        = 'returns package information',
            scope       = 2,
            clr         = Color( 255, 255, 0 ),
            assoc = function( ... )
                rcc.call:Promise( ... )
            end,
        },
    }

    base.calls.commands:Register( pkg_commands )
end
hook.Add( pid( 'cmd.register' ), pid( '__promise.cmd.register' ), register_commands )

/*
*   register package
*/

local function register_pkg( )
    if not istable( _M ) then return end
    base.package:Register( _M )
end
hook.Add( pid( 'pkg.register' ), pid( '__calc.pkg.register' ), register_pkg )

/*
*   module info :: manifest
*/

function pkg:manifest( )
    return self.__manifest
end

/*
*   __tostring
*/

function pkg:__tostring( )
    return self:_NAME( )
end

/*
*   create new class
*/

function pkg:loader( class )
    class = class or { }
    self.__index = self
    return setmetatable( class, self )
end

/*
*   __index / manifest declarations
*/

pkg.__manifest =
{
    __index     = _M,
    name        = _NAME,
    build       = manifest.build,
    version     = manifest.version,
    author      = manifest.author,
    desc        = manifest.desc
}

pkg.__index     = pkg