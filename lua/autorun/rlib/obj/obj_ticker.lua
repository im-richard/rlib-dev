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
*   StructureMsg
*/

function PANEL:StructureMsg( str )

    if not isstring( str ) then return '' end

    str         = str:Replace( '[VERSION]',     rlib.get:ver2str( mf.version ) )
    str         = str:Replace( '[LIB]',         mf.name )

    str         = str:upper( )

    return str

end

/*
*   Init
*/

function PANEL:Init( )

    /*
    *   localizations
    */

    local expire, exists, create = timex.expire, timex.exists, timex.create

    local rand      = math.random
    local count     = table.Count
    local msgs      = cfg.welcome.ticker.msgs
    local delay     = cfg.welcome.ticker.delay
    local clr       = cfg.welcome.ticker.clr
    local speed     = cfg.welcome.ticker.speed

    /*
    *   parent
    */

    self:Dock                   ( FILL                          )

    /*
    *   declarations
    */

    self.bInitialized           = false
    self.results                = rand( count( msgs ) )
    self.selected               = msgs[ self.results ]

    local entry                 = self:StructureMsg( self.selected )

    /*
    *   ticker
    */

    self.ticker                 = ui.new( 'lbl', self           )
    :static                     ( TOP                           )
    :margin                     ( 0, 0, 0                       )
    :textadv                    ( clr, pref( 'welcome_ticker' ), entry, true )

                                :think( function( s )
                                    if not self.bInitialized then
                                        expire( 'rlib_ticker' )
                                    end

                                    if exists( 'rlib_ticker' ) then return end

                                    self.bInitialized = true
                                    create( 'rlib_ticker', delay or 10, 0, function( )
                                        if not self.results then return end

                                        self.results = ( isnumber( self.results ) and self.results + 1 ) or 1
                                        if ( self.results > count( msgs ) ) then self.results = 1 end
                                        if not ui:valid( self ) or not ui:valid( s ) then return end

                                        local lbl   = msgs[ self.results ]
                                        lbl         = self:StructureMsg( lbl )
                                        s:AlphaTo( 0, speed, 0, function( )
                                            s:Dock              ( TOP                       )
                                            s:DockMargin        ( 0, 0, 0, 0               )
                                            s:SetText           ( lbl                       )
                                            s:SetFont           ( pref( 'welcome_ticker' )  )
                                            s:SizeToContents    (                           )
                                            s:SetColor          ( clr                       )
                                            s:AlphaTo           ( 255, speed, 0, function( ) end )
                                        end )
                                    end )
                                end )

end

/*
*   Paint
*
*   @param  : int w
*   @param  : int h
*/

function PANEL:Paint( w, h ) end

/*
*   DefineControl
*/

derma.DefineControl( 'rlib.ui.ticker', 'rlib ticker', PANEL, 'EditablePanel' )