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
local mf                    = base.manifest
local prefix                = mf.prefix
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
*    fonts
*/

surface.CreateFont( prefix .. 'overlay.exit',           { size = 24, weight = 800, antialias = true, font = 'Roboto' } )
surface.CreateFont( prefix .. 'overlay.title',          { size = 16, weight = 600, antialias = true, font = 'Roboto Light' } )

/*
*   PANEL
*/

local PANEL = { }

/*
*   AccessorFunc
*/

AccessorFunc( PANEL, 'm_bDraggable', 'Draggable', FORCE_BOOL )

/*
*   initialize
*/

function PANEL:Init( )

    /*
    *   sizing
    */

    local pnl_w, pnl_h      = ScrW( ), ScrH( )
    local ui_w, ui_h        = pnl_w, pnl_h

    /*
    *   parent pnl
    */

    self:SetSize            ( ui_w, ui_h        )
    self:DockPadding        ( 2, 34, 2, 3       )
    self:MakePopup          (                   )
    self:SetTitle           ( ''                )
    self:SetSizable         ( false             )
    self:ShowCloseButton    ( false             )
    self:SetScreenLock      ( true              )
    self:SetPaintShadow     ( true              )

    /*
    *   misc vars
    */

    self.title = ''

    /*
    *   display parent :: static || animated
    */

    self:SetPos( ( ScrW( ) / 2 ) - ( ui_w / 2 ), ( ScrH( ) / 2 ) - (  ui_h / 2 ) )

    /*
    *   titlebar
    */

    self.lblTitle = vgui.Create( 'DLabel', self )
    self.lblTitle:SetText( '' )
    self.lblTitle:SetFont( prefix .. 'overlay.title' )
    self.lblTitle:SetColor( Color( 255, 255, 255, 255 ) )
    self.lblTitle.Paint = function( s, w, h ) end

    /*
    *   close button
    *
    *   to overwrite existing properties from the skin; do not change this buttons name to anything other
    *   than btnClose otherwise it wont inherit position/size properties
    */

    self.btnClose = vgui.Create( 'DButton', self )
    self.btnClose:SetText( '' )
    self.btnClose:SetTooltip( lang( 'tooltip_close' ) )
    self.btnClose.OnCursorEntered = function( s ) s.hover = true end
    self.btnClose.OnCursorExited = function( s ) s.hover = false end
    self.btnClose.DoClick = function( s )
        self:Destroy( )
    end
    self.btnClose.Paint = function( s, w, h )
        local clr_txt = s.hover and Color( 200, 55, 55, 255 ) or Color( 237, 237, 237, 255 )
        draw.SimpleText( '', prefix .. 'overlay.exit', w / 2, h / 2 + 4, clr_txt, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
    end

end

/*
*   GetTitle
*/

function PANEL:GetTitle( )
    return self.title or ''
end

/*
*   SetTitle
*/

function PANEL:SetTitle( strTitle )
    self.lblTitle:SetText( '' )
    self.title = strTitle or ''
end

/*
*   Think
*/

function PANEL:Think( )
    self.BaseClass.Think( self )

    if ( input.IsKeyDown( KEY_ESCAPE ) or gui.IsGameUIVisible( ) ) and not self.bNoDestroy then self:Destroy( ) end

    local mousex = math.Clamp( gui.MouseX( ), 1, ScrW( ) - 1 )
    local mousey = math.Clamp( gui.MouseY( ), 1, ScrH( ) - 1 )

    if self.Dragging then
        local x = mousex - self.Dragging[ 1 ]
        local y = mousey - self.Dragging[ 2 ]

        if self:GetScreenLock( ) then
            x = math.Clamp( x, 0, ScrW( ) - self:GetWide( ) )
            y = math.Clamp( y, 0, ScrH( ) - self:GetTall( ) )
        end

        self:SetPos( x, y )
    end

    if self.Sizing then
        local x = mousex - self.Sizing[ 1 ]
        local y = mousey - self.Sizing[ 2 ]
        local px, py = self:GetPos( )

        if ( x < self.m_iMinWidth ) then x = self.m_iMinWidth elseif ( x > ScrW( ) - px and self:GetScreenLock( ) ) then x = ScrW( ) - px end
        if ( y < self.m_iMinHeight ) then y = self.m_iMinHeight elseif ( y > ScrH( ) - py and self:GetScreenLock( ) ) then y = ScrH( ) - py end

        self:SetSize( x, y )
        self:SetCursor( 'sizenwse' )
        return
    end

    if ( self.Hovered and self.m_bSizable and mousex > ( self.x + self:GetWide( ) - 20 ) and mousey > ( self.y + self:GetTall( ) - 20 ) ) then
        self:SetCursor( 'sizenwse' )
        return
    end

    if ( self.Hovered and self:GetDraggable( ) and mousey < ( self.y + 24 ) ) then
        self:SetCursor( 'sizeall' )
        return
    end

    self:SetCursor( 'arrow' )

    if self.y < 0 then self:SetPos( self.x, 0 ) end

    if ui:valid( self ) then
        self:MoveToBack( )
    end

    if not IsValid( self:GetAttach( ) ) then
        self:Destroy( )
    end

end

/*
*   OnMousePressed
*/

function PANEL:OnMousePressed( )
    if ( self.m_bSizable and gui.MouseX( ) > ( self.x + self:GetWide( ) - 20 ) and gui.MouseY( ) > ( self.y + self:GetTall( ) - 20 ) ) then
        self.Sizing =
        {
            gui.MouseX( ) - self:GetWide( ),
            gui.MouseY( ) - self:GetTall( )
        }
        self:MouseCapture( true )
        return
    end

    if ( self:GetDraggable( ) and gui.MouseY( ) < ( self.y + 24 ) ) then
        self.Dragging =
        {
            gui.MouseX( ) - self.x,
            gui.MouseY( ) - self.y
        }
        self:MouseCapture( true )
        return
    end
end

/*
*   OnMouseReleased
*/

function PANEL:OnMouseReleased( )
    self.Dragging = nil
    self.Sizing = nil
    self:MouseCapture( false )
end

/*
*   PerformLayout
*/

function PANEL:PerformLayout( )
    local titlePush = 0
    self.BaseClass.PerformLayout( self )

    self.lblTitle:SetPos( 11 + titlePush, 7 )
    self.lblTitle:SetSize( self:GetWide( ) - 25 - titlePush, 20 )
end

/*
*   Paint
*
*   @param  : int w
*   @param  : int h
*/

function PANEL:Paint( w, h )
    design.blur( self, 10 )
    local clr_box = Color( 15, 15, 15, 200 )
    design.box( 0, 0, w, h, Color( clr_box.r, clr_box.g, clr_box.b, clr_box.a ) )
end

/*
*   GetNoDestroy
*
*   @return : bool
*/

function PANEL:GetNoDestroy( )
    return self.bNoDestroy or false
end

/*
*   NoDestroy
*
*   @param  : bool bool
*/

function PANEL:NoDestroy( bool )
    self.bNoDestroy = bool or false
end

/*
*   GetAttach
*/

function PANEL:GetAttach( )
    return self.pnl_attached
end

/*
*   Attach
*/

function PANEL:Attach( pnl )
    self.pnl_attached = pnl
end

/*
*   ActionShow
*/

function PANEL:ActionShow( )
    self:SetMouseInputEnabled( true )
    self:SetKeyboardInputEnabled( true )
end

/*
*   Destroy
*/

function PANEL:Destroy( )
    ui:destroy( self, true, true )
end

/*
*   SetState
*   
*   @param  : bool bVisible
*/

function PANEL:SetState( bVisible )
    if bVisible then
        ui:show( self, true )
    else
        ui:hide( self, true )
    end
end

derma.DefineControl( 'rlib.ui.overlay', 'rlib overlay', PANEL, 'DFrame' )