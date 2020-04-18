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
local mf                    = base.manifest
local prefix                = mf.prefix
local cfg                   = base.settings
local helper                = base.h
local design                = base.d
local ui                    = base.i
local konsole			    = base.k

/*
*   fonts
*/

surface.CreateFont( prefix .. 'ui.slider.hovertip', { font = 'Roboto', size = 12, weight = 700, antialias = true } )

/*
*   PANEL
*/

local PANEL = { }

/*
*   AccessorFunc
*/

AccessorFunc( PANEL, 'm_iMin',          'Min'           )
AccessorFunc( PANEL, 'm_iMax',          'Max'           )
AccessorFunc( PANEL, 'm_iRange',        'Range'         )
AccessorFunc( PANEL, 'm_iValue',        'Value'         )
AccessorFunc( PANEL, 'm_iDecimals',     'Decimals'      )
AccessorFunc( PANEL, 'm_fFloatValue',   'FloatValue'    )

/*
*   initialize
*/

function PANEL:Init( )
    self:SetMin( 2 )
    self:SetMax( 10 )
    self:SetDecimals( 0 )

    local minVal            = self:GetMin( )
    self.Dragging           = true
    self.Knob.Depressed     = true
    self.KnobColor          = Color( 255, 255, 255, 255 )

    self:SetValue( minVal )
    self:SetSlideX( self:GetFraction( ) )

    self.Dragging = false
    self.Knob.Depressed = false
    self.Knob:SetSize( 10, 14 )

    function self.Knob:Paint( w, h )
        draw.RoundedBox( 4, 1, 2, w - 2, h - 5, self:GetParent( ):GetKnobColor( ) )
    end
end

/*
*   SetMinMax
*
*   @param int min
*   @param int max
*/

function PANEL:SetMinMax( min, max )
    self:SetMin( min )
    self:SetMax( max )
end

/*
*   SetValue
*/

function PANEL:SetValue( value )
    value = math.Round( math.Clamp( tonumber( value ) or 0, self:GetMin( ), self:GetMax( ) ), self.m_iDecimals )

    self.m_iValue = value

    self:SetFloatValue( value )
    self:OnValueChanged( value )
    self:SetSlideX( self:GetFraction( ) )
end

/*
*   GetFraction
*/

function PANEL:GetFraction( )
    return ( self:GetFloatValue( ) -self:GetMin( ) ) / self:GetRange( )
end

/*
*   GetRange
*/

function PANEL:GetRange( )
    return self:GetMax( ) - self:GetMin( )
end

/*
*   TranslateValues
*
*   @param int x
*   @param int y
*/

function PANEL:TranslateValues( x, y )
    self:SetValue( self:GetMin( ) + ( x * self:GetRange( ) ) )
    return self:GetFraction( ), y
end

/*
*   OnValueChanged
*/

function PANEL:OnValueChanged( value ) end

/*
*   GetKnobColor
*/

function PANEL:GetKnobColor( )
    return self.KnobColor or Color( 255, 255, 255, 255 )
end

/*
*   SetKnobColor
*
*   @param clr clr
*/

function PANEL:SetKnobColor( clr )
    self.KnobColor = IsColor( clr ) and clr or Color( 255, 255, 255, 255 )
end

/*
*   GetBarColor
*/

function PANEL:GetBarColor( )
    return self.BarColor or Color( 255, 255, 255, 100 )
end

/*
*   SetBarColor
*
*   @param clr clr
*/

function PANEL:SetBarColor( clr )
    local color = IsColor( clr ) and clr or Color( 255, 255, 255, 100 )
    self.BarColor = color
end

/*
*   Paint
*
*   @param int w
*   @param int h
*/

function PANEL:Paint( w, h )
    local barcolor = self:GetBarColor( )
    design.obox( 0, 8, w, 2, Color( 0, 0, 0, 0 ), barcolor )
end

/*
*   PaintOver
*
*   @param int w
*   @param int h
*/

function PANEL:PaintOver( w, h )
    if ( self.Hovered or self.Knob.Hovered or self.Knob.Depressed ) and self:GetValue( ) and isnumber( self:GetValue( ) ) then
        surface.DisableClipping( true )
        draw.SimpleText( self:GetValue( ), prefix .. 'ui.slider.hovertip', self.Knob.x + self.Knob:GetWide( ) / 2, self.Knob.y - 10, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
        surface.DisableClipping( false )
    end
end

derma.DefineControl( 'rlib.ui.slider', 'rlib slider', PANEL, 'DSlider' )