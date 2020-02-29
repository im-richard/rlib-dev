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
*   get access perm
*
*   @param  : str id
*	@return	: tbl
*/

local function perm_name( id )
    return access:getperm_id( id, mod )
end

/*
*   ulx :: rp :: set job
*
*	forces a player to a specified rp job based on the job command defined
*
*   this is an alternative to darkrp_setjob since that command relies on the name which can
*   cause complications of multiple jobs contain similar names. whereas this method ensures the
*   correct job is found
*
*   @param	: ply calling_ply
*   @param  : ply target_ply
*   @param  : str job
*/

function ulx.rcore_rp_setjob( calling_ply, target_ply, job )
    if not rlib or not rlib:bHasDependency( mod ) then
        rlib.msg:route( calling_ply, false, perm_name( 'rcore_rp_setjob' ), 'An error has occured with a required dependency. Contact the developer and we will summon the elves.' )
        return
    end

    if not RPExtraTeams then
        rlib.msg:route( calling_ply, false, perm_name( 'rcore_rp_setjob' ), 'RP jobs table missing -- are you running darkrp?' )
        return
    end

    local job_c, job_res = helper.who:rpjob_custom( job )
    if not job_c or job_c == 0 then
        rlib.msg:route( calling_ply, false, perm_name( 'rcore_rp_setjob' ), 'Specified job with command does not exist' )
        return
    end

    local job_new = job_res[ 0 ]

    local newnum, newjob = nil, nil
    for i,v in pairs( RPExtraTeams ) do
        if v.command:lower( ) == job_new.command:lower( ) then
            newnum = i
            newjob = v
        end
    end

    PrintTable( newjob )

    target_ply:updateJob( newjob.name )
    target_ply:setSelfDarkRPVar( 'salary', newjob.salary )
    target_ply:SetTeam( newnum )

    GAMEMODE:PlayerSetModel( target_ply )
    GAMEMODE:PlayerLoadout( target_ply )

    rlib.msg:route( calling_ply, false, perm_name( 'rcore_rp_setjob' ), 'Forced player', rlib.settings.smsg.clrs.t3, target_ply:Name( ), rlib.settings.smsg.clrs.msg, 'to job', rlib.settings.smsg.clrs.t3, newjob.name )
    rlib.msg:route( target_ply, false, perm_name( 'rcore_rp_setjob' ), 'You have been forced to job', rlib.settings.smsg.clrs.t3, newjob.name )

end
local rcore_rp_setjob                       = ulx.command( perm( 'rcore_rp_setjob' ).category, perm( 'rcore_rp_setjob' ).id, ulx.rcore_rp_setjob, perm( 'rcore_rp_setjob' ).pubcmds )
rcore_rp_setjob:addParam                    { type = ULib.cmds.PlayerArg }
rcore_rp_setjob:addParam                    { type = ULib.cmds.StringArg, hint = 'job cmd', ULib.cmds.takeRestOfLine }
rcore_rp_setjob:defaultAccess               ( access:ulx( 'rcore_rp_setjob', mod ) )
rcore_rp_setjob:help                        ( perm( 'rcore_rp_setjob' ).desc )