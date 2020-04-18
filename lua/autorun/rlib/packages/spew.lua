/*
*   @package        : rlib
*   @module         : spew
*   @author         : Richard [http://steamcommunity.com/profiles/76561198135875727]
*   @copyright      : (C) 2018 - 2020
*   @since          : 1.0.0
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
*   @package    :   gmsv_spew
*   @author     :   ManWithHat
*   @source     :   https://github.com/ManWithHat/gmsv_spew
*   @notes      :   only support added for spew module, module itself
*                   : must be downloaded from the author's github
*/

/*
*   standard tables and localization
*/

rlib                    = rlib or { }
local base              = rlib
local env               = _G
local mf                = base.manifest
local pf                = mf.prefix

/*
*   lib includes
*/

local access            = base.a
local helper            = base.h

/*
*   localize
*/

local sf 	            = string.format

/*
*   tables
*/

base.spew               = base.spew or { }
local spew              = base.spew
local pkg               = spew
local pkg_name          = 'spew'

/*
*   simplifiy funcs
*/

local function con( ... ) base:console( ... ) end
local function log( ... ) base:log( ... ) end

/*
*	prefix :: create id
*/

local function pref( id, suffix )
    local affix     = istable( suffix ) and suffix.id or isstring( suffix ) and suffix or pf
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
*   pkg declarations
*/

local manifest =
{
    author      = 'richard',
    desc        = 'console spew',
    build       = 040420,
    version     = { 2, 1, 0 },
}

/*
*   spew :: enabler
*
*   determines if the spew module will load at all. If you experience issues with the module
*   or if you cannot install a .DLL to your server; then turn this off.
*
*   this is used moreso for the developer, really not needed by servers in production
*
*   @type   : boolean
*/

spew.enabled = false

/*
*   spew :: toggle hook destroy
*
*   if enabled, will destroy the spew hook when the first players connect to the server after
*   the server starts up. will stop cleaning console at this point until restarted or enabled
*   using the concommand.
*
*   @type   : boolean
*/

spew.destroyinit = true

/*
*   spew :: check loaded
*
*   decides if spew has been loaded onto the server yet or not. you should not change this
*   value manually and should always start out false.
*
*   @type   : boolean
*/

spew.loaded = false

/*
*   spew :: initialized :: destroy hook
*
*   destroys the spew hook after its not need anymore.
*   we just needed it when the server first started.
*/

function spew.initialize( )
    timex.simple( 'rlib_spew_run', 3, function( )
        if not spew.destroyinit then return end
        hook.Remove( 'ShouldSpew', pid( 'spew.enabled' ) )
        if spew.enabled then
            log( 6, 'Spew hook destroyed' )
        end
    end )
end
hook.Add( 'Initialize', pid( '__spew.initialize' ), function( ) spew.initialize( ) end )

/*
*   spew :: enable
*
*   allows for the spew module to be enabled which cleans up unwanted console prints.
*/

function spew.enable( )

    if CLIENT then return end

    local is_loaded = false

    if not spew.enabled then
        log( 6, 'Spew module disabled via config setting' )
        return
    end

    if spew.enabled and not is_loaded then
        spew.loaded = pcall( env.require, 'spew' )
    end

    if spew.enabled and spew.loaded and not is_loaded then
        is_loaded = true
    end

    if is_loaded then
        local filter_text =
        {
            [ 'unknown' ]           = true,
            [ 'invalid command' ]   = true,
        }
        hook.Add( 'ShouldSpew', pid( 'spew.enabled' ), function( msg, mtype, clr, lvl, grp )
            local is_found = false
            for k, v in pairs( filter_text ) do
                if not string.match( string.lower( msg ), k ) then continue end
                is_found = true
            end
            if mtype == 0 and not is_found then return true end
            return false
        end )
    else
        log( 2, 'Module spew not loaded -- possibly missing library dll' )
        return
    end

    log( 4, 'Spew module enabled' )
end

/*
*   concommand :: base command
*
*   base package command
*/

function rcc.call:Spew( ply, cmd, args )

    /*
    *   permissions
    */

    local ccmd = base.calls:get( 'commands', 'spew' )

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
*   concommand :: toggle package on/off
*/

function rcc.call:Spew_Enabled( ply, cmd, args )

    /*
    *   permissions
    */

    local ccmd = base.calls:get( 'commands', 'spew_enabled' )

    if ( ccmd.scope == 1 and not base.con:Is( ply ) ) then
        access:deny_consoleonly( ply, script, ccmd.id )
        return
    end

    if not access:bIsRoot( ply ) then
        access:deny_permission( ply, script, ccmd.id )
        return
    end

    local status = args and args[ 1 ] or false

    if status then

        if CLIENT then
            log( 2, 'Spew module cannot be toggled client-side' )
            return
        end

        local is_loaded = false

        local param_status = helper.util:toggle( status )
        if param_status then

            /*
            *   spew :: enable
            */

            spew.enabled = true

            if spew.enabled and not is_loaded then
                spew.loaded = pcall( env.require, 'spew' )
            end

            if spew.enabled and spew.loaded and not is_loaded then
                is_loaded = true
            end

            if is_loaded then
                local filter_text =
                {
                    [ 'unknown' ]           = true,
                    [ 'invalid command' ]   = true,
                }
                hook.Add( 'ShouldSpew', pid( 'spew.enabled' ), function( msg, mtype, clr, lvl, grp )
                    local is_found = false
                    for k, v in pairs( filter_text ) do
                        if not string.match( string.lower( msg ), k ) then continue end
                        is_found = true
                    end
                    if mtype == 0 and not is_found then return true end
                    return false
                end )
            else
                log( 2, 'Module spew not loaded -- possibly missing library dll' )
                return
            end

            log( 4, 'Spew module enabled' )

        else

            /*
            *   spew :: disable
            */

            spew.enabled = false
            hook.Remove( 'ShouldSpew', pid( 'spew.enabled' ) )

            log( 4, '[%s] :: is now disabled', pkg_name )

        end

    else
        log( 1, '[%s] :: arg:[ on, off ]', pkg_name )
        log( 1, '[%s] :: syntax: [ %s ]', pkg_name, 'spew.enabled on' )
    end

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
                rcc.call:Spew( ... )
            end,
        },
        [ pkg_name .. '_enabled' ] =
        {
            enabled     = true,
            warn        = true,
            id          = pkg_name .. '.enabled',
            name        = 'List',
            desc        = 'toggles spew on/off',
            scope       = 1,
            clr         = Color( 255, 255, 0 ),
            assoc = function( ... )
                rcc.call:Spew_Enabled( ... )
            end,
        },
    }

    base.calls.commands:Register( pkg_commands )
end
hook.Add( pid( 'cmd.register' ), pid( '__spew.cmd.register' ), register_commands )

/*
*   register package
*/

local function register_pkg( )
    if not istable( _M ) then return end
    base.package:Register( _M )
end
hook.Add( pid( 'pkg.register' ), pid( '__spew.pkg.register' ), register_pkg )

/*
*   module info :: manifest
*/

function pkg:manifest( )
    return self.__manifest
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

/*
*   spew :: execute
*/

spew.enable( )