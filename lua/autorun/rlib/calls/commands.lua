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

rlib                        = rlib or { }
local base                  = rlib

/*
*   associated commands
*
*   :   parameters
*
*       enabled     :   determines if the command be useable or not
*       is_base     :   will be considered the base command of the lib.
*       is_hidden   :   determines if the command should be shown or not in the main list
*                   :   do not make more than one command the base or you may have issues.
*       id          :   command that must be typed in console to access
*       clr         :   color to display command in when searched / seen in console list
*       pubc        :   public command to execute command
*       desc        :   description of command
*       args        :   additional args that command supports
*       scope       :   what scope the command can be accessed from ( 1 = sv, 2 = sh, 3 = cl )
*       showsetup   :   displays the command in the help info after the server owner has been recognized using ?setup
*       official    :   official rlib command; displayed within console when 'rlib' command input
*       ex          :   examples of how the command can be utilized; used as visual help for user
*       flags       :   command arg flags that can be used to access different sub-features
*       notes       :   important notes to display when user searches help for a command
*       warn        :   displays a warning to the user about using this command and non-liability
*       no_console  :   cannot be executed by server-console. must have a valid player running command
*/

base.c.commands =
{
    [ 'rlib' ] =
    {
        enabled     = true,
        is_base     = true,
        id          = 'rlib',
        desc        = 'base command, displays top-level help',
        args        = '[ <command> ], [ <-flag> <search_keyword> ]',
        scope       = 2,
        showsetup   = true,
        official    = true,
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
            [ 'all' ]       = { flag = '-a',        desc = 'displays all cmds in console regardless of scope' },
            [ 'simple' ]    = { flag = '-s',        desc = 'get a more simplified command list' },
            [ 'filter' ]    = { flag = '-f',        desc = 'filter search results' },
            [ 'help' ]      = { flag = '-h',        desc = 'view help on specific command' },
            [ 'break' ]     = { flag = '-b',        desc = 'add breaks after each command' },
            [ 'modules' ]   = { flag = '-m',        desc = 'displays module commands only' },
        },
        notes =
        {
            'This command is the base command to all sub-levels'
        },
    },
    [ 'rlib_access' ] =
    {
        enabled     = true,
        id          = 'rlib.access',
        name        = 'Access',
        desc        = 'users access to lib',
        pubc        = '!access',
        scope       = 2,
        official    = true,
    },
    [ 'rlib_admins' ] =
    {
        enabled     = true,
        id          = 'rlib.admins',
        name        = 'Admins',
        desc        = 'list of steamids with access to lib',
        scope       = 2,
        showsetup   = true,
        official    = true,
    },
    [ 'rlib_asay' ] =
    {
        enabled     = true,
        warn        = true,
        no_console  = false,
        id          = 'rlib.asay',
        name        = 'Tools » ASay',
        desc        = 'Send msgs using asay',
        args        = '[ <msg> ]',
        scope       = 1,
        showsetup   = true,
        official    = true,
        ex =
        {
            'rlib.asay hello',
        },
    },
    [ 'rlib_calls' ] =
    {
        enabled     = true,
        id          = 'rlib.calls',
        name        = 'Calls',
        desc        = 'list of registered calls',
        args        = '[ <-flag> <search_keyword> ]',
        scope       = 1,
        official    = true,
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
    },
    [ 'rlib_changelog' ] =
    {
        enabled     = true,
        id          = 'rlib.changelog',
        name        = 'Changelog',
        desc        = 'displays the lib changelog',
        scope       = 2,
        official    = true,
        flags =
        {
            [ 'search' ]    = { flag = '-s', desc = 'search results' },
        },
    },
    [ 'rlib_checksum_new' ] =
    {
        enabled     = true,
        id          = 'rlib.checksum.new',
        name        = 'Checksum » New',
        desc        = 'write checksums and deploy lib',
        scope       = 1,
        official    = true,
        ex =
        {
            'rlib.checksum.new',
        },
    },
    [ 'rlib_checksum_verify' ] =
    {
        enabled     = true,
        id          = 'rlib.checksum.verify',
        name        = 'Checksum » Verify',
        desc        = 'checks the integrity of lib files',
        args        = '[ <command> ], [ <-flag> <search_keyword> ]',
        scope       = 1,
        official    = true,
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
    },
    [ 'rlib_clear' ] =
    {
        enabled     = true,
        id          = 'rlib.clear',
        alias       = 'clr',
        name        = 'Clear console',
        desc        = 'clears the console so you can start fresh',
        scope       = 2,
        official    = true,
    },
    [ 'rlib_connections' ] =
    {
        enabled     = true,
        id          = 'rlib.connections',
        name        = 'Connections',
        desc        = 'total connections since last restart',
        pubc        = '!connections',
        scope       = 2,
        showsetup   = true,
        official    = true,
    },
    [ 'rlib_debug' ] =
    {
        enabled     = true,
        id          = 'rlib.debug',
        name        = 'Debug',
        desc        = 'toggles debug mode on and off',
        scope       = 2,
        showsetup   = true,
        official    = true,
    },
    [ 'rlib_debug_status' ] =
    {
        enabled     = true,
        id          = 'rlib.debug.status',
        name        = 'Debug » Status',
        desc        = 'status of debug mode',
        scope       = 2,
        official    = true,
    },
    [ 'rlib_debug_clean' ] =
    {
        enabled     = true,
        id          = 'rlib.debug.clean',
        name        = 'Debug » Clean',
        desc        = 'erases all debug logs from server',
        scope       = 1,
        official    = true,
        ex =
        {
            'rlib.debug.clean',
            'rlib.debug.clean -c',
        },
        flags =
        {
            [ 'cancel' ]    = { flag = '-c', desc = 'cancel cleaning action' },
        },
    },
    [ 'rlib_debug_diag' ] =
    {
        enabled     = true,
        id          = 'rlib.debug.diag',
        name        = 'Debug » Diagnostic',
        desc        = 'dev => production preparation',
        scope       = 1,
        showsetup   = true,
        official    = true,
        ex =
        {
            'rlib.debug.diag',
        },
    },
    [ 'rlib_debug_devop' ] =
    {
        enabled     = true,
        id          = 'rlib.debug.devop',
        name        = 'Debug » DevOP',
        desc        = 'devop hook (dev only)',
        scope       = 2,
        official    = true,
    },
    [ 'rlib_help' ] =
    {
        enabled     = true,
        id          = 'rlib.help',
        name        = 'Help',
        desc        = 'help info for lib',
        scope       = 2,
        showsetup   = true,
        official    = true,
    },
    [ 'rlib_languages' ] =
    {
        enabled     = true,
        id          = 'rlib.languages',
        name        = 'Languages',
        desc        = 'language info',
        scope       = 2,
        official    = true,
    },
    [ 'rlib_license' ] =
    {
        enabled     = true,
        id          = 'rlib.license',
        name        = 'License',
        desc        = 'license for lib',
        scope       = 2,
        official    = true,
    },
    [ 'rlib_manifest' ] =
    {
        enabled     = true,
        id          = 'rlib.manifest',
        name        = 'Manifest',
        desc        = 'lib manifest',
        scope       = 2,
        official    = true,
    },
    [ 'rlib_mats' ] =
    {
        enabled     = true,
        id          = 'rlib.mats',
        name        = 'Material List',
        desc        = 'registered mats',
        scope       = 3,
        official    = true,
    },
    [ 'rlib_modules' ] =
    {
        enabled     = true,
        id          = 'rlib.modules',
        name        = 'rcore modules',
        desc        = 'all rcore modules',
        scope       = 1,
        showsetup   = true,
        official    = true,
        ex =
        {
            'rlib.modules',
            'rlib.modules -p',
        },
        flags =
        {
            [ 'paths' ]         = { flag = '-p', desc = 'display module install paths' },
        },
    },
    [ 'rlib_modules_errlog' ] =
    {
        enabled     = true,
        id          = 'rlib.modules.errlog',
        name        = 'errlogs',
        desc        = 'displays errlog for modules',
        scope       = 1,
        showsetup   = true,
        official    = true,
        ex =
        {
            'rlib.modules.errlog',
        },
    },
    [ 'rlib_oort' ] =
    {
        enabled     = true,
        id          = 'rlib.oort',
        name        = 'Oort Engine » Status',
        desc        = 'status of oort engine',
        scope       = 1,
        official    = true,
    },
    [ 'rlib_oort_update' ] =
    {
        enabled     = true,
        id          = 'rlib.oort.update',
        name        = 'Oort Engine » Update',
        desc        = 'updates server stats to oort engine database',
        scope       = 1,
        official    = true,
    },
    [ 'rlib_oort_next' ] =
    {
        enabled     = true,
        id          = 'rlib.oort.next',
        name        = 'Oort Engine » Next Update',
        desc        = 'returns time until next oort engine stats update',
        scope       = 1,
        official    = true,
    },
    [ 'rlib_oort_sendlog' ] =
    {
        enabled     = true,
        id          = 'rlib.oort.sendlog',
        name        = 'Oort Engine » Send Log',
        desc        = 'sends an error log to developer',
        scope       = 1,
        official    = true,
    },
    [ 'rlib_packages' ] =
    {
        enabled     = true,
        id          = 'rlib.packages',
        name        = 'Packages',
        desc        = 'list of running packages',
        scope       = 1,
        official    = true,
    },
    [ 'rlib_panels' ] =
    {
        enabled     = true,
        id          = 'rlib.panels',
        name        = 'Panels » Registered',
        desc        = 'list of registered panels',
        args        = '[ <-flag> <search_keyword> ]',
        scope       = 3,
        official    = true,
        ex =
        {
            'rlib.panels',
            'rlib.panels -s rlib',
        },
        flags =
        {
            [ 'search' ] = { flag = '-s', desc = 'search results' },
        },
    },
    [ 'rlib_terms' ] =
    {
        enabled     = true,
        id          = 'rlib.terms',
        name        = 'Terms',
        desc        = 'displays terms / intro panel',
        scope       = 3,
        official    = true,
        ex =
        {
            'rlib.terms',
        },
    },
    [ 'rlib_rcc_rehash' ] =
    {
        enabled     = true,
        id          = 'rlib.rcc.rehash',
        name        = 'Rehash RCC',
        desc        = 'refreshes registered command calls',
        scope       = 2,
        official    = true,
        ex =
        {
            'rlib.rcc.rehash',
        },
    },
    [ 'rlib_rehash' ] =
    {
        enabled     = true,
        warn        = true,
        id          = 'rlib.rehash',
        name        = 'Rehash',
        desc        = 'reloads rlib / services on server',
        scope       = 1,
        official    = true,
    },
    [ 'rlib_reload' ] =
    {
        enabled     = true,
        warn        = true,
        id          = 'rlib.reload',
        name        = 'Reload',
        desc        = 'reloads lib on server',
        scope       = 1,
        official    = true,
    },
    [ 'rlib_restart' ] =
    {
        enabled     = true,
        id          = 'rlib.restart',
        name        = 'Restart',
        desc        = 'restart server / cancel timed restarts',
        scope       = 1,
        official    = true,
        flags =
        {
            [ 'cancel' ] = { flag = '-c' },
        },
        ex =
        {
            'rlib.restart',
            'rlib.restart -c',
        },
    },
    [ 'rlib_rpm' ] =
    {
        enabled     = true,
        id          = 'rlib.rpm',
        name        = 'Mount',
        desc        = 'mounts an available package to rlib from the webserver',
        scope       = 1,
        official    = true,
        ex =
        {
            'rlib.rpm',
            'rlib.rpm package',
            'rlib.rpm -l',
        },
        flags =
        {
            [ 'list' ]         = { flag = '-l', desc = 'lists packages available' },
        },
    },
    [ 'rlib_running' ] =
    {
        enabled     = true,
        id          = 'rlib.running',
        name        = 'Running',
        desc        = 'current modules installed on server',
        pubc        = '!running',
        scope       = 2,
        showsetup   = false,
        official    = true,
    },
    [ 'rlib_services' ] =
    {
        enabled     = true,
        id          = 'rlib.services',
        name        = 'Services » Status',
        desc        = 'list of services and status',
        args        = '[ <-flag> <search_keyword> ]',
        scope       = 2,
        official    = true,
        ex =
        {
            'rlib.services',
            'rlib.services -s pco',
        },
        flags =
        {
            [ 'search' ] = { flag = '-s', desc = 'search results' },
        },
    },
    [ 'rlib_trestart' ] =
    {
        enabled     = true,
        id          = 'rlib.trestart',
        name        = 'Restart » Timed',
        desc        = 'delayed restart | Def: 30s',
        args        = '[ <seconds> ]',
        scope       = 1,
        official    = true,
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
    },
    [ 'rlib_tools_pco' ] =
    {
        enabled     = true,
        warn        = true,
        no_console  = true,
        id          = 'rlib.tools.pco',
        name        = 'Tools » PCO',
        desc        = '(player client optimization), return / set status of pco',
        args        = '[ <state> ]',
        scope       = 1,
        showsetup   = true,
        official    = true,
        ex =
        {
            'rlib.tools.pco',
            'rlib.tools.pco enable',
            'rlib.tools.pco disable',
        },
    },
    [ 'rlib_tools_rdo' ] =
    {
        enabled     = true,
        warn        = true,
        id          = 'rlib.tools.rdo',
        name        = 'Tools » RDO',
        desc        = '(render distance optimization), return / set status of rdo',
        args        = '[ <state> ]',
        scope       = 1,
        showsetup   = true,
        official    = true,
        ex =
        {
            'rlib.tools.rdo',
            'rlib.tools.rdo enable',
            'rlib.tools.rdo disable',
        },
    },
    [ 'rlib_session' ] =
    {
        enabled     = true,
        warn        = true,
        id          = 'rlib.session',
        name        = 'Session',
        desc        = 'your current sess id',
        scope       = 2,
        showsetup   = true,
        official    = true,
    },
    [ 'rlib_setup' ] =
    {
        enabled     = true,
        id          = 'rlib.setup',
        name        = 'Setup library',
        desc        = 'setup lib | should be ran at first install',
        pubc        = '!setup',
        scope       = 1,
        official    = true,
    },
    [ 'rlib_status' ] =
    {
        enabled     = true,
        id          = 'rlib.status',
        name        = 'Status',
        desc        = 'stats and data for the lib',
        scope       = 1,
        showsetup   = true,
        official    = true,
    },
    [ 'rlib_udm' ] =
    {
        enabled     = true,
        id          = 'rlib.udm',
        name        = 'Updater',
        desc        = 'toggles udm [ update manager ] on / off',
        scope       = 1,
        official    = true,
        ex =
        {
            'rlib.udm',
            'rlib.udm run',
            'rlib.udm on',
            'rlib.udm off',
        },
    },
    [ 'rlib_uptime' ] =
    {
        enabled     = true,
        id          = 'rlib.uptime',
        name        = 'Uptime',
        desc        = 'uptime of the server',
        pubc        = '!uptime',
        scope       = 2,
        showsetup   = true,
        official    = true,
    },
    [ 'rlib_user' ] =
    {
        enabled     = true,
        id          = 'rlib.user',
        name        = 'Manage User',
        desc        = 'manages player perms for lib',
        scope       = 1,
        official    = true,
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
    },
    [ 'rlib_version' ] =
    {
        enabled     = true,
        id          = 'rlib.version',
        name        = 'Version',
        desc        = 'current running ver of lib',
        pubc        = '!version',
        scope       = 2,
        showsetup   = true,
        official    = true,
    },
    [ 'rlib_workshops' ] =
    {
        enabled     = true,
        id          = 'rlib.workshops',
        name        = 'Workshops',
        desc        = 'workshop ids loaded between modules / lib',
        scope       = 2,
        showsetup   = true,
        official    = true,
    },
}