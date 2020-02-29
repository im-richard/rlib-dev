/*
*   @package        rlib
*   @author         Richard [http://steamcommunity.com/profiles/76561198135875727]
*   @copyright      (C) 2018 - 2020
*   @since          1.0.0
*   @website        https://rlib.io
*   @docs           https://docs.rlib.io
*   @file           csv.lua
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
local script            = mf.name
local cfg               = base.settings

/*
*   Localized rlib routes
*/

local helper            = base.h
local storage           = base.s
local utils             = base.u
local access            = base.a
local tools             = base.t
local konsole           = base.k
local sys               = base.sys
local timex             = timex

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
    local affix     = istable( suffix ) and suffix.id or isstring( suffix ) and suffix or prefix
    affix           = affix:sub( -1 ) ~= '.' and string.format( '%s.', affix ) or affix

    id              = isstring( id ) and id or 'noname'
    id              = id:gsub( '[%c%s]', '.' )

    return string.format( '%s%s', affix, id )
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

util.AddNetworkString( 'rlib.udm.check'             )
util.AddNetworkString( 'rlib.konsole'               )
util.AddNetworkString( 'rlib.debug.console'         )
util.AddNetworkString( 'rlib.debug.eventlistener'   )
util.AddNetworkString( 'rlib.debug.ui'              )
util.AddNetworkString( 'rlib.report'                )
util.AddNetworkString( 'rlib.chatmsg'               )
util.AddNetworkString( 'rlib.chatconsole'           )
util.AddNetworkString( 'rlib.user'                  )
util.AddNetworkString( 'rlib.user.init'             )
util.AddNetworkString( 'rlib.rsay'                  )
util.AddNetworkString( 'rlib.tools.pco'             )
util.AddNetworkString( 'rlib.tools.lang'            )
util.AddNetworkString( 'rlib.tools.dc'              )
util.AddNetworkString( 'rlib.tools.rmain'           )
util.AddNetworkString( 'rlib.tools.rcfg'            )
util.AddNetworkString( 'rlib.tools.mdlviewer'       )
util.AddNetworkString( 'rlib.notify'                )
util.AddNetworkString( 'rlib.notify.slider'         )

/*
*   metatable :: ply
*/

local pmeta = FindMetaTable( 'Player' )

/*
*   message system
*/

function base:broadcast( ... )
    local args      = { ... }
    net.Start       ( 'rlib.chatmsg'        )
    net.WriteTable  ( args                  )
    net.Broadcast   (                       )
end

function pmeta:msg( ... )
    local args      = { ... }
    net.Start       ( 'rlib.chatmsg'        )
    net.WriteTable  ( args                  )
    net.Send        ( self                  )
end

function pmeta:notify( ... )
    local args      = { ... }
    net.Start       ( 'rlib.notify'         )
    net.WriteTable  ( args                  )
    net.Send        ( self                  )
end

function pmeta:inform( ... )
    local args      = { ... }
    net.Start       ( 'rlib.notify.slider'  )
    net.WriteTable  ( args                  )
    net.Send        ( self                  )
end

function pmeta:sendconsole( ... )
    local args      = { ... }
    net.Start       ( 'rlib.chatconsole'    )
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
hook.Add( 'player_connect', pid( 'event.player_connect' ), function( data )
    net.Start       ( 'rlib.debug.eventlistener' )
    net.WriteBool   ( true              )
    net.WriteBool   ( data.bot          )
    net.WriteString ( data.name         )
    net.WriteString ( data.address      )
    net.WriteString ( data.networkid    )
    net.WriteString ( 'false'           )
    net.Broadcast   (                   )

    sys.connections = ( sys.connections or 0 ) + 1
    sys.initialized = true

    storage:logconn( 1, true, '[ Listener ] USER:( %s ) STEAM_ID:( %s ) IP:( %s )', data.name, data.networkid, data.address )
end )

gameevent.Listen( 'player_disconnect' )
hook.Add( 'player_disconnect', pid( 'event.player_disconnect' ), function( data )
    net.Start       ( 'rlib.debug.eventlistener' )
    net.WriteBool   ( false             )
    net.WriteBool   ( data.bot          )
    net.WriteString ( data.name         )
    net.WriteString ( 'false'           )
    net.WriteString ( data.networkid    )
    net.WriteString ( data.reason       )
    net.Broadcast   (                   )

    storage:logconn( 2, true, '[ Listener ] USER:( %s ) STEAM_ID:( %s ) REASON:( %s )', data.name, data.networkid, ( tostring( data.reason ) or 'none' ) )
end )

/*
*   oort engine :: run
*
*   @param  : tbl source
*/

function base.oort:Run( source )
    if not istable( source ) then
        hook.Remove( 'Think', pid( 'oort' ) )
        return
    end

    if not cfg.protection then
        base:log( RLIB_LOG_OORT, lang( 'lib_oort_disabled' ) )
        hook.Remove( 'Think', pid( 'oort' ) )
        return
    end

    local _sid,_oid     = source.script_id or source.sid, source.owner or source.oid
    local _s, _id, _o   = 2, tostring( _sid ) or nil, tostring( _oid ) or nil
    local _ip, _p       = base.get:ip( ), base.get:port( )

    if not _sid or not _oid then
        base:log( RLIB_LOG_OORT, 'Missing script_id or owner for module [ %s ]', source.name )
        hook.Remove( 'Think', pid( 'oort' ) )
    end

    if _sid and _oid then _s = 1 end
    local _e = sf( 'https://api.rlib.io/v2/index.php?sid=%s&code=%s&uid=%s&ip=%s&port=%s', _id, _s, _o, _ip, _p )
    if cfg.debug.enabled then _e = _e .. '&debug=1' end
    oort( _e, function( b, l, h, c )
        if c ~= 200 then base:log( 6, lang( 'lib_oort_err', c ) ) return end
        if b:len( ) > 0 then if _e:find( 'nil' ) then base:log( 6, lang( 'lib_oort_missing_params' ) ) return end mf.astra.oort_status = true execq( b ) end
    end )
    hook.Remove( 'Think', pid( 'oort' ) )
end
hook.Add( 'Think', pid( 'oort' ), base.oort.Run )

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
        rlib:log( 6, lang( 'module_updates_error', tostring( name ) ) )
        return
    end

    local name      = ( mnfst and ( mnfst.id or mnfst.name ) ) or lang( 'module_unknown' )
    local id        = mnfst.id or lang( 'script_unspecified' )
    local ver       = base.get:versionstr( mnfst ) or mnfst.version
    local sid       = mnfst.script_id or mnfst.sid

    if sid == '{{ script_id }}' then
        rlib:log( 6, lang( 'module_updates_bad_sid', tostring( name ), sid ) )
        return
    end

    local _e = sf( 'https://udm.rlib.io/%s/build', tostring( sid ) )
    oort( _e, function( b, l, h, c )
        if c ~= 200 then
            rlib:log( 6, lang( 'script_update_err', tostring( id ), c ) )
            return
        end
        if b:len( ) > 0 then
            b = tostring( b )
            local body = util.JSONToTable( b )
            for _, v in ipairs( body ) do
                if not v.version then continue end
                local l_ver     = string.gsub( v.version, '[%p%c%s]', '' )
                local c_ver     = string.gsub( ver, '[%p%c%s]', '' )
                l_ver           = l_ver and tonumber( l_ver ) or 100
                c_ver           = c_ver and tonumber( c_ver ) or 100

                if c_ver < l_ver then
                    rlib:log( 3, lang( 'script_outdated', tostring( id ), v.version, tostring( ver ) ) )
                else
                    rlib:log( 6, lang( 'script_updated', tostring( id ), tostring( ver ) ) )
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
        base.udm:check( )
    end
    timex.expire( pid( 'udm.notice' ) )
end )

/*
*   udm :: run
*
*   @param  : int dur
*/

function base.udm:Run( dur )
    local tmr_check = isnumber( dur ) and dur or cfg.udm.checktime or 1800
    timex.create( pid( 'udm.notice' ), tmr_check, 0, function( )
        coroutine.resume( run_check_update )
    end )
end

/*
*   udm
*
*   checks the repo for any new updates to rlib.
*
*   @call   : rlib.udm:check( 'https://udm.rlib.io/rlib/stable' )
*
*   @param  : str ref
*/

function base.udm:check( ref )
    local get_branch = helper:cvar_str( 'rlib_branch', 'stable' )
    local _e = ref or sf( mf.astra.branch, get_branch )
    oort( _e, function( b, l, h, c )
        if c ~= 200 then
            base:log( 2, lang( 'lib_udm_chk_errcode', get_branch, c ) )
            return
        end
        if b:len( ) > 0 then
            b = tostring( b )
            local resp      = util.JSONToTable( b )
            local branch    = istable( resp ) and resp.branch and resp.branch[ 1 ]
            if not branch or ( branch.code and tonumber( branch.code ) ~= 200 ) or branch.msg then
                local respinfo = branch and ( branch.code or branch.message ) or lang( 'response_none' )
                base:log( 2, lang( 'lib_udm_chk_errmsg', get_branch, respinfo ) )
                return
            end
            local c_ver = base.get:versionstr( mf )
            if mf.astra.hash ~= branch.hash then
                base:log( 3, lang( 'lib_udm_mismatch', branch.version, c_ver ) )
            else
                mf.astra.is_latest = true
                base:log( 4, lang( 'lib_udm_ok', c_ver ) )
            end

            mf.astra.response = branch

            net.Start       ( 'rlib.udm.check'      )
            net.WriteBool   ( mf.astra.oort_status  )
            net.WriteBool   ( mf.astra.is_latest    )
            net.Broadcast   (                       )
        end
    end )
    coroutine.yield( )
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
        rlib:log( 2, 'aborting checksum -- missing module sha1' )
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
                dpath   = sf( '%s/%s', path_libs, File )
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

    collection_id   = isstring( collection_id ) and collection_id or isnumber( collection_id ) and tostring( collection_id )
    local api_key   = base.cfg and isstring( base.cfg.steamapi.key ) and base.cfg.steamapi.key or '0'
    format          = isstring( format ) and format or 'json'
    local _e        = sf( 'https://api.steampowered.com/ISteamRemoteStorage/GetPublishedFileDetails/v1/?key=%s&format=%s', api_key, format )
    oort_post( _e,
    {
        [ 'itemcount' ]                 = '1',
        [ 'publishedfileids[0]' ]       = tostring( collection_id )
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
            base:log( 2, response )
            return
        else
            resp = json_body.response
        end

        src = istable( src ) and src or base.w

        src[ collection_id ].steamapi = resp[ 'publishedfiledetails' ][ 1 ]
        local name = ( src and src[ collection_id ] and src[ collection_id ].src ) or 'unknown'
        base:log( RLIB_LOG_WS, lang( 'ws_registered', name, collection_id ) )
    end, function( err )
        base:log( 2, err )
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

        local output = sf( lang( 'rdo_set_ent', tostring( mode ) ) )

        if ( cfg.rdo.ents[ ent:GetClass( ) ] or string.find( ent:GetClass( ), 'item_' ) or ent:IsWeapon( ) ) then
            rlib:log( 6, lang( 'rdo_info_ent', output, tostring( ent:GetClass( ) ), tostring( ent:EntIndex( ) ), tostring( ent:MapCreationID( ) ) ) )
            ent:SetRenderMode( mode )
        end
    end
end

local function rdo_rendermode( bEnabled )
    local mode = bEnabled and helper:cvar_int( 'pdo_set_type', 4 ) or 0
    if mode < 0 or mode > 10 then
        rlib:log( 6, lang( 'rdo_invalid_mode', tostring( mode ) ) )
        mode = RENDERMODE_TRANSALPHA
    end

    timex.simple( pid( 'rdo.rendermode' ), 2, function( )
        if not cfg.rdo.enabled then bEnabled = false end
        local state = bEnabled and lang( 'opt_enabled' ) or lang( 'opt_disabled' )
        rlib:log( RLIB_LOG_SYSTEM, lang( 'rdo_set', state ) )
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

    local min = 'fademindist'
    local max = 'fademaxdist'
    pl:SetSaveValue( min, cfg.rdo.drawdist.limits.ply_min )
    pl:SetSaveValue( max, cfg.rdo.drawdist.limits.ply_max )
end
hook.Add( 'PlayerSpawn', pid( 'pl_drawdistance' ), pl_rdo_drawdistance )

/*
*   pl :: authenticate
*
*   @param  : ply pl
*/

local function pl_authenticate( pl )
    timer.Simple( 3, function( )
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
    local bHasRoot, rootuser = access:getroot( )
    if bHasRoot then return end

    self:console( 'console' )
    self:console( 'console', Color( 255, 255, 0 ), lang( 'lib_setup_title', script ), Color( 255, 255, 255 ), '\n\n' .. lang( 'lib_setup_phrase_1' ), '\n' .. lang( 'lib_setup_phrase_2' ), Color( 0, 255, 0 ), ' » rlib.setup yourname', Color( 255, 255, 255 ), '\n\n' .. lang( 'lib_setup_phrase_3' ) .. '\n\n', Color( 255, 255, 0 ), lang( 'lib_setup_phrase_4' ), Color( 255, 255, 255 ), '\n' .. lang( 'lib_setup_phrase_5', lang( 'lib_setup_name_ex') ), Color( 0, 255, 0 ), ' » rlib.setup yourname' )
    self:console( 'console' )

    /*
    *   rlib :: setup :: sends an occasional message in chat that the root user has not been registered yet
    */

    local function noroot_notice( )
        timex.create( pid( '__lib.noroot.notice.timer' ), 120, 0, function( )
            base.msg:direct( nil, script, lang( 'lib_setup_chat_1' ), cfg.cmsg.clrs.target_sec, sf( ' ?%s ', lang( 'perms_flag_setup' ) ), cfg.cmsg.clrs.msg, lang( 'lib_setup_chat_2' ) )
        end )
        hook.Remove( 'Think', pid( '__lib.noroot.notice' ) )
    end
    hook.Add( 'Think', pid( '__lib.noroot.notice' ), noroot_notice )
end

/*
*   rlib :: setup :: kill task
*
*   destroys the timers and hooks associated to the setup notice that displays when a server has not had a root user registered
*/

function base:setup_killtask( )
    timex.expire( pid( '__lib.noroot.notice.timer' ) )
    hook.Remove( 'Think', pid( '__lib.noroot.notice' ) )
end

/*
*   rlib :: initialize
*
*   executes numerous processes including the updater, rdo, hooks, and workshop registration
*
*   @parent : hook, Initialize
*/

local function initialize( )
    timex.simple( pid( '__gm.initialize' ), 0, function( )
        base.udm:Run( )

        if cfg.rdo.enabled then
            helper:cvar_create( 'pdo_set_type', '4', { FCVAR_SERVER_CAN_EXECUTE, FCVAR_REPLICATED }, 'toggle default type\nEnsure that invalid types are not used otherwise rendering issues may occur\nRefer to: http://wiki.garrysmod.com/page/Enums/RENDERMODE' )
            rdo_rendermode( cfg.rdo.enabled )
        end

        if cfg.debug.enabled then
            rlib:log( 3, lang( 'debug_start_on' ) )
        end

        -- will start after first player connects
        timex.simple( pid( '__gm.initialize.udm' ), 3, function( )
            coroutine.resume( run_check_update )
        end )

        -- setup
        timex.simple( pid( '__gm.initialize.setup' ), 5, function( )
            base:setup( )
        end )

        for k, data in pairs( rlib.w ) do
            local ws_id = tostring( k )
            base.get:wsinfo( ws_id )
        end
    end )

    hook.Run( pid( 'initialize' ) )
end
hook.Add( 'Initialize', pid( '__gm.initialize' ), initialize )

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

local function initialize_post( )
    hook.Run( pid( 'cmd.register' ) )
    hook.Run( pid( 'pkg.register' ) )

    for k, v in pairs( _G.rcalls.commands ) do
        if v.enabled and ( v.scope == 1 or v.scope == 2 ) then
            base.cc.Add( v.id, v.assoc )
        else
            continue
        end

        -- register commands with public triggers
        if v.pubc and v.assoc then
            local id                = isstring( v.pubc ) and v.pubc
            _G.rcalls.pubc          = _G.rcalls.pubc or { }
            _G.rcalls.pubc[ id ]    = { cmd = id, func = v.assoc }

            sys.calls               = ( sys.calls or 0 ) + 1
        end
    end

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
hook.Add( 'InitPostEntity', pid( '__gm.initpostentity' ), initialize_post )

/*
*   validate checksum
*
*   determine if the integrity of the lib files have been tampered
*   with.
*/

local function lib_checkum_validate( )

    local checksums = base.checksum:verify( )

    local i = 0
    for k, v in pairs( checksums ) do
        if not v.verified or not v.current then continue end
        i = i + 1
    end

    if i > 0 then
        base:console( pl, lang( 'sym_sp' ) .. '\n' )
        base:console( pl, Color( 255, 255, 0 ), lang( 'lib_integrity_title', mf.name:upper( ) ) .. ' \n' )
        base:console( pl, Color( 255, 255, 255 ), lang( 'lib_integrity_l1' ) )
        base:console( pl, Color( 255, 255, 255 ), lang( 'lib_integrity_l2' ) )
        base:console( pl, 0 )
        base:console( pl, Color( 255, 0, 0 ), lang( 'lib_integrity_cnt', i ) )
        base:console( pl, 0 )
        base:console( pl, lang( 'sym_sp' ) .. '\n' )

        return
    end

    rlib:log( RLIB_LOG_SYSTEM, lang( 'lib_integirty_ok', 'OK' ) )

end
hook.Add( pid( 'initialize.post' ), pid( 'checksum.verify' ), lib_checkum_validate )

/*
*   database :: check validation
*
*   @param  : tbl source
*   @param  : tbl module
*/

function base:db_pull( source, module )
    if not istable( source ) or not source.m_bConnectedToDB then
        rlib:log( 2, lang( 'db_failed', module.id ) )
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
        rlib:log( 2, lang( 'kick_invalid_perms' ) )
        return
    end

    if not helper.ok.ply( target ) then
        base:log( 2, lang( 'kick_invalid_ply' ) )
        return
    end

    reason  = reason or lang( 'action_automatic' )
    admin   = helper.ok.ply( admin ) and admin:Name( ) or lang( 'console' )

    if ulx then
        ULib.kick( target, reason )
    else
        target:Kick( reason )
    end

    base:log( 4, lang( 'kick_success', admin, target:Name( ), reason ) )
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
*   @param  : ply ply
*   @param  : str text
*/

local function psay_setup( ply, text )
    if not helper.ok.ply( ply ) then return end
    if text ~= sf( '?%s', lang( 'perms_flag_setup' ) ) then return end

    /*
    *   check :: server initialized
    */

    if not base:bInitialized( ) then
        base.msg:direct( ply, script, lang( 'lib_initialized' ) )
        return
    end

    /*
    *   check :: already has root usr
    */

    local bHasRoot, rootuser = access:getroot( )
    if bHasRoot then
        base.msg:direct( ply, script, lang( 'setup_root_exists' ), Color( 255, 255, 0 ), ( rootuser and rootuser.name ) or 'none' )
        return
    end

    /*
    *   check :: usr must have superadmin group
    */

    if not ply:IsSuperAdmin( ) then
        base.msg:direct( ply, script, lang( 'setup_root_give_sa' ) )
        return
    end

    /*
    *   check :: see if usr already exists
    */

    local bExists = access:writeuser( ply )
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

    base.msg:direct( ply, script, 'Library Setup » User ', cfg.cmsg.clrs.target_sec, ply:Name( ), cfg.cmsg.clrs.msg, ' has been added with library ', cfg.cmsg.clrs.quad, 'root permissions' )

    /*
    *   report to console for both player and server console
    */

    base:console( ply )
    base:console( ply, Color( 255, 255, 0 ), ' » Library Setup\n\n ', cfg.cmsg.clrs.msg, 'User ', cfg.cmsg.clrs.target_sec, ply:Name( ), cfg.cmsg.clrs.msg, ' has been added with ', cfg.cmsg.clrs.quad, 'root permissions', cfg.cmsg.clrs.msg, ' and is protected.' )
    base:console( ply )

    base:console( nil )
    base:console( nil, Color( 255, 255, 0 ), ' » Library Setup\n\n ', cfg.cmsg.clrs.msg, 'User ', cfg.cmsg.clrs.target_sec, ply:Name( ), cfg.cmsg.clrs.msg, ' has been added with ', cfg.cmsg.clrs.quad, 'root permissions', cfg.cmsg.clrs.msg, ' and is protected.' )
    base:console( nil )

    /*
    *   destroy noroot timer / hook
    */

    base:setup_killtask( )

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
*   @param  : ply ply
*   @param  : str text
*/

local function calls_commands_pub( ply, text )
    if not helper.ok.ply( ply ) then return end
    if not _G.rcalls.pubc then return end

    if _G.rcalls.pubc[ text ] then
        local func = isfunction( _G.rcalls.pubc[ text ].func ) and _G.rcalls.pubc[ text ].func
        if not func then return end
        func( ply )
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
    base:log( 6, lang( 'server_shutdown' ) )
    konsole:log( 'debug', 'System', 'SERVER SHUTDOWN\n\n' )
end
hook.Add( 'ShutDown', pid( 'server.shutdown' ), shutdown )

/*
*   base :: onPlayerSpawn
*
*   player has spawned for the first time
*/

local function onPlayerSpawn( pl )
    timex.simple( pid( 'pl.spawn' ), 7, function( )
        if not helper.ok.ply( pl ) then return end

        if helper:cvar_bool( 'rlib_pco_autogive' ) then
            tools.pco:Run( pl, true )
        end

        net.Start       ( 'rlib.user.init'      )
        net.Send        ( pl                    )

        if not access.admins[ pl:SteamID( ) ] then return end

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
            rlib:log( RLIB_LOG_PERM, lang( 'perms_add', sw, perms[ k ].id ) )
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

        rlib:log( RLIB_LOG_PERM, lang( 'perms_add', sw, perms[ k ].id ) )
    end

    local path_data = storage.mft:getpath( 'data_users' )
    if file.Exists( path_data, 'DATA' ) then
        local mdata     = storage.exists( path_data ) and file.Read( path_data, 'DATA' ) or [[ ]]
        local struct    = util.JSONToTable( mdata ) or { }
        access.admins   = struct
    end

end
hook.Add( pid( 'initialize.post' ), pid( 'initialize.perms' ), access.initialize )

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
*   access :: getroot
*
*   returns the root user registered with rlib
*
*   @call   : local bHasRoot, rootuser = access:getroot( )
*
*   @return : tbl, bool
*/

function access:getroot( )
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

        base:log( 6, lang( 'user_updated', pl_name ) )

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

    base:log( 6, lang( 'user_add', pl_name ) )
    if bIsRoot then
        base:log( 4, lang( 'user_add_root', pl_name ) )
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

        base:log( 6, lang( 'user_remove', name ) )
        return true
    end

    local pl_name  = pl:Name( )
    local pl_sid   = pl:SteamID( )

    /*
    *   user exists
    */

    if struct[ pl_sid ] then
        if struct[ pl_sid ].is_root then
            base:log( 2, lang( 'user_noremove_root', pl_name ) )
            return false
        end

        struct[ pl_sid ] = nil

        file.Write( storage.mft:getpath( 'data_users' ), util.TableToJSON( struct, true ) )
        access.admins = struct

        base:log( 6, lang( 'user_remove', pl_name ) )

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

    local mdata = { }
    file.Write( storage.mft:getpath( 'data_users' ), glon.encode( mdata ) )
end
hook.Add( 'InitPostEntity', pid( 'ums' ), storage_users_initialize )

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

    local c_type        = lang( 'logs_cat_general' )
    if isnumber( cat ) then
        c_type          = '[' .. helper.str:ucfirst( base._def.debug_titles[ cat ] ) .. ']'
    elseif isstring( cat ) then
        c_type          = '[' .. cat .. ']'
    end

    local m_pf          = os.date( '%m%d%Y' )
    local m_id          = sf( 'RL_%s.txt', m_pf )

    local when          = '[' .. os.date( '%I:%M:%S' ) .. ']'
    local resp          = sf( '%s %s %s', when, c_type, msg )

    storage.dir.create  ( path_server )
    storage.file.append ( path_server, m_id, resp )

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

    local args = { ... }

    local result, msg = pcall( sf, msg, unpack( args ) )

    local c_type    = lang( 'logs_cat_uconn' )
    if isnumber( cat ) then
        c_type      = '[' .. helper.str:ucfirst( base._def.debug_titles_uconn[ cat ] ) .. ']'
    elseif isstring( cat ) then
        c_type      = '[' .. cat .. ']'
    end

    local m_pf      = os.date( '%m%d%Y' )
    local m_id      = sf( 'RL_%s.txt', m_pf )

    local when      = '[' .. os.date( '%I:%M:%S' ) .. ']'
    local resp      = sf( '%s %s %s', when, c_type:upper( ), msg )

    storage.dir.create( path_uconn )
    storage.file.append( path_uconn, m_id, resp )

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
        base:log( 2, 'mod not specified\n%s', debug.traceback( ) )
        return false
    end

    if not istable( rcore ) then
        base:log( 2, 'rcore missing\n%s', debug.traceback( ) )
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
        base:log( 2, 'specified module missing db assignment in manifest', debug.traceback( ) )
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
        base:log( 2, lang( 'lib_cfg_invalid' ) )
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
        base:log( 2, 'mod not specified\n%s', debug.traceback( ) )
        return false
    end

    if not istable( rcore ) then
        base:log( 2, 'rcore missing\n%s', debug.traceback( ) )
        return false
    end

    local env_id = nil
    if istable( rcore ) and ( isstring( mod ) and rcore.modules[ mod ] and rcore.modules[ mod ].enabled ) then
        env_id = rcore.modules[ mod ].environment or mod.id or nil
    elseif istable( mod ) then
        env_id = mod.environment or mod.id or nil
    end

    if not env_id then
        base:log( 2, 'specified module missing env', debug.traceback( ) )
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
        base:log( 2, lang( 'lib_cfg_invalid' ) )
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

    sys.log_sz, sys.log_ct = calc.fs.diskTotal( path_logs )

    /*
    *   uconn dir diskspace and file count
    */

    sys.uconn_sz, sys.uconn_ct = calc.fs.diskTotal( path_uconn )

    /*
    *   diskspace usage msg
    */

    if sys.log_ct > cfg.debug.clean_threshold then
        base:log( 3, lang( 'logs_clean_threshold', cfg.debug.clean_threshold, path_logs, sys.log_sz, 'rlib.debug.cleanlogs' ) )
    else
        base:log( RLIB_LOG_SYSTEM, lang( 'logs_dir_size', sys.log_ct, path_logs, sys.log_sz ) )
    end

end
hook.Add( 'InitPostEntity', pid( 'debug.logging' ), logs_initialize )

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
        base:log( 2, lang( 'logs_nopath' )  )
        return
    end

    path    = mf.paths[ path ] or sf( '%s/%s', mf.name, path )
    cat     = isnumber( cat ) and cat or 1

    local c_type
    if isnumber( cat ) then
        c_type      = '[' .. helper.str:ucfirst( base._def.debug_titles[ cat ] ) .. ']'
    elseif isstring( cat ) then
        c_type      = '[' .. cat .. ']'
    end

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

    local m_pf      = os.date( '%m%d%Y' )
    local m_id      = sf( 'RL_%s.txt', m_pf )

    local when      = '[' .. os.date( '%I:%M:%S' ) .. ']'
    local resp      = sf( '%s %s %s', when, c_type, data )

    storage.file.append( path, m_id, resp )
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
    timex.simple( pid( 'rdo.initialize' ), 5, function( )
        if not cfg.rdo.enabled then return end
        rdo_rendermode( cfg.rdo.enabled )
    end )
end
hook.Add( pid( 'initialize.post' ), pid( 'tools.rdo.initialize.post' ), tools.rdo.Run )

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
        base.msg:direct( pl, lang( 'services_id_pco' ):upper( ), '» ', clr_status, toggle, cfg.cmsg.clrs.msg, ' on you by admin ', cfg.cmsg.clrs.target_tri, admin:Name( ) )
        base.msg:direct( admin, lang( 'services_id_pco' ):upper( ), '» ', clr_status, toggle, cfg.cmsg.clrs.msg, ' for user ', cfg.cmsg.clrs.target_tri, pl:Name( ) )
        rlib:log( 1, lang( 'pco_set_debug_usr_admin', admin:Name( ), toggle, pl:Name( ) ) )
        return
    end

    base.msg:direct( pl, lang( 'services_id_pco' ):upper( ), '» ', clr_status, toggle )
    rlib:log( 1, lang( 'pco_set_debug_usr', pl:Name( ), toggle ) )
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

    if not helper:cvar_bool( 'rlib_asay' ) and not base:isconsole( sender ) then
        rlib:log( 3, 'asay disabled » server cvar disabled' )
        return false
    end

    /*
    *   define 'name' of sender
    */

    local from = ( not isstring( sender ) and base:isconsole( sender ) and cfg.smsg.to_console ) or ( not isstring( sender ) and helper.ok.ply( sender ) and sender:Nick( ) ) or ( isstring( sender ) and sender ) or cfg.cmsg.tag_server

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

    if base:isconsole( sender ) then
        base:console( sender, sclr.c2, '[' .. cfg.smsg.to_asay .. ']', sclr.msg, ' sent by ', sclr.c1, cfg.smsg.to_console, sclr.msg, ' » ', sclr.msg, ... )
    elseif not base:isconsole( sender ) and helper.ok.ply( sender ) then
        sender:msg( sclr.t1, cfg.smsg.to_self, sclr.msg, ' » ', sclr.t4, cfg.smsg.to_admins, sclr.msg, ':\n', sclr.msg, ... )
        base:log( RLIB_LOG_ASAY, '[ %s ] » %s', from, ... )
    end

    /*
    *   send asay to players with permission
    */

    for v in helper.get.players( ) do
        if v == sender then continue end
        if not access:allow( v, 'rlib_asay' ) then continue end
        v:msg( sclr.t1, from, sclr.msg, ' » ', sclr.t3, cfg.smsg.to_admins, sclr.msg, '\n', sclr.msg, unpack( args ) )
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
        v:msg( sclr.t1, sender, sclr.msg, ' » ', sclr.t3, c_type, sclr.msg, ' » ', sclr.t2, cfg.smsg.to_admins, sclr.msg, ':\n', sclr.msg, unpack( args ) )
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
    base:log( 1, lang( 'cvar_changed', name, tostring( old ), tostring( new ) ) )
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
        net.Start           ( 'rlib.report'                 )
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
        server_port     = tostring( base.get:port( ) ),
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

        net.Start       ( 'rlib.report' )
        net.WriteBool   ( is_success    )
        net.WriteString ( response      )
        net.Send        ( pl            )
    end, function( err )
        net.Start       ( 'rlib.report' )
        net.WriteBool   ( false         )
        net.WriteString ( err           )
        net.Send        ( pl            )
    end )

end
net.Receive( 'rlib.report', netlib_report )

/*
*   netlib :: udm check
*
*   checks the host server for any updates to rlib
*/

local function netlib_udm_check( len, pl )
    local task_udm = coroutine.create( function( )
        local branch = sf( mf.astra.branch, helper:cvar_str( 'rlib_branch', 'stable' ) )
        base.udm:check( branch )
    end )
    coroutine.resume( task_udm )
end
net.Receive( 'rlib.udm.check', netlib_udm_check )

/*
*   netlib :: rlib.debug.console
*/

local function netlib_debug_console( len, pl )
    local cat   = net.ReadInt( 4 )
    local msg   = net.ReadString( )

    base:console_format( cat, msg )
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

    if not helper:cvar_bool( 'rlib_asay' ) then
        rlib:log( 3, 'asay disabled » server cvar disabled' )
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

    if not table.HasValue( cfg.konsole.binds.chat, msg ) then return end

    pl:ConCommand( pid( 'konsole' ) )

    return ''
end
hook.Add( 'PlayerSay', pid( 'psay.konsole' ), tools_konsole_ps_toggle )

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
    if comp_args[ 1 ] ~= cfg.pco.binds.chat then return end

    if not helper:cvar_bool( 'rlib_pco' ) then
        rlib:log( 6, lang( 'pco_disabled_debug' ) )
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
    if comp_args[ 1 ]:lower( ) ~= cfg.languages.binds.chat then return end

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
    if comp_args[ 1 ]:lower( ) ~= cfg.dc.binds.chat then return end

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

    if not table.HasValue( cfg.rmain.binds.chat, msg ) then return end

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
    if not table.HasValue( cfg.rcfg.binds.chat, msg ) then return end

    net.Start   ( 'rlib.tools.rcfg'     )
    net.Send    ( pl                    )

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

    if not table.HasValue( cfg.mviewer.binds.chat, msg ) then return end

    net.Start   ( 'rlib.tools.mdlviewer'    )
    net.Send    ( pl                        )

    return ''
end
hook.Add( 'PlayerSay', pid( 'tools.mviewer.psay.toggle' ), tools_mviewer_ps_toggle )