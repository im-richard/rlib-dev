/*
*   @package        rlib
*   @author         Richard [http://steamcommunity.com/profiles/76561198135875727]
*   @copyright      (C) 2018 - 2020
*   @since          3.0.0
*   @website        https://rlib.io
*   @docs           https://docs.rlib.io
*   @file           get.lua
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
local prefix            = mf.prefix

/*
*   localized rlib routes
*/

local cfg               = base.settings
local helper            = base.h
local storage           = base.s
local utils             = base.u
local access            = base.a
local tools             = base.t
local konsole           = base.k
local sys               = base.sys
local resources         = base.resources

/*
*   Localized lua funcs
*
*   i absolutely hate having to do this, but for squeezing out every
*   bit of performance, we need to.
*/

local Color             = Color
local pairs             = pairs
local ipairs            = ipairs
local error             = error
local print             = print
local setmetatable      = setmetatable
local Vector            = Vector
local Angle             = Angle
local Entity            = Entity
local EffectData        = EffectData
local GetConVar         = GetConVar
local tonumber          = tonumber
local tostring          = tostring
local IsValid           = IsValid
local istable           = istable
local isfunction        = isfunction
local isentity          = isentity
local isnumber          = isnumber
local isstring          = isstring
local type              = type
local file              = file
local debug             = debug
local util              = util
local table             = table
local os                = os
local coroutine         = coroutine
local player            = player
local math              = math
local string            = string
local sf                = string.format

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
*	prefix :: create id
*/

local function cid( id, suffix )
    local affix = istable( suffix ) and suffix.id or isstring( suffix ) and suffix or prefix
    affix = affix:sub( -1 ) ~= '.' and string.format( '%s.', affix ) or affix

    id = isstring( id ) and id or 'noname'
    id = id:gsub( '[%c%s]', '.' )

    return string.format( '%s%s', affix, id )
end

/*
*	prefix ids
*/

local function pid( str, suffix )
    local state = ( isstring( suffix ) and suffix ) or ( base and prefix ) or false
    return cid( str, state )
end

/*
*   get :: workshops
*
*   returns workshops that are loaded on the server through the various methods including rlib, rcore,
*   and individual modules.
*
*   @param  : tbl src
*   @return : tbl
*/

function base.get:ws( src )
    return istable( src ) and src or base.w
end

/*
*   get :: version
*
*   returns the current running version of a specified manifest
*   supports rlib, module manifest version, and module manifest libreq vesioning
*
*   @since  : v1.1.5
*   @param  : tbl, str mnfst
*   @param  : bool bLibReq
*   @return : tbl
*           : major, minor, patch
*/

function base.get:version( mnfst, bLibReq )
    mnfst = ( isstring( mnfst ) or istable( mnfst ) and mnfst ) or mf

    local src = ( ( not bLibReq and ( istable( mnfst.version ) or isstring( mnfst.version ) ) ) and mnfst.version ) or ( ( bLibReq and ( istable( mnfst.libreq ) or isstring( mnfst.libreq ) ) ) and mnfst.libreq )

    if isstring( src ) then
        local ver = string.Explode( '.', src )
        return {
            [ 'major' ] = ver[ 'major' ] or ver[ 1 ] or 1,
            [ 'minor' ] = ver[ 'minor' ] or ver[ 2 ] or 0,
            [ 'patch' ] = ver[ 'patch' ] or ver[ 3 ] or 0
        }
    elseif istable( src ) then
        return {
            [ 'major' ] = src.major or src[ 1 ] or 1,
            [ 'minor' ] = src.minor or src[ 2 ] or 0,
            [ 'patch' ] = src.patch or src[ 3 ] or 0
        }
    end
    return {
        [ 'major' ] = 1,
        [ 'minor' ] = 0,
        [ 'patch' ] = 0
    }
end

/*
*   get :: version str
*
*   returns the current running version of a specified manifest in human readable format
*
*   @since  : v1.1.5
*   @return : str
*/

function base.get:versionstr( mnfst )
    mnfst = ( isstring( mnfst ) or istable( mnfst ) and mnfst ) or mf

    if isstring( mnfst.version ) then
        return mnfst.version
    elseif istable( mnfst.version ) then
        local major, minor, patch = mnfst.version.major or mnfst.version[ 1 ] or 1, mnfst.version.minor or mnfst.version[ 2 ] or 0, mnfst.version.patch or mnfst.version[ 3 ] or 0
        return sf( '%i.%i.%i', major, minor, patch )
    end

    return '1.0.0'
end

/*
*   get :: os
*
*   return the operating system for the server the script is running on
*
*   @return : str, int
*/

function base.get:os( )
    if system.IsWindows( ) then
        return lang( 'sys_os_windows' ), 1
    elseif system.IsLinux( ) then
        return lang( 'sys_os_linux' ), 2
    else
        return lang( 'sys_os_ukn' ), 0
    end
end

/*
*   get :: host
*
*   return the server hostname
*
*   @return : str
*/

function base.get:host( )
    return GetHostName( ) or lang( 'sys_host_untitled' )
end

/*
*   get :: address
*
*   return the current ip address and port for the server
*
*   @return : str
*/

function base.get:addr( )
    return helper.str:split_addr( game.GetIPAddress( ) )
end

/*
*   get :: gamemode
*
*   return the server gamemode
*
*   @param  : bool bCombine
*   @param  : bool bLowercase
*   @return : str, str
*/

function base.get:gm( bCombine, bLowercase )
    local gm_name = ( GM or GAMEMODE ).Name or lang( 'sys_gm_unknown' )
    local gm_base = ( GM or GAMEMODE ).BaseClass.Name or lang( 'sys_gm_sandbox' )

    -- some darkrp derived gamemodes are marked as sandbox / base
    gm_base = ( istable( DarkRP ) and lang( 'sys_gm_darkrp' ) ) or gm_base

    if bCombine then
        gm_name = sf( '%s [ %s ]', gm_name, gm_base )
        return gm_name
    end

    return bLowercase and gm_name:lower( ) or gm_name, bLowercase and gm_base:lower( ) or gm_base
end

/*
*   get :: hash
*
*   create hash from server ip and port
*
*   @return : str
*/

function base.get:hash( )
    local ip, port = self:getaddr( )
    if not ip then return end
    port = port or '27015'

    local checksum = util.CRC( ip .. port )

    return sf( '%x', checksum )
end

/*
*   get :: server ip
*
*   return server ip
*
*   @return : str
*/

function base.get:ip( )
    local hostip    = GetConVar( 'hostip' ):GetString( )
    hostip          = tonumber( hostip )
    if isnumber( hostip ) then
        local ip    = { }
        ip[ 1 ]     = bit.rshift( bit.band( hostip, 0xFF000000 ), 24 )
        ip[ 2 ]     = bit.rshift( bit.band( hostip, 0x00FF0000 ), 16 )
        ip[ 3 ]     = bit.rshift( bit.band( hostip, 0x0000FF00 ), 8 )
        ip[ 4 ]     = bit.band( hostip, 0x000000FF )
        return table.concat( ip, '.' )
    else
        hostip      = game.GetIPAddress( )
        local e     = string.Explode( ':', hostip )
        return e[ 1 ]
    end
end

/*
*   get :: server port
*
*   returns server port
*
*   @return : str
*/

function base.get:port( )
    local hostport = GetConVar( 'hostport' ):GetInt( )
    if hostport and hostport ~= 0 then
        return hostport
    else
        local ip    = game.GetIPAddress( )
        local e     = string.Explode( ':', ip )
        hostport    = e[ 2 ]

        return hostport
    end
end

/*
*   get :: prefix
*
*   creates a proper str id based on the params provided
*   should be called through a localized function
*
*   local function pref( str, suffix )
*       local state = not suffix and mod or isstring( suffix ) and suffix or false
*       return rlib.get:pref( str, state )
*   end
*
*   @call   : pref( 'pnl.root' )
*             returns 'modname.pnl.root'
*
*           : pref( 'pnl.root', true )
*             returns 'rlib.pnl.root'
*
*           : pref( 'pnl.root', 'test' )
*             returns 'test.pnl.root'
*
*   @param  : str id
*   @param  : tbl, str, bool suffix
*   @return : str
*/

function base.get:pref( id, suffix )
    local affix     = istable( suffix ) and suffix.id or isstring( suffix ) and suffix or prefix
    affix           = affix:sub( -1 ) ~= '.' and sf( '%s.', affix ) or affix

    id              = isstring( id ) and id or 'noname'
    id              = id:gsub( '[%p%c%s]', '.' )

    return sf( '%s%s', affix, id )
end

/*
*   base :: parent owners
*
*   fetches the parent script owners to use in a table
*
*   @ex     : local owners = rlib.get:owners( )
*
*   @param  : tbl source
*/

function base.get:owners( source )
    source = source or base.plugins or { }

    if not istable( source ) then
        base:log( 2, 'missing table for » [ %s ]', debug.getinfo( 1, 'n' ).name )
        return false
    end

    for v in helper.get.data( source ) do
        if not v.manifest.owner then continue end
        if type( v.manifest.owner ) == 'string' then
            if helper.ok.sid64( v.manifest.owner ) and not table.HasValue( base.o, v.manifest.owner ) then
                table.insert( base.o, v.manifest.owner )
            end
        elseif type( v.manifest.owner ) == 'table' then
            for t, ply in pairs( v.manifest.owner ) do
                if helper.ok.sid64( ply ) and not table.HasValue( base.o, ply ) then
                    table.insert( base.o, ply )
                end
            end
        end
    end

    return base.o
end