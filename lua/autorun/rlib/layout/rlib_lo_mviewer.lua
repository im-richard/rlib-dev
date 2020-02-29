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
local sf                    = string.format

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
*   interface settings storage
*/

local cvar_settings =
{
    { id = 'rlib_mviewer_banim',        name = 'Rotate Animation',  desc = 'enable/disable model rotating',     type = 'checkbox',  default = 0,    values = { } },
    { id = 'rlib_mviewer_fov',          name = 'Field of View',     desc = 'Field of view',                     type = 'slider',    default = 100,  values = { },   min = 0,        max = 180 },
    { id = 'rlib_mviewer_campos_x',     name = 'campos x',          desc = 'Camera pos x',                      type = 'slider',    default = 100,  values = { },   min = -1000,    max = 1000 },
    { id = 'rlib_mviewer_campos_y',     name = 'campos y',          desc = 'Camera pos y',                      type = 'slider',    default = 0,    values = { },   min = -1000,    max = 1000 },
    { id = 'rlib_mviewer_campos_z',     name = 'campos z',          desc = 'Camera pos z',                      type = 'slider',    default = 0,    values = { },   min = -1000,    max = 1000 },
    { id = 'rlib_mviewer_lookat_x',     name = 'lookat x',          desc = 'Lookat pos x',                      type = 'slider',    default = 0,    values = { },   min = -1000,    max = 1000 },
    { id = 'rlib_mviewer_lookat_y',     name = 'lookat y',          desc = 'Lookat pos y',                      type = 'slider',    default = 0,    values = { },   min = -1000,    max = 1000 },
    { id = 'rlib_mviewer_lookat_z',     name = 'lookat z',          desc = 'Lookat pos z',                      type = 'slider',    default = 40,   values = { },   min = -1000,    max = 1000 },
}

/*
*   cycle setup convars
*/

local function setup_convars( )
    for k, v in pairs( cvar_settings ) do
        base.cvar:setup( v.type, v.id, v.default, v.values )
    end
end
setup_convars( )

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
    local pnl_w, pnl_h          = cfg.mviewer.ui.width, cfg.mviewer.ui.height
    local ui_w, ui_h            = sc_w * pnl_w, sc_h * pnl_h
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
    *   bIsValidOnly
    *
    *   utilizes util.IsValidModel
    *
    *   if turned on, however this is extremely unreliable for detecting a valid model due to the 
    *   restrictions it has. it is recommended to keep this off unless you need to see if the game sees 
    *   a particular model as valid
    *
    *   A model is considered invalid in following cases:
    *       : Starts with a space or maps
    *       : Doesn't start with models
    *       : On server: If the model isn't precached, if the model file doesn't exist on the disk
    *       : If precache failed
    *       : Model is the error model
    *       : Contains any of the following:
    *           - _gestures
    *           - _animations
    *           - _postures
    *           - _gst
    *           - _pst
    *           - _shd
    *           - _ss
    *           - _anm
    *           - .bsp
    *           - cs_fix
    *
    */

    self.bIsValidOnly = false

    /*
    *   default mdl if nothing searched
    */

    self.mdl_default = 'models/props_interiors/VendingMachineSoda01a.mdl'

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
    :font                       ( pref( 'mviewer.title' )       )
    :clr                        ( Color( 255, 255, 255, 255 )   )

                                :draw( function( s, w, h )
                                    if not self.title or self.title == '' then self.title = 'model viewer' end
                                    draw.SimpleText( utf8.char( 9930 ), pref( 'mviewer.icon' ), 0, 8, Color( 240, 72, 133, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
                                    draw.SimpleText( self.title, pref( 'mviewer.title' ), 25, h / 2, Color( 237, 237, 237, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
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
                                    draw.SimpleText( '-', pref( 'mviewer.exit' ), w / 2, h / 2 + 4, clr_txt, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
                                end )

    /*
    *   header pnl
    */

    self.p_header               = ui.new( 'pnl', self               )
    :static                     ( TOP                               )
    :margin                     ( 0                                 )
    :tall                       ( 60                                )

                                :draw( function( s, w, h )
                                    design.rbox( 0, 0, 0, w, h, Color( 34, 34, 34, 255 ) )
                                    design.box( 0, h - 1, w, 2, Color( 50, 50, 50, 255 ) )
                                    if not self.title or self.title == '' then self.title = 'model viewer' end

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

                                    draw.SimpleText( self.title, pref( 'mviewer.name' ), w / 2, h / 2, clr_rgb, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
                                end )

    /*
    *   subparent pnl
    */

    self.p_subparent            = ui.new( 'pnl', self               )
    :nodraw                     (                                   )
    :static                     ( FILL                              )
    :margin                     ( 10                                )

    /*
    *   dmodel
    */

    self.p_model                = ui.new( 'mdl', self.p_subparent   )
    :static                     ( FILL                              )
    :mdl                        ( self.mdl_default                  )

                                :le( function( ent, s )
                                    if not helper:cvar_bool( 'rlib_mviewer_banim' ) then
                                        s:SetAngles( Angle( 0, 0, 0 ) )
                                        return
                                    end
                                    if ( self.p_model.bAnimated ) then
                                        self.p_model:RunAnimation( )
                                    end

                                    s:SetAngles( Angle( 0, RealTime( ) * 10 % 360, 0 ) )
                                end )

                                :logic( function( s )
                                    if s:GetModel( ) == self.mdl_default then
                                        s:SetFOV( 62 )
                                        s:SetCamPos( Vector( 187, -107, 93 ) )
                                        s:SetLookAt( Vector( 20, 13, 13 ) )
                                        return
                                    end
                                    s:SetFOV( helper:cvar_int( 'rlib_mviewer_fov' ) )
                                    s:SetCamPos( Vector( helper:cvar_int( 'rlib_mviewer_campos_x' ), helper:cvar_int( 'rlib_mviewer_campos_y' ), helper:cvar_int( 'rlib_mviewer_campos_z' ) ) )
                                    s:SetLookAt( Vector( helper:cvar_int( 'rlib_mviewer_lookat_x' ), helper:cvar_int( 'rlib_mviewer_lookat_y' ), helper:cvar_int( 'rlib_mviewer_lookat_z' ) ) )
                                end )

                                :po( function( s, w, h )
                                    local pos_x, pos_y, pos_z       = helper:cvar_int( 'rlib_mviewer_campos_x' ), helper:cvar_int( 'rlib_mviewer_campos_y' ), helper:cvar_int( 'rlib_mviewer_campos_z' )
                                    local look_x, look_y, look_z    = helper:cvar_int( 'rlib_mviewer_lookat_x' ), helper:cvar_int( 'rlib_mviewer_lookat_y' ), helper:cvar_int( 'rlib_mviewer_lookat_z' )
                                    local fov, bAnim                = helper:cvar_int( 'rlib_mviewer_fov' ), helper:cvar_bool( 'rlib_mviewer_banim' ) and 'ON' or 'OFF'
                                    local bValidOnly                = self.bIsValidOnly and 'ON' or 'OFF'
                                    local getmodel                  = self.p_model:GetModel( ) and tostring( self.p_model:GetModel( ) ) or ''
                                    local modelpath                 = ( self.bIsValidOnly and util.IsValidModel( getmodel ) and getmodel ) or ( not self.bIsValidOnly and getmodel ) or getmodel or 'invalid model path'

                                    local clr_label                 = Color( 200, 200, 200, 255 )
                                    local clr_value                 = Color( 93, 180, 255, 255 )

                                    local w_sz, h_sz = w, h
                                    draw.TexturedQuad { texture = surface.GetTextureID( helper._mat[ 'grad_up' ] ), color = Color( 0, 0, 0, 200 ), x = 0, y = h_sz - 100, w = w_sz, h = 100 }

                                    -- stats :: top left :: labels
                                    draw.SimpleText( 'cam', pref( 'mviewer.minfo' ), 55, 10, clr_label, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER )
                                    draw.SimpleText( 'lookat', pref( 'mviewer.minfo' ), 55, 30, clr_label, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER )
                                    draw.SimpleText( 'fov', pref( 'mviewer.minfo' ), 55, 50, clr_label, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER )

                                    -- stats :: top left :: values
                                    draw.SimpleText( sf( '%sx %sy %sz', pos_x, pos_y, pos_z ), pref( 'mviewer.minfo' ), 80, 10, clr_value, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
                                    draw.SimpleText( sf( '%sx %sy %sz', look_x, look_y, look_z ), pref( 'mviewer.minfo' ), 80, 30, clr_value, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
                                    draw.SimpleText( sf( '%s', fov ), pref( 'mviewer.minfo' ), 80, 50, clr_value, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )

                                    -- stats :: top right :: labels
                                    draw.SimpleText( 'Animations', pref( 'mviewer.minfo' ), w - 105, 10, clr_label, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER )
                                    draw.SimpleText( 'Show valid only', pref( 'mviewer.minfo' ), w - 105, 30, clr_label, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER )

                                    -- stats :: top right :: values
                                    draw.SimpleText( sf( '%s', bAnim ), pref( 'mviewer.minfo' ), w - 55, 10, clr_value, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER )
                                    draw.SimpleText( sf( '%s', bValidOnly ), pref( 'mviewer.minfo' ), w - 55, 30, clr_value, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER )

                                    -- stats :: bottom left :: file path
                                    draw.SimpleText( 'file', pref( 'mviewer.minfo' ), 25, h - 12, clr_label, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER )
                                    draw.SimpleText( sf( '%s', modelpath ), pref( 'mviewer.minfo' ), 50, h - 12, clr_value, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
                                end )

    /*
    *   controls pnl
    */

    self.p_ctrls                = ui.new( 'pnl', self               )
    :static                     ( BOTTOM                            )
    :margin                     ( 8                                 )
    :tall                       ( ui_h * 0.27                       )

                                :draw( function( s, w, h )
                                    design.rbox_adv( 4, 2, 2, w - 4, h - 4, Color( 36, 36, 36, 255 ), true, true, false, false )
                                end )

    /*
    *   btm block
    */

    self.p_block_btm            = ui.new( 'pnl', self.p_ctrls       )
    :static                     ( TOP                               )
    :tall                       ( 35                                )

                                :draw( function( s, w, h )
                                    design.rbox( 4, 2, 2, w - 4, h - 4, Color( 31, 31, 31, 255 ) )
                                end )

    /*
    *   search box
    */

    self.dt_searchbox           = ui.new( 'entry', self.p_block_btm )
    :static		                ( FILL 					            )
    :margin		                ( 10, 5, 4, 5 			            )
    :mline	                    ( false 				            )
    :textclr                    ( Color( 255, 255, 255, 255 )       )
    :scur	                    ( Color( 255, 255, 255, 255 ), 'beam' )
    :enabled                    ( true                              )
    :allowascii                 ( false                             )
    :canedit                    ( true                              )
    :autoupdate	                ( true 					            )
    :txt	                    ( 'Search', Color( 255, 255, 255, 255 ), pref( 'mviewer.searchbox' ) )
    :drawentry                  ( clr_text, clr_cur, clr_hl         )
    :ocnf                       ( true                              )

                                :onenter( function( s )
                                    local val = s:GetValue( )
                                    val = helper.str:clean_ws( val )
                                    if ui:valid( self.p_model ) then
                                        if self.bIsValidOnly and util.IsValidModel( self.p_model:GetModel( ) ) or not self.bIsValidOnly then
                                            self.p_model:SetModel( val )
                                        else
                                            self.p_model:SetModel( self.mdl_default )
                                        end
                                    end
                                end )

                                :ongetfocus( function( s )
                                    if s:GetValue( ) == 'Search' then
                                        s:SetValue( '' )
                                    end
                                end )

    /*
    *   search box :: clear text
    */

    self.b_searchclr = vgui.Create( 'DButton', self.dt_searchbox )
    self.b_searchclr:Dock( RIGHT )
    self.b_searchclr:DockMargin( 0, 3, 5, 3 )
    self.b_searchclr:SetText( '' )
    self.b_searchclr:SetWide( 21 )
    self.b_searchclr:SetTooltip( 'clear text' )
    self.b_searchclr.OnCursorEntered = function( s ) s.hover = true end
    self.b_searchclr.OnCursorExited = function( s ) s.hover = false end
    self.b_searchclr.Paint = function( s, w, h )
        design.rbox( 6, 0, 0, w, h, Color( 200, 55, 55, 255 ) )
        if s.hover then
            design.rbox( 6, 0, 0, w, h, Color( 15, 15, 15, 100 ) )
        end
        draw.SimpleText( 'x', pref( 'mviewer.clear' ), w / 2, h / 2 - 2, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    self.b_searchclr.DoClick = function( s )
        s:GetParent( ):SetValue( self.mdl_default )
    end

    self.b_submit = vgui.Create( 'DButton', self.dt_searchbox )
    self.b_submit:Dock( RIGHT )
    self.b_submit:DockMargin( 0, 3, 5, 3 )
    self.b_submit:SetText( '' )
    self.b_submit:SetWide( 21 )
    self.b_submit:SetTooltip( 'search' )
    self.b_submit.OnCursorEntered = function( s ) s.hover = true end
    self.b_submit.OnCursorExited = function( s ) s.hover = false end
    self.b_submit.Paint = function( s, w, h )
        design.rbox( 6, 0, 0, w, h, Color( 70, 140, 84, 255 ) )
        if s.hover then
            design.rbox( 6, 0, 0, w, h, Color( 15, 15, 15, 100 ) )
        end
        draw.SimpleText( '>', pref( 'mviewer.enter' ), w / 2, h / 2 - 2, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    self.b_submit.DoClick = function( s )
        local val = self.dt_searchbox:GetValue( )
        val = helper.str:clean_ws( val )
        if ui:valid( self.p_model ) then
            if self.bIsValidOnly and util.IsValidModel( self.p_model:GetModel( ) ) or not self.bIsValidOnly then
                self.p_model:SetModel( val )
            else
                self.p_model:SetModel( self.mdl_default )
            end
        end
    end

    /*
    *   scroll pnl
    */

    self.dsp = vgui.Create( 'DScrollPanel', self.p_ctrls )
    self.dsp:Dock( FILL )
    self.dsp:DockMargin( 5, 5, 5, 5 )
    self.dsp.Paint = function( s, w, h ) end

    /*
    *   scroll bar
    */

    self.vbar = self.dsp:GetVBar( )
    self.vbar:Dock( RIGHT )
    self.vbar:DockMargin( 0, 0, 0, 0 )
    self.vbar:SetWide( 5 )
    self.vbar.Paint = function( s, w, h )
        design.box( 0, 0, w, h, Color( 0, 0, 0, 100 ) )
    end
    self.vbar.btnUp.Paint = function( s, w, h ) end
    self.vbar.btnDown.Paint = function( s, w, h ) end
    self.vbar.btnGrip.Paint = function( s, w, h )
        design.box( 0, 0, w, h, Color( 255, 106, 93, 190 ) )
    end

    for k, v in pairs( cvar_settings ) do

        local dtype 	= v.type
        local dname		= tostring( k )
        local dcvar		= GetConVar( v.id )

        self.p_block = vgui.Create( 'DPanel', self.dsp )
        self.p_block:Dock( TOP )
        self.p_block:DockMargin( 5, 2, 20, 2 )
        self.p_block.Paint = function( s, w, h )
            design.box( 5, h - 1, w, 1, Color( 44, 44, 44, 255 ) )
        end

        if dtype == 'slider' then
            self.l_name = vgui.Create( 'DLabel', self.p_block )
            self.l_name:Dock( LEFT )
            self.l_name:DockMargin( 15, 0, 0, 5 )
            self.l_name:SetFont( pref( 'mviewer.control' ) )
            self.l_name:SetTextColor( Color( 255, 255, 255, 255 ) )
            self.l_name:SetText( v.desc )
            self.l_name:SizeToContents( )
            self.l_name.Paint = function( s, w, h ) end

            self.p_block_r = vgui.Create( 'DPanel', self.p_block )
            self.p_block_r:Dock( FILL )
            self.p_block_r:DockMargin( 5, 0, 20, 0 )
            self.p_block_r:SetWide( 300 )
            self.p_block_r.Paint = function( s, w, h ) end

            self.ui_elem = vgui.Create( 'rlib.ui.slider', self.p_block_r )
            self.ui_elem:Dock( RIGHT )
            self.ui_elem:DockMargin( 0, 0, 0, 4 )
            self.ui_elem:SetWide( 300 )
            self.ui_elem:SetMin( v.min )
            self.ui_elem:SetMax( v.max )
            self.ui_elem:SetValue( dcvar:GetFloat( ) )
            self.ui_elem:SetKnobColor( Color( 51, 169, 74 ) )
            self.ui_elem.convarname = dcvar
            self.ui_elem.OnValueChanged = function( s )
                dcvar:SetInt( s:GetValue( ) )
            end
        end

        if dtype == 'checkbox' then
            local getcvar = GetConVar( v.id )

            self.p_block_cont = vgui.Create( 'DPanel', self.p_block )
            self.p_block_cont:Dock( FILL )
            self.p_block_cont:DockPadding( 0, 0, 0, 5 )
            self.p_block_cont.Paint = function( s, w, h ) end

            self.l_name = vgui.Create( 'DLabel', self.p_block_cont )
            self.l_name:Dock( FILL )
            self.l_name:DockMargin( 15, 0, 0, 0 )
            self.l_name:SetFont( pref( 'mviewer.control' ) )
            self.l_name:SetTextColor( Color( 255, 255, 255, 255 ) )
            self.l_name:SetText( v.name )
            self.l_name:SizeToContents( )

            self.p_block_r = vgui.Create( 'DPanel', self.p_block_cont )
            self.p_block_r:Dock( FILL )
            self.p_block_r:DockMargin( 5, 0, 20, 0 )
            self.p_block_r:SizeToContents( )
            self.p_block_r.Paint = function( s, w, h ) end

            local tog_option = vgui.Create( 'rlib.ui.toggle', self.p_block_r )
            tog_option:Dock( RIGHT )
            tog_option:DockMargin( 0, 0, 0, 0 )
            tog_option.enabled = getcvar:GetBool( ) or false
            tog_option.onOptionChanged = function( s )
                getcvar:SetBool( tog_option.enabled )
            end
        end

    end

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
    design.rbox( 4, 0, 0, w, h, Color( 40, 40, 40, 255 ) )
    design.rbox_adv( 0, 0, 0, w, 34, Color( 30, 30, 30, 255 ), true, true, false, false )

    -- resizing arrow
    draw.SimpleText( utf8.char( 9698 ), pref( 'mviewer.resizer' ), w - 3, h - 7, Color( 240, 72, 133, 255 ), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER )
    draw.SimpleText( utf8.char( 9698 ), pref( 'mviewer.resizer' ), w - 5, h - 9, Color( 40, 40, 40, 255 ), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER )
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
*   GetRequireValidation
*/

function PANEL:GetbValidOnly( )
    return self.bIsValidOnly
end

/*
*   SetTitle
*
*   @param  : bool bBoolean
*/

function PANEL:bValidOnly( bBoolean )
    self.bIsValidOnly = bBoolean
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

vgui.Register( 'rlib.lo.mviewer', PANEL, 'DFrame' )