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
*   localization :: modules and pkgs
*/

rlib                        = rlib or { }
local base                  = rlib
local cfg                   = base.settings
local mf                    = base.manifest
local helper                = base.h
local design                = base.d
local ui                    = base.i

/*
*   localization :: glua
*/

local Color                 = Color

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
    local state = ( isstring( suffix ) and suffix ) or ( base and mf.prefix ) or false
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

    local sc_w, sc_h            = ui:scalesimple( 0.85, 0.85, 0.90 ), ui:scalesimple( 0.85, 0.85, 0.90 )
    local pnl_w, pnl_h          = cfg.report.ui.width, cfg.report.ui.height
    local ui_w, ui_h            = sc_w * pnl_w, sc_h * pnl_h
    local min_sz                = 0.85

    /*
    *   localized colorization
    */

    local clr_cur               = Color( 200, 200, 200, 255 )
    local clr_text              = Color( 255, 255, 255, 255 )
    local clr_hl                = Color( 25, 25, 25, 255 )

    /*
    *   parent pnl
    */

    self:SetPaintShadow         ( true                          )
    self:SetSize                ( ui_w, ui_h                    )
    self:SetMinWidth            ( ui_w * min_sz                 )
    self:SetMinHeight           ( ui_h * min_sz                 )
    self:MakePopup              (                               )
    self:SetTitle               ( ''                            )
    self:SetSizable             ( true                          )
    self:ShowCloseButton        ( false                         )
    self:DockPadding            ( 2, 34, 2, 3                   )

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

    self.lblTitle               = ui.new( 'lbl', self           )
    :notext                     (                               )
    :font                       ( pref( 'report.title' )        )
    :clr                        ( Color( 255, 255, 255, 255 )   )

                                :draw( function( s, w, h )
                                    if not self.title or self.title == '' then return end
                                    draw.SimpleText( utf8.char( 9930 ), pref( 'report.icon' ), 0, 8, Color( 240, 72, 133, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
                                    draw.SimpleText( self.title, pref( 'report.title' ), 25, h / 2, Color( 237, 237, 237, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
                                end )

    /*
    *   close button
    *
    *   to overwrite existing properties from the skin; do not change this
    *   buttons name to anything other than btnClose otherwise it wont
    *   inherit position/size properties
    */

    self.btnClose               = ui.new( 'btn', self               )
    :bsetup                     (                                   )
    :notext                     (                                   )
    :tooltip                    ( lang( 'tooltip_close' )           )
    :ocr                        ( self                              )

                                :draw( function( s, w, h )
                                    local clr_txt = s.hover and Color( 200, 55, 55, 255 ) or Color( 237, 237, 237, 255 )
                                    draw.SimpleText( helper.get:utf8( 'close' ), pref( 'report.exit' ), w / 2, h / 2 + 4, clr_txt, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
                                end )

    /*
    *   subparent pnl
    */

    self.p_subparent            = ui.new( 'pnl', self               )
    :nodraw                     (                                   )
    :static                     ( FILL                              )
    :margin                     ( 0, 10, 0                          )

    /*
    *   body
    */

    self.p_body                 = ui.new( 'pnl', self.p_subparent   )
    :nodraw                     (                                   )
    :static                     ( FILL                              )
    :margin                     ( 10, 5, 10, 5                      )

    /*
    *   bottom
    */

    self.p_btm                  = ui.new( 'pnl', self.p_subparent   )
    :nodraw                     (                                   )
    :static                     ( BOTTOM                            )
    :margin                     ( 10, 0, 10, 5                      )
    :tall                       ( 32                                )

    /*
    *   bottom :: left
    */

    self.p_btm_l                = ui.new( 'pnl', self.p_btm         )
    :nodraw                     (                                   )
    :static                     ( LEFT                              )
    :margin                     ( 0, 4, 0, 4                        )
    :wide                       ( 70 * 1                            )

    /*
    *   bottom :: right
    */

    self.p_btm_r                = ui.new( 'pnl', self.p_btm         )
    :nodraw                     (                                   )
    :static                     ( FILL                              )
    :margin                     ( 4                                 )

    /*
    *   err :: container
    */

    self.p_err                  = ui.new( 'pnl', self.p_btm_r       )
    :nodraw                     (                                   )
    :static                     ( BOTTOM                            )
    :margin                     ( 0, 5, 0, 0                        )
    :tall                       ( 25                                )

    /*
    *   err :: label
    */

    self.l_err                  = ui.new( 'lbl', self.p_err         )
    :static                     ( FILL                              )
    :margin                     ( 3, 3, 0, 3                        )
    :notext                     (                                   )
    :font                       ( pref( 'report.err' )              )
    :clr                        ( Color( 200, 100, 100, 255 )       )
    :align                      ( 6                                 )

                                :logic( function( s )
                                    s:SetColor( Color( 200, 100, 100, 255 ) )
                                end )

    /*
    *   desc
    */

    self.dtxt_desc              = ui.new( 'entry', self.p_body      )
    :static		                ( TOP 					            )
    :padding		            ( 3 			                    )
    :tall                       ( 90                                )
    :drawbg                     ( false                             )
    :mline	                    ( true 				                )
    :canedit                    ( false                             )
    :autoupdate	                ( true 					            )
    :scur	                    ( Color( 255, 255, 255, 255 ), 'beam' )
    :txt	                    ( lang( 'reports_desc' ), Color( 255, 255, 255, 255 ), pref( 'report.desc' ) )
    :drawentry                  ( clr_text, clr_cur, clr_hl         )

    /*
    *   desc container
    */

    self.p_desc                 = ui.new( 'pnl', self.p_body        )
    :static                     ( FILL                              )
    :padding                    ( 3                                 )

                                :draw( function( s, w, h )
                                    design.rbox( 6, 0, 0, w, h, Color( 30, 30, 30, 255 ) )
                                end )

    /*
    *   dtxt_input textentry
    */

    self.dtxt_input             = ui.new( 'entry', self.p_desc      )
    :static		                ( FILL 					            )
    :padding		            ( 0 			                    )
    :drawbg                     ( false                             )
    :mline	                    ( true 				                )
    :canedit                    ( true                              )
    :focus	                    ( 					                )
    :scur	                    ( Color( 255, 255, 255, 255 ), 'beam' )
    :drawentry                  ( clr_text, clr_cur, clr_hl         )

    /*
    *   auth code parent container
    */

    self.p_auth                 = ui.new( 'pnl', self.p_body        )
    :static                     ( BOTTOM                            )
    :padding                    ( 23, 3                             )
    :tall                       ( 25                                )

                                :draw( function( s, w, h )
                                    design.rbox( 6, 0, 0, w, h, Color( 30, 30, 30, 255 ) )
                                    draw.SimpleText( utf8.char( 10045 ), pref( 'report.auth.icon' ), 2, 12, Color( 240, 113, 113, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
                                end )

    /*
    *   spacer
    *
    *   puts a gap between the description dtextentry and auth code entry
    */

    self.p_spacer               = ui.new( 'pnl', self.p_body        )
    :nodraw                     (                                   )
    :static                     ( BOTTOM                            )
    :margin                     ( 0                                 )
    :tall                       ( 5                                 )

    /*
    *   button spacer
    */

    self.p_auth_spacer          = ui.new( 'pnl', self.p_auth        )
    :nodraw                     (                                   )
    :static                     ( RIGHT                             )
    :margin                     ( 0                                 )
    :size                       ( 55, 18                            )

    /*
    *   auth code input
    */

    local dtxt_default          = lang( 'reports_auth_code' )

    self.dtxt_auth              = ui.new( 'entry', self.p_auth      )
    :static		                ( FILL 					            )
    :padding		            ( 0 			                    )
    :drawbg                     ( false                             )
    :mline	                    ( false 				            )
    :canedit                    ( true                              )
    :font                       ( pref( 'report.auth' )             )
    :text                       ( dtxt_default                      )
    :scur	                    ( Color( 255, 255, 255, 255 ), 'beam' )
    :drawentry                  ( clr_text, clr_cur, clr_hl         )

                                :draw( function( s, w, h )
                                    s:SetCursorColor( Color( clr_cur.r, clr_cur.g, clr_cur.b, 255 ) )
                                    s:SetHighlightColor( Color( clr_hl.r, clr_hl.g, clr_hl.b, 255 ) )

                                    local clr_txt = s:GetValue( ) == dtxt_default and Color( 150, 150, 150, 255 ) or Color( clr_text.r, clr_text.g, clr_text.b, 255 )
                                    s:DrawTextEntryText( clr_txt, s:GetHighlightColor( ), s:GetCursorColor( ) )
                                end )

                                :focuschg( function( s, bFocus )
                                    local value = string.Trim( s:GetValue( ) )
                                    if bFocus then
                                        if value == dtxt_default then
                                            s:SetText( '' )
                                        end
                                    else
                                        if value == '' or not value then
                                            s:SetText( dtxt_default )
                                        end
                                    end
                                end )

    /*
    *   bottom right :: clear button
    */

    self.b_clr                  = ui.new( 'btn', self.p_auth_spacer )
    :bsetup                     (                                   )
    :static                     ( RIGHT                             )
    :margin                     ( 0                                 )
    :notext                     (                                   )
    :size                       ( 20, 18                            )
    :tooltip                    ( lang( 'reports_tooltip_clear' )   )

                                :draw( function( s, w, h )
                                    design.rbox( 6, 0, 0, w, h, Color( 200, 55, 55, 255 ) )
                                    if s.hover then
                                        design.rbox( 6, 0, 0, w, h, Color( 15, 15, 15, 100 ) )
                                    end
                                    draw.SimpleText( 'X', pref( 'report.btn.clr' ), w / 2, h / 2, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
                                end )

                                :oc( function( s )
                                    self.dtxt_auth:SetText( dtxt_default )
                                end )

    /*
    *   bottom right :: request auth key
    */

    self.b_req                  = ui.new( 'btn', self.p_auth_spacer )
    :bsetup                     (                                   )
    :static                     ( RIGHT                             )
    :margin                     ( 0, 0, 5, 0                        )
    :notext                     (                                   )
    :size                       ( 20, 18                            )
    :tooltip                    ( lang( 'reports_auth_code_req' )   )

                                :draw( function( s, w, h )
                                    design.rbox( 6, 0, 0, w, h, Color( 163, 75, 179, 255 ) )
                                    if s.hover then
                                        design.rbox( 6, 0, 0, w, h, Color( 15, 15, 15, 100 ) )
                                    end
                                    draw.SimpleText( utf8.char( 9881 ), pref( 'report.btn.auth' ), 8, 6, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
                                end )

                                :oc( function( s )
                                    gui.OpenURL( mf.astra.auth )
                                end )

    /*
    *   bottom right :: inner
    */

    self.p_btm_l_inner          = ui.new( 'pnl', self.p_btm_l       )
    :nodraw                     (                                   )
    :static                     ( FILL                              )
    :margin                     ( 0, 1, 0, 1                        )

    /*
    *   bottom right :: send report button
    */

    self.b_send                 = ui.new( 'btn', self.p_btm_l_inner )
    :bsetup                     (                                   )
    :static                     ( LEFT                              )
    :margin                     ( 0                                 )
    :notext                     (                                   )
    :size                       ( 60, 20                            )
    :tooltip                    ( lang( 'reports_tooltip_submit' )  )

                                :draw( function( s, w, h )
                                    design.rbox( 6, 0, 0, w, h, Color( 60, 120, 62, 255 ) )
                                    if s.hover then
                                        design.rbox( 6, 0, 0, w, h, Color( 15, 15, 15, 100 ) )
                                    end
                                    draw.SimpleText( lang('reports_btn_submit'), pref( 'report.btn.send' ), w / 2, h / 2 + 1, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
                                end )

                                :oc( function( s )
                                    local has_err, has_msg  = false, false
                                    local char_limit        = 280

                                    local field_authcode    = string.Trim( self.dtxt_auth:GetValue( ) )
                                    local field_feedback    = string.Trim( self.dtxt_input:GetValue( ) )
                                    local field_chars       = field_feedback:len( )
                                    local auth_chars        = field_authcode:len( )

                                    if ( auth_chars < 1 or field_authcode == dtxt_default or not field_authcode ) then
                                        has_err             = true
                                        has_msg             = lang( 'reports_err_auth_invalid' )
                                    elseif auth_chars > 7 and field_authcode ~= dtxt_default then
                                        has_err             = true
                                        has_msg             = lang( 'reports_err_auth_length' )
                                    elseif ( field_chars > char_limit ) then
                                        has_err             = true
                                        has_msg             = lang( 'reports_err_auth_lessthan', char_limit )
                                    elseif ( LocalPlayer( ).rlib_report_cooldown or 0 ) > CurTime( ) then
                                        local remains   = math.Round( LocalPlayer( ).rlib_report_cooldown - CurTime( ) )
                                        has_err             = true
                                        has_msg             = lang( 'reports_err_send_delay', tostring( remains ) )
                                    end

                                    if has_err then
                                        if has_msg then
                                            self.l_err:SetText( has_msg or lang( 'reports_err_unknown' ) )
                                        end
                                        return
                                    else
                                        self.l_err:SetText( '' )
                                    end

                                    if ui:valid( self.l_err ) then
                                        self.l_err:SetText( lang( 'reports_please_wait' ) )
                                    end

                                    net.Start           ( 'rlib.tools.report'   )
                                    net.WriteString     ( field_authcode        )
                                    net.WriteString     ( field_feedback        )
                                    net.SendToServer    (                       )

                                    LocalPlayer( ).rlib_report_cooldown = CurTime( ) + 300
                                end )

    /*
    *    netlib :: report functionality response
    */

    local function netlib_report( )
        local bSuccess = net.ReadBool( )
        local response = net.ReadString( )

        if ui:valid( self.l_err ) then
            self.l_err:SetText( response )
        end
    end
    net.Receive( 'rlib.tools.report', netlib_report )

end

/*
*   Think
*/

function PANEL:Think( )
    self.BaseClass.Think( self )

    if not self.is_visible then self:MoveToBack( ) end
    --if input.IsKeyDown( KEY_ESCAPE ) or gui.IsGameUIVisible( ) then self:ActionHide( ) end

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
        local x         = mousex - self.Sizing[ 1 ]
        local y         = mousey - self.Sizing[ 2 ]
        local px, py    = self:GetPos( )

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
    design.rbox( 4, 0, 0, w, h, Color( 40, 40, 40, 255 ) )
    design.rbox_adv( 4, 2, 2, w - 4, 34 - 4, Color( 30, 30, 30, 255 ), true, true, false, false )

    -- resizing arrow
    draw.SimpleText( utf8.char( 9698 ), pref( 'report.resizer' ), w - 3, h - 7, Color( 240, 72, 133, 255 ), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER )
    draw.SimpleText( utf8.char( 9698 ), pref( 'report.resizer' ), w - 5, h - 9, Color( 40, 40, 40, 255 ), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER )
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
*   SetVisible
*
*   @param  : bool bVisible
*/

function PANEL:SetVisible( bVisible )
    if bVisible then
        ui:show( self, true )
    else
        ui:hide( self, true )
    end
end

/*
*   register
*/

vgui.Register( 'rlib.lo.report', PANEL, 'DFrame' )