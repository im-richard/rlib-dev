/*
*   @package        : rlib
*   @module         : rcore
*   @author         : Richard [http://steamcommunity.com/profiles/76561198135875727]
*   @copyright      : (c) 2018 - 2020
*   @since          : 1.0.0
*   @website        : https://rlib.io
*   @docs           : https://docs.rlib.io
*   @file           : sh_init.lua
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
local base                  = rcore
local mf                    = base.manifest
local prefix                = mf.prefix
local cfg                   = base.settings
local sys                   = base.sys
local helper                = rlib.h
local access                = rlib.a
local storage               = rlib.s
local konsole               = rlib.k

/*
*   Localized lua funcs
*/

local pairs                 = pairs
local ipairs                = ipairs
local SortedPairs           = SortedPairs
local setmetatable          = setmetatable
local GetConVar             = GetConVar
local tonumber              = tonumber
local tostring              = tostring
local IsValid               = IsValid
local istable               = istable
local isfunction            = isfunction
local isentity              = isentity
local isnumber              = isnumber
local isstring              = isstring
local type                  = type
local file                  = file
local debug                 = debug
local util                  = util
local table                 = table
local os                    = os
local player                = player
local math                  = math
local string                = string
local sf                    = string.format

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
    local state = ( isstring( suffix ) and suffix ) or ( base and prefix ) or false
    return rlib.get:pref( str, state )
end

/*
*   module loader statistics
*/

local function modules_cstats( )
    rlib.l                      = { }
    sys.mloadtime               = os.clock( )
    sys.modules.total           = 0
    sys.modules.registered      = 0
    sys.modules.err             = 0
    sys.modules.disabled        = 0
end

/*
*   module :: version
*
*   returns the version of the installed module as a table
*
*   @call   : rcore:module_ver( mod )
*           : rcore:module_ver( 'lunera' )
*
*   @since  : v1.1.5
*   @return : tbl
*           : major, minor, patch
*/

function base:module_ver( mod )
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
*   module :: version to str
*
*   returns the version of the installed module in a human readable string
*
*   @call   : rcore:module_ver2str( mod )
*           : rcore:module_ver2str( 'lunera' )
*
*   @since  : v1.1.5
*   @return : str
*/

function base:module_ver2str( mod )
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
*   bHasModule
*
*   check if the specified module is valid or not
*
*   @param  : tbl, str mod
*   @return : bool
*/

function base:bHasModule( mod )
    if not mod then return false end
    if isstring( mod ) and self.modules[ mod ] and self.modules[ mod ].enabled then
        return true
    elseif istable( mod ) and mod.enabled then
        return true
    end
    return false
end

/*
*   bHasModule :: throw error
*
*   checks to see if a module is valid, if not, returns an error the player who utilized a feature
*   associated to failed module.
*
*   @param  : tbl, str mod
*   @param  : ply ply
*   @return : bool
*/

function base:bHasModule_throwError( mod, ply )
    if not mod then return false end
    if self:bHasModule( mod ) then
        return true
    else
        local mod_name = isstring( mod ) and mod or 'Unspecified'
        rlib:log( 2, 'you don\'t have access to this.' )
        rlib.msg:route( ply, false, rlib.manifest.name, 'WARNING:', rlib.settings.cmsg.clrs.target, mod_name:upper( ), rlib.settings.cmsg.clrs.msg, 'module has encountered an issue. Contact a server admin' )
        return false
    end
end

/*
*   modules :: autoloader :: configs
*
*   once a valid manifest file has been located, this function will be called to load all of the other
*   files assoc to the specified module.
*
*   @ex     : base:autoloader_configs( 'modules/identix', 'identix' )
*
*   @param  : str loc
*   @param  : str mod_id
*/

function base:autoloader_configs( loc, mod_id )
    local files, _ = file.Find( loc .. '/' .. '*', 'LUA' )
    for _, File in ipairs( files ) do
        if ( File:match( '.lua' ) and ( File:match( 'config' ) or File:match( 'cfg' ) or File:match( 'settings' ) ) ) then
            local cfg_file = loc .. '/' .. File
            if SERVER then
                if File:match( 'sh_' ) then
                    AddCSLuaFile( cfg_file )
                    include( cfg_file )
                elseif File:match( 'sv_' ) then
                    include( cfg_file )
                elseif File:match( 'cl_' ) then
                    AddCSLuaFile( cfg_file )
                end
                rlib:log( 6, '+ cfg [ %s ] for module [ %s ]', cfg_file, mod_id )
            elseif CLIENT then
                if File:match( 'sh_' ) then
                    include( cfg_file )
                elseif File:match( 'cl_' ) then
                    include( cfg_file )
                end
                rlib:log( 6, '+ cfg [ %s ] for module [ %s ]', cfg_file, mod_id )
            end
        end
    end
end

/*
*   modules :: autoloader :: assoc files
*
*   loads any files / folders assoc to the specified module. This should be done after the manifest
*   and config files have already been registered with the system.
*
*   recursive subfolders supported
*
*   @assoc  : base:autoloader_modules( loc, module_id, b_isext )
*   @ex     : base:modules_attachfile( 'lunera' )
*
*   @param  : str loc
*   @param  : bool b_isext
*   @return : void
*/

function base:modules_attachfile( loc, b_isext )

    /*
    *   define base path
    */

    local path_base = b_isext and loc or mf.modpath

    /*
    *   module autoloader :: SERVER
    */

    if SERVER then

        local files, dirs = file.Find( path_base .. '/*', 'LUA' )

        /*
        *   module autoloader :: serverside -> shared
        */

        local function inc_sv( path_root, id, term )
            local scope = { [ 1 ] = 'SV', [ 2 ] = 'SH', [ 3 ] = 'CL' }

            for _, File in SortedPairs( file.Find( path_root .. '/' .. term .. '_*.lua', 'LUA' ), true ) do
                if id == 1 or id == 2 then include( path_root .. '/' .. File ) end
                if id == 2 or id == 3 then AddCSLuaFile( path_root .. '/' .. File ) end

                rlib:log( RLIB_LOG_DEBUG, '+ file [ %s ] [ %s ] for module [ %s ]', scope[ id ], File, loc )
            end

            local file_sub, dir_sub = file.Find( path_root .. '/' .. '*', 'LUA' )
            for l, m in pairs( dir_sub ) do
                for _, FileSub in SortedPairs( file.Find( path_root .. '/' .. m .. '/' .. term .. '_*.lua', 'LUA' ), true ) do
                    if id == 1 or id == 2 then include( path_root .. '/' .. m .. '/' .. FileSub ) end
                    if id == 2 or id == 3 then AddCSLuaFile( path_root .. '/' .. m .. '/' .. FileSub ) end

                    rlib:log( RLIB_LOG_DEBUG, '+ file [ %s ] [ %s ] for module [ %s ]', scope[ id ], FileSub, loc )
                end

                if id == 2 then
                    if ( m == 'lang' or m == 'languages' or m == 'translations' ) then
                        for _, SubFile in SortedPairs( file.Find( path_root .. '/' .. m .. '/*.lua', 'LUA' ), true ) do
                            local path_inc  = path_root .. '/' .. m .. '/' .. SubFile
                            AddCSLuaFile    ( path_inc )
                            include         ( path_inc )

                            rlib:log( RLIB_LOG_SYSTEM, '+ lang [ %s ] for module [ %s ]', SubFile, loc )
                        end
                    end
                end
            end
        end

        /*
        *   module autoloader :: serverside -> load
        */

        for _, dir in SortedPairs( dirs, true ) do
            if dir ~= loc then continue end
            if dir == '.' or dir == '..' then continue end

            local path_mod = sf( '%s/%s', path_base, dir )

            inc_sv( path_mod, 1, 'sv'  )
            inc_sv( path_mod, 2, 'sh'  )
            inc_sv( path_mod, 3, 'cl'  )
            inc_sv( path_mod, 3, 'i'   )
        end

    end

    /*
    *   module autoloader :: CLIENT
    */

    if CLIENT then

        local files, dirs = file.Find( path_base .. '/*', 'LUA' )

        /*
        *   module autoloader :: clintside -> shared
        */

        local function inc_cl( path_root, id, term )
            local scope = { [ 2 ] = 'SH', [ 3 ] = 'CL' }

            for _, File in SortedPairs( file.Find( path_root .. '/' .. term .. '_*.lua', 'LUA' ), true ) do
                include( path_root .. '/' .. File )

                rlib:log( RLIB_LOG_DEBUG, '+ file [ %s ] [ %s ] for module [ %s ]', scope[ id ], File, loc )
            end
            local file_sub, dir_sub = file.Find( path_root .. '/' .. '*', 'LUA' )
            for l, m in pairs( dir_sub ) do
                for _, FileSub in SortedPairs( file.Find( path_root .. '/' .. m .. '/' .. term .. '_*.lua', 'LUA' ), true ) do
                    include( path_root  .. '/' .. m .. '/' .. FileSub )

                    rlib:log( RLIB_LOG_DEBUG, '+ file [ %s ] [ %s ] for module [ %s ]', scope[ id ], FileSub, loc )
                end
                if id == 2 then
                    if ( m == 'lang' or m == 'languages' or m == 'translations' ) then
                        for _, SubFile in SortedPairs( file.Find( path_root .. '/' .. m .. '/*.lua', 'LUA' ), true ) do
                            local path_inc = path_root .. '/' .. m .. '/' .. SubFile
                            include( path_inc )

                            rlib:log( RLIB_LOG_SYSTEM, '+ lang [ %s ] for module [ %s ]', SubFile, loc )
                        end
                    end
                end
            end
        end

        /*
        *   module autoloader :: clintside -> load
        */

        for _, dir in SortedPairs( dirs, true ) do
            if dir ~= loc then continue end
            if dir == '.' or dir == '..' then continue end

            local path_mod = sf( '%s/%s', path_base, dir )

            inc_cl( path_mod, 2, 'sh'  )
            inc_cl( path_mod, 3, 'cl'  )
            inc_cl( path_mod, 3, 'i'   )
        end

    end

end

/*
*   modules :: autoloader
*
*   once a valid manifest file has been located, this function will be called to load all of the other
*   files associated to the specified module.
*
*   @ex     : loc => modules/footprints/, mod_id => footprints
*
*   @param  : str loc
*   @param  : str mod_id
*   @param  : bool b_istext
*   @return : void
*/

function base:autoloader_modules( loc, mod_id, b_isext )
    local _, folder = helper.str:splitpath( loc )
    self:modules_attachfile( folder, b_isext )
    rlib:log( RLIB_LOG_SYSTEM, '+ module » [ %s ]', mod_id )
end

/*
*   modules :: autoloader :: manifest
*
*   loads of the modules manifest file and registers the data associated to the specified module.
*/

local function autoloader_manifest_modules( )

    modules_cstats( )
    base.sys.loadpriority = cfg.loadpriority or { }

    local folder    = mf.modpath
    local _, dirs   = file.Find( folder .. '*', 'LUA' )

    /*
     *   prioritized loading for certain modules ( ie: base )
    *   usually configured in `lua\rlib\sh_config.lua`
    */

    for k, v in pairs( base.sys.loadpriority ) do
        local module_dir = sf( '%s/%s', folder, k )
        for _, sub in SortedPairs( file.Find( module_dir .. '/*.lua', 'LUA' ), true ) do
            if not sub:match( 'manifest' ) and not sub:match( 'env' ) and not sub:match( 'pkg' ) then continue end
            if sub:match( 'demo' ) then continue end

            local inc = sf( '%s/%s', module_dir, sub )
            if not inc then continue end

            if SERVER then AddCSLuaFile( inc ) end

            include( inc )
            base:module_register( module_dir, sub )
        end
    end

    /*
    *   load the remainder of the modules not included in the module prioritizer.
    */

    local _, sub_dir = file.Find( folder .. '/' .. '*', 'LUA' )
    for l, m in pairs( sub_dir ) do
        if base.sys.loadpriority[ m ] then continue end
        local path_manifest = sf( '%s/%s', folder, m )
        for _, sub in SortedPairs( file.Find( path_manifest .. '/*.lua', 'LUA' ), true ) do
            if not sub:match( 'manifest' ) and not sub:match( 'env' ) and not sub:match( 'pkg' ) then continue end

            local inc = sf( '%s/%s', path_manifest, sub )
            if not inc then continue end

            if SERVER then AddCSLuaFile( inc ) end

            include( inc )
            base:module_register( path_manifest, sub )
        end
    end

    /*
    *   garbage cleanup
    */

    storage.garbage( 'autoloader_manifest_modules', { base.sys.loadpriority, sys.mloadtime } )

end

/*
*   modules :: autoloader :: externals
*
*   checks for external modules that may have been installed using the addons folder.
*/

function base:autoloader_ext_modules( )

    local function manifest_search( loc )

        if loc == '/' or not loc then loc = '' end

        local files, dirs = file.Find( loc .. '*', 'LUA' )

        for _, dir in pairs( dirs ) do
            manifest_search( loc .. dir .. '/' )
        end

        for _, subfile in pairs( files ) do
            local path = loc .. subfile
            if not path:match( 'manifest' ) then continue end
            self:module_register( loc, subfile, true )
        end

    end

    manifest_search( '/' )

end

/*
*   modules :: prefix
*
*   used for various things such as font names, etc.
*
*   @ex     : base:modules_prefix( mod )
*
*   @param  : tbl mod
*   @param  : str suffix
*   @return : str
*/

function base:modules_prefix( mod, suffix )
    if not istable( mod ) then
        rlib:log( 6, 'warning: cannot create prefix with missing module in \n[ %s ]', debug.traceback( ) )
        return
    end

    suffix = suffix or ''

    return suffix .. mod.id .. '.'
end

/*
*   modules :: settings
*
*   returns the module settings
*
*   @ex     : base:modules_settings( mod )
*
*   @param  : tbl, str mod
*   @return : tbl
*/

function base:modules_settings( mod )
    local bLoaded = false
    if mod then
        if isstring( mod ) then
            if self.modules[ mod ] and self.modules[ mod ].enabled and self.modules[ mod ].settings then
                bLoaded = true
                return self.modules[ mod ].settings
            end
        elseif istable( mod ) then
            if mod.enabled and mod.settings then
                bLoaded = true
                return mod.settings
            end
        end
    end

    if not bLoaded then
        local mod_output = isstring( mod ) and mod or 'unspecified'
        rlib:log( 2, 'missing module settings [ %s ]\n%s', mod_output, debug.traceback( ) )
        return false
    end
end

/*
*   load module
*
*   returns valid data on a particular module and the correct prefix
*
*   @param  : str mod
*   @param  : bool bPrefix
*   @return : tbl, str
*/

function base:modules_load( mod, bPrefix )
    local bLoaded = false
    if mod and self.modules[ mod ] and self.modules[ mod ].enabled then
        if bPrefix then
            return self.modules[ mod ], self:modules_prefix( self.modules[ mod ] )
        else
            return self.modules[ mod ]
        end
        bLoaded = true
    end

    if not bLoaded then
        mod = mod or 'unknown'
        rlib:log( 2, 'missing module [ %s ]\n%s', mod, debug.traceback( ) )
        return false
    end
end

/*
*   modules :: in demo mode
*
*   checks to see if module is in demo mode
*   this mode is typically used by the developer to setup specific settings and features a certain way
*   so they can be presented to the public.
*
*   demo mode can be set in the modules manifest file
*
*   enabling this will cause a warning to display in console
*
*   @param  : tbl, str mod
*   @return : bool
*/

function base:bInDemoMode( mod )
    if not mod then return false end
    if isstring( mod ) and self.modules[ mod ] and ( self.modules[ mod ].demomode or self.modules[ mod ].demo ) then
        return true
    elseif istable( mod ) and ( mod.demomode or mod.demo ) then
        return true
    end
    return false
end

/*
*   modules :: logging
*
*   log module information to the data folder
*       /rlib/modules/[module_name]/
*
*   to write a log to another directory not associated to 
*       /rlib/modules => rlib :: konsole:log( path, cat, data )
*
*   files in the directory are created based on the current date. a new file will be made if a log is 
*   submitted on a day where no file with that date exists.
*
*   param bPostnow will instantly push msg to konsole
*
*   @ex     : base:log( 'xp', 1, 'information to log' )
*
*   @param  : tbl, str mod
*   @param  : int cat
*   @param  : str data
*   @param  : bool bPostnow
*/

function base:log( mod, cat, data, bPostnow )
    if not mod then
        base:log( 2, 'unable to log unspecified module' )
        return false
    end

    local mod_data
    local bLoaded           = false

    if isstring( mod ) then
        if self.modules[ mod ] and self.modules[ mod ].enabled then
            bLoaded         = true
            mod_data        = self.modules[ mod ]
        end
    elseif istable( mod ) then
        if mod.enabled then
            bLoaded         = true
            mod_data        = mod
        end
    end

    if not bLoaded then
        local mod_output = isstring( mod ) and mod or 'unspecified'
        rlib:log( 2, 'missing module [ %s ] :: cannot write log\n%s', mod_output, debug.traceback( ) )
        return false
    end

    if not mod_data.logging then return end
    if not cat then cat = 1 end

    local c_type
    if isnumber( cat ) then
        c_type = '[' .. helper.str:ucfirst( rlib._def.debug_titles[ cat ] ) .. ']'
    elseif isstring( cat ) then
        c_type = '[' .. cat .. ']'
    end

    local f_prefix  = os.date( '%m%d%Y' )
    local f_name    = 'RL_' .. f_prefix .. '.txt'

    local c_date    = '[' .. os.date( '%I:%M:%S' ) .. ']'
    local c_comp    = sf( '%s %s %s', c_date, c_type, data )

    local _stdir    = storage.mft:getpath( 'dir_modules' )
    storage.file.append( _stdir .. '/' .. mod_data.id .. '/logs', f_name, c_comp )

    if bPostnow then
        konsole:add_simple( cat, data )
    end
end

/*
*   modules :: initialize
*
*   start loading all required modules
*/

local function modules_initialize( )

    hook.Run( pid( 'modules.load.pre' ) )

    autoloader_manifest_modules( )

    rlib:log( 0 )
    rlib.calls:load( )
    rlib:log( 0 )

    rlib:log( RLIB_LOG_SYSTEM, lang( 'logs_modules_total',        sys.modules.total               ) )
    rlib:log( RLIB_LOG_SYSTEM, lang( 'logs_modules_active',       sys.modules.registered          ) )
    rlib:log( RLIB_LOG_SYSTEM, lang( 'logs_modules_err',          sys.modules.err                 ) )
    rlib:log( RLIB_LOG_SYSTEM, lang( 'logs_modules_disabled',     sys.modules.disabled            ) )
    rlib:log( RLIB_LOG_SYSTEM, lang( 'logs_modules_loadtime',     timex.secs.ms( sys.mloadtime )  ) )

    rlib:log( 0 )

    hook.Run( pid( 'modules.load.post' ), base.modules )

end
hook.Add( pid( 'loader.post' ), pid( 'modules.initialize' ), modules_initialize )
hook.Add( 'OnReloaded', pid( 'modules.onreload' ), modules_initialize )

/*
*   modules :: storage
*
*   will create any required folders needed by the module to store certain data
*
*   @param  : tbl source
*/

function base:modules_storage( source )

    if source and not istable( source ) then
        rlib:log( 2, 'cannot manage storage for modules, bad table\n%s', debug.traceback( ) )
        return
    end

    source = source or base.modules

    /*
    *   modules :: storage :: create data dir
    *
    *   creates the requested folders in the data directory
    *
    *   @param  : tbl data
    *   @param  : str mod_id
    */

    local function cdatafolder( data, mod_id )
        if not istable( data ) then
            rlib:log( 2, '[ %s ] bad data table provided for [ %s ]', 'modules_storage' )
            return
        end

        mod_id = mod_id or prefix

        if not data[ 'parent' ] or not data[ 'sub' ] then
            rlib:log( 2, '[ %s ] failed to specify new datafolder in manifest', mod_id )
            return
        end

        local fol_parent    = tostring( data[ 'parent' ] )
        local fol_sub       = tostring( data[ 'sub' ] )

        if not file.Exists( fol_parent, 'DATA' ) then
            file.CreateDir( fol_parent )
            rlib:log( 6, '[ %s ] created datafolder parent [ %s ]', mod_id, fol_parent )
        end

        if not file.Exists( fol_parent .. '/' .. fol_sub, 'DATA' ) then
            file.CreateDir( fol_parent .. '/' .. fol_sub )
            rlib:log( 6, '[ %s ] created datafolder sub [ %s ]', mod_id, fol_sub )
        end
    end

    for v in helper.get.data( source ) do
        if v.enabled and v.datafolder and istable( v.datafolder ) then
            for d in helper.get.data( v.datafolder ) do
                cdatafolder( d, v.id )
            end
        end
    end

end
hook.Add( 'PostGamemodeLoaded', pid( 'modules.storage' ), function( source ) base:modules_storage( source ) end )

/*
*   modules :: precache
*
*   precache any valid models and sounds associated to entities
*
*   @param  : tbl source
*/

function base:modules_precache( source )
    if source and not istable( source ) then
        rlib:log( 2, 'cannot find entities for modules, bad table\n%s', debug.traceback( ) )
        return
    end

    source = source or base.modules

    /*
    *   precache various items such as sounds, models, particles
    */

    for v in helper.get.data( source ) do
        if not v.ents and not istable( v.ents ) then continue end
        for m in helper.get.data( v.ents ) do

            /*
            *   models :: string
            */

            if isstring( m.model ) or isstring( m.mdl ) then
                local src_mdl = isstring( m.model ) and m.model or isstring( m.mdl ) and m.mdl
                rlib.register:model( src_mdl, true )
            end

            /*
            *   models :: table
            */

            if istable( m.model ) or istable( m.mdl ) then
                local src_mdl = istable( m.model ) and m.model or istable( m.mdl ) and m.mdl
                for s in helper.get.data( src_mdl ) do
                    rlib.register:model( s, true )
                end
            end

            /*
            *   sounds :: string
            */

            if isstring( m.sound ) or isstring( m.snd ) then
                local src_snd = isstring( m.sound ) and m.sound or isstring( m.snd ) and m.snd
                rlib.register:sound( src_snd )
            end

            /*
            *   sounds :: table
            */

            if istable( m.sound ) or istable( m.snd ) then
                local src_snd = istable( m.sound ) and m.sound or istable( m.snd ) and m.snd
                for s in helper.get.data( src_snd ) do
                    rlib.register:sound( s )
                end
            end

            /*
            *   particles :: string
            */

            if isstring( m.particles ) or isstring( m.ptc ) then
                local src_ptc = isstring( m.particles ) and m.particles or isstring( m.ptc ) and m.ptc
                rlib.register:particle( src_ptc )
            end

            /*
            *   particles :: table
            */

            if istable( m.particles ) or istable( m.ptc ) then
                local src_ptc = istable( m.particles ) and m.particles or istable( m.ptc ) and m.ptc
                for s in helper.get.data( src_ptc ) do
                    rlib.register:particle( s )
                end
            end

            /*
            *   particles :: precache :: table
            */

            if istable( m.particles_pc ) or istable( m.ptc_pc ) then
                local src_ptc = istable( m.particles_pc ) and m.particles_pc or istable( m.ptc_pc ) and m.ptc_pc
                for s in helper.get.data( src_ptc ) do
                    rlib.register:particle( s )
                end
            end

        end
    end
end
hook.Add( 'PostGamemodeLoaded', pid( 'modules.precache' ), function( source ) base:modules_precache( source ) end )

/*
*   modules :: dependency check
*
*   check to see if a module has the proper dependencies
*
*   @param  : tbl source
*/

local function modules_dependencies( source )
    source = source or base.modules

    if not source or ( source and not istable( source ) ) then
        rlib:log( 2, 'cannot check dependency for modules, bad table\n%s', debug.traceback( ) )
        return
    end

    for v in helper.get.data( source ) do
        if not v.id or not v.enabled then continue end

        if v.dependencies and istable( v.dependencies ) then
            for m in helper.get.data( v.dependencies ) do
                local name = isstring( m.name ) and m.name or 'unspecified dependency name'
                if not m.check then
                    rlib:log( 2, '[ %s ] failed dependency check missing func [ %s ]', v.id, name )
                    continue
                end
                local has_depen = m.check( )
                if has_depen then
                    rlib:log( 6, '[ %s ] found dependency [ %s ]', v.id, name )
                else
                    rlib:log( 2, '[ %s ] failed or missing dependency [ %s ]', v.id, name )
                end
            end
        end
    end
end
hook.Add( 'PostGamemodeLoaded', pid( 'modules.dependencies' ), modules_dependencies )

/*
*   modules :: register workshops
*
*   register each workshop assocaited to a module
*
*   @assoc  : modules.load.post
*
*   @param  : tbl source
*/

local function modules_resources( source )

    if source and not istable( source ) then
        rlib:log( 2, 'cannot register workshops for modules, bad table\n%s', debug.traceback( ) )
        return
    end

    source = source or base.modules

    for v in helper.get.data( source ) do

        if not v.id or not v.enabled then continue end

        /*
        *   workshop resources
        *
        *   determined through the module manifest file.
        *
        *   defined in module manifest
        *       :   MODULE.ws_enabled   ( bool )
        *       :   MODULE.ws_lst       ( tbl )
        */

        if ( v.workshopsenabled or v.ws_enabled ) and ( v.workshops or v.ws_lst or v.collections ) then
            local src = istable( v.ws_lst ) and v.ws_lst or istable( v.workshops ) and v.workshops or istable( v.collections ) and v.collections
            if not istable( src ) then continue end
            for m in helper.get.data( src ) do
                if SERVER then
                    resource.AddWorkshop( m )
                    rlib:log( RLIB_LOG_WS, '+ %s » [ %s ]', tostring( v.id ), m )
                elseif CLIENT then
                    steamworks.FileInfo( m, function( res )
                        if res and res.fileid then
                            steamworks.Download( res.fileid, true, function( name )
                                game.MountGMA( name or '' )
                                local size = res.size / 1024
                                rlib:log( RLIB_LOG_WS, '+ %s [ %s ] » %i KB', tostring( v.id ), res.title, math.Round( size ) )
                            end )
                        end
                    end )
                end

                rlib.w[ m ]         = { }
                rlib.w[ m ].id      = m
                rlib.w[ m ].src     = v.id or 'unknown'
            end
        end

        /*
        *   fastdl resources
        *   determined through the module manifest file.
        */

        if v.fastdl then
            local r_path = mf.modpath
            local d_path = r_path .. '/' .. v.id .. '/' .. 'resource'
            if file.IsDir( d_path, 'LUA' ) then
                storage.data.recurv( v.id, d_path )
            else
                local lst_folders = { 'materials', 'sound', 'resource' }
                for l, m in pairs( lst_folders ) do
                    local module_folder     = v.fastdl_folder or v.id
                    local folder            = m .. '/' .. module_folder
                    storage.data.recurv( v.id, folder, 'GAME' )
                end
            end
        end

        /*
        *   ( fonts ) :: regular
        */

        if istable( v.fonts ) then
            local fonts = v.fonts
            if #fonts > 0 then
                for _, f in pairs( fonts ) do
                    resource.AddFile( 'resource/fonts/' .. f )
                    rlib:log( RLIB_LOG_FONT, '+ %s » [ %s ]', v.id, f )
                end
            end
        end

        /*
        *   ( fonts ) :: push internals
        */

        if v.fonts_push then
            local fonts = file.Find( 'resource/fonts/*', 'GAME' )
            if #fonts > 0 then
                for _, f in pairs( fonts ) do
                    resource.AddFile( 'resource/fonts/' .. f )
                    rlib:log( RLIB_LOG_FONT, '+ %s » [ %s ]', v.id, f )
                end
            end
        end

    end

end
hook.Add( pid( 'modules.load.post' ), pid( 'modules.resources.register' ), modules_resources )

/*
*   modules :: register particles
*
*   registers particles for each module
*   particles should be defined in the module manifest file
*       :   MODULE.particles
*
*   entries that include .pcf at the end will mount using game.AddParticles
*   entries without the pcf extension will use PrecacheParticleSystem
*
*   @assoc  : modules.load.post
*
*   @param  : tbl source
*/

local function register_particles( source )

    if source and not istable( source ) then
        rlib:log( 2, 'cannot register particles for modules, bad table\n%s', debug.traceback( ) )
        return
    end

    source = source or base.modules

    for v in helper.get.data( source ) do

        if not v.id or not v.enabled then continue end

        /*
        *   workshop resources
        *   determined through the module manifest file.
        */

        if v.particles then
            if istable( v.particles ) then
                for m in helper.get.data( v.particles ) do
                    rlib.register:particle( m )
                end
            elseif isstring( v.particles ) then
                rlib.register:particle( v.particles )
            end
        end
    end

end
hook.Add( pid( 'modules.load.post' ), pid( 'modules.particles.register' ), register_particles )

/*
*   modules :: register sounds
*
*   registers sounds for each module
*   particles should be defined in the module manifest file
*       :   MODULE.sounds
*
*   @assoc  : modules.load.post
*
*   @param  : tbl source
*/

local function register_sounds( source )

    if source and not istable( source ) then
        rlib:log( 2, 'cannot register particles for modules, bad table\n%s', debug.traceback( ) )
        return
    end

    source = source or base.modules

    for v in helper.get.data( source ) do

        if not v.id or not v.enabled then continue end

        /*
        *   workshop resources
        *   determined through the module manifest file.
        */

        if v.sounds then
            if istable( v.sounds ) then
                for m in helper.get.data( v.sounds ) do
                    rlib.register:particle( m )
                end
            elseif isstring( v.sounds ) then
                rlib.register:particle( v.sounds )
            end
        end
    end

end
hook.Add( pid( 'modules.load.post' ), pid( 'modules.sounds.register' ), register_sounds )

/*
*   modules :: storage :: register defaults
*
*   register default storage tables
*
*   @ex     : hook.Run( pid( 'modules.storage.defaults' ), mod_id )
*
*   @param  : tbl source
*/

local function storage_struct_defs( mod_id )

    if not mod_id then
        rlib:log( 2, 'cannot create def storage tables for module, bad mod id\n%s', debug.traceback( ) )
        return
    end

    local source = base.modules

    /*
    *   storage :: base
    */

    local storage_def =
    {
        bInitialized        = false,
        initialize          = { },
        action              = { },
        cc                  = { },
        ent                 = { },
        binds               = { },
        pnl                 = { },
        ui                  = { },
        dev                 = { },
        ctm                 = { },
        settings            = { },
        themes =
        {
            list            = { },
            hash            = nil,
        },
    }

    for k, v in pairs( storage_def ) do
        source[ mod_id ][ k ] = source[ mod_id ][ k ] or v
    end

    /*
    *   storage :: cfgs
    */

    local storage_cfg =
    {
        initialize          = { },
        general             =
        {
            clrs            = { },
        },
        binds =
        {
            chat            = { },
            console         = { },
            key             = { },
        },
        sounds              = { },
        ui =
        {
            clrs            = { },
        },
        bg =
        {
            live            = { },
            static          = { },
            material        = { },
            filter          = { },
            bokeh           = { },
        },
        nav                 =
        {
            button          = { },
            general         = { },
            list            = { },
        },
        ent                 = { },
        dev                 = { },
    }

    for k, v in pairs( storage_cfg ) do
        source[ mod_id ][ 'settings' ][ k ] = source[ mod_id ][ 'settings' ][ k ] or v
    end

end
hook.Add( pid( 'modules.storage.defaults' ), pid( 'modules.storage.defaults' ), storage_struct_defs )

/*
*   register module
*
*   registers a module with the gamemode
*
*   @ex     : path => modules/tools, mod => sh_tools_manifest.lua
*
*   @param  : str path
*   @param  : str mod
*   @param  : bool b_isext
*/

function base:module_register( path, mod, b_isext )

    if not isstring( path ) or not mod then
        rlib:log( 2, lang( 'logs_rcore_mnfst_err' ) )
        sys.modules.err = sys.modules.err + 1
        return
    end

    local _ENV      = { }
    local manifest  = path .. '/' .. mod
    local tmp_id    = mod:gsub( '.lua', '' )

    if not tmp_id then
        rlib:log( 2, lang( 'logs_rcore_id_err' ) )
        sys.modules.err = sys.modules.err + 1
        return
    end

    _ENV.MODULE = self.modules[ tmp_id ]
    smt = setmetatable( _ENV, { __index = _G } )

    if not smt or ( type( smt ) ~= 'table' ) then
        rlib:log( 6, lang( 'logs_rcore_mt_err' ) )
        sys.modules.err = sys.modules.err + 1
        return
    else
        if sys.modules.registered <= 0 then
            rlib:log( 6, lang( 'logs_rcore_mt_ok' ) )
        end
    end

    local module_exec = CompileFile( manifest )
    sys.modules.total = sys.modules.total + 1

    if not module_exec or not rlib:isfunc( module_exec ) then
        sys.modules.err = sys.modules.err + 1
        rlib:log( 2, lang( 'logs_rcore_func_err', mod ) )
        return
    end

    if not smt.MODULE.enabled then
        rlib:log( 6, lang( 'logs_rcore_mod_disabled', smt.MODULE.id ) )
        sys.modules.disabled = sys.modules.disabled + 1
        return
    end

    debug.setfenv( module_exec, _ENV )
    module_exec( )

    local mod_id                        = smt.MODULE.id
    self.modules[ mod_id ]              = _ENV.MODULE
    self.modules[ mod_id ].id           = mod_id
    self.modules[ mod_id ].loadtime     = CurTime( )
    self.modules[ mod_id ].path         = path
    self.modules[ mod_id ].settings     = { }

    self.modules[ mod_id ]._cache       = { }
    self.modules[ mod_id ]._cache.mats  = { }

    rlib.l[ mod_id ]                    = smt.MODULE.language

    sys.modules.registered = sys.modules.registered + 1
    rlib:log( 6, lang( 'logs_rcore_mnfst_ok', mod ) )

    /*
    *   create storage tables :: shared
    */

    if smt.MODULE.storage and istable( smt.MODULE.storage ) then
        for k, v in pairs( smt.MODULE.storage ) do
            self.modules[ mod_id ][ k ] = v
            rlib:log( 6, lang( 'logs_rcore_storage_ok', smt.MODULE.id, tostring( k ) ) )
        end
        storage.garbage( 'module_loader_storage', { smt.MODULE.storage } )
    else
        smt.MODULE.storage = { }
    end

    /*
    *   create storage tables :: client
    */

    if CLIENT and smt.MODULE.storage_cl and istable( smt.MODULE.storage_cl ) then
        for k, v in pairs( smt.MODULE.storage_cl ) do
            self.modules[ mod_id ][ k ] = v
            rlib:log( 6, lang( 'logs_rcore_storage_ok', smt.MODULE.id, tostring( k ) ) )
        end
    end

    /*
    *   create storage tables :: server
    */

    if SERVER and smt.MODULE.storage_sv and istable( smt.MODULE.storage_sv ) then
        for k, v in pairs( smt.MODULE.storage_sv ) do
            self.modules[ mod_id ][ k ] = v
            rlib:log( 6, lang( 'logs_rcore_storage_ok', smt.MODULE.id, tostring( k ) ) )
        end
    end

    /*
    *   create default storage tables
    *   these tables will be automatically created for every module to help save
    *   on repetitiveness of declaring these in the module manifest file
    */

    hook.Run( pid( 'modules.storage.defaults' ), mod_id )

    /*
    *   module sys tbl
    */

    smt.MODULE.sys = smt.MODULE.sys or { }

    /*
    *   create log folders
    */

    if SERVER and smt.MODULE.logging then
        storage.dir.newstruct( rlib.manifest.name, 'modules', mod_id )
    end

    /*
    *   create datafolders
    */

    if SERVER and smt.MODULE.datafolder and istable( smt.MODULE.datafolder ) then
        for v in helper.get.data( smt.MODULE.datafolder ) do
            if not v.parent then continue end
            storage.dir.newstruct( v.parent )

            if not v.sub then continue end
            storage.dir.newstruct( v.parent, v.sub )
        end
    end

    /*
    *   register calls
    */

    if smt.MODULE.calls then
        rlib.calls:register( rcore, smt.MODULE.calls )
    end

    /*
    *   register resources
    */

    if smt.MODULE.resources then
        rlib.resources:register( rcore, mod_id, smt.MODULE.resources, smt.MODULE.precache or false )
    end

    /*
    *   sql tables
    */

    if SERVER and ( smt.MODULE.ext or smt.MODULE.dbconn ) then
        smt.MODULE.database         = { }
        smt.MODULE.database.cfg     = { }
    end

    /*
    *   load other files in module after good manifest found
    */

    self:autoloader_configs( path, mod_id )
    self:autoloader_modules( path, mod_id, b_isext )

    /*
    *   check demo mode
    */

    if smt.MODULE.demo or smt.MODULE.demomode then
        rlib:log( 3, lang( 'logs_rcore_demomode', smt.MODULE.id ) )
    end

    if rnet then
        hook.Run( pid( 'rnet_register', mod_id ) )
    end

    /*
    *   register materials ( v1 )
    *
    *   will be deprecated in a future update
    */

    if CLIENT and smt.MODULE.materials then
        rlib.m:register_v1( smt.MODULE.materials, mod_id )
    end

    /*
    *   register materials ( v2 )
    */

    if CLIENT and smt.MODULE.mats then
        rlib.m:register( smt.MODULE )
    end

end
hook.Add( pid( 'modules.register' ), pid( 'modules.register' ), function( path, mod, b_isext ) base:module_register( path, mod, b_isext ) end )