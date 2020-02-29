/*
*   @package        rlib
*   @author         Richard [http://steamcommunity.com/profiles/76561198135875727]
*   @copyright      (C) 2018 - 2020
*   @since          3.0.0
*   @website        https://rlib.io
*   @docs           https://docs.rlib.io
*   @file           resources.lua
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
local utils             = base.u
local access            = base.a
local tools             = base.t
local konsole           = base.k
local sys               = base.sys
local resources         = base.resources

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
    local affix = istable( suffix ) and suffix.id or isstring( suffix ) and suffix or prefix
    affix = affix:sub( -1 ) ~= '.' and string.format( '%s.', affix ) or affix

    id = isstring( id ) and id or 'noname'
    id = id:gsub( '[%c%s]', '.' )

    return string.format( '%s%s', affix, id )
end

/*
*	prefix ids
*/

local function pid( str, suffix )
    local state = ( isstring( suffix ) and suffix ) or ( base and prefix ) or false
    return cid( str, state )
end

/*
*   resources :: register
*
*   grab resource categories from main lib table which typically include:
*       : sounds
*       : particles
*       : models
*
*   send regsitered res from source table 
*       rlib.resources[ type ] => _G.rresources[ type ]
*
*   if resource is a recognized type such as sounds, particles, models;
*   the additional step of precaching will be executed
*
*   @param  : tbl parent
*   @param  : tbl src
*/

function resources:register( parent, id, src, bPrecache )
    if not parent.manifest.resources or not istable( parent.manifest.resources ) then
        base:log( 2, 'missing resources definition table -- aborting' )
        return
    end

    if not src or not istable( src ) then
        base:log( 6, 'cannot load resources without valid table' )
        return
    end

    for _, v in pairs( parent.manifest.resources ) do

        /*
        *   v returns call_type
        */

        local call_type = v:lower( )
        if not src[ call_type ] then
            src[ call_type ] = { }
        end

        /*
        *   build resources lib
        *
        *   loop resources and setup structure
        *   : l        =   call_id
        *   : m[ 1 ]   =   call.id
        *   : m[ 2 ]   =   desc (optional)
        */

        for l, m in pairs( src[ call_type ] ) do
            _G.rresources[ call_type ]              = _G.rresources[ call_type ] or { }
            _G.rresources[ call_type ][ id ]        = _G.rresources[ call_type ][ id ] or { }
            _G.rresources[ call_type ][ id ][ l ]   = { tostring( m[ 1 ] ), m[ 2 ] and tostring( m[ 2 ] ) or lang( 'res_no_desc' ) }

            if bPrecache then
                if call_type == 'snd' then
                    if isstring( m[ 1 ] ) then
                        base.register:sound( m[ 1 ] )
                    end
                elseif call_type == 'ptc' then
                    if isstring( m[ 1 ] ) then
                        rlib.register:particle( m[ 1 ] )
                    end
                elseif call_type == 'mdl' then
                    if isstring( m[ 1 ] ) then
                        rlib.register:model( m[ 1 ] )
                    end
                end
            end

            sys.resources = ( sys.resources or 0 ) + 1
        end

    end
end

/*
*   resources :: validation
*
*   checks a provided call id to see if it is registered within _G.rcalls
*
*   @param  : str t
*   @return : tbl
*/

function resources:valid( mod, t )
    if not t or not isstring( t ) or t == '' then
        rlib:log( 2, 'missing specified call type' )
        local resp, cnt_calls, i = '', #_G.rresources, 0
        for k, v in pairs( _G.rresources ) do
            resp = resp .. k
            i = i + 1
            if i < cnt_calls then
                resp = resp .. ', '
            end
        end
        rlib:log( 2, 'valid types are [ %s ]', resp )
        return
    end

    local data = _G.rresources[ t ]
    if not data then
        rlib:log( 2, 'missing resource type » [ %s ]', t )
        return
    end

    return data or false
end

/*
*   resources :: get
*
*   returns the associated call data table
*
*   call using localized function in file that you require fetching needed resources.
*
*   @ex     : rlib.resources:get( 'calltype', 'id' )
*             rlib.resources:get( 'mdl', 'modname_mdl_combine' )
*
*   @param  : str t
*   @param  : str s
*   @return : tbl
*/

function resources:get( t, s )
    local data = self:valid( t )
    if not data then return end

    if s and data[ s ] then
        return data[ s ]
    else
        return data
    end

    return
end