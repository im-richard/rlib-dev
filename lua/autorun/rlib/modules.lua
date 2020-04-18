/*
*   @package        : rlib
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
local resources         = base.resources

/*
*   localized glua
*/

local sf                = string.format

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
    return cid( str, state )
end

/*
*   simplifiy funcs
*/

local function log( ... ) base:log( ... ) end

/*
*   base :: has dependency
*
*   checks to see if a function has the required dependencies such as rlib, rcore + modules, or specified 
*   objects in general are available
*
*   similar to rcore:bHasModule( ) but accepts other tables outside of rcore. use rcores version to confirm
*   just a module
*
*   @ex     : rlib.modules:bInstalled( mod )
*           : rlib.modules:bInstalled( 'identix' )
*
*   @param  : str, tbl mod
*   @return : bool
*/

function base.modules:bInstalled( mod )
    if not mod then
        log( 6, 'dependency not specified\n%s', debug.traceback( ) )
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
    log( 6, 'error loading required dependency [ %s ]\n%s', mod, debug.traceback( ) )

    return false
end

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
*   module :: version
*
*   returns the version of the installed module as a table
*
*   @call   : rlib.modules:ver( mod )
*           : rlib.modules:ver( 'lunera' )
*
*   @since  : v3.0.0
*   @return : tbl
*           : major, minor, patch
*/

function base.modules:ver( mod )
    if not mod then
        return {
            [ 'major' ] = 1,
            [ 'minor' ] = 0,
            [ 'patch' ] = 0
        }
    end
    if isstring( mod ) and self.modules[ mod ] and self.modules[ mod ].version then
        if isstring( self.modules[ mod ].version ) then
            local ver = string.Explode( '.', self.modules[ mod ].version )
            return {
                [ 'major' ] = ver[ 'major' ] or ver[ 1 ] or 1,
                [ 'minor' ] = ver[ 'minor' ] or ver[ 2 ] or 0,
                [ 'patch' ] = ver[ 'patch' ] or ver[ 3 ] or 0
            }
        elseif istable( self.modules[ mod ].version ) then
            return {
                [ 'major' ] = self.modules[ mod ].version.major or self.modules[ mod ].version[ 1 ] or 1,
                [ 'minor' ] = self.modules[ mod ].version.minor or self.modules[ mod ].version[ 2 ] or 0,
                [ 'patch' ] = self.modules[ mod ].version.patch or self.modules[ mod ].version[ 3 ] or 0
            }
        end
    elseif istable( mod ) and mod.version then
        if isstring( mod.version ) then
            local ver = string.Explode( '.', mod.version )
            return {
                [ 'major' ] = ver[ 'major' ] or ver[ 1 ] or 1,
                [ 'minor' ] = ver[ 'minor' ] or ver[ 2 ] or 0,
                [ 'patch' ] = ver[ 'patch' ] or ver[ 3 ] or 0
            }
        elseif istable( mod.version ) then
            return {
                [ 'major' ] = mod.version.major or mod.version[ 1 ] or 1,
                [ 'minor' ] = mod.version.minor or mod.version[ 2 ] or 0,
                [ 'patch' ] = mod.version.patch or mod.version[ 3 ] or 0
            }
        end
    end
    return {
        [ 'major' ] = 1,
        [ 'minor' ] = 0,
        [ 'patch' ] = 0
    }
end

/*
*   base :: module :: get list
*
*   returns table of modules installed on server
*
*   @return : tbl
*/

function base.modules:list( )
    if not rcore.modules then
        log( 2, 'modules table missing\n%s', debug.traceback( ) )
        return false
    end

    return rcore.modules
end

/*
*   module :: version to str
*
*   returns the version of the installed module in a human readable string
*
*   @call   : rlib.modules:ver2str( mod )
*           : rlib.modules:ver2str( 'lunera' )
*
*   @since  : v1.1.5
*   @return : str
*/

function base.modules:ver2str( mod )
    if not mod then return '1.0.0' end
    if isstring( mod ) and self.modules[ mod ] and self.modules[ mod ].version then
        if isstring( self.modules[ mod ].version ) then
            return self.modules[ mod ].version
        elseif istable( self.modules[ mod ].version ) then
            local major, minor, patch = self.modules[ mod ].version.major or self.modules[ mod ].version[ 1 ] or 1, self.modules[ mod ].version.minor or self.modules[ mod ].version[ 2 ] or 0, self.modules[ mod ].version.patch or self.modules[ mod ].version[ 3 ] or 0
            return sf( '%i.%i.%i', major, minor, patch )
        end
    elseif istable( mod ) and mod.version then
        if isstring( mod.version ) then
            return mod.version
        elseif istable( mod.version ) then
            local major, minor, patch = mod.version.major or mod.version[ 1 ] or 1, mod.version.minor or mod.version[ 2 ] or 0, mod.version.patch or mod.version[ 3 ] or 0
            return sf( '%i.%i.%i', major, minor, patch )
        end
    end
    return '1.0.0'
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
        log( 2, 'specified module not available\n%s', debug.traceback( ) )
        return false
    end

    if istable( rcore ) and ( isstring( mod ) and rcore.modules[ mod ] and rcore.modules[ mod ].enabled ) then
        return rcore.modules[ mod ]
    elseif istable( mod ) then
        return mod
    end

    mod = isstring( mod ) and mod or 'unknown'
    log( 6, 'error loading required dependency [ %s ]\n%s', mod, debug.traceback( ) )

    return false
end

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
        log( 6, 'warning: cannot create prefix with missing module in \n[ %s ]', debug.traceback( ) )
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

function base.modules:require( mod, bPrefix )
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
        log( 2, 'missing module [ %s ]\n%s', mod, debug.traceback( ) )
        return false
    end
end

/*
*   base :: module :: manifest
*
*   returns stored modules.txt file
*
*   @return : str
*/

function base.modules:Manifest( )
    local path      = storage.mft:getpath( 'data_modules' )
    local modules   = ''
    if file.Exists( path, 'DATA' ) then
        modules  = file.Read( path, 'DATA' )
    end

    return modules
end

/*
*   base :: module :: ManifestList
*
*   returns a list of modules in a simple string format
*
*   @return : str
*/

function base.modules:ManifestList( )
    local lst       = ''
    local i, pos    = table.Count( rcore.modules ), 1
    for k, v in SortedPairs( rcore.modules ) do
        local name      = v.name:gsub( '[%s]', '' )
        name            = name:lower( )

        local ver       = ( istable( v.version ) and rlib.modules:ver2str( v.version ) ) or v.version
        ver             = ver:gsub( '[%p]', '' )

        local enabled   = v.enabled and "enabled" or "disabled"

        local sep =     ( i == pos and '' ) or '-'
        lst            = string.format( '%s%s_%s_%s%s', lst, name, ver, enabled, sep )

        pos             = pos + 1
    end

    return lst
end

/*
*   base :: module :: log
*
*   logs data to rlib\modules\module_name\logs
*
*   @link   : rcore.log
*
*   @param  : tbl, str mod
*   @param  : int cat
*   @param  : str msg
*   @param  : varg varg
*/

base.modules.log = rcore.log

/*
*   base :: module :: get cfg
*
*   fetches config parameters from the specified module
*
*   @ex :
*
*       local cfg_mo 		= rlib and rlib.modules:cfg( 'module_name' )
*		local job_house		= cfg_mo.setting_name
*
*   @param  : str, tbl mod
*   @return : tbl
*/

function base.modules:cfg( mod )
    if not mod then
        log( 2, 'dependency not specified\n%s', debug.traceback( ) )
        return false
    end

    if istable( rcore ) and ( isstring( mod ) and rcore.modules[ mod ] and rcore.modules[ mod ].enabled ) then
        return rcore.modules[ mod ].settings
    elseif istable( mod ) then
        return mod.settings
    end

    mod = isstring( mod ) and mod or 'unknown'
    log( 6, 'error loading required dependency [ %s ]\n%s', mod, debug.traceback( ) )

    return false
end

/*
*   base :: module :: ents
*
*   fetches module ents
*
*   @param  : str, tbl mod
*   @return : tbl
*/

function base.modules:ents( mod )
    if not mod then
        log( 2, 'dependency not specified\n%s', debug.traceback( ) )
        return false
    end

    if istable( rcore ) and ( isstring( mod ) and rcore.modules[ mod ] and rcore.modules[ mod ].enabled ) then
        return rcore.modules[ mod ].ents
    elseif istable( mod ) then
        return mod.ents
    end

    mod = istable( mod ) and mod or 'unknown'
    log( 6, 'error fetching entities for module [ %s ]\n%s', mod, debug.traceback( ) )

    return false
end