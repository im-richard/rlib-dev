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

/*
*   permissions
*/

base.permissions =
{
    [ 'rlib_root' ] =
    {
        id              = 'rlib_root',
        category        = 'rlib',
        desc            = 'Allows for complete access to rlib',
        access          = 'superadmin'
    },
    [ 'rlib_alogs' ] =
    {
        id              = 'rlib_alogs',
        category        = 'rlib',
        desc            = 'Group can view special chat-based announcement logs as they occur',
        access          = 'superadmin'
    },
    [ 'rlib_asay' ] =
    {
        id              = 'rlib_asay',
        category        = 'rlib',
        desc            = 'In-game special group only chat abilities. Similar to ulx asay',
        access          = 'superadmin'
    },
    [ 'rlib_debug' ] =
    {
        id              = 'rlib_debug',
        category        = 'rlib',
        desc            = 'Allows usage of debugger tools',
        access          = 'superadmin'
    },
    [ 'rlib_forcerehash' ] =
    {
        id              = 'rlib_forcerehash',
        category        = 'rlib',
        desc            = 'Forces a complete rehash of the entire server file-structure',
        access          = 'superadmin'
    },
}