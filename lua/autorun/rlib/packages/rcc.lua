/*
*   @package        : rlib
*   @module         : rcc
*   @author         : Richard [http://steamcommunity.com/profiles/76561198135875727]
*   @copyright      : (C) 2020 - 2020
*   @since          : 3.0.0
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

/*
*   module declarations
*/

local dcat          = 9

/*
*   localizations
*/

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
    local affix     = istable( suffix ) and suffix.id or isstring( suffix ) and suffix or prefix
    affix           = affix:sub( -1 ) ~= '.' and sf( '%s.', affix ) or affix

    id              = isstring( id ) and id or 'noname'
    id              = id:gsub( '[%c%s]', '.' )

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

module( 'rcc', package.seeall )

/*
*   local declarations
*/

local pkg           = rcc
local pkg_name      = _NAME or 'rcc'

/*
*   pkg declarations
*/

local manifest =
{
    author          = 'richard',
    desc            = 'console commands',
    build           = 032620,
    version         = { 2, 0, 0 },
    debug_id        = 'rcc.debug.delay',
}

/*
*   required tables
*/

cfg                 = cfg or { }
sys                 = sys or { }
new                 = new or { }
run                 = run or { }
drop                = drop or { }
call                = call or { }
storage             = storage or { }

/*
*   net :: debugging
*
*   determines if debugging mode is enabled
*/

cfg.debug           = cfg.debug or false

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
*   register
*
*   @param  : str cmd
*   @param  : func fn
*/

function register( cmd, fn )
    if not isstring( cmd ) then return end
    storage[ cmd ] = fn
end

/*
*   get
*
*   @param  : str cmd
*   @return : func
*/

function get( cmd )
    if not isstring( cmd ) then return end
    return storage[ cmd ] or nil
end

/*
*   rcc :: prepare
*
*   takes all of the registered commands through rlib and turns them into
*   a command usable with rcc
*
*   accepts an alternative source table but struct must be the same as the
*   original.
*
*   @call   : rcc.prepare( )
*
*   @param  : tbl source
*   @return : void
*/

function prepare( source )

    source = istable( source ) and source or _G.rcalls.commands

    for k, v in pairs( source ) do
        if not v.enabled then continue end

        if SERVER and ( v.scope == 1 or v.scope == 2 ) then
            local fn = rcc.get( k )
            if not fn then fn = v.assoc end
            rcc.new.gmod( v.id, fn )
            if v.alias then
                rcc.new.gmod( v.alias, fn )
            end
        elseif CLIENT and ( v.scope == 2 or v.scope == 3 ) then
            local fn = rcc.get( k )
            if not fn then fn = v.assoc end
            rcc.new.gmod( v.id, fn )
            if v.alias then
                rcc.new.gmod( v.alias, fn )
            end
        else
            continue
        end

        if SERVER and v.pubc then
            -- register commands with public triggers
            local id                = isstring( v.pubc ) and v.pubc
            _G.rcalls.pubc          = _G.rcalls.pubc or { }
            _G.rcalls.pubc[ id ]    = { cmd = id, func = rcc.get( k ) }

            sys.calls               = ( sys.calls or 0 ) + 1
        end
    end

end

/*
*   register :: commands
*/

local function register_commands( )
    local pkg_commands = { }

    base.calls.commands:Register( pkg_commands )
end
hook.Add( pid( 'cmd.register' ), pid( '__rcc.cmd.register' ), register_commands )

/*
*   register package
*/

local function register_pkg( )
    if not istable( _M ) then return end
    base.package:Register( _M )
end
hook.Add( pid( 'pkg.register' ), pid( '__rcc.pkg.register' ), register_pkg )

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