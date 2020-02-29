/*
*   @package        : rcore
*   @module         : base
*	@extends		: ulx
*   @author         : Richard [http://steamcommunity.com/profiles/76561198135875727]
*   @copyright      : (c) 2018 - 2020
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
*   standard tables and localization
*/

rcore                       = rcore or { }
local base                  = rcore
local helper                = rlib.h
local access                = rlib.a
local storage			    = rlib.s

/*
*   module calls
*/

local mod, prefix       	= rlib.modules:require( 'base', true )
local cfg               	= rlib.modules:cfg( mod )

/*
*   Localized cmd func
*
*   @source : lua\autorun\libs\_calls
*   @param  : str t
*   @param  : tbl { ... }
*/

local function call( t, ... )
    return rlib:call( t, ... )
end

/*
*   Localized res func
*/

local function resources( t, ... )
    return rlib:resource( mod, t, ... )
end

/*
*   Localized translation func
*/

local function lang( ... )
    return rlib:translate( mod, ... )
end

/*
*	prefix ids
*/

local function pref( str, suffix )
    local state = not suffix and mod or isstring( suffix ) and suffix or false
    return rlib.get:pref( str, state )
end

/*
*   get access perm
*
*   @param  : str id
*	@return	: tbl
*/

local function perm( id )
    return access:getperm( id, mod )
end

/*
*   ulx :: tools :: model viewer
*
*	displays a simple model viewer
*
*   @param	: ply calling_ply
*/

function ulx.rcore_tools_mdlviewer( calling_ply )

	if not rlib then
		rlib.msg:route( calling_ply, false, perm( 'rcore_tools_mdlviewer' ).category, 'An error has occured with a required dependency. Contact the developer and we will summon the elves.' )
		return
	end

    net.Start( 'rlib.tools.mdlviewer' )
    net.Send( calling_ply )

end
local rcore_tools_mdlviewer = ulx.command( perm( 'rcore_tools_mdlviewer' ).category, perm( 'rcore_tools_mdlviewer' ).id, ulx.rcore_tools_mdlviewer, perm( 'rcore_tools_mdlviewer' ).pubcmds )
rcore_tools_mdlviewer:defaultAccess( access:ulx( 'rcore_tools_mdlviewer', mod ) )
rcore_tools_mdlviewer:help( perm( 'rcore_tools_mdlviewer' ).desc )

/*
*   ulx :: tools :: pco (player-client-optimizations)
*	
*	toggles pco on/off for players
*   
*   @param	: ply calling_ply
*   @param	: ply target_ply
*   @param  : bool toggle_options
*/

ulx.toggle_options = { }
ulx.toggle_options[ 1 ] = 'disabled'
ulx.toggle_options[ 2 ] = 'enabled'

function ulx.rcore_tools_pco( calling_ply, target_ply, toggle_options )

    if not rlib then
        rlib.msg:route( calling_ply, false, perm( 'rcore_tools_mdlviewer' ).category, 'An error has occured with a required dependency. Contact the developer and we will summon the elves.' )
        return
    end

    if not helper:cvar_bool( 'rlib_pco' ) then
        rlib:log( 6, lang( 'pco_disabled_debug' ) )
        return
    end

    local toggle = toggle_options == 'enabled' and true or false
    tools.pco:Run( target_ply, toggle, calling_ply )

end
local rcore_tools_pco = ulx.command( perm( 'rcore_tools_pco' ).category, perm( 'rcore_tools_pco' ).id, ulx.rcore_tools_pco, perm( 'rcore_tools_pco' ).pubcmds )
rcore_tools_pco:addParam { type = ULib.cmds.PlayerArg }
rcore_tools_pco:addParam { type = ULib.cmds.StringArg, completes = ulx.toggle_options, hint='option', error = 'invalid option \"%s\" specified', ULib.cmds.restrictToCompletes }
rcore_tools_pco:defaultAccess( access:ulx( 'rcore_tools_pco', mod ) )
rcore_tools_pco:help( perm( 'rcore_tools_pco' ).desc )