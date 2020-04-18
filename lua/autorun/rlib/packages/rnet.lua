/*
*   @package        : rlib
*   @module         : rnet
*   @author         : Richard [http://steamcommunity.com/profiles/76561198135875727]
*   @copyright      : (C) 2018 - 2020
*   @since          : 1.1.0
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
local prefix            = mf.prefix
local script            = mf.name

/*
*   lib includes
*/

local helper            = base.h
local access            = base.a
local konsole           = base.k

/*
*   pkg declarations
*/

local manifest =
{
    author          = 'richard',
    desc            = 'network library',
    build           = 032620,
    version         = { 2, 0, 0 },
    debug_id        = 'rnet.debug.delay',
}

/*
*   module declarations
*/

    local dcat          = 9
    local ncat          = 10

/*
*   localizations
*/

    local math          = math
    local module        = module
    local sf            = string.format

/*
*   enums
*
*   RNET_UINT and RNET_INT allow for a specified num of bits to be written and read
*
*   int     : –2147483648 to 2147483647 
*   uint    : 0 to 4294967295 
*/

    RNET_STR            = 1
    RNET_FLOAT          = 2
    RNET_BOOL           = 3
    RNET_TBL            = 4
    RNET_CLR            = 5
    RNET_UINT           = 6
    RNET_UINT4          = 7
    RNET_UINT8          = 8
    RNET_UINT16         = 9
    RNET_UINT32         = 10
    RNET_INT            = 11
    RNET_INT4           = 12
    RNET_INT8           = 13
    RNET_INT16          = 14
    RNET_INT32          = 15
    RNET_VEC            = 16
    RNET_PLY            = 17
    RNET_ENT            = 18
    RNET_BIT            = 19
    RNET_ID             = 20        -- uint32                   || item ids
    RNET_UID32          = 21        -- str                      || pl steam32
    RNET_UID64          = 22        -- str                      || pl steam64
    RNET_UID64D         = 23        -- double                   || pl steam64
    RNET_DATE           = 24        -- uint32                   || timestamps
    RNET_IDX            = 50        -- development only

/*
*   enum definitions
*
*   determines how each net Read/Write should be handled
*/

local netconst_lib =
{
    [ RNET_STR ] =
    {
        read    = function( ) return net.ReadString( ) end,
        write   = function( val ) net.WriteString( val ) end,
    },
    [ RNET_FLOAT ] =
    {
        read    = function( ) return net.ReadFloat( ) end,
        write   = function( val ) net.WriteFloat( val ) end,
    },
    [ RNET_BOOL ] =
    {
        read    = function( ) return net.ReadBool( ) end,
        write   = function( val ) net.WriteBool( val ) end,
    },
    [ RNET_TBL ] =
    {
        read    = function( ) return net.ReadTable( ) end,
        write   = function( val ) net.WriteTable( istable( val ) and val or { } ) end,
    },
    [ RNET_CLR ] =
    {
        read    = function( ) return net.ReadColor( ) end,
        write   = function( val ) net.WriteColor( IsColor( val ) and val or Color( 0, 0, 0, 255 ) ) end,
    },
    [ RNET_UINT ] =
    {
        read    = function( bits ) return net.ReadUInt( bits ) end,
        write   = function( val, bits ) net.WriteUInt( val, bits ) end,
    },
    [ RNET_UINT4 ] =
    {
        read    = function( ) return net.ReadUInt( 4 ) end,
        write   = function( val ) net.WriteUInt( val, 4 ) end,
    },
    [ RNET_UINT8 ] =
    {
        read    = function( ) return net.ReadUInt( 8 ) end,
        write   = function( val ) net.WriteUInt( val, 8 ) end,
    },
    [ RNET_UINT16 ] =
    {
        read    = function( ) return net.ReadUInt( 16 ) end,
        write   = function( val ) net.WriteUInt( val, 16 ) end,
    },
    [ RNET_UINT32 ] =
    {
        read    = function( ) return net.ReadUInt( 32 ) end,
        write   = function( val ) net.WriteUInt( val, 32 ) end,
    },
    [ RNET_INT ] =
    {
        read    = function( bits ) return net.ReadInt( bits ) end,
        write   = function( val, bits ) net.WriteInt( val, bits ) end,
    },
    [ RNET_INT4 ] =
    {
        read    = function( ) return net.ReadInt( 4 ) end,
        write   = function( val ) net.WriteInt( val, 4 ) end,
    },
    [ RNET_INT8 ] =
    {
        read    = function( ) return net.ReadInt( 8 ) end,
        write   = function( val ) net.WriteInt( val, 8 ) end,
    },
    [ RNET_INT16 ] =
    {
        read    = function( ) return net.ReadInt( 16 ) end,
        write   = function( val ) net.WriteInt( val, 16 ) end,
    },
    [ RNET_INT32 ] =
    {
        read    = function( ) return net.ReadInt( 32 ) end,
        write   = function( val ) net.WriteInt( val, 32 ) end,
    },
    [ RNET_VEC ] =
    {
        read    = function( ) return net.ReadVector( ) end,
        write   = function( val ) net.WriteVector( isvector( val ) and val or Vector( 0, 0, 0 ) ) end,
    },
    [ RNET_PLY ] =
    {
        read    = function( ) return Player( net.ReadUInt( 16 ) ) end,
        write   = function( val ) net.WriteUInt( IsValid( val ) and val:UserID( ) or 0, 16 ) end,
    },
    [ RNET_ENT ] =
    {
        read    = function( ) return net.ReadEntity( ) end,
        write   = function( val ) net.WriteEntity( helper.ok.any( val ) and val ) end,
    },
    [ RNET_BIT ] =
    {
        read    = function( ) return net.ReadBit( ) end,
        write   = function( val ) net.WriteBit( val ) end,
    },
    [ RNET_ID ] =
    {
        read    = function( ) return net.ReadUInt( 32 ) end,
        write   = function( val ) net.WriteUInt( val, 32 ) end,
    },
    [ RNET_UID32 ] =
    {
        read    = function( ) return net.ReadString( ) end,
        write   = function( val ) net.WriteString( val ) end,
    },
    [ RNET_UID64 ] =
    {
        read    = function( ) return net.ReadString( ) end,
        write   = function( val ) net.WriteString( val ) end,
    },
    [ RNET_UID64D ] =
    {
        read    = function( ) return net.ReadDouble( ) end,
        write   = function( val ) net.WriteDouble( val ) end,
    },
    [ RNET_DATE ] =
    {
        read    = function( ) return net.ReadUInt( 32 ) end,
        write   = function( val ) net.WriteUInt( val, 32 ) end,
    },
}

/*
*   Localized translation func
*/

local function lang( ... )
    return base:lang( ... )
end

/*
*   call id
*
*   @source : lua\autorun\libs\_calls
*   @param  : str id
*/

local function call_id( id )
    local ret = isfunction( rlib.call ) and rlib:call( 'net', id ) or id
    return ret
end

/*
*	prefix :: create id
*/

local function pref( id, suffix )
    local affix = istable( suffix ) and suffix.id or isstring( suffix ) and suffix or prefix
    affix = affix:sub( -1 ) ~= '.' and string.format( '%s.', affix ) or affix

    id = isstring( id ) and id or 'noname'
    id = id:gsub( '[%c%s]', '.' )

    return string.format( '%s%s', affix, id )
end

/*
*	prefix :: handle
*/

local function pid( str, suffix )
    local state = ( isstring( suffix ) and suffix ) or ( base and mf.prefix ) or false
    return pref( str, state )
end

/*
*   define module
*/

module( 'rnet', package.seeall )

/*
*   local declarations
*/

local pkg           = rnet
local pkg_name      = _NAME or 'rnet'

/*
*   required tables
*/

cfg                 = cfg or { }
sys                 = sys or { }

index               = index or { }
directory           = directory or { }
execute             = execute or { }
routing             = routing or { }
routing.save        = routing.save or { }
send                = { }

/*
*   net :: debugging
*   
*   determines if debugging mode is enabled
*/

cfg.debug           = cfg.debug or false

/*
*   returns directory table
*/

function get_directory( )
    return istable( directory ) and directory or { }
end

/*
*   returns index table
*/

function get_index( )
    return istable( index ) and index or { }
end

/*
*   reroute network functions
*
*   @param  : func old_fn
*   @param  : func new_fn
*/

local function act_route( old_fn, new_fn )
    if not isfunction( old_fn ) or not isfunction( new_fn ) then
        base:log( dcat, '[ %s ] bad arg type for func [ %s ]', pkg_name, debug.getinfo( 1, 'n' ).name )
        return false
    end

    execute[ new_fn ] = old_fn
    return new_fn
end

/*
*   rnet :: reroute
*
*   redirects netlib funcs to allow for prints to output to console and for logs to catch any data 
*   being transferred
*       : enable   rnet:route( bEnable )
*       : disable  rnet:route( )
*
*   @param  : bool bEnable
*/

function rnet:route( bEnable )

    local restore = routing.save or { }

    if not bEnable then
        if sys.nrouter_enabled then
            net.Start       = restore[ 'start' ] or net.Start
            net.Receive     = restore[ 'receive' ] or net.Receive
            net.Incoming    = restore[ 'incoming' ] or net.Incoming

            sys.nrouter_enabled = false
            base:log( ncat, '[%s] Rerouting disabled', pkg_name )

            return false
        else
            base:log( ncat, '[%s] Rerouting is currently not enabled', pkg_name )
            return false
        end
    end

    execute = execute or { }

    if not sys.nrouter_f or sys.nrouter_f == nil then sys.nrouter_f = true end

    if sys.nrouter_f then
        restore[ 'start' ]        = not restore[ 'start' ] and net.Start or restore[ 'start' ]
        restore[ 'receive' ]      = not restore[ 'receive' ] and net.Receive or restore[ 'receive' ]
        restore[ 'incoming' ]     = not restore[ 'incoming' ] and net.Incoming or restore[ 'incoming' ]

        net.Start = act_route( net.Start, function( name, unreliable )
            execute[ net.Start ]( name, unreliable )
            base:log( dcat, 'net.Start :: [ %s ]', name )
        end )

        net.Receive = act_route( net.Receive, function( name, callback )
            execute[ net.Receive ]( name, callback )
            base:log( dcat, 'net.Receive :: [ %s ]', name )
        end )

        sys.nrouter_enabled, sys.nrouter_f = true, false
    end

    function net.Incoming( len, client )
        local i         = net.ReadHeader( )
        local name      = util.NetworkIDToString( i )

        if not name then
            base:log( dcat, 'net.Incoming :: unpooled msg id for [ #%d ]', i )
            return false
        end

        local func = net.Receivers[ name:lower( ) ]

        if not func then
            base:log( dcat, 'net.Incoming :: receiving func missing for [ %s ] net msg [ #%d ]', name, i )
            return false
        end

        len = len - 16

        base:log( dcat, 'net.Incoming :: [ %s ] ( %d ) received ( %.2f kb ( %d b ) )', name, i, len / 8 / 1024, len / 8 )

        func( len, client )
    end

    base:log( dcat, 'netlib functions being rerouted for debugging' )
end

/*
*   status
*
*   check status of routing
*/

function route_status( )
    local status = sys.nrouter_enabled and 'enabled' or 'disabled'
    base:log( ncat, 'routing [ %s ]', status )
end

/*
*   make_id
*
*   creates a new id for directory / index entries
*
*   @param  : tbl src
*   @return : int
*/

local function make_id( src )
    if not src or not istable( src ) then
        base:log( dcat, 'cannot make id from invalid table' )
        return false
    end

    local id = table.Count( src ) + 1

    return id or 1
end

/*
*   rnet :: create
*
*   creates a new netmsg data value
*
*   @ex     :   rnet.create( 'network_string' )
*               rnet.create( call( 'net', 'network_string' ) )
*
*   @alias  :   new
*
*   @param  : str id
*/

function create( id )
    if not isstring( id ) then
        base:log( dcat, 'canceling net create - missing id' )
        return
    end

    id          = call_id( id )
    local n_id  = make_id( index )

    directory =
    {
        id      = id,
        nid     = n_id,
        params  = { },
    }

    base:log( dcat, 'created netlib entry [ %s ] [ %i ]', id, n_id )
end
new = create

/*
*   rnet :: write
*
*   used to specify a new item to pass through the netmsg
*
*   bits
*       :: number 1 to 32
*           1 = bit
*           4 = nibble
*           8 = byte
*           16 = short
*           32 = long
*
*   @ex     :   pass string:    rnet.write( 'item_name', RNET_STR )
*               pass int:       rnet.write( 'item_name', RNET_INT, 4 )
*
*   @param  : str name
*   @param  : con enum
*   @param  : int bits
*/

function write( name, enum, bits )
    local gid       = make_id( directory.params )
    bits            = bits and math.Clamp( bits, 0, 32 ) or 0

    directory.params[ name ] =
    {
        id      = gid,
        enum    = enum,
        bits    = bits
    }
end
add = write

/*
*   rnet :: register
*
*   called after setting up a new network entry
*
*   @ex     : rnet.register( )
*/

function register( )
    local id = directory.id

    if not isstring( id ) then
        base:log( dcat, 'cannot register with invalid id' )
        return false
    end

    index[ id ] = table.Copy( directory )
    if SERVER then
        util.AddNetworkString( id )
        base:log( dcat, 'registered id [ %s ]', id )
    end
end
run = register

/*
*   rnet :: read
*
*   fetches the specified const from net const table
*
*   @param  : int const
*   @param  : int bits
*   @return : tbl
*/

local function read( const, bits )
    if not netconst_lib[ const ] then
        base:log( dcat, 'invalid read type specified' )
        return false
    end

    local result = netconst_lib[ const ].read( bits )
    return result
end

/*
*   rnet :: call / get
*
*   requires id (str)
*
*   a, b are shiftable between bool / func
*   a specifies a bool for silencing the konsole or can be specified as a function but debugging
*   will return a response in the console
*
*   @param  : str id
*   @param  : bool, func a
*   @param  : func b
*/

function call( id, a, b )

    local bSilenced = false
    local action

    /*
    *   check :: a, b exist
    */

    if not a and not b then
        base:log( dcat, 'canceling netmsg call -- missing params for id [ %s ]', id )
        return false
    end

    /*
    *   get net id
    *
    *   utilizes rlib.call
    */

    id = call_id( id )

    /*
    *   a false but b provided
    */

    if not a and isfunction( b ) then
        action = b
    elseif isfunction( a ) then
        action = a
    elseif isbool( a ) and isfunction( b ) then
        bSilenced = a and true or false
        action = b
    end

    net.Receive( id, function( len, ply )
        local obj, data     = index[ id ], { }
        for item, param in SortedPairsByMemberValue( obj.params, 'id' ) do
            local bits      = param and param.bits or 0
            data[ item ]    = read( param.enum, bits )
        end

        if not action or not isfunction( action ) then
            base:log( dcat, 'call :: net.Receive :: [ %s ] :: missing action', id )
            return false
        end

        action( data, ply )

        if not bSilenced then
            base:log( dcat, 'call :: net.Receive :: [ %s ] :: %i b', id, len / 8 )
        end
    end )
end
get = call

/*
*   rnet :: setup
*
*   runs during rnet prep to setup network structure including params and read/write bit sizes (if applic)
*
*   @param  : con const
*   @param  : str val
*   @param  : int bits
*/

local function setup( const, val, bits )
    netconst_lib[ const ].write( val, bits )
end

/*
*   rnet :: prepare
*
*   data are the items that will be passed through the netmsg
*
*   @param  : str id
*   @param  : tbl data
*   @param  : bool bSilence
*/

local function prepare( id, data, bSilence )
    if not isstring( id ) then
        base:log( dcat, 'prepare :: cannot prep an invalid id' )
        return
    end

    id          = call_id( id )
    local obj   = index[ id ]

    if not istable( obj ) then
        base:log( dcat, 'prepare [ %s ] :: cannot prep an unregistered object -- check for valid module / lib hook [ %s ]', id, 'rnet.register' )
        return
    end

    net.Start( id )

    for item, param in SortedPairsByMemberValue( obj.params, 'id' ) do
        local bits = param and param.bits or 0
        setup( param.enum, data[ item ], bits )
    end

    if not bSilence then
        local sent = net.BytesWritten( )
        base:log( dcat, 'prepare [ %s ] :: %i b', id, sent )
    end
end

if SERVER then

    /*
    *   rnet :: send :: player
    *
    *   sends netmsg to specified player
    *
    *   @ex     : rnet.send.player( ply, 'netmsg_str_id', { item_id = id } )
    *           : rnet.send.player( ply, 'netmsg_str_id' )
    *
    *   @param  : ply pl
    *   @param  : str id
    *   @param  : tbl data
    *   @param  : bool bSilence
    */

    function send.player( pl, id, data, bSilence )
        if not helper.ok.ply( pl ) and not istable( pl ) then
            base:log( dcat, '[ %s ] :: [ %s ] :: invalid pl', debug.getinfo( 1, 'n' ).name, id )
            return false
        end

        if not id then
            local trcback = debug.traceback( )
            base:log( dcat, 'bad rnet id specified\n%s', trcback )
            return
        end

        local bSilenced     = bSilence and true or false
        id                  = call_id( id )

        prepare( id, data, bSilenced )
        net.Send( pl )
    end

    /*
    *   rnet :: send :: all
    *
    *   sends broadcasted netmsg to all players
    *
    *   @ex     : rnet.send.all( 'netmsg_str_id', { item_id = id } )
    *           : rnet.send.all( 'netmsg_str_id' )
    *
    *   @param  : str id
    *   @param  : tbl data
    *   @param  : bool bSilence
    */

    function send.all( id, data, bSilence )
        if not id then
            local trcback = debug.traceback( )
            base:log( dcat, 'bad rnet id specified\n%s', trcback )
            return
        end

        local bSilenced   = bSilence and true or false
        id                  = call_id( id )

        prepare( id, data, bSilenced )
        net.Broadcast( )
    end

    /*
    *   rnet :: send :: pvs
    *
    *   sends msg to players that can potentially see this position
    *
    *   @ex     : rnet.send.pvs( pos, 'netmsg_str_id', { item_id = id } )
    *           : rnet.send.pvs( Vector( 0, 0, 0 ), 'netmsg_str_id' )
    *
    *   @param  : vec vec
    *   @param  : str id
    *   @param  : tbl data
    *   @param  : bool bSilence
    */

    function send.pvs( vec, id, data, bSilence )
        if not isvector( vec ) then
            base:log( dcat, '[ %s ] :: [ %s ] :: invalid PVS vector', debug.getinfo( 1, 'n' ).name, id )
            return false
        end

        if not id then
            local trcback = debug.traceback( )
            base:log( dcat, 'bad rnet id specified\n%s', trcback )
            return
        end

        local bSilenced = bSilence and true or false

        prepare( id, data, bSilenced )
        net.SendPVS( vec )
    end

    /*
    *   rnet :: send :: pas
    *
    *   adds all plys that can potentially hear sounds from this position.
    *
    *   @ex     : rnet.send.pas( pos, 'netmsg_str_id', { item_id = id } )
    *           : rnet.send.pas( Vector( 0, 0, 0 ), 'netmsg_str_id' )
    *
    *   @param  : vec vec
    *   @param  : str id
    *   @param  : tbl data
    *   @param  : bool bSilence
    */

    function send.pas( vec, id, data, bSilence )
        if not isvector( vec ) then
            base:log( dcat, '[ %s ] :: [ %s ] :: invalid PAS vector', debug.getinfo( 1, 'n' ).name, id )
            return false
        end

        if not id then
            local trcback = debug.traceback( )
            base:log( dcat, 'bad rnet id specified\n%s', trcback )
            return
        end

        local bSilenced = bSilence and true or false

        prepare( id, data, bSilenced )
        net.SendPAS( vec )
    end

else

    /*
    *   rnet :: send.server
    *
    *   sends netmsg to server
    *
    *   @ex     : rnet.send.server( 'netmsg_str_id', { item_id = id } )
    *           : rnet.send.server( 'netmsg_str_id' )
    *
    *   @param  : str id
    *   @param  : tbl data
    */

    function send.server( id, data )
        if not id then
            local trcback = debug.traceback( )
            base:log( dcat, 'bad rnet id specified\n%s', trcback )
            return
        end

        prepare( id, data )
        net.SendToServer( )
    end
end

/*
*   scope :: server
*/

if SERVER then

    /*
    *   network strings
    */

    util.AddNetworkString( 'rnet.eff.add' )
    util.AddNetworkString( 'rnet.eff.rem' )

    /*
    *   effect :: add
    *
    *   adds a particle
    *
    *   @ex     : rnet.fx_add( 'particle_name', self, self:GetAngles( ), self:GetPos( ), nil, 1 )
    *             rnet.fx_add( 'particle_name', ent, Vector( x, x, x ), Vector( x, x, x ), 'sound/path.wav', 1, 4 )
    *             rnet.fx_add( 'particle_name', self )
    *
    *   @params : eff               name of particle
    *             snd               sound file to attach
    *             parent            parent ent
    *             ang               vector angle
    *             pos               vector position
    *             attach_id         id of the attachment to be used in the way specified by the attachType
    *             attach_type       attachment type using PATTACH_Enums
    *                               :   0   PATTACH_ABSORIGIN
    *                               :   1   PATTACH_ABSORIGIN_FOLLOW
    *                               :   2   PATTACH_CUSTOMORIGIN
    *                               :   3   PATTACH_POINT
    *                               :   4   PATTACH_POINT_FOLLOW
    *                               :   5   PATTACH_WORLDORIGIN
    *
    *   @param  : str eff
    *   @param  : ent parent
    *   @param  : vec ang
    *   @param  : vec pos
    *   @param  : str snd
    *   @param  : int attach_id
    *   @param  : int attach_type
    */

    function fx_add( eff, parent, ang, pos, snd, attach_id, attach_type )
        if not isstring( eff ) then return end
        if not IsValid( parent ) then return end

        local fx        = { }
        fx.eff          = eff
        fx.parent       = parent
        fx.ang          = isvector( ang ) and ang or IsValid( parent ) and parent:GetAngles( )
        fx.pos          = isvector( pos ) and pos or IsValid( parent ) and parent:GetPos( )
        fx.snd          = isstring( snd ) and snd or nil
        fx.attach_id    = isnumber( attach_id ) and attach_id or 1
        fx.attack_type  = isnumber( attach_type ) and attach_type or attach_type or 4

        rnet.send.all( 'rnet.eff.add', { src = fx } )
    end

    /*
    *   effect :: remove
    *
    *   removes a particle
    *
    *   @ex     : rnet.fx_rem( self, 'particle_name', nil )
    *             rnet.fx_rem( Vector( x, x, x ), 'particle_name', 'sound/file.wav' )
    *
    *   @param  : vec, ent parent
    *   @param  : str eff
    *   @param  : str snd
    */

    function fx_rem( parent, eff, snd )

        if not helper.ok.ent( parent ) and not isvector( parent ) then return end
        local pos = isvector( parent ) and parent or helper.ok.ent( parent ) and parent:GetPos( ) or Vector( 0, 0, 0 )

        local fx    = { }
        fx.eff      = eff
        fx.parent   = parent
        fx.snd      = snd

        rnet.send.all( 'rnet.eff.rem', { src = fx } )
    end

end

/*
*   scope :: client
*/

if CLIENT then

    /*
    *   rnet :: effect :: add
    *
    *   @param  : tbl data
    */

    local function fx_eff_add( data )
        local fx = data.src

        if not fx then return end
        if fx.parent == nil then return end
        if not IsValid( fx.parent ) then return end

        if fx.snd then
            fx.parent:EmitSound( fx.snd )
        end

        if fx.eff then
            if fx.attach then
                ParticleEffectAttach( fx.eff, fx.attach_type or 4 , fx.parent, fx.attach_id )
            else
                ParticleEffect( fx.eff, fx.pos, fx.ang, fx.parent )
            end
        end
    end
    rnet.call( 'rnet.eff.add', fx_eff_add )

    /*
    *   rnet :: effect :: remove
    *
    *   @param  : tbl data
    */

    local function fx_eff_rem( data )
        local fx = data.src

        if not fx then return end
        if fx.parent == nil then return end
        if not IsValid( fx.parent ) then return end

        if fx.snd then
            fx.parent:StopSound( fx.snd )
        end

        if fx.eff then
            fx.parent:StopParticlesNamed( fx.eff )
        end
    end
    rnet.call( 'rnet.eff.rem', fx_eff_rem )

end

/*
*   rcc :: debug
*
*   toggles rnet debug mode
*/

function rcc.call:RNet_Debug( ply, cmd, args )

    /*
    *   permissions
    */

    local ccmd = base.calls:get( 'commands', 'rnet_debug' )

    if ( ccmd.scope == 1 and not base.con:Is( ply ) ) then
        access:deny_consoleonly( ply, script, ccmd.id )
        return
    end

    if not access:bIsRoot( ply ) then
        access:deny_permission( ply, script, ccmd.id )
        return
    end

    local time_id   = manifest.debug_id
    local status    = args and args[ 1 ] or false
    local dur       = args and args[ 2 ] or 300

    if status and status ~= 'status' then
        local param_status = helper.util:toggle( status )
        if param_status then
            if timex.exists( time_id ) then
                local remains = timex.secs.sh_cols_steps( timex.remains( time_id ) ) or 0
                base:log( 4, lang( 'debug_enabled_already', remains ) )
                return
            end

            if dur and not helper:bIsNum( dur ) then
                base:log( ncat, lang( 'debug_err_duration' ) )
                return
            end

            cfg.debug = true
            base:log( ncat, lang( 'debug_set_enabled_dur', dur ) )
            konsole:send( ply, 1, lang( 'debug_set_enabled_dur', dur ) )

            timex.create( time_id, dur, 1, function( )
                base:log( ncat, lang( 'debug_auto_disable' ) )
                cfg.debug = false
            end )
        else
            timex.expire( time_id )
            base:log( ncat, lang( 'debug_set_disabled' ) )
            cfg.debug = false
        end
    else
        if cfg.debug then
            if timex.exists( time_id ) then
                local remains = timex.secs.sh_cols_steps( timex.remains( time_id ) ) or 0
                base:log( ncat, lang( 'debug_enabled_time', remains ) )
            else
                base:log( ncat, lang( 'debug_enabled' ) )
            end
            return
        else
            base:log( ncat, lang( 'debug_disabled' ) )
        end

        base:log( ncat, lang( 'rnet_debug_help_info_1' ) )
        base:log( ncat, lang( 'rnet_debug_help_info_2' ) )
    end
end

/*
*   rcc :: refresh
*
*   refreshes rnet
*/

function rcc.call:RNet_Refresh( ply, cmd, args )

    /*
    *   permissions
    */

    local ccmd = base.calls:get( 'commands', 'rnet_refresh' )

    if ( ccmd.scope == 1 and not base.con:Is( ply ) ) then
        access:deny_consoleonly( ply, script, ccmd.id )
        return
    end

    if not access:bIsRoot( ply ) then
        access:deny_permission( ply, script, ccmd.id )
        return
    end

    /*
    *   reload all rnet registration hooks
    */

    if not rcore then
        base.msg:route( ply, false, pkg_name, 'cannot reload rnet registration hooks -- rcore missing' )
        return
    end

    /*
    *   loop rcore modules
    */

    for k, v in pairs( rcore.modules ) do
        if not v.enabled then continue end

        local suffix    = rcore:modules_prefix( v )
        local id        = sf( '%srnet.register', suffix )

                        rhook.run.gmod( id )

        if rnet.cfg.debug then
            base:log( dcat, 'registered module [ %s ]', id )
        end
    end

    base.msg:route( ply, false, pkg_name, 'reloaded all rnet packages' )

end

/*
*   rcc :: index
*
*   returns index for rnet
*/

function rcc.call:RNet_Index( ply, cmd, args )

    /*
    *   permissions
    */

    local ccmd = base.calls:get( 'commands', 'rnet_index' )

    if ( ccmd.scope == 1 and not base.con:Is( ply ) ) then
        access:deny_consoleonly( ply, script, ccmd.id )
        return
    end

    if not access:bIsRoot( ply ) then
        access:deny_permission( ply, script, ccmd.id )
        return
    end

    /*
    *   functionality
    */

    local output    = sf( '\n\n [ %s ] :: %s :: index', script, pkg_name )
    base:console    ( ply, output )
    base:console    ( ply, '\n--------------------------------------------------------------------------------------------' )
    helper.p_table  ( index )
    base:console    ( ply, '\n--------------------------------------------------------------------------------------------' )

end

/*
*   rcc :: reroute netmsg
*
*   after being activated, all net msgs sent and received will be logged in the console.
*/

function rcc.call:RNet_Router( ply, cmd, args )

    /*
    *   permissions
    */

    local ccmd = base.calls:get( 'commands', 'rnet_router' )

    if ( ccmd.scope == 1 and not base.con:Is( ply ) ) then
        access:deny_consoleonly( ply, script, ccmd.id )
        return
    end

    if not access:bIsRoot( ply ) then
        access:deny_permission( ply, script, ccmd.id )
        return
    end

    /*
    *   functionality
    */

    local arg_toggle    = args and args[ 1 ]
    arg_toggle          = helper.util:toggle( arg_toggle )

    if not rnet then
        base:log( 2, '%s module not found, cannot toggle routing', pkg_name )
        return false
    end

    rnet:route( arg_toggle )
end

/*
*   concommand :: base command
*
*   base package command
*/

function rcc.call:RNet( ply, cmd, args )

    /*
    *   permissions
    */

    local ccmd = base.calls:get( 'commands', 'rnet' )

    if ( ccmd.scope == 1 and not base.con:Is( ply ) ) then
        access:deny_consoleonly( ply, script, ccmd.id )
        return
    end

    if not access:bIsRoot( ply ) then
        access:deny_permission( ply, script, ccmd.id )
        return
    end

    base.msg:route( ply, false, pkg_name, script .. ' package' )
    base.msg:route( ply, false, pkg_name, 'v' .. rlib.get:ver2str( manifest.version ) .. ' build-' .. manifest.build )
    base.msg:route( ply, false, pkg_name, 'developed by ' .. manifest.author )
    base.msg:route( ply, false, pkg_name, manifest.desc .. '\n' )

end

/*
*   make id
*
*   creates a package specific id
*   returns only package name if str missing
*
*   @param  : str str
*/

local function new_id( str )
    str = isstring( str ) and str ~= '' and str or false

    if not str then
        return pkg_name
    end

    return pid( str, pkg_name )
end

/*
*   register new commands
*/

local function register_commands( )

    local pkg_commands =
    {
        [ pkg_name ] =
        {
            enabled     = true,
            warn        = true,
            id          = new_id( ),
            desc        = 'returns package information',
            scope       = 2,
            clr         = Color( 255, 255, 0 ),
            assoc = function( ... )
                rcc.call:RNet( ... )
            end,
        },
        [ pkg_name .. '_debug' ] =
        {
            enabled     = true,
            warn        = true,
            id          = new_id( 'debug' ),
            desc        = 'toggles rnet debugging which must be enabled to view netmsg outputs',
            scope       = 1,
            clr         = Color( 255, 255, 0 ),
            assoc = function( ... )
                rcc.call:RNet_Debug( ... )
            end,
        },
        [ pkg_name .. '_refresh' ] =
        {
            enabled     = true,
            warn        = true,
            id          = new_id( 'refresh' ),
            desc        = 'reload all module rnet registration hooks',
            scope       = 1,
            clr         = Color( 255, 255, 0 ),
            assoc = function( ... )
                rcc.call:RNet_Refresh( ... )
            end,
        },
        [ pkg_name .. '_router' ] =
        {
            enabled     = true,
            warn        = true,
            id          = new_id( 'router' ),
            desc        = 'toggles debug mode network routing',
            scope       = 1,
            clr         = Color( 255, 255, 0 ),
            assoc = function( ... )
                rcc.call:RNet_Router( ... )
            end,
        },
        [ pkg_name .. '_index' ] =
        {
            enabled     = true,
            warn        = true,
            id          = new_id( 'index' ),
            desc        = 'returns rnet index',
            scope       = 1,
            clr         = Color( 255, 255, 0 ),
            assoc = function( ... )
                rcc.call:RNet_Index( ... )
            end,
        },
    }

    base.calls.commands:Register( pkg_commands )
end
hook.Add( pid( 'cmd.register' ), pid( '__rnet.cmd.register' ), register_commands )

/*
*   localized netlibs
*/

local function register_rnet_libs( )

    timer.Simple( 5, function( )
        create     ( 'rnet.eff.add'     )
        write      ( 'src', RNET_TBL    )
        register   ( )

        create     ( 'rnet.eff.rem'     )
        write      ( 'src', RNET_TBL    )
        register   ( )
    end )

end
register_rnet_libs( )

/*
*   register package
*/

local function register_pkg( )
    if not istable( _M ) then return end
    base.package:Register( _M )
end
hook.Add( pid( 'pkg.register' ), pid( '__rnet.pkg.register' ), register_pkg )

/*
*   module info :: manifest
*/

function pkg:manifest( )
    return self.__manifest
end

/*
*   __tostring
*/

function pkg:__tostring( )
    return self:_NAME( )
end

/*
*   create new class
*/

function pkg:loader( class )
    class = class or { }
    self.__index = self
    return setmetatable( class, self )
end

/*
*   __index / manifest declarations
*/

pkg.__manifest =
{
    __index     = _M,
    name        = _NAME,
    build       = manifest.build,
    version     = manifest.version,
    author      = manifest.author,
    desc        = manifest.desc
}

pkg.__index     = pkg