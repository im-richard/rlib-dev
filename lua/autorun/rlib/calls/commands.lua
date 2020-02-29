/*
*   @package        : rlib
*   @author         : Richard [http://steamcommunity.com/profiles/76561198135875727]
*   @copyright      : (c) 2018 - 2020
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

rlib                        = rlib or { }
local base                  = rlib

/*
*   associated commands
*
*   ::  parameters
*
*       enabled     ::  determines if the command be useable or not
*       is_base     ::  will be considered the base command of the lib.
*       is_hidden   ::  determines if the command should be shown or not in the main list
*                   ::  do not make more than one command the base or you may have issues.
*       id          ::  command that must be typed in console to access
*       clr         ::  color to display command in when searched / seen in console list
*       pubc        ::  public command to execute command
*       desc        ::  description of command
*       args        ::  additional args that command supports
*       scope       ::  what scope the command can be accessed from ( 1 = sv, 2 = sh, 3 = cl )
*       ex          ::  examples of how the command can be utilized; used as visual help for user
*       flags       ::  command arg flags that can be used to access different sub-features
*       notes       ::  important notes to display when user searches help for a command
*       warn        ::  displays a warning to the user about using this command and non-liability
*       no_console  ::  cannot be executed by server-console. must have a valid player running command
*       assoc       ::  associated function executed when command ran
*/

base.c.commands =
{
    [ 'rlib' ] =
    {
        enabled     = true,
        is_base     = true,
        id          = 'rlib',
        desc        = 'primary command which displays top-level help',
        args        = '[ <command> ], [ <-flag> <search_keyword> ]',
        scope       = 2,
        ex =
        {
            'rlib',
            'rlib rlib.version',
            'rlib -a',
            'rlib -f rlib.version',
            'rlib -h rlib.version'
        },
        flags =
        {
            [ 'all' ]       = { flag = '-a', desc = 'displays all cmds in console regardless of scope' },
            [ 'simple' ]    = { flag = '-s', desc = 'returns a more simplified command list' },
            [ 'filter' ]    = { flag = '-f', desc = 'filter search results' },
            [ 'help' ]      = { flag = '-h', desc = 'view help on specific command' },
            [ 'break' ]     = { flag = '-b', desc = 'add breaks after each command' },
        },
        notes =
        {
            'This command is the base command to all sub-levels'
        },
        assoc = function( ply, cmd, args, str )
            rlib.u.cc_base( ply, cmd, args, str )
        end,
    },
    [ 'rlib_access' ] =
    {
        enabled     = true,
        id          = 'rlib.access',
        name        = 'Access',
        desc        = 'returns your current access to rlib',
        pubc        = '!access',
        scope       = 2,
        assoc = function( ply, cmd, args, str )
            rlib.u.cc_access( ply, cmd, args, str )
        end,
    },
    [ 'rlib_admins' ] =
    {
        enabled     = true,
        id          = 'rlib.admins',
        name        = 'Admins',
        desc        = 'returns list of steamids with access to lib',
        scope       = 2,
        assoc = function( ply, cmd, args, str )
            rlib.u.cc_admins( ply, cmd, args, str )
        end,
    },
    [ 'rlib_calls' ] =
    {
        enabled     = true,
        id          = 'rlib.calls',
        name        = 'Calls',
        desc        = 'returns list of registered calls',
        args        = '[ <-flag> <search_keyword> ]',
        scope       = 1,
        ex =
        {
            'rlib.calls',
            'rlib.calls -r',
            'rlib.calls -s rlib',
        },
        flags =
        {
            [ 'search' ]    = { flag = '-s', desc = 'search results' },
            [ 'raw' ]       = { flag = '-r', desc = 'raw simple output' },
        },
        assoc = function( ply, cmd, args, str )
            rlib.u.cc_calls( ply, cmd, args, str )
        end,
    },
    [ 'rlib_debug' ] =
    {
        enabled     = true,
        id          = 'rlib.debug',
        name        = 'Debug',
        desc        = 'toggles debug mode on and off',
        scope       = 2,
        assoc = function( ply, cmd, args, str )
            rlib.u.cc_debug( ply, cmd, args, str )
        end,
    },
    [ 'rlib_debug_status' ] =
    {
        enabled     = true,
        id          = 'rlib.debug.status',
        name        = 'Debug » Status',
        desc        = 'returns state / status of debug mode',
        scope       = 2,
        assoc = function( ply, cmd, args, str )
            rlib.u.cc_debug_status( ply, cmd, args, str )
        end,
    },
    [ 'rlib_debug_clean' ] =
    {
        enabled     = true,
        id          = 'rlib.debug.clean',
        name        = 'Debug » Clean',
        desc        = 'clears all debug logs from server storage',
        scope       = 1,
        ex =
        {
            'rlib.debug.clean',
            'rlib.debug.clean -c',
        },
        flags =
        {
            [ 'cancel' ]    = { flag = '-c', desc = 'cancel cleaning action' },
        },
        assoc = function( ply, cmd, args, str )
            rlib.u.cc_debug_cleanlogs( ply, cmd, args, str )
        end,
    },
    [ 'rlib_debug_diag' ] =
    {
        enabled     = true,
        id          = 'rlib.debug.diag',
        name        = 'Debug » Diagnostic',
        desc        = 'checks a variety of areas to prep from dev -> production',
        scope       = 1,
        ex =
        {
            'rlib.debug.diag',
        },
        assoc = function( ply, cmd, args, str )
            rlib.u.cc_debug_diag( ply, cmd, args, str )
        end,
    },
    [ 'rlib_debug_devop' ] =
    {
        enabled     = true,
        id          = 'rlib.debug.devop',
        name        = 'Debug » DevOP',
        desc        = 'returns devop hook (testing purposes only)',
        scope       = 2,
        assoc = function( ply, cmd, args, str )
            rlib.u.cc_debug_devop( ply, cmd, args, str )
        end,
    },
    [ 'rlib_checksum_new' ] =
    {
        enabled     = true,
        id          = 'rlib.checksum.new',
        name        = 'Checksum » New',
        desc        = 'write the necessary checksums and deploys lib',
        scope       = 1,
        ex =
        {
            'rlib.checksum.new',
        },
        assoc = function( ply, cmd, args, str )
            rlib.u.cc_checksum_new( ply, cmd, args, str )
        end,
    },
    [ 'rlib_checksum_verify' ] =
    {
        enabled     = true,
        id          = 'rlib.checksum.verify',
        name        = 'Checksum » Verify',
        desc        = 'checks the integrity of the official lib files compared to server copy',
        args        = '[ <command> ], [ <-flag> <search_keyword> ]',
        scope       = 1,
        ex =
        {
            'rlib.checksum.verify',
            'rlib.checksum.verify -f rlib_core_sv',
        },
        flags =
        {
            [ 'all' ]       = { flag = '-a', desc = 'displays all results' },
            [ 'filter' ]    = { flag = '-f', desc = 'filter search results' },
        },
        assoc = function( ply, cmd, args, str )
            rlib.u.cc_checksum_verify( ply, cmd, args, str )
        end,
    },
    [ 'rlib_help' ] =
    {
        enabled     = true,
        id          = 'rlib.help',
        name        = 'Help',
        desc        = 'returns help info for lib',
        scope       = 2,
        assoc = function( ply, cmd, args, str )
            rlib.u.cc_help( ply, cmd, args, str )
        end,
    },
    [ 'rlib_oort' ] =
    {
        enabled     = true,
        id          = 'rlib.oort',
        name        = 'Oort Engine » Status',
        desc        = 'returns state / status of oort engine',
        scope       = 1,
        assoc = function( ply, cmd, args, str )
            rlib.u.cc_oort( ply, cmd, args, str )
        end,
    },
    [ 'rlib_languages' ] =
    {
        enabled     = true,
        id          = 'rlib.languages',
        name        = 'Languages',
        desc        = 'returns translation/language info',
        scope       = 2,
        assoc = function( ply, cmd, args, str )
            rlib.u.cc_languages( ply, cmd, args, str )
        end,
    },
    [ 'rlib_license' ] =
    {
        enabled     = true,
        id          = 'rlib.license',
        name        = 'License',
        desc        = 'returns license information for lib',
        scope       = 2,
        assoc = function( ply, cmd, args, str )
            rlib.u.cc_license( ply, cmd, args, str )
        end,
    },
    [ 'rlib_manifest' ] =
    {
        enabled     = true,
        id          = 'rlib.manifest',
        name        = 'Manifest',
        desc        = 'returns lib manifest',
        scope       = 2,
        assoc = function( ply, cmd, args, str )
            rlib.u.cc_manifest( ply, cmd, args, str )
        end,
    },
    [ 'rlib_mats' ] =
    {
        enabled     = true,
        id          = 'rlib.mats',
        name        = 'Material List',
        desc        = 'returns registered materials',
        scope       = 3,
        assoc = function( ply, cmd, args, str )
            rlib.u.cc_materials_list( ply, cmd, args, str )
        end,
    },
    [ 'rlib_modules' ] =
    {
        enabled     = true,
        id          = 'rlib.modules',
        name        = ':: reroute :: rcore modules',
        desc        = 'reroutes to rcore.modules',
        scope       = 1,
        ex =
        {
            'rlib.modules',
            'rlib.modules -p',
        },
        flags =
        {
            [ 'paths' ]         = { flag = '-p', desc = 'display module install paths' },
        },
        assoc = function( ply, cmd, args, str )
            rlib.u.cc_modules_reroute( ply, cmd, args, str )
        end,
    },
    [ 'rlib_packages' ] =
    {
        enabled     = true,
        id          = 'rlib.packages',
        name        = 'Packages',
        desc        = 'returns list of running packages',
        scope       = 1,
        assoc = function( ply, cmd, args, str )
            rlib.u.cc_packages( ply, cmd, args, str )
        end,
    },
    [ 'rlib_panels' ] =
    {
        enabled     = true,
        id          = 'rlib.panels',
        name        = 'Panels » Registered',
        desc        = 'returns list of registered panels',
        args        = '[ <-flag> <search_keyword> ]',
        scope       = 3,
        ex =
        {
            'rlib.panels',
            'rlib.panels -s rlib',
        },
        flags =
        {
            [ 'search' ] = { flag = '-s', desc = 'search results' },
        },
        assoc = function( ply, cmd, args, str )
            rlib.u.cc_rpanels( ply, cmd, args, str )
        end,
    },
    [ 'rlib_services' ] =
    {
        enabled     = true,
        id          = 'rlib.services',
        name        = 'Services » Status',
        desc        = 'returns list of services and their status',
        args        = '[ <-flag> <search_keyword> ]',
        scope       = 2,
        ex =
        {
            'rlib.services',
            'rlib.services -s pco',
        },
        flags =
        {
            [ 'search' ] = { flag = '-s', desc = 'search results' },
        },
        assoc = function( ply, cmd, args, str )
            rlib.u.cc_services( ply, cmd, args, str )
        end,
    },
    [ 'rlib_asay' ] =
    {
        enabled     = true,
        warn        = true,
        no_console  = false,
        id          = 'rlib.asay',
        name        = 'Tools » ASay',
        desc        = 'Send messages using the asay tool',
        args        = '[ <msg> ]',
        scope       = 1,
        ex =
        {
            'rlib.asay hello',
        },
        assoc = function( ply, cmd, args, str )
            rlib.u.cc_tools_asay( ply, cmd, args, str )
        end,
    },
    [ 'rlib_tools_rdo' ] =
    {
        enabled     = true,
        warn        = true,
        id          = 'rlib.tools.rdo',
        name        = 'Tools » RDO',
        desc        = '(render distance optimization), return or set state / status of rdo',
        args        = '[ <state> ]',
        scope       = 1,
        ex =
        {
            'rlib.tools.rdo',
            'rlib.tools.rdo enable',
            'rlib.tools.rdo disable',
        },
        assoc = function( ply, cmd, args, str )
            rlib.u.cc_tools_rdo( ply, cmd, args, str )
        end,
    },
    [ 'rlib_tools_pco' ] =
    {
        enabled     = true,
        warn        = true,
        no_console  = true,
        id          = 'rlib.tools.pco',
        name        = 'Tools » PCO',
        desc        = '(player client optimization), return or set state / status of pco',
        args        = '[ <state> ]',
        scope       = 1,
        ex =
        {
            'rlib.tools.pco',
            'rlib.tools.pco enable',
            'rlib.tools.pco disable',
        },
        assoc = function( ply, cmd, args, str )
            rlib.u.cc_tools_pco( ply, cmd, args, str )
        end,
    },
    [ 'rlib_restart' ] =
    {
        enabled     = true,
        id          = 'rlib.restart',
        name        = 'Restart',
        desc        = 'restarts server / cancel a timed restart.',
        scope       = 1,
        flags =
        {
            [ 'cancel' ] = { flag = '-c' },
        },
        ex =
        {
            'rlib.restart',
            'rlib.restart -c',
        },
        assoc = function( ply, cmd, args, str )
            rlib.u.cc_restart( ply, cmd, args, str )
        end,
    },
    [ 'rlib_trestart' ] =
    {
        enabled     = true,
        id          = 'rlib.trestart',
        name        = 'Restart » Timed',
        desc        = 'restarts server after (x) secs / notice in-game. Default: 30s can be cancelled with rlib.trestart -c',
        args        = '[ <seconds> ]',
        scope       = 1,
        flags =
        {
            [ 'cancel' ] = { flag = '-c' },
        },
        ex =
        {
            'rlib.trestart',
            'rlib.trestart -c',
        },
        notes =
        {
            'Can be cancelled with the command [ rlib.trestart -c ]',
            'Default: 30 seconds'
        },
        assoc = function( ply, cmd, args, str )
            rlib.u.cc_timed_restart( ply, cmd, args, str )
        end,
    },
    [ 'rlib_setup' ] =
    {
        enabled     = true,
        id          = 'rlib.setup',
        name        = 'Setup library',
        desc        = 'configures certain parameters of rlib; should be ran when first installed',
        pubc        = '!setup',
        scope       = 1,
        assoc = function( ply, cmd, args, str )
            rlib.u.cc_setup( ply, cmd, args, str )
        end,
    },
    [ 'rlib_status' ] =
    {
        enabled     = true,
        id          = 'rlib.status',
        name        = 'Status',
        desc        = 'returns stats and data for the lib',
        scope       = 1,
        assoc = function( ply, cmd, args, str )
            rlib.u.cc_status( ply, cmd, args, str )
        end,
    },
    [ 'rlib_reload' ] =
    {
        enabled     = true,
        warn        = true,
        id          = 'rlib.reload',
        name        = 'Reload',
        desc        = 'reloads rlib to server',
        scope       = 1,
        assoc = function( ply, cmd, args, str )
            rlib.u.cc_reload( ply, cmd, args, str )
        end,
    },
    [ 'rlib_udm' ] =
    {
        enabled     = true,
        id          = 'rlib.udm',
        name        = 'Updater',
        desc        = 'toggles udm [ update manager ] on / off',
        scope       = 1,
        ex =
        {
            'rlib.udm',
            'rlib.udm run',
            'rlib.udm on',
            'rlib.udm off',
        },
        assoc = function( ply, cmd, args, str )
            rlib.u.cc_udm( ply, cmd, args, str )
        end,
    },
    [ 'rlib_uptime' ] =
    {
        enabled     = true,
        id          = 'rlib.uptime',
        name        = 'Uptime',
        desc        = 'returns uptime of the server',
        pubc        = '!uptime',
        scope       = 2,
        assoc = function( ply, cmd, args, str )
            rlib.u.cc_uptime( ply, cmd, args, str )
        end,
    },
    [ 'rlib_user' ] =
    {
        enabled     = true,
        id          = 'rlib.user',
        name        = 'Manage User',
        desc        = 'manages player perms for lib',
        scope       = 1,
        ex =
        {
            'rlib.user add player',
            'rlib.user remove player',
            'rlib.user status player',
            'rlib.user -a player',
            'rlib.user -r player',
            'rlib.user -s player',
        },
        flags =
        {
            [ 'add' ]       = { flag = '-a', desc = 'adds a player to rlib access' },
            [ 'remove' ]    = { flag = '-r', desc = 'removes a player from rlib access' },
            [ 'status' ]    = { flag = '-s', desc = 'checks a players access to rlib' },
        },
        assoc = function( ply, cmd, args, str )
            rlib.u.cc_user( ply, cmd, args, str )
        end,
    },
    [ 'rlib_version' ] =
    {
        enabled     = true,
        id          = 'rlib.version',
        name        = 'Version',
        desc        = 'current running build of lib',
        pubc        = '!version',
        scope       = 2,
        assoc = function( ply, cmd, args, str )
            rlib.u.cc_version( ply, cmd, args, str )
        end,
    },
    [ 'rlib_workshops' ] =
    {
        enabled     = true,
        id          = 'rlib.workshops',
        name        = 'Workshops',
        desc        = 'returns workshop ids loaded between modules / lib',
        scope       = 2,
        assoc = function( ply, cmd, args, str )
            rlib.u.cc_workshops( ply, cmd, args, str )
        end,
    },
}