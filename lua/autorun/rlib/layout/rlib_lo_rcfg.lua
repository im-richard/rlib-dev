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

    local ui_w, ui_h        = cfg.rcfg.ui.width, cfg.rcfg.ui.height

    /*
    *   localized colorization
    */

    local clr_cur           = Color( 200, 200, 200, 255 )
    local clr_text          = Color( 255, 255, 255, 255 )
    local clr_hl            = Color( 25, 25, 25, 255 )
    local clr_box_status    = Color( 150, 50, 50, 255 )

    local mat_bg            = 'http://cdn.rlib.io/gms/bg.png'
    local state, r, g, b    = 0, 255, 0, 0
    local sf                = string.format

    /*
    *   parent pnl
    */

    self:SetPaintShadow     ( true              )
    self:SetSize            ( ui_w, ui_h        )
    self:SetMinWidth        ( ui_w              )
    self:SetMinHeight       ( ui_h              )
    self:MakePopup          (                   )
    self:SetTitle           ( ''                )
    self:SetSizable         ( true              )
    self:ShowCloseButton    ( false             )
    self:DockPadding        ( 0, 34, 0, 0       )

    self.hdr_title          = 'rcfg'
    self.conn_clr           = Color( 200, 100, 100, 255 )

        /*
        *   image :: dhtml src
        */

    self.par                    = ui.new( 'dhtml', self             )
    :nodraw                     (                                   )
    :static                     ( FILL                              )
    :margin                     ( 5, 0, 5, 0                        )
    :sbar                       ( false                             )

                                self.par:SetHTML(
                                [[
                                    <body style='overflow: hidden; height: 100%; width: 100%; margin:0px;'>
                                        <img width='100%' height='100%' style='width:200%;height:140%;' src=']] .. mat_bg .. [['>
                                    </body>
                                ]])

    self.filter                 = ui.new( 'pnl', self               )
    :static                     ( FILL                              )
    :margin                     ( 5, 0, 5, 0                        )

                                :draw( function( s, w, h )
                                    design.blur( s, 4 )
                                    design.box( 0, 0, w, h, Color( 0, 0, 0, 220 ) )
                                end )

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
    *
    *   to overwrite existing properties from the skin; do not change this
    *   labels name to anything other than lblTitle otherwise it wont
    *   inherit position/size properties
    */

    self.lblTitle               = ui.new( 'lbl', self               )
    :notext                     (                                   )
    :font                       ( pref( 'rcfg.title' )              )
    :clr                        ( Color( 255, 255, 255, 255 )       )

                                :draw( function( s, w, h )
                                    if not self.title or self.title == '' then self.title = 'rcfg' end
                                    draw.SimpleText( utf8.char( 9930 ), pref( 'rcfg.icon' ), 0, 8, Color( 240, 72, 133, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
                                    draw.SimpleText( self.title, pref( 'rcfg.title' ), 25, h / 2, Color( 237, 237, 237, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
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
                                    draw.SimpleText( helper.get:utf8( 'close' ), pref( 'rcfg.exit' ), w / 2 - 7, h / 2 + 4, clr_txt, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
                                end )

    /*
    *   header
    */

    self.p_hdr                  = ui.new( 'pnl', self               )
    :static                     ( TOP                               )
    :margin                     ( 0                                 )
    :tall                       ( 70                                )

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

                                    draw.SimpleText( self.hdr_title:upper( ), pref( 'rcfg.name' ), w / 2, h / 2 - 8, clr_rgb, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
                                    draw.SimpleText( 'MODULE MANAGEMENT', pref( 'rcfg.sub' ), w / 2, h / 2 + 17, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
                                end )

    /*
    *   status :: pnl
    */

    self.p_status               = ui.new( 'pnl', self               )
    :static                     ( TOP                               )
    :margin                     ( 0                                 )
    :tall                       ( 20                                )

                                :draw( function( s, w, h )
                                    design.rbox( 0, 2, 1, w - 4, h, Color( 15, 15, 15, 230 ) )
                                    design.blur( s, 0.5 )
                                    design.rbox( 0, 0, 2, w, h, Color( clr_box_status.r, clr_box_status.g, clr_box_status.b, 255 ) )
                                end )

    /*
    *   status :: label
    */

    self.l_status               = ui.new( 'lbl', self.p_status      )
    :notext                     (                                   )
    :static                     ( FILL                              )
    :margin                     ( 3, 5, 3, 1                        )
    :txt                        ( 'Under Development', Color( 255, 255, 255, 255 ), pref( 'rcfg.status' ), false, 5 )

    /*
    *   subparent pnl
    */

    self.p_sub                  = ui.new( 'pnl', self               )
    :nodraw                     (                                   )
    :static                     ( FILL                              )
    :margin                     ( 10                                )

    /*
    *   scroll panel
    */

    self.dsp                    = ui.new( 'rlib.ui.scrollpanel', self.p_sub )
    :static                     ( FILL                              )
    :margin                     ( 10, 5, 5, 0                       )

    self.dsp.AlphaOR            = true
    self.dsp.KnobColor          = Color( 68, 114, 71, 255 )

    /*
    *   declarations
    */

    local clr_title             = Color( 38, 175, 99 )
    local clr_ver_box           = Color( 194, 43, 84, 255 )
    local clr_ver_txt           = Color( 255, 255, 255, 255 )
    local clr_rel_txt           = Color( 200, 200, 200, 255 )
    local clr_des_txt           = Color( 230, 230, 230, 255 )

    local sz_item               = 72
    local i_modules             = table.Count( rcore.modules )
    local str_modules           = sf( '%i modules installed', i_modules )
    local osset                 = 15

    /*
    *   loop modules
    */

    local i = 0
    for k, v in SortedPairs( rcore.modules ) do

        local clr_box               = i % 2 == 0 and Color( 255, 255, 255, 0 ) or Color( 255, 255, 255, 4 )
        local clr_box_border        = i % 2 == 0 and Color( 255, 255, 255, 0 ) or Color( 255, 255, 255, 4 )
        local clr_mat               = i % 2 == 0 and Color( 255, 255, 255, 0 ) or Color( 255, 255, 255, 3 )

        /*
        *   declare modules data
        */

        local m_name                = isstring( v.name ) and v.name or v.id
        local m_ver                 = sf( '%s', rlib.get:versionstr( v ) )
        local m_rel                 = v.released and os.date( '%m.%d.%y', v.released )
        local m_def                 = 'http://cdn.rlib.io/gms/env.png'
        local m_img                 = ( isstring( v.icon ) and v.icon ~= '' and v.icon ) or m_def
        local m_url                 = ( isstring( v.url ) and v.url ) or rlib.manifest.site
        local m_desc                = isstring( v.desc ) and v.desc or 'No description'
        m_desc                      = helper.str:truncate( m_desc, 60, '...' ) or lang( 'err' )
        m_desc                      = helper.str:ucfirst( m_desc )

        /*
        *   item :: parent
        */

        self.item                   = ui.new( 'pnl', self.dsp           )
        :nodraw                     (                                   )
        :static                     ( TOP                               )
        :tall                       ( sz_item - 10                      )
        :margin                     ( 0, 0, 15, 1                       )

                                    :draw( function( s, w, h )
                                        design.rbox( 4, 0, 0, w - osset, h, clr_box )
                                        design.obox( 0, 0, w - osset, h, Color( 35, 35, 35, 0 ), clr_box_border )

                                        local w_sz, h_sz = w, h
                                        draw.TexturedQuad { texture = surface.GetTextureID( helper._mat[ 'grad_down' ] ), color = clr_mat, x = 0, y = 1, w = w_sz - osset, h = h_sz * 1 }
                                    end )

        /*
        *   item :: sub
        */

        self.item_sub               = ui.new( 'pnl', self.item          )
        :nodraw                     (                                   )
        :static                     ( FILL                              )
        :margin                     ( 5                                 )

        /*
        *   item :: right
        */

        self.p_right                = ui.new( 'pnl', self.item_sub      )
        :nodraw                     (                                   )
        :static                     ( FILL                              )
        :margin                     ( 0, 0, 0, 0                        )

        /*
        *   item :: right :: top
        */

        self.p_r_top                = ui.new( 'pnl', self.p_right       )
        :nodraw                     (                                   )
        :static                     ( TOP                               )
        :margin                     ( 0, 0, 0, 0                        )
        :tall                       ( 20                                )

                                    :draw( function( s, w, h )
                                       design.text( m_rel, w - 5 - osset, 12, clr_rel_txt, pref( 'rcfg.item.rel' ), 2, 1 )
                                       design.title_boxcat( m_name, pref( 'rcfg.item.name' ), m_ver, pref( 'rcfg.item.ver' ), clr_title, clr_ver_box, clr_ver_txt, 8, 12, 1, 0 )
                                    end )

        /*
        *   item :: right :: btm
        */

        self.p_r_btm                = ui.new( 'pnl', self.p_right       )
        :nodraw                     (                                   )
        :static                     ( FILL                              )
        :margin                     ( 0, 0, 0, 0                        )

        /*
        *   item :: right :: desc
        */

        self.desc                   = ui.new( 'dt', self.p_right        )
        :static                     ( TOP                               )
        :tall                       ( 23                                )
        :margin                     ( 5, 0, 0, 0                        )
        :drawbg                     ( false                             )
        :mline	                    ( false 				            )
        :ascii	                    ( false 				            )
        :canedit	                ( false 				            )
        :scur	                    ( Color( 255, 255, 255, 255 ), 'beam' )
        :txt	                    ( m_desc, clr_des_txt, pref( 'rcfg.item.desc' ) )
        :ocnf                       ( true                              )

        /*
        *   image :: container
        */

        self.p_img                  = ui.new( 'pnl', self.item_sub      )
        :static                     ( LEFT                              )
        :wide                       ( sz_item - 25                      )
        :margin                     ( 4                                 )

                                    :draw( function( s, w, h )
                                        design.box( 0, 0, w, h, Color( 255, 255, 255, 25 ))
                                    end )

        /*
        *   image :: dhtml src
        */

        self.av_url                 = ui.new( 'dhtml', self.p_img       )
        :nodraw                     (                                   )
        :static                     ( FILL                              )
        :margin                     ( 1                                 )
        :sbar                       ( false                             )

                                    self.av_url:SetHTML(
                                    [[
                                        <body style='overflow: hidden; height: 100%; width: 100%; margin:0px;'>
                                            <img width='100%' height='100%' style='width:100%;height:100%;' src=']] .. m_img .. [['>
                                        </body>
                                    ]])

        /*
        *   image :: dhtml src
        */

        self.av_def                 = ui.new( 'dhtml', self.p_img       )
        :nodraw                     (                                   )
        :static                     ( FILL                              )
        :margin                     ( 1                                 )
        :sbar                       ( false                             )

                                    self.av_url:SetHTML(
                                    [[
                                        <body style='overflow: hidden; height: 100%; width: 100%; margin:0px;'>
                                            <img width='100%' height='100%' style='width:100%;height:100%;' src=']] .. m_def .. [['>
                                        </body>
                                    ]])

        /*
        *   image :: btn
        */

        self.b_hov                  = ui.new( 'btn', self.item          )
        :bsetup                     (                                   )
        :notext                     (                                   )
        :static                     ( FILL                              )
        :margin                     ( 0, 0, 0, 0                        )
        :openurl                    ( m_url                             )

                                    :draw( function( s, w, h )
                                        if s.hover then
                                            design.rbox( 4, w - 5, 0, 5, h, Color( 231, 103, 81, 255 ) )
                                        end
                                    end )

        /*
        *   count loop progress
        */

        i = i + 1

        /*
        *   hide spacer if last item in list
        */

        if i == i_modules then
            ui:hide( self.sp )
        end

    end

    /*
    *   spacer :: bottom
    */

    self.sp_btm                     = ui.new( 'pnl', self.dsp           )
    :nodraw                         (                                   )
    :static                         ( TOP                               )
    :tall                           ( 10                                )
    :margin                         ( 0, 3, 20, 3                       )

    /*
    *   footer
    */

    self.p_ftr                      = ui.new( 'pnl', self               )
    :static                         ( BOTTOM                            )
    :margin                         ( 5, 0, 5, 0                        )
    :tall                           ( 25                                )

                                    :draw( function( s, w, h )
                                        design.box( 0, 0, w, h, Color( 34, 34, 34, 255 ) )
                                        draw.SimpleText( str_modules, pref( 'rcfg.footer.count' ), w - 6, h / 2, Color( 255, 255, 255, 255 ), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER )
                                    end )

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
    design.rbox( 4, 5, 0, w - 10, h - 8, Color( 44, 49, 55, 255 ) )
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