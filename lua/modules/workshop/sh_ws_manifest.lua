/*
*   @package        : rcore
*   @module         : workshop
*   @author         : Richard [http://steamcommunity.com/profiles/76561198135875727]
*   @copyright      : (c) 2018 - 2020
*   @since          : 3.0.0
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

    MODULE.enabled		    = true
    MODULE.demo             = false
    MODULE.name			    = 'Workshop'
    MODULE.id			    = 'workshop'
    MODULE.author		    = 'Richard'
    MODULE.desc			    = 'workshop content downloader'
    MODULE.owner		    = false
    MODULE.version          = { 2, 0, 0 }
    MODULE.libreq           = { 3, 0, 0 }
    MODULE.released		    = 1582778880

/*
*   fonts
*
*   adding fonts to this list will ensure they are included when the server boots up
*   utilizing resource.AddFile( )
*/

    MODULE.fonts =
    {
        'akbar.ttf',
        'gregorianflf.ttf',
        'kgchasingpavements.ttf',
        'marcellus_regular.ttf',
        'roboto_black.ttf',
        'roboto_blackitalic.ttf',
        'roboto_bold.ttf',
        'roboto_boldcondensed.ttf',
        'roboto_boldcondenseditalic.ttf',
        'roboto_bolditalic.ttf',
        'roboto_condensed.ttf',
        'roboto_condenseditalic.ttf',
        'roboto_italic.ttf',
        'roboto_light.ttf',
        'roboto_lightitalic.ttf',
        'roboto_medium.ttf',
        'roboto_mediumitalic.ttf',
        'roboto_regular.ttf',
        'roboto_thin.ttf',
        'roboto_thinitalic.ttf',
    }

/*
*   workshops
*
*   this section allows you to include workshop collections that
*   will be automatically mounted when the server boots up and
*   when players connect.
*/

    MODULE.fastdl 	            = true
    MODULE.precache             = false
    MODULE.ws_enabled 	        = true
    MODULE.ws_lst               = { }

/*
*   storage
*/

    MODULE.storage = { }

/*
*   ext files
*/

    MODULE.ext = { }

/*
*   translations
*/

    MODULE.language = { }

/*
*   materials
*/

    MODULE.materials = { }

/*
*   datafolder
*/

    MODULE.datafolder = { }

/*
*   permissions
*/

    MODULE.permissions = { }

/*
*   entities
*/

    MODULE.ents = { }

/*
*   module :: calls :: net
*/

    MODULE.calls.net = { }

/*
*   module :: calls :: hooks
*/

    MODULE.calls.hooks = { }

/*
*   module :: calls :: commands
*/

    MODULE.calls.commands = { }

/*
*   module :: calls :: timers
*/

    MODULE.calls.timers = { }

/*
*   resources :: particles
*/

    MODULE.resources.ptc  = { }

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
*   doclick
*/

    MODULE.doclick = function( ) end

/*
*   dependencies
*/

    MODULE.dependencies =
    {

    }