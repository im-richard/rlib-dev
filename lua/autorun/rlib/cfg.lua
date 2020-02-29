/*
*   @package        rlib
*   @author         Richard [http://steamcommunity.com/profiles/76561198135875727]
*   @copyright      (C) 2018 - 2020
*   @since          1.0.0
*   @website        https://rlib.io
*   @docs           https://docs.rlib.io
*   @file           cfg.lua
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
local cfg               = base.settings
local mf                = base.manifest
local prefix            = mf.prefix

/*
*   Localized rlib routes
*/

local ui                = base.i
local konsole           = base.k

/*
*   Localized lua funcs
*/

local string            = string
local sf                = string.format

/*
*   Localized translation func
*/

local function lang( ... )
    return base:lang( ... )
end

/*
*	language
*
*	determines language to use when translating particular strings.
*	list of available languages can be found in the lang folder or by typing the console command:
*       :: rlib.languages
*
*	@type       : str
*	@default    : 'en'
*/

    cfg.lang = 'en'

/*
*   protection
*
*   if enabled, vital code will be called from the outside protection system. Turning this off may
*   cause numerous parts of the script to fail due to lack of code.
*
*   @assoc      : rlib => oort
*   @type       : bool
*   @default    : true
*/

    cfg.protection = true

/*
*   udm [ update manager ]
*    
*   :   enabled
*       checks the repo for the most up-to-date version
*
*   :   checktime
*       determines how often the system checks for updates to lib in seconds
*/

    cfg.udm =
    {
        enabled     = true,
        checktime   = 1800,
    }

/*
*   debug :: toggle
*
*   enabled [ true ] allows for special debug returns to print in console which helps with diagnosing 
*   issues with the server
*
*   you may use the alternative method provided which utilizing a concommand to activate debug mode for
*   approx. 20 minutes. automatically turns itself off after the timer has expired.
* 
*   if disabled [ false ], logging system will still print message types related to errors, warnings, 
*   successes, and various others, however, anything labeled as a 'debug' message type will be silenced.
*
*   :   enabled
*       determines if debug mode enabled
*
*   :   stats
*       prints server and loadtime statistics when everything has finished loading.
*
*   :   clean_threshold
*       number of files that must reside in the debug folder before a message is displayed in console to 
*       clean the folder.
*
*   @assoc      : libs/rlib_core_sh.lua
*               : base:log( )
*/

    cfg.debug =
    {
        enabled             = false,
        stats               = true,
        time_default        = 300,
        clean_threshold     = 100,
        clean_delaytime     = 30,
    }

/*
*   interface :: konsole
*
*   integrated console which accepts input from users with access
*
*   :   ui.width, ui.height
*       determines the size of the rlib dev console interface
*
*   :   keybind.act_btn1, keybind.act_btn2
*       keys to press in order to activate konsole interface
*
*   :   keybind.history_up, keybind.history_down
*       keys to press in order to shuffle through command history
*
*   :   fadetime
*       determines how long the ui will fade for when an action occurs
*
*   :   prefix_say
*       the prefix to start a command out with in order for it to detect it as a 'say' activity.
*
*   :   prefix_gcon
*       the prefix to start a command out with in order for it to detect it as an actual console command 
*       which will utilize RunConsoleCommand / rlib.rcc
*
*   :   ts_format
*       determines how timestamps will appear for messages
*/

    cfg.konsole =
    {
        ui =
        {
            width           = 500,
            height          = 345,
        },
        binds =
        {
            act_btn1        = 79,   -- key: shift
            act_btn2        = 59,   -- key: period
            history_up      = 88,   -- key: up arrow
            history_down    = 90,   -- key: down arrow
            chat            = { '!console', '!konsole' },
        },
        fadetime            = 8,
        prefix_say          = '!',
        prefix_gcon         = '#',
        ts_format           = os.date( '%I:%M:%S' ),
    }

/*
*   konsole :: help
*
*   pre-determined actions based on keyphrases
*
*   @todo       : more detailed help
*   @type       : tbl
*/

    cfg.konsole.help =
    {
        [ 'help' ] =
        {
            desc = 'view a list of available commands',
            func = function( )
                local help_cache = { }
                local i = #cfg.konsole.help
                for k, v in SortedPairs( cfg.konsole.help ) do
                    if not v.func then continue end
                    help_cache[ i ] = k
                    i = i + 1
                end

                local help_list     = table.concat( help_cache, ', ' )
                help_list           = help_list:sub( 1, -1 )

                konsole:send( 8, 'Help :: Commands' )
                konsole:send( 0, help_list )
            end
        },
        [ 'calls' ] =
        {
            desc = 'view the registered list of calls',
            func = function( )
                base.cc.Run( prefix .. 'calls' )
                konsole:send( 8, 'View console for calls list' )
            end
        },
        [ 'clear' ] =
        {
            desc = 'clears the konsole text window',
            func = function( )
                if ui:valid( konsole.pnl ) then
                    konsole.pnl:Clean( )
                end
            end
        },
        [ 'clearhistory' ] =
        {
            desc = 'clear list of commands you have used during this session',
            func = function( )
                local pl            = LocalPlayer( )
                local i_history     = pl.konsole_history and #pl.konsole_history or 0
                pl.konsole_history  = { }

                konsole:send_varg( 8, '%i entries successfully cleared', i_history )
            end
        },
        [ 'exit' ] =
        {
            desc = 'destroys this console panel completely with no further feedback during this session',
            func = function( s )
                ui:destroy( s )
            end
        },
        [ 'history' ] =
        {
            desc = 'returns number of commands in your history list',
            func = function( )
                local pl            = LocalPlayer( )
                local i_history     = pl.konsole_history and #pl.konsole_history or 0
                konsole:send_varg( 8, '%i entries in command history', i_history )
            end
        },
        [ 'listhistory' ] =
        {
            desc = 'list commands you have used during this session',
            func = function( )
                local pl        = LocalPlayer( )
                local h_table   = pl.konsole_history or { }
                local h_list    = table.concat( h_table, ', ' )
                h_list          = h_list:sub( 1, -1 )

                konsole:send( 8, 'History List' )
                konsole:send( 0, h_list )
            end
        },
        [ 'uptime' ] =
        {
            desc = 'how long the server has been online',
            func = function( )
                base.cc.Run( prefix .. 'uptime' )
                local uptime = timex.secs.sh_cols( SysTime( ) - rlib.sys.uptime )
                konsole:send( 0, Color( 255, 255, 255 ), sf( '%s ', lang( 'server_uptime' ) ), Color( 200, 50, 50 ), uptime )
            end
        },
        [ 'version' ] =
        {
            desc = 'get the current version of ' .. prefix,
            func = function( )
                base.cc.Run( prefix .. 'version' )
                konsole:send( 0, Color( 255, 255, 255 ), 'running ', Color( 31, 133, 222 ), 'v' .. base.get:versionstr( ), Color( 200, 200, 200 ), ' [ ', Color( 194, 111, 111 ), os.date( '%m.%d.%Y', mf.released ), Color( 200, 200, 200 ), ' ] ' )
            end
        },
    }

/*
*   interfaces
*/

    /*
    *   interface :: main
    *
    *   various setting related to rmain interface
    *
    *   :   ui.width, ui.height
    *       determines the size of the interface
    *
    *   :   binds.key1, binds.key2
    *       keys to press in order to activate interface
    */

        cfg.rmain =
        {
            ui =
            {
                width       = 333,
                height      = 495,
            },
            binds =
            {
                key1        = 79,   -- key: shift
                key2        = 58,   -- key: comma
                chat        = { '!rlib', '!about' },
            },
        }

    /*
    *   interface :: rlib cofiguration manager
    *
    *   various setting related to config manager interface
    *
    *   :   ui.width, ui.height
    *       determines the size of the interface
    *
    *   :   binds.key1, binds.key2
    *       keys to press in order to activate interface
    */

        cfg.rcfg =
        {
            ui =
            {
                width       = 400,
                height      = 350,
            },
            binds =
            {
                enabled     = false,
                key1        = 79,   -- key: shift
                key2        = 58,   -- key: comma
                chat        = { '!rcfg', '!configs' },
            },
        }

    /*
    *   interface :: model viewer
    *
    *   various setting related to mviewer (model viewer) interface
    *
    *   :   ui.width, ui.height
    *       determines the size of the interface
    */

        cfg.mviewer =
        {
            ui =
            {
                width       = 1000,
                height      = 900,
            },
            binds =
            {
                chat        = { '!mviewer', '!mdlview' },
            },
        }

    /*
    *   interface :: language select
    *
    *   displays the language selection interface
    *
    *   :   ui.width, ui.height
    *       determines the size of the interface
    */

        cfg.languages =
        {
            ui =
            {
                width       = 450,
                height      = 250,
            },
            binds =
            {
                chat        = '!lang',
            },
        }

    /*
    *   interface :: disconnect
    *
    *   various setting related to disconnection interface
    *   
    *   :   ui.width, ui.height
    *       determines the size of the interface
    */

        cfg.dc =
        {
            ui =
            {
                width       = 450,
                height      = 250,
            },
            binds =
            {
                chat        = '!dc',
            },
        }

    /*
    *   interface :: report
    *
    *   various setting related to report interface
    *   
    *   :   ui.width, ui.height
    *       determines the size of the interface
    *
    *   :   binds.key1, binds.key2
    *       keys to press in order to activate interface
    */

        cfg.report =
        {
            ui =
            {
                width       = 550,
                height      = 400,
            },
            binds =
            {
                key1        = 79,   -- key: shift
                key2        = 60,   -- key: slash
            },
        }

/*
*   services :: pco [ player client optimizations ]
*
*   only works if server-side cvar 'rlib_pco 1'
*/

    cfg.pco =
    {
        binds =
        {
            chat    = '!pco',
        }
    }

/*
*   services :: rdo [ render distance optimizations ]
*/

    cfg.rdo =
    {
        enabled = true,
        drawdist =
        {
            enabled = true,
            limits =
            {
                ply_min = 5000,     ply_max = 5000,
                ent_min = 3000,     ent_max = 3000,
                npc_min = 1500,     npc_max = 1750,
                oth_min = 3000,     oth_max = 3000,
                wls_min = 10000,    wls_max = 10000,
            },
        },
        ents =
        {
            [ 'prop_dynamic' ]                  = true,
            [ 'prop_dynamic_override' ]         = true,
            [ 'prop_physics' ]                  = true,
            [ 'prop_physics_multiplayer' ]      = true,
            [ 'prop_physics_override' ]         = true,
            [ 'prop_ragdoll' ]                  = true,
            [ 'info_overlay' ]                  = true,
            [ 'func_lod' ]                      = true,
            [ 'func_button' ]                   = true,
            [ 'func_door' ]                     = true,
            [ 'func_door_rotating' ]            = true,
        }
    }

/*
*   services :: precaching
*/

    cfg.cache =
    {
        darkrp_mdl      = true,
        debug_listall   = false,
    }

/*
*   dialogs
*
*   dialogs help deliver important information to users on-screen using draw hooks. the properties below
*   help customize these notices.
*/

    cfg.dialogs =
    {
        mat_gradient        = 'gui/center_gradient',
        audio               = 'ambient/levels/canals/drip3.wav',
        clrs =
        {
            primary         = Color( 25, 25, 25, 255 ),
            secondary       = Color( 217, 72, 72, 255 ),
            primary_text    = Color( 255, 255, 255, 255 ),
            progress        = Color( 217, 72, 72, 255 ),
            icons           = Color( 255, 255, 255, 255 ),
        }
    }

/*
*   sendcmsg
*
*   @note   : will be deprecated in a future release
*           : review new smsg table
*
*   cmessages allow for user input when a player types something in chat.
*   they attempt to inform the player about an action based on the command they enter in chat, which color
*   variants to separate data so it is more easily readable to the player.
*
*   :   tag_private
*       tag lets the player know that the message they have received is a private message.
*
*       @example    : < [PRIVATE] [subcategory]: message >
*                   : < [PRIVATE] [module name]: Feature has been disabled >
*
*   :   tag_server
*       tag lets the player know that the message they have received is a private message.
*
*       @example    : < [SERVER] [subcategory]: message >
*                   : < [SERVER] [module name]: Feature has been disabled >
*
*   :   clrs
*       defines the colors to use for particular segments
*
*       cat         : Gamemode or Module name
*       subcat      : Feature name
*       msg         : Standard message
*       target      : First set of data
*       target_sec  : Second set of data
*       target_tri  : Third set of data
*/

    cfg.cmsg =
    {
        tag             = 'rlib',
        tag_private     = 'PRIVATE',
        tag_server      = 'SERVER',
        tag_console     = 'CONSOLE',
        clrs =
        {
            cat         = Color( 255, 89, 0 ),       -- red / orange
            subcat      = Color( 255, 255, 25 ),     -- yellow
            msg         = Color( 255, 255, 255 ),    -- white
            target      = Color( 25, 200, 25 ),      -- green
            target_sec  = Color( 180, 20, 20 ),      -- dark red
            target_tri  = Color( 13, 134, 255 ),     -- blue
            sec         = Color( 255, 255, 25 ),     -- yellow
            tri         = Color( 255, 107, 250 ),    -- pink
            quad        = Color( 25, 200, 25 ),      -- green
        }
    }

/*
*   sendmsg
*   
*   similar to cmsg which will be deprecated in the future, so we're specifying the new tables
*   now so that they can be used for future projects.
*
*   @ref    : cmsg
*/

    cfg.smsg =
    {
        id              = 'rlib',
        to_private      = 'PRIVATE',
        to_server       = 'SERVER',
        to_staff        = 'STAFF',
        to_admins       = 'ADMINS',
        to_console      = 'CONSOLE',
        to_asay         = 'ASAY',
        to_self         = 'YOU',
        binds =
        {
            asay        = { trigger = '#', command = '/asay' }
        },
        clrs =
        {
            c1      = Color( 255, 89, 0 ),       -- red / orange
            c2      = Color( 255, 255, 25 ),     -- yellow
            msg     = Color( 255, 255, 255 ),    -- white
            t1      = Color( 25, 200, 25 ),      -- green
            t2      = Color( 180, 20, 20 ),      -- dark red
            t3      = Color( 13, 134, 255 ),     -- blue
            t4      = Color( 255, 255, 25 ),     -- yellow
            t5      = Color( 255, 107, 250 ),    -- pink
            t6      = Color( 25, 200, 25 ),      -- green
        }
    }