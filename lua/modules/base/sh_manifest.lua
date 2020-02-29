/*
*   @package        : rcore
*   @module         : base
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
*   module data
*/

    MODULE                  = { }
    MODULE.calls            = { }
    MODULE.resources        = { }

    MODULE.enabled          = true
    MODULE.name             = 'Base'
    MODULE.id               = 'base'
    MODULE.desc             = 'base module'
    MODULE.author           = 'Richard'
    MODULE.icon             = ''
    MODULE.version          = { 2, 0, 0 }
    MODULE.libreq           = { 3, 0, 0 }
    MODULE.released		    = 1582778880

/*
*   content distribution
*/

    MODULE.fastdl 	        = false
    MODULE.precache         = false
    MODULE.ws_enabled 	    = false
    MODULE.ws_lst           = { }

/*
*   storage :: sh
*/

    MODULE.storage =
    {
        settings = { },
    }

/*
*   storage :: sv
*/

    MODULE.storage_sv = { }

/*
*   storage :: cl
*/

    MODULE.storage_cl = { }

/*
*   calls :: commands
*/

    MODULE.calls.commands =
    {
        [ 'rcore_modules' ] =
        {
            enabled     = true,
            id          = 'rcore.modules',
            desc        = 'returns a list of installed and running modules',
            scope       = 1,
            ex =
            {
                'rcore.modules',
                'rcore.modules -p',
            },
            flags =
            {
                [ 'paths' ]     = { flag = '-p', desc = 'display module install paths' },
            },
            assoc = function( ply, cmd, args, str )
                rcore.cc_modules( ply, cmd, args, str )
            end,
        },
        [ 'rcore_reload' ] =
        {
            enabled     = true,
            id          = 'rcore.reload',
            desc        = 'reloads the core module completely',
            scope       = 1,
            assoc = function( ply, cmd, args, str )
                rcore.cc_reload( ply, cmd, args, str )
            end,
        },
        [ 'rcore_errlog' ] =
        {
            enabled     = true,
            id          = 'rcore.errlog',
            desc        = 'displays any registered errors with the specified module',
            scope       = 1,
            assoc = function( ply, cmd, args, str )
                rcore.cc_errlog( ply, cmd, args, str )
            end,
        },
    }

/*
*   calls :: hooks
*/

    MODULE.calls.hooks = { }

/*
*   calls :: net
*/

    MODULE.calls.net = { }

/*
*   calls :: timers
*/

    MODULE.calls.timers = { }

/*
*   resources :: particles
*/

    MODULE.resources.ptc = { }

/*
*   resources :: sounds
*/

    MODULE.resources.snd = { }

/*
*   resources :: models
*/

    MODULE.resources.mdl = { }

/*
*   resources :: panels
*/

    MODULE.resources.pnl = { }

/*
*   permissions
*/

    MODULE.permissions =
    {
        [ 'rcore_user_gag_timed' ] =
        {
            id              = 'rcore_user_gag_timed',
            category        = 'RLib » User',
            desc            = 'Gags a player for a certain duration and then auto un-gags them',
            access          = 'superadmin',
            pubcmds         = { '!timedgag', '!tgag' },
            is_interactive  = true,
        },
        [ 'rcore_user_mute_timed' ] =
        {
            id              = 'rcore_user_mute_timed',
            category        = 'RLib » User',
            desc            = 'Mutes a player for a certain duration and then auto un-mutes them',
            access          = 'superadmin',
            pubcmds         = { '!timedmute', '!tmute' },
            is_interactive  = true,
        },
        [ 'rcore_tools_mdlviewer' ] =
        {
            id              = 'rcore_tools_mdlviewer',
            category        = 'RLib » Tools',
            desc            = 'Model viewer',
            access          = 'superadmin',
            pubcmds         = { '!mdlview', '!mdlviewer', '!mviewer' },
            is_interactive  = true,
        },
        [ 'rcore_tools_pco' ] =
        {
            id              = 'rcore_tools_pco',
            category        = 'RLib » Tools',
            desc            = 'Player-client-optimization service',
            access          = 'superadmin',
            pubcmds         = { '!pcotool' },
            is_interactive  = true,
        },
        [ 'rcore_rp_setjob' ] =
        {
            id              = 'rcore_rp_setjob',
            category        = 'RLib » RP',
            desc            = 'Set rp job based on command',
            access          = 'superadmin',
            pubcmds         = { '!setjob' },
            is_interactive  = true,
        },
    }

/*
*   doclick
*/

    MODULE.doclick = function( ) end

/*
*   dependencies
*/

    MODULE.dependencies =
    {

    }