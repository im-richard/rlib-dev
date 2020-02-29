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

/*
*   pkg declarations
*/

    local manifest =
    {
        author          = 'richard',
        desc            = 'hook management',
        build           = 121919.1,
        version         = '1.0.0',
        debug_id        = 'rhook.debug.delay',
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
    return rlib:call( 'hooks', id )
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

module( 'rhook', package.seeall )

/*
*   local declarations
*/

local pkg           = rhook
local pkg_name      = _NAME or 'rhook'

/*
*   required tables
*/

cfg                 = cfg or { }
sys                 = sys or { }
new                 = new or { }
run                 = run or { }
call                = call or { }
drop                = drop or { }

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

    id          = call_id( id )

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
*   ( switching parameters )
*       id      : can be either str or fn
*                 if id is a function, id will match event name
*
*   @ex     : rhook.new.rlib( 'identix_pl_authenticate', 'custom_id', pl_validate )
*           : rhook.new.rlib( 'identix_pl_authenticate', pl_validate )
*
*   @param  : str event
*   @param  : varg ( ... )
*/

function new.rlib( event, ... )
    event       = gid( event )
    local arg1  = select( 1, ... )
    local arg2  = select( 2, ... )

    local id = isfunction( arg1 ) and event or isstring( arg1 ) and arg1
    local fn = isfunction( arg1 ) and arg1 or isstring( arg1 ) and arg2 or nil

    if not isfunction( fn ) then
        base:log( dcat, '[ %s ] :: invalid func\n%s', pkg_name, tostring( trcback ) )
        return
    end

    hook.Add( event, id, fn )
end

/*
*   new :: gmod
*
*   @param  : str event
*   @param  : str id
*   @param  : fn fn
*/

function new.gmod( event, id, fn )
    id = gid( id )
    hook.Add( event, id, fn )
end

/*
*   new :: base
*
*   @param  : varg ( ... )
*/

function new.base( ... )
    hook.Add( ... )
end

/*
*   drop :: rlib
*
*   @param  : str event
*   @param  : str id
*   @param  : fn fn
*/

function drop.rlib( event, id )
    event = gid( event )
    hook.Remove( event, id )
end

/*
*   drop :: gmod
*
*   @param  : str event
*   @param  : str id
*   @param  : fn fn
*/

function drop.gmod( event, id )
    id = gid( id )
    hook.Remove( event, id )
end

/*
*   run :: rlib
*
*   @param  : str event
*   @param  : varg ...
*/

function run.rlib( event, ... )
    event = gid( event )
    hook.Run( event, ... )
end

/*
*   run :: gmod
*
*   @param  : str event
*   @param  : varg ...
*/

function run.gmod( event, ... )
    if not isstring( event ) then return end
    hook.Run( event, ... )
end

/*
*   call :: rlib
*
*   @param  : str event
*   @param  : varg ...
*/

function call.rlib( event, ... )
    event = gid( event )
    hook.Call( event, ... )
end

/*
*   call :: gmod
*
*   @param  : str event
*   @param  : varg ...
*/

function call.gmod( event, ... )
    if not isstring( event ) then return end
    hook.Call( event, ... )
end

/*
*   register :: commands
*/

local function register_commands( )
    local pkg_commands = { }

    base.calls:register_cmds( pkg_commands )
end
hook.Add( pid( 'cmd.register' ), pid( '__rhook.cmd.register' ), register_commands )

/*
*   register package
*/

local function register_pkg( )
    if not istable( _M ) then return end
    base.pkgs:register( _M )
end
hook.Add( pid( 'pkg.register' ), pid( '__rhook.pkg.register' ), register_pkg )

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