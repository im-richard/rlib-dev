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
local script            = mf.name
local version           = mf.version
local cfg               = base.settings

/*
*   localized rlib routes
*/

local helper            = base.h
local access            = base.a
local konsole           = base.k
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
local IsValid           = IsValid
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
*   convar :: validate
*
*   checks if the provided item is a convar
*
*   @param  : mix obj
*   @return : bool
*/

function cvar:valid( obj )
    return ( type( obj ) == 'ConVar' ) or false
end

/*
*   convar :: register
*
*   @param  : str name
*   @param  : str value
*   @param  : enum, tbl flags
*   @param  : str help
*/

function cvar:Register( name, value, flags, help )
    if not helper.str:valid( name ) or not helper.str:valid( name ) then
        log( 2, 'cannot register cvar with missing parameters' )
        return
    end

    if not ConVarExists( name ) then
        if not value then
            log( 2, 'cvar default missing » [ %s ]', name )
            return
        end

        if not flags then
            log( 2, 'cvar flags missing » [ %s ]', name )
            return
        end

        help = help or ''

        CreateConVar( name, value, flags, help )

        log( 6, lang( 'cvar_added', name ) )
    end
end

/* 
*   convar :: get :: clr
*
*   fetches the proper clrs associated with a particular convar.
*
*   @param  : str id
*   @param  : tbl alt
*   @return : clr tbl
*/

function cvar:Clr( id, alt )
    local channels = { id .. '_red', id .. '_green', id .. '_blue', id .. '_alpha' }

    local i = 0
    for _, v in pairs( channels ) do
        if not ConVarExists( v ) then continue end
        i = i + 1
    end

    if i < 3 then
        return alt or Color( 255, 255, 255, 255 )
    elseif i == 3 then
        return Color( GetConVar( id .. '_red' ):GetInt( ), GetConVar( id .. '_green' ):GetInt( ), GetConVar( id .. '_blue' ):GetInt( ) )
    elseif i > 3 then
        return Color( GetConVar( id .. '_red' ):GetInt( ), GetConVar( id .. '_green' ):GetInt( ), GetConVar( id .. '_blue' ):GetInt( ), GetConVar( id .. '_alpha' ):GetInt( ) )
    end
end

/* 
*   convar :: get
*
*   valides and returns a specified convar
*
*   @param  : str id
*   @return : cvar
*/

function cvar:Get( id )
    return ( isstring( id ) and ConVarExists( id ) and GetConVar( id ) ) or ( self:valid( id ) and id ) or false
end

/* 
*   convar :: get :: name
*
*   valides and returns a specified convar
*   param accepts either a str; or the convar itself
*
*   @param  : str id
*   @return : cvar
*/

function cvar:Name( id )
    local cv = ( isstring( id ) and ConVarExists( id ) and GetConVar( id ) ) or ( self:valid( id ) and id ) or false
    return cv:GetName( )
end

/* 
*   convar :: get :: helptext
*
*   returns the helptext for a registered convar
*
*   @param  : str id
*   @return : str
*/

function cvar:Help( id )
    local cv = self:Get( id )
    if not cv then return end
    return cv:GetHelpText( ) or lang( 'cvar_nohelp' )
end

/* 
*   convar :: set :: int
*
*   @param  : str id
*   @param  : int val
*/

function cvar:SetInt( id, val )
    local cv = self:Get( id )
    if not cv then return end
    cv:SetInt( val )
end

/* 
*   convar :: set :: str
*
*   @param  : str id
*   @param  : str val
*/

function cvar:SetStr( id, val )
    if not id then return end

    if ( isstring( id ) and self:Get( id ) ) then
        local cv = GetConVar( id )
        cv:SetString( val )
    elseif ( self:valid( id ) ) then
        id:SetString( val )
    end
end

/* 
*   convar :: set :: bool
*
*   @param  : str id
*   @param  : bool val
*/

function cvar:SetBool( id, val )
    if not id then return end
    val = val or false

    if ( isstring( id ) and self:Get( id ) ) then
        local cv = GetConVar( id )
        cv:SetBool( val )
    elseif ( self:valid( id ) ) then
        id:SetBool( val )
    end
end

/* 
*   convar :: set :: float
*
*   @param  : str id
*   @param  : flt val
*/

function cvar:SetFloat( id, val )
    if not id then return end
    val = val or 0

    if ( isstring( id ) and self:Get( id ) ) then
        local cv = GetConVar( id )
        cv:SetFloat( val )
    elseif ( self:valid( id ) ) then
        id:SetFloat( val )
    end
end

/* 
*   convar :: get :: default
*
*   returns a cvar default value
*
*   @param  : str id
*   @return : mix
*/

function cvar:GetDef( id )
    return ConVarExists( id ) and GetConVar( id ):GetDefault( )
end

/* 
*   convar :: get :: int
*
*   fetches the proper int associated with a particular convar.
*   param accepts either a str; or the convar itself
*
*   @param  : str id
*   @param  : int alt
*   @return : int
*/

function cvar:GetInt( id, alt )
    return ( isstring( id ) and ConVarExists( id ) and GetConVar( id ):GetInt( ) ) or ( self:valid( id ) and id:GetInt( ) ) or self:GetDef( id ) or alt
end

/* 
*   convar :: get :: str
*
*   fetches the proper str associated with a particular convar.
*   param accepts either a str; or the convar itself
*
*   @param  : str id
*   @param  : str alt
*   @return : str
*/

function cvar:GetStr( id, alt )
    return ( isstring( id ) and ConVarExists( id ) and GetConVar( id ):GetString( ) ) or ( self:valid( id ) and id:GetString( ) ) or self:GetDef( id ) or alt
end

/* 
*   convar :: get :: str :: strict method
*
*   fetches the proper str associated with a particular convar.
*
*   @param  : str id
*   @param  : str alt
*   @return : str
*/

function cvar:GetStrStrict( id, alt )
    return ConVarExists( id ) and GetConVar( id ):GetString( ) or self:GetDef( id ) or alt
end

/* 
*   convar :: get :: float
*
*   fetches the proper float associated with a particular convar.
*   param accepts either a str; or the convar itself
*
*   @param  : str, cvar id
*   @param  : flt alt
*   @return : flt
*/

function cvar:GetFloat( id, alt )
    return ( isstring( id ) and ConVarExists( id ) and GetConVar( id ):GetFloat( ) ) or ( self:valid( id ) and id:GetFloat( ) ) or self:GetDef( id ) or alt or 0
end

/* 
*   convar :: get :: bool
*
*   fetches the proper bool associated with a particular convar.
*   param accepts either a str; or the convar itself
*
*   @param  : str, cvar id
*   @return : bool
*/

function cvar:GetBool( id )
    return ( isstring( id ) and ConVarExists( id ) and GetConVar( id ):GetBool( ) ) or ( self:valid( id ) and id:GetBool( ) ) or false
end

/* 
*   convar :: int to bool
*
*   converts an int stored cvar to a bool
*   param accepts either a str; or the convar itself
*
*   @param  : str, cvar id
*   @return : bool
*/

function cvar:Int2Bool( id )
    return ( isstring( id ) and ConVarExists( id ) and self:int2bool( GetConVar( id ):GetInt( ) ) ) or ( self:valid( id ) and helper:int2bool( id:GetInt( ) ) ) or false
end