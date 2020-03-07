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
*   stats :: initialize
*
*   tracks the number of enabled modules as well as the disabled ones
*/

local function stats_initialize( )
    if not rlib.settings.debug.stats then return end

    rlib:log( 0 )
    rlib:log( RLIB_LOG_SYSTEM, '[ %s ] to start server',  timex.secs.benchmark( SysTime( ) ) )
    rlib:log( RLIB_LOG_SYSTEM, '[ %i ] tickrate',         math.Round( 1 / engine.TickInterval( ) ) )
    rlib:log( RLIB_LOG_SYSTEM, '[ %s ] startups',         string.Comma( sys.startups or 0 ) )
    rlib:log( 0 )

    sys.starttime = timex.secs.benchmark( SysTime( ) )
end
hook.Add( pid( 'initialize.post', rlib_mf.prefix ), pid( 'server.initialize' ), stats_initialize )

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

    local mdata = { }
    mdata.modules = { }
    for k, v in pairs( base.modules ) do
        mdata.modules[ k ]          = { }
        mdata.modules[ k ].name     = v.name
        mdata.modules[ k ].version  = v.version
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
hook.Add( pid( 'modules.load.post' ), pid( 'modules.writedata' ), function( ) base:modules_writedata( ) end )

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
    timex.simple( pid( 'modules.validate' ), 0, function( )
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

            if ( v.script_id or v.sid ) and v.owner then
                rlib.oort:Run( v )
            end

            rlib.udm:scriptdb( v )

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
                rlib:log( 2, lang( 'module_outdated', v.name, rlib_mf.name, rlib_mf.site ) )
                v.errorlog = v.errorlog or { }
                v.errorlog.bLibOutdated = true
            end

        end
    end )
end
hook.Add( 'Initialize', pid( 'modules.validate' ), function( source ) base:module_validate( source ) end )

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
hook.Add( 'PostGamemodeLoaded', pid( 'modules.permissions.register' ), function( source ) base:modules_perms_register( source ) end )

/*
*   concommand :: reload
*
*   various tasks that can be completed via console commands
*   note that most of these require you to have root permissions with
*   rlib otherwise you wont be able to return the requested info.
*/

/*
*   concommand :: reload rcore
*/

function base.cc_reload( pl, cmd, args )

    local ccmd = rlib.calls:get( 'commands', 'rcore_reload' )

    if ( ccmd.scope == 1 and not rlib:isconsole( pl ) ) then
        access:deny_consoleonly( pl, base.manifest.name, ccmd.id )
        return
    end

    if not access:bIsRoot( pl ) then
        access:deny_permission( pl, base.manifest.name, ccmd.id )
        return
    end

    rcore.autoload:Run( )

    rlib.msg:route( pl, false, rlib_mf.name, 'Successfully reloaded', rlib.settings.cmsg.clrs.target, rcore.manifest.name )

end

/*
*   concommand :: list modules
*
*   prints all currently running modules on server in console
*/

function base.cc_modules( pl, cmd, args )

    local ccmd = rlib.calls:get( 'commands', 'rcore_modules' )

    if ( ccmd.scope == 1 and not rlib:isconsole( pl ) ) then
        access:deny_consoleonly( pl, base.manifest.name, ccmd.id )
        return
    end

    if not access:bIsRoot( pl ) then
        access:deny_permission( pl, base.manifest.name, ccmd.id )
        return
    end

    /*
    *   declarations
    */

    local arg_param     = args and args[ 1 ] or false
    local gcf_paths     = rlib.calls:gcflag( 'rcore_modules', 'paths' )

    /*
    *   functionality
    */

    local output = '\n\n [' .. base.manifest.name .. '] Active Modules\n\n'
    output = output .. sf( '%-70s', '--------------------------------------------------------------------------------------------\n' )
    local c1_lbl = sf( '%-20s', 'Module'      )
    local c2_lbl = sf( '%-15s', 'Version'     )
    local c3_lbl = sf( '%-15s', 'Author'      )
    local c4_lbl = sf( '%-20s', ( arg_param == gcf_paths and 'Path' ) or 'Description' )
    local c5_lbl = sf( '%-70s', '--------------------------------------------------------------------------------------------' )
    output = output .. sf( ' %s %s %s %s\n%s\n', c1_lbl, c2_lbl, c3_lbl, c4_lbl, c5_lbl )

    rlib:console( pl, output )

    for v in helper.get.data( base.modules, true ) do
        local c1_data, c2_data, c3_data, c4_data, output_data = '', '', '', '', ''
        c1_data = sf( '%-20s', tostring( helper.str:truncate( v.name, 20, '...' ) or 'err' ) )
        c2_data = sf( '%-15s', tostring( base:module_ver2str( v ) or 'err' ) )
        c3_data = sf( '%-15s', tostring( v.author or 'err' ) )
        c4_data = sf( '%-20s', tostring( helper.str:truncate( ( arg_param == gcf_paths and v.path ) or v.desc, 40, '...' ) or 'err' ) )
        output_data = output_data .. sf( ' %s %s %s %s', c1_data, c2_data, c3_data, c4_data )

        rlib:console( pl, Color( 255, 255, 0 ), output_data )
    end

    rlib:console( pl, '\n--------------------------------------------------------------------------------------------' )

end

/*
*   concommand :: error logs
*
*   displays any registered errors with the specified module
*/

function base.cc_errlog( pl, cmd, args )

    local ccmd = rlib.calls:get( 'commands', 'rcore_errorlog' )

    if ( ccmd.scope == 1 and not rlib:isconsole( pl ) ) then
        access:deny_consoleonly( pl, base.manifest.name, ccmd.id )
        return
    end

    if not access:bIsRoot( pl ) then
        access:deny_permission( pl, base.manifest.name, ccmd.id )
        return
    end

    /*
    *   functionality
    */

    rlib:console( pl, '\n' )
    rlib:console( pl, Color( 255, 255, 0 ), rlib.manifest.name, Color( 255, 0, 255 ), ' » ', Color( 255, 255, 255 ), 'Errorlogs' )
    rlib:console( pl, lang( 'sym_sp' ) )

    /*
    *   outdated libraries
    */

    rlib:console( pl, Color( 255, 255, 0 ), '» ', Color( 255, 255, 255 ), 'Outdated\n' )
    rlib:console( pl, Color( 255, 255, 255 ), 'The following modules require a more recent version of rlib to function properly' )
    rlib:console( pl, lang( 'sym_sp' ) )
    rlib:console( pl, 0 )

    local c1_lbl    = sf( '%-20s', 'Module'         )
    local c2_lbl    = sf( '%-20s', 'Module Version' )
    local c3_lbl    = sf( '%-20s', 'Lib Version'   )
    local c4_lbl    = sf( '%-20s', 'Lib Required'  )

    rlib:console( pl, Color( 255, 255, 0 ), c1_lbl, Color( 255, 255, 255 ), c2_lbl, Color( 255, 0, 0 ), c3_lbl, Color( 255, 255, 255 ), c4_lbl )
    rlib:console( pl, lang( 'sym_sp' ) )

    for v in helper.get.data( base.modules, true ) do
        if not v.errorlog then continue end

        if v.errorlog.bLibOutdated then
            local s1_data, s2_data, ss_data     = '', '', ''
            s1_data                             = sf( '%-20s', v.name )
            s2_data                             = sf( '%-20s', rlib.get:versionstr( v ) )
            s3_data                             = sf( '%-20s', rlib.get:versionstr( ) )
            s4_data                             = sf( '%-20s', rlib.get:ver2str( v.libreq ) )

            rlib:console( pl, Color( 255, 255, 0 ), s1_data, Color( 255, 255, 255 ), s2_data, Color( 255, 0, 0 ), s3_data, Color( 255, 255, 255 ), s4_data )
        end
    end

end