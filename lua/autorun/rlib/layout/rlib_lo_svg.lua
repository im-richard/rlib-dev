/*
*   @package        : rlib
*   @author         : Richard [http://steamcommunity.com/profiles/76561198135875727]
*   @copyright      : (C) 2019 - 2020
*   @since          : 2.0.0
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
local mf                    = base.manifest
local cfg                   = base.settings
local helper                = base.h
local design                = base.d
local ui                    = base.i

/*
*   Localized translation func
*/

local function lang( ... )
    return base:lang( ... )
end

/*
*	prefix ids
*/

local function pref( str, suffix )
    local state = ( isstring( suffix ) and suffix ) or ( base and base.manifest.prefix ) or false
    return rlib.get:pref( str, state )
end

/*
*   declare panel
*/

local PANEL = { }

/*
*   Initialize
*/

function PANEL:Init( )
    if not mf.astra.svg.stats then return end

    self:SetSize( 1, 1 )

    self.svg            = ui.new( 'dhtml', self     )
    :static             ( FILL                      )
    :sbar               ( false                     )
    :svg                ( mf.astra.svg.stats        )

end

/*
*   Paint
*/

function PANEL:Paint( w, h ) end

/*
*   Destroy
*/

function PANEL:Destroy( )
    ui:destroy( self )
end

/*
*   register
*/

vgui.Register( 'rlib.lo.svg', PANEL, 'DPanel' )