/*
*   @package        : rlib
*   @author         : Richard [http://steamcommunity.com/profiles/76561198135875727]
*   @copyright      : (C) 2018 - 2020
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
*   localization :: modules and pkgs
*/

rlib                        = rlib or { }
local base                  = rlib
local cfg                   = base.settings
local helper                = base.h
local design                = base.d
local ui                    = base.i
local cvar                  = base.v

/*
*   localization :: glua
*/

local Color             = Color

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

    local sc_w, sc_h            = ui:scalesimple( 0.85, 0.85, 0.85 ), ui:scalesimple( 0.85, 0.85, 0.85 )
    local pnl_w, pnl_h          = cfg.dc.ui.width, cfg.dc.ui.height
    local ui_w, ui_h            = sc_w * pnl_w, sc_h * pnl_h

    /*
    *   localized colorization
    */

    local clr_box_status        = Color( 150, 50, 50, 255 )
    local state, r, g, b        = 0, 255, 0, 0

    /*
    *   parent pnl
    */

    self:SetPaintShadow         ( true                          )
    self:SetSize                ( ui_w, ui_h                    )
    self:SetMinWidth            ( ui_w                          )
    self:SetMinHeight           ( ui_h                          )
    self:MakePopup              (                               )
    self:SetTitle               ( ''                            )
    self:SetSizable             ( true                          )
    self:ShowCloseButton        ( false                         )
    self:DockPadding            ( 0, 34, 0, 0                   )

    /*
    *   display parent :: static || anim
    */

    if cvar:GetBool( 'rlib_animations_enabled' ) then
        self:SetPos( ( ScrW( ) / 2 ) - ( ui_w / 2 ), ScrH( ) + ui_h )
        self:MoveTo( ( ScrW( ) / 2 ) - ( ui_w / 2 ), ( ScrH( ) / 2 ) - (  ui_h / 2 ), 0.4, 0, -1 )
    else
        self:SetPos( ( ScrW( ) / 2 ) - ( ui_w / 2 ), ( ScrH( ) / 2 ) - (  ui_h / 2 ) )
    end

    /*
    *   titlebar
    */

    self.lblTitle               = ui.new( 'lbl', self           )
    :notext                     (                               )
    :font                       ( pref( 'dc_title' )            )

                                :draw ( function( s, w, h )
                                    if not self.title or self.title == '' then self.title = 'about' end
                                    draw.SimpleText( utf8.char( 9930 ), pref( 'dc_icon' ), 5, 8, Color( 240, 72, 133, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
                                    draw.SimpleText( self.title, pref( 'dc_title' ), 30, h / 2, Color( 237, 237, 237, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
                                end )

    /*
    *   close button
    *
    *   to overwrite existing properties from the skin; do not change this buttons name to anything other 
    *   than btnClose otherwise it wont inherit position/size properties
    */

    self.btnClose               = ui.new( 'btn', self           )
    :bsetup                     (                               )
    :notext                     (                               )
    :tip                        ( lang( 'tooltip_close' )       )
    :onclick_r                  ( self                          )

                                :draw ( function( s, w, h )
                                    local clr_txt = s.hover and Color( 200, 55, 55, 255 ) or Color( 237, 237, 237, 255 )
                                    draw.SimpleText( helper.get:utf8( 'close' ), pref( 'dc_exit' ), w / 2 - 10, h / 2 + 4, clr_txt, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
                                end )

    /*
    *   subparent left
    */

    self.p_sub_header           = ui.new( 'pnl', self           )
    :static                     ( TOP                           )
    :margin                     ( 0                             )
    :notext                     (                               )
    :tall                       ( ui_h * 0.25                   )

                                :draw( function( s, w, h )
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

                                    draw.SimpleText( lang( 'dc_leave' ), pref( 'dc_name' ), w / 2, h / 2, clr_rgb, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
                                end )

    /*
    *   status :: container
    */

    self.p_status               = ui.new( 'pnl', self           )
    :static                     ( TOP                           )
    :margin                     ( 0                             )
    :notext                     (                               )
    :tall                       ( 26                            )

                                :draw( function( s, w, h )
                                    design.rbox( 0, 2, 1, w - 4, h, Color( 15, 15, 15, 230 ) )
                                    design.blur( s, 0.5 )
                                    design.rbox( 0, 0, 2, w, h, Color( clr_box_status.r, clr_box_status.g, clr_box_status.b, 255 ) )
                                end )

    /*
    *   status :: label
    */

    self.l_status               = ui.new( 'lbl', self.p_status  )
    :static                     ( FILL                          )
    :margin                     ( 3, 3, 3, 1                    )
    :textadv                    ( Color( 255, 255, 255, 255 ), pref( 'dc_msg' ), lang( 'dc_msg' ), true )
    :align                      ( 5                             )

    /*
    *   desc container
    */

    self.p_desc                 = ui.new( 'pnl', self           )
    :nodraw                     (                               )
    :static                     ( FILL                          )
    :margin                     ( 10                            )

    /*
    *   sub
    */

    self.p_sub                  = ui.new( 'pnl', self.p_desc    )
    :nodraw                     (                               )
    :static                     ( FILL                          )
    :margin                     ( 20, 10, 20, 10                )

    /*
    *   btn :: declare size
    */

    local btn_w                 = ui_w / 2 - 45

    /*
    *   btn :: option :: stay
    */

    self.stay                   = ui.new( 'btn', self.p_sub     )
    :bsetup                     (                               )
    :static                     ( LEFT                          )
    :notext                     (                               )
    :wide                       ( btn_w                         )
    :margin                     ( 5, 10, 5, 10                  )
    :tip                        ( lang( 'tooltip_close' )       )
    :anim_click_ol              ( Color( 255, 255, 255, 25 )    )
    :ocr                        ( self                          )

                                :draw ( function( s, w, h )
                                    design.rbox( 4, 0, 0, w, h, Color( 124, 62, 59, 255 ) )
                                    design.rbox( 4, 2, 2, w - 4, h - 4, Color( 84, 45, 43, 255 ) )

                                    if s.hover then
                                        design.rbox( 4, 0, 0, w, h, Color( 5, 5, 5, 100 ) )
                                    end

                                    local clr_txt = s.hover and Color( 255, 255, 255, 255 ) or Color( 255, 255, 255, 255 )
                                    --draw.SimpleText( helper.get:utf8( 'close' ), pref( 'dc_exit' ), 2, h / 2 + 4, clr_txt, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
                                    draw.SimpleText( lang( 'dc_opt_stay' ), pref( 'dc_btn' ), w / 2, h / 2, clr_txt, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
                                end )

    /*
    *   btn :: option :: disconnect
    */

    self.go                     = ui.new( 'btn', self.p_sub     )
    :bsetup                     (                               )
    :static                     ( RIGHT                         )
    :notext                     (                               )
    :wide                       ( btn_w                         )
    :margin                     ( 5, 10, 5, 10                  )
    :tip                        ( lang( 'tooltip_close' )       )
    :anim_click_ol              ( Color( 41, 77, 117, 200 )     )

                                :draw( function( s, w, h )
                                    design.rbox( 4, 0, 0, w, h, Color( 82, 106, 58, 255 ) )
                                    design.rbox( 4, 2, 2, w - 4, h - 4, Color( 56, 74, 39, 255 ) )

                                    if s.hover then
                                        design.rbox( 4, 0, 0, w, h, Color( 5, 5, 5, 100 ) )
                                    end

                                    local clr_txt = s.hover and Color( 255, 255, 255, 255 ) or Color( 255, 255, 255, 255 )
                                    --draw.SimpleText( helper.get:utf8( 'close' ), pref( 'dc_exit' ), 2, h / 2 + 4, clr_txt, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
                                    draw.SimpleText( lang( 'dc_opt_leave' ), pref( 'dc_btn' ), w / 2, h / 2, clr_txt, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
                                end )

                                :oc( function( s )
                                    RunConsoleCommand( 'disconnect' )
                                end )

    /*
    *   footer
    */

    self.footer                 = ui.new( 'pnl', self.p_desc    )
    :nodraw                     (                               )
    :static                     ( BOTTOM                        )
    :margin                     ( 0                             )
    :tall                       ( 10                            )

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
    design.rbox( 4, 5, 0, w - 10, h - 8, Color( 40, 40, 40, 255 ) )
    design.rbox_adv( 0, 5, 0, w - 10, 34, Color( 30, 30, 30, 255 ), true, true, false, false )
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

vgui.Register( 'rlib.lo.dc', PANEL, 'DFrame' )