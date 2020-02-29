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
*   ulx :: user :: timed mute
*	
*	forces the player to select a new name before they can do anything else on the server. once they
*	submit a new first/last name, they must wait for an admin to accept the new name change before
*	the dialog box will close and they can continue playing.
*   
*   @param	: ply calling_ply
*   @param	: ply, tbl target_plys
*   @param	: int duration
*   @param	: str reason
*	@param	: bool should_unmute
*/

local ID_MUTE = 2

function ulx.rcore_user_mute_timed( calling_ply, target_plys, duration, reason, should_unmute )

    if not rlib then
        rlib.msg:route( calling_ply, false, perm( 'rcore_user_mute_timed' ).category, 'An error has occured with a required dependency. Contact the developer and we will summon the elves.' )
        return
    end

    duration = isnumber( duration ) and duration or 300
    duration = duration == 0 and 86400 or duration

    for i = 1, #target_plys do
        local v = target_plys[ i ]
        local t_id = string.format( 'ulx.player.mute.%s', v:SteamID64( ) )
        if should_unmute then
            v.gimp = nil
            timex.expire( t_id )
        else
            v.gimp = ID_MUTE
            if not timex.exists( t_id ) then
                timex.create( t_id, duration, 1, function( )
                    rlib.msg:route( v, false, 'Timed Mute', 'Expired. Additional mutes by an admin may last longer.' )
                    hook.Run( 'alogs.send', 'ulx mute', 'timed mute on player', rlib.settings.cmsg.clrs.target_tri, v:Name( ), rlib.settings.cmsg.clrs.msg, 'has expired' )
                end )
            end
        end
        v:SetNWBool( 'ulx_muted', not should_unmute )
    end

    if not should_unmute then
        if helper.str:valid( reason ) and reason ~= 'reason' then
            if duration == 0 or duration == 86400 then
                ulx.fancyLogAdmin( calling_ply, '#A muted #T permanently for reason [ #s ]', target_plys, reason )
            else
                ulx.fancyLogAdmin( calling_ply, '#A muted #T for #s seconds for reason [ #s ]', target_plys, duration, reason )
            end
        else
            if duration == 0 or duration == 86400 then
                ulx.fancyLogAdmin( calling_ply, '#A muted #T permanently', target_plys )
            else
                ulx.fancyLogAdmin( calling_ply, '#A muted #T for #s seconds', target_plys, duration )
            end
        end
    else
        ulx.fancyLogAdmin( calling_ply, '#A unmuted #T', target_plys )
    end

end
local rcore_user_mute_timed = ulx.command( perm( 'rcore_user_mute_timed' ).category, perm( 'rcore_user_mute_timed' ).id, ulx.rcore_user_mute_timed, perm( 'rcore_user_mute_timed' ).pubcmds )
rcore_user_mute_timed:addParam { type = ULib.cmds.PlayersArg }
rcore_user_mute_timed:addParam { type = ULib.cmds.NumArg, min = 0, max = 1800, default = 300, hint = 'Seconds to mute for / 0 = perm', ULib.cmds.optional, ULib.cmds.round }
rcore_user_mute_timed:addParam { type = ULib.cmds.StringArg, hint = 'reason', ULib.cmds.optional, ULib.cmds.takeRestOfLine }
rcore_user_mute_timed:addParam { type = ULib.cmds.BoolArg, invisible = true }
rcore_user_mute_timed:defaultAccess( access:ulx( 'rcore_user_mute_timed', mod ) )
rcore_user_mute_timed:help( perm( 'rcore_user_mute_timed' ).desc )

/*
*   ulx :: user :: timed gag
*	
*	forces the player to select a new name before they can do anything else on the server. once they
*	submit a new first/last name, they must wait for an admin to accept the new name change before
*	the dialog box will close and they can continue playing.
*   
*   @param	: ply calling_ply
*   @param	: ply, tbl target_plys
*   @param	: int duration
*   @param	: str reason
*	@param	: bool should_ungag
*/

function ulx.rcore_user_gag_timed( calling_ply, target_plys, duration, reason, should_ungag )

    if not rlib then
        rlib.msg:route( calling_ply, false, perm( 'rcore_user_gag_timed' ).category, 'An error has occured with a required dependency. Contact the developer and we will summon the elves.' )
        return
    end

    duration = isnumber( duration ) and duration or 300
    duration = duration == 0 and 86400 or duration

    local players = player.GetAll( )
    for i = 1, #target_plys do
        local v = target_plys[ i ]
        v.ulx_gagged = not should_ungag
        v:SetNWBool( 'ulx_gagged', v.ulx_gagged )

        local t_id = string.format( 'ulx.player.gag.%s', v:SteamID64( ) )
        if not should_ungag then
            if not timex.exists( t_id ) then
                timex.create( t_id, duration, 1, function( )
                    v.ulx_gagged = false
                    v:SetNWBool( 'ulx_gagged', v.ulx_gagged )
                    rlib.msg:route( v, false, 'Gag', 'Expired. Additional gags by an admin may last longer.' )
                    hook.Run( 'alogs.send', 'ulx gag', 'timed gag on player', rlib.settings.cmsg.clrs.target_tri, v:Name( ), rlib.settings.cmsg.clrs.msg, 'has expired' )
                end )
            end
        else
            timex.expire( t_id )
        end
    end

    if not should_ungag then
        if helper.str:valid( reason ) and reason ~= 'reason' then
            if duration == 0 or duration == 86400 then
                ulx.fancyLogAdmin( calling_ply, '#A gagged #T permanently for reason [ #s ]', target_plys, reason )
            else
                ulx.fancyLogAdmin( calling_ply, '#A gagged #T for #s seconds for reason [ #s ]', target_plys, duration, reason )
            end
        else
            if duration == 0 or duration == 86400 then
                ulx.fancyLogAdmin( calling_ply, '#A gagged #T permanently', target_plys )
            else
                ulx.fancyLogAdmin( calling_ply, '#A gagged #T for #s seconds', target_plys, duration )
            end
        end
    else
        ulx.fancyLogAdmin( calling_ply, '#A ungagged #T', target_plys )
    end

end
local rcore_user_gag_timed = ulx.command( perm( 'rcore_user_gag_timed' ).category, perm( 'rcore_user_gag_timed' ).id, ulx.rcore_user_gag_timed, perm( 'rcore_user_gag_timed' ).pubcmds )
rcore_user_gag_timed:addParam { type = ULib.cmds.PlayersArg }
rcore_user_gag_timed:addParam { type = ULib.cmds.NumArg, min = 0, max = 1800, default = 300, hint = 'Seconds to gag for / 0 = perm', ULib.cmds.optional, ULib.cmds.round }
rcore_user_gag_timed:addParam { type = ULib.cmds.StringArg, hint = 'reason', ULib.cmds.optional, ULib.cmds.takeRestOfLine }
rcore_user_gag_timed:addParam { type = ULib.cmds.BoolArg, invisible=true }
rcore_user_gag_timed:defaultAccess( access:ulx( 'rcore_user_gag_timed', mod ) )
rcore_user_gag_timed:help( perm( 'rcore_user_gag_timed' ).desc )