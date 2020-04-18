/*
*   @package        : rlib
*   @module         : rcore
*   @author         : Richard [http://steamcommunity.com/profiles/76561198135875727]
*   @copyright      : (c) 2018 - 2020
*   @since          : 1.0.0
*   @website        : https://rlib.io
*   @docs           : https://docs.rlib.io
*   @file           : sv_init.lua
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

rcore                       = rcore or { }
local rlib                  = rlib
local base                  = rcore
local helper                = rlib.h
local storage               = rlib.s
local access                = rlib.a
local sys                   = rlib.sys
local rlib_mf               = rlib.manifest

/*
*   Localized lua funcs
*/

local Color                 = Color
local pairs                 = pairs
local tostring              = tostring
local istable               = istable
local isstring              = isstring
local file                  = file
local debug                 = debug
local util                  = util
local table                 = table
local os                    = os
local engine                = engine
local math                  = math
local string                = string
local sf                    = string.format

/*
*   Localized call func
*
*   @call   : call( 'net', 'initialize' )
*   @call   : call( 'hooks', 'initialize' )
*
*   @source : lua\autorun\libs\calls
*   @param  : str type
*   @param  : varg { ... }
*/

local function call( t, ... )
    return rlib:call( t, ... )
end

/*
*   Localized translation func
*/

local function lang( ... )
    return rlib:lang( ... )
end

/*
*	prefix ids
*/

local function pid( str, suffix )
    local state = ( isstring( suffix ) and suffix ) or ( base and base.manifest.prefix ) or false
    return rlib.get:pref( str, state )
end

/*
*   initialize :: stats
*
*   tracks the number of enabled modules as well as the disabled ones
*/

local function initialize_stats( )
    if not rlib.settings.debug.stats then return end

    rlib:log( 0 )
    rlib:log( RLIB_LOG_SYSTEM, '[ %s ] to start server',  timex.secs.benchmark( SysTime( ) ) )
    rlib:log( RLIB_LOG_SYSTEM, '[ %i ] tickrate',         math.Round( 1 / engine.TickInterval( ) ) )
    rlib:log( RLIB_LOG_SYSTEM, '[ %s ] startups',         string.Comma( sys.startups or 0 ) )
    rlib:log( 0 )

    sys.starttime = timex.secs.benchmark( SysTime( ) )
end
hook.Add( pid( 'initialize.post', rlib_mf.prefix ), pid( 'server.initialize' ), initialize_stats )

/*
*   modules :: write data
*
*   reports the list of loaded modules to a data file
*/

function base:modules_writedata( )

    local manifest = rlib_mf

    /*
    *   writedata :: modules
    *
    *   outputs the current installed modules to json in data/rlib
    */

    local mdata     = { }
    mdata.modules   = { }
    for k, v in pairs( base.modules ) do
        local ver   = ( istable( v.version ) and rlib.modules:ver2str( v.version ) ) or v.version

        mdata.modules[ k ]          = { }
        mdata.modules[ k ].name     = v.name
        mdata.modules[ k ].version  = ver
        mdata.modules[ k ].enabled  = v.enabled
    end
    table.sort( mdata, function( a, b ) return a[ 1 ] < b[ 1 ] end )

    file.Write( storage.mft:getpath( 'data_modules' ), util.TableToJSON( mdata ) )

    /*
    *   writedata :: manifest
    *
    *   outputs the current rlib manifest to json in data/rlib
    */

    local mnfst = { }
    for k, v in pairs( manifest ) do
        mnfst[ k ] = v
    end

    file.Write( storage.mft:getpath( 'data_manifest' ), util.TableToJSON( mnfst ) )

    /*
    *   writedata :: history
    *
    *   outputs the current startup to data/rlib
    */

    local ind_pos   = 0
    local data      = { }
    data.history    = { }
    data.startups   = 0

    local path_history = storage.mft:getpath( 'data_history' )
    if file.Exists( path_history, 'DATA' ) then
        local gdata = util.JSONToTable( file.Read( path_history, 'DATA' ) )
        if gdata then
            for k, v in pairs( gdata.history ) do
                data.history[ k ] = v
                ind_pos = ind_pos + 1
            end
        end
    end

    ind_pos         = ind_pos + 1
    data.startups   = ind_pos

    data.history[ ind_pos ] = os.time( )

    local history_sz    = file.Size( path_history, 'DATA' )

    sys.startups        = ind_pos
    sys.history_sz      = calc.fs.size( history_sz ) or 0
    sys.history_ct      = history_sz and 1 or 0

    file.Write( path_history, util.TableToJSON( data ) )

end
rhook.new.rlib( 'rcore_modules_load_post', 'rcore_modules_writedata', function( ) base:modules_writedata( ) end )

/*
*   validate module
*
*   checks a module for validation (typically used for gmodstore related addons)
*   validation also requires mod.parent.sys otherwise validation will fail
*
*   @param  : tbl source
*   @param  : bool bBypass
*/

function base:module_validate( source, bBypass )
    timex.simple( 'rcore_modules_validate', 0, function( )
        if source and not istable( source ) then
            local trcback = debug.traceback( )
            rlib:log( 2, 'cannot validate module, bad table\n[%s]', trcback )
            return
        end

        source = source or base.modules

        for v in helper.get.data( source ) do
            if not v.parent then continue end

            local mod_sys       = istable( v.parent.sys ) and v.parent.sys or { }
            mod_sys.validate    = true

            /*
            if ( v.script_id or v.sid ) and v.owner then
                rlib.oort:Gmodstore( v )
            end

            rlib.udm:scriptdb( v )
            */

            /*
            *   check each module's libreq version to see if rlib is updated to run properly
            */

            local libreq = v.libreq
            if not libreq then continue end
            if not bBypass and ( v.errorlog and v.errorlog.bLibOutdated ) then continue end

            local bHasError = false
            local mreq_ver  = rlib.get:version( v, true )
            local rlib_ver  = rlib.get:version( )

            /*
            *   major mismatch
            */

            if ( mreq_ver.major > rlib_ver.major ) then
                bHasError = true
            elseif ( mreq_ver.major == rlib_ver.major ) then

                /*
                *   minor mismatch
                */

                if mreq_ver.minor > rlib_ver.minor then
                    bHasError = true
                elseif mreq_ver.minor == rlib_ver.minor then

                    /*
                    *   patch mismatch
                    */

                    if mreq_ver.patch > rlib_ver.patch then
                        bHasError = true
                    end
                end
            end

            if bHasError then
                rlib:log( 0 )
                rlib:log( 2, '--------------------------------------------------------------------------------' )
                rlib:log( 2, lang( 'module_outdated', v.name, rlib_mf.name, rlib_mf.site ) )
                rlib:log( 2, '--------------------------------------------------------------------------------' )
                rlib:log( 0 )
                v.errorlog = v.errorlog or { }
                v.errorlog.bLibOutdated = true
            end

        end
    end )
end
rhook.new.gmod( 'Initialize', 'rcore_modules_validate', function( source ) base:module_validate( source ) end )

/*
*   modules :: register permissions
*
*   register permissions for each module
*
*   @param  : tbl source
*/

function base:modules_perms_register( source )
    if source and not istable( source ) then
        local trcback = debug.traceback( )
        rlib:log( 2, 'cannot register permissions for modules, bad table\n%s', trcback )
        return
    end

    source = source or base.modules

    for v in helper.get.data( source ) do
        if not v.enabled or not v.permissions then continue end
        rlib.a:initialize( v.permissions )
    end
end
rhook.new.gmod( 'PostGamemodeLoaded', 'rcore_modules_perms_register', function( source ) base:modules_perms_register( source ) end )