/*
*   @package        : rlib
*   @author         : Richard [http://steamcommunity.com/profiles/76561198135875727]
*   @copyright      : (C) 2020 - 2020
*   @since          : 3.0.0
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
*   DEVELOPER NOTE
*   ---------------------------------------------------------------------------------------------
*   rlib currently contains rmats v1 and v2
*
*   v1 will be deprecated in a future release and is slowly being phased out
*   for a more optimized system which caches the materials directly within
*   the module they are associated with.
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
local materials         = base.m

/*
*   Localized glua
*/

local pairs             = pairs
local type              = type
local tostring          = tostring
local istable           = istable
local Material          = Material
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
*	prefix :: create id
*/

local function cid( id, suffix )
    local affix     = istable( suffix ) and suffix.id or isstring( suffix ) and suffix or prefix
    affix           = affix:sub( -1 ) ~= '.' and sf( '%s.', affix ) or affix

    id              = isstring( id ) and id or 'noname'
    id              = id:gsub( '[%c%s]', '.' )

    return sf( '%s%s', affix, id )
end

/*
*   materials :: valid
*
*   determines if the provided resource is a material
*
*   @param  : str mat
*   @return : bool
*/

function materials:valid( mat )
    return type( mat ) == 'IMaterial' and not mat:IsError( ) and tostring( mat ) ~= 'Material [debug/debugempty]' and mat or false
end

/*
*   materials :: get source materials table
*
*   returns specified module table
*
*   @since  : v3.0.0
*
*   @param  : str, tbl mod
*   @return : tbl
*/

function materials:get_manifest( mod )
    if not mod then
        log( 2, 'specified module not available\n%s', debug.traceback( ) )
        return false
    end

    if istable( rcore ) and ( isstring( mod ) and rcore.modules[ mod ] and rcore.modules[ mod ].enabled ) then
        return rcore.modules[ mod ].mats
    elseif istable( mod ) then
        return mod.mats
    end

    mod = isstring( mod ) and mod or 'unknown'
    log( 6, 'cannot fetch materials manifest table for invalid module [ %s ]\n%s', mod, debug.traceback( ) )

    return false
end

/*
*   materials :: register
*
*   takes a list of materials provided in a table and loads them into a system which can be used later 
*   to call a material client-side, without the need to define the material.
*
*   source material folder takes 3 paramters:
*
*       [ 1 ] unique name, [ 2 ] path to image, [ 3 ] parameters
*
*   if [ 3 ] is not specified, it will automatically apply 'noclamp smooth' to each material. 
*   only use [ 3 ] if you wish to not use both noclamp and smooth as your material parameters.
*
*   @src    :   materials = 
*               { 
*                   { 'uniquename', 'materials/folder/image.png', 'noclamp smooth' } 
*               }
*
*   @call   : rlib.m.register( materials )
*           : rlib.m.register( materials, 'base' )
*           : rlib.m.register( materials, 'base', 'mat' )
*
*   @result : m_rlib_uniquename
*           : mbase_uniquename
*           : matbase_uniquename
*
*   @syntax : once your materials have been loaded, you can call for one such as the result examples above.
*           : <append>_<suffix>_<src>
*           : <m>_<rlib>_<uniquename
*           : m_rlib_uniquename
*
*   @since  : v1.0.0
*
*   @param  : tbl src
*   @param  : str suffix
*   @param  : str append
*   @return : void
*/

function materials:register_v1( src, suffix, append )
    if not src then return end
    if not suffix then suffix = base.id end
    if not append then append = 'm' end

    suffix  = suffix:lower( )
    append  = append:lower( )
    base.m  = base.m or { }

    for _, m in pairs( src ) do
        if m[ 3 ] then
            base.m[ append .. '_' .. suffix .. '_' .. m[ 1 ] ] =
            {
                material    = Material( m[ 2 ], m[ 3 ] ),
                path        = m[ 2 ],
            }
            log( 6, '[L] [' .. append .. '_' .. suffix .. '_' .. m[ 1 ] .. ']' )
        else
            base.m[ append .. '_' .. suffix .. '_' .. m[ 1 ] ] =
            {
                material    = Material( m[ 2 ], 'noclamp smooth' ),
                path        = m[ 2 ]
            }
            log( 6, '[L] [' .. append .. '_' .. suffix .. '_' .. m[ 1 ] .. ']' )
        end
    end
end

/*
*   materials :: register
*
*   @since  : v3.0.0
*
*   @param  : tbl, str src
*   @return : void
*/

function materials:register( mod )
    if not mod then
        log( 2, 'specified module not available\n%s', debug.traceback( ) )
        return
    end

    local mnfst_mats    = self:get_manifest( mod )
    mod._cache          = mod._cache or { }
    mod._cache.mats     = { }

    for id, m in pairs( mnfst_mats ) do
        if not m[ 1 ] then continue end

        local mpath     = m[ 1 ]
        local flag      = isstring( m[ 2 ] ) and m[ 2 ] or 'noclamp smooth'
        mod._cache.mats[ id ] =
        {
            material    = Material( mpath, flag ),
            path        = mpath
        }

        log( 6, '[L] [' .. mpath .. ']' )
    end
end

/*
*   materials :: get cache
*
*   returns registered materials for a specified module
*
*   @since  : v3.0.0
*
*   @param  : str, tbl mod
*   @param  : tbl
*   @return : tbl
*/

function materials:getcache( mod, src )
    if not mod then
        log( 2, 'specified module not available\n%s', debug.traceback( ) )
        return
    end

    local bSuccess = false
    if istable( rcore ) and ( isstring( mod ) and rcore.modules[ mod ] and rcore.modules[ mod ].enabled ) then
        bSuccess = true
    elseif istable( mod ) then
        bSuccess = true
    end

    if not bSuccess then
        log( 2, 'unspecified module called for material loader\n%s', debug.traceback( ) )
        return
    end

    src = ( istable( src ) or isstring( src ) and mod[ src ] ) or mod._cache.mats

    if not istable( src ) then
        log( 2, 'no cached materials registered with mod\n%s', debug.traceback( ) )
        return
    end

    return src
end

/*
*   materials :: call
*
*   returns a registered material assigned via the id
*   id is stored in the module manifest file
*
*   @ex     : materials:call( mod, id )
*           : materials:call( mod, 'pnl_test' )
*
*   @since  : v3.0.0
*
*   @param  : tbl, str mod
*   @param  : str id
*   @param  : str ref
*/

function materials:call( mod, id, ref )
    if not mod then
        log( 2, 'cannot call material; invalid module specified\n%s', debug.traceback( ) )
        return
    end

    if not id then
        log( 2, 'cannot call material; invalid id specified\n%s', debug.traceback( ) )
        return
    end

    ref = isstring( ref ) and ref or 'material'

    return mod._cache.mats[ id ] and mod._cache.mats[ id ][ ref ] or '__error'
end