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
local prefix            = mf.prefix
local script            = mf.name
local cfg               = base.settings

/*
*   localized rlib routes
*/

local helper            = base.h
local storage           = base.s
local access            = base.a
local tools             = base.t
local konsole           = base.k
local sys               = base.sys
local timex             = timex

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
local Color             = Color
local util              = util
local table             = table
local os                = os
local coroutine         = coroutine
local player            = player
local math              = math
local string            = string
local sf                = string.format

/*
*   simplifiy funcs
*/

local function log( ... ) base:log( ... ) end
local function route( ... ) base.msg:route( ... ) end

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
    affix           = affix:sub( -1 ) ~= '.' and sf( '%s.', affix ) or affix

    id              = isstring( id ) and id or 'noname'
    id              = id:gsub( '[%c%s]', '.' )

    return sf( '%s%s', affix, id )
end

/*
*	prefix ids
*/

local function pid( str, suffix )
    local state = ( isstring( suffix ) and suffix ) or ( base and prefix ) or false
    return pref( str, state )
end

/*
*   user interaction choices
*
*   used for player input when trying to toggle certain features on or off. got tired of people not 
*   knowing what to type in order to turn something on, so here is a solution, with some added humor.
*/

local options_yes       = { 'true', '1', 'on', 'yes', 'enable', 'enabled', 'sure', 'agree', 'confirm' }
local options_no        = { 'false', '0', 'off', 'no', 'disable', 'disabled', 'nah', 'disagree', 'decline' }
local options_huh       = { 'kinda', 'sorta', 'tomorrow', 'maybe' }

/*
*   helper :: print table
*
*   prints a table to console in a structured format
*
*   @param  : tbl src
*   @param  : int indent
*   @param  : bool bSub
*/

function helper.p_table( src, indent, bSub )
    local output
    if not indent then indent = 0 end
    for k, item in pairs( src ) do
        if not bSub then
            output = '\n » ' .. string.rep( '  ', indent ) .. k .. ' » '
        else
            output = string.rep( '  ', indent ) .. k .. ': '
        end
        if type( item ) ~= 'function' then
            if type( item ) == 'table' then
                print( output )
                helper.p_table( item, indent + 2, true )
            elseif type( item ) == 'boolean' then
                print( output, tostring( item ) )
            else
                print( output, item )
            end
        end
    end
end

/*
*   ok :: validate :: all
*
*   check validation of object
*
*   @param  : ent target
*   @return : bool
*/

function helper.ok.any( target )
    return IsValid( target ) and true or false
end

/*
*   ok :: validate :: ply
*
*   checks to see if an entity is both valid and a player
*   contains other checks beforehand due to how some of the functions are written in order to cut
*   down lines of code that valid other objects
*
*   can provide bReqAlive which checks for a valid player who is also ALIVE.
*
*   @param  : ply pl
*   @param  : bool bReqAlive
*   @return : bool
*/

function helper.ok.ply( pl, bReqAlive )
    return ( ( isentity( pl ) and IsValid( pl ) and pl:IsPlayer( ) ) and ( bReqAlive and pl:Alive( ) or not bReqAlive ) and true ) or false
end

/*
*   ok :: validate :: ply alive
*
*   checks to see if an entity is both valid and a player, and also alive
*   contains other checks beforehand due to how some of the functions are written in order to cut
*   down lines of code that valid other objects
*
*   @param  : ply pl
*   @return : bool
*/

function helper.ok.alive( pl )
    return ( isentity( pl ) and IsValid( pl ) and pl:IsPlayer( ) and pl:Alive( ) and true ) or false
end

/*
*   ok :: validate :: ent
*
*   checks to see if target is entity and valid
*
*   @param  : ent targ
*   @return : bool
*/

function helper.ok.ent( targ )
    return ( isentity( targ ) and IsValid( targ ) and true ) or false
end

/*
*   ok :: validate :: veh
*
*   checks to see if target is a vehicle and valid
*
*   @param  : ent targ
*   @return : bool
*/

function helper.ok.veh( targ )
    return ( IsValid( targ ) and type( targ ) == 'Vehicle' and true ) or false
end

/*
*   ok :: validate :: npc
*
*   checks to see if target is an npc and valid
*
*   @param  : ent targ
*   @return : bool
*/

function helper.ok.npc( targ )
    return ( IsValid( targ ) and type( targ ) == 'NPC' and true ) or false
end

/*
*   ok :: validate :: null
*
*   checks to see if target is null
*
*   @param  : ent targ
*   @return : bool
*/

function helper.ok.null( targ )
    return ( targ and targ == NULL and true ) or false
end

/*
*   ok :: validate :: physobj
*
*   checks to see if a entity is both valid and a player
*
*   @param  : ent targ
*/

function helper.ok.physobj( targ )
    return ( TypeID( targ ) == TYPE_PHYSOBJ ) and IsValid( targ ) and targ ~= NULL
end

/*
*   ok :: validate :: ip
*
*   @param  : str ip
*   @return : mix 
*/

function helper.ok.ip( ip )
    if not ip then return false end
    return ip:find( '^%d%d?%d?%.%d%d?%d?%.%d%d?%d?%.%d%d?%d?$' ) and true or false
end

/*
*   ok :: validate :: port
*
*   @call   : helper.ok.port( 27015 )
*
*   @ex     : 27015     returns true
*           : 94029     returns false
*
*   @param  : str port
*   @return : bool
*/

function helper.ok.port( port )
    if not port then return false end
    return port:find( '^[2][7]%d%d%d$' ) and true or false
end

/*
*   ok :: validate :: addr (ip/port combo)
*
*   @param  : str str
*   @return : bool
*/

function helper.ok.addr( str )
    if not str then return false end
    return str:find( '^%d%d?%d?%.%d%d?%d?%.%d%d?%d?%.%d%d?%d?:[2][7]%d%d%d$' ) and true or false
end

/*
*   checks to see if a provided steam32 is valid
*
*   @param  : str sid
*   @return : bool
*/

function helper.ok.sid32( sid )
    if not sid then return end
    if sid:lower( ) == lang( 'sys_user_type' ):lower( ) then return true end
    return sid:match( '^STEAM_%d:%d:%d+$' ) ~= nil
end

/*
*   checks to see if a provided steam64 is valid
*
*   @param  : str sid
*   @return : bool
*/

function helper.ok.sid64( sid )
    return sid:match( '^7656%d%d%d%d%d%d%d%d%d%d%d%d%d+$' ) ~= nil
end

/*
*   helper :: get :: bots
*
*   return list of all bots
*
*   @ex     : for v in helper.get.bots( ) do
*
*   @param  : bool bSorted
*   @return : value
*/

function helper.get.bots( bSorted )
    return coroutine.wrap( function( )
        local sorting = not bSorted and pairs or SortedPairs
        for _, v in sorting( player.GetBots( ) ) do
            coroutine.yield( v )
        end
    end )
end

/*
*   helper :: get :: humans
*
*   return list of all human players
*
*   @ex     : for v in helper.get.humans( ) do
*
*   @param  : bool bSorted
*   @return : value
*/

function helper.get.humans( bSorted )
    return coroutine.wrap( function( )
        local sorting = not bSorted and pairs or SortedPairs
        for _, v in sorting( player.GetHumans( ) ) do
            if not helper.ok.ply( v ) then continue end
            coroutine.yield( v )
        end
    end )
end

/*
*   helper :: get :: players
*
*   return list of all players
*
*   @ex     : for v in helper.get.players( ) do
*           : for k, v in helper.get.players( true ) do
*
*   @param  : bool bKey
*   @param  : bool bSorted
*   @return : value
*/

function helper.get.players( bKey, bSorted )
    return coroutine.wrap( function( )
        local sorting = not bSorted and pairs or SortedPairs
        for _, v in sorting( player.GetAll( ) ) do
            if not helper.ok.ply( v ) then continue end
            if bKey then
                coroutine.yield( _, v )
            else
                coroutine.yield( v )
            end
        end
    end )
end

/*
*   helper :: get :: chat prefix
*
*   return the chat prefix used within a playersay
*
*   @param  : str str
*   @return : str
*/

function helper.get.cmdprefix( str )
    return string.sub( str, 1, 1 )
end

/*
*   helper :: get :: jobs
*
*   return list of all rp gamemode jobs
*   returns key and value
*
*   @ex     : for k, v in helper.get.jobs( ) do
*
*   @param  : bool bTableOnly
*   @param  : bool bSorted
*   @return : key, value
*/

function helper.get.jobs( bTableOnly, bSorted )
    if not istable( RPExtraTeams ) then return { } end
    local src = RPExtraTeams
    if bTableOnly then
        return coroutine.wrap( function( )
            coroutine.yield( src )
        end )
    end
    return coroutine.wrap( function( )
        local sorting = not bSorted and pairs or SortedPairs
        for _, v in sorting( src ) do
            coroutine.yield( _, v )
        end
    end )
end

/*
*   helper :: get :: shipements
*
*   return list of all entries in rp gamemode shipments table
*
*   @ex     : for k, v in helper.get.ships( ) do
*
*   @param  : bool bTableOnly
*   @param  : bool bSorted
*   @return : key, value
*/

function helper.get.ships( bTableOnly, bSorted )
    if not istable( CustomShipments ) then return { } end
    local src = CustomShipments
    if bTableOnly then
        return coroutine.wrap( function( )
            coroutine.yield( src )
        end )
    end
    return coroutine.wrap( function( )
        local sorting = not bSorted and pairs or SortedPairs
        for _, v in sorting( src ) do
            coroutine.yield( _, v )
        end
    end )
end

/*
*   helper :: get :: vehicles
*
*   return list of all entries in rp gamemode vehicles table
*
*   @ex     : for k, v in helper.get.veh( ) do
*
*   @param  : bool bTableOnly
*   @param  : bool bSorted
*   @return : key, value
*/

function helper.get.veh( bTableOnly, bSorted )
    if not istable( CustomVehicles ) then return { } end
    local src = CustomVehicles
    if bTableOnly then
        return coroutine.wrap( function( )
            coroutine.yield( src )
        end )
    end
    return coroutine.wrap( function( )
        local sorting = not bSorted and pairs or SortedPairs
        for _, v in sorting( src ) do
            coroutine.yield( _, v )
        end
    end )
end

/*
*   helper :: get :: food
*
*   return list of all entries in rp gamemode food table
*
*   @ex     : for k, v in helper.get.food( ) do
*
*   @param  : bool bTableOnly
*   @param  : bool bSorted
*   @return : key, value
*/

function helper.get.food( bTableOnly, bSorted )
    if not istable( FoodItems ) then return { } end
    local src = FoodItems
    if bTableOnly then
        return coroutine.wrap( function( )
            coroutine.yield( src )
        end )
    end
    return coroutine.wrap( function( )
        local sorting = not bSorted and pairs or SortedPairs
        for _, v in sorting( src ) do
            coroutine.yield( _, v )
        end
    end )
end

/*
*   helper :: get :: ents
*
*   return list of all rp gamemode jobs
*   returns key and value
*
*   @ex     : for k, v in helper.get.rpents( ) do
*
*   @param  : bool bTableOnly
*   @param  : bool bSorted
*   @return : key, value
*/

function helper.get.rpents( bTableOnly, bSorted )
    if not istable( DarkRPEntities ) then return { } end
    local src = DarkRPEntities
    if bTableOnly then
        return coroutine.wrap( function( )
            coroutine.yield( src )
        end )
    end
    return coroutine.wrap( function( )
        local sorting = not bSorted and pairs or SortedPairs
        for _, v in sorting( src ) do
            coroutine.yield( _, v )
        end
    end )
end

/*
*   helper :: get :: entities
*
*   return list of all ents
*
*   @ex     : for v in helper.get.ents( ) do
*
*   @param  : bool, str bSorted
*   @return : value
*/

function helper.get.ents( bKey, sorted )
    return coroutine.wrap( function( )
        local sorting = ( not sorted and pairs ) or ( isfunction( sorted ) and sorted ) or ( isbool( sorted ) == true and SortedPairs )
        for _, v in sorting( ents.GetAll( ) ) do
            if not IsValid( v ) then continue end
            if bKey then
                coroutine.yield( _, v )
            else
                coroutine.yield( v )
            end
        end
    end )
end

/*
*   helper :: get :: players nearby
*
*   return list of all players near a specified player
*
*   @since  : v3.0.0
*   @param  : ply pl
*   @param  : int dist
*   @return : tbl
*/

function helper.get.playersNearby( pl, dist )

    if not pl then return end
    dist = isnumber( dist ) and dist or 300

    local tab = { }
    for ply in helper.get.players( ) do
        if ( ply:GetPos( ):Distance( pl:GetPos( ) ) > dist ) then continue end

        local tr = util.TraceLine(
        {
            start   = pl:GetShootPos( ),
            endpos  = ply:GetShootPos( ),
            filter  = { ply, pl }
        })

        if ( tr.HitWorld ) then continue end

        tab[ #tab + 1 ] = ply
    end

    return tab
end

/*
*   helper :: get :: data
*
*   return list of all items in table
*
*   @ex     : for v in helper.get.data( table_name ) do
*
*   @param  : tbl tbl
*   @param  : bool, str sorted
*   @return : value
*/

function helper.get.data( tbl, sorted )
    if not istable( tbl ) then return end
    return coroutine.wrap( function( )
        local sorting = ( not sorted and pairs ) or ( isfunction( sorted ) and sorted ) or ( isbool( sorted ) == true and SortedPairs )
        for _, v in sorting( tbl ) do
            coroutine.yield( v )
        end
    end )
end

/*
*   helper :: get :: table
*
*   return list of all items in table
*   similar to helper.get.data except returns
*   key and value in table
*
*   @ex     : for k, v in helper.get.data( table_name ) do
*
*   @param  : tbl tbl
*   @param  : bool, str sorted
*   @return : key, val
*/

function helper.get.table( tbl, sorted )
    if not istable( tbl ) then return end
    return coroutine.wrap( function( )
        local sorting = ( not sorted and pairs ) or ( isfunction( sorted ) and sorted ) or ( isbool( sorted ) == true and SortedPairs )
        for _, v in sorting( tbl ) do
            coroutine.yield( _, v )
        end
    end )
end

/*
*   helper :: get :: sorted
*
*   much like helper.get.data but more specific to your needs
*
*   @param  : tbl tbl
*   @param  : int itype
*           : type 1    : pairs
*           : type 2    : ipairs
*           : type 3    : SortedPairs
*           : type 4    : SortedPairsByMemberValue
*           : type 5    : SortedPairsByValue
*   @param  : bool, str val
*/

function helper.get.sorted( tbl, itype, val )
    if not istable( tbl ) then return end
    return coroutine.wrap( function( )
        local sorting = ( itype == 1 and pairs ) or ( itype == 2 and ipairs ) or ( itype == 3 and SortedPairs ) or ( itype == 4 and SortedPairsByMemberValue ) or ( itype == 5 and SortedPairsByValue ) or pairs
        for _, v in sorting( tbl, val ) do
            coroutine.yield( v )
        end
    end )
end

/*
*   helper :: get :: sorted
*
*   much like helper.get.data but more specific to your needs
*
*   @param  : tbl tbl
*   @param  : int itype
*           : type 1    : pairs
*           : type 2    : ipairs
*           : type 3    : SortedPairs
*           : type 4    : SortedPairsByMemberValue
*           : type 5    : SortedPairsByValue
*   @param  : bool, str val
*/

function helper.get.sorted_k( tbl, itype, val )
    if not istable( tbl ) then return end
    return coroutine.wrap( function( )
        local sorting = ( itype == 1 and pairs ) or ( itype == 2 and ipairs ) or ( itype == 3 and SortedPairs ) or ( itype == 4 and SortedPairsByMemberValue ) or ( itype == 5 and SortedPairsByValue ) or pairs
        for _, v in sorting( tbl, val ) do
            coroutine.yield( _, v )
        end
    end )
end

/*
*   helper :: get :: avg player ping
*
*   for diagnostic purposes
*
*   records the ping of all players on the server and then divides the number by the total number of
*   players on the server.
*
*   :   ( bool ) bSortHighest
*       instead of fetching the average, the highest ping of all players will return
*   
*   @param  : bool bSortHighest
*   @return : int
*/

function helper.get.avgping( bSortHighest )
    return coroutine.wrap( function( )
        local calc_ping = 0
        for _, v in pairs( player.GetAll( ) ) do
            if bSortHighest then
                if v:Ping( ) > calc_ping then calc_ping = v:Ping( ) end
                continue
            end
            calc_ping = calc_ping + v:Ping( )
        end
        if not bSortHighest then
            calc_ping = math.Round( calc_ping / #player.GetHumans( ) )
        end
        coroutine.yield( calc_ping )
    end )
end

/*
*   helper :: get :: shuffle
*
*   shuffles items in a table
*
*   @param  : tbl tbl
*   @return : tbl
*/

function helper.get.shuffle( tbl )
    if not istable( tbl ) then return end
    return coroutine.wrap( function( )
        size = #tbl
        for i = size, 1, -1 do
            local rand = math.random( size )
            tbl[ i ], tbl[ rand ] = tbl[ rand ], tbl[ i ]
        end
        coroutine.yield( tbl )
    end )
end

/*
*   helper :: get :: groupmatch
*
*   returns if a pl usergroup matches tbl
*
*   @param  : tbl tbl
*   @param  : ply pl
*   @return : bool
*/

function helper.get.groupmatch( tbl, pl )
    for v in helper.get.data( tbl ) do
        if v == pl:getgroup( true ) then
            return true
        end
    end
    return false
end

/*
*   helper :: get :: datetime now
*
*   @call   : helper.get.now( )
*           : helper.get.now( '%Y-%m-%d' )
*
*   @param  : str flags
*   @return : str
*/

function helper.get.now( flags )
    return flags and os.date( flags ) or os.date( '%Y-%m-%d %H:%M:%S' )
end

/*
*   helper :: get :: increment
*
*   @call   : helper.get.increment( var )
*             returns var + 1
*
*           : helper.get.i( var, 2 )
*             returns var + 2
*
*   @param  : int i
*   @param  : int add
*   @return : int
*/

function helper.get.increment( i, add )
    i       = isnumber( i ) and i or tonumber( i ) or i
    add     = isnumber( add ) and add or 1
    i       = i + add

    return i
end
helper.get.i = helper.get.increment

/*
*   helper :: get :: has population
*
*   @call   : helper.get.haspop( )
*
*   @return : bool
*/

function helper.get.haspop( )
    return #player.GetHumans( ) > 0 and true or false
end

/*
*   helper :: get :: population
*
*   @call   : helper.get.popcount( )
*
*   @return : int
*/

function helper.get.popcount( )
    return #player.GetAll( ) or 0
end

/*
*   helper :: get :: id
*
*   makes a new id based on the specified varargs
*   all special characters and spaces are replaced with [ . ] char
*
*   @note   : ply associated func pmeta:cid( ... )
*
*   @ex     : timer_id = helper.get.id( 'timer', 'frostshell'  )
*   @res    : timer.frostshell
*
*   @param  : varg { ... }
*/

function helper.get.id( ... )
    local args          = { ... }
    local resp          = table.concat( args, '_' )
    resp                = resp:lower( )
    resp                = resp:gsub( '[%p%c]', '.' )
    resp                = resp:gsub( '[%s]', '_' )

    return resp
end

/*
*   helper :: get :: utf8 icons
*
*   returns the proper utf8 icon for the str provided
*
*   @param  : str id
*/

function helper.get:utf8( id )
    id = isstring( id ) and id or 'default'
    local val = base._def.utf8[ id ]

    return utf8.char( val )
end

/*
*   helper :: get :: utf8 :: char
*
*   converts int to utf8 char
*
*   @param  : str id
*/

function helper.get:utf8char( id )
    id = isnumber( id ) and id or tonumber( id )

    return utf8.char( id )
end

/*
*   helper :: ply :: usergroup
*
*   gets a players usergroup
*
*   @param  : ply pl
*   @param  : bool bLowercase
*   @return : str
*/

function helper.ply.ugroup( pl, bLowercase )
    if not IsValid( pl ) or not pl:IsPlayer( ) then return end
    return bLowercase and helper.str:clean( pl:GetUserGroup( ) ) or pl:GetUserGroup( )
end

/*
*   helper :: ply :: alias
*
*   gets a players alias
*   alt version of pmeta:palias( )
*
*   @param  : ply pl
*   @param  : str override
*   @return : str
*/

function helper.ply.alias( pl, override )
    if not IsValid( pl ) or not pl:IsPlayer( ) then return end
    return pl:palias( override )
end

/*
*   return counted items
*
*   second param determines how many to add to increment value
*   typically this will just be 1 ( +1 ) per result found
*
*   @usage  : local i = helper.countdata( cfg.table, 'tablerow' )( )
*           : local i = helper.countdata( v, 1 )( )
*
*   @param  : tbl tbl
*   @param  : int i
*   @param  : str target
*   @param  : str check
*/

function helper.countdata( tbl, i, target, check )
    if not istable( tbl ) then return end
    i = isnumber( i ) and i or 1
    return coroutine.wrap( function( )
        local cnt = 0
        for _, v in pairs( tbl ) do
            if check and not v[ check ] then continue end
            if target and v[ target ] then
                cnt = cnt + v[ target ] + i
            else
                cnt = cnt + i
            end
        end
        coroutine.yield( cnt )
    end )
end
helper.countData = helper.countdata

/*
*   helper :: emts :: count
*
*   second param determines how many to add to increment value
*   typically this will just be 1 ( +1 ) per result found
*
*   @usage  : local i = helper.ent.count( 'ent_name' )( )
*           : local i = helper.ent.count( 'ent_name', 1 )( )
*
*   @param  : tbl tbl
*   @param  : int i
*/

function helper.ent.count( ent, i )
    if not ent then return end
    i = isnumber( i ) and i or 1
    return coroutine.wrap( function( )
        local cnt = 0
        for v in helper.get.data( ents.FindByClass( ent ) ) do
            cnt = cnt + i
        end
        coroutine.yield( cnt )
    end )
end

/*
*   helper :: ents :: find
*
*   returns list of ents by class
*
*   @ex     : for v in helper.ent.find( 'class_id' ) do
*           : for k, v in helper.ent.find( 'class_id', true ) do
*
*   @param  : str ent
*   @param  : bool bKey
*   @return : value
*/

function helper.ent.find( ent, bKey )
    return coroutine.wrap( function( )
        for _, v in pairs( ents.FindByClass( ent ) ) do
            if not helper.ok.ent( v ) then continue end
            if bKey then
                coroutine.yield( _, v )
            else
                coroutine.yield( v )
            end
        end
    end )
end

/*
*   packages :: register
*
*   library includes numerous packages which will be registered and stored in their own table
*   packages include timex, rnet, and calc
*
*   package manifests stored in rlib.package.index
*
*   @param  : tbl pkg
*/

function base.package:Register( pkg )
    if not istable( pkg ) then return end
    if not istable( pkg.__manifest ) then
        log( 2, 'skipping package registration for [ %s ] » missing manifest', pkg._NAME )
        return
    end

    local id = tostring( pkg._NAME )

    self.index = self.index or { }
    self.index[ id ] =
    {
        name    = pkg._NAME,
        desc    = pkg.__manifest.desc,
        author  = pkg.__manifest.author,
        build   = pkg.__manifest.build,
        version = pkg.__manifest.version,
    }
end

/*
*   packages :: installed
*
*   checks to see if a module is indeed available to use
*
*   @ex     :   rlib.package:bInstalled( 'glon', mod )
*               rlib.package:bInstalled( 'rnet', 'module' )
*
*   @param  : str name
*   @param  : tbl, str requester
*   @return : bool
*/

function base.package:bInstalled( name, requester )
    if not name then return end
    name = isstring( name ) and name or tostring( name )

    local id = requester or script

    if ( isstring( requester ) and istable( rcore ) and rcore.modules[ requester ] and rcore.modules[ requester ].enabled ) then
        id = rcore.modules[ requester ].name
    elseif ( istable( requester ) and requester.enabled ) then
        id = requester.name
    elseif ( istable( requester ) and not requester.name ) then
        id = script
    end

    if package.loaded[ name ] then return true end

    for _, v in ipairs( package.searchers or package.loaders ) do
        local loader = v( name )
        if isfunction( loader ) then
            package.preload[ name ] = loader
            return true
        end
    end

    log( 2, 'missing module [ %s ] » required for [ %s ]', name, id )

    return false
end

/*
*   initialize :: modules
*
*   utilizes require to load modules
*/

local function lib_initialize_modules( )

    /*
    *   require
    */


end
hook.Add( pid( 'initialize.post' ), pid( 'initialize_modules' ), lib_initialize_modules )

/*
*   access :: ulx_getgroup
*
*   specifies the default usergroup that will be allowed to access a command.
*   typically used in conjunction with access:getperm( perm, mod ).access
*
*   @assoc  : access:initialize( )
*
*   @ex     : access:ulx_getgroup( 'superadmin' )
*           : returns ULib.ACCESS_SUPERADMIN
*
*   @ex     : access:ulx_getgroup( access:getperm( perm, mod ).access )
*
*   @param  : str ugroup
*   @return : tbl
*/

function access:ulx_getgroup( ugroup )
    local groups =
    {
        [ 'superadmin' ]    = ULib.ACCESS_SUPERADMIN,
        [ 'admin' ]         = ULib.ACCESS_ADMIN,
        [ 'operator' ]      = ULib.ACCESS_OPERATOR,
        [ 'moderator' ]     = ULib.ACCESS_OPERATOR,
        [ 'all' ]           = ULib.ACCESS_ALL,
        [ 'user' ]          = ULib.ACCESS_ALL
    }

    return ( ugroup and groups[ ugroup ] ) or groups[ 'superadmin' ]
end

/*
*   access :: get perm
*
*   returns the associated permission data
*
*   @call   : access:getperm( perm, mod )
*   @ex     : access:getperm( 'rlib_asay' )
*             access:getperm( 'rlib_asay', 'rlib' )
*             access:getperm( 'apollo_hasaccess', mod )
*             access:getperm( 'apollo_hasaccess', 'apollo' )
*
*   @param  : str perm
*   @param  : str, tbl mod
*   @return : str || tbl
*/

function access:getperm( perm, mod )
    if not isstring( perm ) or not rcore then return end
    if ( mod == mf.name and base.permissions[ perm ] ) or ( not mod and base.permissions[ perm ] ) then
        return base.permissions[ perm ]
    end
    return not mod and perm or ( isstring( mod ) and rcore.modules[ mod ] and rcore.modules[ mod ].permissions[ perm ] ) or ( istable( mod ) and mod.permissions[ perm ] )
end
access.gperm = access.getperm

/*
*   access :: get perm :: id
*
*   returns the name or id of a permission
*
*   @call   : access:getperm_id( perm, mod )
*           : access:pid( perm, mod )
*
*   @param  : str perm
*   @param  : str, tbl mod
*   @return : str
*/

function access:getperm_id( perm, mod )
    if not isstring( perm ) or not rcore then return end
    if ( mod == mf.name and base.permissions[ perm ] ) or ( not mod and base.permissions[ perm ] ) then
        return base.permissions[ perm ]
    end

    local permission = not mod and perm or ( isstring( mod ) and rcore.modules[ mod ] and rcore.modules[ mod ].permissions[ perm ] ) or ( istable( mod ) and mod.permissions[ perm ] )
    return ( permission and ( permission.name or permission.id ) or perm )
end
access.pid = access.getperm_id

/*
*   access :: ulx
*
*   specifies the default usergroup that will be allowed to access a command.
*   used with ulx modules
*
*   @assoc  : access:ulx_getgroup
*           : access:getperm
*
*   @ex     : access:ulx( 'rcore_tools_pco', mod )
*
*   @param  : str perm
*   @param  : tbl, str mod
*   @return : str
*/

function access:ulx( perm, mod )
    return self:ulx_getgroup( self:getperm( perm, mod ).access or self:getperm( perm, mod ).usrlvl )
end

/*
*   access :: has perm
*
*   works in conjunction with access:allow( ) except calling this func will first check to see if the 
*   player has the proper access, and if not, it will toss an error to the pl stating 
*   'invalid perm'
*
*   @assoc  : access:validate( )
*
*   @param  : ply pl
*   @param  : str perm
*   @return : bool
*/

function access:hasperm( pl, perm, bThrowErr )
    if not access:validate( pl, perm ) then
        local str_perm = perm and tostring( perm ) or lang( 'action_requested' )
        base.msg:route( pl, false, script, lang( 'perms_invalid' ), cfg.cmsg.clrs.target, str_perm )
        return false
    end
    return true
end

/*
*   access :: deny_permission
*
*   returns a perm denied error without utilizing access:allow( )
*   useful for other types of perm checks
*
*   @oaram  : ply pl
*   @param  : tbl, str mod
*   @param  : str perm
*   @return : str, false
*/

function access:deny_permission( pl, mod, perm )
    mod = istable( mod ) and mod.name or isstring( mod ) and mod
    local str_perm = perm and tostring( perm ) or lang( 'action_requested' )
    route( pl, false, mod, lang( 'perms_invalid' ), cfg.cmsg.clrs.target, str_perm )
    return false
end

/*
*   access :: deny_consoleonly
*
*   returns a perm denied error related to executing a server scope command elsewhere
*
*   @todo   : merge deny_consoleonly and deny_console
*
*   @oaram  : ply pl
*   @param  : tbl, str mod
*   @param  : str perm
*   @return : str, false
*/

function access:deny_consoleonly( pl, mod, perm )
    mod = istable( mod ) and isstring( mod.name ) and mod.name or isstring( mod ) and mod or tostring( mod )
    local str_perm = perm and tostring( perm ) or lang( 'action_requested' )
    route( pl, false, mod, 'command', cfg.cmsg.clrs.target, str_perm, cfg.cmsg.clrs.msg, 'must be executed', cfg.cmsg.clrs.target_sec, 'server-side only' )
    return false
end

/*
*   access :: deny_console
*
*   returns a perm denied error for console called commands
*
*   @todo   : merge deny_consoleonly and deny_console
*
*   @oaram  : ply pl
*   @param  : tbl, str mod
*   @param  : str perm
*   @return : str
*/

function access:deny_console( pl, mod, perm )
    mod = istable( mod ) and isstring( mod.name ) and mod.name or isstring( mod ) and mod or tostring( mod )
    local str_perm = perm and tostring( perm ) or lang( 'action_requested' )
    route( pl, false, mod, 'command ', cfg.cmsg.clrs.target, str_perm, cfg.cmsg.clrs.msg, 'must be called by valid player and not by', cfg.cmsg.clrs.target_sec, 'console' )
    return false
end

/*
*   access :: is owner
*
*   returns if a player is the owner of a script
*
*   @param  : ply pl
*   @return : bool
*/

function access:bIsOwner( pl )
    if not helper.ok.ply( pl ) then return false end

    local owners = base.get:owners( ) or { }
    if table.HasValue( owners, pl:SteamID64( ) ) then return true end

    return false
end

/*
*   access :: is root
*
*   functionality with this restriction means very few people will be able to use the feature
*   
*   returns true on condition:
*       : is superadmin    [ based on glua GetUserGroup( ) ]
*       : is admin         [ internal ]
*       : is owner         [ internal ]
*       : is dev           [ internal ]
*
*   @param  : ply pl
*   @param  : bool bNoConsole
*   @return : bool
*/

function access:bIsRoot( pl, bNoConsole )
    if ( not bNoConsole and base.con:Is( pl ) ) or ( helper.ok.ply( pl ) and ( access:bIsOwner( pl ) or access:bIsDev( pl ) or access:bIsAdmin( pl ) or pl:IsSuperAdmin( ) ) ) then
        return true
    end
    return false
end

/*
*   access :: is developer
*
*   rlib features a developer console which should only be accessed by the developer of the script.
*
*   this doesnt give the developer any special permissions to do anything to a server other than
*   to read more in-depth debugging info
*
*   script owners could have access but i felt it may be annoying to server owners to have text
*   scrolling in the bottom right of their screen.
*
*   @param  : ply pl
*   @return : bool
*/

function access:bIsDev( pl )
    if base.con:Is( pl ) then return true end

    if not mf.developers then return end
    local devs = mf.developers or { }
    if table.HasValue( devs, pl:SteamID64( ) ) then return true end

    return false
end

/*
*   access :: is admin
*
*   much like bIsDev; but separates the list for protection, and eventually additional features will 
*   be added.
*
*   only give this to users you trust
*
*   @param  : ply pl
*   @return : bool
*/

function access:bIsAdmin( pl )
    if base.con:Is( pl ) then return true end

    if not access.admins then return end
    local pl_sid = pl:SteamID( )

    if access.admins[ pl_sid ] then return true end

    return false
end

/*
*   access :: validate
*
*   checks to see if a player has perm to utilize the desired perm.
*
*   @ex     : rlib.a:validate( ply, rlib.permissions[ 'core_permission_name' ].id )
*
*   @param  : ply pl
*   @param  : str, tbl perm
*   @return : bool
*/

function access:validate( pl, perm )
    if not IsValid( pl ) then
        if base.con:Is( pl ) then return true end
        return false
    end

    if pl:IsSuperAdmin( ) then return true end
    if self:bIsRoot( pl ) then return true end

    if not isstring( perm ) and not istable( perm ) then return false end

    if ulx then
        -- Work around for ulib.authed issue
        local unique_id = pl:UniqueID( )
        if CLIENT and game.SinglePlayer( ) then unique_id = '1' end

        perm = ( istable( perm ) and perm.id ) or perm
        if not ULib or not ULib.ucl.authed[ unique_id ] then return end
        if ULib.ucl.query( pl, perm ) then return true end
    elseif maestro then
        perm = ( istable( perm ) and perm.id ) or perm
        if maestro.rankget( maestro.userrank( pl ) ).flags[ perm ] then return true end
    elseif evolve then
        perm = ( istable( perm ) and perm.id ) or perm
        if pl:EV_HasPrivilege( perm ) then return true end
    elseif serverguard then
        perm = ( istable( perm ) and ( perm.name or perm.id ) ) or isstring( perm ) and perm
        if serverguard.player:HasPermission( pl, perm ) then return true end
    end

    return false
end

/*
*   access :: allow
*
*   checks to see if a ply has access to a specified perm
*
*   this function is similar to access:validate( ) which will be deprecated soon for the allow() which
*   combines all checks together.
*
*   @assoc  : rlib.a:validate( pl, rlib.permissions[ 'core_permission_name' ].id )
*   @since  : v1.1.5
*
*   @param  : ply pl
*   @param  : str perm
*   @param  : str, tbl mod
*   @return : bool
*/

function access:allow( pl, perm, mod )
    if not IsValid( pl ) then
        if base.con:Is( pl ) then return true end
        return false
    end

    if pl:IsSuperAdmin( ) then return true end
    if self:bIsRoot( pl ) then return true end

    if not isstring( perm ) then return false end
    if mod then
        perm = self:getperm( perm, mod )
    end

    if ulx then
        -- Work around for ulib.authed issue
        local unique_id = pl:UniqueID( )
        if CLIENT and game.SinglePlayer( ) then unique_id = '1' end

        perm = ( istable( perm ) and perm.id ) or perm
        if not ULib or not ULib.ucl.authed[ unique_id ] then return end
        if ULib.ucl.query( pl, perm ) then return true end
    elseif maestro then
        perm = ( istable( perm ) and perm.id ) or perm
        if maestro.rankget( maestro.userrank( pl ) ).flags[ perm ] then return true end
    elseif evolve then
        perm = ( istable( perm ) and perm.id ) or perm
        if pl:EV_HasPrivilege( perm ) then return true end
    elseif serverguard then
        perm = ( istable( perm ) and ( perm.name or perm.id ) ) or isstring( perm ) and perm
        if serverguard.player:HasPermission( pl, perm ) then return true end
    end

    return false
end

/*
*   access :: strict
*
*   similar to access:allow( ), however, does not take special circumstances into account
*   such as IsSuperAdmin or root
*
*   checks to see if a pl has access to a specified perm
*
*   this function is similar to access:validate( ) which will be deprecated soon for the allow() which
*   combines all checks together.
*
*   @assoc  : rlib.a:validate( pl, rlib.permissions[ 'core_permission_name' ].id )
*   @since  : v3.0.0
*
*   @param  : ply pl
*   @param  : str perm
*   @param  : str, tbl mod
*   @return : bool
*/

function access:strict( pl, perm, mod )
    if not IsValid( pl ) then
        if base.con:Is( pl ) then return true end
        return false
    end

    if not isstring( perm ) then return false end
    if mod then
        perm = self:getperm( perm, mod )
    end

    if ulx then
        -- Work around for ulib.authed issue
        local unique_id = pl:UniqueID( )
        if CLIENT and game.SinglePlayer( ) then unique_id = '1' end

        perm = ( istable( perm ) and perm.id ) or perm
        if not ULib or not ULib.ucl.authed[ unique_id ] then return end
        if ULib.ucl.query( pl, perm ) then return true end
    elseif maestro then
        perm = ( istable( perm ) and perm.id ) or perm
        if maestro.rankget( maestro.userrank( pl ) ).flags[ perm ] then return true end
    elseif evolve then
        perm = ( istable( perm ) and perm.id ) or perm
        if pl:EV_HasPrivilege( perm ) then return true end
    elseif serverguard then
        perm = ( istable( perm ) and ( perm.name or perm.id ) ) or isstring( perm ) and perm
        if serverguard.player:HasPermission( pl, perm ) then return true end
    end

    return false
end

/*
*   access :: allow :: throwExcept
*
*   utilizes access:allow but also throws an error to the pl about permissions
*
*   @oaram  : ply pl
*   @param  : str perm
*   @param  : str, tbl mod
*   @param  : str msg
*   @return : str, false
*/

function access:allow_throwExcept( pl, perm, mod, msg )
    local bChk = self:allow( pl, perm, mod )
    if not bChk then
        msg = isstring( msg ) and msg or 'You lack permission to'
        base.msg:target( pl, ( mod and mod.name ) or mf.name, msg, cfg.cmsg.clrs.target_tri, tostring( perm ) )
        return false
    end

    return true
end

/*
*   access :: strict :: throwExcept
*
*   utilizes access:strict but also throws an error to the ply about permissions
*
*   @oaram  : ply pl
*   @param  : str perm
*   @param  : str, tbl mod
*   @param  : str msg
*   @return : str, false
*/

function access:strict_throwExcept( pl, perm, mod, msg )
    local bChk = self:strict( pl, perm, mod )
    if not bChk then
        msg = isstring( msg ) and msg or 'You lack permission to'
        base.msg:target( pl, ( mod and mod.name ) or mf.name, msg, cfg.cmsg.clrs.target_tri, tostring( perm ) )
        return false
    end

    return true
end

/*
*   helper :: str :: split address:port
*
*   splits ip:port into two variables
*   
*   @ex     : ip, port = helper.str:split_addr( '127.0.0.1:27015' )
*             ip = 127.0.0.1
*             port = 27015
*
*   @param  : str val
*/

function helper.str:split_addr( val )
    if not val then return false end
    return unpack( string.Split( val, ':' ) )
end

/*
*   helper :: mew :: id
*
*   created a random string of a speciifed length
*
*   @call   : helper.new.id( len )
*   @ex     : helper.new.id( 10 )
*
*   @param  : int len
*   @return : str
*/

function helper.new.id( len )
    len = isnumber( len ) and len or tonumber( len ) or 10

    local charset =
    {
        '0', '1', '2', '3', '4', '5', '6', '7', '8', '9',
        'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j',
        'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't',
        'u', 'v', 'w', 'x', 'y', 'z'
    }

    local response = ''
    for i = 1, len do
        local index = math.random( 1, #charset )
        response = response .. charset[ index ]
    end

    return response
end

/*
*   helper :: new :: uid
*
*   created a random string of a speciifed length
*   dont use this method via  loop otherwise all uids will be the same
*   (unless you want that)
*
*   @call   : helper.new.uid( len )
*   @ex     : helper.new.uid( 10 )
*
*   @param  : int len
*   @return : str
*/

function helper.new.uid( len )
    len = isnumber( len ) and len or 8
    math.randomseed( os.time( ) )
    local response = ''

    for i = 1, len do
        response = response .. string.char( math.random( 65, 90 ) )
    end

    return response
end

/*
*   helper :: new :: hash
*
*   creates a hash with either a specified seed or random
*
*   @param  : int len
*   @param  : int seed
*   @return : str
*/

function helper.new.hash( len, seed )
    len     = isnumber( len ) and len or tonumber( len ) or 10
    seed    = isnumber( seed ) and seed or os.time( )

    local charset = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789'

    math.randomseed( seed )

    local chars = { }
    for v in charset:gmatch( '.' ) do
        table.insert( chars, v )
    end

    local response = ''
    for i = 1, len do
        local index = math.random( 1, #chars )
        response = response .. chars[ index ]
    end

    return response
end

/*
*   helper :: str :: uppercase first
*
*   takes the first letter of a string and transforms to upper-case
*
*   @param  : str str
*   @return : str
*/

function helper.str:ucfirst( str )
    return str:gsub( '^%l', string.upper )
end

/*
*   helper :: str :: clean
*
*   by default, transforms all text to lowercase and replaces any spaces with underscores.
*
*   ( bool )    bRemove
*               will remove all space chars instead of replace
*
*   @param  : str str
*   @param  : bool bRemove
*   @return : str
*/

function helper.str:clean( str, bRemove )
    str = isstring( str ) and str or tostring( str )
    str = str:lower( )
    str = bRemove and str:gsub( '%s+', '' ) or str:gsub( '%s+', '_' )

    return str
end

/*
*   helper :: str :: escape
*
*   strips any special characters, controls, and spaces
*
*       %c      :   represents all control characters           ( special characters "\t", "\n", etc. )
*       %p      :   represents all punctuation characters       ( ".", ",", etc. )
*       %s      :   represents all space characters             ( a normal space, tab, etc. )
*
*   ( bool )    bKeepCase
*               will not use :lower( ) on string
*
*   @param  : str str
*   @param  : bool bKeepCase
*   @return : str
*/

function helper.str:escape( str, bKeepCase )
    str = isstring( str ) and str or tostring( str )
    str = not bKeepCase and str:lower( ) or str
    str = str:gsub( '[%c%p]', '' )
    str = str:gsub( '[%s]', '_' )

    return str
end

/*
*   helper :: str :: clean whitespace
*
*   cleans whitespace from beginning and end of string
*
*   @param  : str str
*   @return : str
*/

function helper.str:clean_ws( str )
    return str:match( '^%s*(.-)%s*$' ) -- fix '
end

/*
*   helper :: str :: length
*
*   returns w, h of str size
*
*   @param  : str str
*   @param  : str font
*   @param  : int offset
*   @param  : int min
*   @param  : int max
*   @return : int, int
*/

function helper.str:len( str, font, offset, min_x, max_x, min_y, max_y )
    if not str then return end
    if not font then return end
    offset = isnumber( offset ) and offset or 0

    surface.SetFont( font )
    local x, y = surface.GetTextSize( str )
    x = x + offset

    x = ( isnumber( min_x ) and x < min_x and min_x ) or x
    x = ( isnumber( max_x ) and x > max_x and max_x ) or x

    y = ( isnumber( min_y ) and y < min_y and min_y ) or y
    y = ( isnumber( max_y ) and y > max_y and max_y ) or y

    return x, y
end

/*
*   helper :: str :: empty str
*
*   checks for a valid string but also checks for blank or space chars

*   @param  : str str
*   @return : bool
*/

function helper.str:isempty( str )
    if not str then return true end

    local text = str:gsub( '%s', '' )
    if not isstring( text ) or text == '' or text == 'NULL' or str == NULL then return true end
    return false
end

/*
*   helper :: str :: starts with
*
*   determines if a string starts with a particular word/char
*
*   @param  : str str
*   @param  : str starts
*   @return : str
*/

function helper.str:startsw( str, starts )
    if not isstring( str ) or not isstring( starts ) then return end
    return string.sub( str, 1, string.len( starts ) ) == starts
end

/*
*   helper :: str :: ends with
*
*   determines if a string ends with a particular word/char
*
*   @param  : str str
*   @param  : str ends
*   @return : bool
*/

function helper.str:endsw( str, ends )
    if not isstring( str ) and not isstring( ends ) then return end
    return ends == '' or string.sub( str, -string.len( ends ) ) == ends
end

/*
*   helper :: str :: count spaces
*
*   ensure string contains no special characters
*
*   @call   : helper.str:count_spaces( 'random string msg' ) :: returns 2
*
*   @param  : str text
*   @return : int
*/

function helper.str:count_spaces( text )
    text = tostring( text )
    local i = 0
    for k in string.gmatch( text:Trim( ), '.' ) do
        if k ~= ' ' then continue end
        i = i + 1
    end

    return i
end

/*
*   helper :: str :: leader
*
*   used for evening out rows of data with a 'leader'
*   counts the number of chars in a string and adds on series of leading chars until the str hits max so
*   that all rows are even in width / char count.
*
*   @swap   :   ( a, b )
*
*           :   ( a )
*               bool    : determines if a space should be added at the beginning of the orig str
*               str     : char to use for leader ( def = period [ . ] )
*
*           :   ( b )
*               str     : char to use for leader ( def = period [ . ] )
*
*   @usage  :   local item = helper.str:leader( 'string', 20, true )
*               output  'string .............'
*
*           :   local item = helper.str:leader( 'string', 20, '.' )
*               output  'string..............'
*
*           :   local item = helper.str:leader( 'string', 20, true, '|' )
*               output  'string |||||||||||||'
*
*   @out    :   example-text................
*           :   second-item.................
*           :   third.......................
*
*   @param  : str str
*   @param  : int max [optional]
*   @param  : str, bool a [optional]
*   Wparam  : str b [optional]
*   @return : str
*/

function helper.str:leader( str, max, a, b )
    str = tostring( str )

    max = isnumber( max ) and max or tonumber( max ) or 20

    local bSpace    = isbool( a ) and true or false
    local leader    = isstring( b ) and b or isstring( a ) and a or '.'
    local sz_str    = str:len( )
    local sz_add    = max - sz_str
    sz_add          = tonumber( sz_add )
    str             = bSpace and str .. ' ' or str
    sz_add          = bSpace and ( sz_add - 1 ) or sz_add

    if sz_add < 1 then return str end

    for i = 1, sz_add do
        str = str .. leader
    end

    -- add blank space at end of str
    str = bSpace and str .. ' ' or str

    return str
end

/*
*   helper :: str :: valididate
*
*   simply ensures a str is cleaned up and not left blank
*
*   @param  : str str
*   @return : bool, str
*/

function helper.str:valid( str )
    if not isstring( str ) then return end

    str = string.Trim( str )
    if str ~= nil and str ~= '' then
        return true, str
    end

    return false, str
end

/*
*   helper :: str :: truncate
*
*   shortens the provided string down based on a length specified
*
*   @call   : helper.str:truncate( 'this is a test string', 12 )
*           : 'this is a te...'
*
*   @param  : str str
*   @param  : int limit [min: 5]
*   @param  : str affix
*   @return : str
*/

function helper.str:truncate( str, limit, affix )
    limit = limit or 9
    affix = affix or '...'

    if limit < 5 then limit = 5 end

    if str:len( ) > limit then
        str = string.sub( str, 1, limit - 3 ) .. affix
    else
        str = sf( '%9s' , str )
    end

    return string.TrimLeft( str, ' ' )
end

/*
*   helper :: str :: simple strip
*
*   performs a simple strip on a string with the given filter
*
*   @param  : str str
*   @param  : str chrs
*   @return : str
*/

function helper.str:strip( str, chrs )
    return str:gsub( '[' .. chrs:gsub( '%W', '%%%1' ) .. ']', '' )
end

/*
*   helper :: str :: wordwrap
*
*   takes a string and splits them into smaller lines and converts the result to a table with each line
*   being an entry
*
*   @param  : str str
*   @param  : int limit
*   @return : str
*/

function helper.str:wordwrap( str, limit )
    if not isstring( str ) then return end
    limit = isnumber( limit ) and limit or 100

    local seg, pos  = '', 1
    local resp, c   = { }, 0
    str:gsub( '(%s*)()(%S+)()', function( space, st, word, tend )
        if tend - pos > limit then
            pos     = st
            table.insert( resp, seg )
            seg     = word
            c       = c + 1
        else
            seg = seg .. space .. word
        end
    end )

    if ( seg ~= '' ) then
        table.insert( resp, seg )
        c = c + 1
    end

    return resp, c
end

/*
*   helper :: str :: split paths
*
*   typically used to split module paths up
*
*   @param  : str str
*   @return : str
*/

function helper.str:splitpath( str )
    return str:match( '(.+)/(.+)' ) -- fix '
end

/*
*   helper :: str :: explode
*
*   breaks a string up based on the specified seperator
*
*   @param  : str str
*   @param  : str sep
*   @param  : int limit
*   @return : tbl
*/

function helper.str:explode( str, sep, limit )
    sep     = isstring( sep ) and sep or ' '
    limit   = isnumber( limit ) and limit or 0

    local pos, seg = 1, { }

    while true do
        local pos_new, pos_end = str:find( sep, pos )
        if pos_new ~= nil then
            table.insert( seg, str:sub( pos, pos_new - 1 ) )
            pos = pos_end + 1
        else
            table.insert( seg, str:sub( pos ) )
            break
        end

        if ( limit and limit ~= 0 and #seg >= limit ) then return seg end
    end
    return seg
end

/*
*   helper :: str :: plural
*
*   returns a str with a singular or plural suffix
*
*   @ex     :   helper.str:plural( 'dog', 2 )
*               returns 'dogs'
*
*           :   helper.str:plural( 'dogs', 1 )
*               returns 'dog'
*
*   @param  : str str
*   @param  : int amt
*   @return : str
*/

function helper.str:plural( str, amt )
    amt = isnumber( amt ) and amt or 0
    return ( amt ~= 1 and str:sub( -1 ) ~= 's' and str .. 's' ) or ( amt == 1 and str:sub( -1 ) == 's' and str:sub( 1, -2 ) ) or str
end

/*
*   helper :: str :: comma
*
*   returns a str of numbers with comma seperation
*
*   @ex     :   helper.str:comma( '234553' )
*               returns 234, 553
*
*           :   helper.str:comma( 500000 )
*               returns 500, 000
*
*   @param  : str, int val
*   @return : str
*/

function helper.str:comma( val )
    local resp, k = tostring( val ), nil

    while true do
        resp, k = string.gsub( resp, '^(-?%d+)(%d%d%d)', '%1,%2' )
        if ( k == 0 ) then break end
    end

    return resp
end

/* 
*   helper :: sortedkeys
* 
*   assigns a clientconvar based on the parameters specified.
*   these convars will then be used later in order for the player to modify their settings on-the-fly.
*
*   ::  example
*       for name, line in base.sortedkeys( table ) do
*           table.insert( new_sorted_table, line )
*       end
*
*   @param  : tbl src
*   @param  : func sortf
*   @return : mixed
*/

function helper:sortedkeys( src, sortf )
    if not istable( src ) then
        log( 2, lang( 'sort_badtable' ) )
        return
    end

    local a = { }
    for n in pairs( src ) do
        table.insert( a, n )
    end
    table.sort( a, sortf )

    local i = 0
    local iter = function( )
        i = i + 1
        if a[ i ] == nil then
            return nil
        else
            return a[ i ], src[ a[ i ] ]
        end
    end
    return iter
end

/* 
*   helper :: switch
*
*   emulates a switch statement
*
*   a = switch
*   {
*       [ 1 ] = function ( x ) print( x, 10 ) end,
*       [ 2 ] = function ( x ) print( x, 20 ) end,
*       default = function ( x ) print( x, 0 ) end,
*   }
*
*   a:case( 1 )
*   a:case( 2 )
*
*   @param  : tbl tbl
*   @return : tbl
*/

function helper.switch( tbl )
    tbl.case = function( self, x )
        local f = self[ x ] or self.default
        if f then
            if isfunction( f ) then
                f( x, self )
            else
                error( lang( 'case_nofunc', tostring( x ) ) )
            end
        end
    end
    return tbl
end

/* 
*   helper :: util :: table is exact
*
*   compares two tables and determines if both are identical
*
*   @param  : tbl a
*   @param  : tbl b
*   @return : bool
*/

function helper.util:bTableExact( a, b )

    local function compare_table( t1, t2 )

        if t1 == t2 then return true end

        for k, v in pairs( t1 ) do
            if type( t1[ k ] ) ~= type( t2[ k ] ) then return false end

            if istable( t1[ k ] ) then
                if not compare_table( t1[ k ], t2[ k ] ) then return false end
            else
                if t1[ k ] ~= t2[ k ] then return false end
            end
        end

        for k, v in pairs( t2 ) do
            if type( t2[ k ] ) ~= type( t1[ k ] ) then return false end

            if istable( t2[ k ] ) then
                if not compare_table( t2[ k ], t1[ k ] ) then return false end
            else
                if t2[ k ] ~= t1[ k ] then return false end
            end
        end

        return true
    end

    if type( a ) ~= type( b ) then return false end

    if istable( a ) then
        return compare_table( a, b )
    else
        return ( a == b )
    end

end

/*
*   helper :: locate table entry
*
*   matches a string with a table value
*
*   @param  : tbl tbl
*   @param  : str str
*   @return : bool, str
*/

function helper:table_hasval( tbl, str )
    if not istable( tbl ) or not isstring( str ) then return end

    for item in string.gmatch( str, '(%a+)' ) do -- fix '
        if tbl[ item:lower( ) ] then
            return true, item
        end
    end
    return false
end

/* 
*   helper :: clr clamp
*
*   clamps a value to be within the boundaries of a color ( 0 - 255 )
*   accepts color table or single int value
*
*   @def    : white
*
*   @param  : int val
*   @return : int
*/

function helper:clr_clamp( val )
    if not val or ( not IsColor( val ) and not isnumber( val ) ) then
        return Color( 255, 255, 255, 255 )
    end
    if IsColor( val ) then
        local r = math.Clamp( math.Round( val.r ), 0, 255 )
        local g = math.Clamp( math.Round( val.g ), 0, 255 )
        local b = math.Clamp( math.Round( val.b ), 0, 255 )
        local a = math.Clamp( math.Round( val.a ), 0, 255 )

        return Color( r, g, b, a )
    else
        return math.Clamp( math.Round( val ), 0, 255 )
    end
end

/*
*   helper :: bool to string
*
*   converts a bool to a string
*
*   @param  : bool bool
*   @param  : str opt_y
*   @param  : str opt_n
*   @return : str
*/

function helper:bool2str( bool, opt_y, opt_n )
    return bool and 'true' or 'false'
end

/*
*   helper :: bool to int
*
*   transforms an bool into int
*
*   @param  : bool bool
*   @param  : bool cstring [optional]
*   @return : mix [ bool | str ]
*/

function helper:bool2int( bool )
    return bool and 1 or 0
end

/* 
*   helper :: int to bool
*
*   transforms an int to bool
*
*   @param  : int int
*   @return : bool
*/

function helper:int2bool( int )
    return int == 1 and true or false
end

/* 
*   helper :: type to bool toggle
*
*   allows user-input to toggle something using common words such as 'true', 'enable', 'on', etc 
*   with a boolean return.
*
*   a function that solves human stupidity and their desire to always do what you tell them NOT to
*
*   @param  : mix val
*   @return : bool
*/

function helper.util:toggle( val )
    if not val then return end

    if ( isstring( val ) ) then
        if ( table.HasValue( options_yes, val ) ) then
            return true
        elseif ( table.HasValue( options_no, val ) ) then
            return false
        elseif ( table.HasValue( options_huh, val ) ) then
            log( 1, lang( 'convert_toggle_idiot' ) )
            return false
        end
    elseif ( isnumber( val ) ) then
        if ( val == 1 ) then
            return true
        elseif ( val == 0 ) then
            return false
        end
    elseif ( isbool( val ) ) then
        if ( val == true ) then
            return true
        elseif ( val == false ) then
            return false
        end
    end

    return false
end

/* 
*   helper :: util :: human bool
*
*   takes an int such as 1 and returns a human readable bool such as 'true' or 'false'
*
*   @param  : mix val
*   @param  : bool bOnOff
*   @return : str
*/

function helper.util:humanbool( val, bOnOff )
    if not val then return end

    if ( isstring( val ) ) then
        if ( table.HasValue( options_yes, val ) ) then
            return not bOnOff and 'true' or 'on'
        elseif ( table.HasValue( options_no, val ) ) then
            return not bOnOff and 'false' or 'off'
        elseif ( table.HasValue( options_huh, val ) ) then
            log( 1, lang( 'convert_toggle_idiot' ) )
            return not bOnOff and 'false' or 'off'
        end
    elseif ( isnumber( val ) ) then
        if ( val == 1 ) then
            return not bOnOff and 'true' or 'on'
        elseif ( val == 0 ) then
            return not bOnOff and 'false' or 'off'
        end
    elseif ( isbool( val ) ) then
        if ( val == true ) then
            return not bOnOff and 'true' or 'on'
        elseif ( val == false ) then
            return not bOnOff and 'false' or 'off'
        end
    end

    return not bOnOff and 'false' or 'off'
end

/*
*   msg :: target
*
*   routes a message as either a private or broadcast based on the target
*
*   @param  : ply pl
*   @param  : str subcat [optional]
*   @param  : varg { ... }
*/

function base.msg:target( pl, subcat, ... )
    if not cfg or not cfg.cmsg then
        log( 2, lang( 'cmsg_missing' ) )
        return
    end

    local cmsg = cfg.cmsg

    local args = { ... }
    for k, v in pairs( args ) do
        if not isstring( v ) then continue end
        args[ k ] = v .. ' '
    end

    local sub_c = ( not helper.str:isempty( subcat ) and '[' .. subcat .. '] ' ) or '[' .. mf.name .. '] '

    if CLIENT then
        chat.AddText( cmsg.clrs.cat, '[' .. cmsg.tag_private .. '] ', cmsg.clrs.subcat, sub_c, cmsg.clrs.msg, unpack( args ) )
    else
        if helper.ok.ply( pl ) then
            pl:umsg( cmsg.clrs.cat, '[' .. cmsg.tag_private .. '] ', cmsg.clrs.subcat, sub_c, cmsg.clrs.msg, unpack( args ) )
        else
            base:broadcast( cmsg.clrs.cat, '[' .. cmsg.tag_server .. '] ', cmsg.clrs.subcat, sub_c, cmsg.clrs.msg, unpack( args ) )
        end
    end
end

/*
*   msg :: simple
*
*   sends a msg with no affixed formatting
*
*   @param  : ply pl
*   @param  : varg { ... }
*/

function base.msg:simple( pl, ... )
    local args = { ... }
    for k, v in pairs( args ) do
        if not isstring( v ) then continue end
        args[ k ] = v .. ' '
    end

    if CLIENT then
        chat.AddText( unpack( args ) )
    else
        if pl and pl ~= nil then
            if base.con:Is( pl ) then
                table.insert( args, '\n' )
                MsgC( unpack( args ) )
            else
                pl:umsg( unpack( args ) )
            end
        else
            base:broadcast( unpack( args ) )
        end
    end
end

/*
*   msg :: th
*
*   posts think delay
*
*   @param  : ply pl
*   @param  : clr clr
*   @param  : str cat
*   @param  : int delay
*   @param  : varg { ... }
*/

function base.msg:th( pl, clr, cat, delay, ... )
    local args  = { ... }
    clr         = IsColor( clr ) and clr or Color( 255, 255, 255 )
    timex.simple( delay, function( )
        base:console( pl, clr, unpack( args ) )
    end )
end

/*
*   msg :: structureize
*
*   formats a msg in an acceptable structure to unpack when needed
*
*   @param  : int scope
*   @param  : str subcat [optional]
*   @param  : varg { ... }
*/

function base.msg:struct( scope, subcat, ... )
    if not cfg or not cfg.cmsg then
        log( 2, lang( 'cmsg_missing' ) )
        return
    end

    local cmsg = cfg.cmsg

    scope = isnumber( scope ) and scope or 0
    local tag = cmsg.tag_private
    if scope == 1 then
        tag = cmsg.tag_server
    end

    local args = { ... }
    for k, v in pairs( args ) do
        if not isstring( v ) then continue end
        args[ k ] = v .. ' '
    end

    return cmsg.clrs.cat, '[' .. tag .. '] ', cmsg.clrs.subcat, subcat and '[' .. subcat .. '] ' or nil, cmsg.clrs.msg, unpack( args )
end

/*
*   msg :: server
*
*   routes a message to each player as a server broadcast
*
*   @param  : ply pl
*   @param  : str subcat [optional]
*   @param  : varg { ... }
*/

function base.msg:server( pl, subcat, ... )
    if not cfg or not cfg.cmsg then
        log( 2, lang( 'cmsg_missing' ) )
        return false
    end

    local cmsg = cfg.cmsg

    local args = { ... }
    for k, v in pairs( args ) do
        if not isstring( v ) then continue end
        args[ k ] = v .. ' '
    end

    if CLIENT then
        chat.AddText( cmsg.clrs.cat, '[' .. cmsg.tag_server .. '] ', cmsg.clrs.subcat, subcat and '[' .. subcat .. '] ' or nil, cmsg.clrs.msg, unpack( args ) )
    else
        if helper.ok.ply( pl ) then
            pl:umsg( cmsg.clrs.cat, '[' .. cmsg.tag_server .. '] ', cmsg.clrs.subcat, subcat and '[' .. subcat .. '] ' or nil, cmsg.clrs.msg, unpack( args ) )
        else
            base:broadcast( cmsg.clrs.cat, '[' .. cmsg.tag_server .. '] ', cmsg.clrs.subcat, subcat and '[' .. subcat .. '] ' or nil, cmsg.clrs.msg, unpack( args ) )
        end
    end
end

/*
*   msg :: route
*
*   can send a message via multiple routes
*
*   if console, the message reply will simply go back to the console.
*
*   if player, the reply output will be sent both to their chat using sendcmsg, and to their console
*   using bConsole.
*
*   since sending to player chat has a tendency to also add to the player console, bConsole 
*   has been added.
*
*   @param  : ply pl
*   @param  : bool bConsole
*   @param  : varg { ... }
*/

function base.msg:route( pl, bConsole, ... )
    local args          = { ... }
    local toConsole     = isbool( bConsole ) and bConsole or false
    local subcat        = isbool( bConsole ) and args[ 1 ] or bConsole
    local cmsg          = cfg.cmsg

    if subcat == args[ 1 ] then
        table.remove( args, 1 )
    end

    for k, v in pairs( args ) do
        if not isstring( v ) then continue end
        args[ k ] = v .. ' '
    end

    if CLIENT then
        chat.AddText( cmsg.clrs.cat, '[' .. cmsg.tag_console .. '] ', cmsg.clrs.subcat, subcat and '[' .. subcat .. '] ' or nil, cmsg.clrs.msg, unpack( args ) )
        if toConsole then
            table.insert( args, '\n' )
            MsgC( cmsg.clrs.cat, '[' .. cmsg.tag_console .. '] ', cmsg.clrs.subcat, subcat and '[' .. subcat .. '] ' or nil, cmsg.clrs.msg, unpack( args ) )
        end
    else
        if pl and pl ~= nil then
            if base.con:Is( pl ) then
                table.insert( args, '\n' )
                MsgC( cmsg.clrs.cat, '[' .. cmsg.tag_console .. '] ', cmsg.clrs.subcat, subcat and '[' .. subcat .. '] ' or nil, cmsg.clrs.msg, unpack( args ) )
            else
                if toConsole then
                    table.insert( args, '\n' )
                    pl:konsole( cmsg.clrs.cat, '[' .. cmsg.tag_console .. '] ', cmsg.clrs.subcat, subcat and '[' .. subcat .. '] ' or nil, cmsg.clrs.msg, unpack( args ) )
                end
                pl:umsg( cmsg.clrs.cat, '[' .. cmsg.tag_private .. '] ', cmsg.clrs.subcat, subcat and '[' .. subcat .. '] ' or nil, cmsg.clrs.msg, unpack( args ) )
            end
        else
            base:broadcast( cmsg.clrs.cat, '[' .. cmsg.tag_server .. '] ', cmsg.clrs.subcat, subcat and '[' .. subcat .. '] ' or nil, cmsg.clrs.msg, unpack( args ) )
        end
    end
end

/*
*   msg :: direct
*
*   can send a message via multiple routes
*
*   if console, the message reply will simply go back to the console.
*
*   if player, the reply output will be sent both to their chat using sendcmsg, and to their console
*   using bConsole.
*
*   since sending to player chat has a tendency to also add to the player console, bConsole 
*   has been added.
*
*   @note   : func msg_prepare temp for now for testing; will be migrated in future version
*
*   @ex     : rlib.msg:direct( LocalPlayer( ), nil, 'your name is', rlib.settings.cmsg.clrs.target, 'rob' )
*                   sends a msg to a single player with the message 'your name is rob'
*
*           : rlib.msg:direct( nil, nil, 'hello ', rlib.settings.cmsg.clrs.target, 'everyone' )
*                   sends a broadcast message to all players with no category prefix
* 
*   @param  : ply pl
*   @param  : str subcat [optional]
*   @param  : varg { ... }
*/

local function msg_prepare( ... )
    local args = { ... }
    return args
end

function base.msg:direct( pl, subcat, ... )
    local args  = { ... }
    local cmsg  = cfg.cmsg
    subcat      = isstring( subcat ) and subcat

    local resp  = msg_prepare( cmsg.clrs.cat, '[' .. cmsg.tag_private .. '] ', cmsg.clrs.subcat, subcat and '[' .. subcat .. '] ' or nil, cmsg.clrs.msg )
    table.Add( resp, args )

    if CLIENT then
        chat.AddText( unpack( resp ) )
    else
        if pl and pl ~= nil then
            if base.con:Is( pl ) then
                table.insert( resp, '\n' )
                MsgC( unpack( resp ) )
            else
                pl:umsg( cmsg.clrs.cat, '[' .. cmsg.tag_private .. '] ', cmsg.clrs.subcat, subcat and '[' .. subcat .. '] ' or nil, cmsg.clrs.msg, ... )
            end
        else
            base:broadcast( cmsg.clrs.cat, '[' .. cmsg.tag_private .. '] ', cmsg.clrs.subcat, subcat and '[' .. subcat .. '] ' or nil, cmsg.clrs.msg, ... )
        end
    end
end

/*
*   helper :: util :: steam 32 to 64
*
*   canvert steam 32 to 64
*
*   @ref    : https://developer.valvesoftware.com/wiki/SteamID
*
*   @param  : str sid
*   @return : str
*/

function helper.util:sid32_64( sid )
    if not sid or not helper.ok.sid32( sid ) then
        local ret = lang( 'util_nil' )
        if sid and sid ~= nil then ret = sid end
        log( 2, lang( 'util_s32_noconvert', ret ) )
        return false
    end

    sid             = sid:upper( )

    local sid_pre   = '7656'
    local segs      = string.Explode( ':', string.sub( sid, 7 ) )
    local to64      = ( 1197960265728 + tonumber( segs[ 2 ] ) ) + ( tonumber( segs[ 3 ] ) * 2 )
    local output    = sf( '%f', to64 )

    return sid_pre .. string.sub( output, 1, string.find( output, '.', 1, true ) - 1 )
end

/*
*   helper :: util :: steam 64 to 32
*
*   canverts a steam 64 to 32
*
*   :   STEAM_X:Y:Z
*       X = universe ( 0 - 5 | def. 0 )
*       Y = Lowest bit for acct id ( 0 or 1 )
*       Z = upper 31 bits for acct id
*
*   :   universes
*       0   Individual / Unspecified
*       1   Public
*       2   Beta
*       3   Internal
*       4   Dev
*       5   RC
*
*   @ref    : https://developer.valvesoftware.com/wiki/SteamID
*
*   @param  : str sid
*   @param  : int x [ optional ]
*   @return : str
*/

function helper.util:sid64_32( sid, x )
    if not sid or tonumber( sid ) == nil then
        local ret = lang( 'util_nil' )
        if sid and sid ~= nil then ret = sid end
        log( 2, lang( 'util_s64_noconvert', ret ) )
        return false
    end

    x = x or 0
    if x > 5 then x = 0 end

    local b_id      = 6561197960265728
    local from64    = tonumber( sid:sub( 2 ) )
    local y         = from64 % 2 == 0 and 0 or 1
    local z         = math.abs( b_id - from64 - y ) / 2

    return 'STEAM_' .. x .. ':' .. y .. ':' .. ( y == 1 and z - 1 or z )
end

/*
*   helper :: who :: player by name ( exact )
*
*   attempts to locate a player by the specified name
*
*   @param  : str, ply pl
*   @return : ent
*/

function helper.who:name( pl )
    if not pl then return end
    pl = isstring( pl ) and pl:lower( ) or helper.ok.ply( pl ) and pl:Name( )

    local res = false
    for v in helper.get.players( ) do
        local res_name = v:Name( ):lower( )
        if res_name ~= pl then continue end

        res = v
    end

    return helper.ok.ply( res ) and res
end

/*
*   helper :: who :: player by name ( wildcard )
*
*   attempts to locate a player by the specified name in a wildcard fashion (partial name matches)
*   any matches will be placed in a table with the starting index [ 0 ]
*
*   @call   : local res_cnt, res_ply = helper.who:name_wc( ply )
*
*   @param  : str, ply pl
*   @return : int, tbl
*/

function helper.who:name_wc( pl )
    if not pl then return end
    pl = isstring( pl ) and pl:lower( ) or helper.ok.ply( pl ) and pl:Name( )

    local i, outp = 0, { }
    for v in helper.get.players( ) do
        local res_name = v:Name( ):lower( )
        if ( string.find( res_name, pl, 1, true ) == nil ) then continue end

        outp[ i ] = v
        i = i + 1
    end

    return i, outp
end

/*
*   helper :: who :: rpname
*
*   determines if a pl has a valid rp name
*
*   @call   : helper.who:rpname( pl )
*
*   @param  : ply pl
*   @return : str, bool
*/

function helper.who:rpname( pl )
    if not pl.DarkRPVars or not pl.DarkRPVars.rpname then return end
    return pl.DarkRPVars.rpname ~= 'NULL' and pl.DarkRPVars.rpname or false
end

/*
*   helper :: who :: rpjob
*
*   attempts to locate a darkrp job by the specified name
*
*   returns table with 2 rows:
*       [ 1 ]   = job/team id
*       [ 2 ]   = job table data
*
*   @param  : str name
*   @return : tbl
*/

function helper.who:rpjob( name )
    if not RPExtraTeams then
        log( 2, lang( 'hlp_who_rp_notable' ) )
        return false
    end

    local resp = nil
    for i, v in pairs( RPExtraTeams ) do
        if v.name:lower( ) ~= name:lower( ) then continue end
        resp = { i, v }
    end

    return resp
end

/*
*   helper :: who :: rpjob :: wildcard
*
*   attempts to locate a darkrp job by the specified name in a wildcard fashion (partial name matches)
*   any matches will be placed in a table with the starting index [ 0 ]
*
*   returns two values
*       i, matches
*
*   @param  : str name
*   @return : tbl
*/

function helper.who:rpjob_wc( name )
    if not RPExtraTeams then
        log( 2, 'darkrp table [ %s ] missing » check gamemode', 'RPExtraTeams' )
        return false
    end

    if not name then return RPExtraTeams or false end
    name = isstring( name ) and name:lower( ) or tostring( name ):lower(  )

    local i, outp = 0, { }
    for v in helper.get.data( RPExtraTeams ) do
        local res_name = v.name:lower()
        if ( string.find( res_name, name, 1, true ) == nil ) then continue end

        outp[ i ] = v
        i = i + 1
    end

    return i, outp
end

/*
*   helper :: who :: rpjob :: custom
*
*   attempts to locate a darkrp job based on a custom field specified. you can search using any field that
*   the jobs table has.
*
*   defaults to 'command' field if left blank
*
*   @ex     : helper.who:rpjob_custom( '1', 'lvl' )
*           : returns jobs matching level 1
*
*           : helper.who:rpjob_custom( 'citizen' )
*           : defaults to job /command field.
*
*   returns two values
*       i, matches
*
*   @param  : str name
*   @return : tbl
*/

function helper.who:rpjob_custom( name, field )
    if not RPExtraTeams then
        log( 2, 'darkrp table [ %s ] missing » check gamemode', 'RPExtraTeams' )
        return false
    end

    if not name then return RPExtraTeams or false end

    name    = isstring( name ) and name:lower( ) or tostring( name ):lower(  )
    field   = field or 'command'

    local i, outp = 0, { }
    for v in helper.get.data( RPExtraTeams ) do
        local res_name = isstring( v[ field ] ) and v[ field ]:lower( ) or v[ field ]
        if ( string.find( res_name, name, 1, true ) == nil ) then continue end

        outp[ i ] = v
        i = i + 1
    end

    return i, outp
end

/*
*   helper :: who :: rpjob :: lc / clean
*
*   serves the same purpose as the func helper.who:rpjob_custom but with cleaning of the strings
*   so that values match identically.
*
*   defaults to 'command' field if left blank
*
*   @ex     : helper.who:rpjob_custom( 'citizen' )
*           : defaults to job /command field.
*
*   returns two values
*       i, matches
*
*   @param  : str name
*   @return : tbl
*/

function helper.who:rpjob_custom_lc( name, field )
    if not RPExtraTeams then
        log( 2, 'darkrp table [ %s ] missing » check gamemode', 'RPExtraTeams' )
        return false
    end

    if not name then return RPExtraTeams or false end

    name    = isstring( name ) and name or tostring( name )
    name    = helper.str:clean( name )
    field   = field or 'command'

    local i, outp = 0, { }
    for v in helper.get.data( RPExtraTeams ) do
        local res_name = isstring( v[ field ] ) and v[ field ]:lower( ) or v[ field ]
        if helper.str:clean( res_name ) ~= name then continue end

        outp[ i ] = v
        i = i + 1
    end

    return i, outp
end

/*
*   helper :: who :: sid
*
*   locates a ply based on steam64
*
*   if steam32 provided; will be converted to s64 before checking for a matching ply.
*
*   :   steam_id
*       supports steam32 and steam64 ids
*
*   :   bNameOnly
*       false   : returns the ply ent
*       true    : returns only ply name str
*
*   @param  : str sid
*   @param  : bool bNameOnly
*   @return : ply
*/

function helper.who:sid( sid, bNameOnly )
    sid = isstring( sid ) and sid or tostring( sid )
    if helper.ok.sid32( sid ) then
        sid = helper.util:sid32_64( sid )
    end

    local i, outp = 0, { }
    for v in helper.get.players( ) do
        if v:SteamID64( ) ~= sid then continue end

        outp[ i ] = not bNameOnly and v or v:Name( )
        i = i + 1
    end

    return i, outp
end

/*
*   helper :: bIsAlpha
*
*   the characters that a player is allowed to use when they are using an input field.
*   anything not in the following table will be classified as an invalid character.
*
*   @param  : str text
*   @return : bool
*/

function helper:bIsAlpha( text )
    local whitelist =
    {
        'q', 'w', 'e', 'r', 't', 'y', 'u', 'i', 'o',
        'p', 'a', 's', 'd', 'f', 'g', 'h', 'j', 'k',
        'l', 'z', 'x', 'c', 'v', 'b', 'n', 'm', ' '
    }

    for k in string.gmatch( text, '.' ) do
        if table.HasValue( whitelist, k:lower( ) ) then return true end
    end

    return false
end

/*
*   helper :: bIsNum
*
*   listed values in the local table will determine what chars are allowed in the func being used.
*
*   @param  : str text
*   @return : bool
*/

function helper:bIsNum( text )
    text = tostring( text )
    local whitelist = { '0', '1', '2', '3', '4', '5', '6', '7', '8', '9' }

    for k in string.gmatch( text, '.' ) do
        if table.HasValue( whitelist, k:lower( ) ) then return true end
    end

    return false
end

/*
*   helper :: bIsAlphaNum
*
*   allows for a string to only contain alphanumerical characters.
*
*   @param  : str text
*   @return : bool
*/

function helper:bIsAlphaNum( text )
    text = tostring( text )
    local whitelist =
    {
        'q', 'w', 'e', 'r', 't', 'y', 'u', 'i', 'o', 'p', 'a', 's',
        'd', 'f', 'g', 'h', 'j', 'k', 'l', 'z', 'x', 'c', 'v', 'b',
        'n', 'm', '0', '1', '2', '3', '4', '5', '6', '7', '8', '9'
    }

    for k in string.gmatch( text, '.' ) do
        if table.HasValue( whitelist, k:lower( ) ) then return true end
    end

    return false
end

/*
*   helper :: bBlacklisted
*
*   determines if a word(s) are in a defined blacklist table
*
*   @call   :   blacklist = { 'word', 'other word' }
*               helper:bBlacklisted( 'other word', blacklist ) :: returns true
*               helper:bBlacklisted( 'test', blacklist ) :: returns false
*
*   @param  : str text
*   @param  : tbl src
*   @return : bool
*/

function helper:bBlacklisted( text, src )
    local bBlocked = false
    for word in helper.get.data( src ) do
        local msg, i = string.gsub( text, word, function( d )
            bBlocked = true
        end )
        if bBlocked then break end
    end
    return bBlocked
end

/*
*   color :: is hex
*
*   uses patterns to determine if a string is a valid hex code.
*
*   @ex     : #FFFFFF   : true
*   @ex     : #ZJF      : false
*
*   @param  : str hex
*   @return : bool
*/

function helper:clr_ishex( hex )
    hex = hex:gsub( '#', '' )
    return hex:match( '^%x%x%x%x%x%x' ) and true or false
end

/*
*   color :: hex to rgb
*
*   takes a hex value and converts it into an rgb
*
*   @ex     : #FFFFFF       : 255 255 255
*   @ex     : #FFFFFF, 50   : 255 255 255 50
*
*   @param  : str hex
*   @param  : int alpha
*   @return : tbl
*/

function helper:clr_hex2rgb( hex, alpha )
    if not isstring( hex ) then return end
    hex = hex:gsub( '#', '' )

    if hex:len( ) ~= 6 or not self:clr_ishex( hex ) then return end

    alpha = isnumber( alpha ) and math.Clamp( alpha, 0, 255 ) or 255
    return tonumber( '0x' .. hex:sub( 1, 2 ) ), tonumber( '0x' .. hex:sub( 3, 4 ) ), tonumber( '0x' .. hex:sub( 5, 6 ) ), alpha
end

/*
*   color :: rgb to hex
*
*   takes rgb color table and converts it to hexadecimal
*
*   @ex     : { 255, 255, 255 }     : 0XFFFFFF
*   @ex     : ( 0, 0, 0 )           : 0X000000
*
*   @param  : tbl rgb
*   @param  : bool bClean
*   @return : str
*/

function helper:rgb2hex( rgb, bClean )
    local hexadecimal = '0X'

    if not rgb or not istable( rgb ) then return end

    for k, v in pairs( rgb ) do
        local hex = ''

        while ( v > 0 ) do
            local ind = math.fmod( v, 16 ) + 1
            v = math.floor( v / 16 )
            local substr = '0123456789ABCDEF'
            hex = substr:sub( ind, ind ) .. hex
        end

        hex = ( hex:len( ) == 0 and '00' ) or ( hex:len( ) == 1 and '0' .. hex ) or hex

        hexadecimal = hexadecimal .. hex
    end

    if bClean then
        hexadecimal = hexadecimal:gsub( '0X', '' )
    end

    return hexadecimal
end

/*
*   helper :: table add entry
*
*   adds entries to a specified table
*
*   @call   : helper:table_addentry( table, { 'a', 'b', 'c' } )
*
*   @param  : tbl src
*   @param  : tbl entries
*/

function helper:table_addentry( src, entries )
    if not istable( src ) then
        log( 2, 'cannot add table entries without valid table' )
        return
    end

    if not istable( entries ) then
        log( 2, 'cannot add missing entries to table' )
        return
    end

    for v in self.get.data( entries ) do
        table.insert( src, v )
    end
end

/*
*   helper :: table del index
*
*   removes a specified number of table indexes
*
*   @ex     :   local src = { 'aaa', 'bbb', 'ccc' }
*           :   helper:table_remove( src, 2 )
*
*               returns entries 'aaa', 'bbb'
*
*   @param  : tbl tbl
*   @param  : int int
*/

function helper:table_remove( tbl, int )
    if not istable( tbl ) then
        log( 2, 'cannot remove table indexes without valid table' )
        return
    end

    int = calc.bIsNum( int ) and int or 1

    for i = 1, int do
        table.remove( tbl, 1 )
    end
end

/*
*   helper :: copy table
*
*   completely copies a table; including sub-tables
*   do not use on tables that contain themselves somewhere, otherwise it may cause
*   an infinite loop
*
*   @ex     :   local src = { 'aaa', 'bbb', 'ccc' }
*           :   helper:table_remove( src, 2 )
*
*               returns entries 'aaa', 'bbb'
*
*   @param  : tbl tbl
*   @param  : int int
*/

function helper:table_copyall( tbl )
    if not istable( tbl ) then return end

    local res = { }
    for k, v in pairs( tbl ) do
        if ( type( v ) == 'table' ) then
            res[ k ] = helper:table_copyall( v )
        elseif ( type( v ) == 'Vector' ) then
            res[ k ] = Vector( v.x, v.y, v.z )
        elseif ( type( v ) == 'Angle' ) then
            res[ k ] = Angle( v.p, v.y, v.r )
        else
            res[ k ] = v
        end
    end

    return res
end

/*
*   helper :: log colors
*
*   returns the clr used for a particular log type id
*
*   @param  : int id
*   @param  : int limit
*   @return : clr || clr, clr
*/

function helper:_logclr( id, limit )
    if not id then return Color( 255, 255, 255, 255 ) end
    limit = isstring( limit ) and limit:lower( ) or isnumber( limit ) and limit or false

    if limit == 1 or limit == 'rgb' then
        return self.def._lc_rgb[ id ] or Color( 255, 255, 255, 255 )
    elseif limit == 2 or limit == 'rgb6' then
        return self.def._lc_rgb6[ id ] or Color( 255, 255, 255, 255 )
    else
        return self.def._lc_rgb[ id ] or Color( 255, 255, 255, 255 ), self.def._lc_rgb6[ id ] or Color( 255, 255, 255, 255 )
    end
end

/*
*   sends information to the konsole
*
*   @assoc  : rlib:log( )
*
*   @param  : ply calling_ply
*   @param  : int itype
*   @param  : str msg
*   @param  : varg { ... }
*/

function konsole:add( calling_ply, itype, msg, ... )
    if CLIENT then return end

    itype = isnumber( itype ) and itype or 1

    if not isstring( msg ) then
        log( 6, 'attempt to process konsole post message with invalid msg type' )
        return false
    end

    for pl in helper.get.players( ) do
        if not access:bIsDev( pl ) then continue end
        if calling_ply and not helper.ok.ply( calling_ply ) then continue end
        if calling_ply and calling_ply ~= pl then continue end

        net.Start       ( 'rlib.konsole'    )
        net.WriteInt    ( itype, 4          )
        net.WriteString ( msg               )
        net.Send        ( pl                )
    end
end

/*
*   sends a simple string to the konsole without accepting vars as a table.
*
*   @assoc  : rlib:modules_log( )
*
*   @param  : int itype
*   @param  : str msg
*/

function konsole:add_simple( itype, msg )
    if CLIENT then return end

    itype = itype or 1
    if not isstring( msg ) then return end

    for pl in helper.get.players( ) do
        if not access:bIsDev( pl ) then continue end

        net.Start       ( 'rlib.konsole'    )
        net.WriteInt    ( itype, 4          )
        net.WriteString ( msg               )
        net.Send        ( pl                )
    end
end

/*
*   konsole :: notify all
*
*   @param  : int itype
*   @param  : str msg
*/

function konsole:notifyall( itype, msg )
    itype   = isnumber( itype ) and itype or 1
    msg     = isstring( msg ) and msg or 'no message'

    net.Start           ( 'rlib.debug.ui'   )
    net.WriteInt        ( itype, 4          )
    net.WriteString     ( msg               )
    net.SendToServer    (                   )
end

/*
*   rsay :: shared
*
*   prints a message in center of the screen as well as in the users consoles.
*
*   @param  : ply pl        send to ply ( set nil for broadcast )
*   @param  : str msg       msg to send
*   @param  : clr clr       <@optional> clr for msg
*   @param  : int dur       <@optional> amt of time to show the msg
*   @param  : int fade      <@optional> length of fade time [ def:1 ]
*/

local function rsay_netlib_sv( pl, msg, clr, dur, fade )
    if not SERVER then return end

    net.Start           ( 'rlib.rsay'   )
    net.WriteString     ( msg           )
    net.WriteColor      ( clr           )
    net.WriteInt        ( dur, 8        )
    net.WriteInt        ( fade, 8       )
    if pl then
        net.Send( pl )
    else
        net.Broadcast( )
    end
end

function base.rsay( pl, msg, clr, dur, fade )
    pl      = IsValid( pl ) and pl or nil
    msg     = isstring( msg ) and msg or 'missing msg'
    clr     = IsColor( clr ) and clr or Color( 255, 255, 255, 255 )
    dur     = isnumber( dur ) and dur or 8
    fade    = isnumber( fade ) and fade or 1

    rsay_netlib_sv( pl, msg, clr, dur, fade )
    base.con:Guided( pl, msg )
end