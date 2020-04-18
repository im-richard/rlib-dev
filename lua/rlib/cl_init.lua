/*
*   @package        : rlib
*   @module         : rcore
*   @author         : Richard [http://steamcommunity.com/profiles/76561198135875727]
*   @copyright      : (c) 2018 - 2020
*   @since          : 1.0.0
*   @website        : https://rlib.io
*   @docs           : https://docs.rlib.io
*   @file           : cl_init.lua
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

rcore                   = rcore or { }
local base              = rcore
local pf                = base.manifest.prefix

/*
*   Localized rlib routes
*
*   : base.h            = helpers
*   : base.a            = access
*/

local helper            = rlib.h
local access            = rlib.a
local design            = rlib.d

/*
*   Localized translation func
*/

local function lang( ... )
    return rlib:translate( mod, ... )
end

/*
*   netlib :: sms :: umsg
*
*   sends a message directly to the ply chat
*/

local function netlib_sms_umsg( len, pl )
    local msg = net.ReadTable( )
    if not msg then return end
    chat.AddText( unpack( msg ) )
end
net.Receive( 'rlib.sms.umsg', netlib_sms_umsg )

/*
*   netlib :: sms :: konsole
*
*   sends a message directly to the ply console
*/

local function netlib_sms_konsole( len, pl )
    local msg = net.ReadTable( )
    if not msg then return end
    table.insert( msg, '\n' )
    MsgC( Color( 255, 255, 255 ), unpack( msg ) )
end
net.Receive( 'rlib.sms.konsole', netlib_sms_konsole )

/*
*   netlib :: sms :: notify
*
*   sends a standard notification directly to the ply screen
*/

local function netlib_sms_notify( len, pl )
    local args  = net.ReadTable( )
    local cat   = args and args[ 1 ] or 1
    local msg   = args and args[ 2 ] or ''
    local dur   = args and args[ 3 ] or 5
    local pos   = args and args[ 4 ] or 1
    local bFull = args and args[ 5 ] or false

    design:notify( cat, msg, dur, pos, bFull )
end
net.Receive( 'rlib.sms.notify', netlib_sms_notify )

/*
*   netlib :: inform :: bc
*
*   sends a slider notification directly to the ply screen
*   slides in from the right side.
*/

local function netlib_sms_inform( len, pl )
    local args  = net.ReadTable( )
    local cat   = args and args[ 1 ] or 1
    local msg   = args and args[ 2 ] or ''
    local title = args and args[ 3 ] or lang( 'notify_title_def' )
    local dur   = args and isnumber( args[ 4 ] ) and args[ 4 ] or 5

    design:inform( cat, msg, title, dur )
end
net.Receive( 'rlib.sms.inform', netlib_sms_inform )

/*
*   netlib :: bubble :: bc
*
*   sends a bubble msg that displays to the bottom right of the
*   players screen
*/

local function netlib_sms_bubble( len, pl )
    local args      = net.ReadTable( )
    local msg       = args and args[ 1 ] or ''
    local dur       = args and isnumber( args[ 2 ] ) and args[ 2 ] or nil
    local clr_box   = args and IsColor( args[ 3 ] ) and args[ 3 ] or nil
    local clr_txt   = args and IsColor( args[ 4 ] ) and args[ 4 ] or nil

    design:bubble( msg, dur, clr_box, clr_txt )
end
net.Receive( 'rlib.sms.bubble', netlib_sms_bubble )

/*
*   get material data
* 
*   returns material data based on the values provided
*   providing no second arg ( mod ) will make it return m_src
*
*   providing a mod returns m_mod.id_src
*
*   @ex     : rlib.m:get( 'btn_menu_steam', mod )
*           : rlib.m:get( 'btn_menu_steam', 'mod_str' )
*
*   @param  : str src
*   @param  : tbl, str mod
*   @return : tbl, str
*/

function base:mats_get( src, mod )
    if not isstring( src ) then return end
    local suffix = ''
    if mod then
        if isstring( mod ) and self.modules[ mod ] and self.modules[ mod ].id then
            suffix = self.modules[ mod ].id
        elseif istable( mod ) and mod.id then
            suffix = mod.id
        end
    end

    if isstring( mod ) and not suffix or suffix == '' then
        suffix = mod
    end

    suffix = suffix and suffix:lower( )

    local mat_ref = ( not suffix and 'm_' .. src ) or ( 'm_' .. suffix .. '_' .. src )

    return rlib.m[ mat_ref ] or mat_ref or ''
end

/*
*   get material index
* 
*   returns material data based on the values provided
*   no second arg ( mod ) will make it return m_src
*
*   providing a mod returns m_mod.id_src
*
*   @ex     : rlib.m:get( 'btn_menu_steam', mod )
*           : rlib.m:get( 'btn_menu_steam', 'mod_str' )
*
*   @param  : tbl, str modsrc
*   @param  : bool bString
*   @return : tbl, str
*/

function base:mats_index( modsrc, bPath )
    local suffix = ''
    if modsrc then
        if isstring( modsrc ) and self.modules[ modsrc ] and self.modules[ modsrc ].id then
            suffix = self.modules[ modsrc ].id
        elseif istable( modsrc ) and modsrc.id then
            suffix = modsrc.id
        end
    end

    if isstring( modsrc ) and not suffix or suffix == '' then
        suffix = modsrc
    end

    suffix = suffix and suffix:lower( )

    if not modsrc then
        return rlib.m
    end

    local mat_ref = 'm_' .. suffix .. '_'

    local resp, cnt = { }, 0
    for k, v in pairs( rlib.m ) do
        if ( string.find( k, mat_ref, 1, true ) ~= nil ) then
            local id    = k
            id          = id:gsub( mat_ref, '' )
            resp[ id ]  = bPath and k.path or v
            cnt         = cnt + 1
        end
    end

    return resp, cnt

end

/*
*   modules :: register permissions
*
*   register permissions for each module
*
*   @param  : tbl source
*/

function base:modules_perms_register( source )
    if source and not istable( source ) then
        local trcback = debug.traceback( )
        rlib:log( 2, 'cannot register permissions for modules, bad table\n%s', trcback )
        return
    end

    source = source or base.modules

    for v in helper.get.data( source ) do
        if not v.enabled or not v.permissions then continue end
        access:initialize( v.permissions )
    end
end
rhook.new.gmod( 'PostGamemodeLoaded', 'rcore_modules_perms_register', function( source ) base:modules_perms_register( source ) end )