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
local prefix            = base.manifest.prefix

/*
*   Localized rlib routes
*
*   : base.h          = helpers
*   : base.d          = draw/design
*   : base.c          = calls
*   : base.p          = panels
*   : base.i          = interface
*   : base.s          = storage
*/

local helper            = rlib.h
local access            = rlib.a
local design            = rlib.d
local ui                = rlib.i
local mats              = rlib.m

/*
*   Localized cmd func
*
*   @source : lua\autorun\libs\_calls
*   @param  : str type
*   @param  : varg { ... }
*/

local function call( t, ... )
    return rlib:call( t, ... )
end

/*
*   Localized translation func
*/

local function lang( ... )
    return rlib:translate( mod, ... )
end

/*
*   Localized res func
*/

local function resources( t, ... )
    return rlib:resource( mod, t, ... )
end

/*
*	localized mat func
*/

local function mat( id )
    return mats:call( mod, id )
end

/*
*	prefix ids
*/

local function pref( str, suffix )
    local state = not suffix and mod or isstring( suffix ) and suffix or false
    return rlib.get:pref( str, state )
end

/*
*   netlib :: chatmsg
*
*   sends a message directly to the ply chat
*/

local function netlib_chatmsg( len, ply )
    local msg = net.ReadTable( )
    if not msg then return end
    chat.AddText( unpack( msg ) )
end
net.Receive( 'rlib.chatmsg', netlib_chatmsg )

/*
*   netlib :: chatconsole
*
*   sends a message directly to the ply console
*/

local function netlib_chatconsole( len, ply )
    local msg = net.ReadTable( )
    if not msg then return end
    table.insert( msg, '\n' )
    MsgC( Color( 255, 255, 255 ), unpack( msg ) )
end
net.Receive( 'rlib.chatconsole', netlib_chatconsole )

/*
*   netlib :: notify
*
*   sends a standard notification directly to the ply screen
*/

local function netlib_notify( len, ply )
    local args  = net.ReadTable( )
    local cat   = args and args[ 1 ] or 1
    local msg   = args and args[ 2 ] or ''
    local dur   = args and args[ 3 ] or 5
    local pos   = args and args[ 4 ] or 1
    local bFull = args and args[ 5 ] or false

    design:notify( cat, msg, dur, pos, bFull )
end
net.Receive( 'rlib.notify', netlib_notify )

/*
*   netlib :: inform
*
*   sends a slider notification directly to the ply screen
*   slides in from the right side.
*/

local function netlib_inform( len, ply )
    local args  = net.ReadTable( )
    local cat   = args and args[ 1 ] or 1
    local msg   = args and args[ 2 ] or ''
    local title = args and args[ 3 ] or lang( 'notify_title_def' )
    local dur   = args and isnumber( args[ 4 ] ) and args[ 4 ] or 5

    design:inform( cat, msg, title, dur )
end
net.Receive( 'rlib.notify.slider', netlib_inform )

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

    local mat = 'm_' .. src
    if suffix then
        mat = 'm_' .. suffix .. '_' .. src
    end

    return rlib.m[ mat ] or mat or ''
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
*   @param  : tbl, str mod
*   @param  : bool bString
*   @return : tbl, str
*/

function base:mats_index( mod, bPath )
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

    suffix = suffix and string.lower( suffix )

    if not mod then
        return rlib.m
    end

    local mat = 'm_' .. suffix .. '_'

    local resp, cnt = { }, 0
    for k, v in pairs( rlib.m ) do
        if ( string.find( k, mat, 1, true ) ~= nil ) then
            local id    = k
            id          = id:gsub( mat, '' )
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
hook.Add( 'PostGamemodeLoaded', prefix .. 'modules.permissions.register', function( source ) base:modules_perms_register( source ) end )