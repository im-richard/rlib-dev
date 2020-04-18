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

rlib                    = rlib or { }
local base              = rlib
local mf                = base.manifest

/*
*   Localized rlib routes
*/

local surface           = surface
local reg_font          = surface.CreateFont

/*
*   Localized cmd func
*
*   @source : lua\autorun\libs\calls
*   @param  : str t
*   @param  : varg { ... }
*/

local function call( t, ... )
    return rlib:call( t, ... )
end

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
*   fonts :: core
*/

reg_font( pref( 'sys_entry_default' ),                  { size = 16, weight = 400, antialias = true, font = 'Roboto Light' } )
reg_font( pref( 'sys_text_default' ),                   { size = 16, weight = 100, antialias = true, shadow = false, font = 'Roboto Light' } )
reg_font( pref( 'sys_rsay_text' ),                      { size = 30, weight = 100, antialias = true, shadow = true, font = 'Roboto Light' } )
reg_font( pref( 'sys_rsay_text_sub' ),                  { size = 20, weight = 100, antialias = true, shadow = true, font = 'Roboto Light' } )
reg_font( pref( 'sys_hud_indicator' ),                  { size = 22, weight = 400, antialias = true, shadow = true, font = 'Roboto Light' } )
reg_font( pref( 'sys_hud_s2_indicator' ),               { size = 40, weight = 400, antialias = true, shadow = true, font = 'Roboto Light' } )
reg_font( pref( 'sys_hud_s2_indicator_sub' ),           { size = 70, weight = 800, antialias = true, shadow = true, font = 'Roboto' } )
reg_font( pref( 'sys_draw_textscroll' ),                { size = 14, weight = 100, antialias = true, shadow = true, font = 'Roboto Light' } )
reg_font( pref( 'sys_dialog_title' ),	                { size = 36, weight = 100, antialias = true, shadow = true, font = 'Roboto Light' } )
reg_font( pref( 'sys_dialog_msg' ),		                { size = 20, weight = 100, antialias = true, shadow = false, font = 'Roboto' } )
reg_font( pref( 'sys_dialog_qclose' ),	                { size = 16, weight = 100, antialias = true, shadow = true, font = 'Roboto Light' } )
reg_font( pref( 'sys_dialog_slider_title' ),            { size = 23, weight = 100, antialias = true, shadow = true, font = 'Roboto Light' } )
reg_font( pref( 'sys_dialog_slider_msg' ),              { size = 17, weight = 300, antialias = true, shadow = true, font = 'Roboto' } )
reg_font( pref( 'sys_dialog_slider_exit' ),             { size = 42, weight = 800, antialias = true, shadow = false, font = 'Segoe UI Light' } )
reg_font( pref( 'sys_bubble_msg' ),                     { size = 19, weight = 400, antialias = true, shadow = true, font = 'Roboto Condensed' } )
reg_font( pref( 'sys_bubble_ico' ),                     { size = 48, weight = 400, antialias = true, shadow = true, font = 'Roboto Condensed' } )
reg_font( pref( 'sys_notify_text' ),                    { size = 18, weight = 400, antialias = true, shadow = false, font = 'Roboto Light' } )
reg_font( pref( 'sys_tippy_text' ),                     { size = 15, weight = 200, antialias = true, shadow = false, font = 'Roboto Light' } )

/*
*    fonts :: interface :: about
*/

reg_font( pref( 'about_exit' ),                         { size = 24, weight = 800, antialias = true, font = 'Roboto' } )
reg_font( pref( 'about_resizer' ),                      { size = 24, weight = 100, antialias = true, font = 'Roboto Light' } )
reg_font( pref( 'about_icon' ),                         { size = 24, weight = 100, antialias = true, font = 'Roboto Light' } )
reg_font( pref( 'about_name' ),                         { size = 44, weight = 100, antialias = true, font = 'Roboto Light' } )
reg_font( pref( 'about_title' ),                        { size = 16, weight = 600, antialias = true, font = 'Roboto Light' } )
reg_font( pref( 'about_entry' ),                        { size = 15, weight = 300, antialias = true, font = 'Roboto' } )
reg_font( pref( 'about_entry_label' ),                  { size = 14, weight = 800, antialias = true, font = 'Roboto' } )
reg_font( pref( 'about_entry_value' ),                  { size = 16, weight = 200, antialias = true, font = 'Roboto Light' } )
reg_font( pref( 'about_status' ),                       { size = 14, weight = 800, antialias = true, font = 'Roboto' } )
reg_font( pref( 'about_status_conn' ),                  { size = 14, weight = 400, antialias = true, font = 'Roboto' } )

/*
*    fonts :: interface :: rcfg
*/

reg_font( pref( 'rcfg_exit' ),                          { size = 36, weight = 800, antialias = true, font = 'Roboto Light' } )
reg_font( pref( 'rcfg_resizer' ),                       { size = 24, weight = 100, antialias = true, font = 'Roboto Light' } )
reg_font( pref( 'rcfg_icon' ),                          { size = 24, weight = 100, antialias = true, font = 'Roboto Light' } )
reg_font( pref( 'rcfg_name' ),                          { size = 40, weight = 100, antialias = true, font = 'Segoe UI Light' } )
reg_font( pref( 'rcfg_sub' ),                           { size = 16, weight = 100, antialias = true, font = 'Roboto Light' } )
reg_font( pref( 'rcfg_title' ),                         { size = 16, weight = 600, antialias = true, font = 'Roboto Light' } )
reg_font( pref( 'rcfg_entry' ),                         { size = 15, weight = 300, antialias = true, font = 'Roboto' } )
reg_font( pref( 'rcfg_status' ),                        { size = 14, weight = 800, antialias = true, font = 'Roboto' } )
reg_font( pref( 'rcfg_status_conn' ),                   { size = 14, weight = 400, antialias = true, font = 'Roboto' } )
reg_font( pref( 'rcfg_item_name' ),                     { size = 19, weight = 400, antialias = true, font = 'Roboto' } )
reg_font( pref( 'rcfg_item_ver' ),                      { size = 12, weight = 400, antialias = true, font = 'Roboto' } )
reg_font( pref( 'rcfg_item_rel' ),                      { size = 14, weight = 200, antialias = true, font = 'Roboto' } )
reg_font( pref( 'rcfg_item_desc' ),                     { size = 15, weight = 100, antialias = true, font = 'Roboto Lt' } )
reg_font( pref( 'rcfg_footer_i' ),                      { size = 14, weight = 400, antialias = true, font = 'Roboto' } )
reg_font( pref( 'rcfg_symbol' ),                        { size = 48, weight = 800, antialias = true, font = 'gmodsymbolic', extended = true } )

/*
*    fonts :: interface :: lang
*/

reg_font( pref( 'lang_close' ),                         { size = 24, weight = 800, antialias = true, font = 'Roboto' } )
reg_font( pref( 'lang_icon' ),                          { size = 24, weight = 100, antialias = true, font = 'Roboto Light' } )
reg_font( pref( 'lang_title' ),                         { size = 16, weight = 600, antialias = true, font = 'Roboto Light' } )
reg_font( pref( 'lang_desc' ),                          { size = 16, weight = 400, antialias = true, font = 'Roboto Light' } )
reg_font( pref( 'lang_item' ),                          { size = 16, weight = 400, antialias = true, font = 'Roboto Light' } )

/*
*   fonts :: interface :: reports
*/

reg_font( pref( 'report_exit' ),                        { size = 24, weight = 800, antialias = true, font = 'Roboto' } )
reg_font( pref( 'report_resizer' ),                     { size = 24, weight = 100, antialias = true, font = 'Roboto Light' } )
reg_font( pref( 'report_btn_clr' ),                     { size = 15, weight = 800, antialias = true, font = 'Roboto' } )
reg_font( pref( 'report_btn_auth' ),                    { size = 29, weight = 800, antialias = true, font = 'Roboto' } )
reg_font( pref( 'report_btn_send' ),                    { size = 15, weight = 800, antialias = true, font = 'Roboto' } )
reg_font( pref( 'report_err' ),                         { size = 14, weight = 800, antialias = true, font = 'Roboto' } )
reg_font( pref( 'report_icon' ),                        { size = 24, weight = 100, antialias = true, font = 'Roboto Light' } )
reg_font( pref( 'report_title' ),                       { size = 16, weight = 600, antialias = true, font = 'Roboto Light' } )
reg_font( pref( 'report_desc' ),                        { size = 16, weight = 400, antialias = true, font = 'Roboto Light' } )
reg_font( pref( 'report_auth' ),                        { size = 16, weight = 400, antialias = true, font = 'Roboto Light' } )
reg_font( pref( 'report_auth_icon' ),                   { size = 24, weight = 100, antialias = true, font = 'Roboto Light' } )

/*
*    fonts :: interface :: mviewer
*/

reg_font( pref( 'mviewer_exit' ),                       { size = 24, weight = 800, antialias = true, font = 'Roboto' } )
reg_font( pref( 'mviewer_resizer' ),                    { size = 24, weight = 100, antialias = true, font = 'Roboto Light' } )
reg_font( pref( 'mviewer_icon' ),                       { size = 24, weight = 100, antialias = true, font = 'Roboto Light' } )
reg_font( pref( 'mviewer_name' ),                       { size = 44, weight = 100, antialias = true, font = 'Roboto Light' } )
reg_font( pref( 'mviewer_title' ),                      { size = 16, weight = 600, antialias = true, shadow = true, font = 'Roboto Light' } )
reg_font( pref( 'mviewer_clear' ),                      { size = 20, weight = 800, antialias = true, font = 'Roboto' } )
reg_font( pref( 'mviewer_enter' ),                      { size = 20, weight = 800, antialias = true, font = 'Roboto' } )
reg_font( pref( 'mviewer_control' ),                    { size = 16, weight = 200, antialias = true, font = 'Roboto Condensed' } )
reg_font( pref( 'mviewer_searchbox' ),                  { size = 18, weight = 100, antialias = true, font = 'Roboto Light' } )
reg_font( pref( 'mviewer_minfo' ),                      { size = 16, weight = 400, antialias = true, font = 'Roboto Light' } )
reg_font( pref( 'mviewer_copyclip' ),                   { size = 14, weight = 100, antialias = true, shadow = true, font = 'Roboto Light' } )

/*
*    fonts :: interface :: konsole
*/

reg_font( pref( 'konsole_exit' ),                       { size = 24, weight = 800, antialias = true, font = 'Roboto' } )
reg_font( pref( 'konsole_icon' ),                       { size = 24, weight = 100, antialias = true, font = 'Roboto Light' } )
reg_font( pref( 'konsole_resizer' ),                    { size = 24, weight = 100, antialias = true, font = 'Roboto Light' } )
reg_font( pref( 'konsole_gear' ),                       { size = 32, weight = 800, antialias = true, font = 'Roboto' } )
reg_font( pref( 'konsole_clear' ),                      { size = 20, weight = 800, antialias = true, font = 'Roboto' } )
reg_font( pref( 'konsole.copy' ),                       { size = 20, weight = 100, antialias = true, font = 'Roboto' } )
reg_font( pref( 'konsole_title' ),                      { size = 16, weight = 600, antialias = true, font = 'Roboto Light' } )
reg_font( pref( 'konsole_text' ),                       { size = 13, weight = 400, antialias = true, font = 'Roboto' } )
reg_font( pref( 'konsole_textfield' ),                  { size = 14, weight = 600, antialias = true, font = 'Roboto Light' } )
reg_font( pref( 'konsole_input_icon' ),                 { size = 24, weight = 100, antialias = true, font = 'Roboto Light' } )
reg_font( pref( 'konsole_cbox_label' ),                 { size = 13, weight = 400, antialias = true, font = 'Roboto' } )

/*
*    fonts :: interface :: dc
*/

reg_font( pref( 'dc_exit' ),                            { size = 24, weight = 800, antialias = true, font = 'Roboto' } )
reg_font( pref( 'dc_icon' ),                            { size = 24, weight = 100, antialias = true, font = 'Roboto Light' } )
reg_font( pref( 'dc_name' ),                            { size = 24, weight = 100, antialias = true, font = 'Roboto Light' } )
reg_font( pref( 'dc_title' ),                           { size = 16, weight = 600, antialias = true, font = 'Roboto Light' } )
reg_font( pref( 'dc_msg' ),                             { size = 16, weight = 600, antialias = true, font = 'Roboto Light' } )
reg_font( pref( 'dc_btn' ),                             { size = 22, weight = 200, antialias = true, font = 'Roboto' } )

/*
*   fonts :: interface :: welcome
*/

reg_font( pref( 'welcome_exit' ),                       { size = 36, weight = 800, antialias = true, font = 'Roboto Light' } )
reg_font( pref( 'welcome_icon' ),                       { size = 24, weight = 100, antialias = true, font = 'Roboto Light' } )
reg_font( pref( 'welcome_title' ),                      { size = 16, weight = 600, antialias = true, font = 'Roboto Light' } )
reg_font( pref( 'welcome_name' ),                       { size = 40, weight = 100, antialias = true, font = 'Segoe UI Light' } )
reg_font( pref( 'welcome_intro' ),                      { size = 20, weight = 100, antialias = true, font = 'Open Sans Light' } )
reg_font( pref( 'welcome_ticker' ),                     { size = 14, weight = 100, antialias = true, font = 'Open Sans' } )
reg_font( pref( 'welcome_btn' ),                        { size = 16, weight = 400, antialias = true, font = 'Roboto Light' } )
reg_font( pref( 'welcome_data' ),                       { size = 12, weight = 200, antialias = true, font = 'Roboto Light' } )
reg_font( pref( 'welcome_fx' ),                         { size = 150, weight = 100, antialias = true, font = 'Roboto Light' } )