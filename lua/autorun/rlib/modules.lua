/*
*   @package        rlib
*   @author         Richard [http://steamcommunity.com/profiles/76561198135875727]
*   @copyright      (C) 2018 - 2020
*   @since          3.0.0
*   @website        https://rlib.io
*   @docs           https://docs.rlib.io
*   @file           modules.lua
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
local cfg               = base.settings

/*
*   localized rlib routes
*/

local helper            = base.h
local storage           = base.s
local utils             = base.u
local access            = base.a
local tools             = base.t
local konsole           = base.k
local sys               = base.sys
local resources         = base.resources

/*
*   Localized cmd func
*
*   @source : lua\autorun\libs\calls
*   @param  : str t
*   @param  : varg { ... }
*/

local function call( t, ... )
    return rlib:call( t, ... )
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

local function cid( id, suffix )
    local affix = istable( suffix ) and suffix.id or isstring( suffix ) and suffix or prefix
    affix = affix:sub( -1 ) ~= '.' and string.format( '%s.', affix ) or affix

    id = isstring( id ) and id or 'noname'
    id = id:gsub( '[%c%s]', '.' )

    return string.format( '%s%s', affix, id )
end

/*
*	prefix ids
*/

local function pid( str, suffix )
    local state = ( isstring( suffix ) and suffix ) or ( base and prefix ) or false
    return cid( str, state )
end

/*
*   base :: package installed
*
*   checks to see if a module is indeed available to use
*
*   @ex     :   rlib:bPackageInstalled( 'glon', mod )
*               rlib:bPackageInstalled( 'rnet', 'module' )
*
*   @param  : str name
*   @param  : tbl, str requester
*   @return : bool
*/

function base:bPackageInstalled( name, requester )
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
        local chk_loader = v( name )
        if type( loader ) == 'function' then
            package.preload[ name ] = chk_loader
            return true
        end
    end

    base:log( 2, 'missing module [ %s ] » required for [ %s ]', name, id )

    return false
end

/*
*   base :: has dependency
*
*   checks to see if a function has the required dependencies such as rlib, rcore + modules, or specified 
*   objects in general are available
*
*   similar to rcore:bHasModule( ) but accepts other tables outside of rcore. use rcores version to confirm
*   just a module
*
*   @ex     : rlib:bHasDependency( mod )
*           : rlib:bHasDependency( 'identix' )
*
*   @param  : str, tbl mod
*   @return : bool
*/

function base:bHasDependency( mod )
    if not mod then
        base:log( 6, 'dependency not specified\n%s', debug.traceback( ) )
        return false
    end

    if istable( rcore ) and ( isstring( mod ) and rcore.modules[ mod ] and rcore.modules[ mod ].enabled ) then
        return true
    elseif istable( mod ) and mod.enabled then
        return true
    elseif istable( mod ) then
        return true
    end

    mod = isstring( mod ) and mod or 'unknown'
    rlib:log( 6, 'error loading required dependency [ %s ]\n%s', mod, debug.traceback( ) )

    return false
end
base.modules.bInstalled = base.bHasDependency

/*
*   base :: module :: exists
*
*   check if the specified module is valid or not
*
*   @param  : tbl, str mod
*   @return : bool
*/

function base.modules:bExists( mod )
    if not mod then return false end
    if istable( rcore ) and ( isstring( mod ) and rcore.modules[ mod ] and rcore.modules[ mod ].enabled ) then
        return true
    elseif istable( mod ) then
        return true
    end

    return false
end

/*
*   base :: module :: get module
*
*   returns specified module table
*
*   @param  : str, tbl mod
*   @return : tbl
*/

function base.modules:get( mod )
    if not mod then
        base:log( 2, 'specified module not available\n%s', debug.traceback( ) )
        return false
    end

    if istable( rcore ) and ( isstring( mod ) and rcore.modules[ mod ] and rcore.modules[ mod ].enabled ) then
        return rcore.modules[ mod ]
    elseif istable( mod ) then
        return mod
    end

    mod = isstring( mod ) and mod or 'unknown'
    base:log( 6, 'error loading required dependency [ %s ]\n%s', mod, debug.traceback( ) )

    return false
end
base.modules.inc = base.modules.get

/*
*   base :: module :: get prefix
*
*   used for various things such as font names, etc.
*
*   @param  : tbl mod
*   @param  : str suffix
*/

function base.modules:prefix( mod, suffix )
    if not istable( mod ) then
        base:log( 6, 'warning: cannot create prefix with missing module in \n[ %s ]', debug.traceback( ) )
        return
    end

    suffix = suffix or ''

    return string.format( '%s%s.', suffix, mod.id )
end
base.modules.pf = base.modules.prefix

/*
*   base :: module :: load module
*
*   loads specified module table
*
*   @param  : str, tbl mod
*   @return : tbl
*/

function base.modules:load( mod, bPrefix )
    local bLoaded = false
    if mod and rcore.modules[ mod ] and rcore.modules[ mod ].enabled then
        if bPrefix then
            return rcore.modules[ mod ], self:prefix( rcore.modules[ mod ] )
        else
            return rcore.modules[ mod ]
        end
        bLoaded = true
    end

    if not bLoaded then
        mod = mod or 'unknown'
        base:log( 2, 'missing module [ %s ]\n%s', mod, debug.traceback( ) )
        return false
    end
end
base.modules.require = base.modules.load

/*
*   base :: module :: get cfg
*
*   fetches config parameters from the specified module
*
*   @ex :
*
*       local cfg_mo 		= rlib and rlib.modules:getcfg( 'module_name' )
*		local job_house		= cfg_mo.setting_name
*
*   @param  : str, tbl mod
*   @return : tbl
*/

function base.modules:getcfg( mod )
    if not mod then
        base:log( 2, 'dependency not specified\n%s', debug.traceback( ) )
        return false
    end

    if istable( rcore ) and ( isstring( mod ) and rcore.modules[ mod ] and rcore.modules[ mod ].enabled ) then
        return rcore.modules[ mod ].settings
    elseif istable( mod ) then
        return mod.settings
    end

    mod = isstring( mod ) and mod or 'unknown'
    rlib:log( 6, 'error loading required dependency [ %s ]\n%s', mod, debug.traceback( ) )

    return false
end
base.modules.cfg = base.modules.getcfg

/*
*   base :: module :: get ents
*
*   fetches module ents
*
*   @param  : str, tbl mod
*   @return : tbl
*/

function base.modules:getents( mod )
    if not mod then
        base:log( 2, 'dependency not specified\n%s', debug.traceback( ) )
        return false
    end

    if istable( rcore ) and ( isstring( mod ) and rcore.modules[ mod ] and rcore.modules[ mod ].enabled ) then
        return rcore.modules[ mod ].ents
    elseif istable( mod ) then
        return mod.ents
    end

    mod = istable( mod ) and mod or 'unknown'
    rlib:log( 6, 'error fetching entities for module [ %s ]\n%s', mod, debug.traceback( ) )

    return false
end
base.modules.ents = base.modules.getents