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
local istable           = istable
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
*   declarations
*/

local M 			= { }
local deferred 		= { }
deferred.__index 	= deferred

/*
*   declare :: status
*/

local PENDING 		= 0
local RESOLVING 	= 1
local REJECTING 	= 2
local RESOLVED 		= 3
local REJECTED 		= 4

/*
*   finish
*/

local function finish( deferred, state )
    state = state or REJECTED
    for i, f in ipairs( deferred.queue ) do
        if state == RESOLVED then
            f:resolve( deferred.value )
        else
            f:reject( deferred.value )
        end
    end
    deferred.state = state
end

/*
*	isfunc
*/

local function isfunc( f )
    if type( f ) == 'table' then
        local mt = getmetatable( f )
        return mt ~= nil and type( mt.__call ) == 'function'
    end
    return type( f ) == 'function'
end

/*
*	promise
*/

local function promise( deferred, next, success, failure, nonpromisecb )
    if istable( deferred ) and istable( deferred.value ) and isfunc( next ) then

        local called = false

        local ok, err = pcall( next, deferred.value, function( v )
            if called then return end
            called          = true
            deferred.value  = v
            success( )
        end, function( v )
            if called then return end
            called          = true
            deferred.value  = v
            failure( )
        end )

        if not ok and not called then
            deferred.value = err
            failure( )
        end
    else
        nonpromisecb( )
    end
end

/*
*	fire
*/

local function fire( deferred )
    local next
    if type( deferred.value ) == 'table' then
        next = deferred.value.next
    end
    promise( deferred, next, function( )
        deferred.state = RESOLVING
        fire( deferred )
    end, function( )
        deferred.state = REJECTING
        fire( deferred )
    end, function( )
        local ok
        local v
        if deferred.state == RESOLVING and isfunc( deferred.success ) then
            ok, v = pcall( deferred.success, deferred.value )
        elseif deferred.state == REJECTING and isfunc( deferred.failure ) then
            ok, v = pcall( deferred.failure, deferred.value )
            if ok then
                deferred.state = RESOLVING
            end
        end

        if ok ~= nil then
            if ok then
                deferred.value = v
            else
                deferred.value = v
                return finish( deferred )
            end
        end

        if deferred.value == deferred then
            deferred.value = pcall( error, 'resolving promise with itself' )
            return finish( deferred )
        else
            promise( deferred, next, function( )
                finish( deferred, RESOLVED )
            end, function( state )
                finish( deferred, state )
            end, function( )
                finish( deferred, deferred.state == RESOLVING and RESOLVED )
            end )
        end
    end )
end

/*
*	resolve
*/

local function resolve( deferred, state, value )
    if deferred.state == 0 then
        deferred.value = value
        deferred.state = state
        fire( deferred )
    end

    return deferred
end

/*
*	PUBLIC
*/

/*
*	deferred :: resolve
*/

function deferred:resolve( val )
    return resolve( self, RESOLVING, val )
end

/*
*	deferred :: reject
*/

function deferred:reject( val )
    return resolve( self, REJECTING, val )
end

/*
*   new
*
*	returns a new promise object
*
*   @ex     : local deferred = require( 'deferred' )
*/

function M.new( options )
    if isfunc( options ) then
        local d         = M.new( )
        local ok, err   = pcall( options, d )

        if not ok then
            d:reject( err )
        end

        return d
    end
    options = options or { }
    local d
    d =
    {
        next = function( self, success, failure )
            local next = M.new( { success = success, failure = failure, extend = options.extend } )
            if d.state == RESOLVED then
                next:resolve( d.value )
            elseif d.state == REJECTED then
                next:reject( d.value )
            else
                table.insert( d.queue, next )
            end
            return next
        end,

        state 	= 0,
        queue 	= { },
        success = options.success,
        failure = options.failure,
    }
    d = smt( d, deferred )

    if isfunc( options.extend ) then
        options.extend( d )
    end

    return d
end

/*
*   all
*
*	returns a new promise object that is resolved when all promises are resolved/rejected.
*/

function M.all( args )
    local d = M.new( )

    if #args == 0 then
        return d:resolve( { } )
    end

    local method 	= 'resolve'
    local pending 	= #args
    local results 	= { }

    local function synchronizer( i, resolved )
        return function( value )
            results[ i ] = value
            if not resolved then
                method = 'reject'
            end

            pending = pending - 1

            if pending == 0 then
                d[ method ]( d, results )
            end

            return value
        end
    end

    for i = 1, pending do
        args[ i ]:next( synchronizer( i, true ), synchronizer( i, false ) )
    end

    return d
end

/*
*   new
*
*	returns a new promise object that is resolved with the values
*   of sequential application of function fn to each element in the
*   list. fn is expected to return promise object.
*/

function M.map( args, fn )
    local d = M.new( )
    local results = { }
    local function donext( i )
        if i > #args then
            d:resolve( results )
        else
            fn( args[ i ] ):next( function( res )
                table.insert( results, res )
                donext( i + 1 )
            end, function( err )
                d:reject( err )
            end )
        end
    end

    donext( 1 )

    return d
end

/*
*   first
*
*	returns a new promise object that is resolved as soon as 
*   the first of the promises gets resolved/rejected.
*/

function M.first( args )
    local d = M.new( )
    for _, v in ipairs( args ) do
        v:next( function( res )
            d:resolve(res)
        end, function( err )
            d:reject( err )
        end )
    end

    return d
end

return M