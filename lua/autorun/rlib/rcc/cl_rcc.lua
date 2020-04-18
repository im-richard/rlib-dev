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
local pf                = mf.prefix
local script            = mf.name
local cfg               = base.settings

/*
*   localized rlib routes
*/

local helper            = base.h
local storage           = base.s
local access            = base.a

/*
*   Localized lua funcs
*
*   i absolutely hate having to do this, but for squeezing out every
*   bit of performance, we need to.
*/

local Color             = Color
local pairs             = pairs
local tonumber          = tonumber
local tostring          = tostring
local istable           = istable
local isfunction        = isfunction
local isnumber          = isnumber
local isstring          = isstring
local string            = string
local sf                = string.format

/*
*   simplifiy funcs
*/

local function con      ( ... ) base:console( ... ) end

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
*   rcc :: materials :: list
*
*   lists materials that can be shared through-out scripts
*/

local function rcc_materials_list( pl, cmd, args )

    /*
    *   define command
    */

    local ccmd = base.calls:get( 'commands', 'rlib_mats' )

    /*
    *   scope
    */

    if ( ccmd.scope == 1 and not base.con:Is( pl ) ) then
        access:deny_consoleonly( pl, script, ccmd.id )
        return
    end

    /*
    *   perms
    */

    if not access:bIsRoot( pl ) then
        access:deny_permission( pl, script, ccmd.id )
        return
    end

    /*
    *   args
    */

    local arg_flag          = args and args[ 1 ] or false
    local arg_srch          = args and args[ 2 ] or nil

    /*
    *   declarations
    */

    local bCatListed        = false
    local cat_id            = ''
    local i_entries         = 0

    /*
    *   header
    */

    con( pl, 0 )
    con( pl, Color( 255, 0, 0 ), 'Registered Panels' )
    con( pl, 0 )

    /*
    *   header :: args
    */

    if arg_flag and arg_flag == '-s' and arg_srch then
        con( pl, Color( 255, 0, 0 ), ' ', Color( 255, 0, 0 ), lang( 'search_term', arg_srch ) )
    end

    /*
    *   loop modules
    */

    for a, b in pairs( rcore.modules ) do

        local i_fields = 0

        bCatListed = a ~= cat_id and false or bCatListed

        local mnfst = rlib.m:get_manifest( b )
        if not mnfst then continue end

        local i = 0
        for c in helper.get.data( mnfst ) do
            i = i + 1
        end

        for k, v in pairs( mnfst ) do
            if not bCatListed then
                local cat       = sf( ' %s', a )

                con( pl, 0 )

                local c1_l      = sf( '%-15s',      cat:upper( ) )
                local c2_l      = sf( '%-35s',      lang( 'col_id' ) )
                local c3_l      = sf( '%-35s',      lang( 'col_ref_id' ) )
                local resp      = sf( '%s %s %s',   c1_l, c2_l, c3_l )

                con( pl, Color( 255, 255, 255 ), resp )
                con( pl, 0 )

                bCatListed, cat_id = true, a
            end

            for l, m in pairs( v ) do
                if arg_srch and not string.match( k, arg_srch ) then continue end
                i_fields        = i_fields + 1

                local c1_d      = sf( '%-15s',      tostring( '' ) )
                local c2_d      = sf( '%-35s',      tostring( k ) )
                local c3_d      = sf( '%-35s',      tostring( m ) )
                local resp      = sf( '%s %s %s ',  c1_d, c2_d, c3_d )

                if i_fields == i then
                    resp        = resp .. '\n'
                    i_fields    = 0
                else
                    i_entries   = i_entries + 1
                end

                con( pl, Color( 255, 255, 0 ), resp )
            end

        end

        bCatListed = false
    end
end
rcc.register( 'rlib_mats', rcc_materials_list )

/*
*   rcc :: panels :: registered
*
*   returns a list of registered panels
*
*   @usage  : rlib.panels <returns all panels>
*   @usage  : rlib.panels -s termhere <returns entries matching term>
*/

local function rcc_panels_registered( pl, cmd, args )

    /*
    *   define command
    */

    local ccmd = base.calls:get( 'commands', 'rlib_panels' )

    /*
    *   scope
    */

    if ( ccmd.scope == 1 and not base.con:Is( pl ) ) then
        access:deny_consoleonly( pl, script, ccmd.id )
        return
    end

    /*
    *   perms
    */

    if not access:bIsRoot( pl ) then
        access:deny_permission( pl, script, ccmd.id )
        return
    end

    /*
    *   functionality
    */

    local arg_flag          = args and args[ 1 ] or false
    local arg_srch          = args and args[ 2 ] or nil
    local i_entries         = 0
    local output            = '\n\n [' .. rlib.manifest.name .. '] :: registered panels'

    con( pl, output )

    /*
    *   loop registered panels table
    */

    local bCatListed        = false
    local cat_id            = ''
    local tb_pnls           = base.p

    if arg_flag and arg_flag == '-s' and arg_srch then
        con( pl, Color( 255, 0, 0 ), ' ', Color( 255, 0, 0 ), lang( 'search_term', arg_srch ) )
    end

    for a, b in pairs( tb_pnls ) do

        bCatListed = a ~= cat_id and false or bCatListed

        for k, v in pairs( b ) do

            if not bCatListed then
                local cat       = sf( ' %s', a )

                con( pl, 0 )

                local c1_l      = sf( '%-15s', cat )
                local c2_l      = sf( '%-35s', lang( 'col_id' ) )
                local c3_l      = sf( '%-35s', lang( 'col_ref_id' ) )
                local resp      = sf( '%s %s %s', c1_l, c2_l, c3_l )

                con( pl, Color( 255, 255, 255 ), resp )
                con( pl, 0 )

                bCatListed, cat_id = true, a
            end

            local i = 0
            for c in helper.get.data( v ) do
                i = i + 1
            end

            local id, i_fields  = 0, ''
            for l, m in pairs( v ) do
                if arg_srch and not string.match( k, arg_srch ) then continue end
                i_fields        = i_fields + 1

                if i_fields ~= 1 then id = '' else id = k end

                local c1_d      = sf( '%-15s', tostring( '' ) )
                local c2_d      = sf( '%-35s', tostring( id ) )
                local c3_d      = sf( '%-35s', tostring( m ) )
                local resp      = sf( '%s %s %s ', c1_d, c2_d, c3_d )

                if i_fields == i then
                    resp        = resp .. '\n'
                    i_fields    = 0
                else
                    i_entries   = i_entries + 1
                end

                con( pl, Color( 255, 255, 0 ), resp )
            end

        end

    end

    con( pl, 1 )
    con( pl, Color( 0, 255, 0 ), sf( lang( 'inf_found_cnt', i_entries ) ) )
    con( pl, 1 )

end
rcc.register( 'rlib_panels', rcc_panels_registered )

/*
*   rcc :: terms
*
*   displays terms interface
*/

local function rcc_terms( pl, cmd, args )

    /*
    *   define command
    */

    local ccmd = base.calls:get( 'commands', 'rlib_terms' )

    /*
    *   scope
    */

    if ( ccmd.scope == 1 and not base.con:Is( pl ) ) then
        access:deny_consoleonly( pl, script, ccmd.id )
        return
    end

    /*
    *   perms
    */

    if not access:bIsRoot( pl ) then
        access:deny_permission( pl, script, ccmd.id )
        return
    end


end
rcc.register( 'rlib_terms', rcc_terms )