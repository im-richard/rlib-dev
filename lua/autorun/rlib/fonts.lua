/*
*   @package        rlib
*   @author         Richard [http://steamcommunity.com/profiles/76561198135875727]
*   @copyright      (C) 2018 - 2020
*   @since          3.0.0
*   @website        https://rlib.io
*   @docs           https://docs.rlib.io
*   @file           fonts.lua
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

reg_font( pref( 'sys.entry.default' ),              { size = 16, weight = 400, antialias = true, font = 'Roboto Light' } )
reg_font( pref( 'sys.text.default' ),               { size = 16, weight = 100, antialias = true, shadow = false, font = 'Roboto Light' } )
reg_font( pref( 'sys.rsay.text' ),                  { size = 30, weight = 100, antialias = true, shadow = true, font = 'Roboto Light' } )
reg_font( pref( 'sys.rsay.text.sub' ),              { size = 20, weight = 100, antialias = true, shadow = true, font = 'Roboto Light' } )
reg_font( pref( 'sys.hud.indicator' ),              { size = 22, weight = 400, antialias = true, shadow = true, font = 'Roboto Light' } )
reg_font( pref( 'sys.hud.s2.indicator' ),           { size = 40, weight = 400, antialias = true, shadow = true, font = 'Roboto Light' } )
reg_font( pref( 'sys.hud.s2.indicator.sub' ),       { size = 70, weight = 800, antialias = true, shadow = true, font = 'Roboto' } )
reg_font( pref( 'sys.draw.textscroll' ),            { size = 14, weight = 100, antialias = true, shadow = true, font = 'Roboto Light' } )
reg_font( pref( 'sys.dialog.title' ),	            { size = 36, weight = 100, antialias = true, shadow = true, font = 'Roboto Light' } )
reg_font( pref( 'sys.dialog.msg' ),		            { size = 20, weight = 100, antialias = true, shadow = false, font = 'Roboto' } )
reg_font( pref( 'sys.dialog.qclose' ),	            { size = 16, weight = 100, antialias = true, shadow = true, font = 'Roboto Light' } )
reg_font( pref( 'sys.dialog.slider.title' ),        { size = 23, weight = 100, antialias = true, shadow = true, font = 'Roboto Light' } )
reg_font( pref( 'sys.dialog.slider.msg' ),          { size = 17, weight = 300, antialias = true, shadow = true, font = 'Roboto' } )
reg_font( pref( 'sys.dialog.slider.exit' ),         { size = 42, weight = 800, antialias = true, shadow = false, font = 'Segoe UI Light' } )
reg_font( pref( 'sys.notify.text' ),                { size = 18, weight = 400, antialias = true, shadow = false, font = 'Roboto Light' } )

/*
*    fonts :: interface :: about
*/

reg_font( pref( 'about.exit' ),                     { size = 24, weight = 800, antialias = true, font = 'Roboto' } )
reg_font( pref( 'about.resizer' ),                  { size = 24, weight = 100, antialias = true, font = 'Roboto Light' } )
reg_font( pref( 'about.icon' ),                     { size = 24, weight = 100, antialias = true, font = 'Roboto Light' } )
reg_font( pref( 'about.name' ),                     { size = 44, weight = 100, antialias = true, font = 'Roboto Light' } )
reg_font( pref( 'about.title' ),                    { size = 16, weight = 600, antialias = true, font = 'Roboto Light' } )
reg_font( pref( 'about.entry' ),                    { size = 15, weight = 300, antialias = true, font = 'Roboto' } )
reg_font( pref( 'about.entry.label' ),              { size = 14, weight = 800, antialias = true, font = 'Roboto' } )
reg_font( pref( 'about.entry.value' ),              { size = 16, weight = 200, antialias = true, font = 'Roboto Light' } )
reg_font( pref( 'about.status' ),                   { size = 14, weight = 800, antialias = true, font = 'Roboto' } )
reg_font( pref( 'about.status.conn' ),              { size = 14, weight = 400, antialias = true, font = 'Roboto' } )

/*
*    fonts :: interface :: rcfg
*/

reg_font( pref( 'rcfg.exit' ),                      { size = 24, weight = 800, antialias = true, font = 'Roboto' } )
reg_font( pref( 'rcfg.resizer' ),                   { size = 24, weight = 100, antialias = true, font = 'Roboto Light' } )
reg_font( pref( 'rcfg.icon' ),                      { size = 24, weight = 100, antialias = true, font = 'Roboto Light' } )
reg_font( pref( 'rcfg.name' ),                      { size = 44, weight = 100, antialias = true, font = 'Roboto Light' } )
reg_font( pref( 'rcfg.sub' ),                       { size = 16, weight = 100, antialias = true, font = 'Roboto Light' } )
reg_font( pref( 'rcfg.title' ),                     { size = 16, weight = 600, antialias = true, font = 'Roboto Light' } )
reg_font( pref( 'rcfg.entry' ),                     { size = 15, weight = 300, antialias = true, font = 'Roboto' } )
reg_font( pref( 'rcfg.entry.label' ),               { size = 14, weight = 800, antialias = true, font = 'Roboto' } )
reg_font( pref( 'rcfg.entry.value' ),               { size = 16, weight = 200, antialias = true, font = 'Roboto Light' } )
reg_font( pref( 'rcfg.status' ),                    { size = 14, weight = 800, antialias = true, font = 'Roboto' } )
reg_font( pref( 'rcfg.status.conn' ),               { size = 14, weight = 400, antialias = true, font = 'Roboto' } )

/*
*    fonts :: interface :: lang
*/

reg_font( pref( 'lang.close' ),                     { size = 24, weight = 800, antialias = true, font = 'Roboto' } )
reg_font( pref( 'lang.icon' ),                      { size = 24, weight = 100, antialias = true, font = 'Roboto Light' } )
reg_font( pref( 'lang.title' ),                     { size = 16, weight = 600, antialias = true, font = 'Roboto Light' } )
reg_font( pref( 'lang.desc' ),                      { size = 16, weight = 400, antialias = true, font = 'Roboto Light' } )
reg_font( pref( 'lang.item' ),                      { size = 16, weight = 400, antialias = true, font = 'Roboto Light' } )

/*
*   fonts :: interface :: reports
*/

reg_font( pref( 'report.exit' ),                    { size = 24, weight = 800, antialias = true, font = 'Roboto' } )
reg_font( pref( 'report.resizer' ),                 { size = 24, weight = 100, antialias = true, font = 'Roboto Light' } )
reg_font( pref( 'report.btn.clr' ),                 { size = 15, weight = 800, antialias = true, font = 'Roboto' } )
reg_font( pref( 'report.btn.auth' ),                { size = 29, weight = 800, antialias = true, font = 'Roboto' } )
reg_font( pref( 'report.btn.send' ),                { size = 15, weight = 800, antialias = true, font = 'Roboto' } )
reg_font( pref( 'report.err' ),                     { size = 14, weight = 800, antialias = true, font = 'Roboto' } )
reg_font( pref( 'report.icon' ),                    { size = 24, weight = 100, antialias = true, font = 'Roboto Light' } )
reg_font( pref( 'report.title' ),                   { size = 16, weight = 600, antialias = true, font = 'Roboto Light' } )
reg_font( pref( 'report.desc' ),                    { size = 16, weight = 400, antialias = true, font = 'Roboto Light' } )
reg_font( pref( 'report.auth' ),                    { size = 16, weight = 400, antialias = true, font = 'Roboto Light' } )
reg_font( pref( 'report.auth.icon' ),               { size = 24, weight = 100, antialias = true, font = 'Roboto Light' } )

/*
*    fonts :: interface :: mviewer
*/

reg_font( pref( 'mviewer.exit' ),                 { size = 24, weight = 800, antialias = true, font = 'Roboto' } )
reg_font( pref( 'mviewer.resizer' ),              { size = 24, weight = 100, antialias = true, font = 'Roboto Light' } )
reg_font( pref( 'mviewer.icon' ),                 { size = 24, weight = 100, antialias = true, font = 'Roboto Light' } )
reg_font( pref( 'mviewer.name' ),                 { size = 44, weight = 100, antialias = true, font = 'Roboto Light' } )
reg_font( pref( 'mviewer.title' ),                { size = 16, weight = 600, antialias = true, shadow = true, font = 'Roboto Light' } )
reg_font( pref( 'mviewer.button' ),               { size = 13, weight = 100, antialias = true, shadow = true, font = 'Roboto Light' } )
reg_font( pref( 'mviewer.chances' ),              { size = 16, weight = 100, antialias = true, shadow = true, font = 'Roboto' } )
reg_font( pref( 'mviewer.report.header' ),        { size = 12, weight = 400, antialias = true, shadow = true, font = 'Roboto' } )
reg_font( pref( 'mviewer.clear' ),                { size = 20, weight = 800, antialias = true, font = 'Roboto' } )
reg_font( pref( 'mviewer.enter' ),                { size = 20, weight = 800, antialias = true, font = 'Roboto' } )
reg_font( pref( 'mviewer.control' ),              { size = 14, weight = 200, antialias = true, font = 'Roboto Condensed' } )
reg_font( pref( 'mviewer.searchbox' ),            { size = 18, weight = 100, antialias = true, font = 'Roboto Light' } )
reg_font( pref( 'mviewer.minfo' ),                { size = 16, weight = 400, antialias = true, font = 'Roboto Light' } )

/*
*    fonts :: interface :: konsole
*/

reg_font( pref( 'konsole.ico' ),                 { size = 24, weight = 800, antialias = true, font = 'Roboto' } )
reg_font( pref( 'konsole.icon' ),                { size = 24, weight = 100, antialias = true, font = 'Roboto Light' } )
reg_font( pref( 'konsole.resizer' ),             { size = 24, weight = 100, antialias = true, font = 'Roboto Light' } )
reg_font( pref( 'konsole.gear' ),                { size = 32, weight = 800, antialias = true, font = 'Roboto' } )
reg_font( pref( 'konsole.clear' ),               { size = 20, weight = 800, antialias = true, font = 'Roboto' } )
reg_font( pref( 'konsole.trash' ),               { size = 24, weight = 800, antialias = true, font = 'Roboto' } )
reg_font( pref( 'konsole.copy' ),                { size = 20, weight = 100, antialias = true, font = 'Roboto' } )
reg_font( pref( 'konsole.title' ),               { size = 16, weight = 600, antialias = true, font = 'Roboto Light' } )
reg_font( pref( 'konsole.text' ),                { size = 13, weight = 400, antialias = true, font = 'Roboto' } )
reg_font( pref( 'konsole.textfield' ),           { size = 14, weight = 600, antialias = true, font = 'Roboto Light' } )
reg_font( pref( 'konsole.input.icon' ),          { size = 24, weight = 100, antialias = true, font = 'Roboto Light' } )
reg_font( pref( 'konsole.chkb.label' ),          { size = 13, weight = 400, antialias = true, font = 'Roboto' } )

/*
*    fonts :: interface :: dc
*/

reg_font( pref( 'dc.exit' ),                    { size = 24, weight = 800, antialias = true, font = 'Roboto' } )
reg_font( pref( 'dc.icon' ),                    { size = 24, weight = 100, antialias = true, font = 'Roboto Light' } )
reg_font( pref( 'dc.name' ),                    { size = 24, weight = 100, antialias = true, font = 'Roboto Light' } )
reg_font( pref( 'dc.title' ),                   { size = 16, weight = 600, antialias = true, font = 'Roboto Light' } )
reg_font( pref( 'dc.msg' ),                     { size = 16, weight = 600, antialias = true, font = 'Roboto Light' } )
reg_font( pref( 'dc.btn' ),                     { size = 22, weight = 200, antialias = true, font = 'Roboto' } )

/*
*    fonts :: interface :: addons
*/

reg_font( pref( 'rcfg.item.name' ),             { size = 19, weight = 100, antialias = true, font = 'Roboto' } )
reg_font( pref( 'rcfg.item.ver' ),              { size = 14, weight = 400, antialias = true, font = 'Roboto' } )
reg_font( pref( 'rcfg.item.rel' ),              { size = 14, weight = 200, antialias = true, font = 'Roboto' } )
reg_font( pref( 'rcfg.item.desc' ),             { size = 15, weight = 100, antialias = true, font = 'Roboto Lt' } )
reg_font( pref( 'rcfg.item.hover' ),            { size = 15, weight = 300, antialias = true, font = 'Roboto Lt' } )
reg_font( pref( 'rcfg.footer.count' ),          { size = 14, weight = 400, antialias = true, font = 'Roboto' } )