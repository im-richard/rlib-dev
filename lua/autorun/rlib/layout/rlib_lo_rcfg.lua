/*
*   @package        : rlib
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
*   standard tables and localization
*/

rlib                        = rlib or { }
local base                  = rlib
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
*   panel
*/

local PANEL = { }

/*
*   accessorfunc
*/

AccessorFunc( PANEL, 'm_bDraggable', 'Draggable', FORCE_BOOL )

/*
*   initialize
*/

function PANEL:Init( )

    /*
    *   sizing
    */

    local sc_w, sc_h        = ui:scalesimple( 0.90, 0.90, 0.90 ), ui:scalesimple( 0.90, 0.90, 0.90 )
    local pnl_w, pnl_h      = cfg.rcfg.ui.width, cfg.rcfg.ui.height
    local ui_w, ui_h        = sc_w * pnl_w, sc_h * pnl_h

    /*
    *   localized colorization
    */

    local clr_cursor        = Color( 200, 200, 200, 255 )
    local clr_text          = Color( 255, 255, 255, 255 )
    local clr_hl            = Color( 25, 25, 25, 255 )
    local clr_box_status    = Color( 150, 50, 50, 255 )
    local state, r, g, b    = 0, 255, 0, 0

    /*
    *   parent pnl
    */

    self:SetPaintShadow     ( true          )
    self:SetSize            ( ui_w, ui_h    )
    self:SetMinWidth        ( ui_w          )
    self:SetMinHeight       ( ui_h          )
    self:MakePopup          (               )
    self:SetTitle           ( ''            )
    self:SetSizable         ( true          )
    self:ShowCloseButton    ( false         )
    self:DockPadding        ( 0, 34, 0, 0   )

    self.hdr_title          = 'rcfg'
    self.conn_status        = lang( 'lib_oort_abt_status_pending' )
    self.conn_clr           = Color( 200, 100, 100, 255 )

    /*
    *   display parent :: static || animated
    */

    if helper:cvar_bool( 'rlib_animations_enabled' ) then
        self:SetPos( ( ScrW( ) / 2 ) - ( ui_w / 2 ), ScrH( ) + ui_h )
        self:MoveTo( ( ScrW( ) / 2 ) - ( ui_w / 2 ), ( ScrH( ) / 2 ) - (  ui_h / 2 ), 0.4, 0, -1 )
    else
        self:SetPos( ( ScrW( ) / 2 ) - ( ui_w / 2 ), ( ScrH( ) / 2 ) - (  ui_h / 2 ) )
    end

    /*
    *   titlebar
    */

    self.lblTitle = vgui.Create( 'DLabel', self )
    self.lblTitle:SetText( '' )
    self.lblTitle:SetFont( pref( 'rcfg.title' ) )
    self.lblTitle:SetColor( Color( 255, 255, 255, 255 ) )
    self.lblTitle.Paint = function( s, w, h )
        if not self.title or self.title == '' then self.title = 'rcfg' end
        draw.SimpleText( utf8.char( 9930 ), pref( 'rcfg.icon' ), 0, 8, Color( 240, 72, 133, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
        draw.SimpleText( self.title, pref( 'rcfg.title' ), 25, h / 2, Color( 237, 237, 237, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
    end

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
        draw.SimpleText( helper.get:utf8( 'close' ), pref( 'rcfg.exit' ), w / 2 - 7, h / 2 + 4, clr_txt, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
    end

    /*
    *   subparent left
    */

    self.p_sub_header = vgui.Create( 'DPanel', self )
    self.p_sub_header:Dock( TOP )
    self.p_sub_header:DockMargin( 0, 0, 0, 0 )
    self.p_sub_header:SetTall( 70 )
    self.p_sub_header.Paint = function( s, w, h )
        design.rbox( 0, 5, 0, w - 10, h, Color( 34, 34, 34, 255 ) )
        design.box( 5, h - 1, w - 10, 2, Color( 35, 35, 35, 255 ) )

        if ( state == 0 ) then
            g = g + 1
            if ( g == 255 ) then state = 1 end
        elseif ( state == 1 ) then
            r = r - 1
            if ( r == 0 ) then state = 2 end
        elseif ( state == 2 ) then
            b = b + 1
            if ( b == 255 ) then state = 3 end
        elseif ( state == 3 ) then
            g = g - 1
            if ( g == 0 ) then state = 4 end
        elseif ( state == 4 ) then
            r = r + 1
            if ( r == 255 ) then state = 5 end
        elseif ( state == 5 ) then
            b = b - 1
            if ( b == 0 ) then state = 0 end
        end

        local clr_rgb = Color( r, g, b )

        draw.SimpleText( self.hdr_title, pref( 'rcfg.name' ), w / 2, h / 2, clr_rgb, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
    end

    /*
    *   status indicator
    */

    self.p_status = vgui.Create( 'DPanel', self )
    self.p_status:Dock( TOP )
    self.p_status:DockMargin( 0, 0, 0, 0 )
    self.p_status:SetTall( 20 )
    self.p_status.Paint = function( s, w, h )
        design.rbox( 0, 2, 1, w - 4, h, Color( 15, 15, 15, 230 ) )
        design.blur( s, 0.5 )
        design.rbox( 0, 0, 2, w, h, Color( clr_box_status.r, clr_box_status.g, clr_box_status.b, 255 ) )
    end

    self.l_status = vgui.Create( 'DLabel', self.p_status )
    self.l_status:Dock( FILL )
    self.l_status:DockMargin( 3, 5, 3, 1 )
    self.l_status:SetFont( pref( 'rcfg.status' ) )
    self.l_status:SetText( 'Coming Soon' )
    self.l_status:SetColor( Color( 255, 255, 255, 255 ) )
    self.l_status:SetContentAlignment( 5 )
    self.l_status.Think = function( s )
        s:SetColor( Color( 255, 255, 255, 255 ) )
    end

    /*
    *   subparent pnl
    */

    self.p_subparent = vgui.Create( 'DPanel', self )
    self.p_subparent:Dock( FILL )
    self.p_subparent:DockMargin( 10, 10, 10, 10 )
    self.p_subparent.Paint = function( s, w, h ) end

end

/*
*   Think
*/

function PANEL:Think( )
    self.BaseClass.Think( self )

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
    self.Dragging   = nil
    self.Sizing     = nil
    self:MouseCapture( false )
end

/*
*   PerformLayout
*/

function PANEL:PerformLayout( )
    local titlePush = 0
    self.BaseClass.PerformLayout( self )

    self.lblTitle:SetPos( 17 + titlePush, 7 )
    self.lblTitle:SetSize( self:GetWide( ) - 25 - titlePush, 20 )
end

/*
*   Paint
*
*   @param  : int w
*   @param  : int h
*/

function PANEL:Paint( w, h )
    design.rbox( 4, 5, 0, w - 10, h - 8, Color( 40, 40, 40, 255 ) )
    design.rbox_adv( 0, 5, 0, w - 10, 34, Color( 30, 30, 30, 255 ), true, true, false, false )

    -- resizing arrow
    draw.SimpleText( utf8.char( 9698 ), pref( 'rcfg.resizer' ), w - 3, h - 10, Color( 240, 72, 133, 255 ), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER )
end

/*
*   ActionHide
*/

function PANEL:ActionHide( )
    self:SetMouseInputEnabled( false )
    self:SetKeyboardInputEnabled( false )
end

/*
*   ActionShow
*/

function PANEL:ActionShow( )
    self:SetMouseInputEnabled( true )
    self:SetKeyboardInputEnabled( true )
end

/*
*   GetTitle
*
*   @return : str
*/

function PANEL:GetTitle( )
    return self.title
end

/*
*   SetTitle
*
*   @param  : str title
*/

function PANEL:SetTitle( title )
    self.lblTitle:SetText( '' )
    self.title = title
end

/*
*   Destroy
*/

function PANEL:Destroy( )
    timex.expire( pref( 'timer.update.check' ) )
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

/*
*   register
*/

vgui.Register( 'rlib.lo.rcfg', PANEL, 'DFrame' )