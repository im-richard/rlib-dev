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
    MODULE.parent		    = addonGlobalTable or { }
    MODULE.demo             = false
    MODULE.name             = 'Base'
    MODULE.id               = 'base'
    MODULE.desc             = 'base module'
    MODULE.author           = 'Richard'
    MODULE.icon             = ''
    MODULE.script_id	    = '{{ script_id }}'
    MODULE.owner		    = '{{ user_id }}'
    MODULE.version          = { 1, 0, 0 }
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
*   fonts :: push
*/

    MODULE.fonts_push       = false

/*
*   fonts :: list
*/

    MODULE.fonts =
    {
        'fontname.ttf'
    }

/*
*   external config files
*/

    MODULE.ext =
    {
        [ 'database' ]      = 'database.rlib',
    }

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
*   entities
*/

    MODULE.ents =
    {
        [ 1 ] =
        {
            ent                 = 'ent_name',
            model               = 'path/to/model.mdl',
            material            = 'path/to/material',
            ptc =
            {
                'particles/path/file_01.pcf',
                'particles/path/file_02.pcf',
            },
            ptc_pc =
            {
                'particle_name_id_01',
                'particle_name_id_02'
            },
            name                = 'Entity Name',
            desc                = 'Short description of ent',
            author              = 'Richard',
            category            = 'DarkRP',
            spawnable           = true,
            adminspawn          = true,
        },
    }

/*
*   calls :: commands
*/

    MODULE.calls.commands =
    {
        [ 'module_cmd' ] =
        {
            enabled     = true,
            id          = 'module.cmd',
            desc        = 'demo command example',
            scope       = 1,
            assoc = function( ply, cmd, args, str )
                module.cc_demo( ply, cmd, args, str )
            end,
        },
    }

/*
*   datafolder
*/

    MODULE.datafolder =
    {
        [ 1 ] =
        {
            parent      = 'rlib/modules',
            sub         = 'example',
            file        = game.GetMap( )
        },
    }

/*
*   permissions
*/

    MODULE.permissions =
    {
        [ 'demo_perm_ex' ] =
        {
            id              = 'demo_perm_ex',
            category        = 'Demo » Perm',
            desc            = 'Permission example',
            access          = 'superadmin',
            pubcmds         = { '!chatcmd', '!chatcmd2' },
            is_ext          = true,
        },
    }

/*
*   mats
*/

    MODULE.mats =
    {
        [ 'mat_example' ]                   = { 'path/to/image.png' },
    }

/*
*   calls :: hooks
*/

    MODULE.calls.hooks =
    {
        [ 'hook_name_demo' ]                = { 'hook.name.demo' },
    }

/*
*   calls :: net
*/

    MODULE.calls.net =
    {
        [ 'net_name_demo' ]                 = { 'net.name.demo' },
    }

/*
*   calls :: timers
*/

    MODULE.calls.timers =
    {
        [ 'timer_name_demo' ]               = { 'timer.name.demo' },
    }

/*
*   resources :: particles
*/

    MODULE.resources.ptc =
    {
        [ 'particle_file_demo_call' ]       = { 'particles/path/to/particle.pcf' },
        [ 'particle_demo_call' ]            = { 'particle_name' },
    }

/*
*   resources :: sounds
*/

    MODULE.resources.snd =
    {
        [ 'snd_call_id' ]                   = { 'path/to/sound/file.mp3' },
    }

/*
*   resources :: models
*/

    MODULE.resources.mdl =
    {
        [ 'mdl_call_id' ]                   = { 'path/to/mdl/file.mdl' },
    }

/*
*   resources :: panels
*/

    MODULE.resources.pnl =
    {
        [ 'pnl_call_id' ]                   = { 'module.pnl.call.id' },
    }

/*
*   language
*/

    MODULE.language =
    {

        /*
        *   emglish
        */

        [ 'en' ] =
        {
            translated_string_id            = 'Example string in English',
        },
    }

/*
*   doclick
*/

    MODULE.doclick = function( ) end

/*
*   dependencies
*/

    MODULE.dependencies = { HpwRewrite, PS2 }