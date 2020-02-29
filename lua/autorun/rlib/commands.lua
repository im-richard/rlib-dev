/*
*   @package        rlib
*   @author         Richard [http://steamcommunity.com/profiles/76561198135875727]
*   @copyright      (C) 2018 - 2020
*   @since          1.0.0
*   @website        https://rlib.io
*   @docs           https://docs.rlib.io
*   @file           commands.lua
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
local script            = mf.name
local cfg               = base.settings

/*
*   Localized rlib routes
*/

local helper            = base.h
local storage           = base.s
local utils             = base.u
local access            = base.a
local tools             = base.t
local konsole           = base.k
local sys               = base.sys
local timex             = timex

/*
*   Localized lua funcs
*
*   absolutely hate having to do this, but for squeezing out every bit of performance, we need to.
*/

local Color             = Color
local pairs             = pairs
local ipairs            = ipairs
local SortedPairs       = SortedPairs
local error             = error
local print             = print
local setmetatable      = setmetatable
local Vector            = Vector
local Angle             = Angle
local Entity            = Entity
local EffectData        = EffectData
local GetConVar         = GetConVar
local tonumber          = tonumber
local tostring          = tostring
local IsValid           = IsValid
local istable           = istable
local isfunction        = isfunction
local isentity          = isentity
local isnumber          = isnumber
local isstring          = isstring
local type              = type
local file              = file
local debug             = debug
local util              = util
local table             = table
local os                = os
local coroutine         = coroutine
local player            = player
local math              = math
local string            = string
local sf                = string.format
local execq             = RunString

/*
*   debug path
*/

local path_logs         = mf.paths[ 'dir_logs' ]
local path_uconn        = mf.paths[ 'dir_uconn' ]
local path_server       = mf.paths[ 'dir_server' ]

/*
*   localized http.fetch
*/

local function oort( ... )
    return http.Fetch( ... )
end

/*
*   localized http.post
*/

local function oort_post( ... )
    return http.Post( ... )
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

local function pref( id, suffix )
    local affix = istable( suffix ) and suffix.id or isstring( suffix ) and suffix or prefix
    affix = affix:sub( -1 ) ~= '.' and string.format( '%s.', affix ) or affix

    id = isstring( id ) and id or 'noname'
    id = id:gsub( '[%c%s]', '.' )

    return string.format( '%s%s', affix, id )
end

/*
*	prefix ids
*/

local function pid( str, suffix )
    local state = ( isstring( suffix ) and suffix ) or ( base and mf.prefix ) or false
    return pref( str, state )
end

/*
*   concommand :: user
*
*   manages a players access with rlib
*
*   : subargs
*       : add < player >
*       : remove < player >
*
*   @call   : rlib.user < subarg > < player >
*/

function utils.cc_user( pl, cmd, args )

    /*
    *   define command
    */

    local ccmd = base.calls:get( 'commands', 'rlib_user' )

    /*
    *   scope
    */

    if ( ccmd.scope == 1 and not base:isconsole( pl ) ) then
        access:deny_consoleonly( pl, script, ccmd.id )
        return
    end

    /*
    *   perms
    */

    if not access:bIsRoot( pl ) then return end

    /*
    *   functionality
    */

    local subarg = args and args[ 1 ] or nil
    local target = args and args[ 2 ] or false

    if not target then
        base.msg:route( pl, script, 'You must supply at least a valid partial', cfg.cmsg.clrs.target, 'player name' )
        return
    end

    local c_results, result = helper.who:name_wc( target )

    if c_results > 1 then
        base.msg:route( pl, script, 'More than one result was found, type more of the name. Place in quotes for names with spaces. Example:', cfg.cmsg.clrs.target, '\"John Doe\"' )
        return
    elseif not c_results or c_results < 1 then
        if subarg == 'remove' or subarg == '-r' then
            local users = access:getusers( )

            local cnt, user, user_name = 0, false, 'unknown'
            for k, v in pairs( users ) do
                local ply_name = v.name:lower( )
                if ( string.find( ply_name, target, 1, true ) == nil ) then continue end
                user        = k
                user_name   = v.name
                cnt         = cnt + 1
            end

            if cnt > 1 then
                base.msg:route( pl, script, 'More than one result was found, type more of the name. Place in quotes for names with spaces. Example:', cfg.cmsg.clrs.target, '\"John Doe\"' )
                return
            elseif cnt == 0 then
                base.msg:route( pl, script, 'No valid player found' )
                return
            elseif cnt == 1 then
                local bRemoved = access:deluser( user )

                if bRemoved then
                    base.msg:route( pl, script, 'Successfully removed player', cfg.cmsg.clrs.target, user_name, cfg.cmsg.clrs.msg, 'from rlib access' )
                else
                    base.msg:route( pl, script, 'No access found for player', cfg.cmsg.clrs.target, user_name )
                end
            end
        else
            base.msg:route( pl, script, 'No results found! Place in quotes for names with spaces. Example:', cfg.cmsg.clrs.target, '\"John Doe\"' )
            return
        end
    else
        if not helper.ok.ply( result[ 0 ] ) then
            base.msg:route( pl, script, 'No valid player found' )
            return
        else
            result = result[ 0 ]
            if subarg == 'add' or subarg == '-a' then
                local bExists = access:writeuser( result )

                if bExists then
                    base.msg:route( pl, script, 'user', cfg.cmsg.clrs.target, result:Name( ), cfg.cmsg.clrs.msg, 'already exists' )
                else
                    base.msg:route( pl, script, 'Successfully added player', cfg.cmsg.clrs.target, result:Name( ), cfg.cmsg.clrs.msg, 'to rlib access' )
                end
            elseif subarg == 'remove' or subarg == '-r' then
                local bRemoved = access:deluser( result )

                if bRemoved then
                    base.msg:route( pl, script, 'Successfully removed player', cfg.cmsg.clrs.target, result:Name( ), cfg.cmsg.clrs.msg, 'from rlib access' )
                else
                    base.msg:route( pl, script, 'no access found for player', cfg.cmsg.clrs.target, result:Name( ) )
                end
            elseif subarg == 'status' or subarg == '-s' then
                local bExists = access:hasuser( result )
                if not bExists then
                    base.msg:route( pl, script, cfg.cmsg.clrs.target, result:Name( ), cfg.cmsg.clrs.msg, 'does not have access' )
                else
                    base.msg:route( pl, script, cfg.cmsg.clrs.target, result:Name( ), cfg.cmsg.clrs.msg, 'has admin access' )
                end
            end

            -- update admins list for perms
            net.Start( 'rlib.user' )
            net.WriteTable( access.admins )
            net.Broadcast( )

        end
    end

end

/*
*   concommand :: debug :: clean
*
*   cleans files in debug log folder
*/

function utils.cc_debug_cleanlogs( pl, cmd, args, str )

    /*
    *   define command
    */

    local ccmd = base.calls:get( 'commands', 'rlib_debug_clean' )

    /*
    *   scope
    */

    if ( ccmd.scope == 1 and not base:isconsole( pl ) ) then
        access:deny_consoleonly( pl, script, ccmd.id )
        return
    end

    /*
    *   perms
    */

    if not access:bIsRoot( pl ) then
        access:deny_permission( pl, script, ccmd.id )
        return
    end

    /*
    *   functionality
    */

    local arg_param = args and args[ 1 ] or false
    if arg_param then
        arg_param = arg_param:lower( )
    end

    local gcf_cancel    = base.calls:gcflag( 'rlib_debug_clean', 'cancel' )
    local timer_clean   = cfg.debug.clean_delaytime

    if ( arg_param and ( arg_param == gcf_cancel ) or ( arg_param == '-cancel' or arg_param == 'cancel' ) and timex.exists( prefix .. 'debug.doclean' ) ) then
        timex.expire( prefix .. 'debug.doclean' )
        base:log( 4, lang( 'logs_clean_cancel' ) )
        return
    end

    if arg_param then
        base:log( 2, lang( 'cmd_param_invalid', timer_clean, prefix ) )
        return
    end

    base:log( 4, lang( 'logs_clean_scheduled', timer_clean, prefix, '-c' ) )

    timex.create( prefix .. 'debug.doclean', timer_clean, 1, function( )
        local files, _ = file.Find( path_logs .. '/*', 'DATA' )

        local i_del = 0
        for v in helper.get.data( files ) do
            local file_path = sf( '%s/%s', path_logs, v )
            file.Delete( file_path )

            i_del = i_del + 1
        end

        base:log( 4, lang( 'logs_clean_success', i_del, path_logs ) )
    end )

end

/*
*   concommand :: debug :: diag
*
*   checks a variety of areas to prep from dev -> production
*/

function utils.cc_debug_diag( pl, cmd, args, str )

    /*
    *   define command
    */

    local ccmd = base.calls:get( 'commands', 'rlib_debug_diag' )

    /*
    *   scope
    */

    if ( ccmd.scope == 1 and not base:isconsole( pl ) ) then
        access:deny_consoleonly( pl, script, ccmd.id )
        return
    end

    /*
    *   perms
    */

    if not access:bIsRoot( pl ) then
        access:deny_permission( pl, script, ccmd.id )
        return
    end

    /*
    *   functionality
    */

    base:console( pl, '\n' )
    base:console( pl, Color( 255, 255, 0 ), ' ' .. script, Color( 255, 0, 255 ), ' » ', Color( 255, 255, 255 ), 'Debug Diag' )
    base:console( pl, lang( 'sym_sp' ) )
    base:console( pl, Color( 255, 255, 255 ), ' Information listed below is for the developer to utilize in order to determine what state\n the current build is configured in.' )
    base:console( pl, lang( 'sym_sp' ) )

    local g0_cat = sf( '\n %s » %s', script, 'General' )
    base:console( pl, Color( 255, 0, 0 ), g0_cat .. '\n' )

    local get_state =
    {
        { id = lang( 'status_col_branch' ),         val = helper:cvar_str( 'rlib_branch', 'stable' ) },
        { id = lang( 'status_col_basecmd' ),        val = sys.calls_basecmd or lang( 'none' ) },
        { id = lang( 'status_col_debug' ),          val = cfg.debug.enabled and lang( 'opt_enabled' ) or lang( 'opt_disabled' ) },
        { id = lang( 'status_col_rnet_route' ),     val = rnet and rnet.sys.nrouter_enabled and lang( 'opt_enabled' ) or lang( 'opt_disabled' ) },
        { id = lang( 'status_col_rnet_debug' ),     val = rnet and rnet.cfg.debug and lang( 'opt_enabled' ) or lang( 'opt_disabled' ) },
        { id = lang( 'status_col_rcore' ),          val = istable( rcore ) and lang( 'opt_yes' ) or lang( 'opt_no' ) },
    }

    for m in helper.get.data( get_state ) do
        if not m.val then continue end

        local id    = tostring( m.id )
        local val   = tostring( m.val )

        local l1_d, l2_d, cs_data = '', '', ''
        l1_d        = sf( '%-20s', ' ' .. id )
        cs_data     = sf( '%-5s', ' » ' )
        l2_d        = sf( '%-15s', val )

        base:console( pl, Color( 255, 255, 0 ), l1_d, Color( 255, 0, 255 ), cs_data, Color( 255, 255, 255 ), l2_d )
    end

    local v0_cat = sf( '\n %s » %s', script, 'Versions' )
    base:console( pl, Color( 255, 0, 0 ), v0_cat .. '\n' )

    local get_versions =
    {
        { id = lang( 'col_name_lib' ),          val = base.get:versionstr( ) or 'missing' },
        { id = lang( 'col_name_spew' ),         val = base.spew and base.spew.__manifest and base.spew.__manifest.version or 'missing' },
        { id = rnet.__manifest.name,            val = rnet and rnet.__manifest and rnet.__manifest.version or 'missing' },
        { id = timex.__manifest.name,           val = timex and timex.__manifest and timex.__manifest.version or 'missing' },
        { id = rcc.__manifest.name,             val = rcc and rcc.__manifest and rcc.__manifest.version or 'missing' },
        { id = rhook.__manifest.name,           val = rhook and rhook.__manifest and rhook.__manifest.version or 'missing' },
    }

    for m in helper.get.data( get_versions ) do
        if not m.val then continue end

        local id    = tostring( m.id )
        local val   = tostring( m.val )

        local l1_d, l2_d, cs_data = '', '', ''
        l1_d        = sf( '%-20s', ' ' .. id )
        cs_data     = sf( '%-5s', ' » ' )
        l2_d        = sf( '%-15s', val )

        base:console( pl, Color( 255, 255, 0 ), l1_d, Color( 255, 0, 255 ), cs_data, Color( 255, 255, 255 ), l2_d )
    end

    /*
    *   rcore output
    */

    if not istable( rcore ) then
        base:console( pl, '\n' .. lang( 'sym_sp' ) )
        base:console( pl, Color( 255, 0, 0 ), ' \n ', Color( 255, 0, 0 ), lang( 'status_rcore_missing' ) )
        return
    end

    base:console( pl, '\n' .. lang( 'sym_sp' ) )

    local c0_cat = sf( '\n %s » %s', 'rcore', 'Demo Mode Active\n' )

    base:console( pl, Color( 255, 0, 0 ), c0_cat )

    local bIsDemo = false
    for v in helper.get.data( rcore.modules ) do
        if not v.demo and not v.demomode then continue end
        local name      = tostring( helper.str:truncate( v.name, 20, '...' ) or lang( 'err' ) )
        local ver       = tostring( v.version )
        local author    = tostring( v.author )
        local desc      = tostring( helper.str:truncate( v.desc, 40, '...' ) or lang( 'err' ) )

        local ml1_data, ml2_data, ml3_data, ml4_data, ml0_resp = '', '', '', '', ''
        ml1_data = sf( '%-20s', name )
        ml2_data = sf( '%-15s', ver )
        ml3_data = sf( '%-15s', author )
        ml4_data = sf( '%-20s', desc )
        ml0_resp = sf( '%s %s %s %s %s', ml0_resp, ml1_data, ml2_data, ml3_data, ml4_data )

        bIsDemo = true

        base:console( pl, Color( 255, 255, 0 ), ml0_resp )
    end

    if not bIsDemo then
        base:console( pl, ' No modules' )
    end

    base:console( pl, '\n' .. lang( 'sym_sp' ) )

end

/*
*   concommand :: checksum :: new
*
*   writes the lib checksums to data/rlib/checksum.txt
*/

function utils.cc_checksum_new( pl, cmd, args, str )

    /*
    *   define command
    */

    local ccmd = base.calls:get( 'commands', 'rlib_checksum_new' )

    /*
    *   scope
    */

    if ( ccmd.scope == 1 and not base:isconsole( pl ) ) then
        access:deny_consoleonly( pl, script, ccmd.id )
        return
    end

    /*
    *   perms
    */

    if not access:bIsDev( pl ) then
        access:deny_permission( pl, script, ccmd.id )
        return
    end

    local deploy = base.checksum:new( true )

    /*
    *   confirm msg to pl
    */

    base.msg:direct( pl, script, not deploy and lang( 'checksum_write_err' ) or lang( 'checksum_write_success' ) )

end

/*
*   concommand :: checksum :: verify
*
*   verifies released lib checksums with any files that may be modified on the server
*   and reports the differences
*/

function utils.cc_checksum_verify( pl, cmd, args, str )

    /*
    *   define command
    */

    local ccmd = base.calls:get( 'commands', 'rlib_checksum_verify' )

    /*
    *   scope
    */

    if ( ccmd.scope == 1 and not base:isconsole( pl ) ) then
        access:deny_consoleonly( pl, script, ccmd.id )
        return
    end

    /*
    *   perms
    */

    if not access:bIsDev( pl ) then
        access:deny_permission( pl, script, ccmd.id )
        return
    end

    /*
    *   check :: see if checksums table valid
    */

    local checksums = base.checksum:verify( )
    if not istable( checksums ) then
        base:console( pl, Color( 255, 255, 255 ), lang( 'checksum_validate_fail' ) )
        return
    end

    /*
    *   declarations
    */

    local arg_param     = args and args[ 1 ] or false
    local arg_searchstr = args and args[ 2 ] or nil

    /*
    *   flags
    */

    local gcf_all       = base.calls:gcflag( 'rlib_checksum_verify', 'all' )
    local gcf_filter    = base.calls:gcflag( 'rlib_checksum_verify', 'filter' )

    /*
    *   output :: header
    */

    local cnt = table.Count( checksums )

    base:console( pl, '\n' )
    base:console( pl, Color( 255, 255, 0 ), script, Color( 255, 0, 255 ), ' » ', Color( 255, 255, 255 ), lang( 'con_checksum_verify' ) )
    base:console( pl, lang( 'sym_sp' ) )

    /*
    *   output :: check :: files verified
    */

    if cnt == 0 then
        base:console( pl, Color( 255, 255, 255 ), lang( 'files_modified_none' ) )
        base:console( pl, lang( 'sym_sp' ) )
        return
    end

    /*
    *   output :: subheader
    */

    base:console( pl, Color( 255, 255, 255 ), lang( 'files_listed_have_been_modified' ) )
    base:console( pl, lang( 'sym_sp' ) .. '\n' )

    /*
    *   columns
    */

    local l1_l      = sf( '%-40s',    lang( 'col_file'        ) )
    local l2_l      = sf( '%-15s',    lang( 'col_verified'    ) )
    local l3_l      = sf( '%-5s',     lang( 'sym_arrow'       ) )
    local l4_l      = sf( '%-15s',    lang( 'col_current'     ) )

    base:console( pl, Color( 255, 255, 255 ), l1_l, Color( 0, 255, 0 ), l2_l, Color( 255, 255, 255 ), l3_l, Color( 255, 0, 0 ), l4_l )
    base:console( pl )

    local i = 0
    for k, v in pairs( checksums ) do
        if not v.verified or not v.current then continue end

        local verified  = v.verified:sub( -7 )
        local current   = v.current:sub( -7 )

        local l1_d      = sf( '%-40s',  k           )
        local l2_d      = sf( '%-15s',  verified    )
        local l3_d      = sf( '%-5s',   '»'         )
        local l4_d      = sf( '%-15s',  current     )

        base:console( pl, Color( 255, 255, 0 ), l1_d, Color( 0, 255, 0 ), l2_d, Color( 255, 255, 255 ), l3_d, Color( 255, 0, 0 ), l4_d )

        i = i + 1
    end

    if i > 0 then
        base:console( pl, lang( 'sym_sp' ) .. '\n' )
        base:console( pl, Color( 255, 255, 255 ), lang( 'files_modified_count', i ) )
    end

    base:console( pl, '\n' )

end

/*
*   concommand :: udm
*
*   toggles the update notification for the remainder of the session and will revert to default when 
*   the server is rebooted.
*/

function utils.cc_udm( pl, cmd, args )

    /*
    *   define command
    */

    local ccmd = base.calls:get( 'commands', 'rlib_udm' )

    /*
    *   scope
    */

    if ( ccmd.scope == 1 and not base:isconsole( pl ) ) then
        access:deny_consoleonly( pl, script, ccmd.id )
        return
    end

    /*
    *   perms
    */

    if not access:bIsRoot( pl ) then
        access:deny_permission( pl, script, ccmd.id )
        return
    end

    /*
    *   functionality
    */

    local timer_id  = prefix .. 'udm.notice'
    local status    = args and args[ 1 ] or false
    local duration  = args and args[ 2 ] or cfg.udm.checktime or 1800

    if not base:bInitialized( ) then
        base:log( 1, lang( 'lib_udm_err_noinit' ) )
        return
    end

    /*
    *   param :: run updater
    */

    if status and status == 'run' then
        local task_udm = coroutine.create( function( )
            local branch = sf( mf.astra.branch, helper:cvar_str( 'rlib_branch', 'stable' ) )
            base.udm:check( branch )
        end )
        coroutine.resume( task_udm )
        return
    end

    if status then
        local param_status = helper.util:toggle( status )
        if param_status then
            if timex.exists( timer_id ) then
                local next_chk = timex.remains( timer_id )
                next_chk = timex.secs.sh_simple( next_chk, false, true )
                base:log( 4, lang( 'lib_udm_nextchk', next_chk ) )
                return
            end

            if duration and not helper:bIsNum( duration ) then
                base:log( 2, lang( 'lib_udm_bad_dur' ) )
                return
            end

            base:log( 4, lang( 'lib_udm_started', duration ) )

            base.udm:Run( duration )
        else
            timex.expire( timer_id )
            base:log( 4, lang( 'lib_udm_stopped', duration ) )
        end
    else
        if timex.exists( timer_id ) then
            local next_chk = timex.remains( timer_id )
            next_chk = timex.secs.sh_simple( next_chk, false, true )
            base:log( 4, lang( 'lib_udm_active', next_chk ) )
            return
        else
            base:log( 1, lang( 'lib_udm_inactive' ) )
        end
    end

end

/*
*   concommand :: calls
*
*   returns a list of all registered calls associated to rlib / rcore
*
*   @usage : rlib.calls <returns all calls>
*   @usage : rlib.calls rlib <returns rlib only>
*   @usage : rlib.calls -s termhere <returns entries matching term>
*   @usage : rlib.calls -r <returns raw output>
*/

function utils.cc_calls( pl, cmd, args )

    /*
    *   define command
    */

    local ccmd = base.calls:get( 'commands', 'rlib_calls' )

    /*
    *   scope
    */

    if ( ccmd.scope == 1 and not base:isconsole( pl ) ) then
        access:deny_consoleonly( pl, script, ccmd.id )
        return
    end

    /*
    *   perms
    */

    if not access:bIsRoot( pl ) then return end

    /*
    *   functionality
    */

    local arg_param     = args and args[ 1 ] or false
    local arg_searchstr = args and args[ 2 ] or nil
    local i_entries     = 0

    local output = sf( '\n\n [%s] :: call definitions', script )
    if arg_param then
        if arg_param == script then
            output = sf( '\n\n [%s] :: call definitions [ %s library only ]', script, script )
        elseif arg_param == '-r' then
            output = sf( '\n\n [%s] :: call definitions :: raw', script, script )
        end
    end

    base:console( pl, output )

    /*
    *   loop calls table
    */

    local cat_islisted, cat_id = false, ''
    local tbl_calls = _G.rcalls

    if arg_param then
        if arg_param == script then
            tbl_calls = rlib.c
        else
            if arg_param == '-s' and arg_searchstr then
                base:console( pl, Color( 255, 0, 0 ), ' ' .. lang( 'search_term', arg_searchstr ) )
            elseif arg_param == '-r' then
                base:console( pl, Color( 255, 0, 0 ), ' ' .. lang( 'search_raw' ) )
                helper.p_table( tbl_calls )
                return
            end
        end
    end

    for a, b in pairs( tbl_calls ) do

        if a ~= cat_id then
            cat_islisted = false
        end

        for k, v in pairs( b ) do

            if not cat_islisted then
                local l_category = sf( ' %s', a )
                base:console( pl, '\n' .. lang( 'sym_sp' ) )

                local l1_l      = sf( '%-15s', l_category )
                local l2_l      = sf( '%-35s', lang( 'col_id' ) )
                local l3_l      = sf( '%-35s', lang( 'col_data' ) )
                local l4_l      = sf( '%s %s %s', l1_l, l2_l, l3_l )

                base:console( pl, Color( 255, 255, 255 ), l4_l )
                base:console( pl, lang( 'sym_sp' ) )

                cat_islisted, cat_id = true, a
            end

            if istable( v ) then
                local i = helper.countdata( v, 1 )( )

                local id, cnt_fields = '', 0
                for l, m in pairs( v ) do
                    if arg_searchstr and not string.match( k, arg_searchstr ) then continue end
                    cnt_fields = cnt_fields + 1

                    id = k
                    if cnt_fields ~= 1 then id = '' end

                    local l1_d, l2_d, l3_d, c0_resp = '', '', '', ''
                    l1_d = sf( '%-15s', tostring( '' ) )
                    l2_d = sf( '%-35s', tostring( id ) )
                    l3_d = sf( '%-35s', lang( 'missing_item' , tostring( l ) ) )

                    if m ~= '' then
                        l3_d = sf( '%-35s', tostring( l ) .. ' : ' .. helper.str:truncate( tostring( m ), 60, '...' ) )
                    end

                    c0_resp = sf( '%s%s %s %s', c0_resp, l1_d, l2_d, l3_d )

                    if cnt_fields == i then
                        i_entries = i_entries + 1
                        c0_resp     = c0_resp .. '\n'
                        cnt_fields  = 0
                    end

                    base:console( pl, Color( 255, 255, 0 ), c0_resp )
                end
            elseif isstring( v ) then
                if not arg_searchstr or arg_searchstr and string.match( v, arg_searchstr ) then
                    local l1_d, l2_d, l3_d, c0_resp = '', '', '', ''
                    l1_d = sf( '%-15s', tostring( '' ) )
                    l2_d = sf( '%-35s', tostring( k ) )
                    l3_d = sf( '%-35s', tostring( v ) )

                    c0_resp = sf( '%s%s %s %s', c0_resp, l1_d, l2_d, l3_d )

                    i_entries = i_entries + 1
                    base:console( pl, Color( 255, 255, 0 ), c0_resp )
                end
            end

        end

    end

    base:console( pl, '\n' .. lang( 'sym_sp' ) )
    local c_ftr = sf( lang( 'calls_found_cnt', i_entries ) )
    base:console( pl, Color( 0, 255, 0 ), c_ftr )
    base:console( pl, lang( 'sym_sp' ) )

end

/*
*   concommand :: modules :: reroute
*
*   in the event that someone types 'rlib.modules', this command will redirect them to the proper 
*   'rcore.modules'
*/

function utils.cc_modules_reroute( pl, cmd, args )

    /*
    *   define command
    */

    local ccmd = base.calls:get( 'commands', 'rlib_modules' )

    /*
    *   scope
    */

    if ( ccmd.scope == 1 and not base:isconsole( pl ) ) then
        access:deny_consoleonly( pl, script, ccmd.id )
        return
    end

    /*
    *   perms
    */

    if not access:bIsRoot( pl ) then return end

    /*
    *   functionality
    */

    if not istable( rcore ) then
        base:console( pl, Color( 255, 0, 0 ), ' ', Color( 255, 0, 0 ), lang( 'reroute_rcore_missing' ) )
        return
    end

    rcore.cc_modules( pl, cmd, args, str )
end

/*
*   concommand :: tools :: asay
*
*   sends a message to all players in chat who have the permission 'rlib_asay'
*   similar to ulx asay
*/

function utils.cc_tools_asay( pl, cmd, args )

    /*
    *   define command
    */

    local ccmd = base.calls:get( 'commands', 'rlib_asay' )

    /*
    *   check :: permissions
    */

    if ( ccmd.no_console and base:isconsole( pl ) ) then
        access:deny_console( pl, script, ccmd.id )
        return
    end

    /*
    *   perms
    */

    if not access:bIsRoot( pl ) then
        access:deny_permission( pl, script, ccmd.id )
        return
    end

    /*
    *   functionality
    */

    local asay_message = table.concat( args, ' ' )

    /*
    *   check if asay str empty; return error
    */

    if helper.str:isempty( asay_message ) then
        base.msg:route( pl, false, 'asay', 'cannot send empty message' )
        return
    end

    /*
    *   run asay hook
    */

    hook.Run( 'asay.broadcast', pl, asay_message )

end

/*
*   concommand :: tools :: pco
*
*   player client optimizations, which sets specific command variables for the calling player which 
*   helps increase frames ( if enabled )
*/

function utils.cc_tools_pco( pl, cmd, args )

    /*
    *   define command
    */

    local ccmd = base.calls:get( 'commands', 'rlib_tools_pco' )

    /*
    *   check :: permissions
    */

    if ( ccmd.no_console and base:isconsole( pl ) ) then
        access:deny_console( pl, script, ccmd.id )
        return
    end

    /*
    *   perms
    */

    if not access:bIsRoot( pl ) then
        access:deny_permission( pl, script, ccmd.id )
        return
    end

    /*
    *   functionality
    */

    local arg_toggle    = args and args[ 1 ]
    local arg_state     = helper.util:toggle( arg_toggle )

    -- no arg specified, simply return pco status
    if not arg_toggle then
        local state = pl:GetNWBool( prefix .. 'tools.pco' ) and lang( 'opt_enabled' ) or lang( 'opt_disabled' )
        base.msg:route( pl, false, script, 'pco is currently', cfg.cmsg.clrs.target, state )
        return
    end

    tools.pco:Run( pl, arg_state )

end

/*
*   concommand :: tools :: rdo
*
*   set the rendermode on entities
*
*   @usage  : rlib.rdo <returns state>
*   @usage  : rlib.rdo enable|disable <set rdo active state>
*/

function utils.cc_tools_rdo( pl, cmd, args )

    /*
    *   define command
    */

    local ccmd = base.calls:get( 'commands', 'rlib_tools_rdo' )

    /*
    *   scope
    */

    if ( ccmd.scope == 1 and not base:isconsole( pl ) ) then
        access:deny_consoleonly( pl, script, ccmd.id )
        return
    end

    /*
    *   perms
    */

    if not access:bIsRoot( pl ) then return end

    /*
    *   functionality
    */

    local arg_toggle    = args and args[ 1 ]
    local arg_state     = helper.util:toggle( arg_toggle )

    if not arg_toggle then
        local state = cfg.rdo.enabled and lang( 'opt_enabled' ) or lang( 'opt_disabled' )
        base.msg:route( pl, false, script, 'rdo »', cfg.cmsg.clrs.target, state )
        return
    end

    cfg.rdo.enabled = arg_state
    rdo_rendermode( arg_state )

    local set_state = arg_state and lang( 'opt_enabled' ) or lang( 'opt_disabled' )
    base.msg:route( pl, false, script, 'rdo »', cfg.cmsg.clrs.target, set_state )

end

/*
*   concommand :: setup
*
*   sets up rlib after the initial install
*/

function utils.cc_setup( pl, cmd, args )

    /*
    *   define command
    */

    local ccmd = base.calls:get( 'commands', 'rlib_setup' )

    /*
    *   scope
    */

    if ( ccmd.scope == 1 and not base:isconsole( pl ) ) then
        access:deny_consoleonly( pl, script, ccmd.id )
        return
    end

    /*
    *   perms
    */

    if not access:bIsRoot( pl ) then
        access:deny_permission( pl, script, ccmd.id )
        return
    end

    /*
    *   check :: command disabled
    */

    if not ccmd.enabled then
        base:log( 3, lang( 'setup_cmd_disabled' ) )
        return
    end

    /*
    *   check :: already has root usr
    */

    local bHasRoot, rootuser = access:getroot( )
    if bHasRoot then
        base.msg:route( pl, false, script, lang( 'setup_root_exists' ), Color( 255, 255, 0 ), ( rootuser and rootuser.name ) or 'none' )
        return
    end

    /*
    *   check :: server initialized
    */

    if not base:bInitialized( ) then
        base.msg:route( pl, false, script, lang( 'lib_initialized' ) )
        return
    end

    /*
    *   functionality
    */

    local target = args and args[ 1 ] or false

    if not target then
        base.msg:route( pl, false, script, lang( 'user_find_errmsg' ) )
        return
    end

    local c_results, result = helper.who:name_wc( target )

    if c_results > 1 then
        base.msg:route( pl, false, script, lang( 'user_find_multires' ), cfg.cmsg.clrs.target, lang( 'user_find_quotes_ex' ) )
        return
    elseif not c_results or c_results < 1 then
        if sys.connections == 1 then
            base.msg:route( pl, false, script, lang( 'user_find_nores_one' ) )
        else
            base.msg:route( pl, false, script, lang( 'user_find_nores' ), cfg.cmsg.clrs.target, lang( 'user_find_quotes_ex' ) )
        end
        return
    else
        if not helper.ok.ply( result[ 0 ] ) then
            if sys.connections == 1 then
                base.msg:route( pl, false, script, lang( 'user_find_noply_one' ) )
            else
                base.msg:route( pl, false, script, lang( 'user_find_noply' ) )
            end
            return
        else
            result = result[ 0 ]
            local bExists = access:writeuser( result )

            if bExists then return end

            base:console( pl, ' ' )
            base:console( pl, Color( 255, 255, 0 ), ' » Library Setup\n\n ', color_white, 'User ', Color( 255, 0, 255 ), result:Name( ), color_white, ' has been added with ', Color( 0, 255, 0 ), 'root access', color_white, ' and is protected.' )
            base:console( pl, ' ' )

            -- update admins list for perms
            net.Start       ( 'rlib.user' )
            net.WriteTable  ( access.admins )
            net.Broadcast   ( )

            base:setup_killtask( )
        end
    end

end

/*
*   concommand :: status
*
*   returns various types of information related to installed packages, library stats, debugging, 
*   installed modules and base core module
*/

function utils.cc_status( pl, cmd, args )

    /*
    *   define command
    */

    local ccmd = base.calls:get( 'commands', 'rlib_status' )

    /*
    *   scope
    */

    if ( ccmd.scope == 1 and not base:isconsole( pl ) ) then
        access:deny_consoleonly( pl, script, ccmd.id )
        return
    end

    /*
    *   perms
    */

    if not access:bIsRoot( pl ) then
        access:deny_permission( pl, script, ccmd.id )
        return
    end

    /*
    *   header output
    */

    base:console( pl, '\n' )

    local id_cat     = script or lang( 'lib_name' )
    local id_subcat  = ccmd.title or ccmd.name or lang( 'untitled' )

    base:console( pl, sf( ' %s » %s', id_cat, id_subcat ) )

    /*
    *   manifest output
    */

    base:console( pl, '\n' .. lang( 'sym_sp' ) )

    local l0_l      = sf( ' %s » %s', script, lang( 'manifest' ) )
    local l1_l      = sf( '%-20s', l0_l )
    local l2_l      = sf( '%-15s', '' )
    local l3_l      = sf( '%s %s', l1_l, l2_l )

    base:console( pl, Color( 255, 0, 0 ), l3_l )
    base:console( pl )

    local data_about = helper.str:wordwrap( mf.about, 64 )

    for l, m in SortedPairs( mf ) do
        if istable( m ) then continue end

        local id    = tostring( l ) or nil
        local val   = tostring( m ) or lang( 'missing' )

        local l1_d, l2_d, s1_l = '', '', ''
        if id == 'about' then
            l1_d        = sf( '%-20s', ' ' .. tostring( id ) )
            s1_l        = sf( '%-5s', ' » ' )
            l2_d        = sf( '%-15s', data_about[ 1 ] )

            base:console( pl, Color( 255, 255, 0 ), l1_d, Color( 255, 0, 255 ), s1_l, Color( 255, 255, 255 ), l2_d )

            for k, v in pairs( data_about ) do
                if k == 1 then continue end -- hide the first line, already called in the initial col
                val = tostring( v ) or lang( 'missing' )

                local l3_d = sf( '%-20s', '' )
                local l4_d = sf( '%-15s', val )

                base:console( pl, Color( 255, 255, 0 ), l3_d, Color( 255, 255, 255 ), '    ', Color( 255, 255, 255 ), l4_d )
            end
        else
            val = ( id == 'released' and os.date( '%m.%d.%Y', val ) ) or val

            l1_d        = sf( '%-20s', ' ' .. id )
            s1_l        = sf( '%-5s', ' » ' )
            l2_d        = sf( '%-15s', val )

            base:console( pl, Color( 255, 255, 0 ), l1_d, Color( 255, 0, 255 ), s1_l, Color( 255, 255, 255 ), l2_d )
        end
    end

    /*
    *   appends version to the manifest output
    */

    local l1_d          = sf( '%-20s', ' ' .. lang( 'label_version' ) )
    local s1_l          = sf( '%-5s', ' » ' )
    local l2_d          = sf( '%-15s', base.get:versionstr( ) )

    base:console( pl, Color( 255, 255, 0 ), l1_d, Color( 255, 0, 255 ), s1_l, Color( 255, 255, 255 ), l2_d )

    base:console( pl, '\n\n' .. lang( 'sym_sp' ) )

    /*
    *   stats output
    */

    local c0_cat        = sf( ' %s » %s', script, lang( 'stats' ) )
    local l1_l          = sf( '%-20s', c0_cat )
    local l2_l          = sf( '%-15s', '' )
    local l3_l          = sf( '%s %s', l1_l, l2_l )

    base:console( pl, Color( 255, 0, 0 ), l3_l )
    base:console( pl )

    local tbl_stats =
    {
        { id = lang( 'status_col_os' ),             val = base.get:os( ) },
        { id = lang( 'status_col_gm' ),             val = base.get:gm( true ) },
        { id = lang( 'status_col_branch' ),         val = helper:cvar_str( 'rlib_branch', 'stable' ) },
        { id = lang( 'status_col_admins' ),         val = table.Count( access.admins ) or 0 },
        { id = lang( 'status_col_calls' ),          val = lang( 'stats_reg_cnt', sys.calls or 0 ) },
        { id = lang( 'status_col_basecmd' ),        val = sys.calls_basecmd or lang( 'none' ) },
        { id = lang( 'status_col_init' ),           val = sys.initialized and lang( 'opt_yes' ) or lang( 'opt_no' ) },
        { id = lang( 'status_col_conncnt' ),        val = sys.connections or 0 },
        { id = lang( 'status_col_debug_mode' ),     val = cfg.debug.enabled and lang( 'opt_enabled' ) or lang( 'opt_disabled' ) },
        { id = lang( 'status_col_logs' ),           val = ( sys.log_ct or 0 ) .. ' ( ' .. ( sys.log_sz or 0 ) .. ' )' or 0 },
        { id = lang( 'status_col_uconn' ),          val = ( sys.uconn_ct or 0 ) .. ' ( ' .. ( sys.uconn_sz or 0 ) .. ' )' or 0 },
        { id = lang( 'status_col_history' ),        val = ( sys.history_ct or 0 ) .. ' ( ' .. ( sys.history_sz or 0 ) .. ' )' or 0 },
        { id = lang( 'status_col_rnet_route' ),     val = rnet and rnet.sys.nrouter_enabled and lang( 'opt_enabled' ) or lang( 'opt_disabled' ) },
        { id = lang( 'status_col_rcore' ),          val = istable( rcore ) and lang( 'opt_yes' ) or lang( 'opt_no' ) },
        { id = lang( 'status_col_starttime' ),      val = sys.starttime or 0 },
        { id = lang( 'status_col_startcnt' ),       val = sys.startups or 0 },
        { id = lang( 'status_col_uptime' ),         val = timex.secs.sh_cols( SysTime( ) - sys.uptime ) },
        { id = lang( 'status_col_validated' ),      val = sys.validate and lang( 'opt_yes' ) or lang( 'opt_no' ) },
    }

    for m in helper.get.data( tbl_stats ) do
        if not m.val then continue end

        local id, val = tostring( m.id ), tostring( m.val )

        local l1_d, l2_d, cs_data = '', '', ''
        l1_d            = sf( '%-20s', ' ' .. id )
        cs_data         = sf( '%-5s', ' » ' )
        l2_d            = sf( '%-15s', val )

        base:console( pl, Color( 255, 255, 0 ), l1_d, Color( 255, 0, 255 ), cs_data, Color( 255, 255, 255 ), l2_d )
    end

    base:console( pl, '\n\n' .. lang( 'sym_sp' ) )

    /*
    *   paths
    */

    local s0_cat        = sf( ' %s » %s', script, lang( 'storage' ) )
    local s1_lbl        = sf( '%-20s', s0_cat )
    local s2_lbl        = sf( '%-15s', '' )
    local s0_lbl        = sf( '%s %s', s1_lbl, s2_lbl )

    base:console( pl, Color( 255, 0, 0 ), s0_lbl )
    base:console( pl )

    for l, m in SortedPairs( mf.paths ) do
        local id        = tostring( l )
        local val       = tostring( m )

        local s1_data, s2_data, ss_data = '', '', ''
        s1_data         = sf( '%-20s', ' ' .. id )
        ss_data         = sf( '%-5s', ' » ' )
        s2_data         = sf( '%-15s', val )

        base:console( pl, Color( 255, 255, 0 ), s1_data, Color( 255, 0, 255 ), ss_data, Color( 255, 255, 255 ), s2_data )
    end

    base:console( pl, '\n\n' .. lang( 'sym_sp' ) )

    /*
    *   packages output
    */

    local pk0_cat       = sf( ' %s » %s', script, lang( 'packages' ) )
    local pk1_lbl       = sf( '%-20s', pk0_cat )
    local pk2_lbl       = sf( '%-20s', '' )
    local pk3_lbl       = sf( '%-25s', '' )
    local pk0_lbl       = sf( '%s %s %s', pk1_lbl, pk2_lbl, pk3_lbl )

    base:console( pl, Color( 255, 0, 0 ), pk0_lbl )
    base:console( pl, lang( 'sym_sp' ) )

    for i, m in SortedPairs( base.pkgs.index ) do
        local id        = tostring( i )
        local ver       = sf( '%s : %s', m.version, m.build )
        local desc      = tostring( helper.str:truncate( m.desc, 50, '...' ) or lang( 'none' ) )

        local pk1_data, pk2_data, pks_data = '', '', ''
        pk1_data        = sf( '%-20s', ' ' .. id )
        pks_data        = sf( '%-5s', ' » ' )
        pk2_data        = sf( '%-20s', ver )
        pk3_data        = sf( '%-25s', desc )

        base:console( pl, Color( 255, 255, 0 ), pk1_data, Color( 255, 0, 255 ), pks_data, Color( 255, 255, 255 ), pk2_data, Color( 255, 255, 255 ), pk3_data )
    end

    base:console( pl, '\n\n' .. lang( 'sym_sp' ) )

    /*
    *   rcore output
    */

    if not istable( rcore ) then
        base:console( pl, Color( 255, 0, 0 ), ' ', Color( 255, 0, 0 ), lang( 'status_rcore_missing' ) )
        return
    end

    local rc0_cat = sf( ' rcore » %s', script, lang( 'modules' ) )
    local rc1_lbl = sf( '%-20s', rc0_cat )
    local rc2_lbl = sf( '%-15s', '' )
    local rc0_lbl = sf( '%s %s', rc1_lbl, rc2_lbl )

    base:console( pl, Color( 255, 0, 0 ), rc0_lbl )
    base:console( pl )

    local tbl_modules =
    {
        { id = lang( 'stats_total' ),         val = rcore.sys.modules.total or 0 },
        { id = lang( 'stats_registered' ),    val = rcore.sys.modules.registered or 0 },
        { id = lang( 'stats_errors' ),        val = rcore.sys.modules.err or 0 },
        { id = lang( 'stats_disabled' ),      val = rcore.sys.modules.disabled or 0 },
    }

    for m in helper.get.data( tbl_modules ) do
        if not m.val then continue end

        local id    = tostring( m.id )
        local val   = tostring( m.val )

        local rc1_data, rc2_data, rcs_data = '', '', ''
        rc1_data = sf( '%-20s', ' ' .. id )
        rcs_data = sf( '%-5s', ' » ' )
        rc2_data = sf( '%-15s', val )

        base:console( pl, Color( 255, 255, 0 ), rc1_data, Color( 255, 0, 255 ), rcs_data, Color( 255, 255, 255 ), rc2_data )
    end

    /*
    *   rcore :: module list
    */

    local ml0_lbl = '\n\n'
    local ml1_lbl = sf( '%-20s', lang( 'col_module' ) )
    local ml2_lbl = sf( '%-15s', lang( 'col_version' ) )
    local ml3_lbl = sf( '%-15s', lang( 'col_author' ) )
    local ml4_lbl = sf( '%-20s', lang( 'col_desc' ) )
    local ml5_lbl = sf( '%-70s', lang( 'sym_sp' ) )
    ml0_lbl = sf( ' %s %s %s %s %s\n%s', ml0_lbl, ml1_lbl, ml2_lbl, ml3_lbl, ml4_lbl, ml5_lbl )

    base:console( pl, ml0_lbl )

    local clr_status = Color( 255, 255, 0 )
    for v in helper.get.data( rcore.modules ) do
        clr_status      = not v.enabled and Color( 255, 0, 0 ) or clr_status

        local name      = tostring( helper.str:truncate( v.name, 20, '...' ) or lang( 'err' ) )
        local ver       = tostring( rcore:module_ver2str( v ) )
        local author    = tostring( v.author )
        local desc      = tostring( helper.str:truncate( v.desc, 40, '...' ) or lang( 'err' ) )

        local ml1_data, ml2_data, ml3_data, ml4_data, ml0_resp = '', '', '', '', ''
        ml1_data = sf( '%-20s', name )
        ml2_data = sf( '%-15s', ver )
        ml3_data = sf( '%-15s', author )
        ml4_data = sf( '%-20s', desc )
        ml0_resp = sf( '%s %s %s %s %s', ml0_resp, ml1_data, ml2_data, ml3_data, ml4_data )

        base:console( pl, clr_status, ml0_resp )
    end

end

/*
*   concommand :: list packages
*
*   returns a list of installed / running packages
*/

function utils.cc_packages( pl, cmd, args )

    /*
    *   define command
    */

    local ccmd = base.calls:get( 'commands', 'rlib_packages' )

    /*
    *   scope
    */

    if ( ccmd.scope == 1 and not rlib:isconsole( pl ) ) then
        access:deny_consoleonly( pl, mf.name, ccmd.id )
        return
    end

    /*
    *   perms
    */

    if not access:bIsRoot( pl ) then
        access:deny_permission( pl, mf.name, ccmd.id )
        return
    end

    /*
    *   functionality
    */

    local id_cat     = script or lang( 'lib_name' )
    local id_subcat  = ccmd.title or ccmd.name or lang( 'untitled' )

    base:console( pl, '\n' )

    local c0_lbl = sf( ' %s » %s', id_cat, id_subcat )
    base:console( pl, Color( 255, 0, 0 ), c0_lbl )

    local output    = sf( '%-70s', ' -------------------------------------------------------------------------------------------\n' )
    local l1_l      = sf( '%-15s', lang( 'col_package' )   )
    local l2_l      = sf( '%-15s', lang( 'col_version' )   )
    local l3_l      = sf( '%-15s', lang( 'col_author' )    )
    local l4_l      = sf( '%-20s', lang( 'col_desc' )      )
    local l5_l      = sf( '%-70s', ' -------------------------------------------------------------------------------------------' )
    output          = output .. sf( ' %s %s %s %s\n%s\n', l1_l, l2_l, l3_l, l4_l, l5_l )

    base:console( pl, output )

    for v in helper.get.data( base.pkgs.index ) do
        local l1_d, l2_d, l3_d, l4_d, output_data = '', '', '', '', ''
        l1_d = sf( '%-15s', tostring( helper.str:truncate( v.name, 20, '...' ) or lang( 'err' ) ) )
        l2_d = sf( '%-15s', tostring( v.version ) or lang( 'err' ) )
        l3_d = sf( '%-15s', tostring( v.author ) or lang( 'err' ) )
        l4_d = sf( '%-20s', tostring( helper.str:truncate( v.desc, 40, '...' ) or lang( 'err' ) ) )
        output_data = output_data .. sf( ' %s %s %s %s', l1_d, l2_d, l3_d, l4_d )

        base:console( pl, Color( 255, 255, 0 ), output_data )
    end

    base:console( pl, '\n ' .. lang( 'sym_sp' ) )

end

/*
*   concommand :: license
*
*   returns license information associated with the library
*/

function utils.cc_license( pl, cmd, args )

    /*
    *   define command
    */

    local ccmd = base.calls:get( 'commands', 'rlib_license' )

    /*
    *   scope
    */

    if ( ccmd.scope == 1 and not base:isconsole( pl ) ) then
        access:deny_consoleonly( pl, script, ccmd.id )
        return
    end

    /*
    *   perms
    */

    if not access:bIsRoot( pl ) then
        access:deny_permission( pl, script, ccmd.id )
        return
    end

    /*
    *   functionality
    */

    base:console( pl, '\n' )

    local id_cat        = script or lang( 'lib_name' )
    local id_subcat     = ccmd.title or ccmd.name or lang( 'untitled' )

    local l1_l          = sf( ' %s » %s', id_cat, id_subcat )
    local l2_l          = sf( '%-15s', '' )
    local l3_l          = sf( '%s %s', l1_l, l2_l )

    base:console( pl, Color( 255, 0, 0 ), l3_l )
    base:console( pl, lang( 'sym_sp' ) )

    local data_about = helper.str:wordwrap( mf.license.text, 72 )

    for l, m in SortedPairs( mf.license ) do
        if istable( m ) then continue end

        local id    = tostring( l ) or nil
        local val   = tostring( m ) or lang( 'missing' )

        local l1_d, l2_d, s1_l = '', '', ''
        if id == 'text' then
            l1_d    = sf( '%-10s', ' ' .. tostring( id ) )
            s1_l    = sf( '%-5s', ' » ' )
            l2_d    = sf( '%-15s', data_about[ 1 ] )

            base:console( pl, Color( 255, 255, 0 ), l1_d, Color( 255, 0, 255 ), s1_l, Color( 255, 255, 255 ), l2_d )

            for k, v in pairs( data_about ) do
                if k == 1 then continue end -- hide first line
                val = tostring( v ) or lang( 'missing' )

                local l3_d = sf( '%-10s', '' )
                local l4_d = sf( '%-15s', val )

                base:console( pl, Color( 255, 255, 0 ), l3_d, Color( 255, 255, 255 ), '    ', Color( 255, 255, 255 ), l4_d )
            end
            base:console( pl, '' )
        else
            l1_d    = sf( '%-10s', ' ' .. id )
            s1_l    = sf( '%-5s', ' » ' )
            l2_d    = sf( '%-15s', val )

            base:console( pl, Color( 255, 255, 0 ), l1_d, Color( 255, 0, 255 ), s1_l, Color( 255, 255, 255 ), l2_d )
        end

    end

    base:console( pl, lang( 'sym_sp' ) )

end

/*
*   concommand :: check oort
*
*   checks the status of oort
*/

function utils.cc_oort( pl, cmd, args )

    /*
    *   define command
    */

    local ccmd = base.calls:get( 'commands', 'rlib_oort' )

    /*
    *   scope
    */

    if ( ccmd.scope == 1 and not base:isconsole( pl ) ) then
        access:deny_consoleonly( pl, script, ccmd.id )
        return
    end

    /*
    *   perms
    */

    if not access:bIsDev( pl ) then
        access:deny_permission( pl, script, ccmd.id )
        return
    end

    /*
    *   functionality
    */

    local has_oort = oort and lang( 'opt_enabled' ) or lang( 'opt_disabled' )
    base.msg:route( pl, false, script, 'Oort Engine', cfg.cmsg.clrs.target, '[' .. has_oort .. ']' )
end

/*
*   concommand :: cancel restart
*
*   allows for a player/console to cancel a server restart using either the restart concommand or timed.
*/

local function restart_cancel( pl )
    local bIsActive = false
    local timers =
    {
        prefix .. 'timer.srv.restart',
        prefix .. 'timer.srv.restart.delay',
        prefix .. 'timer.srv.restart.delay.s1',
        prefix .. 'timer.srv.restart.delay.s2',
        prefix .. 'timer.srv.restart.delay.s3.p1'
    }

    for v in helper.get.data( timers ) do
        if not timex.exists( v ) then continue end
        timex.expire( v )
        bIsActive = true
    end

    hook.Remove( 'Tick', prefix .. 'timer.srv.restart' )

    if not bIsActive then
        rlib:log( 1, lang( 'restart_none_active' ) )
        return false
    end

    local admin_name = base:isconsole( pl ) and lang( 'console' ) or pl:Name( )

    base.msg:route( nil, true, script, 'Server restart', cfg.cmsg.clrs.target_tri, 'CANCELLED' )
    storage:log( 7, false, '[ %s ] » cancelled an active server restart', admin_name )
    rlib:log( 4, 'server restart cancelled by player [ %s ]', admin_name )

    return false
end

/*
*   concommand :: server restart
*
*   gives a counter in public chat which forces a server restart after timer expires
*/

function utils.cc_restart( pl, cmd, args )

    /*
    *   define command
    */

    local ccmd = base.calls:get( 'commands', 'rlib_restart' )

    /*
    *   scope
    */

    if ( ccmd.scope == 1 and not base:isconsole( pl ) ) then
        access:deny_consoleonly( pl, script, ccmd.id )
        return
    end

    if not access:bIsRoot( pl ) then
        access:deny_permission( pl, script, ccmd.id )
        return
    end

    /*
    *   functionality
    */

    local restart_timer = 5
    local arg_param = args and args[ 1 ] or false

    if arg_param then
        arg_param = arg_param:lower( )
    end

    local gcf_cancel = base.calls:gcflag( 'rlib_restart', 'cancel' )

    if ( arg_param and ( arg_param == gcf_cancel ) or ( arg_param == '-cancel' or arg_param == 'cancel' ) ) then
        restart_cancel( pl )
        return false
    end

    if not timex.exists( prefix .. 'timer.srv.restart' ) then
        local admin_name = base:isconsole( pl ) and lang( 'console' ) or pl:Name( )

        storage:log( 7, false, '[ %s ] » forced a server restart', admin_name )
        rlib:log( 4, '[ %s ] » forced a server restart', admin_name )

        timex.create( prefix .. 'timer.srv.restart', restart_timer, 1, function( )
            rlib:log( 4, lang( 'restart_now' ) )
            for v in helper.get.ents( ) do v:SetPos( Vector( 99999999999999999, 0, 0 ) ) end
        end )

        base.msg:route( nil, true, script, 'Server restart in', cfg.cmsg.clrs.target_tri, tostring( restart_timer ), cfg.cmsg.clrs.msg, 'seconds' )
    end
end

/*
*   concommand :: timed server restart
*
*   gives a counter in public chat which forces a server restart after timer expires
*   yes we know the method of used to restart is 'hacky', but most servers utilize some type of hosting 
*   that auto-detects a downed server and restarts it. this method basically crashes the server and then 
*   the hosting servers take over.
*/

function utils.cc_timed_restart( pl, cmd, args )

    /*
    *   define command
    */

    local ccmd = base.calls:get( 'commands', 'rlib_trestart' )

    /*
    *   scope
    */

    if ( ccmd.scope == 1 and not base:isconsole( pl ) ) then
        access:deny_consoleonly( pl, script, ccmd.id )
        return
    end

    if not access:bIsRoot( pl ) then
        access:deny_permission( pl, script, ccmd.id )
        return
    end

    /*
    *   functionality
    */

    local arg_time  = args and args[ 1 ] or 60
    local arg_param = arg_time

    if arg_param then
        arg_param = arg_param:lower( )
    end

    local gcf_cancel = base.calls:gcflag( 'rlib_trestart', 'cancel' )

    if ( arg_param and ( arg_param == gcf_cancel ) or ( arg_param == '-cancel' or arg_param == 'cancel' ) ) then
        restart_cancel( pl )
        return false
    end

    local time_step2    = arg_time / 2 -- half of original arg time
    local timex_cd      = 10 -- when to start the second-by-second last countdown

    if tonumber( arg_time ) > 300 then
        base.msg:route( pl, false, 'RESTART', 'Forced restart time cannot exceed', cfg.cmsg.clrs.target_tri, '300', cfg.cmsg.clrs.msg, 'seconds' )
        return
    end

    local step2_OK, step3_OK = false, false

    if not timex.exists( prefix .. 'timer.srv.restart.delay' ) then

        local admin_name = base:isconsole( pl ) and lang( 'console' ) or pl:Name( )

        base.msg:route( nil, true, script, 'Server will restart in', cfg.cmsg.clrs.target_tri, tostring( arg_time ), cfg.cmsg.clrs.msg, 'seconds' )
        rlib:log( 4, 'Server restart in [ %s ] seconds', arg_time )
        storage:log( 7, false, '[ %s ] has forced a timed server restart in [ %i ] seconds', admin_name, arg_time )

        -- overall timer action to execute when timer runs out
        timex.create( prefix .. 'timer.srv.restart.delay', arg_time, 1, function( )
            rlib:log( 4, lang( 'restart_now' ) )
            for v in helper.get.ents( ) do v:SetPos( Vector( 99999999999999999, 0, 0 ) ) end
            hook.Remove( 'Tick', prefix .. 'timer.srv.restart' )
        end )

        local function restart_execute( )
            local exec_cd = timex_cd
            if not timex.exists( prefix .. 'timer.srv.restart.delay.s3.part2' ) then
                timex.create( prefix .. 'timer.srv.restart.delay.s3.part2', 1, timex_cd, function( )
                    if exec_cd ~= 11 then
                        local term = ( exec_cd == 1 ) and 'second' or 'seconds'
                        if ULib then ULib.csay( _, 'Server restart in [ ' .. tostring( exec_cd ) .. ' ] ' .. term ) end
                        base.msg:route( nil, true, script, 'Server restart in', cfg.cmsg.clrs.target_tri, tostring( exec_cd ), cfg.cmsg.clrs.msg, term )
                        rlib:log( 4, 'Server restart in [ %s ] %s', tostring( exec_cd ), term )
                    end
                    exec_cd = exec_cd - 1
                end )
            end
        end

        hook.Add( 'Tick', prefix .. 'timer.srv.restart', function( )
            local timex_remains    = timex.remains( prefix .. 'timer.srv.restart.delay' )
            timex_remains = math.Round( timex_remains )

            if ( timex_remains == time_step2 and not step2_OK ) and not timex.exists( prefix .. 'timer.srv.restart.delay.s2' ) then
                timex.create( prefix .. 'timer.srv.restart.delay.s2', 0.01, 1, function( )
                    base.msg:route( nil, true, script, 'Server restart in', cfg.cmsg.clrs.target_tri, tostring( time_step2 ), cfg.cmsg.clrs.msg, 'seconds' )
                    rlib:log( 4, 'Server restart in [ %s ] seconds', tostring( time_step2 ) )
                    step2_OK = true
                end )
            end

            if ( timex_remains == timex_cd and not step3_OK ) and not timex.exists( prefix .. 'timer.srv.restart.delay.s3.p1' ) then
                timex.create( prefix .. 'timer.srv.restart.delay.s3.p1', 0.01, 1, function( )
                    step3_OK = true
                    hook.Remove( 'Tick', prefix .. 'timer.srv.restart' )
                    restart_execute( )
                end )
            end
        end )

    end
end