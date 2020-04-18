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
*   localized rlib routes
*/

local helper            = base.h
local storage           = base.s
local access            = base.a
local konsole           = base.k
local cvar              = base.v
local sys               = base.sys

/*
*   Localized lua funcs
*
*   i absolutely hate having to do this, but for squeezing out every
*   bit of performance, we need to.
*/

local Color             = Color
local pairs             = pairs
local ipairs            = ipairs
local tonumber          = tonumber
local tostring          = tostring
local istable           = istable
local isfunction        = isfunction
local isentity          = isentity
local isnumber          = isnumber
local isstring          = isstring
local Color             = Color
local file              = file
local table             = table
local os                = os
local string            = string
local sf                = string.format

/*
*   simplifiy funcs
*/

local function con      ( ... ) base:console( ... ) end
local function log      ( ... ) base:log( ... ) end
local function route    ( ... ) base.msg:route( ... ) end
local function target   ( ... ) base.msg:target( ... ) end

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
*	localize clrs
*/

local clr_r             = Color( 255, 0, 0 )
local clr_y             = Color( 255, 255, 0 )
local clr_w             = Color( 255, 255, 255 )
local clr_p             = Color( 255, 0, 255 )

/*
*   rcc :: base
*
*   base concommand for lib which includes all help information and the ability to search for specific
*   commands built into the library
*
*   command to be used in console
*
*   @usage  : rlib                        [displays full lib command list]
*           : rlib <search_string>        [search for cmd help info]
*           : rlib -h <search_string>     [search for cmd help info]
*           : rlib -f <search_string>     [show only commands matching search string]
*
*   @ex     : rlib rlib.version
*           : rlib version
*           : rlib -h version
*/

local function rcc_base( pl, cmd, args )

    /*
    *   define command
    */

    local ccmd = base.calls:get( 'commands', 'rlib' )

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
    *   declarations
    */

    local arg_flag      = args and args[ 1 ] or false
    local arg_srch      = args and args[ 2 ] or nil

    local gcf_a         = base.calls:gcflag( 'rlib', 'all'      )
    local gcf_f         = base.calls:gcflag( 'rlib', 'filter'   )
    local gcf_h         = base.calls:gcflag( 'rlib', 'help'     )
    local gcf_s         = base.calls:gcflag( 'rlib', 'simple'   )
    local gcf_b         = base.calls:gcflag( 'rlib', 'break'    )       -- adds a line break between commands
    local gcf_m         = base.calls:gcflag( 'rlib', 'modules'  )       -- displays only commands related to modules

    local i_res         = 0
    local i_hidden      = 0

    /*
    *   declare
    */

    local res_k, res_f, res_i, res_c = nil, false, nil, nil

    /*
    *   check :: minimum character amount
    *
    *   @def    : ( min ) 4
    */

    if arg_flag and not helper.str:startsw( arg_flag, '-' ) and arg_flag:len( ) < 2 then
        con( pl, 1 )
        con( pl, clr_y, 'Help » ', clr_r, 'Too few characters\n' )
        con( pl, clr_w, '       Use at least ', clr_y, '2', clr_w, ' characters in your search term' )
        con( pl, clr_w, '       If using a ', clr_y, 'flag', clr_w, ', make sure it is valid.' )
        return
    end

    /*
    *   check :: minimum character amount
    *
    *   @def    : ( min ) 4
    */

    if not helper.str:isempty( arg_srch ) and arg_srch:len( ) < 2 then
        con( pl, 1 )
        con( pl, clr_y, 'Help » ', clr_r, 'Too few characters\n' )
        con( pl, clr_w, '       Use at least ', clr_y, '2', clr_w, ' characters in your search term' )
        con( pl, clr_w, '       If using a ', clr_y, 'flag', clr_w, ', make sure it is valid.' )
        return
    end

    /*
    *   check for a provided exact match in search arg
    */

    if ( arg_flag == gcf_h and arg_srch ) then
        res_k = arg_srch
    elseif arg_flag == gcf_h and ( helper.str:isempty( arg_srch ) ) then
        con( pl, 1 )
        con( pl, clr_y, 'Help » ', clr_w, 'no command specified' )
        con( pl, clr_w, '       type ', clr_y, script .. ' -h commandname', clr_w, ' for help on a particular command' )
        return
    elseif ( arg_flag and arg_flag ~= gcf_h ) then
        res_k = arg_flag
    end

    /*
    *   search command list for matching search string
    *
    *   for rlib based commands; it supports both the full command
    *   as well as a string without [ rlib. ]
    *
    *   Example:        rlib.setup OR setup
    *                   return the same result
    */

    for k, v in pairs( rlib.calls:get( 'commands' ) ) do
        local res_filtered = ( v.id and v.id:gsub( 'rlib.', '' ) ) or ( v[ 1 ] and v[ 1 ]:gsub( 'rlib.', '' ) )
        if res_k and ( ( res_k == res_filtered ) or ( res_k == v.id or res_k == v[ 1 ] ) ) then
            res_i, res_f = k, true
            if res_k == v[ 1 ] then
                res_i   = v[ 1 ]
                res_c   = k
            end
            break
        end
    end

    /*
    *   no search result for cmd found
    */


    /*
    if arg_srch and not res_i then
        con( pl, clr_y, 'Help » ', clr_w, 'no command found' )
        return
    end
    */

    /*
    *   search :: subset
    *
    *   if no results are found in the initial search, look for any mention of the search string in
    *   the list of registred rlib commands
    *
    *   @ex     search string:
    *               ::  rlib rlib.help
    *                   returns help command results
    *
    *               ::  rlib help
    *                   returns help command results (same as first ex)
    */

        /*
        if res_k and not res_f then
            for k, v in pairs( rlib.calls:get( 'commands' ) ) do
                if not string.match( k, res_k ) then continue end
                res_i, res_f = k, true
                if res_k == v[ 1 ] then
                    res_i = v[ 1 ]
                    res_c = k
                end
                break
            end
        end
        */

    /*
    *   error :: -f flag with no search string
    */

    if ( arg_flag == gcf_f and not arg_srch ) then
        con( pl, 1 )
        con( pl, clr_y, 'Help » ', clr_w, 'No search term specified' )
        con( pl, clr_w, '       type ', 'Syntax: ', clr_y, script .. ' ' .. gcf_f .. ' <search_keyword>' )
        return
    end

    /*
    *   error :: invalid flag specified
    */

    if not res_f and arg_flag and helper.str:startsw( arg_flag, '-' ) and not base.calls:gcflag_valid( ccmd.id, arg_flag ) then
        local val_srch = arg_flag or 'unspecified'
        con( pl, 1 )
        con( pl, clr_y, 'Help » ', clr_r, val_srch, clr_w, ' is not a valid flag' )
        con( pl, clr_w, '       type ', clr_y, script, clr_w, ' for a list of registered commands' )
        con( pl, '' )
        return
    end

    /*
    *   error :: no result but param
    */

    if not res_f and ( arg_flag and not base.calls:gcflag_valid( ccmd.id, arg_flag ) ) then
        local val_srch = arg_srch or arg_flag
        con( pl, 1 )
        con( pl, clr_y, 'Help » ', clr_r, '< ' .. val_srch .. ' >', clr_w, ' is not recognized as a valid command', '\n' )
        con( pl, clr_w, '       type ', clr_y, script, clr_w, ' for a list of valid commands' )

        return
    end

    /*
    *   output :: specific command result
    *
    *   output the result of the searched console command
    *   run this before anything else so we can keep annoying header prints from appearing for each and
    *   every command result which should only show at the top level
    */

    if res_f then
        local item      = base.calls:get( 'commands', res_i )
        local id        = ( item and item.id ) or res_i
        local desc      = ( item and item.desc ) or ( item and res_c and item[ res_c ][ 2 ] ) or 'no information provided'

        con( pl, 1 )
        con( pl, clr_y, 'Help', clr_p, ' » ', clr_y, 'Command', clr_p, ' » ', clr_w, id )
        con( pl, 0 )
        con( pl, clr_w, desc .. '\n' )

        /*
        *   command arguments
        */

        if item.args and item.args ~= '' then
            local a1_l              = sf( '%-15s',  'SYNTAX' )
            local a1_d              = sf( '%-35s',  '' )
            local a2_l              = sf( '%-5s',   '' )
            local a2_d              = sf( '%-35s',  '   ' .. item.args )

            con( pl, clr_y, a1_l, clr_w, a1_d )
            con( pl, clr_y, a2_l, clr_w, a2_d .. '\n' )
        end

        /*
        *   command is_base
        */

        if item.is_base then
            con( pl )

            local c1_l              = sf( '%-15s',  'BASE' )
            local c1_d              = sf( '%-35s',  '' )
            local c2_l              = sf( '%-5s',   '' )
            local c2_d              = sf( '%-35s',  '   This is the base command for ' .. script )

            con( pl, clr_p, c1_l, clr_w, c1_d )
            con( pl, clr_y, c2_l, clr_w, c2_d .. '\n' )
        end

        /*
        *   command scope
        */

        if isnumber( item.scope ) then
            local s1_l              = sf( '%-15s',  'SCOPE' )
            local s1_d              = sf( '%-35s',  '' )
            local s2_l              = sf( '%-5s',   '' )
            local s2_d              = sf( '%-35s',  '   ' .. base._def.scopes[ item.scope ] or 'unknown' )

            con( pl, clr_y, s1_l, clr_w, s1_d )
            con( pl, clr_y, s2_l, clr_w, s2_d .. '\n' )
        end

        /*
        *   command flags
        */

        if item.flags and istable( item.flags ) then
            local f1_l              = sf( '%-15s',  'FLAGS' )
            local f1_2              = sf( '%-35s',  '' )

            con( pl, clr_y, f1_l, clr_w, f1_2 )

            for v in helper.get.data( item.flags, SortedPairs ) do
                local i_flag        = v.flag or '-'
                local i_desc        = v.desc or 'no desc'

                local f1_d          = sf( '%-5s',   '' )
                local f2_d          = sf( '%-15s',  '   ' .. i_flag )
                local f3_d          = sf( '%-35s',  i_desc )
                local f1_c          = f1_d .. f2_d .. f3_d

                con( pl, clr_w, f1_c )
            end
            con( pl, clr_y, '' )
        end

        /*
        *   command examples
        */

        if item.ex and istable( item.ex ) then
            local x1_l = sf( '%-15s', 'EXAMPLES' )
            con( pl, clr_y, x1_l )
            for v in helper.get.data( item.ex, ipairs ) do
                local x1_d          = sf( '%-5s', '' )
                local x2_d          = sf( '%-35s', '   ' .. v )
                local x1_c          = x1_d .. x2_d

                con( pl, clr_w, x1_c )
            end
        end

        /*
        *   command notes
        */

        if item.notes and istable( item.notes ) then
            con( pl )

            local n1_l = sf( '%-15s', 'NOTES' )
            con( pl, clr_y, n1_l )
            for v in helper.get.data( item.notes, pairs ) do
                local n1_d          = sf( '%-5s', '' )
                local n2_d          = sf( '%-35s', '   ' .. v )
                local n1_c          = n1_d .. n2_d

                con( pl, clr_w, n1_c )
            end
        end

        /*
        *   command hiddem
        */

        if item.is_hidden then
            con( pl )

            local h1_l      = sf( '%-15s',      'HIDDEN' )
            local h2_l      = sf( '%-5s',       '' )
            local h1_d      = sf( '%-35s',      '' )
            local h2_d      = sf( '%-35s',      '   This command is hidden from the main directory list.' )

            con( pl, clr_r, h1_l, clr_w, h1_d )
            con( pl, clr_y, h2_l, clr_w, h2_d .. '\n' )
        end

        /*
        *   command warn
        */

        if item.warn then
            con( pl )

            local w1_l      = sf( '%-15s',      'WARNING' )
            local w2_l      = sf( '%-5s',       '' )
            local w1_d      = sf( '%-35s',      '' )
            local w2_d      = sf( '%-35s',      '   Only used at developers direction. Misuse may cause server / data damage.' )

            con( pl, clr_r, w1_l, clr_w, w1_d )
            con( pl, clr_y, w2_l, clr_w, w2_d .. '\n' )
        end

        /*
        *   command deny server-side execution
        */

        if item.no_console then
            con( pl )

            local c1_l      = sf( '%-15s',      'NOTICE' )
            local c2_l      = sf( '%-5s',       '' )
            local c1_d      = sf( '%-35s',      '' )
            local c2_d      = sf( '%-35s',      '   Command must have a valid player to execute. Server console cannot run.' )

            con( pl, clr_p, c1_l, clr_w, c1_d )
            con( pl, clr_y, c2_l, clr_w, c2_d .. '\n' )
        end

        con( pl, 0 )

        return false
    end

    /*
    *   output :: header
    */

    local tbl_about = helper.str:wordwrap( mf.about, 90 )

    con( pl, 0 )
    con( pl, clr_y, script, clr_p, ' » ', clr_w, 'Help' )
    con( pl, 0 )

    for v in helper.get.data( tbl_about, pairs ) do
        con( pl, clr_w, v )
    end

    con( pl, 0 )

    /*
    *   output :: search string
    *
    *   displays the string being located if flag and search string provided
    */

    if ( arg_flag == gcf_f ) and arg_srch then
        con( pl, clr_w, 'Searching with match: ' .. arg_srch .. '\n' )
    end

    /*
    *   output :: header columns
    */

    local c1_l      = sf( '%-35s',      'Command'           )
    local c2_l      = sf( '%-5s',       ''                  )
    local c3_l      = sf( '%-35s',      'Description'       )
    local resp      = sf( '%s %s %s',   c1_l, c2_l, c3_l    )

    con( pl, clr_r, resp .. '\n' )

    /*
    *   output :: results
    */

    for k, v in helper:sortedkeys( base.calls:get( 'commands' ) ) do

        /*
        *   :   no flags
        *       if no gcf flags specified, only show commands marked as 'official'
        */

        if not arg_flag and not v.official then
            i_hidden = i_hidden + 1
            continue
        end

        /*
        *   :   gcf_a
        *       if flag -a not specified; all commands not on the correct running scope will be
        *       hidden.
        */

        if ( arg_flag ~= gcf_a ) and ( SERVER and v.scope == 3 or CLIENT and v.scope == 1 ) then
            i_hidden = i_hidden + 1
            continue
        end

        /*
        *   :   gcf_m
        *       will only display module commands
        */

        if arg_flag == gcf_m and v.official then
            i_hidden = i_hidden + 1
            continue
        end

        /*
        *   :   gcf_a
        *       will only display module commands
        */

        if ( arg_flag ~= gcf_a ) and v.is_hidden then
            i_hidden = i_hidden + 1
            continue
        end

        if arg_flag == gcf_f and arg_srch and not string.match( k, arg_srch ) then continue end

        local id            = v.id or v[ 1 ] or 'no id'
        local _desc         = v.desc or v[ 2 ] or lang( 'cmd_no_desc' )
        local desc          = helper.str:wordwrap( _desc, 100 )

        local c1_d          = sf( '%-35s', id )
        local c2_d          = sf( '%-5s', '»' )
        local c3_d          = sf( '%-35s', '   ' .. desc[ 1 ] ) -- return first line of command description

        -- clrs all commands that match lib name a different clr from others
        local clr_cmd = clr_w
        if string.match( id, script ) or string.match( id, pf ) then
            clr_cmd = clr_p
        elseif rcore and string.match( id, rcore.manifest.prefix ) then
            clr_cmd = Color( 0, 255, 0 )
        elseif v.clr and IsColor( v.clr ) then
            clr_cmd = v.clr
        end

        con( pl, clr_y, clr_cmd, c1_d, clr_y, c2_d, clr_w, c3_d )

        if arg_flag ~= gcf_s then
            for l, m in pairs( desc ) do
                if l == 1 then continue end -- hide the first line, already called in the initial call
                local val   = tostring( m ) or 'missing'
                local l1_d  = sf( '%-35s', '' )
                local l2_d  = sf( '%-35s', '   ' .. val )

                con( pl, clr_y, l1_d, clr_w, '    ', clr_w, l2_d )
            end
        end

        if arg_flag == gcf_b then
            con( pl, '' )
        end

        i_res = i_res + 1
    end

    /*
    *   output :: footer
    */

    con( pl, 0 )
    con( pl, clr_y, 'Results: ', clr_w, i_res, clr_y, '      Hidden: ', clr_w, i_hidden )
    con( pl, 0 )
    con( pl, 1 )
    con( pl, clr_y, 'Additional Help:' )
    con( pl, clr_w, 'Help with particular command: ', clr_r, '    rlib commandname' )
    con( pl, clr_w, 'Search similar named commands: ', clr_r, '   rlib -f yourtext' )
    con( pl, clr_w, 'List all commands: ', clr_r, '               rlib -a' )
    con( pl, clr_w, 'List only module commands: ', clr_r, '       rlib -m' )
    con( pl, 1 )

end
rcc.register( 'rlib', rcc_base )

/*
*   rcc :: access
*
*   returns a targets current access to the library
*/

local function rcc_access( pl, cmd, args )

    /*
    *   define command
    */

    local ccmd = base.calls:get( 'commands', 'rlib_access' )

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

    if base.con:Is( pl ) then
        log( 1, 'You are [ %s ], a god-like particle that floats around with infinite permissions.', 'CONSOLE' )
        return
    end

    /*
    *   validate player
    */

    if not helper.ok.ply( pl ) then return end

    /*
    *   get users group
    */

    local ugroup = helper.ply.ugroup( pl )

    /*
    *   is developer
    */

    if access:bIsDev( pl ) then
        target( pl, script, 'I recognize you as ', cfg.cmsg.clrs.target_tri, 'developer' )
        return
    end

    /*
    *   is owner
    */

    if access:bIsOwner( pl ) then
        target( pl, script, 'I recognize you as ', cfg.cmsg.clrs.target, 'owner' )
        return
    end

    /*
    *   response
    */

    if ugroup and ugroup ~= 'user' then
        target( pl, script, 'Your usergroup on the server is ', cfg.cmsg.clrs.target, ugroup )
    else
        target( pl, script, 'You have ', cfg.cmsg.clrs.target_sec, 'no access' )
    end

end
rcc.register( 'rlib_access', rcc_access )

/*
*   rcc :: changelog
*
*   returns contents of the changelog.json file
*/

local function rcc_changelog( pl, cmd, args )

    /*
    *   define command
    */

    local ccmd = base.calls:get( 'commands', 'rlib_changelog' )

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
    *   params
    */

    local arg_flag      = args and args[ 1 ] or false
    local arg_srch      = args and args[ 2 ] or nil

    /*
    *   flags
    */

    local gcf_s         = base.calls:gcflag( 'rlib_changelog', 'search' )

    /*
    *   changelog src
    */

    local src           = storage.get.json( 'changelog.json' )
    local tbl           = src[ 'releases' ]

    con( pl, 2 )
    con( pl, 0 )

    con( pl, clr_y, script, clr_p, ' » ', clr_w, 'Changelogs' )

    con( pl, 0 )

    /*
    *   no search args
    *
    *   print list of available versions
    */

    if not arg_flag and not arg_srch then
        local a1_l              = sf( '%-20s',  'Version'   )
        local a2_l              = sf( '%-35s',  'Running'   )

        con( pl, clr_y, a1_l, a2_l )
        con( pl, 0 )
        con( pl, 1 )

        for k, v in SortedPairs( tbl ) do
            local bRunning          = base.get:ver2str_mf( )
            bRunning                = bRunning == k and 'X' or '-'

            local a1_d              = sf( '%-20s',  k )
            local a2_d              = sf( '%-35s',  bRunning )

            con( pl, clr_y, a1_d, clr_w, a2_d )
        end

        con( pl, 1 )
        con( pl, 0 )
        con( pl, 1 )
        con( pl, 'Select a particular version to display by typing ', clr_y, 'rlib.changelog ' .. rlib.get:ver2str_mf( ) )
        con( pl, 1 )
        con( pl, 0 )
        con( pl, 1 )

        return
    end

    /*
    *   -s flag provided, but no search string
    */

    if ( arg_flag and arg_flag == gcf_s ) and not arg_srch then
        con( pl, clr_w, 'No value provided for ', clr_y, 'search' )
        con( pl, 0 )
        return
    end

    /*
    *   -s flag provided, value given
    */

    if ( arg_flag and arg_flag == gcf_s ) and arg_srch then
        local a1_l              = sf( '%-20s',  'Version'   )
        local a2_l              = sf( '%-35s',  'Running'   )

        con( pl, clr_y, a1_l, a2_l )
        con( pl, 0 )
        con( pl, 1 )

        for k, v in SortedPairs( tbl ) do
            if not string.match( k, arg_srch ) then continue end

            local bRunning      = base.get:ver2str_mf( )
            bRunning            = bRunning == k and 'X' or '-'

            local a1_d          = sf( '%-20s',  k )
            local a2_d          = sf( '%-35s',  bRunning )

            con( pl, clr_y, a1_d, clr_w, a2_d )
        end

        con( pl, 1 )
        con( pl, 0 )
        con( pl, 1 )
        con( pl, 'Select a particular version to display by typing ', clr_y, 'rlib.changelog ' .. rlib.get:ver2str_mf( ) )
        con( pl, 1 )
        con( pl, 0 )
        con( pl, 1 )

        return
    end

    /*
    *   search arg returns no results
    */

    if arg_flag and not tbl[ tostring( arg_flag ) ] then
        con( pl, 1 )
        con( pl, clr_w, 'No changelogs found for ', clr_y, arg_flag )
        con( pl, 1 )
        con( pl, 0 )

        con( pl, 1 )
        con( pl, 'Search for changelogs by typing ', clr_y, 'rlib.changelog -s version number' )
        con( pl, '                            Ex: ', clr_r, 'rlib.changelog -s 1.0' )
        con( pl, 1 )

        return
    end

    /*
    *   search arg matches list of versions listed in changelog
    */

    if tbl[ tostring( arg_flag ) ] then

        con( pl, 1 )
        con( pl, clr_y, arg_flag )
        con( pl, 1 )
        con( pl, 0 )

        for k, v in SortedPairs( tbl[ tostring( arg_flag ) ] ) do
            local a1_d = sf( '%-20s',  v )

            con( pl, clr_w, a1_d )
        end

        con( pl, 2 )

        return
    end

end
rcc.register( 'rlib_changelog', rcc_changelog )

/*
*   rcc :: clear
*
*   clears the console
*/

local function rcc_clear( pl, cmd, args )

    /*
    *   define command
    */

    local ccmd = base.calls:get( 'commands', 'rlib_clear' )

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
    *
    *   sort of a 'hack' for clearing. 
    *   server-side consoles dont have a clear function; and client-side concommand 'clear'
    *   is blocked.
    *
    *   can be executed client-side also, but really no use considering client has a true command
    *   already.
    *
    *   pretty much im just tired of raping my enter key server-side so i can track errors
    */

    for i = 1, 200 do
        con( pl, 1 )
    end

end
rcc.register( 'rlib_clear', rcc_clear )

/*
*   rcc :: commands :: rehash
*
*   register commands with rcc
*   calls rlib.calls.commands:RCC( )
*/

local function rcc_commands_rehash( pl, cmd, args, str )

    /*
    *   define command
    */

    local ccmd = base.calls:get( 'commands', 'rlib_rcc_rehash' )

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
    *   register commands
    */

    rcc.prepare( )

    /*
    *   output
    */

    log( 4, lang( 'rcc_commands_rehash' ) )

end
rcc.register( 'rlib_rcc_rehash', rcc_commands_rehash )

/*
*   rcc :: services
*
*   returns a list of all registered calls associated to rlib / rcore
*
*   @usage : rlib.services <returns all services>
*   @usage : rlib.services -s termhere <returns services matching search term>
*/

local function rcc_services( pl, cmd, args )

    /*
    *   define command
    */

    local ccmd = base.calls:get( 'commands', 'rlib_services' )

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

    local resp = sf( '[ %s ] :: services', script )
    if arg_flag then
        if arg_flag == script then
            resp = sf( '[ %s ] :: call definitions [ %s library only ]', script, script )
        elseif arg_flag == '-r' then
            resp = sf( '[ %s ] :: call definitions :: raw', script, script )
        end
    end

    con( pl, 0      )
    con( pl, resp   )
    con( pl, 0      )

    /*
    *   loop services table
    */

    if arg_flag then
        if arg_flag == script then
            tbl_calls = base.c
        else
            if arg_flag == '-s' and arg_srch then
                con( pl, clr_r, lang( 'search_term', arg_srch ) )
            end
        end
    end

    local tbl_services =
    {
        {
            id      = lang( 'services_id_udm' ),
            desc    = 'update check service',
            cb      = function( )
                if not timex.exists( 'rlib_udm_notice' ) then return 'stopped' end
                return 'running'
            end,
        },
        {
            id      = lang( 'services_id_pco' ),
            desc    = 'player-client-optimization',
            cb      = function( )
                if not cvar:GetBool( 'rlib_pco' ) then return 'stopped' end
                return 'running'
            end,
        },
        {
            id      = lang( 'services_id_rdo' ),
            desc    = 'render-distance-optimization',
            cb      = function( )
                if not cfg.rdo.enabled then return 'stopped' end
                return 'running'
            end,
        },
        {
            id      = lang( 'services_id_oort' ),
            desc    = 'oort engine',
            cb      = function( )
                if not cfg.oort.enabled then return 'stopped' end
                if not istable( oort ) or not oort.bInitialized then return 'failed' end
                return 'running'
            end,
        },
    }

    local i = 0
    for m in helper.get.data( tbl_services ) do
        local status    = m.cb( ) or lang( 'services_status_warn' )
        local id        = tostring( m.id )
        local desc      = tostring( m.desc )
        local val       = isstring( status ) and status or isbool( status ) and lang( 'services_status_running' ) or lang( 'services_status_stopped' )

        local c1_d      = sf( '%-15s', id )
        local c2_d      = sf( '%-5s', '»' )
        local c3_d      = sf( '%-15s', val )
        local c4_d      = sf( '%-25s', desc )

        con( pl, clr_y, c1_d, clr_p, c2_d, clr_w, c3_d, clr_w, c4_d )

        i = i + 1
    end

    con( pl, 1 )
    con( pl, 0 )

    local c_ftr = sf( lang( 'services_found_cnt', i ) )
    con( pl, Color( 0, 255, 0 ), c_ftr )
    con( pl, 0 )

end
rcc.register( 'rlib_services', rcc_services )

/*
*   rcc :: rehash
*
*   various tasks that can be completed via console commands
*   note that most of these require you to have root permissions with
*   rlib otherwise you wont be able to return the requested info.
*/

local function rcc_rehash( pl, cmd, args )

    /*
    *   define command
    */

    local ccmd = base.calls:get( 'commands', 'rlib_rehash' )

    /*
    *   scope
    */

    if ( ccmd.scope == 1 and not base.con:Is( pl ) ) then
        access:deny_consoleonly( pl, base.manifest.name, ccmd.id )
        return
    end

    /*
    *   permission
    */

    if not access:bIsRoot( pl ) then
        access:deny_permission( pl, base.manifest.name, ccmd.id )
        return
    end

    /*
    *   functionality
    */

    local path      = args and args[ 1 ] or 'rlib'
    local bExec     = false

    orion.run( path, function( f )
        include( f )

        if bExec then return end

        rcore.autoload:Run( function( )
            route( pl, false, rlib_mf.name, 'Successfully reloaded', rlib.settings.cmsg.clrs.target, rcore.manifest.name )
        end )

        bExec = true
    end )

end
rcc.register( 'rlib_rehash', rcc_rehash )

/*
*   rcc :: reload
*/

local function rcc_reload( pl, cmd, args )

    /*
    *   define command
    */

    local ccmd = base.calls:get( 'commands', 'rlib_reload' )

    /*
    *   scope
    */

    if ( ccmd.scope == 1 and not rlib.con:Is( pl ) ) then
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
    *   declarations
    */

    local arg_flag          = args and args[ 1 ] or false
    arg_flag                = not helper.str:isempty( arg_flag ) and arg_flag:lower( ) or false

    if not arg_flag then
        route( pl, false, ccmd.id, lang ( 'modules_rehash_unknown' ) )
        return
    end

    /*
    *   check :: rcore missing
    */

    if not rcore then
        route( pl, false, ccmd.id, 'An issue has occured with', cfg.cmsg.clrs.target, 'rcore', cfg.cmsg.clrs.msg )
        return
    end

    /*
    *   action :: reload rcore
    */

    if arg_flag == 'rcore' then
        rlib.autoload:Run( rcore )
        route( pl, false, ccmd.id, lang( 'modules_rehash_rcore' ) )
        return
    end

    /*
    *   declare :: specific module
    */

    local folder        = rcore.manifest.modpath
    local i             = 0
    local mf_path       = nil

    local _, sub_dir    = file.Find( folder .. '/' .. '*', 'LUA' )
    for l, m in pairs( sub_dir ) do
        if m ~= arg_flag then continue end
        mf_path         = folder .. '/' .. m
        i               = i + 1
    end

    /*
    *   check :: no matching modules found
    */

    if i < 1 then
        route( pl, false, ccmd.id, 'No specified module found with name', cfg.cmsg.clrs.target, arg_flag, cfg.cmsg.clrs.msg )
        return
    end

    /*
    *   locate specified module manifest file
    */

    for l, m in pairs( sub_dir ) do
        if m ~= arg_flag then continue end
        for _, sub_f in SortedPairs( file.Find( mf_path .. '/*.lua', 'LUA' ), true ) do
            if not string.match( sub_f, 'manifest' ) and not string.match( sub_f, 'define' ) and not string.match( sub_f, 'pkg' ) then continue end

            local inc = sf( '%s/%s', mf_path, sub_f )
            if not inc then continue end

            if SERVER then AddCSLuaFile( inc ) end
            include( inc )

            rcore:module_register( mf_path, sub_f, true )
        end
    end

    /*
    *   load msg
    */

    route( pl, false, ccmd.id, 'reloaded module', cfg.cmsg.clrs.target, arg_flag )

end
rcc.register( 'rlib_reload', rcc_reload )

/*
*   rcc :: running
*
*   outputs list of installed modules
*/

local function rcc_running( pl, cmd, args )

    /*
    *   define command
    */

    local ccmd = base.calls:get( 'commands', 'rlib_running' )

    /*
    *   scope
    */

    if ( ccmd.scope == 1 and not base.con:Is( pl ) ) then
        access:deny_consoleonly( pl, script, ccmd.id )
        return
    end

    /*
    *   functionality
    */

    local modules   = { }
    local i         = #base.modules:list( )

    for k, v in SortedPairs( base.modules:list( ) ) do
        if not v.enabled then continue end
        modules[ i ] = k
        i = i + 1
    end

    local mod_list      = table.concat( modules, ', ' )
    mod_list            = mod_list:sub( 1, -1 )

    base.msg:route( pl, false, script, cfg.smsg.clrs.msg, 'nodules »', cfg.smsg.clrs.t1, mod_list )

end
rcc.register( 'rlib_running', rcc_running )

/*
*   rcc :: version
*
*   outputs version of rlib running.
*/

local function rcc_version( pl, cmd, args )

    /*
    *   define command
    */

    local ccmd = base.calls:get( 'commands', 'rlib_version' )

    /*
    *   scope
    */

    if ( ccmd.scope == 1 and not base.con:Is( pl ) ) then
        access:deny_consoleonly( pl, script, ccmd.id )
        return
    end

    /*
    *   functionality
    */

    base.msg:simple( pl, cfg.smsg.clrs.t4, sf( '%s Manifest:', script) )

    base.msg:simple( pl, '       Ver : ', cfg.smsg.clrs.t4, 'v' .. base.get:ver2str_mf( ), cfg.smsg.clrs.msg, ' ( ' .. os.date( '%m.%d.%Y', mf.released ) .. ' ) ' )
    base.msg:simple( pl, '       Dev : ', cfg.smsg.clrs.t4, mf.author )
    base.msg:simple( pl, '       Doc : ', cfg.smsg.clrs.t4, mf.docs )

end
rcc.register( 'rlib_version', rcc_version )

/*
*   rcc :: manifest
*
*   displays more detailed info about rlib
*/

local function rcc_manifest( pl, cmd, args )

    /*
    *   define command
    */

    local ccmd = base.calls:get( 'commands', 'rlib_manifest' )

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

    con( pl, 0 )

    local l1_l = sf( '%-20s', 'rlib » manifest' )

    con( pl, clr_r, l1_l )
    con( pl, 0 )

    local tbl_about = helper.str:wordwrap( mf.about, 64 )

    for l, m in SortedPairs( mf ) do
        if istable( m ) then continue end

        local m1_d, m2_d, m3_d = '', '', ''
        if l == 'about' then
            m1_d    = sf( '%-20s', tostring( l ) )
            m2_d    = sf( '%-5s', ' » ' )
            m3_d    = sf( '%-15s', tbl_about[ 1 ] )

            con( pl, clr_y, m1_d, clr_p, m2_d, clr_w, m3_d )

            for k, v in pairs( tbl_about ) do
                if k == 1 then continue end -- hide the first line, already called in the initial col
                local l1_d  = sf( '%-20s', '' )
                local l2_d  = sf( '%-15s', tostring( v ) )

                con( pl, clr_y, l1_d, clr_w, '    ', clr_w, l2_d )
            end
        else
            m1_d    = sf( '%-20s', tostring( l ) )
            m2_d    = sf( '%-5s', ' » ' )
            m3_d    = sf( '%-15s', tostring( m ) )

            con( pl, clr_y, m1_d, clr_p, m2_d, clr_w, m3_d )
        end
    end

    con( pl, 0 )

end
rcc.register( 'rlib_manifest', rcc_manifest )

/*
*   concommand :: help
*
*   returns support info
*/

local function rcc_help( pl, cmd, args )

    /*
    *   define command
    */

    local ccmd = base.calls:get( 'commands', 'rlib_help' )

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

    con( pl, 0 )

    local h1_l      = sf( '%-20s', 'rlib » help' )
    local h2_l      = sf( '%-15s', '' )
    local h1_d      = h1_l .. ' ' .. h2_l

    con( pl, clr_r, h1_d )
    con( pl, 0 )

    local resp = sf( 'For more help related to %s, you can visit our website for documentation or to get\n an updated version at:\n', script )
    con( pl, clr_w, resp )

    local tbl_help =
    {
        { id = 'Docs',  val = mf.docs or lang( 'not_specified' ) },
        { id = 'Repo',  val = mf.repo or lang( 'not_specified' ) },
        { id = 'Site',  val = mf.site or lang( 'not_specified' ) },
    }

    for l, m in SortedPairs( tbl_help ) do
        local id    = tostring( m.id )
        local val   = tostring( m.val )

        local l1_d, l2_d, l3_d = '', '', ''
        l1_d        = sf( '%-15s', id )
        l2_d        = sf( '%-5s', '»' )
        l3_d        = sf( '%-15s', val )

        con( pl, clr_y, l1_d, clr_p, l2_d, clr_w, l3_d )
    end

    local base_cmd
    for v in helper.get.data( base.calls:get( 'commands' ) ) do
        if not v.is_base then continue end
        base_cmd = v.id
    end

    con( pl, 1 )
    con( pl, clr_y, 'Help » ', clr_w, 'Access the command list by typing ', Color( 0, 255, 0 ), base_cmd, clr_w, ' in console'  )
    con( pl, clr_y, 'Help » ', clr_w, 'Syntax: ', Color( 0, 255, 0 ), base_cmd )

    con( pl, 0 )

end
rcc.register( 'rlib_help', rcc_help )

/*
*   rcc :: languages
*
*   returns information related to language entries
*/

local function rcc_languages( pl, cmd, args )

    /*
    *   define command
    */

    local ccmd = base.calls:get( 'commands', 'rlib_languages' )

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

    local cat       = script or mf.name
    local subcat    = ccmd.title or ccmd.name or lang( 'untitled' )

    local a1_lbl    = sf( '%s » %s', cat, subcat )
    local a2_lbl    = sf( '%-15s', '' )
    local a3_lbl    = sf( '%s %s', a1_lbl, a2_lbl )

    con( pl, clr_r, a3_lbl )
    con( pl, 0 )

    /*
    *   output
    */

    local cnt_entries = 0
    for k, v in pairs( base.language ) do
        for l, m in pairs( v ) do
            cnt_entries = cnt_entries + 1
        end
    end

    local tbl_stats =
    {
        { id = lang( 'languages' ),     val = table.Count( base.language ) },
        { id = lang( 'entries' ),       val = cnt_entries },
    }

    for m in helper.get.data( tbl_stats ) do
        local id    = tostring( m.id )
        local val   = tostring( m.val )

        local b1_d, b2_d, b3_d = '', '', ''
        b1_d        = sf( '%-20s', id )
        b2_d        = sf( '%-5s', ' » ' )
        b3_d        = sf( '%-15s', val )

        con( pl, clr_y, b1_d, clr_p, b2_d, clr_w, b3_d )
    end

    /*
    *   rcore language entries
    */

    local a1_l      = sf( 'rlib » language entries' )
    local a2_l      = sf( '%-15s', '' )
    local a3_l      = sf( '%s %s', a1_l, a2_l )

    con( pl, 1 )
    con( pl, clr_r, a3_l )
    con( pl, 0 )

    local b1_l      = sf( '%-20s', lang( 'col_module' ) )
    local b2_l      = sf( '%-15s', lang( 'col_language' ) )
    local b3_l      = sf( '%-5s', '»' )
    local b4_l      = sf( '%-15s', lang( 'col_entries' ) )

    local col_lo    = sf( '%s%s%s%s', b1_l, b2_l, b3_l, b4_l )

    con( pl, clr_w, col_lo )
    con( pl, 0 )

    if not istable( rcore ) then
        con( pl, clr_r, ' ', clr_r, lang( 'lang_rcore_missing' ) )
        return
    end

    local i = 0
    for k, v in SortedPairs( rcore.modules, false ) do
        if not v.language then continue end
        for t, l in SortedPairs( v.language, false ) do
            if not istable( l ) then continue end

            local tr        = sf( '%i', helper.countdata( l, 1 )( ) )
            local a1_d      = sf( '%-20s', helper.str:truncate( v.name, 15 ) )
            local a2_d      = sf( '%-15s', t )
            local a3_d      = sf( '%-5s', '»' )
            local a4_d      = sf( '%-15s', tr )

            local col_d     = sf( '%s%s%s%s', a1_d, a2_d, a3_d, a4_d )

            con( pl, clr_y, col_d )

            -- total number of entries for all modules combined
            i = i + helper.countdata( l, 1 )( )
        end
    end

    local c1_d      = sf( '%-20s', '' )
    local c2_d      = sf( '%-15s', '' )
    local c3_d      = sf( '%-5s', '»' )
    local c4_d      = sf( '%-15s', lang( 'stats_total_cnt', i ) )

    local ftr       = sf( '\n%s%s %s%s', c1_d, c2_d, c3_d, c4_d )

    con( pl, clr_p, ftr )
    con( pl, 0 )

end
rcc.register( 'rlib_languages', rcc_languages )

/*
*   rcc :: debug :: enable
*
*   turns debug mode on for a duration of time specified and then automatically turns it off after the
*   timer has expired.
*/

local function rcc_debug( pl, cmd, args )

    /*
    *   define command
    */

    local ccmd = base.calls:get( 'commands', 'rlib_debug' )

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

    local time_id       = 'rlib_debug_delay'
    local status        = args and args[ 1 ] or false
    local dur           = args and args[ 2 ] or cfg.debug.time_default

    if status then
        local param_status = helper.util:toggle( status )
        if param_status then
            if timex.exists( time_id ) then
                local remains = timex.secs.sh_cols_steps( timex.remains( time_id ) ) or 0
                log( 4, lang( 'debug_enabled_already', remains ) )
                return
            end

            if dur and not helper:bIsNum( dur ) then
                log( 2, lang( 'debug_err_duration' ) )
                return
            end

            cfg.debug.enabled = true
            log( 4, lang( 'debug_set_enabled_dur', dur ) )
            if CLIENT then
                konsole:notifyall( 6, lang( 'debug_set_notify_enabled_dur', dur ) )
            end

            timex.create( time_id, dur, 1, function( )
                log( 4, lang( 'debug_auto_disable' ) )
                cfg.debug.enabled = false

                if CLIENT then
                    konsole:notifyall( 4, lang( 'debug_auto_notify_disable' ) )
                end
            end )
        else
            timex.expire( time_id )
            cfg.debug.enabled = false
            log( 4, lang( 'debug_set_disabled' ) )
            if CLIENT then
                konsole:notifyall( 4, lang( 'debug_set_notify_disabled' ) )
            end
        end
    else
        if cfg.debug.enabled then
            if timex.exists( time_id ) then
                local remains = timex.secs.sh_cols_steps( timex.remains( time_id ) ) or 0
                log( 4, lang( 'debug_enabled_time', remains ) )
            else
                log( 4, lang( 'debug_enabled' ) )
            end
            return
        else
            log( 1, lang( 'debug_disabled' ) )
        end

        log( 1, lang( 'debug_help_info_1' ) )
        log( 1, lang( 'debug_help_info_2' ) )
    end
end
rcc.register( 'rlib_debug', rcc_debug )

/*
*   rcc :: debug :: check status
*
*   checks the status of debug mode
*/

local function rcc_debug_status( pl, cmd, args )

    /*
    *   define command
    */

    local ccmd = base.calls:get( 'commands', 'rlib_debug_status' )

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

    local dbtimer   = timex.remains( 'rlib_debug_delay' ) or false
    local status    = cfg.debug.enabled and lang( 'opt_enabled' ) or lang( 'opt_disabled' )

    log( 1, lang( 'debug_status', status ) )

    if dbtimer then
        log( 1, lang( 'debug_auto_remains', timex.secs.sh_cols_steps( dbtimer ) ) )
    end
end
rcc.register( 'rlib_debug_status', rcc_debug_status )

/*
*   rcc :: debug :: devop
*
*   executes devop hook
*/

local function rcc_debug_devop( pl, cmd, args )

    /*
    *   define command
    */

    local ccmd = base.calls:get( 'commands', 'rlib_debug_devop' )

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

end
rcc.register( 'rlib_debug_devop', rcc_debug_devop )

/*
*   rcc :: admins
*
*   returns a list of steamids who have access to rlib as a developer
*/

local function rcc_admins( pl, cmd, args )

    /*
    *   define command
    */

    local ccmd = base.calls:get( 'commands', 'rlib_admins' )

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

    local struct        = access:getusers( ) or { }

    con( pl, 0 )

    local d1_l          = sf( '%-25s', 'name'    )
    local d2_l          = sf( '%-5s', '»' )
    local d3_l          = sf( '%-26s', 'steamid' )
    local d4_l          = sf( '%-13s', 'added' )
    local d5_l          = sf( '%-13s', 'last seen' )
    local d7_l          = sf( '%-15s', 'connections' )

    local dv0_l         = sf( '%s%s%s%s%s%s', d1_l, d2_l, d3_l, d4_l, d5_l, d7_l )

    con( pl, clr_r, dv0_l )
    con( pl, 0 )

    local admins        = struct
    local cnt_admins    = table.Count( admins ) or 0

    if cnt_admins < 1 then
        con( pl, clr_y, 'No admins registered with ' .. mf.name )
        con( pl, 0 )
        return
    end

    for l, m in SortedPairs( admins ) do
        local d1_d      = sf( '%-25s', m.name )
        local d2_d      = sf( '%-5s', '»' )
        local d3_d      = sf( '%-26s', l )
        local d4_d      = sf( '%-13s', ( m.date_added ~= 0 and os.date( '%m-%d-%y', m.date_added ) ) or lang( 'timestamp_never' ) )
        local d5_d      = sf( '%-13s', ( m.date_seen ~= 0 and os.date( '%m-%d-%y', m.date_seen ) ) or lang( 'timestamp_never' ) )
        local d6_d      = sf( '%-15s', m.conn or 0 )

        local clr_pl    = not m.is_root and clr_w or clr_p

        con( pl, clr_pl, d1_d, clr_p, d2_d, clr_w, d3_d, clr_w, d4_d, clr_w, d5_d, clr_w, d6_d )
    end

    con( pl, 0 )

end
rcc.register( 'rlib_admins', rcc_admins )

/*
*   rcc :: uptime
*
*   displays the current uptime of the server
*/

local function rcc_uptime( pl, cmd, args )

    /*
    *   define command
    */

    local ccmd = base.calls:get( 'commands', 'rlib_uptime' )

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

    local uptime = timex.secs.sh_cols( SysTime( ) - sys.uptime )
    route( pl, false, script, sf( '%s ', lang( 'server_uptime' ) ), cfg.cmsg.clrs.target, tostring( uptime ) )

end
rcc.register( 'rlib_uptime', rcc_uptime )

/*
*   rcc :: connections
*
*   returns total number of connections to server since last restart
*/

local function rcc_connections( pl, cmd, args )

    /*
    *   define command
    */

    local ccmd = base.calls:get( 'commands', 'rlib_connections' )

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

    local i_pop     = isnumber( sys.connections ) and sys.connections or 0
    local uptime    = timex.secs.duration( SysTime( ) - sys.uptime )
    route( pl, false, script, cfg.smsg.clrs.t1, tostring( i_pop ), cfg.smsg.clrs.msg, 'connections since last restart', cfg.smsg.clrs.t1, uptime, cfg.smsg.clrs.msg, 'ago' )

end
rcc.register( 'rlib_connections', rcc_connections )

/*
*   concommand :: workshops
*
*   returns workshops that are loaded on the server through the various methods including rlib, rcore,
*   and individual modules.
*/

local function rcc_workshops( pl, cmd, args )

    /*
    *   define command
    */

    local ccmd = base.calls:get( 'commands', 'rlib_workshops' )

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

    con( pl, 0 )

    local h1_l  = sf( '%-15s', 'rlib » workshops' )
    local h2_l  = sf( '%-15s', '' )
    local h3_l  = sf( '%s %s', h1_l, h2_l )

    con( pl, clr_r, h3_l )
    con( pl, 0 )

    local ws = base.get:ws( ) or { }

    for l, m in SortedPairs( ws ) do
        local collection_name = istable( m.steamapi ) and m.steamapi.title or lang( 'ws_no_steam_data' )

        if CLIENT then
            steamworks.FileInfo( l, function( res )
                base.w[ l ].steamapi = { title = res.title }
            end )
            collection_name = base.w[ l ].steamapi.title
        end

        local h1_d  = sf( '%-15s', tostring( l ) )
        local h2_d  = sf( '%-5s', '»' )
        local h3_d  = sf( '%-20s', tostring( m.src ) )
        local h4_d  = sf( '%-5s', '»' )
        local h5_d  = sf( '%-15s', helper.str:truncate( collection_name, 40 ) )

        con( pl, clr_y, h1_d, clr_p, h2_d, clr_w, h3_d, clr_p, h4_d, clr_w, h5_d )
    end

    con( pl, 0 )

end
rcc.register( 'rlib_workshops', rcc_workshops )