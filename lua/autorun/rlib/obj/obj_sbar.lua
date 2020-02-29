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
local konsole			    = base.k

/*
*   PANEL
*/

local PANEL = { }

/*
*   AccessorFunc
*/

AccessorFunc( PANEL, 'm_HideButtons', 'HideButtons' )

/*
*    init
*/

function PANEL:Init( )

    self.Offset         = 0
    self.Scroll         = 0
    self.CanvasSize     = 1
    self.BarSize        = 1

    self.btnUp = vgui.Create( 'DButton', self )
    self.btnUp:SetText( '' )
    self.btnUp.DoClick = function( s ) s:GetParent():AddScroll( -1 ) end

    self.btnDown = vgui.Create( 'DButton', self )
    self.btnDown:SetText( '' )
    self.btnDown.DoClick = function( s ) s:GetParent():AddScroll( 1 ) end

    self.btnGrip = vgui.Create( 'DScrollBarGrip', self )

    self:SetSize( 15, 15 )
    self:SetHideButtons( false )

    self.Paint = function( s, w, h )
        draw.RoundedBox( 4, 12, 10, 4, h - 20, Color( 24, 24, 24, self.Alpha ) )
    end
    self.btnUp.Paint = function( s, w, h ) end
    self.btnDown.Paint = function( s, w, h ) end
    self.btnGrip.Paint = function( s, w, h )
        local knobcolor = self.KnobColor or Color( 76, 158, 73 )
        draw.RoundedBox( 4, 0, 0, 20, h, Color( knobcolor.r, knobcolor.g, knobcolor.b, self.Alpha ) )
    end

end

/*
*   set enabled
*
*   @param  : bool b
*/

function PANEL:SetEnabled( b )
    if not b then
        self.Offset = 0
        self:SetScroll( 0 )
        self.HasChanged = true
    end

    self:SetMouseInputEnabled( b )
    self:SetVisible( b )
    if self.Enabled ~= b then
        self:GetParent( ):InvalidateLayout( )

        if self:GetParent( ).OnScrollbarAppear then
            self:GetParent( ):OnScrollbarAppear( )
        end
    end

    self.Enabled = b
end

/*
*   value
*/

function PANEL:Value( )
    return self.Pos
end

/*
*   bar scale
*/

function PANEL:BarScale( )
    if self.BarSize == 0 then return 1 end
    return self.BarSize / ( self.CanvasSize + self.BarSize )
end

/*
*   set up
*   
*   @param  : int sz_bar
*   @param  : int sz_canvas
*/

function PANEL:SetUp( sz_bar, sz_canvas )
    self.BarSize = sz_bar
    self.CanvasSize = math.max( sz_canvas - sz_bar, 1 )

    self:SetEnabled( sz_canvas > sz_bar )
    self:InvalidateLayout( )
end

/*
*   on mouse wheeled
*
*   @param  : int dlta
*/

function PANEL:OnMouseWheeled( dlta )
    if not self:IsVisible( ) then return false end

    return self:AddScroll( dlta * -2 )
end

/*
*   add scroll
*
*   @param  : int dlta
*/

function PANEL:AddScroll( dlta )
    local OldScroll = self:GetScroll( )

    dlta = dlta * 25
    self:SetScroll( self:GetScroll( ) + dlta )

    return OldScroll ~= self:GetScroll( )
end

/*
*   set scroll
*
*   @param  : int scrll
*/

function PANEL:SetScroll( scrll )
    if not self.Enabled then self.Scroll = 0 return end

    self.Scroll = math.Clamp( scrll, 0, self.CanvasSize )
    self:InvalidateLayout( )

    local func = self:GetParent( ).OnVScroll
    if func then
        func( self:GetParent( ), self:GetOffset( ) )
    else
        self:GetParent( ):InvalidateLayout( )
    end
end

/*
*   animate to
*
*   @param  : int scrll
*   @param  : int length
*   @param  : int delay
*   @param  : int ease
*/

function PANEL:AnimateTo( scrll, length, delay, ease )
    local anim = self:NewAnimation( length, delay, ease )
    anim.StartPos = self.Scroll
    anim.TargetPos = scrll
    anim.Think = function( anim, pnl, fraction )
        pnl:SetScroll( Lerp( fraction, anim.StartPos, anim.TargetPos ) )
    end
end

/*
*   get scroll
*/

function PANEL:GetScroll( )
    if not self.Enabled then self.Scroll = 0 end
    return self.Scroll
end

/*
*   get offset
*/

function PANEL:GetOffset( )
    if not self.Enabled then return 0 end
    return self.Scroll * -1
end

/*
*   think
*/

function PANEL:Think( )
    if IsValid( konsole.pnl ) then
        self.Alpha = konsole.pnl.is_visible and 255 or 0
    end
    if self.AlphaOR then
        self.Alpha = 255
    end
end

/*
*   paint
*
*   @param  : int w
*   @param  : int h
*/

function PANEL:Paint( w, h )
    derma.SkinHook( 'Paint', 'VScrollBar', self, w, h )
    return true
end

/*
*   mouse pressed
*/

function PANEL:OnMousePressed( )
    local _, y = self:CursorPos( )
    local sz_page = self.BarSize

    if y > self.btnGrip.y then
        self:SetScroll( self:GetScroll( ) + sz_page )
    else
        self:SetScroll( self:GetScroll( ) - sz_page )
    end
end

/*
*   mouse released
*/

function PANEL:OnMouseReleased( )
    self.Dragging = false
    self.DraggingCanvas = nil
    self:MouseCapture( false )
    self.btnGrip.Depressed = false
end

/*
*   cursor moved
*
*   @param  : int x
*   @param  : int y
*/

function PANEL:OnCursorMoved( x, y )
    if not self.Enabled then return end
    if not self.Dragging then return end

    local x, y = self:ScreenToLocal( 0, gui.MouseY( ) )

    y = y - self.btnUp:GetTall( )
    y = y - self.HoldPos

    local sz_btn_h = self:GetWide( )
    if self:GetHideButtons( ) then sz_btn_h = 0 end

    local track_size = self:GetTall( ) - sz_btn_h * 2 - self.btnGrip:GetTall( )

    y = y / track_size

    self:SetScroll( y * self.CanvasSize )
end

/*
*   grip
*/

function PANEL:Grip( )
    if not self.Enabled then return end
    if self.BarSize == 0 then return end

    self:MouseCapture( true )
    self.Dragging = true

    local _, y = self.btnGrip:ScreenToLocal( 0, gui.MouseY( ) )
    self.HoldPos = y

    self.btnGrip.Depressed = true
end

/*
*   perform layout
*/

function PANEL:PerformLayout( )

    local sz_wide = self:GetWide( )
    local sz_btn_h = sz_wide

    if self:GetHideButtons( ) then sz_btn_h = 0 end

    local Scroll    = self:GetScroll( ) / self.CanvasSize
    local BarSize   = 20
    local track     = self:GetTall( ) - ( sz_btn_h * 2 ) - BarSize
    track           = track + 1
    Scroll          = Scroll * track

    self.btnGrip:SetPos( 4, sz_btn_h + Scroll )
    self.btnGrip:SetSize( sz_wide, BarSize )

    if ( sz_btn_h > 0 ) then
        self.btnUp:SetPos( 4, 0, sz_wide, sz_wide )
        self.btnUp:SetSize( sz_wide, sz_btn_h )

        self.btnDown:SetPos( 4, self:GetTall( ) - sz_btn_h )
        self.btnDown:SetSize( sz_wide, sz_btn_h )

        self.btnUp:SetVisible( true )
        self.btnDown:SetVisible( true )
    else
        self.btnUp:SetVisible( false )
        self.btnDown:SetVisible( false )
        self.btnDown:SetSize( sz_wide, sz_btn_h )
        self.btnUp:SetSize( sz_wide, sz_btn_h )
    end

end

derma.DefineControl( 'rlib.ui.scrollbar', 'rlib scrollbar', PANEL, 'Panel' )