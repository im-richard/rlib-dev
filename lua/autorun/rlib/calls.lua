/*
*   @package        rlib
*   @author         Richard [http://steamcommunity.com/profiles/76561198135875727]
*   @copyright      (C) 2018 - 2020
*   @since          1.0.0
*   @website        https://rlib.io
*   @docs           https://docs.rlib.io
*   @file           calls.lua
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
local prefix            = mf.prefix
local cfg               = base.settings

/*
*   localized rlib routes
*/

local helper            = base.h
local storage           = base.s
local utils             = base.u
local access            = base.a
local tools             = base.t
local konsole           = base.k
local sys               = base.sys
local resources         = base.resources

/*
*   Localized lua funcs
*
*   i absolutely hate having to do this, but for squeezing out every
*   bit of performance, we need to.
*/

local pairs             = pairs
local tostring          = tostring
local istable           = istable
local isstring          = isstring
local debug             = debug
local util              = util
local string            = string
local sf                = string.format

/*
*   Localized cmd func
*
*   @source : lua\autorun\libs\calls
*   @param  : str t
*   @param  : varg { ... }
*/

local function call( t, ... )
    return rlib:call( t, ... )
end

/*
*   Localized translation func
*/

local function lang( ... )
    return base:lang( ... )
end

/*
*	prefix :: create id
*/

local function cid( id, suffix )
    local affix     = istable( suffix ) and suffix.id or isstring( suffix ) and suffix or prefix
    affix           = affix:sub( -1 ) ~= '.' and string.format( '%s.', affix ) or affix

    id              = isstring( id ) and id or 'noname'
    id              = id:gsub( '[%c%s]', '.' )

    return string.format( '%s%s', affix, id )
end

/*
*	prefix ids
*/

local function pid( str, suffix )
    local state = ( isstring( suffix ) and suffix ) or ( base and prefix ) or false
    return cid( str, state )
end

/*
*   calls :: register
*
*   grab call categories from main lib table which typically include:
*       : hooks
*       : timers
*       : commands
*       : net
*       : pubcmd
*
*   send regsitered calls from source table 
*       rlib.c[ type ] => _G.rcalls[ type ]
*
*   @param  : tbl parent
*   @param  : tbl src
*/

function base.calls:register( parent, src )
    if not parent.manifest.calls or not istable( parent.manifest.calls ) then
        base:log( 2, 'missing definition table -- aborting' )
        return
    end

    if not src or not istable( src ) then
        base:log( 2, 'cannot run calls without valid table' )
        return
    end

    for _, v in pairs( parent.manifest.calls ) do

        /*
        *   v returns call_type
        */

        local call_type = v:lower( )
        if not src[ call_type ] then
            src[ call_type ] = { }
        end

        /*
        *   build calls lib
        *
        *   loop calls and setup structure
        *   : l        =   call_id
        *   : m[ 1 ]   =   call.id
        *   : m[ 2 ]   =   desc (optional)
        *
        *   structure ex
        *       commands:
        *       rlib_command:
        *           1   : rlib.command
        *           2   : no description
        */

        for l, m in pairs( src[ call_type ] ) do
            _G.rcalls[ call_type ] = _G.rcalls[ call_type ] or { }
            if call_type ~= 'commands' then
                _G.rcalls[ call_type ][ l ]     = { tostring( m[ 1 ] ), m[ 2 ] and tostring( m[ 2 ] ) or lang( 'cmd_no_desc' ) }
            else
                _G.rcalls[ call_type ][ l ]     = m
            end
            sys.calls = ( sys.calls or 0 ) + 1
        end

    end
end

/*
*   calls :: load
*
*   takes all registered net calls and loads them to server
*
*   :   (bool) bPrefix
*       true adds lib prefix at front of all network entries
*       'rlib.network_string_id'
*
*   :   (str) affix
*       bPrefix must be true, determines what prefix to add to
*       the front of a netnw string. if none provided, lib prefix
*       will be used
*
*   @param  : bool bPrefix
*   @param  : str affix
*/

function base.calls:load( bPrefix, affix )
    base:log( 6, 'registering netlibs' )

    if not _G.rcalls[ 'net' ] then
        _G.rcalls[ 'net' ] = { }
        base:log( 6, '+ netlib calls table' )
    end

    for v in helper.get.data( _G.rcalls[ 'net' ] ) do
        if SERVER then
            local u_affix = isstring( affix ) and affix or prefix
            local call_id = bPrefix and tostring( u_affix .. v[ 1 ] ) or tostring( v[ 1 ] )

            util.AddNetworkString( call_id )
            base:log( 6, '+ net » [ %s ]', call_id )
        end
    end

    if rnet then
        hook.Run( pid( 'rnet.register' ) )
    end

    hook.Run( pid( 'calls.post' ) )
end

/*
*   calls :: validation
*
*   checks a provided call id to see if it is registered within _G.rcalls
*
*   @param  : str t
*   @return : tbl
*/

function base.calls:valid( t )
    if not t or not isstring( t ) or t == '' then
        rlib:log( 2, 'missing specified call type' )
        local response, cnt_calls, i = '', #_G.rcalls, 0
        for k, v in pairs( _G.rcalls ) do
            response = response .. k
            i = i + 1
            if i < cnt_calls then
                response = response .. ', '
            end
        end
        rlib:log( 2, 'valid types are [ %s ]', response )
        return
    end

    local data = _G.rcalls[ t ]
    if not data then
        rlib:log( 2, 'missing call type » [ %s ]', t )
        return
    end

    return data or false
end

/*
*   calls :: gcflag
*
*   returns the flag for a specified command
*
*   :   (str) cmd
*       command name
*
*   :   (str) flg_id
*       name of the flag
*
*   :   (bool) ret
*       true, 2 will return flag, desc
*
*   @ex     : rlib.calls:gcflag( 'rlib', 'all' )
*   @ex     : rlib.calls:gcflag( 'timex_list', 'active' )
*
*   @param  : str cmd
*   @param  : str flg_id
*   @param  : bool ret
*   @return : tbl
*/

function base.calls:gcflag( cmd, flg_id, ret )
    local data = self:valid( 'commands' )
    if not data then return end

    if ( cmd and data[ cmd ] and data[ cmd ].flags and flg_id and data[ cmd ].flags[ flg_id ] ) then
        local item = data[ cmd ].flags[ flg_id ]
        if not ret then
            return item.flag
        else
            return item.flag, item.desc
        end
    else
        return data
    end

    return false
end

/*
*   calls :: gcflag :: valid
*
*   returns if a provided flag is valid for the specified command
*
*   @call   : rlib.calls:gcflag_valid( 'command_name', '-arg' )
*   @ex     : rlib.calls:gcflag_valid( 'rlib_debug_clean', '-cancel' )
*
*   @param  : str cmd
*   @param  : str flag
*   @return : bool
*/

function base.calls:gcflag_valid( cmd, flag )
    local data = self:valid( 'commands' )
    if not data or not cmd or not flag then return end
    cmd = cmd:gsub( '[.]', '_' )
    if ( cmd and data[ cmd ] and data[ cmd ].flags ) then
        for key, value in pairs( data[ cmd ].flags ) do
            if not string.match( value.flag, flag ) then continue end
            return true
        end
    end
    return false
end

/*
*   calls :: post load
*
*   executed after all calls have been setup and loaded
*   typically utilized for processes such as checking for base command existence and various other tasks.
*/

local function calls_load_post( )
    local get_basecmd  = false
    local has_basecmd  = false

    for k, v in pairs( rlib.calls:get( 'commands' ) ) do
        if not v.is_base then continue end
        if has_basecmd then continue end

        has_basecmd, get_basecmd = true, v.id
    end

    sys.calls_basecmd = has_basecmd and get_basecmd or false

    if not has_basecmd then
        base:log( 2, 'missing base lib cmd »\n%s', debug.getinfo( 1, 'n' ).name )
    else
        base:log( RLIB_LOG_SYSTEM, '+ base lib cmd [ %s ]', get_basecmd )
    end
end
hook.Add( pid( 'calls.post' ), pid( 'calls.load.post' ), calls_load_post )

/*
*   calls :: get call
*
*   returns the associated call data table
*
*   call using localized function in file that you require fetching needed calls.
*
*   @ex     : rlib.calls:get( 'calltype', 'id' )
*             rlib.calls:get( 'commands', 'rcore_modules' )
*
*   @param  : str t
*   @param  : str s
*   @return : tbl
*/

function base.calls:get( t, s )
    local data = self:valid( t )
    if not data then return end

    if s and data[ s ] then
        return data[ s ]
    else
        return data
    end

    return
end

/*
*   calls :: register command
*
*   inserts a new command into base commands table which allows it to display within the base library
*   concommand, as well as execution params
*
*   this is an alternative method to registering commands that aren't provided through the module
*   manifest method
*
*   @ex     : rlib.calls:register_cmds( local_tbl_varname )
*
*   @param  : tbl params
*/

function base.calls:register_cmds( params )
    if not istable( params ) then
        base:log( 2, 'missing table params specified for new command [ %s ]', debug.getinfo( 1, 'n' ).name )
        return
    end

    for k, v in pairs( params ) do
        if not isstring( k ) then
            base:log( 2, 'invalid command id » canceling command registration [ %s ]', debug.getinfo( 1, 'n' ).name )
            continue
        end

        base.c.commands[ k ]           = v
        _G.rcalls[ 'commands' ][ k ]   = v

        sys.calls = ( sys.calls or 0 ) + 1

        base:log( 6, '+ command [ %s ]', k )
    end
end

/*
*   call
*
*   returns the associated call
*
*   call using localized function in file that you require fetching needed calls.
*   these are usually stored in the modules' manifest file
*
*   @call   : call( 'type', 'string_id' )
*
*   @ex     : call( 'commands', 'rlib_modules' )
*             call( 'hooks', 'lunera_initialize' )
*
*   @param  : str t
*   @param  : str s
*   @param  : varg { ... }
*   @return : str
*/

function base:call( t, s, ... )
    local data = base.calls:valid( t )
    if not data then return end

    if not isstring( s ) then
        rlib:log( 2, 'id missing » [ %s ]', t )
        return false
    end

    s = s:gsub( '[%p%c%s]', '_' ) -- replace punct, contrl chars, and whitespace with underscores

    if t == 'commands' then
        local ret = sf( s, ... )
        if data[ s ] then
            local cmd = s
            if ( data[ s ][ 'id' ] and isstring( data[ s ][ 'id' ] ) ) then
                cmd = data[ s ][ 'id' ]
            elseif ( data[ s ][ 1 ] and isstring( data[ s ][ 1 ] ) ) then
                cmd = data[ s ][ 1 ]
            end
            ret = sf( cmd, ... )
        end
        return ret
    else
        local ret = sf( s, ... )
        if data[ s ] then
            ret = sf( data[ s ][ 1 ], ... )
        end
        return ret
    end
end