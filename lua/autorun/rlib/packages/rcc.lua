/*
*   @package        rlib
*   @author         Richard [http://steamcommunity.com/profiles/76561198135875727]
*   @copyright      (C) 2018 - 2020
*   @since          3.0.0
*   @website        https://rlib.io
*   @docs           https://docs.rlib.io
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
*   pkg declarations
*/

    local manifest =
    {
        author          = 'richard',
        desc            = 'console commands',
        build           = 121919.1,
        version         = '1.0.0',
        debug_id        = 'rcc.debug.delay',
    }

/*
*   module declarations
*/

local dcat          = 9

/*
*   localizations
*/

local math          = math
local module        = module
local sf            = string.format

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
    return rlib:call( 'commands', id )
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

module( 'rcc', package.seeall )

/*
*   local declarations
*/

local pkg           = rcc
local pkg_name      = _NAME or 'rcc'

/*
*   required tables
*/

cfg                 = cfg or { }
sys                 = sys or { }
new                 = new or { }
run                 = run or { }
drop                = drop or { }

/*
*   net :: debugging
*   
*   determines if debugging mode is enabled
*/

cfg.debug = cfg.debug or false

/*
*	prefix :: getid
*/

local function gid( id )
    id = isstring( id ) and id or nil
    if not isstring( id ) then
        local trcback = debug.traceback( )
        base:log( dcat, '[ %s ] :: invalid id\n%s', pkg_name, tostring( trcback ) )
        return
    end

    id = call_id( id )

    return id
end

/*
*   module info :: manifest
*/

function pkg:manifest( )
    return self.__manifest
end

/*
*   new :: rlib
*
*   @ex     : rcc.new.rlib( 'module_concommand_name', module_fn_name )
*
*   @param  : str name
*   @param  : varg ( ... )
*/

function new.rlib( name, ... )
    name = gid( name )
    concommand.Add( name, ... )
end

/*
*   new :: gmod
*
*   @param  : varg ( ... )
*/

function new.gmod( ... )
    concommand.Add( ... )
end

/*
*   drop :: rlib
*
*   @param  : str name
*/

function drop.rlib( name )
    name = gid( name )
    concommand.Remove( name )
end

/*
*   drop :: gmod
*
*   @param  : str name
*/

function drop.gmod( name )
    concommand.Remove( name )
end

/*
*   run :: rlib
*
*   @param  : str cmd
*   @param  : varg ( ... )
*/

function run.rlib( cmd, ... )
    cmd = gid( cmd )
    RunConsoleCommand( cmd, ... )
end

/*
*   run :: gmod
*
*   @param  : varg ( ... )
*/

function run.gmod( ... )
    RunConsoleCommand( ... )
end

/*
*   register :: commands
*/

local function register_commands( )
    local pkg_commands = { }

    base.calls:register_cmds( pkg_commands )
end
hook.Add( pid( 'cmd.register' ), pid( '__rcc.cmd.register' ), register_commands )

/*
*   register package
*/

local function register_pkg( )
    if not istable( _M ) then return end
    base.pkgs:register( _M )
end
hook.Add( pid( 'pkg.register' ), pid( '__rcc.pkg.register' ), register_pkg )

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