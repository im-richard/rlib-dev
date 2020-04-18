/*
*   @package        : rlib
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
local ui                = base.i
local cvar              = base.v

/*
*   Localized lua funcs
*
*   i absolutely hate having to do this, but for squeezing out every
*   bit of performance, we need to.
*/

local Color             = Color
local pairs             = pairs
local ipairs            = ipairs
local GetConVar         = GetConVar
local tonumber          = tonumber
local tostring          = tostring
local istable           = istable
local isfunction        = isfunction
local isentity          = isentity
local isnumber          = isnumber
local isstring          = isstring
local type              = type
local Color             = Color
local table             = table
local string            = string
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
*   simplifiy funcs
*/

local function log( ... ) base:log( ... ) end

/*
*   cvar :: prepare
*
*   called client-side when cvars need to be registerd with a player
*/

function cvar:Prepare( )
    if not istable( ui.cvars ) then return end

    local _toregister = { }
    for k, v in helper:sortedkeys( ui.cvars ) do
        _toregister[ #_toregister + 1 ] = v
    end

    table.sort( _toregister, function( a, b ) return a.sid < b.sid end )

    for k, v in pairs( _toregister ) do
        if base._def.elements_ignore[ v.stype ] then continue end
        cvar:Setup( v.stype, v.id, v.default, v.values, v.forceset, v.desc )
    end
end

/*
*   cvar :: setup
*
*   assigns a clientconvar based on the parameters specified. these convars will then be used later in 
*   order for the player.
*
*   forceset will ensure that if the server owner ever updates the core theme manifest that it will 
*   auto-push the updated changes to the client on next connection
*
*   @param  : str flag
*   @param  : str id
*   @param  : str def
*   @param  : tbl vals
*   @param  : bool forceset
*   @param  : str help
*   @return : void
*/

function cvar:Setup( flag, id, def, vals, forceset, help )
    if not helper.str:valid( flag ) or not helper.str:valid( id ) then
        log( 2, lang( 'properties_setup' ) )
        return false
    end

    forceset    = forceset or false
    help        = isstring( help ) and help or 'no description'

    if flag ~= 'rgba' and flag ~= 'object' and flag ~= 'dropdown' then
        CreateClientConVar( id, def, true, false, help )
        if forceset then
            local cvar = GetConVar( id )
            cvar:SetString( def )
        end
    elseif flag == 'dropdown' then
        CreateClientConVar( id, def or '', true, false, help )
        if forceset then
            local cvar = GetConVar( id )
            cvar:SetString( def )
        end
    elseif flag == 'object' or flag == 'rgba' then
        if not istable( vals ) then return end
        for dn, dv in pairs( vals ) do
            local assign_id = id .. '_' .. dn
            CreateClientConVar( assign_id, dv, true, false, help )
            if forceset then
                local cvar = GetConVar( assign_id )
                cvar:SetString( dv )
            end
        end
    end
end

/*
*   cvar :: client create
*
*   create a client convar
*
*   @param  : str name
*   @param  : str default
*   @param  : bool save
*   @param  : bool udata
*   @param  : str help
*/

function cvar:CreateClient( name, default, save, udata, help )
    if not helper.str:valid( name ) then
        log( 2, lang( 'cvar_missing_name' ) )
        return false
    end

    if not ConVarExists( name ) then
        if not default then
            log( 2, lang( 'cvar_missing_def', name ) )
            return false
        end

        save        = save or true
        udata       = udata or false
        help        = help or 'auto-created by rlib'

        CreateClientConVar( name, default, save, udata, help )
        log( 6, lang( 'cvar_added', name ) )
    end
end