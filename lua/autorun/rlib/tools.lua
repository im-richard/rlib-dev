/*
*   @package        rlib
*   @author         Richard [http://steamcommunity.com/profiles/76561198135875727]
*   @copyright      (C) 2018 - 2020
*   @since          1.0.0
*   @website        https://rlib.io
*   @docs           https://docs.rlib.io
*   @file           tools.lua
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

rlib                        = rlib or { }
local base                  = rlib
local mf                    = base.manifest
local prefix                = mf.prefix
local cfg                   = base.settings

/*
*   Localized rlib routes
*/

local helper                = base.h
local access                = base.a
local design                = base.d
local ui                    = base.i
local mats                  = base.m
local tools                 = base.t
local konsole               = base.k
local utils                 = base.u

/*
*   Localized translation func
*/

local function lang( ... )
    return base:lang( ... )
end

/*
*	prefix ids
*/

local function pid( str, suffix )
    local state = ( isstring( suffix ) and suffix ) or ( base and prefix ) or false
    return rlib.get:pref( str, state )
end

/*
*	tools :: disconnect :: run
*
*	disconnect interface
*/

function tools.dc:Run( )
    if not access:bIsDev( LocalPlayer( ) ) and not access:bIsRoot( LocalPlayer( ) ) then return end

    if ui:valid( self.pnl ) then
        ui:destroy( self.pnl )
        return
    end

    self.pnl            = ui.new( 'rlib.lo.dc'                  )
    :title              ( lang( 'dc_title' )                    )
    :actshow            (                                       )
end
base.cc.Add( pid( 'dc' ), tools.dc.Run )

/*
*	konsole :: run
*
*	rlib konsole
*/

function tools.konsole:Run( )
    if not access:bIsDev( LocalPlayer( ) ) then return end
    if not ui:valid( konsole.pnl ) then
        konsole.pnl = vgui.Create( 'rlib.lo.konsole' )
    end
    konsole.pnl:ActionShow( )
end
base.cc.Add( pid( 'konsole' ), tools.konsole.Run )

/*
*	tools :: languages :: run
*
*	language selection interface
*/

function tools.language:Run( )
    if ui:valid( self.pnl ) then
        ui:destroy( self.pnl )
        return
    end

    self.pnl                = ui.new( 'rlib.lo.language'        )
    :title                  ( lang( 'lang_sel_title' )          )
    :actshow                (                                   )
end
base.cc.Add( pid( 'lang' ), tools.language.Run )

/*
*	tools :: mviewer :: run
*
*	model viewer interface
*/

function tools.mviewer:Run( )
    if not access:bIsDev( LocalPlayer( ) ) and not access:bIsRoot( LocalPlayer( ) ) then return end

    if ui:visible( self.pnl ) then
        ui:destroy( self.pnl )
    end

    self.pnl                = ui.new( 'rlib.lo.mviewer'         )
    :title                  ( lang( 'mviewer_title' )           )
    :actshow                (                                   )
end
base.cc.Add( pid( 'mview' ), tools.mviewer.Run )

/*
*   tools :: pco :: run
*
*   optimization tool which helps adjust a few game vars in order to cut back and save frames.
*   should only be used if you actually know what changes this makes
*
*   @param  : bool bEnable
*/

function tools.pco:Run( bEnable )
    bEnable = bEnable or false

    for k, v in pairs( helper._pco_cvars ) do
        local val = v.val or ( bEnable and 1 ) or 0
        base.cc.Run( v.id, val )
    end
end

/*
*	tools :: rcfg :: run
*
*	rcfg interface
*/

function tools.rcfg:Run( )
    if not access:bIsDev( LocalPlayer( ) ) and not access:bIsRoot( LocalPlayer( ) ) then return end

    if ui:valid( self.pnl ) then
        ui:destroy( self.pnl )
        return
    end

    self.pnl                = ui.new( 'rlib.lo.rcfg'            )
    :title                  ( lang( 'rcfg_title' )              )
    :actshow                (                                   )
end
base.cc.Add( pid( 'rcfg' ), tools.rcfg.Run )

/*
*	tools :: rmain :: run
*
*	rlib main / about interface
*/

function tools.rmain:Run( )
    if not access:bIsDev( LocalPlayer( ) ) and not access:bIsRoot( LocalPlayer( ) ) then return end

    /*
    *   about :: network update check
    */

    net.Start               ( 'rlib.udm.check'  )
    net.SendToServer        (                   )

    /*
    *   about :: create / show parent pnl
    */

    if ui:valid( self.pnl ) then
        ui:destroy( self.pnl )
        return
    end

    self.pnl                = ui.new( 'rlib.lo.about'           )
    :title                  ( lang( 'title_about' )             )
    :actshow                (                                   )
end
base.cc.Add( pid( 'about' ), tools.rmain.Run )

/*
*	tools :: report :: run
*
*	report bug / diagnostics interface
*/

function tools.report:Run( )
    if not access:bIsDev( LocalPlayer( ) ) and not access:bIsRoot( LocalPlayer( ) ) then return end

    if ui:valid( self.pnl ) then
        ui:destroy( self.pnl )
        return
    end

    self.pnl                = ui.new( 'rlib.lo.report'          )
    :title                  ( lang( 'reports_title' )           )
    :actshow                (                                   )
end
base.cc.Add( pid( 'report' ), tools.report.Run )

/*
*   netlib :: konsole
*
*   prompts an in-game notification for issues
*/

local function netlib_konsole( )
    if not helper.ok.ply( LocalPlayer( ) ) then return end

    local mtype     = net.ReadInt( 4 )
    local msg       = net.ReadString( )

    mtype           = mtype or 1
    msg             = msg or lang( 'debug_receive_err' )

    konsole:send( mtype, msg )
end
net.Receive( 'rlib.konsole', netlib_konsole )

/*
*   netlib :: tools :: dc
*
*   initializes dc ui
*/

local function netlib_tools_dc( )
    if not helper.ok.ply( LocalPlayer( ) ) then return end
    tools.dc:Run( )
end
net.Receive( 'rlib.tools.dc', netlib_tools_dc )

/*
*   netlib :: tools :: lang
*
*   initializes lang selector ui
*/

local function netlib_lang( )
    if not helper.ok.ply( LocalPlayer( ) ) then return end
    tools.language:Run( )
end
net.Receive( 'rlib.tools.lang', netlib_lang )

/*
*   netlib :: tools :: mviewer
*
*   net.Receive to open model viewer
*/

local function netlib_mdlviewer( )
    if not helper.ok.ply( LocalPlayer( ) ) then return end
    tools.mviewer:Run( )
end
net.Receive( 'rlib.tools.mdlviewer', netlib_mdlviewer )

/*
*   netlib :: tools :: pco
*
*   player-client-optimizations
*/

local function netlib_pco( )
    if not helper.ok.ply( LocalPlayer( ) ) then return end

    local bool = net.ReadBool( )
    tools.pco:Run( bool )
end
net.Receive( 'rlib.tools.pco', netlib_pco )

/*
*   netlib :: tools :: rcfg
*
*   initializes rcfg ui
*/

local function netlib_tools_rcfg( )
    if not helper.ok.ply( LocalPlayer( ) ) then return end
    tools.rcfg:Run( )
end
net.Receive( 'rlib.tools.rcfg', netlib_tools_rcfg )

/*
*   netlib :: tools :: rlib rmain
*
*   run rlib ui
*/

local function netlib_tools_rmain( )
    if not helper.ok.ply( LocalPlayer( ) ) then return end
    tools.rmain:Run( )
end
net.Receive( 'rlib.tools.rmain', netlib_tools_rmain )

/*
*	keybinds :: konsole
*
*	checks to see if the assigned keys are being pressed to activate the developer console
*/

local i_konsole_think = 0
local function th_binds_konsole( )
    if not access:bIsDev( LocalPlayer( ) ) and not access:bIsAdmin( LocalPlayer( ) ) then return end
    if gui.IsConsoleVisible( ) then return end

    local iKey1, iKey2      = cfg.konsole.binds.act_btn1, cfg.konsole.binds.act_btn2
    local b_Keybfocus       = vgui.GetKeyboardFocus( )

    if LocalPlayer( ):IsTyping( ) or b_Keybfocus then return end

    if ( isnumber( iKey1 ) and iKey1 ~= 0 ) then
        if ( input.IsKeyDown( iKey1 ) and input.IsKeyDown( iKey2 ) ) then
            if i_konsole_think > CurTime( ) then return end
            tools.konsole:Run( )
            i_konsole_think = CurTime( ) + 1
        end
    else
        if ( iKey2 and input.IsKeyDown( iKey2 ) ) then
            if i_konsole_think > CurTime( ) then return end
            tools.konsole:Run( )
            i_konsole_think = CurTime( ) + 1
        end
    end
end
hook.Add( 'Think', pid( 'keybinds.konsole' ), th_binds_konsole )

/*
*	keybinds :: send report
*
*	checks to see if the assigned keys are being pressed to activate the report ui
*/

local i_rep_think = 0
local function th_binds_report( )
    if not access:bIsDev( LocalPlayer( ) ) and not access:bIsRoot( LocalPlayer( ) ) then return end
    if gui.IsConsoleVisible( ) then return end

    local iKey1, iKey2      = cfg.report.binds.key1, cfg.report.binds.key2
    local b_Keybfocus       = vgui.GetKeyboardFocus( )

    if LocalPlayer( ):IsTyping( ) or b_Keybfocus then return end

    if ( isnumber( iKey1 ) and iKey1 ~= 0 ) then
        if ( input.IsKeyDown( iKey1 ) and input.IsKeyDown( iKey2 ) ) then
            if i_rep_think > CurTime( ) then return end
            tools.report:Run( )
            i_rep_think = CurTime( ) + 1
        end
    else
        if ( iKey2 and input.IsKeyDown( iKey2 ) ) then
            if i_rep_think > CurTime( ) then return end
            tools.report:Run( )
            i_rep_think = CurTime( ) + 1
        end
    end
end
hook.Add( 'Think', pid( 'keybinds.report' ), th_binds_report )

/*
*   keybinds :: rlib main
*
*   checks to see if the assigned keys are being pressed to activate the about ui
*/

local i_rmain_think = 0
local function th_binds_rmain( )
    if not access:bIsDev( LocalPlayer( ) ) and not access:bIsRoot( LocalPlayer( ) ) then return end
    if gui.IsConsoleVisible( ) then return end

    local iKey1, iKey2      = cfg.rmain.binds.key1, cfg.rmain.binds.key2
    local b_Keybfocus       = vgui.GetKeyboardFocus( )

    if LocalPlayer( ):IsTyping( ) or b_Keybfocus then return end

    if ( isnumber( iKey1 ) and iKey1 ~= 0 ) then
        if ( input.IsKeyDown( iKey1 ) and input.IsKeyDown( iKey2 ) ) then
            if i_rmain_think > CurTime( ) then return end
            tools.rmain:Run( )
            i_rmain_think = CurTime( ) + 1
        end
    else
        if ( iKey2 and input.IsKeyDown( iKey2 ) ) then
            if i_rmain_think > CurTime( ) then return end
            tools.rmain:Run( )
            i_rmain_think = CurTime( ) + 1
        end
    end
end
hook.Add( 'Think', pid( 'keybinds.rmain' ), th_binds_rmain )

/*
*   keybinds :: rcfg
*
*   checks to see if the assigned keys are being pressed to activate the rcfg ui
*/

local i_rcfg_think = 0
local function th_binds_rcfg( )
    if not access:bIsDev( LocalPlayer( ) ) and not access:bIsRoot( LocalPlayer( ) ) then return end
    if gui.IsConsoleVisible( ) then return end
    if not cfg.rcfg.binds.enabled then return end

    local iKey1, iKey2      = cfg.rcfg.binds.key1, cfg.rcfg.binds.key2
    local b_Keybfocus       = vgui.GetKeyboardFocus( )

    if LocalPlayer( ):IsTyping( ) or b_Keybfocus then return end

    if ( isnumber( iKey1 ) and iKey1 ~= 0 ) then
        if ( input.IsKeyDown( iKey1 ) and input.IsKeyDown( iKey2 ) ) then
            if i_rcfg_think > CurTime( ) then return end
            tools.rcfg:Run( )
            i_rcfg_think = CurTime( ) + 1
        end
    else
        if ( iKey2 and input.IsKeyDown( iKey2 ) ) then
            if i_rcfg_think > CurTime( ) then return end
            tools.rcfg:Run( )
            i_rcfg_think = CurTime( ) + 1
        end
    end
end
hook.Add( 'Think', pid( 'keybinds.rcfg' ), th_binds_rcfg )