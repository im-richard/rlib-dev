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
local cfg                   = base.settings
local helper                = base.h
local design                = base.d
local ui                    = base.i

/*
*   PANEL
*/

local PANEL = { }

/*
*   Init
*/

function PANEL:Init( )
    self:SetSize    ( 40, 15 )
    self:SetCursor  ( 'hand' )
    self.enabled    = false
end

/*
*   Paint
*/

function PANEL:Paint( w, h )
    draw.RoundedBox( 8, 0, 0, w, h, Color( 255, 255, 255, 5 ) )

    if self.enabled then
        design.circle( w - 10, 10, 7, 25, Color( 103, 136, 214 ) )
    else
        design.circle( 10, 10, 7, 25, Color( 214, 103, 144 ) )
    end
end

/*
*   OnMousePressed
*/

function PANEL:OnMousePressed( )
    surface.PlaySound( 'ui/buttonclick.wav' )

    self.enabled = not self.enabled
    self:onOptionChanged( )
end

/*
*   onOptionChanged
*/

function PANEL:onOptionChanged( ) end

/*
*   DefineControl
*/

derma.DefineControl( 'rlib.ui.toggle', 'rlib toggle', PANEL, 'EditablePanel' )