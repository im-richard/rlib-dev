/*
*   @package        : rlib
*   @author         : Richard [http://steamcommunity.com/profiles/76561198135875727]
*   @copyright      : (C) 2018 - 2020
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
*   standard tables and localization
*/

rlib                    = rlib or { }
local base              = rlib
local mf                = base.manifest
local pf                = mf.prefix
local script            = mf.name
local cfg               = base.settings

/*
*   Localized rlib routes
*/

local helper            = base.h
local storage           = base.s
local access            = base.a
local tools             = base.t
local cvar              = base.v
local sys               = base.sys

/*
*   Localized lua funcs
*
*   absolutely hate having to do this, but for squeezing out every bit of performance, we need to.
*/

local Color             = Color
local pairs             = pairs
local SortedPairs       = SortedPairs
local Vector            = Vector
local tonumber          = tonumber
local tostring          = tostring
local istable           = istable
local isfunction        = isfunction
local isentity          = isentity
local isnumber          = isnumber
local isstring          = isstring
local file              = file
local table             = table
local os                = os
local coroutine         = coroutine
local math              = math
local string            = string
local sf                = string.format

/*
*   manifest paths
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
*   Localized translation func
*/

local function lang( ... )
    return base:lang( ... )
end

/*
*	localize clrs
*/

local clr_r             = Color( 255, 0, 0 )
local clr_y             = Color( 255, 255, 0 )
local clr_w             = Color( 255, 255, 255 )
local clr_p             = Color( 255, 0, 255 )

/*
*   simplifiy funcs
*/

local function con      ( ... ) base:console( ... ) end
local function log      ( ... ) base:log( ... ) end
local function route    ( ... ) base.msg:route( ... ) end

/*
*   rcc :: user
*
*   manages a players access with rlib
*
*   : subargs
*       : add < player >
*       : remove < player >
*
*   @call   : rlib.user < subarg > < player >
*/

local function rcc_user( pl, cmd, args )

    /*
    *   define command
    */

    local ccmd = base.calls:get( 'commands', 'rlib_user' )

    /*
    *   scope
    */

    if ( ccmd.scope == 1 and not base.con:Is( pl ) ) then
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
        route( pl, script, 'You must supply at least a valid partial', cfg.cmsg.clrs.target, 'player name' )
        return
    end

    local c_results, result = helper.who:name_wc( target )

    if c_results > 1 then
        route( pl, script, 'More than one result was found, type more of the name. Place in quotes for names with spaces. Example:', cfg.cmsg.clrs.target, '\"John Doe\"' )
        return
    elseif not c_results or c_results < 1 then
        if subarg == 'remove' or subarg == '-r' then
            local users = access:getusers( )

            local i, user, user_name = 0, false, 'unknown'
            for k, v in pairs( users ) do
                local ply_name = v.name:lower( )
                if ( string.find( ply_name, target, 1, true ) == nil ) then continue end
                user        = k
                user_name   = v.name
                i           = i + 1
            end

            if i > 1 then
                route( pl, script, 'More than one result was found, type more of the name. Place in quotes for names with spaces. Example:', cfg.cmsg.clrs.target, '\"John Doe\"' )
                return
            elseif i == 0 then
                route( pl, script, 'No valid player found' )
                return
            elseif i == 1 then
                local bRemoved = access:deluser( user )

                if bRemoved then
                    route( pl, script, 'Successfully removed player', cfg.cmsg.clrs.target, user_name, cfg.cmsg.clrs.msg, 'from rlib access' )
                else
                    route( pl, script, 'No access found for player', cfg.cmsg.clrs.target, user_name )
                end
            end
        else
            route( pl, script, 'No results found! Place in quotes for names with spaces. Example:', cfg.cmsg.clrs.target, '\"John Doe\"' )
            return
        end
    else
        if not helper.ok.ply( result[ 0 ] ) then
            route( pl, script, 'No valid player found' )
            return
        else
            result = result[ 0 ]
            if subarg == 'add' or subarg == '-a' then
                local bExists = access:writeuser( result )

                if bExists then
                    route( pl, script, 'user', cfg.cmsg.clrs.target, result:Name( ), cfg.cmsg.clrs.msg, 'already exists' )
                else
                    route( pl, script, 'Successfully added player', cfg.cmsg.clrs.target, result:Name( ), cfg.cmsg.clrs.msg, 'to rlib access' )
                end
            elseif subarg == 'remove' or subarg == '-r' then
                local bRemoved = access:deluser( result )

                if bRemoved then
                    route( pl, script, 'Successfully removed player', cfg.cmsg.clrs.target, result:Name( ), cfg.cmsg.clrs.msg, 'from rlib access' )
                else
                    route( pl, script, 'no access found for player', cfg.cmsg.clrs.target, result:Name( ) )
                end
            elseif subarg == 'status' or subarg == '-s' then
                local bExists = access:hasuser( result )
                if not bExists then
                    route( pl, script, cfg.cmsg.clrs.target, result:Name( ), cfg.cmsg.clrs.msg, 'does not have access' )
                else
                    route( pl, script, cfg.cmsg.clrs.target, result:Name( ), cfg.cmsg.clrs.msg, 'has admin access' )
                end
            end

            -- update admins list for perms
            net.Start       ( 'rlib.user'   )
            net.WriteTable  ( access.admins )
            net.Broadcast   (               )

        end
    end

end
rcc.register( 'rlib_user', rcc_user )

/*
*   rcc :: debug :: clean
*
*   cleans files in debug log folder
*/

local function rcc_debug_clean( pl, cmd, args, str )

    /*
    *   define command
    */

    local ccmd = base.calls:get( 'commands', 'rlib_debug_clean' )

    /*
    *   scope
    */

    if ( ccmd.scope == 1 and not base.con:Is( pl ) ) then
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

    local arg_flag          = args and args[ 1 ] or false
    arg_flag                = not helper.str:isempty( arg_flag ) and arg_flag:lower( ) or false

    local gcf_cancel        = base.calls:gcflag( 'rlib_debug_clean', 'cancel' )
    local timer_clean       = cfg.debug.clean_delaytime

    if ( arg_flag and ( arg_flag == gcf_cancel ) or ( arg_flag == '-cancel' or arg_flag == 'cancel' ) and timex.exists( 'rlib_debug_doclean' ) ) then
        timex.expire( 'rlib_debug_doclean' )
        log( 4, lang( 'logs_clean_cancel' ) )
        return
    end

    if arg_flag then
        log( 2, lang( 'cmd_param_invalid', timer_clean, pf ) )
        return
    end

    log( 4, lang( 'logs_clean_scheduled', timer_clean, pf, '-c' ) )

    timex.create( 'rlib_debug_doclean', timer_clean, 1, function( )
        local files, _ = file.Find( path_logs .. '/*', 'DATA' )

        local i_del = 0
        for v in helper.get.data( files ) do
            local file_path = sf( '%s/%s', path_logs, v )
            file.Delete( file_path )

            i_del = i_del + 1
        end

        log( 4, lang( 'logs_clean_success', i_del, path_logs ) )
    end )

end
rcc.register( 'rlib_debug_clean', rcc_debug_clean )

/*
*   rcc :: debug :: diag
*
*   checks a variety of areas to prep from dev -> production
*/

local function rcc_debug_diag( pl, cmd, args, str )

    /*
    *   define command
    */

    local ccmd = base.calls:get( 'commands', 'rlib_debug_diag' )

    /*
    *   scope
    */

    if ( ccmd.scope == 1 and not base.con:Is( pl ) ) then
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

    con( pl, '\n' )
    con( pl, clr_y, script, clr_p, ' » ', clr_w, 'Debug Diag' )
    con( pl, 0 )
    con( pl, clr_w, 'Information listed below is for the developer to utilize in order to determine what state\n the current build is configured in.' )
    con( pl, 0 )

    local h1_l = sf( '\n %s » %s', script, 'General' )
    con( pl, clr_r, h1_l .. '\n' )

    local get_state =
    {
        { id = lang( 'status_col_branch' ),         val = cvar:GetStr( 'rlib_branch', 'stable' ) },
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
        l1_d        = sf( '%-20s', id )
        cs_data     = sf( '%-5s', ' » ' )
        l2_d        = sf( '%-15s', val )

        con( pl, clr_y, l1_d, clr_p, cs_data, clr_w, l2_d )
    end

    con( pl, 1 )
    con( pl, 0 )

    local h2_l = sf( '\n %s » %s', script, 'Versions' )
    con( pl, clr_r, h2_l .. '\n' )

    local get_versions =
    {
        { id = lang( 'col_name_lib' ),          val = base.get:ver2str_mf( ) or 'missing' },
        { id = lang( 'col_name_spew' ),         val = base.get:ver_pkg( base.spew ) },
        { id = rnet.__manifest.name,            val = base.get:ver_pkg( rnet ) },
        { id = timex.__manifest.name,           val = base.get:ver_pkg( timex ) },
        { id = rcc.__manifest.name,             val = base.get:ver_pkg( rcc ) },
        { id = rhook.__manifest.name,           val = base.get:ver_pkg( rhook ) },
    }

    for m in helper.get.data( get_versions ) do
        if not m.val then continue end

        local id    = m.id
        local val   = m.val

        local l1_d, l2_d, cs_data = '', '', ''
        l1_d        = sf( '%-20s', id )
        cs_data     = sf( '%-5s', ' » ' )
        l2_d        = sf( '%-15s', val )

        con( pl, clr_y, l1_d, clr_p, cs_data, clr_w, l2_d )
    end

    /*
    *   rcore output
    */

    if not istable( rcore ) then
        con( pl, 0 )
        con( pl, clr_r, '\n ', clr_r, lang( 'status_rcore_missing' ) )
        return
    end

    con( pl, 1 )
    con( pl, 0 )

    local c0_cat = sf( '\n %s » %s', 'rcore', 'Demo Mode Active\n' )

    con( pl, clr_r, c0_cat )

    local bIsDemo = false
    for v in helper.get.data( rcore.modules ) do
        if not v.demo and not v.demomode then continue end

        local name      = helper.str:truncate( v.name, 20, '...' ) or lang( 'err' )
        local ver       = base.get:ver2str( v.version )
        local author    = v.author
        local desc      = helper.str:truncate( v.desc, 40, '...' ) or lang( 'err' )

        local d1_d      = sf( '%-20s', name )
        local d2_d      = sf( '%-15s', ver )
        local d3_d      = sf( '%-15s', author )
        local d4_d      = sf( '%-20s', desc )
        local d1_r      = sf( '%s %s %s %s', d1_d, d2_d, d3_d, d4_d )

        bIsDemo = true

        con( pl, clr_y, d1_r )
    end

    if not bIsDemo then
        con( pl, 'No modules' )
    end

    con( pl, 1 )
    con( pl, 0 )

end
rcc.register( 'rlib_debug_diag', rcc_debug_diag )

/*
*   rcc :: checksum :: new
*
*   writes the lib checksums to data/rlib/checksum.txt
*/

local function rcc_checksum_new( pl, cmd, args, str )

    /*
    *   define command
    */

    local ccmd = base.calls:get( 'commands', 'rlib_checksum_new' )

    /*
    *   scope
    */

    if ( ccmd.scope == 1 and not base.con:Is( pl ) ) then
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
rcc.register( 'rlib_checksum_new', rcc_checksum_new )

/*
*   rcc :: checksum :: verify
*
*   verifies released lib checksums with any files that may be modified on the server
*   and reports the differences
*/

local function rcc_checksum_verify( pl, cmd, args, str )

    /*
    *   define command
    */

    local ccmd = base.calls:get( 'commands', 'rlib_checksum_verify' )

    /*
    *   scope
    */

    if ( ccmd.scope == 1 and not base.con:Is( pl ) ) then
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
        con( pl, clr_w, lang( 'checksum_validate_fail' ) )
        return
    end

    /*
    *   output :: header
    */

    local i = table.Count( checksums )

    con( pl, 1 )
    con( pl, clr_y, script, clr_p, ' » ', clr_w, lang( 'con_checksum_verify' ) )
    con( pl, 0 )

    /*
    *   output :: check :: files verified
    */

    if i == 0 then
        con( pl, clr_w, lang( 'files_modified_none' ) )
        con( pl, 0 )
        return
    end

    /*
    *   output :: subheader
    */

    con( pl, clr_w, lang( 'files_listed_have_been_modified' ) )
    con( pl, 1 )
    con( pl, 0 )

    /*
    *   columns
    */

    local l1_l      = sf( '%-40s',    lang( 'col_file'        ) )
    local l2_l      = sf( '%-20s',    lang( 'col_verified'    ) )
    local l3_l      = sf( '%-5s',     lang( 'sym_arrow'       ) )
    local l4_l      = sf( '%-20s',    lang( 'col_current'     ) )

    con( pl, clr_w, l1_l, Color( 0, 255, 0 ), l2_l, clr_w, l3_l, clr_r, l4_l )
    con( pl )

    local i = 0
    for k, v in pairs( checksums ) do
        if not v.verified or not v.current then continue end

        local verified  = v.verified:sub( 1, 15 )
        local current   = v.current:sub( 1, 15 )

        local l1_d      = sf( '%-40s',  k           )
        local l2_d      = sf( '%-20s',  verified    )
        local l3_d      = sf( '%-5s',   '»'         )
        local l4_d      = sf( '%-20s',  current     )

        con( pl, clr_y, l1_d, Color( 0, 255, 0 ), l2_d, clr_w, l3_d, clr_r, l4_d )

        i = i + 1
    end

    if i > 0 then
        con( pl, 0 )
        con( pl, 1 )
        con( pl, clr_w, lang( 'files_modified_count', i ) )
    end

    con( pl, 1 )

end
rcc.register( 'rlib_checksum_verify', rcc_checksum_verify )

/*
*   rcc :: udm
*
*   toggles the update notification for the remainder of the session and will revert to default when 
*   the server is rebooted.
*/

local function rcc_udm( pl, cmd, args )

    /*
    *   define command
    */

    local ccmd = base.calls:get( 'commands', 'rlib_udm' )

    /*
    *   scope
    */

    if ( ccmd.scope == 1 and not base.con:Is( pl ) ) then
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

    local timer_id  = 'rlib_udm_notice'
    local status    = args and args[ 1 ] or false
    local dur       = args and args[ 2 ] or cfg.udm.checktime or 1800

    if not base:bInitialized( ) then
        log( 1, lang( 'lib_udm_err_noinit' ) )
        return
    end

    /*
    *   param :: run updater
    */

    if status and status == 'run' then
        local task_udm = coroutine.create( function( )
            local branch = sf( mf.astra.udm.branch, cvar:GetStr( 'rlib_branch', 'stable' ) )
            base.udm:Check( branch )
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
                log( 4, lang( 'lib_udm_nextchk', next_chk ) )
                return
            end

            if dur and not helper:bIsNum( dur ) then
                log( 2, lang( 'lib_udm_bad_dur' ) )
                return
            end

            log( 4, lang( 'lib_udm_started', dur ) )

            base.udm:Run( dur )
        else
            timex.expire( timer_id )
            log( 4, lang( 'lib_udm_stopped', dur ) )
        end
    else
        if timex.exists( timer_id ) then
            local next_chk = timex.remains( timer_id )
            next_chk = timex.secs.sh_simple( next_chk, false, true )
            log( 4, lang( 'lib_udm_active', next_chk ) )

            return
        else
            log( 1, lang( 'lib_udm_inactive' ) )
        end
    end

end
rcc.register( 'rlib_udm', rcc_udm )

/*
*   rcc :: calls
*
*   returns a list of all registered calls associated to rlib / rcore
*
*   @usage : rlib.calls <returns all calls>
*   @usage : rlib.calls rlib <returns rlib only>
*   @usage : rlib.calls -s termhere <returns entries matching term>
*   @usage : rlib.calls -r <returns raw output>
*/

local function rcc_calls( pl, cmd, args )

    /*
    *   define command
    */

    local ccmd = base.calls:get( 'commands', 'rlib_calls' )

    /*
    *   scope
    */

    if ( ccmd.scope == 1 and not base.con:Is( pl ) ) then
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

    local arg_flag          = args and args[ 1 ] or false
    local arg_srch          = args and args[ 2 ] or nil
    local i_entries         = 0

    local output = sf( '\n\n [%s] :: call definitions', script )
    if arg_flag then
        if arg_flag == script then
            output = sf( '\n\n [%s] :: call definitions [ %s library only ]', script, script )
        elseif arg_flag == '-r' then
            output = sf( '\n\n [%s] :: call definitions :: raw', script, script )
        end
    end

    con( pl, output )

    /*
    *   loop calls table
    */

    local cat_islisted, cat_id = false, ''
    local tbl_calls = _G.rcalls

    if arg_flag then
        if arg_flag == script then
            tbl_calls = rlib.c
        else
            if arg_flag == '-s' and arg_srch then
                con( pl, clr_r, ' ' .. lang( 'search_term', arg_srch ) )
            elseif arg_flag == '-r' then
                con( pl, clr_r, ' ' .. lang( 'search_raw' ) )
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
                local cat       = sf( ' %s', a )

                con( pl, 1 )
                con( pl, 0 )

                local l1_l      = sf( '%-15s',      cat )
                local l2_l      = sf( '%-35s',      lang( 'col_id' ) )
                local l3_l      = sf( '%-35s',      lang( 'col_data' ) )
                local l4_l      = sf( '%s %s %s',   l1_l, l2_l, l3_l )

                con( pl, clr_w, l4_l )
                con( pl, 0 )

                cat_islisted, cat_id = true, a
            end

            if istable( v ) then
                local i = helper.countdata( v, 1 )( )

                local id, i_fields = '', 0
                for l, m in pairs( v ) do
                    if arg_srch and not string.match( k, arg_srch ) then continue end
                    i_fields = i_fields + 1

                    id = k
                    if i_fields ~= 1 then id = '' end

                    local l1_d, l2_d, l3_d, c0_resp = '', '', '', ''
                    l1_d    = sf( '%-15s', tostring( '' ) )
                    l2_d    = sf( '%-35s', tostring( id ) )
                    l3_d    = sf( '%-35s', lang( 'missing_item' , tostring( l ) ) )

                    if m ~= '' then
                        l3_d = sf( '%-35s', tostring( l ) .. ' : ' .. helper.str:truncate( tostring( m ), 60, '...' ) )
                    end

                    c0_resp = sf( '%s%s %s %s', c0_resp, l1_d, l2_d, l3_d )

                    if i_fields == i then
                        i_entries   = i_entries + 1
                        c0_resp     = c0_resp .. '\n'
                        i_fields  = 0
                    end

                    con( pl, clr_y, c0_resp )
                end
            elseif isstring( v ) then
                if not arg_srch or arg_srch and string.match( v, arg_srch ) then
                    local l1_d, l2_d, l3_d, c0_resp = '', '', '', ''
                    l1_d    = sf( '%-15s', tostring( '' ) )
                    l2_d    = sf( '%-35s', tostring( k ) )
                    l3_d    = sf( '%-35s', tostring( v ) )

                    c0_resp = sf( '%s%s %s %s', c0_resp, l1_d, l2_d, l3_d )

                    i_entries = i_entries + 1
                    con( pl, clr_y, c0_resp )
                end
            end

        end

    end

    con( pl, 1 )
    con( pl, 0 )
    local c_ftr = sf( lang( 'calls_found_cnt', i_entries ) )
    con( pl, Color( 0, 255, 0 ), c_ftr )
    con( pl, 0 )

end
rcc.register( 'rlib_calls', rcc_calls )

/*
*   rcc :: modules :: error logs
*
*   displays any registered errors with the specified module
*/

local function rcc_modules_errlog( pl, cmd, args )

    /*
    *   define command
    */

    local ccmd = rlib.calls:get( 'commands', 'rlib_modules_errlog' )

    /*
    *   scope
    */

    if ( ccmd.scope == 1 and not rlib.con:Is( pl ) ) then
        access:deny_consoleonly( pl, base.manifest.name, ccmd.id )
        return
    end

    /*
    *   perms
    */

    if not access:bIsRoot( pl ) then
        access:deny_permission( pl, base.manifest.name, ccmd.id )
        return
    end

    /*
    *   functionality
    */

    con             ( pl, 1 )
    con             ( pl, clr_y, rlib.manifest.name, clr_p, ' » ', clr_w, 'Errorlogs' )
    con             ( pl, 0 )

    /*
    *   outdated libraries
    */

    con             ( pl, clr_y, '» ', clr_w, 'Outdated\n' )
    con             ( pl, clr_w, 'The following modules require a more recent version of rlib to function properly' )
    con             ( pl, 0 )
    con             ( pl, 1 )

    local l1_l      = sf( '%-20s', 'Module'         )
    local l2_l      = sf( '%-20s', 'Module Version' )
    local l3_l      = sf( '%-20s', 'Lib Version'    )
    local l4_l      = sf( '%-20s', 'Lib Required'   )

    con             ( pl, clr_y, l1_l, clr_w, l2_l, clr_r, l3_l, clr_w, l4_l )
    con             ( pl, 0 )

    for v in helper.get.data( rcore.modules, true ) do
        if not v.errorlog then continue end

        if v.errorlog.bLibOutdated then
            local l1_d  = sf( '%-20s', v.name )
            local l2_d  = sf( '%-20s', rlib.get:ver2str_mf( v ) )
            local l3_d  = sf( '%-20s', rlib.get:ver2str_mf( ) )
            local l4_d  = sf( '%-20s', rlib.get:ver2str( v.libreq ) )

            con( pl, clr_y, l1_d, clr_w, l2_d, clr_r, l3_d, clr_w, l4_d )
        end
    end

end
rcc.register( 'rlib_modules_errlog', rcc_modules_errlog )

/*
*   rcc :: modules :: reroute
*
*   lists all installed modules
*/

local function rcc_modules( pl, cmd, args )

    /*
    *   define command
    */

    local ccmd = rlib.calls:get( 'commands', 'rlib_modules' )

    /*
    *   scope
    */

    if ( ccmd.scope == 1 and not rlib.con:Is( pl ) ) then
        access:deny_consoleonly( pl, base.manifest.name, ccmd.id )
        return
    end

    /*
    *   perms
    */

    if not access:bIsRoot( pl ) then
        access:deny_permission( pl, base.manifest.name, ccmd.id )
        return
    end

    /*
    *   declarations
    */

    local arg_flag  = args and args[ 1 ] or false
    local gcf_path  = rlib.calls:gcflag( 'rlib_modules', 'paths' )

    /*
    *   functionality
    */

    con             ( pl, '\n\n [' .. base.manifest.name .. '] Active Modules' )
    con             ( pl, 0 )

    local c1_l      = sf( '%-20s', 'Module'      )
    local c2_l      = sf( '%-15s', 'Version'     )
    local c3_l      = sf( '%-15s', 'Author'      )
    local c4_l      = sf( '%-20s', ( arg_flag == gcf_path and 'Path' ) or 'Description' )

    con             ( pl, sf( ' %s %s %s %s', c1_l, c2_l, c3_l, c4_l ) )
    con             ( pl, 0 )

    for v in helper.get.data( rcore.modules, true ) do
        local l1_d  = sf( '%-20s', tostring( helper.str:truncate( v.name, 20, '...' ) or 'err' ) )
        local l2_d  = sf( '%-15s', tostring( rlib.modules:ver2str( v ) or 'err' ) )
        local l3_d  = sf( '%-15s', tostring( v.author or 'err' ) )
        local l4_d  = sf( '%-20s', tostring( helper.str:truncate( ( arg_flag == gcf_path and v.path ) or v.desc, 40, '...' ) or 'err' ) )
        local resp  = sf( ' %s %s %s %s', l1_d, l2_d, l3_d, l4_d )

        con( pl, clr_y, resp )
    end

    con( pl, 0 )

end
rcc.register( 'rlib_modules', rcc_modules )

/*
*   rcc :: tools :: asay
*
*   sends a message to all players in chat who have the permission 'rlib_asay'
*   similar to ulx asay
*/

local function rcc_tools_asay( pl, cmd, args )

    /*
    *   define command
    */

    local ccmd = base.calls:get( 'commands', 'rlib_asay' )

    /*
    *   check :: permissions
    */

    if ( ccmd.no_console and base.con:Is( pl ) ) then
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
        route( pl, false, 'asay', 'cannot send empty message' )
        return
    end

    /*
    *   run asay hook
    */

    hook.Run( 'asay.broadcast', pl, asay_message )

end
rcc.register( 'rlib_asay', rcc_tools_asay )

/*
*   rcc :: tools :: pco
*
*   player client optimizations, which sets specific command variables for the calling player which 
*   helps increase frames ( if enabled )
*/

local function rcc_tools_pco( pl, cmd, args )

    /*
    *   define command
    */

    local ccmd = base.calls:get( 'commands', 'rlib_tools_pco' )

    /*
    *   check :: permissions
    */

    if ( ccmd.no_console and base.con:Is( pl ) ) then
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
        local state = pl:GetNWBool( pf .. 'tools.pco' ) and lang( 'opt_enabled' ) or lang( 'opt_disabled' )
        route( pl, false, script, 'pco is currently', cfg.cmsg.clrs.target, state )
        return
    end

    tools.pco:Run( pl, arg_state )

end
rcc.register( 'rlib_tools_pco', rcc_tools_pco )

/*
*   rcc :: tools :: rdo
*
*   set the rendermode on entities
*
*   @usage  : rlib.rdo <returns state>
*   @usage  : rlib.rdo enable|disable <set rdo active state>
*/

local function rcc_tools_rdo( pl, cmd, args )

    /*
    *   define command
    */

    local ccmd = base.calls:get( 'commands', 'rlib_tools_rdo' )

    /*
    *   scope
    */

    if ( ccmd.scope == 1 and not base.con:Is( pl ) ) then
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
        route( pl, false, script, 'rdo »', cfg.cmsg.clrs.target, state )
        return
    end

    cfg.rdo.enabled = arg_state
    rdo_rendermode( arg_state )

    local set_state = arg_state and lang( 'opt_enabled' ) or lang( 'opt_disabled' )
    route( pl, false, script, 'rdo »', cfg.cmsg.clrs.target, set_state )

end
rcc.register( 'rlib_tools_rdo', rcc_tools_rdo )

/*
*   rcc :: session
*
*   returns the current session id
*/

local function rcc_session( pl, cmd, args )

    /*
    *   define command
    */

    local ccmd = base.calls:get( 'commands', 'rlib_session' )

    /*
    *   scope
    */

    if ( ccmd.scope == 1 and not base.con:Is( pl ) ) then
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
        log( 3, lang( 'setup_cmd_disabled' ) )
        return
    end

    /*
    *   return session id
    */

    route( pl, false, script, lang( 'lib_session_id', sys.startups ) )

end
rcc.register( 'rlib_session', rcc_session )

/*
*   rcc :: setup
*
*   sets up rlib after the initial install
*/

local function rcc_setup( pl, cmd, args )

    /*
    *   define command
    */

    local ccmd = base.calls:get( 'commands', 'rlib_setup' )

    /*
    *   scope
    */

    if ( ccmd.scope == 1 and not base.con:Is( pl ) ) then
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
        log( 3, lang( 'setup_cmd_disabled' ) )
        return
    end

    /*
    *   check :: already has root usr
    */

    local bHasRoot, rootuser = access:root( )
    if bHasRoot then
        route( pl, false, script, lang( 'setup_root_exists' ), clr_y, ( rootuser and rootuser.name ) or 'none' )
        return
    end

    /*
    *   check :: server initialized
    */

    if not base:bInitialized( ) then
        route( pl, false, script, lang( 'lib_initialized' ) )
        return
    end

    /*
    *   functionality
    */

    local target = args and args[ 1 ] or false

    if not target then
        route( pl, false, script, lang( 'user_find_errmsg' ) )
        return
    end

    local c_results, result = helper.who:name_wc( target )

    if c_results > 1 then
        route( pl, false, script, lang( 'user_find_multires' ), cfg.cmsg.clrs.target, lang( 'user_find_quotes_ex' ) )
        return
    elseif not c_results or c_results < 1 then
        if sys.connections == 1 then
            route( pl, false, script, lang( 'user_find_nores_one' ) )
        else
            route( pl, false, script, lang( 'user_find_nores' ), cfg.cmsg.clrs.target, lang( 'user_find_quotes_ex' ) )
        end
        return
    else
        if not helper.ok.ply( result[ 0 ] ) then
            if sys.connections == 1 then
                route( pl, false, script, lang( 'user_find_noply_one' ) )
            else
                route( pl, false, script, lang( 'user_find_noply' ) )
            end
            return
        else
            result          = result[ 0 ]
            local bExists   = access:writeuser( result )

            if bExists then return end

            con( pl, 2 )
            con( pl, 0 )
            con( pl, clr_y, '» Library Setup' )
            con( pl, 0 )
            con( pl, 1 )
            con( pl, clr_w, 'User ', clr_p, result:Name( ), color_white, ' has been added with ', Color( 0, 255, 0 ), 'root access', color_white, ' and is protected.' )
            con( pl, clr_w, 'With root, you have access to all admin-based privledges and abilities that rlib utilizes.\n' )
            con( pl, clr_w, 'For more info; type ', Color( 0, 255, 0 ), 'rlib.manifest', color_white, ' in con and visit the docs URL\n' )
            con( pl, 0 )
            con( pl, 1 )
            con( pl, clr_w, 'Review the list of useful commands below to get started\n\n' )

            /*
            *   loop :: setup :: useful commands
            */

            for v in helper.get.data( rlib.calls:get( 'commands' ), true ) do
                if not v.enabled or not v.showsetup then continue end

                con( pl, clr_y, '   ' .. v.id )
            end

            con( pl, 1 )
            con( pl, 0 )

            -- update admins list for perms
            net.Start       ( 'rlib.user' )
            net.WriteTable  ( access.admins )
            net.Broadcast   ( )

            base:setup_killtask( )
        end
    end

end
rcc.register( 'rlib_setup', rcc_setup )

/*
*   rcc :: status
*
*   returns various types of information related to installed packages, library stats, debugging, 
*   installed modules and base core module
*/

local function rcc_status( pl, cmd, args )

    /*
    *   define command
    */

    local ccmd = base.calls:get( 'commands', 'rlib_status' )

    /*
    *   scope
    */

    if ( ccmd.scope == 1 and not base.con:Is( pl ) ) then
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

    con( pl, 1 )

    local cat       = script or lang( 'lib_name' )
    local subcat    = ccmd.title or ccmd.name or lang( 'untitled' )

    con( pl, sf( '%s » %s', cat, subcat ) )

    /*
    *   manifest output
    */

    con( pl, 1 )
    con( pl, 0 )

    local l0_l      = sf( '%s » %s', script, lang( 'manifest' ) )
    local l1_l      = sf( '%-20s', l0_l )
    local l2_l      = sf( '%-15s', '' )

    con( pl, clr_r, l1_l, l2_l )
    con( pl )

    local about_d   = helper.str:wordwrap( mf.about, 64 )

    for l, m in SortedPairs( mf ) do
        if istable( m ) then continue end

        local id    = tostring( l ) or nil
        local val   = tostring( m ) or lang( 'missing' )

        local l1_d, l2_d, s1_l = '', '', ''
        if id == 'about' then
            l1_d        = sf( '%-20s', tostring( id ) )
            s1_l        = sf( '%-5s', '»' )
            l2_d        = sf( '%-15s', about_d[ 1 ] )

            con( pl, clr_y, l1_d, clr_p, s1_l, clr_w, l2_d )

            for k, v in pairs( about_d ) do
                if k == 1 then continue end -- hide the first line, already called in the initial col
                val             = tostring( v ) or lang( 'missing' )

                local l3_d      = sf( '%-20s', '' )
                local l4_d      = sf( '%-15s', val )

                con( pl, clr_y, l3_d, clr_w, '    ', clr_w, l4_d )
            end
        else
            val         = ( id == 'released' and os.date( '%m.%d.%Y', val ) ) or val

            l1_d        = sf( '%-20s', id )
            s1_l        = sf( '%-5s', '»' )
            l2_d        = sf( '%-15s', val )

            con( pl, clr_y, l1_d, clr_p, s1_l, clr_w, l2_d )
        end
    end

    /*
    *   appends version to the manifest output
    */

    local v1_d          = sf( '%-20s', lang( 'label_version' ) )
    local v2_d          = sf( '%-5s', '»' )
    local v3_d          = sf( '%-15s', base.get:ver2str_mf( ) )

    con( pl, clr_y, v1_d, clr_p, v2_d, clr_w, v3_d )

    con( pl, 2 )
    con( pl, 0 )

    /*
    *   stats output
    */

    local s0_c          = sf( '%s » %s', script, lang( 'stats' ) )
    local s1_l          = sf( '%-20s', s0_c )
    local s2_l          = sf( '%-15s', '' )

    con( pl, clr_r, s1_l, clr_p, s2_l )
    con( pl )

    local tbl_stats =
    {
        { id = lang( 'status_col_os' ),             val = base.get:os( ) },
        { id = lang( 'status_col_gm' ),             val = base.get:gm( true ) },
        { id = lang( 'status_col_admins' ),         val = table.Count( access.admins ) or 0 },
        { id = lang( 'status_col_calls' ),          val = lang( 'stats_reg_cnt', sys.calls or 0 ) },
        { id = lang( 'status_col_basecmd' ),        val = sys.calls_basecmd or lang( 'none' ) },
        { id = lang( 'status_col_init' ),           val = sys.initialized and lang( 'opt_yes' ) or lang( 'opt_no' ) },
        { id = lang( 'status_col_conncnt' ),        val = sys.connections or 0 },
        { id = lang( 'status_col_debug_mode' ),     val = cfg.debug.enabled and lang( 'opt_enabled' ) or lang( 'opt_disabled' ) },
        { id = lang( 'status_col_rnet_route' ),     val = rnet and rnet.sys.nrouter_enabled and lang( 'opt_enabled' ) or lang( 'opt_disabled' ) },
        { id = lang( 'status_col_rcore' ),          val = istable( rcore ) and lang( 'opt_yes' ) or lang( 'opt_no' ) },
        { id = lang( 'status_col_starttime' ),      val = sys.starttime or 0 },
        { id = lang( 'status_col_startcnt' ),       val = sys.startups or 0 },
        { id = lang( 'status_col_uptime' ),         val = timex.secs.sh_cols( SysTime( ) - sys.uptime ) },
    }

    for m in helper.get.data( tbl_stats ) do
        if not m.val then continue end

        local id, val       = tostring( m.id ), tostring( m.val )

        local s1_d          = sf( '%-20s', id )
        local s2_d          = sf( '%-5s', '»' )
        local s3_d          = sf( '%-15s', val )

        con( pl, clr_y, s1_d, clr_p, s2_d, clr_w, s3_d )
    end

    con( pl, 2 )
    con( pl, 0 )

    /*
    *   stats output
    */

    local o0_c          = sf( '%s » %s', script, lang( 'oort' ) )
    local o1_l          = sf( '%-20s', o0_c )
    local o2_l          = sf( '%-15s', '' )

    con( pl, clr_r, o1_l, clr_p, o2_l )
    con( pl )

    local bHasRoot, rootuser = access:root( )
    local owner_id = bHasRoot and istable( rootuser ) and rootuser.name or 'none'

    local tbl_oort =
    {
        -- { id = lang( 'status_col_validated' ),      val = sys.validate and lang( 'opt_yes' ) or lang( 'opt_no' ) },
        { id = lang( 'status_col_owner' ),          val = bHasRoot and owner_id or 'unregistered' },
        { id = lang( 'status_col_validated' ),      val = mf.astra.oort.validated and lang( 'opt_yes' ) or lang( 'opt_no' ) },
        { id = lang( 'status_col_latest_ver' ),     val = mf.astra.oort.has_latest and lang( 'opt_yes' ) or lang( 'opt_no' ) },
        { id = lang( 'status_col_sess_id' ),        val = mf.astra.oort.sess_id or 'null' },
        { id = lang( 'status_col_auth_id' ),        val = mf.astra.oort.auth_id or 'null' },
        { id = lang( 'status_col_branch' ),         val = cvar:GetStr( 'rlib_branch', 'stable' ) },
    }

    for m in helper.get.data( tbl_oort ) do
        if not m.val then continue end

        local id, val       = tostring( m.id ), tostring( m.val )

        local s1_d          = sf( '%-20s', id )
        local s2_d          = sf( '%-5s', '»' )
        local s3_d          = sf( '%-15s', val )

        con( pl, clr_y, s1_d, clr_p, s2_d, clr_w, s3_d )
    end

    con( pl, 2 )
    con( pl, 0 )

    /*
    *   paths
    */

    local t1_c          = sf( '%s » %s', script, lang( 'storage' ) )
    local t1_l          = sf( '%-20s', t1_c )
    local t2_l          = sf( '%-15s', '' )

    con( pl, clr_r, t1_l, clr_r, t2_l )
    con( pl )

    for l, m in SortedPairs( mf.paths ) do
        local id        = tostring( l )
        local val       = tostring( m )

        local s1_data, s2_data, ss_data = '', '', ''
        s1_data         = sf( '%-20s', id )
        ss_data         = sf( '%-5s', '»' )
        s2_data         = sf( '%-15s', val )

        con( pl, clr_y, s1_data, clr_p, ss_data, clr_w, s2_data )
    end

    con( pl, 1 )

    local tbl_storage =
    {
        { id = lang( 'status_col_logs' ),           val = ( sys.log_ct or 0 ) .. ' ( ' .. ( sys.log_sz or 0 ) .. ' )' or 0 },
        { id = lang( 'status_col_uconn' ),          val = ( sys.uconn_ct or 0 ) .. ' ( ' .. ( sys.uconn_sz or 0 ) .. ' )' or 0 },
        { id = lang( 'status_col_history' ),        val = ( sys.history_ct or 0 ) .. ' ( ' .. ( sys.history_sz or 0 ) .. ' )' or 0 },
    }

    for m in helper.get.data( tbl_storage ) do
        if not m.val then continue end

        local id, val       = tostring( m.id ), tostring( m.val )

        local s1_d          = sf( '%-20s', id )
        local s2_d          = sf( '%-5s', '»' )
        local s3_d          = sf( '%-15s', val )

        con( pl, clr_y, s1_d, clr_p, s2_d, clr_w, s3_d )
    end

    con( pl, 2 )
    con( pl, 0 )

    /*
    *   packages output
    */

    local p1_c          = sf( '%s » %s', script, lang( 'packages' ) )
    local p1_l          = sf( '%-20s', p1_c )
    local p2_l          = sf( '%-20s', '' )
    local p3_l          = sf( '%-25s', '' )

    con( pl, clr_r, p1_l, p2_l, p3_l )
    con( pl, 0 )

    for i, m in SortedPairs( base.package.index ) do
        local id        = tostring( i )
        local ver       = sf( '%s : %s', base.get:ver2str( m.version ), m.build )
        local desc      = tostring( helper.str:truncate( m.desc, 50, '...' ) or lang( 'none' ) )

        local p1_d      = sf( '%-20s', id )
        local p2_d      = sf( '%-5s', '»' )
        local p3_d      = sf( '%-20s', ver )
        local p4_d      = sf( '%-25s', desc )

        con( pl, clr_y, p1_d, clr_p, p2_d, clr_w, p3_d, clr_w, p4_d )
    end

    con( pl, 2 )
    con( pl, 0 )

    /*
    *   rcore output
    */

    if not istable( rcore ) then
        con( pl, clr_r, ' ', clr_r, lang( 'status_rcore_missing' ) )
        return
    end

    local rc0_cat   = sf( 'rcore » %s', script, lang( 'modules' ) )
    local rc1_l     = sf( '%-20s', rc0_cat )
    local rc2_l     = sf( '%-15s', '' )

    con( pl, clr_r, rc1_l, rc2_l )
    con( pl )

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

        r1_d        = sf( '%-20s', id )
        r2_d        = sf( '%-5s', '»' )
        r3_d        = sf( '%-15s', val )

        con( pl, clr_y, r1_d, clr_p, r2_d, clr_w, r3_d )
    end

    /*
    *   rcore :: module list
    */

    con( pl, 2 )
    con( pl, 0 )

    local m1_l       = sf( '%-20s', lang( 'col_module' )    )
    local m2_l       = sf( '%-15s', lang( 'col_version' )   )
    local m3_l       = sf( '%-15s', lang( 'col_author' )    )
    local m4_l       = sf( '%-20s', lang( 'col_desc' )      )

    con( pl, clr_w, m1_l, m2_l, m3_l, m4_l )

    con( pl, 0 )

    local clr_status = clr_y
    for v in helper.get.data( rcore.modules ) do
        clr_status      = not v.enabled and clr_r or clr_status

        local name      = tostring( helper.str:truncate( v.name, 20, '...' ) or lang( 'err' ) )
        local ver       = tostring( rlib.modules:ver2str( v ) )
        local author    = tostring( v.author )
        local desc      = tostring( helper.str:truncate( v.desc, 40, '...' ) or lang( 'err' ) )

        local m1_d      = sf( '%-20s', name )
        local m2_d      = sf( '%-15s', ver )
        local m3_d      = sf( '%-15s', author )
        local m4_d      = sf( '%-20s', desc )

        con( pl, clr_status, m1_d, m2_d, m3_d, m4_d )
    end

end
rcc.register( 'rlib_status', rcc_status )

/*
*   rcc :: list packages
*
*   returns a list of installed / running packages
*/

local function rcc_packages( pl, cmd, args )

    /*
    *   define command
    */

    local ccmd = base.calls:get( 'commands', 'rlib_packages' )

    /*
    *   scope
    */

    if ( ccmd.scope == 1 and not rlib.con:Is( pl ) ) then
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

    con( pl, 2 )

    local cat       = script or lang( 'lib_name' )
    local subcat    = ccmd.title or ccmd.name or lang( 'untitled' )

    con( pl, 1 )

    local c0_lbl    = sf( '%s » %s', cat, subcat )

    con( pl, clr_r, c0_lbl )

    local l1_l      = sf( '%-15s', lang( 'col_package' )   )
    local l2_l      = sf( '%-15s', lang( 'col_version' )   )
    local l3_l      = sf( '%-15s', lang( 'col_author' )    )
    local l4_l      = sf( '%-20s', lang( 'col_desc' )      )

    con( pl, 0 )

    con( pl, l1_l, l2_l, l3_l, l4_l )

    con( pl, 0 )

    for v in helper.get.data( base.package.index ) do
        local l1_d        = sf( '%-15s', tostring( helper.str:truncate( v.name, 20, '...' ) or lang( 'err' ) ) )
        local l2_d        = sf( '%-15s', base.get:ver2str( v.version ) or lang( 'err' ) )
        local l3_d        = sf( '%-15s', tostring( v.author ) or lang( 'err' ) )
        local l4_d        = sf( '%-20s', tostring( helper.str:truncate( v.desc, 40, '...' ) or lang( 'err' ) ) )

        con( pl, clr_y, l1_d, l2_d, l3_d, l4_d )
    end

    con( pl, 0 )

end
rcc.register( 'rlib_packages', rcc_packages )

/*
*   rcc :: license
*
*   returns license information associated with the library
*/

local function rcc_license( pl, cmd, args )

    /*
    *   define command
    */

    local ccmd = base.calls:get( 'commands', 'rlib_license' )

    /*
    *   scope
    */

    if ( ccmd.scope == 1 and not base.con:Is( pl ) ) then
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

    con( pl, 1 )

    local cat       = script or lang( 'lib_name' )
    local subcat    = ccmd.title or ccmd.name or lang( 'untitled' )

    local l1_l      = sf( '%s » %s', cat, subcat )
    local l2_l      = sf( '%-15s', '' )

    con( pl, clr_r, l1_l, l2_l )
    con( pl, 0 )

    local about_d   = helper.str:wordwrap( mf.license.text, 72 )

    for l, m in SortedPairs( mf.license ) do
        if istable( m ) then continue end

        local id    = tostring( l ) or nil
        local val   = tostring( m ) or lang( 'missing' )

        local l1_d, l2_d, s1_l = '', '', ''
        if id == 'text' then
            l1_d    = sf( '%-10s', tostring( id ) )
            s1_l    = sf( '%-5s', ' » ' )
            l2_d    = sf( '%-15s', about_d[ 1 ] )

            con( pl, clr_y, l1_d, clr_p, s1_l, clr_w, l2_d )

            for k, v in pairs( about_d ) do
                if k == 1 then continue end -- hide first line
                val = tostring( v ) or lang( 'missing' )

                local l3_d  = sf( '%-10s', '' )
                local l4_d  = sf( '%-15s', val )

                con( pl, clr_y, l3_d, clr_w, '    ', clr_w, l4_d )
            end
            con( pl, '' )
        else
            l1_d    = sf( '%-10s', id )
            s1_l    = sf( '%-5s', '»' )
            l2_d    = sf( '%-15s', val )

            con( pl, clr_y, l1_d, clr_p, s1_l, clr_w, l2_d )
        end

    end

    con( pl, 0 )

end
rcc.register( 'rlib_license', rcc_license )

/*
*   rcc :: check oort
*
*   checks the status of oort
*/

local function rcc_oort( pl, cmd, args )

    /*
    *   define command
    */

    local ccmd = base.calls:get( 'commands', 'rlib_oort' )

    /*
    *   scope
    */

    if ( ccmd.scope == 1 and not base.con:Is( pl ) ) then
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
    route( pl, false, script, 'Oort Engine', cfg.cmsg.clrs.target, '[' .. has_oort .. ']' )
end
rcc.register( 'rlib_oort', rcc_oort )

/*
*   rcc :: oort :: update
*
*   forces oort to update server stats to database
*/

local function rcc_oort_update( pl, cmd, args )

    /*
    *   define command
    */

    local ccmd = base.calls:get( 'commands', 'rlib_oort_update' )

    /*
    *   scope
    */

    if ( ccmd.scope == 1 and not base.con:Is( pl ) ) then
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

    rlib.oort:Authorize( true )
    timex.simple( 3, function( )
        rlib.oort:Stats( true )
        route( pl, false, script, 'Oort Engine successfully', cfg.cmsg.clrs.target, 'updated' )
    end )
end
rcc.register( 'rlib_oort_update', rcc_oort_update )

/*
*   rcc :: oort :: next update
*
*   returns the update timer duration for oort stats
*/

local function rcc_oort_next( pl, cmd, args )

    /*
    *   define command
    */

    local ccmd = base.calls:get( 'commands', 'rlib_oort_next' )

    /*
    *   scope
    */

    if ( ccmd.scope == 1 and not base.con:Is( pl ) ) then
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

    local remains   = timex.remains( 'rlib.oort.stats' )
    local resp      = sf( '%s :: oort :: next update', script )

    con( pl, 1  )
    con( pl, 0  )
    con( pl, clr_y, resp )
    con( pl, 0  )
    con( pl, 1  )
    con( pl, 'Next stats update in ', clr_y, remains, clr_w, ' seconds' )
    con( pl, 1  )
    con( pl, 0  )
    con( pl, 1  )

end
rcc.register( 'rlib_oort_next', rcc_oort_next )

/*
*   rcc :: oort :: sendlog
*
*   returns the update timer duration for oort stats
*/

local function rcc_oort_sendlog( pl, cmd, args )

    /*
    *   define command
    */

    local ccmd = base.calls:get( 'commands', 'rlib_oort_sendlog' )

    /*
    *   scope
    */

    if ( ccmd.scope == 1 and not base.con:Is( pl ) ) then
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
    *   prepare log
    */

    base.oort:PrepareLog( false )

end
rcc.register( 'rlib_oort_sendlog', rcc_oort_sendlog )

/*
*   concommand :: cancel restart
*
*   allows for a player/console to cancel a server restart using either the restart concommand or timed.
*/

local function restart_cancel( pl )
    local bIsActive = false
    local timers =
    {
        'rlib_cmd_srv_restart',
        'rlib_cmd_srv_restart_wait',
        'rlib_cmd_srv_restart_wait_s1',
        'rlib_cmd_srv_restart_wait_s2',
        'rlib_cmd_srv_restart_wait_s3_p1',
        'rlib_cmd_srv_restart_wait_s3_p2',
    }

    for v in helper.get.data( timers ) do
        if not timex.exists( v ) then continue end
        timex.expire( v )
        bIsActive = true
    end

    hook.Remove( 'Tick', pf .. 'timer.srv.restart' )

    if not bIsActive then
        log( 1, lang( 'restart_none_active' ) )
        return false
    end

    local admin_name = base.con:Is( pl ) and lang( 'console' ) or pl:Name( )

    route( nil, true, script, 'Server restart', cfg.cmsg.clrs.target_tri, 'CANCELLED' )
    storage:log( 7, false, '[ %s ] » cancelled an active server restart', admin_name )
    log( 4, 'server restart cancelled by player [ %s ]', admin_name )

    return false
end

/*
*   rcc :: server restart
*
*   gives a counter in public chat which forces a server restart after timer expires
*/

local function rcc_restart( pl, cmd, args )

    /*
    *   define command
    */

    local ccmd = base.calls:get( 'commands', 'rlib_restart' )

    /*
    *   scope
    */

    if ( ccmd.scope == 1 and not base.con:Is( pl ) ) then
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

    local restart_timer     = 5
    local arg_flag          = args and args[ 1 ] or false
    arg_flag                = not helper.str:isempty( arg_flag ) and arg_flag:lower( ) or false

    local gcf_cancel = base.calls:gcflag( 'rlib_restart', 'cancel' )

    if ( arg_flag and ( arg_flag == gcf_cancel ) or ( arg_flag == '-cancel' or arg_flag == 'cancel' ) ) then
        restart_cancel( pl )
        return false
    end

    if not timex.exists( 'rlib_cmd_srv_restart' ) then
        local admin_name = base.con:Is( pl ) and lang( 'console' ) or pl:Name( )

        storage:log( 7, false, '[ %s ] » forced a server restart', admin_name )
        log( 4, '[ %s ] » forced a server restart', admin_name )

        timex.create( 'rlib_cmd_srv_restart', restart_timer, 1, function( )
            log( 4, lang( 'restart_now' ) )
        end )

        route( nil, true, script, 'Server restart in', cfg.cmsg.clrs.target_tri, tostring( restart_timer ), cfg.cmsg.clrs.msg, 'seconds' )
    end
end
rcc.register( 'rlib_restart', rcc_restart )

/*
*   rcc :: timed server restart
*
*   gives a counter in public chat which forces a server restart after timer expires
*   yes we know the method of used to restart is 'hacky', but most servers utilize some type of hosting 
*   that auto-detects a downed server and restarts it. this method basically crashes the server and then 
*   the hosting servers take over.
*/

local function rcc_trestart( pl, cmd, args )

    /*
    *   define command
    */

    local ccmd = base.calls:get( 'commands', 'rlib_trestart' )

    /*
    *   scope
    */

    if ( ccmd.scope == 1 and not base.con:Is( pl ) ) then
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

    local arg_time      = args and args[ 1 ] or 60
    local arg_flag      = arg_time
    arg_flag            = not helper.str:isempty( arg_flag ) and arg_flag:lower( ) or false

    local gcf_cancel    = base.calls:gcflag( 'rlib_trestart', 'cancel' )

    if ( arg_flag and ( arg_flag == gcf_cancel ) or ( arg_flag == '-cancel' or arg_flag == 'cancel' ) ) then
        restart_cancel( pl )
        return false
    end

    local time_step2    = arg_time / 2 -- half of original arg time
    local timex_cd      = 10 -- when to start the second-by-second last countdown

    if tonumber( arg_time ) > 300 then
        route( pl, false, 'RESTART', 'Forced restart time cannot exceed', cfg.cmsg.clrs.target_tri, '300', cfg.cmsg.clrs.msg, 'seconds' )
        return
    end

    local step2_OK, step3_OK = false, false

    if not timex.exists( 'rlib_cmd_srv_restart_delay' ) then

        local admin_name = base.con:Is( pl ) and lang( 'console' ) or pl:Name( )

        route( nil, true, script, 'Server will restart in', cfg.cmsg.clrs.target_tri, tostring( arg_time ), cfg.cmsg.clrs.msg, 'seconds' )
        log( 4, 'Server restart in [ %s ] seconds', arg_time )
        storage:log( 7, false, '[ %s ] has forced a timed server restart in [ %i ] seconds', admin_name, arg_time )

        -- overall timer action to execute when timer runs out
        timex.create( 'rlib_cmd_srv_restart_delay', arg_time, 1, function( )
            log( 4, lang( 'restart_now' ) )
            for v in helper.get.ents( ) do v:SetPos( Vector( 99999999999999999, 0, 0 ) ) end
            hook.Remove( 'Tick', pf .. 'timer.srv.restart' )
        end )

        local function restart_execute( )
            local exec_cd = timex_cd
            if not timex.exists( 'rlib_cmd_srv_restart_wait_s3_p2' ) then
                timex.create( 'rlib_cmd_srv_restart_wait_s3_p2', 1, timex_cd, function( )
                    if exec_cd ~= 11 then
                        local term = ( exec_cd == 1 ) and 'second' or 'seconds'
                        if ULib then ULib.csay( _, 'Server restart in [ ' .. tostring( exec_cd ) .. ' ] ' .. term ) end
                        route( nil, true, script, 'Server restart in', cfg.cmsg.clrs.target_tri, tostring( exec_cd ), cfg.cmsg.clrs.msg, term )
                        log( 4, 'Server restart in [ %s ] %s', tostring( exec_cd ), term )
                    end
                    exec_cd = exec_cd - 1
                end )
            end
        end

        hook.Add( 'Tick', pf .. 'timer.srv.restart', function( )
            local timex_remains     = timex.remains( 'rlib_cmd_srv_restart_wait' )
            timex_remains           = math.Round( timex_remains )

            if ( timex_remains == time_step2 and not step2_OK ) and not timex.exists( 'rlib_cmd_srv_restart_wait_s2' ) then
                timex.create( 'rlib_cmd_srv_restart_wait_s2', 0.01, 1, function( )
                    route( nil, true, script, 'Server restart in', cfg.cmsg.clrs.target_tri, tostring( time_step2 ), cfg.cmsg.clrs.msg, 'seconds' )
                    log( 4, 'Server restart in [ %s ] seconds', tostring( time_step2 ) )
                    step2_OK = true
                end )
            end

            if ( timex_remains == timex_cd and not step3_OK ) and not timex.exists( 'rlib_cmd_srv_restart_wait_s3_p1' ) then
                timex.create( 'rlib_cmd_srv_restart_wait_s3_p1', 0.01, 1, function( )
                    step3_OK = true
                    hook.Remove( 'Tick', pf .. 'timer.srv.restart' )
                    restart_execute( )
                end )
            end
        end )

    end
end
rcc.register( 'rlib_trestart', rcc_trestart )

/*
*   rcc :: rpm
*
*   rlib package manager
*/

local function rcc_rpm( pl, cmd, args )

    /*
    *   define command
    */

    local ccmd = base.calls:get( 'commands', 'rlib_rpm' )

    /*
    *   scope
    */

    if ( ccmd.scope == 1 and not base.con:Is( pl ) ) then
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

    local arg_flag          = args and args[ 1 ] or false
    arg_flag                = not helper.str:isempty( arg_flag ) and arg_flag:lower( ) or false

    local gcf_list          = base.calls:gcflag( 'rlib_rpm', 'list' )

    local resp              = sf( '%s :: package manager', script )

    con( pl, 1  )
    con( pl, 0  )
    con( pl, clr_y, resp )
    con( pl, 0  )
    con( pl, 'Allows you to mount packages that are available for rlib.' )
    con( pl, 0  )
    con( pl, 1  )

    /*
    *   arg_flag : -l
    */

    if arg_flag and ( arg_flag == gcf_list ) then

        /*
        *   retrieval will start here
        *
        *   @todo    : add promise
        */

        con( pl, 'Listing available packages' )
        con( pl, 2  )

        base.get:Rpm( )

        return
    end

    con( pl, 'Service currently unavailable' )

    if arg_flag and not helper.str:isempty( arg_flag ) then
        base.get:Rpm( )
    end

    con( pl, 2  )
    con( pl, 0  )
    con( pl, clr_y, 'View list of list of packages with ', clr_r, 'rlib.rpm -l' )
    con( pl, 2  )

end
rcc.register( 'rlib_rpm', rcc_rpm )