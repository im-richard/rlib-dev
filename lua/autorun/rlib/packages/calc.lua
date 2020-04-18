/*
*   @package        : rlib
*   @module         : calc
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
local settings          = base.settings

/*
*   lib includes
*/

local access            = base.a
local helper            = base.h

/*
*   localizations
*/

local math              = math
local module            = module
local smt               = setmetatable
local sf                = string.format

/*
*   simplifiy funcs
*/

local function con( ... ) base:console( ... ) end
local function log( ... ) base:log( ... ) end

/*
*	prefix :: create id
*/

local function pref( id, suffix )
    local affix = istable( suffix ) and suffix.id or isstring( suffix ) and suffix or prefix
    affix       = affix:sub( -1 ) ~= '.' and sf( '%s.', affix ) or affix

    id          = isstring( id ) and id or 'noname'
    id          = id:gsub( '[%c%s]', '.' )

    return sf( '%s%s', affix, id )
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

module( 'calc', package.seeall )

/*
*   local declarations
*/

local pkg           = calc
local pkg_name      = _NAME or 'calc'

/*
*   pkg declarations
*/

local manifest =
{
    author          = 'richard',
    desc            = 'mathmatical calculations related to time, memory, data counts, etc',
    build           = 040220,
    version         = { 2, 1, 0 },
}

/*
*   required tables
*/

settings            = settings or { }
sys                 = sys or { }
pos                 = pos or { }
fs                  = fs or { }

/*
*   return number of human players on server
*/

function players( )
    return #player.GetHumans( ) or 0
end

/*
*   return number of bots on server
*/

function bots( )
    return #player.GetBots( ) or 0
end

/*
*   count from a min to max number set
*
*   @param  : int from
*   @param  : int to
*/

function sequence( from, to )
    return coroutine.wrap( function( )
        for i = from, to do
            coroutine.yield( i )
        end
    end )
end

/*
*   get percentage of two numbers
*
*   @param  : int num
*   @param  : int max
*   @param  : bool bFormat
*   @return : int
*/

function percent( num, max, bFormat )
    num = tonumber( num ) or 0
    max = tonumber( max ) or 100

    local pcalc = 100 * num / max
    pcalc = math.Clamp( pcalc, 0, 100 )
    pcalc = math.Round( pcalc )

    return not bFormat and pcalc or string.format( '%.f%%', pcalc )
end

/*
*   bIsInf
*
*   checks for infinity ( -inf, inf )
*
*   @param  : int num
*   @return : bool
*/

function bIsInf( num )
    return not ( num ~= num or num == math.huge or num == -math.huge )
end

/*
*   bIsNum
*
*   a more controlled version of isnumber used in various circumstances
*
*   @param  : int num
*   @return : bool
*/

function bIsNum( num )
    num = num and tonumber( num )

    if num ~= num then return false end
    if not isnumber( num ) or num < 0 then return false end
    if num == math.huge or num == -math.huge then return false end

    return true
end

/*
*   converts bytes to various other size types progressively; KB, MB, GB, TB
*
*   @ex     : fs.size( 1024 )           : returns 1KB
*           : fs.size( 1048576 )        : returns 1MB
*           : fs.size( 1078000000 )     : returns 1GB
*
*   @param  : int bytes
*   @return : str
*/

function fs.size( bytes )
    local rpos  = 2
    local kb    = 1024
    local mb    = kb * 1024
    local gb    = mb * 1024
    local tb    = gb * 1024

    if ( ( bytes >= 0 ) and ( bytes < kb ) ) then
        return bytes .. ' Bytes'
    elseif ( ( bytes >= kb ) and ( bytes < mb ) ) then
        return math.Round( bytes / kb, rpos ) .. ' KB'
    elseif ( ( bytes >= mb ) and ( bytes < gb ) ) then
        return math.Round( bytes / mb, rpos ) .. ' MB'
    elseif ( ( bytes >= gb ) and (bytes < tb ) ) then
        return math.Round(bytes / gb, rpos ) .. ' GB'
    elseif ( bytes >= tb ) then
        return math.Round( bytes / tb, rpos ) .. ' TB'
    else
        return bytes .. ' B'
    end
end

/*
*   returns the count of files from a specificed path and the 
*   total diskspace used
*
*   @ex     : sys.uconn_sz, sys.uconn_ct    = calc.fs.diskTotal( 'data/rlib/uconn' )
*
*   @param  : str path
*   @return : int, int
*/

function fs.diskTotal( path )
    local files, _      = file.Find( path .. '/*', 'DATA' )
    local ct_files      = #files or 0
    local ct_folders    = #_
    local ct_size       = 0

    local function recurv( path_sub )
        local sub_path      = path .. '/' .. path_sub
        local ifiles, _     = file.Find( sub_path .. '/*', 'DATA' )
        ct_files            = ct_files + #ifiles

        for k, v in pairs( ifiles ) do
            local file_path = sf( '%s/%s', sub_path, v )
            local file_size = file.Size( file_path, 'DATA' )
            ct_size         = ct_size + file_size
        end
    end

    /*
    *   add folders
    */

    for _, v in pairs( _ ) do
        recurv( v )
    end

    local sz_output   = fs.size( ct_size )

    return sz_output, ct_files, ct_folders
end

/*
*   ratio
*
*   determines the ratio of two numbers ( normally for k:d ratio ), however two different outputs are
*   available depending on your needs.
*
*   by default, negative numbers can occur, so it is possible ot get -5.00 for a K:D ratio, but if
*   bPositive is true, this is avoided and all numbers are positive, which is how a majority of k:d
*   trackers do things
*
*   view examples of the outputs below:
*
*   @ex     :   ratio( 5, -10 )             : -0.50
*           :   ratio( 5, -10, true )       : 5.00
*           :   ratio( -10, 5 )             : -2.00
*           :   ratio( -10, 5, true )       : 0.00
*
*   @param  : int k
*   @param  : int d
*   @param  : bool bPositive
*   @return : str
*/

function ratio( k, d, bPositive )
    local response  = 0
    local params    = '%.2f'

    k = bPositive and bIsNum( k ) and k or tonumber( k ) or 0
    d = bPositive and bIsNum( d ) and d or tonumber( d ) or 0

    if ( d == 0 and k == 0 ) then
        return sf( params, response )
    end

    if d == 0 then d = 1 end

    response = math.Round( k / d, 2 )

    if k == 0 and d > 0 then
        response = -d
    elseif k == d then
        response = 1
    elseif k > 0 and d == 0 then
        response = k
    end

    if bPositive then
        response = d < 1 and k or response
        response = k <= 0 and 0 or response
    end

    return sf( params, response )
end

/*
*   seed
*
*   creates random seed based on length ; can be returned as a string using bString = true
*
*   @param  : int len
*   @param  : bool bString
*   @return : int, str
*/

function seed( len, bString )
    len = isnumber( len ) and len or tonumber( len ) or 10

    local response = ''
    for i = 1, len do
        local min = response == '' and 1 or 0
        local index = math.random( min, 9 )
        response = response .. index
    end

    return not bString and tonumber( response ) or tostring( response )
end

/*
*   calc :: xp percent
*
*   returns information about a users xp
*
*   @param  : ply ply
*   @param  : int multiplier
*   @return : int
*/

function xp_percent( ply, multiplier )

    local pl_level          = ( isfunction( ply.getlevel ) and ply:getlevel( ) ) or 0
    local pl_xp             = ( isfunction( ply.getxp ) and math.floor( ply:getxp( ) ) ) or 0
    local xp_format         = 0
    local xp_calc           = 0
    local output            = 0
    if LevelSystemConfiguration then
        local xp_perc       = ( ( pl_xp or 0 ) / ( ( ( 10 + ( ( ( pl_level or 1 ) * ( ( pl_level or 1 ) + 1 ) * 90 ) ) ) ) * ( ( isnumber( multiplier ) and multiplier ) or LevelSystemConfiguration.XPMult or 1.0 ) ) ) or 0
        xp_calc             = xp_perc * 100 or 0
        xp_calc             = math.Round( xp_calc ) or 0
        xp_format           = math.Clamp( xp_calc, 0, 99 )
        output              = xp_format or 0
    elseif DARKRP_LVL_SYSTEM then
        local lvl_format    = DARKRP_LVL_SYSTEM[ 'XP' ][ tonumber( pl_level ) ]
        if not lvl_format then return end

        xp_calc             = ( pl_xp * 100 / lvl_format ) or 0
        xp_format           = math.floor( xp_calc ) or 0
        output              = xp_format or 0
    elseif DARKRP_LEVELING_ENTRESTRICT then
        local maxexp        = ExpFormula( ply:GetNWInt( "lvl", 0 ))
        xp_calc             = ( pl_xp * 100 / maxexp ) or 0
        xp_format           = math.Round( xp_calc )
        output              = xp_format
    end

    return ( isnumber( output ) and output ) or 0

end

/*
*   calc :: xp percentage float
*
*   returns the percentage completed based on a 0 - 1 float
*
*   @ex     : 0%        0
*           : 50%       0.5
*           : 100%      1
*
*   @param  : ply ply
*   @param  : int multiplier
*   @return : float
*/

function xp_percent_float( ply, multiplier )
    if not LevelSystemConfiguration then return 0 end

    local pl_level      = ( isfunction( ply.getlevel ) and ply:getlevel( ) ) or 0
    local pl_xp         = ( isfunction( ply.getxp ) and math.floor( ply:getxp( ) ) ) or 0
    local pl_calc       = ( ( pl_xp or 0 ) / ( ( ( 10 + ( ( ( pl_level or 1 ) * ( ( pl_level or 1 ) + 1 ) * 90 ) ) ) ) * ( ( isnumber( multiplier ) and multiplier ) or LevelSystemConfiguration.XPMult or 1.0 ) ) ) or 0

    return pl_calc
end

/*
*   calc :: date :: ending trail
*
*   attaches an ending trail onto days
*
*   @ex     : 21        21st
*           : 15        15th
*
*   @param  : int dayn
*   @return : str
*/

function date_trailing( dayn )
    local getday    = tonumber( dayn )
    last_digit      = dayn % 10

    if last_digit == 1 and getday ~= 11 then
        return 'st'
    elseif last_digit == 2 and getday ~= 12 then
        return 'nd'
    elseif last_digit == 3 and getday ~= 13 then
        return 'rd'
    else
        return 'th'
    end
end

/*
*   calc :: is finite
*
*   determines if a value is finite
*/

function bIsFinite( num )
    return not ( num ~= num or num == math.huge or num == -math.huge )
end

/*
*   calc :: pos :: midpoint
*/

function pos.midpoint( min, max )
    local angle     = Angle( )
    local mid       = Vector( ( min.x + max.x ) / 2, ( min.y + max.y ) / 2, ( min.z + max.z ) / 2 )
    min             = WorldToLocal( min, angle, mid, angle )
    max             = WorldToLocal( max, angle, mid, angle )

    return mid, min, max
end

/*
*   calc :: pos :: find floor pos in area
*/

function pos.findfloorinarea( area )
    local trData            = { }
    local trRes             = { }

    local data              = area.data
    local i_pos             = Vector( 0, 0, 0 )
    local dist              = 0

    data                    = data[ math.random( 1, #data ) ]

    local min               = data.min + Vector( 16, 16, 0 )
    local max               = data.max - Vector( 16, 16, 36 )
    i_pos.x                 = math.random( min.x, max.x )
    i_pos.y                 = math.random( min.y, max.y )

    if isvector( area.LastFoundPos ) then
        while Vector( i_pos.x, i_pos.y, 0 ):Distance( area.LastFoundPos ) < 16 do
            i_pos.x = math.random( min.x, max.x )
            i_pos.y = math.random( min.y, max.y )
        end
    end

    area.LastFoundPos       = Vector( i_pos.x, i_pos.y, 0 )

    -- Trying to find the floor.
    trData.start            = Vector( i_pos.x, i_pos.y, max.z )
    trData.endpos           = Vector( i_pos.x, i_pos.y, min.z )
    trRes                   = util.TraceLine( trData )

    dist                    = trRes.HitPos:Distance( trData.start )
    i_pos.z                 = trRes.HitPos.z

    if dist < 40 then -- Attempt to place under objects.
        trData.start        = Vector( i_pos.x, i_pos.y, min.z )
        trData.endpos       = Vector( i_pos.x, i_pos.y, max.z )
        trRes               = util.TraceLine( trData )

        trData.start        = trRes.HitPos
        trData.endpos       = Vector( i_pos.x, i_pos.y, min.z )
        trRes               = util.TraceLine( trData )

        dist                = trRes.HitPos:Distance( trData.start )
        i_pos.z             = trRes.HitPos.z
    end

    i_pos.z = i_pos.z + 10

    return i_pos, ( dist > 40 )
end

/*
*   calc :: pos :: fix min max
*
*   @param  : int min
*   @param  : int max
*
*   @return : vector
*/

function pos.fix_minmax( min, max )
    local minX = math.min( min.x, max.x )
    local minY = math.min( min.y, max.y )
    local minZ = math.min( min.z, max.z )

    local maxX = math.max( min.x, max.x )
    local maxY = math.max( min.y, max.y )
    local maxZ = math.max( min.z, max.z )

    return Vector( minX, minY, minZ ), Vector( maxX, maxY, maxZ )
end

/*
*   calc :: int2hex
*
*   converts intger to hex
*
*   @param  : int num
*
*   @return : str
*/

function int2hex( num )
    local b, str, val, cur, d = 16, '0123456789ABCDEF', '', 0
    while num > 0 do
        cur     = cur + 1
        num, d  = math.floor( num / b ), math.fmod( num, b ) + 1
        val     = string.sub( str, d, d ) .. val
    end


    val = '0x' .. val

    return val
end

/*
*   calc :: hex2int
*
*   converts hex to integer
*
*   @param  : str hex
*
*   @return : int
*/

function hex2int( hex )
    return ( tonumber( hex, 16 ) + 2^31 ) % 2^32 - 2^31
end

/*
*   calc :: equation
*
*   chain mathmatics
*
*   @ex     : calc:equation( 10 ):add( 5 ):sub( 3 ):mul( 2 ):result( )
*
*   @return : int
*/

local equations =
{
    __index =
    {
        add     = function( s, num ) s._r = s._r + num return s end,
        sub     = function( s, num ) s._r = s._r - num return s end,
        mul     = function( s, num ) s._r = s._r * num return s end,
        div     = function( s, num ) s._r = s._r / num return s end,
        result  = function( s) return s._r end
} }

equation = function( s, num )
return smt(
{
    _r = num or 0
}, equations ) end

/*
*   rcc :: base command
*
*   base package command
*/

function rcc.call:Calc( ply, cmd, args )

    /*
    *   permissions
    */

    local ccmd = base.calls:get( 'commands', 'calc' )

    if ( ccmd.scope == 1 and not base.con:Is( ply ) ) then
        access:deny_consoleonly( ply, script, ccmd.id )
        return
    end

    if not access:bIsRoot( ply ) then
        access:deny_permission( ply, script, ccmd.id )
        return
    end

    /*
    *   output
    */

    con( pl, 1 )
    con( pl, 0 )
    con( pl, Color( 255, 255, 0 ), sf( 'Manifest » %s', pkg_name ) )
    con( pl, 0 )
    con( pl, manifest.desc )
    con( pl, 1 )

    local a1_l              = sf( '%-20s',  'Version'   )
    local a2_l              = sf( '%-5s',  '»'   )
    local a3_l              = sf( '%-35s',  sf( 'v%s build-%s', rlib.get:ver2str( manifest.version ), manifest.build )   )

    con( pl, Color( 255, 255, 0 ), a1_l, Color( 255, 255, 255 ), a2_l, a3_l )

    local b1_l              = sf( '%-20s',  'Author'    )
    local b2_l              = sf( '%-5s',  '»'          )
    local b3_l              = sf( '%-35s',  sf( '%s', manifest.author ) )

    con( pl, Color( 255, 255, 0 ), b1_l, Color( 255, 255, 255 ), b2_l, b3_l )

    con( pl, 2 )

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
            id          = pkg_name,
            name        = pkg_name,
            desc        = 'returns package information',
            scope       = 2,
            clr         = Color( 255, 255, 0 ),
            assoc = function( ... )
                rcc.call:Calc( ... )
            end,
        },
    }

    base.calls.commands:Register( pkg_commands )
end
hook.Add( pid( 'cmd.register' ), pid( '__calc.cmd.register' ), register_commands )

/*
*   register package
*/

local function register_pkg( )
    if not istable( _M ) then return end
    base.package:Register( _M )
end
hook.Add( pid( 'pkg.register' ), pid( '__calc.pkg.register' ), register_pkg )

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

function pkg:new( class )
    class = class or { }
    self.__index = self
    return smt( class, self )
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