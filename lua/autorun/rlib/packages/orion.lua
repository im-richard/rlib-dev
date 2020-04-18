/*
*   @package        : rlib
*   @module         : orion
*   @author         : Richard [http://steamcommunity.com/profiles/76561198135875727]
*   @copyright      : (C) 2020 - 2020
*   @since          : 2.0.0
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
local helper            = base.h

/*
*   lib includes
*/

local access            = base.a
local helper            = base.h

/*
*   localize
*/

local sf 	            = string.format
local ins               = table.insert

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

module( 'orion', package.seeall )

/*
*   local declarations
*/

local pkg           = orion
local pkg_name      = _NAME or 'orion'

/*
*   pkg declarations
*/

local manifest =
{
    author          = 'richard',
    desc            = 'autoloader',
    build           = 040220,
    version         = { 1, 1, 0 },
    debug_id        = 'orion.debug.delay',
}

/*
*   dispatch
*/

local t = { }
local function dispatch( )
    t.cl = { }
    t.sh = { }
    t.sv = { }
end

/*
*   doFile
*/

local function doFile( dir, f )
    local realm = f:sub( 1, 3 )

    f = dir .. '/' .. f

    if realm == 'sh_' then
        ins( t.sh, f )
    elseif realm == 'sv_' then
        ins( t.sv, f )
    elseif realm == 'cl_' then
        ins( t.cl, f )
    end
end

/*
*   do_recurv
*/

local function do_recurv( dir )
    local files, dirs = file.Find( dir .. '/*', 'LUA' )

    rlib:log( 8, '   + folder       | %s', dir )

    for f in helper.get.data( files, ipairs ) do
        rlib:log( 8, '                  | %s', f )
        if f:match( '.*%.lua$' ) then
            doFile( dir, f )
        end
    end

    for d in helper.get.data( dirs, ipairs ) do
        rlib:log( 8, ' ' )
        do_recurv( dir .. '/' .. d )
    end
end

/*
*   orion :: run
*/

function run( dir, inc )
    rlib:log( 8, ' ' )
    rlib:log( 8, '[ %s ] Loading [ %s ]', pkg_name, dir )
    rlib:log( 8, '%s has now started loading the specified list of folders and files', pkg_name )
    rlib:log( 8, ' ' )

    dispatch( )
    do_recurv(dir)

    for v in helper.get.data( t.sh, ipairs ) do
        AddCSLuaFile( v )
        inc( v )
    end

    if SERVER then
        for v in helper.get.data( t.sv, ipairs ) do
            inc( v )
        end
    end

    for v in helper.get.data( t.cl, ipairs ) do
        if CLIENT then
            inc( v )
        else
            AddCSLuaFile( v )
        end
    end
end

/*
*   rcc :: base command
*
*   base package command
*/

function rcc.call:Orion( ply, cmd, args )

    /*
    *   permissions
    */

    local ccmd = base.calls:get( 'commands', 'orion' )

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
                rcc.call:Orion( ... )
            end,
        },
    }

    base.calls.commands:Register( pkg_commands )
end
hook.Add( pid( 'cmd.register' ), pid( '__orion.cmd.register' ), register_commands )

/*
*   register package
*/

local function register_pkg( )
    if not istable( _M ) then return end
    base.package:Register( _M )
end
hook.Add( pid( 'pkg.register' ), pid( '__orion.pkg.register' ), register_pkg )

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