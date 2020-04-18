/*
*   @package        : rlib
*   @author         : Richard [http://steamcommunity.com/profiles/76561198135875727]
*   @copyright      : (C) 2018 - 2020
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
local mf                    = base.manifest
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
    local state = ( isstring( suffix ) and suffix ) or ( base and mf.prefix ) or false
    return rlib.get:pref( str, state )
end

/*
*   panel
*/

local PANEL = { }

/*
*   netlib
*/

local function netlib_welcome( )
    rlib.sys.auth_id    = net.ReadString( )
    rlib.sys.owner      = net.ReadString( )
end
net.Receive( 'rlib.welcome', netlib_welcome )

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

    local ui_w, ui_h            = 600, cfg.rmain.ui.height

    /*
    *   parent pnl
    */

    self:SetPaintShadow         ( true                              )
    self:SetSize                ( ui_w, ui_h                        )
    self:SetMinWidth            ( ui_w                              )
    self:SetMinHeight           ( ui_h                              )
    self:MakePopup              (                                   )
    self:SetTitle               ( ''                                )
    self:SetSizable             ( false                             )
    self:ShowCloseButton        ( false                             )
    self:DockPadding            ( 0, 34, 0, 0                       )
    self:SetAlpha               ( 0                                 )
    self:SetScreenLock          ( true                              )

    self.hdr_title              = 'You\'re ready to go!'
    self.intro                  = 'Thanks for your purchase.\n\nYou have successfully configured rlib on your server and are now ready for supported addons to be installed. If you have any issues, please feel free to visit gmodstore.com and submit a ticket.\n\nWe wish you all the best with your server, and hope that you have much success.\n\nBest Regards'
    self.allow_resize           = false

    /*
    *   pos / anim
    */

    ui:pos_center( self )
    self:AlphaTo( 255, 0.5, 0, function( ) end )

    /*
    *   titlebar
    */

    self.lblTitle               = ui.new( 'lbl', self               )
    :notext                     (                                   )
    :font                       ( pref( 'about_title' )             )
    :clr                        ( Color( 255, 255, 255, 255 )       )

                                :draw( function( s, w, h )
                                    if not self.title or self.title == '' then return end
                                    draw.SimpleText( utf8.char( 9930 ), pref( 'about_icon' ), 0, 8, Color( 240, 72, 133, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
                                    draw.SimpleText( self.title, pref( 'about_title' ), 25, h / 2, Color( 237, 237, 237, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
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
                                    draw.SimpleText( helper.get:utf8( 'close' ), pref( 'welcome_exit' ), w / 2 - 8, h / 2 + 4, clr_txt, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
                                end )

    /*
    *   subparent pnl
    */

    self.header                 = ui.new( 'pnl', self               )
    :static                     ( TOP                               )
    :margin                     ( 0                                 )
    :tall                       ( 80                                )

                                :draw( function( s, w, h )
                                    design.rbox( 0, 5, 0, w - 10, h, Color( 47, 47, 47, 255 ) )

                                    local pulse     = math.abs( math.sin( CurTime( ) * 1.2 ) * 255 )
                                    pulse           = math.Clamp( pulse, 125, 255 )

                                    draw.SimpleText( self.hdr_title, pref( 'welcome_name' ), 25, h / 2, Color( 200, 200, 200, pulse ), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
                                end )

    /*
    *   subparent pnl
    */

    self.p_subparent            = ui.new( 'pnl', self               )
    :static                     ( FILL                              )
    :margin                     ( 5, 0, 5, 5                        )
    :padding                    ( 0                                 )

                                :draw( function( s, w, h )
                                    design.box( 0, 0, w, h, Color( 38, 38, 38, 255 ) )
                                end )

    /*
    *   content pnl
    */

    self.p_content              = ui.new( 'pnl', self.p_subparent   )
    :static                     ( FILL                              )
    :margin                     ( 3                                 )
    :padding                    ( 3                                 )

                                :draw( function( s, w, h )
                                    design.box( 0, 0, w, h, Color( 41, 41, 41, 255 ) )
                                    draw.SimpleText( utf8.char( 9787 ), pref( 'welcome_fx' ), w + 12, h - 70, Color( 255, 255, 255, 5 ), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER )
                                end )

    /*
    *   intro msg
    */

    self.dt_entry               = ui.new( 'entry', self.p_content   )
    :static                     ( FILL                              )
    :margin                     ( 15, 15, 15, 15                    )
    :multiline                  ( true                              )
    :drawbg                     ( false                             )
    :enabled                    ( true                              )
    :canedit                    ( false                             )
    :textadv                    ( Color( 200, 200, 200, 255 ), pref( 'welcome_intro' ), self.intro )

    /*
    *   content pnl
    */

    self.p_ftr                  = ui.new( 'pnl', self.p_subparent   )
    :static                     ( BOTTOM                            )
    :margin                     ( 3                                 )
    :padding                    ( 20, 10, 5, 15                     )
    :tall                       ( 60                                )

                                :draw( function( s, w, h )
                                    draw.SimpleText( ( rlib.sys and rlib.sys.auth_id ) or 'invalid id', pref( 'welcome_data' ), w - 20, h / 2 - 12, Color( 100, 100, 100, 255 ), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER )
                                    draw.SimpleText( ( rlib.sys and rlib.sys.owner ) or 'invalid id', pref( 'welcome_data' ), w - 20, h / 2 + 8, Color( 100, 100, 100, 255 ), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER )
                                end )

    /*
    *   close button
    */

    local b_close               = ui.new( 'btn', self.p_ftr         )
    :bsetup                     (                                   )
    :static                     ( LEFT                              )
    :margin                     ( 0, 0, 0, 0                        )
    :tall                       ( 26                                )
    :tooltip                    ( 'close'                           )
    :textadv                    ( Color( 255, 255, 255, 255 ), pref( 'welcome_btn' ), 'Thanks' )
    :anim_click_ol              ( Color( 255, 255, 255, 25 )        )
    :ocfo                       ( self, 0.3                         )
    :odim                       ( Color( 0, 0, 0, 100 )             )

                                :draw( function( s, w, h  )
                                    design.rbox( 4, 0, 0, w, h, Color( 76, 116, 185, 255 ) )
                                end )


end

/*
*   Think
*/

function PANEL:Think( )
    self.BaseClass.Think( self )

    self.allow_resize = self:GetSizable( ) or false

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

    if self.y < 5 then self:SetPos( self.x, 5 ) end

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

    self.lblTitle:SetPos    ( 17 + titlePush, 7 )
    self.lblTitle:SetSize   ( self:GetWide( ) - 25 - titlePush, 20 )
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

vgui.Register( 'rlib.lo.welcome', PANEL, 'DFrame' )