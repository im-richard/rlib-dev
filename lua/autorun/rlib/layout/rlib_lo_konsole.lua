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
local access                = base.a
local helper                = base.h
local design                = base.d
local ui                    = base.i
local konsole               = base.k

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

    local sc_w, sc_h            = ui:scalesimple( 0.85, 0.85, 0.90 ), ui:scalesimple( 0.85, 0.85, 0.90 )
    local pnl_w, pnl_h          = cfg.konsole.ui.width, cfg.konsole.ui.height
    local ui_w, ui_h            = sc_w * pnl_w, sc_h * pnl_h
    local min_sz                = 0.85
    local state, r, g, b        = 0, 255, 0, 0

    /*
    *   localized colorization
    */

    local clr_cur               = Color( 200, 200, 200, 255     )
    local clr_text              = Color( 255, 255, 255, 255     )
    local clr_hl                = Color( 25, 25, 25, 255        )

    /*
    *   parent pnl
    */

    self:SetPaintShadow         ( true                          )
    self:SetSize                ( ui_w, ui_h                    )
    self:SetMinWidth            ( ui_w * min_sz                 )
    self:SetMinHeight           ( ui_h * min_sz                 )
    self:DockPadding            ( 2, 34, 2, 3                   )
    self:MakePopup              (                               )
    self:SetTitle               ( ''                            )
    self:SetSizable             ( true                          )
    self:ShowCloseButton        ( false                         )

    self.Alpha                  = 255
    self.is_visible             = true

    /*
    *   display parent :: static || animated
    */

    if helper:cvar_bool( 'rlib_animations_enabled' ) then
        self:SetPos( ScrW( ) - ui_w - 20, ScrH( ) + ui_h )
        self:MoveTo( ScrW( ) - ui_w - 20, ScrH( ) - ui_h - 20, 0.4, 0, -1 )
    else
        self:SetPos( ScrW( ) - ui_w - 20, ScrH( ) - ui_h - 20 )
    end

    /*
    *   titlebar
    */

    self.lblTitle               = ui.new( 'lbl', self           )
    :notext                     (                               )
    :font                       ( pref( 'konsole.title' )       )
    :clr                        ( Color( 255, 255, 255, self.Alpha ) )

                                :draw ( function( s, w, h )
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

                                    local clr_rgb = Color( r, g, b, self.Alpha )

                                    draw.SimpleText( utf8.char( 9930 ), pref( 'konsole.icon' ), 0, 8, clr_rgb, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
                                    draw.SimpleText( lang( 'title_konsole' ), pref( 'konsole.title' ), 25, h / 2, Color( 237, 237, 237, self.Alpha ), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
                                end )

    /*
    *   close button
    *
    *   to overwrite existing properties from the skin; do not change this buttons name to anything other 
    *   than btnClose otherwise it wont inherit position/size properties
    */

    self.btnClose               = ui.new( 'btn', self               )
    :bsetup                     (                                   )
    :notext                     (                                   )
    :tip                        ( lang( 'ui_minimize' )             )

                                :draw ( function( s, w, h )
                                    local clr_txt = s.hover and Color( 200, 55, 55, self.Alpha ) or Color( 237, 237, 237, self.Alpha )
                                    draw.SimpleText( helper.get:utf8( 'close' ), pref( 'konsole.ico' ), w / 2, h / 2 + 4, clr_txt, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
                                end )

                                :oc( function( s )
                                    self:ActionHide( )
                                end )

    /*
    *   subparent pnl
    */

    self.sub                    = ui.new( 'pnl', self               )
    :nodraw                     (                                   )
    :static                     ( FILL                              )
    :margin                     ( 0                                 )

    /*
    *   body
    */

    self.body                   = ui.new( 'pnl', self.sub           )
    :nodraw                     (                                   )
    :static                     ( FILL                              )
    :margin                     ( 0, 5, 0                           )

    /*
    *   body :: scroll panel
    */

    self.dsp_content            = ui.new( 'rlib.ui.scrollpanel', self.body )
    :static                     ( FILL                              )

    /*
    *   bottom
    */

    self.p_btm                  = ui.new( 'pnl', self.sub           )
    :nodraw                     (                                   )
    :static                     ( BOTTOM                            )
    :margin                     ( 3, 0, 3, 3                        )
    :tall                       ( 32                                )

    /*
    *   bottom left
    */

    self.p_btm_sub              = ui.new( 'pnl', self.p_btm         )
    :nodraw                     (                                   )
    :static                     ( FILL                              )
    :margin                     ( 6, 4, 6, 4                        )

    /*
    *   input parent container
    */

    self.p_input                = ui.new( 'pnl', self.p_btm_sub     )
    :static                     ( FILL                              )
    :padding                    ( 23, 3                             )
    :tall                       ( 25                                )

                                :draw( function( s, w, h )
                                    design.rbox( 6, 0, 0, w, h, Color( 30, 30, 30, self.Alpha ) )
                                    draw.SimpleText( utf8.char( 10097 ), pref( 'konsole.input.icon' ), 10, 9, Color( 240, 113, 113, self.Alpha ), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
                                end )

    /*
    *   btn :: spacer
    */

    self.b_spacer               = ui.new( 'pnl', self.p_input       )
    :nodraw                     (                                   )
    :static                     ( RIGHT                             )
    :padding                    ( 0                                 )
    :size                       ( 55, 18                            )

    /*
    *   dtxt_input textentry
    */

    self.dtxt_input             = ui.new( 'entry', self.p_input     )
    :static		                ( FILL 					            )
    :padding		            ( 7, 3, 7, 3 			            )
    :drawbg                     ( false                             )
    :focus	                    ( 					                )
    :scur	                    ( Color( 255, 255, 255, 255 ), 'beam' )
    :drawentry                  ( clr_text, clr_cur, clr_hl         )

                                :pl( function( s, w, h )
                                    gamemode.Call( 'ChatTextChanged', s:GetValue( ) )
                                end )

                                :onenter( function( s )
                                    self:ActionEnter( )
                                end )

    /*
    *   btn :: settings / config
    */

    self.b_cfg                  = ui.new( 'btn', self.b_spacer      )
    :bsetup                     (                                   )
    :static                     ( RIGHT                             )
    :margin                     ( 0                                 )
    :notext                     (                                   )
    :size                       ( 20, 18                            )
    :tooltip                    ( lang( 'konsole_tooltip_cfg' )     )

                                :draw( function( s, w, h )
                                    design.rbox( 6, 0, 0, w, h, Color( 163, 75, 179, self.Alpha ) )
                                    if s.hover then
                                        design.rbox( 6, 0, 0, w, h, Color( 15, 15, 15, 100 ) )
                                    end
                                    draw.SimpleText( '⚙', pref( 'konsole.gear' ), w / 2, h / 2 - 4, Color( 255, 255, 255, self.Alpha ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
                                end )

                                :oc( function( s )
                                    if ui:visible( self.pnl_settings ) then
                                        ui:destroy( self.pnl_settings )
                                        self.pnl_settings = nil
                                    else
                                        self.pnl_settings = vgui.Create( 'rlib.lo.konsole.cfg' )
                                    end
                                end )

    /*
    *   btn :: clear
    */

    self.b_clr                  = ui.new( 'btn', self.b_spacer      )
    :bsetup                     (                                   )
    :static                     ( RIGHT                             )
    :margin                     ( 0, 0, 5, 0                        )
    :notext                     (                                   )
    :size                       ( 20, 18                            )
    :tooltip                    ( lang( 'konsole_tooltip_clear' )   )

                                :draw( function( s, w, h )
                                    design.rbox( 6, 0, 0, w, h, Color( 200, 55, 55, self.Alpha ) )
                                    if s.hover then
                                        design.rbox( 6, 0, 0, w, h, Color( 15, 15, 15, 100 ) )
                                    end
                                    draw.SimpleText( 'x', pref( 'konsole.clear' ), w / 2, h / 2 - 1, Color( 255, 255, 255, self.Alpha ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
                                end )

                                :oc( function( s )
                                    self:ActionClear( )
                                end )

end

/*
*   GetTitle
*
*   @return : str
*/

function PANEL:GetTitle( )
    return self.lblTitle:GetText( )
end

/*
*   SetTitle
*
*   @param  : str title
*/

function PANEL:SetTitle( title )
    self.lblTitle:SetText( title )
end

/*
*   Think
*/

local i_think = 0
function PANEL:Think( )
    self.BaseClass.Think( self )

    if not self.is_visible then self:MoveToBack( ) end
    if input.IsKeyDown( KEY_ESCAPE ) or gui.IsGameUIVisible( ) then self:ActionHide( ) end

    local pl = LocalPlayer( )
    if not helper.ok.ply( pl ) then return end

    /*
    *   keyup and keydown dtxt_input detection for history
    */

    if input.IsKeyDown( cfg.konsole.binds.history_up ) or input.IsKeyDown( cfg.konsole.binds.history_down ) then

        if i_think > CurTime( ) then return end

        pl.konsole_history      = pl.konsole_history or { }
        pl.konsole_index        = pl.konsole_index or 0

        local i_history         = #pl.konsole_history

        /*
        *   keyup
        *
        *   @ref    : http://wiki.garrysmod.com/page/Enums/KEY
        */

        if input.IsKeyDown( cfg.konsole.binds.history_up ) then

            if ( pl.konsole_index < 1 ) then
                pl.konsole_index = 1
            elseif ( pl.konsole_index == 1 ) or ( pl.konsole_index < i_history ) then
                pl.konsole_index = pl.konsole_index + 1
            elseif ( pl.konsole_index >= i_history ) then
                pl.konsole_index = i_history
            end

        /*
        *   keydown
        *
        *   @ref    : http://wiki.garrysmod.com/page/Enums/KEY
        */

        elseif input.IsKeyDown( cfg.konsole.binds.history_down ) then

            if ( pl.konsole_index < 1 ) then
                pl.konsole_index = 1
            elseif ( pl.konsole_index > 1 ) or ( pl.konsole_index <= i_history ) then
                pl.konsole_index = pl.konsole_index - 1
            elseif ( pl.konsole_index >= i_history ) then
                pl.konsole_index = i_history
            end

        end

        /*
        *   find next key in history table and set textentry
        */

        local history = pl.konsole_history[ pl.konsole_index ]
        if history then
            self.dtxt_input:RequestFocus    ( )
            self.dtxt_input:SetText         ( history )
            self.dtxt_input:SetCaretPos     ( string.len( self.dtxt_input:GetValue( ) ) )
        end

        i_think = CurTime( ) + 0.3

    end

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

    if IsValid( self ) and ( pl.konsoleres_w ~= ScrW( ) or pl.konsoleres_h ~= ScrH( ) ) then
        pl.konsoleres_w     = ScrW( )
        pl.konsoleres_h     = ScrH( )

        local sc_w, sc_h    = ui:scalesimple( 0.85, 0.85, 0.90 ), ui:scalesimple( 0.85, 0.85, 0.90 )
        local pnl_w, pnl_h  = cfg.konsole.ui.width, cfg.konsole.ui.height
        local ui_w, ui_h    = sc_w * pnl_w, sc_h * pnl_h

        self:SetPos( ScrW( ) - ui_w - 20, ScrH( ) - ui_h - 20 )
    end

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
    design.rbox( 4, 0, 0, w, h, Color( 40, 40, 40, self.Alpha ) )
    design.rbox_adv( 4, 2, 2, w - 4, 34 - 4, Color( 30, 30, 30, self.Alpha ), true, true, false, false )

    -- resizing arrow
    draw.SimpleText( utf8.char( 9698 ), pref( 'konsole.resizer' ), w - 3, h - 7, Color( 240, 72, 133, self.Alpha ), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER )
    draw.SimpleText( utf8.char( 9698 ), pref( 'konsole.resizer' ), w - 5, h - 9, Color( 40, 40, 40, self.Alpha ), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER )
end

/*
*   AddEntry
*
*   @param  : int cat
*   @param  : varg { ... }
*/

function PANEL:AddEntry( cat, ... )
    self.entry = vgui.Create( 'rlib.lo.konsole.entry', self.dsp_content )
    self.entry:HandleSetup( cat, ... )

    local y     = self.dsp_content.pnlCanvas:GetTall( )
    local _, h  = self.entry:GetSize( )
    y           = y + h * 0.5
    y           = y - self.dsp_content:GetTall( ) * 0.5

    self.dsp_content.VBar:AnimateTo( y, 0.5, 0, 0.5 )
end

/*
*   Clean
*
*   clears all text within konsole for a clean start
*/

function PANEL:Clean( )
    if not ui:valid( self.dsp_content ) then return end
    self.dsp_content:Clear( )
end

/*
*   AddHistory
*
*   @param  : str command
*/

function PANEL:AddHistory( command )
    local pl = LocalPlayer( )
    pl.konsole_history = pl.konsole_history or { }

    table.insert( pl.konsole_history, command )
end

/*
*   ClearHistoryIndex
*
*   clears the entire list of commands that the player has executed during their session
*/

function PANEL:ClearHistoryIndex( )
    local pl = LocalPlayer( )
    pl.konsole_index = 0
end

/*
*   ActionEnter
*/

function PANEL:ActionEnter( )

    /*
    *   declarations
    */

    local cmd               = self.dtxt_input:GetValue( )
    local cmd_filter        = string.Trim( cmd )
    local cmd_len           = string.len( cmd_filter )
    local is_console        = false
    local is_say            = false
    local is_executed       = false

    /*
    *   required minimum command length
    */

    if cmd_len < 1 then
        konsole:send( 2, 'invalid command' )
        self.dtxt_input:RequestFocus( )
        return false
    end

    /*
    *   check for gmod console command prefix
    *   strip prefix from command if present
    */

    if string.sub( cmd_filter, 1, 1 ) == cfg.konsole.prefix_gcon then
        is_console      = true
        cmd_filter      = string.sub( cmd_filter, 2 )
    end

    /*
    *   check for gmod say prefix
    *   strip prefix from command if present
    */

    if string.sub( cmd_filter, 1, 1 ) == cfg.konsole.prefix_say then
        is_say          = true
        cmd_filter      = string.sub( cmd_filter, 2 )
    end

    /*
    *   create command arguments
    */

    local args          = string.Explode( ' ', cmd_filter )
    local cmd_base      = args and args[ 1 ]

    /*
    *   check permissions
    *
    *   just in case they get past the first permission check for whatever reason
    */

    if not access:bIsDev( LocalPlayer( ) ) then
        if cmd_base == 'exit' then
            cfg.konsole.help[ cmd_base ].func( self, args )
        end

        konsole:send( 2, 'access denied » contact system admin' )
        self.dtxt_input:SetText( '' )
        self.dtxt_input:RequestFocus( )
        return
    end

    /*
    *   is console command
    */

    if not is_executed and is_console then
        local concmd = table.concat( args, ' ' )
        LocalPlayer( ):ConCommand( concmd )

        konsole:send( 0, Color( 200, 50, 50 ), 'executed concommand: ', Color( 255, 255, 255 ), concmd )
        self:AddHistory( cmd_filter )
        is_executed = true
    end

    /*
    *   is say command
    */

    if not is_executed and is_say then
        local concmd = table.concat( args, ' ' )
        if cmd_filter:len( ) < 2 then
            konsole:send( 2, 'too few characters' )
            return false
        end

        LocalPlayer( ):ConCommand( 'say ' .. concmd )

        konsole:send( 0, Color( 50, 200, 50 ), 'executed say: ', Color( 255, 255, 255 ), concmd )
        self:AddHistory( cmd_filter )
        is_executed = true
    end

    /*
    *   is integrated rlib command
    */

    if not is_executed and not is_console and ( cfg.konsole.help[ cmd_base ] and cfg.konsole.help[ cmd_base ].func ) then
        helper:table_remove( args, 1 )
        cfg.konsole.help[ cmd_base ].func( self, args )
        self:AddHistory( cmd_filter )
        is_executed = true
    end

    self.dtxt_input:SetText( '' )
    self.dtxt_input:RequestFocus( )

end

/*
*   ActionClear
*/

function PANEL:ActionClear( )
    self.dtxt_input:SetText( '' )
    self.dtxt_input:RequestFocus( )
end

/*
*   ActionHide
*/

function PANEL:ActionHide( )
    self.is_visible = false

    self:SetState( )
    self:ClearHistoryIndex( )
    self:SetMouseInputEnabled( false )
    self:SetKeyboardInputEnabled( false )
end

/*
*   ActionShow
*/

function PANEL:ActionShow( )
    self.is_visible = true
    self:SetState( )
    self:SetMouseInputEnabled( true )
    self:SetKeyboardInputEnabled( true )
    self.dtxt_input:RequestFocus( )
end

/*
*   SetState
*/

function PANEL:SetState( )
    self.Alpha = self.is_visible and 255 or 0
    if IsValid( self.btnClose ) then self.btnClose:SetAlpha( self.Alpha ) end
    if IsValid( self.dtxt_input ) then self.dtxt_input:SetAlpha( self.Alpha ) end
    if IsValid( self.b_cfg ) then self.b_cfg:SetAlpha( self.Alpha ) end
end

/*
*   Destroy
*/

function PANEL:Destroy( )
    self:ClearHistoryIndex( )
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

vgui.Register( 'rlib.lo.konsole', PANEL, 'DFrame' )

/*
*   panel :: konsole :: settings
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

    local sc_w, sc_h            = ui:scalesimple( 0.85, 0.85, 0.90 ), ui:scalesimple( 0.85, 0.85, 0.90 )
    local pnl_w, pnl_h          = 500, 345
    local ui_w, ui_h            = sc_w * pnl_w, sc_h * pnl_h
    local state, r, g, b        = 0, 255, 0, 0

    /*
    *   initialize
    */

    self:SetPaintShadow         ( true              )
    self:SetSize                ( ui_w, ui_h        )
    self:MakePopup              (                   )
    self:SetTitle               ( ''                )
    self:SetSizable             ( true              )
    self:ShowCloseButton        ( false             )
    self:DockPadding            ( 2, 34, 2, 3       )

    self.Alpha                  = 255
    self.is_visible             = true

    /*
    *   animations
    */

    if helper:cvar_bool( 'rlib_animations_enabled' ) then
        ui:setpos_center( self, 0.3, 1 )
    else
        ui:setpos_center( self )
    end

    /*
    *   titlebar
    */

    self.lblTitle               = ui.new( 'lbl', self               )
    :notext                     (                                   )
    :font                       ( pref( 'konsole.title' )           )
    :clr                        ( Color( 255, 255, 255, self.Alpha ) )

                                :draw ( function( s, w, h )
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

                                    local clr_rgb = Color( r, g, b, self.Alpha )

                                    draw.SimpleText( utf8.char( 9930 ), pref( 'konsole.icon' ), 0, 8, clr_rgb, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
                                    draw.SimpleText( lang( 'konsole_settings' ), pref( 'konsole.title' ), 25, h / 2, Color( 237, 237, 237, self.Alpha ), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
                                end )

    /*
    *   close button
    *
    *   to overwrite existing properties from the skin; do not change this buttons name to anything other 
    *   than btnClose otherwise it wont inherit position/size properties
    */

    self.btnClose               = ui.new( 'btn', self               )
    :bsetup                     (                                   )
    :notext                     (                                   )
    :tip                        ( lang( 'ui_tip_close' )            )
    :onclick_r                  ( self                              )

                                :draw ( function( s, w, h )
                                    local clr_txt = s.hover and Color( 200, 55, 55, self.Alpha ) or Color( 237, 237, 237, self.Alpha )
                                    draw.SimpleText( helper.get:utf8( 'close' ), pref( 'konsole.ico' ), w / 2, h / 2 + 4, clr_txt, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
                                end )

    /*
    *   subparent pnl
    */

    self.sub                    = ui.new( 'pnl', self               )
    :nodraw                     (                                   )
    :static                     ( FILL                              )
    :margin                     ( 0, 10, 0                          )

    /*
    *   body
    */

    self.body                   = ui.new( 'pnl', self.sub           )
    :nodraw                     (                                   )
    :static                     ( FILL                              )

    /*
    *   body :: scroll panel
    */

    self.dsp_ctl_content        = ui.new( 'rlib.ui.scrollpanel', self.body )
    :static                     ( FILL                              )


    local pl_settings = { }

    /*
    *   populate settings
    */

    if istable( ui.cvars ) then
        for k, v in helper:sortedkeys( ui.cvars ) do
            pl_settings[ #pl_settings + 1 ] = v
        end

        table.sort( pl_settings, function( r1, r2 ) return r1.sid < r2.sid end )

        for k, v in pairs( pl_settings ) do
            if base._def.elements_ignore[ v.stype ] then continue end
            base.cvar:setup( v.stype, v.id, v.default, v.values, v.forceset, v.desc )
        end
    end

    for k, v in pairs( pl_settings ) do

        if not v.is_visible then continue end

        local cfg_type      = v.stype
        local cfg_id        = tostring( k )

        /*
        *   type checkbox
        */

        if cfg_type == 'checkbox' then
            local gcvar                 = GetConVar( v.id )

            self.item                   = ui.new( 'pnl', self.dsp_ctl_content )
            :nodraw                     (                                   )
            :static                     ( TOP                               )
            :margin                     ( 12, 5, 12, 0                      )
            :tall                       ( 20                                )

            self.l_name                 = ui.new( 'lbl', self.item          )
            :nodraw                     (                                   )
            :static                     ( FILL                              )
            :margin                     ( 0                                 )
            :font                       ( pref( 'konsole.chkb.label' )      )
            :text                       ( v.name                            )
            :autosize                   (                                   )

            self.togg                   = ui.new( 'rlib.ui.toggle', self.item )
            :static                     ( RIGHT                             )
            :var                        ( 'enabled', gcvar:GetBool( ) or false )

                                        :ooc( function( s )
                                            gcvar:SetBool( s.enabled )
                                        end )
        end

    end

end

/*
*   GetTitle
*
*   @return : str
*/

function PANEL:GetTitle( )
    return self.lblTitle:GetText( )
end

/*
*   SetTitle
*
*   @param  : str title
*/

function PANEL:SetTitle( title )
    self.lblTitle:SetText( title )
end

/*
*   Think
*/

function PANEL:Think( )
    self.BaseClass.Think( self )
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
    design.rbox( 4, 0, 0, w, h, Color( 45, 45, 45, self.Alpha ) )
    design.rbox_adv( 4, 2, 2, w - 4, 34 - 4, Color( 36, 36, 36, self.Alpha ), true, true, false, false )
end

/*
*   register
*/

vgui.Register( 'rlib.lo.konsole.cfg', PANEL, 'DFrame' )

/*
*   panel
*/

local PANEL = { }

/*
*   initialize
*/

function PANEL:Init( )

    self.name                   = ''
    self.ply                    = nil
    self.clr                    = nil
    self.fade_reversed          = false
    self.fade_expired           = false
    self.fade_timer             = CurTime( ) + ( cfg.konsole.fadetime or 7 )

    self:SetSize                ( self:GetParent( ):GetWide( ), 10  )
    self:Dock                   ( TOP                               )
    self:DockMargin             ( 5, 0, 5, 0                        )
    self:LerpPositions          ( 1, true                           )
    self:SetAlpha               ( 0                                 )
    self:AlphaTo                ( 255, 0.7                          )

    self.resp                   = ui.new( 'rtxt', self              )
    :pos                        ( 0, 0                              )
    :wide                       ( self:GetParent( ):GetWide( ) - 10 )
    :appendclr                  ( 255, 255, 255, 255                )

end

/*
*   paint
*
*   @param  : int w
*   @param  : int h
*/

function PANEL:Paint( w, h ) end

/*
*   preform layout
*/

function PANEL:PerformLayout( )
    self.resp:SetFontInternal               ( pref( 'konsole.text' ) )
    self.resp:SetVerticalScrollbarEnabled   ( false )
    self.resp:SetToFullHeight               ( )
    self.resp:SetWide                       ( self:GetParent( ):GetWide( ) - 64 )

    self:SizeToChildren                     ( false, true )
    self:InvalidateParent                   ( )
end

/*
*   think
*/

function PANEL:Think( )
    if konsole.pnl.is_visible then
        self.fade_reversed = false
    else
        self.fade_reversed = true
    end

    if self.fade_reversed then
        if self.fade_expired then
            self:SetAlpha( 0 )
            return false
        end

        if ( self.fade_timer and self.fade_timer <= CurTime( ) ) then
            self:AlphaTo( 0, 1.5, 0, function( ) self.fade_expired = true end )
        end
    else
        self:SetAlpha( 255 )
    end
end

/*
*   handle setup
*/

function PANEL:HandleSetup( cat, data, bVarg )
    if helper:cvar_bool( 'console_timestamps' ) then
        self.resp:InsertColorChange( 215, 215, 215, 255 )
        self.resp:AppendText( '[' .. cfg.konsole.ts_format .. '] ' )
    end

    if bVarg then
        if cat and cat > 0 then
            local data_cat      = '[' .. helper.str:ucfirst( base._def.debug_titles[ cat ] ) .. '] '
            local data_clr      = base._def.lc_rgb[ cat ]

            self.resp:InsertColorChange ( data_clr.r, data_clr.g, data_clr.b, 255 )
            self.resp:AppendText        ( data_cat )
            self.resp:InsertColorChange ( 255, 255, 255, 255 )
        end

        self.resp:InsertColorChange     ( 255, 255, 255, 255 )
        self.resp:AppendText            ( data )
        return
    end

    for k, v in ipairs( data ) do
        if cat and cat > 0 then
            local data_cat      = '[' .. helper.str:ucfirst( base._def.debug_titles[ cat ] ) .. '] '
            local data_clr      = base._def.lc_rgb[ cat ]

            self.resp:InsertColorChange ( data_clr.r, data_clr.g, data_clr.b, 255 )
            self.resp:AppendText        ( data_cat )
            self.resp:InsertColorChange ( 255, 255, 255, 255 )
        end

        if IsColor( v ) then
            local data_clr = v
            self.resp:InsertColorChange( data_clr.r, data_clr.g, data_clr.b, data_clr.a )
        elseif isstring( v ) then
            self.resp:AppendText( v )
        end
    end

    if not IsValid( self.ply ) then
        self.clr = Color( 255, 255, 255, 255 )
        self:InvalidateLayout( )
    end
end

/*
*   register
*/

vgui.Register( 'rlib.lo.konsole.entry', PANEL, 'DPanel' )