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
local cfg                   = base.settings
local helper                = base.h
local design                = base.d
local ui                    = base.i
local cvar                  = base.v

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
    local pnl_w, pnl_h          = 500, 200
    local ui_w, ui_h            = sc_w * pnl_w, sc_h * pnl_h
    local min_sz                = 0.85

    /*
    *   localized colorization
    */

    local clr_cur               = Color( 200, 200, 200, self.Alpha )
    local clr_text              = Color( 255, 255, 255, self.Alpha )
    local clr_hl                = Color( 25, 25, 25, self.Alpha )

    /*
    *   parent pnl
    */

    self:SetPaintShadow         ( true                          )
    self:SetSize                ( ui_w, ui_h                    )
    self:SetMinWidth            ( ui_w * min_sz                 )
    self:SetMinHeight           ( ui_h * min_sz                 )
    self:MakePopup              (                               )
    self:SetTitle               ( ''                            )
    self:ShowCloseButton        ( false                         )
    self:DockPadding            ( 2, 34, 2, 3                   )

    /*
    *   localized declarations
    */

    self.bIsPopulated           = false
    self.bNoFocus               = false

    /*
    *   display parent :: static || animated
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
    :font                       ( pref( 'lang_title' )          )
    :clr                        ( Color( 255, 255, 255, 255 )   )

                                :draw( function( s, w, h )
                                    if not self.title or self.title == '' then return end
                                    draw.SimpleText( utf8.char( 9930 ), pref( 'lang_icon' ), 0, 8, Color( 240, 72, 133, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
                                    draw.SimpleText( self.title, pref( 'lang_title' ), 25, h / 2, Color( 237, 237, 237, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
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
                                    draw.SimpleText( helper.get:utf8( 'close' ), pref( 'lang_close' ), w / 2, h / 2 + 4, clr_txt, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
                                end )

    /*
    *   subparent pnl
    */

    self.p_subparent            = ui.new( 'pnl', self               )
    :nodraw                     (                                   )
    :static                     ( FILL                              )
    :margin                     ( 0, 10, 0, 0                       )

    /*
    *   body
    */

    self.p_body                 = ui.new( 'pnl', self.p_subparent   )
    :nodraw                     (                                   )
    :static                     ( FILL                              )
    :margin                     ( 10, 5, 10, 5                      )

    /*
    *   dtxt_desc
    */

    self.dtxt_desc              = ui.new( 'entry', self.p_body      )
    :static		                ( TOP 					            )
    :padding		            ( 3, 3, 3, 3 			            )
    :tall                       ( 60                                )
    :drawbg                     ( false                             )
    :mline	                    ( true 				                )
    :canedit                    ( true                              )
    :scur	                    ( Color( 255, 255, 255, 255 ), 'beam' )
    :txt	                    ( lang( 'lang_sel_desc' ), Color( 255, 255, 255, 255 ), pref( 'lang_desc' ) )
    :drawentry                  ( clr_text, clr_cur, clr_hl         )

    /*
    *   dcbox :: languages
    */

    self.dcb_combine            = ui.new( 'cbo', self.p_body        )
    :static		                ( TOP 					            )
    :margin		                ( 0, 3, 0, 3 			            )
    :tall                       ( 24                                )
    :value                      ( cvar:GetStr( 'rlib_language' )    )
    :font                       ( pref( 'lang_item' )               )

                                :draw( function( s, w, h )
                                    design.rbox( 4, 0, 0, w, h, Color( 67, 67, 67, 255 ) )

                                    local clr_box = Color( 20, 20, 20, 255 )
                                    design.rbox( 4, 1, 1, w - 2, h - 2, clr_box )

                                    s:SetTextColor( Color( 255, 255, 255, 255 ) )
                                    s:SetTextInset( 10, 0 )
                                end )

    /*
    *   dcbox :: populate values
    *
    *   will display all available languages based on the translations provided
    *   only shows the language itself, which is only valid if in a table structure
    */

    local sel_langs = { }
    for k, v in SortedPairs( rcore.modules, false ) do
        if not v.language then continue end
        for t, l in SortedPairs( v.language, false ) do
            if not istable( l ) then continue end
            sel_langs[ t ] = t
        end
    end

    for i in helper.get.data( sel_langs ) do
        self.dcb_combine:AddChoice( i, i )
    end

    /*
    *   dcbox :: set cvar id
    */

    self.dcb_combine.convarname = 'rlib_language'
    self.dcb_combine.OnSelect = function( s, index, value, data )
        data = data ~= nil and data or 'en'
        local getcvar = GetConVar( s.convarname )
        getcvar:SetString( data )
    end

    /*
    *   dcbox :: doclick
    */

    self.dcb_combine.DoClick = function( s )
        if s:IsMenuOpen( ) then return s:CloseMenu( ) end
        s:OpenMenu( )

        for pnl in helper.get.data( s.Menu:GetCanvas( ):GetChildren( ) ) do
            function pnl:Paint( w, h )
                local col1 = Color( 25, 25, 25, 255 )
                design.box( 0, 0, w, h, col1 )
            end
        end
    end

    /*
    *   dcbox :: action :: openmenu
    */

    self.dcb_combine.OpenMenu = function( s, pControlOpener )
        if ( pControlOpener and pControlOpener == self.TextEntry ) then return end
        if ( #s.Choices == 0 ) then return end

        if ui:valid( s.Menu ) then
            s.Menu:Remove( )
            s.Menu = nil
        end

        s.Menu = DermaMenu( false, s )

        /*
        *   sort all combo options and add to list
        */

        local sorted = { }
        for k, v in pairs( s.Choices ) do table.insert( sorted, { id = k, data = v } ) end
        for k, v in SortedPairsByMemberValue( sorted, 'data' ) do
            local p = s.Menu:AddOption( v.data, function( ) s:ChooseOption( v.data, v.id ) end )
            p:SetFont( s:GetFont( ) )
            p:SetTextColor( Color( 255, 255, 255, 255 ) )
            p:SetTextInset( 10, 1 )
        end

        local x, y = s:LocalToScreen( 0, s:GetTall( ) )

        s.Menu:SetMinimumWidth( s:GetWide( ) )
        s.Menu:Open( x, y, false, s )
    end

end

/*
*   Think
*/

function PANEL:Think( )
    self.BaseClass.Think( self )

    /*
    *   check focus and react accordingly
    *   if console is open and interface doesnt have focus, mouse cursor can disappear and make the
    *   activating player stuck. setting populated false will wait for dialog to have focus again and
    *   then make cursor re-appear
    */

    if input.IsKeyDown( KEY_ESCAPE ) or gui.IsGameUIVisible( ) then
        self.bIsPopulated = false
        self:ActionHide( )
        return
    end

    /*
    *   initial population
    */

    if not self.bIsPopulated then
        self:ActionShow( )
        self.bIsPopulated = true
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
*/

function PANEL:Paint( w, h )
    design.rbox( 4, 0, 0, w, h, Color( 40, 40, 40, 255 ) )
    design.rbox_adv( 4, 2, 2, w - 4, 34 - 4, Color( 30, 30, 30, 255 ), true, true, false, false )
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
*/

function PANEL:GetTitle( )
    return self.title
end

/*
*   SetTitle
*/

function PANEL:SetTitle( strTitle )
    self.lblTitle:SetText( '' )
    self.title = strTitle
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
        self:ActionShow( )
    else
        ui:hide( self, true )
        self:ActionHide( )
    end
end

/*
*   register
*/

vgui.Register( 'rlib.lo.language', PANEL, 'DFrame' )