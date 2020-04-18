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
*   Init
*/

function PANEL:Init( )

    self:SetSize        ( 200, 25 )

    self.bIsPopulated   = false

    self.svgimg         = ui.new( 'dhtml', self     )
    :static             ( FILL                      )
    :sbar               ( false                     )
    :svg                ( self:GetImg( ), true      )

    ui:register         ( 'pnl.svg', 'rlib',   self.svgimg, 'svg src' )

end

/*
*   GetImg
*/

function PANEL:GetImg( )
    return self.img or ''
end

/*
*   SetImg
*
*   @param  : str uri
*/

function PANEL:SetImg( uri )
    self.img = uri or ''
end

/*
*   Think
*/

function PANEL:Think( )

    /*
    *   bIsPopulated
    */

    if not self.bIsPopulated and self.svgimg then
        local svgimg        = ui.get( self.svgimg           )
        :svg                ( self:GetImg( ), true          )

        self.bIsPopulated   = true
    end
end

/*
*   Paint
*
*   @param  : int w
*   @param  : int h
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

vgui.Register( 'rlib.lo.svg.c', PANEL, 'DPanel' )