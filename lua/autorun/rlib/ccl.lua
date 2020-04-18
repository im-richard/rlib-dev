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
local cfg               = base.settings

/*
*   Localized rlib routes
*/

local helper            = base.h
local design            = base.d
local ui                = base.i
local access            = base.a
local konsole           = base.k
local cvar              = base.v

/*
*   Localized lua funcs
*
*   absolutely hate having to do this, but for squeezing out every bit of performance, we need to.
*/

local pairs             = pairs
local type              = type
local istable           = istable
local isnumber          = isnumber
local Color             = Color
local vgui              = vgui
local surface           = surface
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
        { id = 'gmod_mcore_test',                   off = '0', on = '1'     },
        { id = 'mat_queue_mode',                    off = '0', on = '-1'    },
        { id = 'studio_queue_mode',                 off = '0', on = '1'     },
        { id = 'cl_threaded_bone_setup',            off = '0', on = '1'     },
        { id = 'cl_threaded_client_leaf_system',    off = '0', on = '1'     },
        { id = 'r_threaded_client_shadow_manager',  off = '0', on = '1'     },
        { id = 'r_threaded_particles',              off = '0', on = '1'     },
        { id = 'r_threaded_renderables',            off = '0', on = '1'     },
        { id = 'r_queued_ropes',                    off = '0', on = '1'     },
        { id = 'r_shadowfromworldlights',           off = '1', on = '0'     },
        { id = 'nb_shadow_dist',                    off = '1', on = '0'     },
        { id = 'mat_shadowstate',                   off = '1', on = '0'     },
        { id = 'r_shadowrendertotexture',           off = '1', on = '0'     },
        { id = 'r_shadowmaxrendered',               off = '1', on = '0'     },
    }

/*
*   helper :: internals :: pco :: hooks
*
*   list of hooks to manage when pco toggled
*/

    helper._pco_hooks =
    {
        { event = 'RenderScreenspaceEffects',       name = 'RenderSharpen'          },
        { event = 'RenderScreenspaceEffects',       name = 'RenderMaterialOverlay'  },
        { event = 'RenderScreenspaceEffects',       name = 'RenderMotionBlur'       },
        { event = 'RenderScreenspaceEffects',       name = 'RenderColorModify'      },
        { event = 'RenderScreenspaceEffects',       name = 'RenderSobel'            },
        { event = 'RenderScreenspaceEffects',       name = 'RenderBloom'            },
        { event = 'RenderScreenspaceEffects',       name = 'RenderSunbeams'         },
        { event = 'RenderScreenspaceEffects',       name = 'RenderToyTown'          },
        { event = 'RenderScreenspaceEffects',       name = 'RenderTexturize'        },
        { event = 'RenderScene',                    name = 'RenderStereoscopy'      },
        { event = 'RenderScene',                    name = 'RenderSuperDoF'         },
        { event = 'PostRender',                     name = 'RenderFrameBlend'       },
        { event = 'PreRender',                      name = 'PreRenderFrameBlend'    },
        { event = 'RenderScreenspaceEffects',       name = 'RenderBokeh'            },
        { event = 'NeedsDepthPass',                 name = 'NeedsDepthPass_Bokeh'   },
        { event = 'PostDrawEffects',                name = 'RenderWidgets'          },
        { event = 'PostDrawEffects',                name = 'RenderHalos'            },
        { event = 'Think',                          name = 'DOFThink'               },
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
        log( 6, 'missing [ %s ] and unable to crop', notfound )
        return false
    end

    if phrase and phrase == '' then
        log( 6, 'phrase contains empty str' )
    end

    if not font then
        font = 'Marlett'
        log( 6, 'strcrop font not specified, defaulting to [%s]', font )
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
        if ( istable( v ) ) and ( v.id == val ) then return true end
    end
    return false
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
hook.Add( pid( 'initialize.post' ), pid( 'initialize_perms' ), access.initialize )

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
*   netlib :: debug :: ui
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
*   netlib :: user :: update
*
*   only update the table when it has been modified
*
*   @note   : 3 second delay from server
*/

local function netlib_user_update( )
    if not helper.ok.ply( LocalPlayer( ) ) then return end
    local pl = LocalPlayer( )

    cvar:Prepare( )

    /*
    *   create ply var table
    */

    pl.rlib         = pl.rlib or { }
end
net.Receive( 'rlib.user.update', netlib_user_update )

/*
*   netlib :: debug :: event listener
* 
*   output to konsole when a player connects or disconnects from the server.
*/

local function netlib_debug_listener( )
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
net.Receive( 'rlib.debug.listener', netlib_debug_listener )

/*
*   rlib :: initialize
*
*   executes numerous processes including the updater, rdo, hooks, and workshop registration
*   
*   @parent : hook, Initialize
*/

local function initialize( )
    timex.simple( '__lib_initialize', 1, function( )
        for l, m in SortedPairs( base.w ) do
            steamworks.FileInfo( l, function( res )
                if not res or not res.title then return end
                base.w[ l ].steamapi = { title = res.title }
                log( RLIB_LOG_WS, lang( 'ws_registered', m.id, l ) )
            end )
        end
    end )

    timex.simple( 10, function( )
        hook.Run( pid( 'initialize' ) )
    end )
end
hook.Add( 'Initialize', pid( '__lib_initialize' ), initialize )

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

local function __lib_initpostentity( )
    hook.Run( pid( 'cmd.register' ) )
    hook.Run( pid( 'pkg.register' ) )
    hook.Run( pid( 'fnt.register' ) )

    /*
    *   register commands
    */

    rcc.prepare( )

    hook.Run( pid( 'initialize.post' ) )
end
hook.Add( 'InitPostEntity', pid( '__lib_initpostentity' ), __lib_initpostentity )

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

    i_rlib_think = CurTime( ) + 0.5
end
hook.Add( 'Think', pid( 'think.pl.res' ), think_pl_res )

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