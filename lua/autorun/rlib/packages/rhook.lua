/*
*   @package        : rlib
*   @module         : rhook
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
*   lib includes
*/

local access            = base.a
local helper            = base.h

/*
*   module declarations
*/

local dcat              = 9

/*
*   localizations
*/

local module            = module
local isstring          = isstring
local istable           = istable
local isfunction        = isfunction
local sf                = string.format

/*
*   simplifiy funcs
*/

local function con( ... ) base:console( ... ) end
local function log( ... ) base:log( ... ) end

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

module( 'rhook', package.seeall )

/*
*   local declarations
*/

local pkg           = rhook
local pkg_name      = _NAME or 'rhook'

/*
*   pkg declarations
*/

local manifest =
{
    author          = 'richard',
    desc            = 'hook management',
    build           = 032620,
    version         = { 2, 0, 0 },
    debug_id        = 'rhook.debug.delay',
}

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
        local tb = debug.traceback( )
        log( dcat, '[ %s ] :: invalid id\n%s', pkg_name, tostring( tb ) )
        return
    end

    id = call_id( id )

    return id
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

    local id    = isfunction( arg1 ) and event or isstring( arg1 ) and arg1
    local fn    = isfunction( arg1 ) and arg1 or isstring( arg1 ) and arg2 or nil

    if isstring( id ) then
        id = gid( id )
    end

    if not isfunction( fn ) then
        log( dcat, '[ %s ] :: invalid func\n%s', pkg_name, tostring( trcback ) )
        return
    end

    if cfg.debug then
        con( nil, event )
        con( nil, id )
        con( nil, 0 )
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
    event   = gid( event )
    id      = gid( id )
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
*   rcc :: base command
*
*   base package command
*/

function rcc.call:RHook( pl, cmd, args )

    /*
    *   permissions
    */

    local ccmd = base.calls:get( 'commands', 'rhook' )

    if ( ccmd.scope == 1 and not base.con:Is( pl ) ) then
        access:deny_consoleonly( pl, script, ccmd.id )
        return
    end

    if not access:bIsRoot( pl ) then
        access:deny_permission( pl, script, ccmd.id )
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
                rcc.call:RHook( ... )
            end,
        },
    }

    base.calls.commands:Register( pkg_commands )
end
hook.Add( pid( 'cmd.register' ), pid( '__rhook.cmd.register' ), register_commands )

/*
*   register package
*/

local function register_pkg( )
    if not istable( _M ) then return end
    base.package:Register( _M )
end
hook.Add( pid( 'pkg.register' ), pid( '__rhook.pkg.register' ), register_pkg )

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