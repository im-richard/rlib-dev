/*
*   @package        rlib
*   @author         Richard [http://steamcommunity.com/profiles/76561198135875727]
*   @copyright      (C) 2018 - 2020
*   @since          1.0.0
*   @website        https://rlib.io
*   @docs           https://docs.rlib.io
*   @file           ccl.lua
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
local cfg               = base.settings

/*
*   Localized rlib routes
*/

local helper            = base.h
local design            = base.d
local ui                = base.i
local mats              = base.m
local utils             = base.u
local access            = base.a
local tools             = base.t
local storage           = base.s
local konsole           = base.k
local sys               = base.sys

/*
*   Localized lua funcs
*
*   absolutely hate having to do this, but for squeezing out every bit of performance, we need to.
*/

local pairs             = pairs
local ipairs            = ipairs
local type              = type
local error             = error
local print             = print
local GetConVar         = GetConVar
local tonumber          = tonumber
local tostring          = tostring
local IsValid           = IsValid
local istable           = istable
local isfunction        = isfunction
local isentity          = isentity
local isnumber          = isnumber
local IsColor           = IsColor
local Color             = Color
local Material          = Material
local ScreenScale       = ScreenScale
local gui               = gui
local vgui              = vgui
local input             = input
local table             = table
local player            = player
local math              = math
local surface           = surface
local render            = render
local string            = string
local sf                = string.format
local reg_font          = surface.CreateFont

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
    local affix     = istable( suffix ) and suffix.id or isstring( suffix ) and suffix or prefix
    affix           = affix:sub( -1 ) ~= '.' and string.format( '%s.', affix ) or affix

    id              = isstring( id ) and id or 'noname'
    id              = id:gsub( '[%c%s]', '.' )

    return string.format( '%s%s', affix, id )
end

/*
*	prefix ids
*/

local function pid( str, suffix )
    local state = ( isstring( suffix ) and suffix ) or ( base and mf.prefix ) or false
    return cid( str, state )
end

/*
*   helper :: internals :: pco cvars
*
*   command variables to be adjusted when pco is toggled
*/

    helper._pco_cvars =
    {
        { id = 'gmod_mcore_test' },
        { id = 'r_queued_ropes' },
        { id = 'cl_threaded_bone_setup' },
        { id = 'cl_threaded_client_leaf_system' },
        { id = 'mat_queue_mode', val = '-1' },
        { id = 'r_threaded_renderables' },
        { id = 'r_threaded_particles' },
    }

/*
*   helper :: predefined materials
*
*   list of internal gmod mat paths
*/

    helper._mat =
    {
        [ 'pp_blur' ]       = 'pp/blurscreen',
        [ 'pp_blur_m' ]     = 'pp/motionblur',
        [ 'pp_blur_x' ]     = 'pp/blurx',
        [ 'pp_blur_y' ]     = 'pp/blury',
        [ 'pp_blur_b' ]     = 'pp/bokehblur',
        [ 'pp_copy' ]       = 'pp/copy',
        [ 'pp_add' ]        = 'pp/add',
        [ 'pp_sub' ]        = 'pp/sub',
        [ 'pp_clr_mod' ]    = 'pp/colour',
        [ 'clr_white' ]     = 'vgui/white',
        [ 'circle' ]        = 'vgui/circle',
        [ 'grad_center']    = 'gui/center_gradient',
        [ 'grad' ]          = 'gui/gradient',
        [ 'grad_up']        = 'gui/gradient_up',
        [ 'grad_down' ]     = 'gui/gradient_down',
        [ 'grad_l']         = 'vgui/gradient-l',
        [ 'grad_r']         = 'vgui/gradient-r',
        [ 'grad_u' ]        = 'vgui/gradient-u',
        [ 'grad_d']         = 'vgui/gradient-d',
    }

/*
*   helper :: predefined corners
*/

    helper._corners =
    {
        [ 'corner_8' ]      = 'gui/corner8',
        [ 'corner_16' ]     = 'gui/corner16',
        [ 'corner_32' ]     = 'gui/corner32',
        [ 'corner_64' ]     = 'gui/corner64',
        [ 'corner_512' ]    = 'gui/corner512',
    }

/*
*	helper :: bokeh material list
*
*	list of available bokeh effects
*/

    helper._bokehfx =
    {
        [ 'circles' ]	    = 'rlib/general/fx/bokeh/fx-bokeh-circles.png',
        [ 'gradients' ]	    = 'rlib/general/fx/bokeh/fx-bokeh-gradients.png',
        [ 'outlines' ]	    = 'rlib/general/fx/bokeh/fx-bokeh-outlines.png',
    }

/*
*   str_wrap
*
*   takes characters in a string and determines where they need to be 'word-wrapped' based on the length 
*   provided in the parameters.
*
*   @param  : str phrase
*   @param  : int len
*   @return : tbl
*/

local function str_wrap( phrase, len )
    local phrase_len    = 0
    local pattern       = '.'

    phrase = string.gsub( phrase, pattern, function( char )
        phrase_len = phrase_len + surface.GetTextSize( char )
        if phrase_len >= len then
            phrase_len = 0
            return '\n' .. char
        end
        return char
    end )

    return phrase, phrase_len
end

/*
*   str_crop
*
*   originally developed by FPtje in DarkRP and as time went on I made my own interpretation, 
*   so credit goes to him.
*
*   @usage  : helper.str:crop( 'your test text', 200, 'Trebuchet18' )
*
*   @param  : str phrase
*   @param  : int len
*   @param  : str font
*   @return : str
*/

function helper.str:crop( phrase, len, font )
    local phrase_len    = 0
    local pattern       = '(%s?[%S]+)'
    local c             = 1

    if not phrase or not len then
        local notfound = not phrase and 'phrase' or not len and 'length'
        base:log( 6, 'missing [ %s ] and unable to crop', notfound )
        return false
    end

    if phrase and phrase == '' then
        base:log( 6, 'phrase contains empty str' )
    end

    if not font then
        font = 'Marlett'
        base:log( 6, 'strcrop font not specified, defaulting to [%s]', font )
    end

    surface.SetFont( font )

    local excludes  = { '\n', '\t' }
    local spacer    = select( 1, surface.GetTextSize( ' ' ) )

    phrase = string.gsub( phrase, pattern, function( word )

        local char = string.sub( word, 1, 1 )

        for v in rlib.h.get.data( excludes ) do
            if char == v then phrase_len = 0 end
        end

        local str_len = select( 1, surface.GetTextSize( word ) )
        phrase_len = phrase_len + str_len

        if str_len >= len then
            local spl_phrase, spl_cursor = str_wrap( word, len )
            phrase_len = spl_cursor
            c = c + 1
            return spl_phrase
        elseif phrase_len < len then
            return word
        end

        if char == ' ' then
            phrase_len = str_len - spacer
            c = c + 1
            return '\n' .. string.sub( word, 2 )
        end
        phrase_len = str_len

        c = c + 1
        return '\n' .. word

    end )

    return phrase, c

end

/*
*   cvar :: register
*
*   called client-side when cvars need to be registerd with a player
*/

function base.cvar:register( )
    if not istable( ui.cvars ) then return end

    local _toregister = { }
    for k, v in helper:sortedkeys( ui.cvars ) do
        _toregister[ #_toregister + 1 ] = v
    end

    table.sort( _toregister, function( a, b ) return a.sid < b.sid end )

    for k, v in pairs( _toregister ) do
        if base._def.elements_ignore[ v.stype ] then continue end
        base.cvar:setup( v.stype, v.id, v.default, v.values, v.forceset, v.desc )
    end
end

/*
*   cvar :: setup cvar properties
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
*   @param  : str helptext
*   @return : void
*/

function base.cvar:setup( flag, id, def, vals, forceset, helptext )
    if not helper.str:valid( flag ) or not helper.str:valid( id ) then
        base:log( 2, lang( 'properties_setup' ) )
        return false
    end

    forceset = forceset or false
    helptext = isstring( helptext ) and helptext or 'no description'

    if flag ~= 'rgba' and flag ~= 'object' and flag ~= 'dropdown' then
        CreateClientConVar( id, def, true, false, helptext )
        if forceset then
            local cvar = GetConVar( id )
            cvar:SetString( def )
        end
    elseif flag == 'dropdown' then
        CreateClientConVar( id, def or '', true, false, helptext )
        if forceset then
            local cvar = GetConVar( id )
            cvar:SetString( def )
        end
    elseif flag == 'object' or flag == 'rgba' then
        if not istable( vals ) then return end
        for dn, dv in pairs( vals ) do
            local assign_id = id .. '_' .. dn
            CreateClientConVar( assign_id, dv, true, false, helptext )
            if forceset then
                local cvar = GetConVar( assign_id )
                cvar:SetString( dv )
            end
        end
    end
end

/*
*   failsafe check
*
*   checks to see if any theme properties are missing
*
*   @param  : tbl tbl
*   @param  : str val
*   @return : bool
*/

function helper:fscheck( tbl, val )
    for k, v in pairs( tbl ) do
        if ( type( v ) == 'table' ) and ( v.id == val ) then return true end
    end
    return false
end

/*
*   create convar
*
*   create a client convar
*
*   @param  : str name
*   @param  : str default
*   @param  : bool shouldsave
*   @param  : bool userdata
*   @param  : str helptext
*/

function helper:cvar_cl_create( name, default, shouldsave, userdata, helptext )
    if not helper.str:valid( name ) then
        base:log( 2, lang( 'cvar_missing_name' ) )
        return false
    end

    if not ConVarExists( name ) then
        if not default then
            base:log( 2, lang( 'cvar_missing_def', name ) )
            return false
        end

        shouldsave  = shouldsave or true
        userdata    = userdata or false
        helptext    = helptext or ''

        CreateClientConVar( name, default, shouldsave, userdata, helptext )
        base:log( 6, lang( 'cvar_added', name ) )
    end
end

/*
*   access :: initialize
*
*   on server start, load all permissions provided through a table.
*
*   if no table specified; will load base script permissions which are in rlib.permissions table
*
*   function is called both server and clientside due to different admin mods registering permissions
*   differently; as well as other functionality.
*
*   @call   : access:initialize( base.modules.permissions )
*   @param  : tbl perms
*/

function access:initialize( perms )

    access.admins = { }

    if not perms then perms = base.permissions end

    local cat   = perms[ 'index' ] and perms[ 'index' ].category or script
    local sw    = lang( 'perms_type_base' )

    for k, v in pairs( perms ) do
        if ( k == lang( 'perms_flag_index' ) or k == lang( 'perms_flag_setup' ) ) then continue end
        local id = isstring( v.id ) and v.id or k

        if serverguard then

            /*
            *   permissions :: serverguard
            */

            id = isstring( v.name ) and v.name or v.id or k
            serverguard.permission:Add( id )
            sw = lang( 'perms_type_sg' )

        end

        rlib:log( RLIB_LOG_PERM, lang( 'perms_add', sw, perms[ k ].id ) )
    end

end
hook.Add( pid( 'initialize.post' ), pid( 'initialize.perms' ), access.initialize )

/*
*   konsole :: send
*
*   sends a msg to the konsole
*
*   @param  : int mtype
*   @param  : varg { ... }
*/

function konsole:send( mtype, ... )
    mtype = isnumber( mtype ) and mtype or 0

    if not ui:valid( self.pnl ) and access:bIsDev( LocalPlayer( ) ) then
        self.pnl = vgui.Create( 'rlib.lo.konsole' )
        self.pnl:ActionHide( )
    end

    if not ui:valid( self.pnl ) then return end

    self.pnl:AddEntry( mtype, { ... } )
end

/*
*   konsole :: send vararg
*
*   allows vararg in msg
*   does not support colorization as konsole:send does
*
*   @ex     : rlib.k:send_varg( 8, '%i entries successfully cleared', 1 )
*
*   @param  : int mtype
*   @param  : str msg
*   @param  : varg { ... }
*/

function konsole:send_varg( mtype, msg, ... )
    mtype = isnumber( mtype ) and mtype or 0

    if not ui:valid( self.pnl ) and access:bIsDev( LocalPlayer( ) ) then
        self.pnl = vgui.Create( 'rlib.lo.konsole' )
        self.pnl:ActionHide( )
    end

    local args          = { ... }
    local resp, msg     = pcall( sf, msg, unpack( args ) )

    if not ui:valid( self.pnl ) then return end

    self.pnl:AddEntry( mtype, msg, true )
end

/*
*   concommand :: matlist
*
*   lists materials that can be shared through-out scripts
*/

function utils.cc_materials_list( pl, cmd, args )

    local ccmd = base.calls:get( 'commands', 'rlib_mats' )

    if ( ccmd.scope == 1 and not base:isconsole( pl ) ) then
        access:deny_consoleonly( pl, script, ccmd.id )
        return
    end

    if not access:bIsRoot( pl ) then
        access:deny_permission( pl, script, ccmd.id )
        return
    end

    /*
    *   functionality
    */

    if not base.m or not istable( base.m ) then return end

    for _, m in pairs( base.m ) do
        base:log( 6, '[L] [' .. _ .. ']' )
    end
end

/*
*   concommand :: registered panels
* 
*   returns a list of registered panels
*    
*   @usage  : rlib.panels <returns all panels>
*   @usage  : rlib.panels -s termhere <returns entries matching term>
*/

function utils.cc_rpanels( pl, cmd, args )

    local ccmd = base.calls:get( 'commands', 'rlib_panels' )

    if ( ccmd.scope == 1 and not base:isconsole( pl ) ) then
        access:deny_consoleonly( pl, script, ccmd.id )
        return
    end

    if not access:bIsRoot( pl ) then
        access:deny_permission( pl, script, ccmd.id )
        return
    end

    /*
    *   functionality
    */

    local arg_param     = args and args[ 1 ] or false
    local arg_searchstr = args and args[ 2 ] or nil
    local cnt_entries   = 0
    local output        = '\n\n [' .. rlib.manifest.name .. '] :: registered panels'

    base:console( pl, output )

    /*
    *   loop registered panels table
    */

    local cat_islisted  = false
    local cat_id        = ''
    local tb_pnls       = base.p

    if arg_param and arg_param == '-s' and arg_searchstr then
        base:console( pl, Color( 255, 0, 0 ), ' ', Color( 255, 0, 0 ), lang( 'search_term', arg_searchstr ) )
    end

    for a, b in pairs( tb_pnls ) do

        cat_islisted = a ~= cat_id and false or cat_islisted

        for k, v in pairs( b ) do

            if not cat_islisted then
                local l_category = sf( ' %s', a )
                base:console( pl, lang( 'sym_sp' ) )

                local c1_lbl = sf( '%-15s', l_category )
                local c2_lbl = sf( '%-35s', lang( 'col_id' ) )
                local c3_lbl = sf( '%-35s', lang( 'col_ref_id' ) )
                local c0_out = sf( '%s %s %s', c1_lbl, c2_lbl, c3_lbl )

                base:console( pl, Color( 255, 255, 255 ), c0_out )
                base:console( pl, lang( 'sym_sp' ) )

                cat_islisted, cat_id = true, a
            end

            local i = 0
            for c in helper.get.data( v ) do
                i = i + 1
            end

            local id = ''
            local cnt_fields = 0
            for l, m in pairs( v ) do
                if arg_searchstr and not string.match( k, arg_searchstr ) then continue end
                cnt_fields = cnt_fields + 1

                if cnt_fields ~= 1 then id = '' else id = k end
                local c1_data = sf( '%-15s', tostring( '' ) )
                local c2_data = sf( '%-35s', tostring( id ) )
                local c3_data = sf( '%-35s', tostring( m ) )
                local c0_data = sf( '%s%s %s %s ', c0_data, c1_data, c2_data, c3_data )

                if cnt_fields == i then
                    c0_data = c0_data .. '\n'
                    cnt_fields = 0
                else
                    cnt_entries = cnt_entries + 1
                end

                base:console( pl, Color( 255, 255, 0 ), c0_data )
            end

        end

    end

    base:console( pl, lang( 'sym_sp' ) )
    base:console( pl, Color( 0, 255, 0 ), sf( lang( 'inf_found_cnt', cnt_entries ) ) )
    base:console( pl, lang( 'sym_sp' ) )

end

/*
*   netlib :: debug ui
*
*   prompts an in-game notification for issues
*
*   @assoc  : konsole:send( )
*/

local function netlib_debug_ui( )
    if not helper.ok.ply( LocalPlayer( ) ) then return end

    local mtype     = net.ReadInt( 4 )
    local msg       = net.ReadString( )

    mtype           = mtype or 1
    msg             = msg or lang( 'debug_receive_err' )

    design:notify( mtype, msg )
end
net.Receive( 'rlib.debug.ui', netlib_debug_ui )

/*
*   netlib :: user management update
*
*   only update the table when it has been modified
*/

local function netlib_user( )
    if not helper.ok.ply( LocalPlayer( ) ) then return end
    local tbl_access    = net.ReadTable( )
    access.admins       = istable( tbl_access ) and tbl_access or { }
end
net.Receive( 'rlib.user', netlib_user )

/*
*   netlib :: user management update
*
*   only update the table when it has been modified
*/

local function netlib_user_init( )
    if not helper.ok.ply( LocalPlayer( ) ) then return end
    base.cvar:register( )
end
net.Receive( 'rlib.user.init', netlib_user_init )

/*
*   netlib :: event listener
* 
*   output to konsole when a player connects or disconnects from the server.
*/

local function netlib_debug_listen( )
    local is_join   = net.ReadBool( )
    local is_bot    = net.ReadBool( )
    local target    = net.ReadString( )
    local addr      = net.ReadString( )
    local nwid      = net.ReadString( )
    local param     = net.ReadString( )

    local c         = is_join and '[ JOIN ] ' or '[ PART ] '
    local a         = not is_bot and addr or lang( 'sys_user_type' ):upper( )
    local append    = not is_join and param or false

    if is_bot then
        konsole:send( 0, Color( 50, 200, 50 ), c, Color( 255, 255, 255 ), target .. ' ', Color( 255, 255, 25 ), '[' .. nwid .. ']' )
    else
        local ip, _ = is_join and helper.str:split_addr( addr ) or false, false
        if not is_join then ip = 'D/C' end
        if append then
            konsole:send( 0, Color( 50, 200, 50 ), c, Color( 255, 255, 255 ), target .. ' ', Color( 255, 255, 25 ), '[' .. nwid .. ']', Color( 255, 255, 255 ), '[' .. ip .. '] ', Color( 180, 20, 20 ), append )
        else
            konsole:send( 0, Color( 50, 200, 50 ), c, Color( 255, 255, 255 ), target .. ' ', Color( 255, 255, 25 ), '[' .. nwid .. ']', Color( 255, 255, 255 ), '[' .. ip .. '] ' )
        end

    end
end
net.Receive( 'rlib.debug.eventlistener', netlib_debug_listen )

/*
*   rlib :: initialize
*
*   executes numerous processes including the updater, rdo, hooks, and workshop registration
*   
*   @parent : hook, Initialize
*/

local function initialize( )
    timex.simple( pid( '__gm.initialize' ), 1, function( )
        for l, m in SortedPairs( base.w ) do
            steamworks.FileInfo( l, function( res )
                if not res or not res.title then return end
                base.w[ l ].steamapi = { title = res.title }
                base:log( RLIB_LOG_WS, lang( 'ws_registered', m.id, l ) )
            end )
        end
    end )

    hook.Run( pid( 'initialize' ) )
end
hook.Add( 'Initialize', pid( '__gm.initialize' ), initialize )

/*
*   rlib :: initialize :: post
*
*   called within gmod hook InitPostEntity which is after all steps related to rlib and rcore should be 
*   loaded.
*
*   registration hooks include
*       : commands      rlib.cmd.register
*       : packages      rlib.pkg.register
*       : fonts         rlib.fnt.register
*
*   commonly used for actions such as registering permissions, concommands, etc.
*/

local function initialize_post( )
    hook.Run( pid( 'cmd.register' ) )
    hook.Run( pid( 'pkg.register' ) )
    hook.Run( pid( 'fnt.register' ) )

    for k, v in pairs( _G.rcalls.commands ) do
        if ( v.scope == 2 or v.scope == 3 ) and v.enabled then
            base.cc.Add( v.id, v.assoc )
        else
            continue
        end
    end

    hook.Run( pid( 'initialize.post' ) )
end
hook.Add( 'InitPostEntity', pid( '__gm.initpostentity' ), initialize_post )

/*
*	rlib :: think :: resolution
*
*	monitor resolution changes
*
*	@todo   : integrate into existing scripts
*/

local i_rlib_think = 0
local function think_pl_res( )
    if i_rlib_think > CurTime( ) then return end
    if not helper.ok.ply( LocalPlayer( ) ) then return end

    local pl = LocalPlayer( )

    -- rather than painting positions, just store the players old monitor resolution
    -- and reinit the ui if the monitor resolution changes.
    if not ( pl.scnres_w or pl.scnres_h ) or ( pl.scnres_w ~= ScrW( ) or pl.scnres_h ~= ScrH( ) ) then
        pl.scnres_w, pl.scnres_h = ScrW( ), ScrH( )
    end

    i_rlib_think = CurTime( ) + 0.2
end
hook.Add( 'Think', pid( 'think.plres' ), think_pl_res )

/*
*   cvars :: onchangecb
*
*   executed when a cvar has been modified
*   may not include all cvars; only important ones that require monitoring
*
*   @param  : str name
*   @param  : str old
*   @param  : str new
*/

local function cvar_cb_lang( name, old, new )
    design.notify_adv( false, lang( 'lang_title' ), lang( 'lang_msg_change', new ), delay )
end
cvars.AddChangeCallback( 'rlib_language', cvar_cb_lang )