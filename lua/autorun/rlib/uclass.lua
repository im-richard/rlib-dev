/*
*   @package        rlib
*   @author         Richard [http://steamcommunity.com/profiles/76561198135875727]
*   @copyright      (C) 2018 - 2020
*   @since          1.0.0
*   @website        https://rlib.io
*   @docs           https://docs.rlib.io
*   @file           uclass.lua
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
local design                = base.d
local ui                    = base.i
local mats                  = base.m
local utils                 = base.u
local access                = base.a
local tools                 = base.t
local konsole               = base.k
local sys                   = base.sys

/*
*   Localized lua funcs
*
*   absolutely hate having to do this, but for squeezing out every bit of performance, we need to.
*/

local pairs                 = pairs
local ipairs                = ipairs
local SortedPairs           = SortedPairs
local type                  = type
local error                 = error
local print                 = print
local GetConVar             = GetConVar
local tonumber              = tonumber
local tostring              = tostring
local IsValid               = IsValid
local istable               = istable
local isfunction            = isfunction
local isentity              = isentity
local isnumber              = isnumber
local IsColor               = IsColor
local Color                 = Color
local Material              = Material
local ScreenScale           = ScreenScale
local gui                   = gui
local vgui                  = vgui
local table                 = table
local player                = player
local math                  = math
local surface               = surface
local draw                  = draw
local render                = render
local string                = string
local sf                    = string.format

/*
*   helper :: predefined materials
*
*   list of internal gmod mat paths
*/

helper._vgui =
{
    [ 'avatarimage' ]       = 'AvatarImage',
    [ 'avatar' ]            = 'AvatarImage',
    [ 'av' ]                = 'AvatarImage',
    [ 'dbinder' ]           = 'DBinder',
    [ 'binder' ]            = 'DBinder',
    [ 'dbubblecontainer' ]  = 'DBubbleContainer',
    [ 'bubble' ]            = 'DBubbleContainer',
    [ 'dbutton' ]           = 'DButton',
    [ 'button']             = 'DButton',
    [ 'btn']                = 'DButton',
    [ 'dcategorylist' ]     = 'DCategoryList',
    [ 'categories' ]        = 'DCategoryList',
    [ 'catlst' ]            = 'DCategoryList',
    [ 'catlist' ]           = 'DCategoryList',
    [ 'dcheckbox' ]         = 'DCheckBox',
    [ 'checkbox' ]          = 'DCheckBox',
    [ 'chkbox' ]            = 'DCheckBox',
    [ 'cbox' ]              = 'DCheckBox',
    [ 'cb' ]                = 'DCheckBox',
    [ 'catexpand' ]         = 'DCollapsibleCategory',
    [ 'dcolorcombo' ]       = 'DColorCombo',
    [ 'clrcombo' ]          = 'DColorCombo',
    [ 'clrcbo' ]            = 'DColorCombo',
    [ 'dcolorcube' ]        = 'DColorCube',
    [ 'clrcube' ]           = 'DColorCube',
    [ 'dcolormixer' ]       = 'DColorMixer',
    [ 'clrmixer' ]          = 'DColorMixer',
    [ 'dcolorpalette' ]     = 'DColorPalette',
    [ 'clrpal' ]            = 'DColorPalette',
    [ 'dcolumnsheet' ]      = 'DColumnSheet',
    [ 'colsheet' ]          = 'DColumnSheet',
    [ 'dcombobox' ]         = 'DComboBox',
    [ 'combobox' ]          = 'DComboBox',
    [ 'cbo' ]               = 'DComboBox',
    [ 'dfilebrowser' ]      = 'DFileBrowser',
    [ 'file' ]              = 'DFileBrowser',
    [ 'dform' ]             = 'DForm',
    [ 'form' ]              = 'DForm',
    [ 'DFrame' ]            = 'DFrame',
    [ 'frame' ]             = 'DFrame',
    [ 'frm' ]               = 'DFrame',
    [ 'dgrid' ]             = 'DGrid',
    [ 'grid' ]              = 'DGrid',
    [ 'dhtml' ]             = 'DHTML',
    [ 'dweb' ]              = 'DHTML',
    [ 'html' ]              = 'HTML',
    [ 'web' ]               = 'HTML',
    [ 'dhtmlcontrols' ]     = 'DHTMLControls',
    [ 'dhtmlctrls' ]        = 'DHTMLControls',
    [ 'ctrls' ]             = 'DHTMLControls',
    [ 'dhtmctrl' ]          = 'DHTMLControls',
    [ 'htmctrl' ]           = 'DHTMLControls',
    [ 'diconlayout' ]       = 'DIconLayout',
    [ 'iconlayout' ]        = 'DIconLayout',
    [ 'dico' ]              = 'DIconLayout',
    [ 'ilayout' ]           = 'DIconLayout',
    [ 'il' ]                = 'DIconLayout',
    [ 'dimage' ]            = 'DImage',
    [ 'img' ]               = 'DImage',
    [ 'dlabel' ]            = 'DLabel',
    [ 'label' ]             = 'DLabel',
    [ 'lbl' ]               = 'DLabel',
    [ 'listlayout' ]        = 'DListLayout',
    [ 'lstlayout' ]         = 'DListLayout',
    [ 'listview' ]          = 'DListView',
    [ 'lstview' ]           = 'DListView',
    [ 'dmenu' ]             = 'DMenu',
    [ 'menu' ]              = 'DMenu',
    [ 'mnu' ]               = 'DMenu',
    [ 'dmenubar' ]          = 'DMenuBar',
    [ 'menubar' ]           = 'DMenuBar',
    [ 'mnubar' ]            = 'DMenuBar',
    [ 'menuopt' ]           = 'DMenuOption',
    [ 'mnuopt' ]            = 'DMenuOption',
    [ 'menucvar' ]          = 'DMenuOptionCVar',
    [ 'mnucvar' ]           = 'DMenuOptionCVar',
    [ 'modelpanel' ]        = 'DModelPanel',
    [ 'model' ]             = 'DModelPanel',
    [ 'mdl' ]               = 'DModelPanel',
    [ 'modelselect' ]       = 'DModelSelect',
    [ 'modelsel' ]          = 'DModelSelect',
    [ 'notify' ]            = 'DNotify',
    [ 'numscale' ]          = 'DNumberScratch',
    [ 'numscratch' ]        = 'DNumberScratch',
    [ 'numwang' ]           = 'DNumberWang',
    [ 'numslider' ]         = 'DNumSlider',
    [ 'dpanel' ]            = 'DPanel',
    [ 'panel' ]             = 'DPanel',
    [ 'pnl' ]               = 'DPanel',
    [ 'progress' ]          = 'DProgress',
    [ 'properties' ]        = 'DProperties',
    [ 'propertysheet' ]     = 'DPropertySheet',
    [ 'rgb' ]               = 'DRGBPicker',
    [ 'scrollpanel' ]       = 'DScrollPanel',
    [ 'scrollpnl' ]         = 'DScrollPanel',
    [ 'spanel' ]            = 'DScrollPanel',
    [ 'spnl' ]              = 'DScrollPanel',
    [ 'sgrip' ]             = 'DScrollBarGrip',
    [ 'grip' ]              = 'DScrollBarGrip',
    [ 'autosize' ]          = 'DSizeToContents',
    [ 'slider' ]            = 'DSlider',
    [ 'sprite' ]            = 'DSprite',
    [ 'tab' ]               = 'DTab',
    [ 'dte' ]               = 'DTextEntry',
    [ 'entry' ]             = 'DTextEntry',
    [ 'textentry' ]         = 'DTextEntry',
    [ 'txt' ]               = 'DTextEntry',
    [ 'tlayout' ]           = 'DTileLayout',
    [ 'tlo' ]               = 'DTileLayout',
    [ 'tip' ]               = 'DTooltip',
    [ 'tooltip' ]           = 'DTooltip',
    [ 'tree' ]              = 'DTree',
    [ 'treenode' ]          = 'DTree_Node',
    [ 'node' ]              = 'DTree_Node',
    [ 'treebtn' ]           = 'DTree_Node_Button',
    [ 'nodebtn' ]           = 'DTree_Node_Button',
    [ 'vdivider' ]          = 'DVerticalDivider',
    [ 'verdiv' ]            = 'DVerticalDivider',
    [ 'vsbar' ]             = 'DVScrollBar',
    [ 'geditable' ]         = 'EditablePanel',
    [ 'gpanel' ]            = 'Panel',
    [ 'material' ]          = 'Material',
    [ 'mat' ]               = 'Material',
    [ 'panellist' ]         = 'PanelList',
    [ 'panellst' ]          = 'PanelList',
    [ 'pnllist' ]           = 'PanelList',
    [ 'plist' ]             = 'PanelList',
    [ 'rtxt' ]              = 'RichText',
    [ 'rt' ]                = 'RichText',
    [ 'rich' ]              = 'RichText',
}

/*
*   helper :: ui :: id preferences
*/

helper._vgui_id =
{
    [ 1 ]                   = 'DFrame',
    [ 2 ]                   = 'DPanel',
    [ 3 ]                   = 'Panel',
    [ 4 ]                   = 'EditablePanel',
}

/*
*   dock definitions
*
*   in addition to default glua enums assigned to docking,
*   the following entries can be used.
*/

local dock_align =
{
    [ 'fill' ]      = FILL,
    [ 'left' ]      = LEFT,
    [ 'top' ]       = TOP,
    [ 'right' ]     = RIGHT,
    [ 'bottom' ]    = BOTTOM,

    [ 'f' ]         = FILL,
    [ 'l' ]         = LEFT,
    [ 't' ]         = TOP,
    [ 'r' ]         = RIGHT,
    [ 'b' ]         = BOTTOM,
}

/*
*   interface :: cvars :: define
*
*   cvars to be used throughout the interface
*/

ui.cvars =
{
    { sid = 1, stype = 'dropdown', is_visible = false,  id = 'rlib_language',           name = 'Preferred language',            desc = 'default interface language',    forceset = false, default = 'en' },
    { sid = 1, stype = 'checkbox', is_visible = true,   id = 'rlib_animations_enabled', name = 'Animations enabled',            desc = 'interface animations',          forceset = false, default = 1 },
    { sid = 2, stype = 'checkbox', is_visible = true,   id = 'console_timestamps',      name = 'Show timestamps in console',    desc = 'show timestamp in logs',        forceset = false, default = 0 },
}

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
    local state = ( isstring( suffix ) and suffix ) or ( base and base.manifest.prefix ) or false
    return rlib.get:pref( str, state )
end

/*
*   metatables
*/

local dmeta = FindMetaTable( 'Panel' )

/*
*   ui :: element
*
*   gets the correct element based on the class provided
*
*   @param  : str class
*   @return : str
*/

function ui.element( class )
    class = helper.str:clean( class )
    return ( class and helper._vgui and helper._vgui[ class ] or class ) or false
end

/*
*   ui :: scale
*
*   standard scaling
*
*   @param  : int iclamp
*   @return : int
*/

function ui:scale( iclamp )
    return math.Clamp( ScrW( ) / 1920, iclamp or 0.75, 1 )
end

/*
*   ui :: screenscale
*
*   works similar to glua ScreenScale( )
*
*   @param  : int val
*   @param  : int iMax
*   @return : int
*/

function ui:screenscale( val, iMax )
    iMax = isnumber( iMax ) and iMax or ScrW( )
    return val * ( iMax / 640.0 )
end

/*
*   ui :: controlled scale
*
*   a more controlled solution to screen scaling because I dislike how doing simple ScreenScaling never 
*   makes things perfect.
*
*   yes I know, an rather odd way, but it works for the time being.
*
*   -w 800 -h 600
*   -w 1024 -h 768
*   -w 1280 -h 720
*   -w 1366 -h 768
*   -w 1920 -h -1080
*
*   @note   : deprecated in a future version with new system
*
*   @param  : bool bSimple
*   @param  : int i800
*   @param  : int i1024
*   @param  : int i1280
*   @param  : int i1366
*   @param  : int i1600
*   @param  : int i1920
*   @param  : int i2xxx
*   @return : int
*/

function ui:cscale( bSimple, i800, i1024, i1280, i1366, i1600, i1920, i2xxx )
    if not isbool( bSimple ) then
        base:log( 2, 'func [%s]: bSimple not bool', debug.getinfo( 1, 'n' ).name )
    end

    if not i800 then
        base:log( 2, 'func [%s]: no scale int specified', debug.getinfo( 1, 'n' ).name )
    end

    if not i1024 then i1024, i1280, i1366, i1600, i1920, i2xxx = i800, i800, i800, i800, i800, i800 end
    if not i1280 then i1280, i1366, i1600, i1920, i2xxx = i800, i800, i800, i800, i800 end
    if not i1366 then i1366, i1600, i1920, i2xxx = i1280, i1280, i1280, i1280 end
    if not i1600 then i1600, i1920, i2xxx = i1366, i1366, i1366 end
    if not i1920 then i1920, i2xxx = i1600, i1600 end
    if not i2xxx then i2xxx = i1920 end

    if ScrW( ) <= 800 then
        return bSimple and i800 or ScreenScale( i800 )
    elseif ScrW( ) > 800 and ScrW( ) <= 1024 then
        return bSimple and i1024 or ScreenScale( i1024 )
    elseif ScrW( ) > 1024 and ScrW( ) <= 1280 then
        return bSimple and i1280 or ScreenScale( i1280 )
    elseif ScrW( ) > 1280 and ScrW( ) <= 1366 then
        return bSimple and i1366 or ScreenScale( i1366 )
    elseif ScrW( ) > 1366 and ScrW( ) <= 1600 then
        return bSimple and i1600 or ScreenScale( i1600 )
    elseif ScrW( ) > 1600 and ScrW( ) <= 1920 then
        return bSimple and i1920 or ScreenScale( i1920 )
    elseif ScrW( ) > 1920 then
        return bSimple and i2xxx or self:screenscale( i1920, 1920 )
    end
end

/*
*   ui :: controlled scale :: strict
*
*   a more controlled solution to screen scaling because I dislike how doing simple ScreenScaling never 
*   makes things perfect.
*
*   yes I know, an rather odd way, but it works for the time being.
*
*   -w 800 -h 600
*   -w 1024 -h 768
*   -w 1280 -h 720
*   -w 1366 -h 768
*   -w 1920 -h -1080
*
*   @note   : deprecated in a future version with new system
*
*   @param  : bool bSimple
*   @param  : int i800
*   @param  : int i1024
*   @param  : int i1280
*   @param  : int i1366
*   @param  : int i1600
*   @param  : int i1920
*   @param  : int i2560
*   @return : int
*/

function ui:cscale_strict( bSimple, i800, i1024, i1280, i1366, i1600, i1920, i2560 )
    if not isbool( bSimple ) then
        base:log( 2, 'func [%s]: bSimple not bool', debug.getinfo( 1, 'n' ).name )
    end

    if not i800 then
        base:log( 2, 'func [%s]: no scale int specified', debug.getinfo( 1, 'n' ).name )
    end

    if not i1024 then i1024, i1280, i1366, i1600, i1920, i2560 = i800, i800, i800, i800, i800, i800 end
    if not i1280 then i1280, i1366, i1600, i1920, i2560 = i800, i800, i800, i800, i800 end
    if not i1366 then i1366, i1600, i1920, i2560 = i1280, i1280, i1280, i1280 end
    if not i1600 then i1600, i1920, i2560 = i1366, i1366, i1366 end
    if not i1920 then i1920, i2560 = i1600, i1600 end
    if not i2560 then i2560 = i1920 end

    if ScrW( ) <= 800 then
        return bSimple and i800 or ScreenScale( i800 )
    elseif ScrW( ) > 800 and ScrW( ) <= 1024 then
        return bSimple and i1024 or ScreenScale( i1024 )
    elseif ScrW( ) > 1024 and ScrW( ) <= 1280 then
        return bSimple and i1280 or ScreenScale( i1280 )
    elseif ScrW( ) > 1280 and ScrW( ) <= 1366 then
        return bSimple and i1366 or ScreenScale( i1366 )
    elseif ScrW( ) > 1366 and ScrW( ) <= 1600 then
        return bSimple and i1600 or ScreenScale( i1600 )
    elseif ScrW( ) > 1600 and ScrW( ) <= 1920 then
        return bSimple and i1920 or ScreenScale( i1920 )
    elseif ScrW( ) > 1920 then
        return bSimple and i2560 or self:screenscale( i2560, 2560 )
    end
end

/*
*   ui :: limit scale
*
*   clamp a width and height value
*
*   @param  : int w
*   @param  : int h
*   @return : int w, h
*/

function ui:lscale( w, h )
    h = isnumber( h ) and h or w
    return math.Clamp( 1920, 0, ScrW( ) / w ), math.Clamp( 1080, 0, ScrH( ) / h )
end

/*
*   ui :: scale :: width
*
*   clamp a width value
*
*   @param  : int w
*   @param  : int min
*   @param  : int max
*   @return : int
*/

function ui:scale_w( w, min, max )
    w = isnumber( w ) and w or ScrW( )
    return math.Clamp( ScreenScale( w ), min or 0, max or ScreenScale( w ) )
end

/*
*   ui :: scale :: height
*
*   clamp a height value
*
*   @param  : int h
*   @param  : int min
*   @param  : int max
*   @return : int
*/

function ui:scale_h( h, min, max )
    h = isnumber( h ) and h or ScrH( )
    return math.Clamp( ScreenScale( h ), min or 0, max or ScreenScale( h ) )
end

/*
*   ui :: basic scale
*
*   basic scaling control
*
*   @param  : int s
*   @param  : int m
*   @param  : int l
*   @return : int
*/

function ui:bscale( s, m, l )
    if not m then m = s end
    if not l then l = s end

    if ScrW( ) <= 1280 then
        return ScreenScale( s )
    elseif ScrW( ) >= 1281 and ScrW( ) <= 1600 then
        return ScreenScale( m )
    elseif ScrW( ) >= 1601 then
        return ScreenScale( l )
    else
        return s
    end
end

/*
*   ui :: scalesimple
*
*   simple scaling
*
*   @param  : int s
*   @param  : int m
*   @param  : int l
*   @return : int
*/

function ui:scalesimple( s, m, l )
    if not m then m = s end
    if not l then l = s end

    if ScrW( ) <= 1280 then
        return s
    elseif ScrW( ) >= 1281 and ScrW( ) <= 1600 then
        return m
    elseif ScrW( ) >= 1601 then
        return l
    else
        return s
    end
end

/*
*   ui :: setscale
*
*   calculates the screenscaled size (w, h) of a panel
*
*   @param  : int w
*   @param  : int h
*   @return : int, int
*/

function ui:setscale( w, h )
    w = isnumber( w ) and w or 300
    h = isnumber( h ) and h or w

    local sc_w, sc_h        = self:scalesimple( 0.85, 0.85, 0.90 ), self:scalesimple( 0.85, 0.85, 0.90 )
    local pnl_w, pnl_h      = w, h
    local ui_w, ui_h        = sc_w * pnl_w, sc_h * pnl_h

    return ui_w, ui_h
end

/*
*   ui :: get_padding
*
*   return current padding
*
*   @return : int
*/

function ui:getpadding( val )
    return val or 0
end

/*
*   ui :: get_margin
*
*   return current margin
*
*   @return : int
*/

function ui:getmargin( val )
    return val or 0
end

/*
*   ui :: valid
*
*   checks validation of a panel
*   uses this vs isvalid for future control
*
*   @param  : pnl pnl
*   @return : bool
*/

function ui:valid( pnl )
    return IsValid( pnl ) and true or false
end

/*
*   ui :: update
*
*   executes invalidatelayout if pnl valid
*
*   @alias  : rehash, invalidate
*
*   @param  : pnl pnl
*   @return : void
*/

function ui:rehash( pnl )
    if not self:valid( pnl ) then return end
    pnl:InvalidateLayout( )
end
ui.invalidate = ui.rehash

/*
*   ui :: clear
*
*   clears an interface
*
*   @param  : pnl pnl
*/

function ui:clear( pnl )
    if not self:valid( pnl ) then return end
    pnl:Clear( )
end

/*
*   ui :: close
*
*   hides or removes the DFrame, and calls DFrame:OnClose.
*   to set whether the frame is hidden or removed, use DFrame:SetDeleteOnClose.
*
*   @param  : pnl pnl
*/

function ui:close( pnl )
    if not self:valid( pnl ) then return end
    pnl:Close( )
end

/*
*   ui :: visible
*
*   checks a panel for validation and if currently visible
*
*   @param  : pnl pnl
*   @return : bool
*/

function ui:visible( pnl )
    return self:valid( pnl ) and pnl:IsVisible( ) and true or false
end

/*
*   ui :: destroy
*
*   checks a panel for validation and then removes it completely.
*
*   @param  : pnl pnl
*   @param  : bool halt
*   @param  : bool kmouse [optional]
*   @param  : pnl subpanel [optional]
*/

function ui:destroy( pnl, halt, kmouse, sub )
    if sub and not self:valid( sub ) then return end
    if self:valid( pnl ) then pnl:Remove( ) end
    if kmouse then
        gui.EnableScreenClicker( false )
    end
    if halt then return false end
end

/*
*   ui :: destroy visible
*
*   checks a panel for validation and visible then removes it completely.
*
*   @param  : pnl pnl
*/

function ui:destroy_visible( pnl )
    if self:valid( pnl ) and self:visible( pnl ) then
        pnl:Remove( )
    end
end

/*
*   ui :: hide
*
*   checks a panel for validation and if its currently visible and then sets panel visibility to false.
*
*   @param  : pnl pnl
*   @param  : bool kmouse
*/

function ui:hide( pnl, kmouse )
    if self:valid( pnl ) then
        pnl:SetVisible( false )
        if kmouse then
            gui.EnableScreenClicker( false )
        end
    end
end

/*
*   ui :: autosize
*
*   applies SizeToContents( ) to specified pnl
*
*   @param  : pnl pnl
*/

function ui:autosize( pnl )
    if not self:visible( pnl ) then return end
    pnl:SizeToContents( )
end

/*
*   ui :: hide visible
*
*   checks a panel for validation and if its currently visible and then sets panel visibility to false.
*
*   @param  : pnl pnl
*   @param  : bool kmouse
*/

function ui:hide_visible( pnl, kmouse )
    if self:valid( pnl ) and self:visible( pnl ) then
        pnl:SetVisible( false )
        if kmouse then
            gui.EnableScreenClicker( false )
        end
    end
end

/*
*   ui :: show
*
*   checks a panel for validation and if its not currently visible and then sets panel to visible.
*
*   @param  : pnl pnl
*   @param  : bool kmouse
*/

function ui:show( pnl, kmouse )
    if self:valid( pnl ) and not self:visible( pnl ) then
        pnl:SetVisible( true )
        if kmouse then
            gui.EnableScreenClicker( true )
        end
    end
end

/*
*   ui :: visibility flip
*
*   determines if a panel is currently either visible or not and then flips the panel visibility status.
*
*   providing a sub panel will check both the parent and sub for validation, but only flip the sub panel
*   if the parent panel is valid.
*
*   @param  : pnl pnl
*   @param  : pnl sub
*/

function ui:visible_flip( pnl, sub )
    if not self:valid( pnl ) then return end

    if sub then
        if not self:valid( sub ) then return end
    else
        sub = pnl
    end

    if self:visible( pnl ) then
        sub:SetVisible( false )
    else
        sub:SetVisible( true )
    end
end

/*
*   ui :: set visible
*
*   allows for a bool to be passed to determine if the pnl should be visible or not
*
*   @param  : pnl pnl
*   @param  : bool b
*/

function ui:setvisible( pnl, b )
    if not self:valid( pnl ) then return end
    pnl:SetVisible( b or false )
end

/*
*   ui :: setpos
*
*   checks an obj for validation and sets its position
*
*   @param  : pnl pnl
*   @param  : int x
*   @param  : int y
*/

function ui:setpos( pnl, x, y )
    x = x or 0
    y = y or 0
    if self:valid( pnl ) and self:visible( pnl ) then
        pnl:SetPos( x, y )
    end
end

/*
*   ui :: movecenter
* 
*   anim to move panel to center
*   
*   can be used as
*       panel:MoveTo( base.h.movetocenter( p_size_w, p_size_h, 0.4 ) )
*   
*   @param  : int w
*   @param  : int h
*   @param  : int time
*   @return : int (w), int (h)
*/

function ui:movecenter( w, h, time )
    if not time then time = 0.5 end
    return ScrW( ) / 2 - math.Clamp( 1920, 0, ScrW( ) / w ) / 2, ScrH( ) / 2 - math.Clamp( 1080, 0, ScrH( ) / h ) / 2, time, 0, -1
end

/*
*   ui :: setpos center
*
*   animation to move panel to center
*
*   dframes may not allow top-down animations to work properly and start the panel off-screen, so the 
*   effect may not be as desired.
*
*   @param  : pnl pnl
*   @param  : int time
*   @param  : str, int from :: [optional] :: default left
*/

function ui:setpos_center( pnl, time, from )
    if not self:valid( pnl ) then return end
    local w, h = pnl:GetSize( )

    time = isnumber( time ) and time or 0
    from = from or 3

    local init_w, init_h = -w, ( ScrH( ) / 2 ) - ( h / 2 )
    local move_w, move_h = ScrW( ) / 2 - w / 2, ScrH( ) / 2 - h / 2

    if ( from == 'top' or from == 2 ) then
        init_w, init_h    = ScrW( ) / 2 - w / 2, - h
    elseif ( from == 'right' or from == 3 ) then
        init_w, init_h    = ScrW( ) + w, ( ScrH( ) / 2 ) - ( h / 2 )
    elseif ( from == 'bottom' or from == 4 ) then
        init_w, init_h    = ScrW( ) / 2 - w / 2, ScrH( ) + h
    end

    -- for testing even though time should never be zero
    if not time then
        init_w, init_h = move_w, move_h
    end

    pnl:SetPos( init_w, init_h )
    pnl:MoveTo( move_w, move_h, time, 0, -1 )
end

/*
*   ui :: settext
*
*   method to setting text
*
*   @param  : pnl pnl
*   @param  : str text
*   @param  : str font
*/

function ui:settext( pnl, text, font )
    if not self:valid( pnl ) then return end
    text = isstring( text ) and text or ''

    if font then
        pnl:SetFont( font )
    end
    pnl:SetText( text )
end

/*
*   ui :: register panel
*
*   creates a usable panel that may need to be accessed globally. Do not store local panels using 
*   this method.
*
*   places registered pnl in :: base.p[ mod ][ panel_id ]
*
*   @param  : str id
*   @param  : str mod
*   @param  : pnl pnl
*   @param  : str desc
*/

function ui:register( id, mod, panel, desc )
    if not helper.str:valid( id ) then
        base:log( 2, lang( 'inf_reg_id_invalid' ) )
        return false
    end

    mod     = ( isstring( mod ) and mod ) or ( istable( mod ) and mod.id ) or prefix
    base.p  = istable( base.p ) and base.p or { }

    id = helper.str:clean( id )

    if ui:valid( panel ) then
        base.p[ mod ] = base.p[ mod ] or { }
        base.p[ mod ][ id ] =
        {
            pnl     = panel,
            desc    = desc or lang( 'none' )
        }
        base:log( 6, lang( 'inf_registered', id ) )
    end
end

/*
*   ui :: registered :: load
*
*   loads a previously registered panel
*
*   @ex     :       local content = ui:load( 'pnl.parent.content', 'xtask' )
^                   if not content or not ui:valid( content.pnl ) then return end
^                   content.pnl:Clear( )
*
*   @param  : str id
*   @param  : str, tbl mod
*   @return : tbl
*/

function ui:load( id, mod )
    if not helper.str:valid( id ) then
        base:log( 2, lang( 'inf_load_id_invalid' ) )
        return false
    end

    mod = ( isstring( mod ) and mod ) or ( istable( mod ) and mod.id ) or prefix

    if not istable( base.p ) then
        base:log( 2, lang( 'inf_load_tbl_invalid' ) )
        return false
    end

    id = helper.str:clean( id )

    if not istable( base.p[ mod ] ) or not istable( base.p[ mod ][ id ] ) then return end
    return IsValid( base.p[ mod ][ id ].pnl ) and base.p[ mod ][ id ] or false
end

/*
*   ui :: registered :: call panel
*
*   calls a previously registered panel similar to ui.load
*   but this validates and calls just the panel.
*
*   @ex     :   local pnl = ui:call( id, mod )
*               if not pnl then return end
*
*   @param  : str id
*   @param  : str, tbl mod
*   @return : tbl
*/

function ui:call( id, mod )
    if not helper.str:valid( id ) then
        base:log( 2, lang( 'inf_load_id_invalid' ) )
        return false
    end

    mod = ( isstring( mod ) and mod ) or ( istable( mod ) and mod.id ) or prefix

    if not istable( base.p ) then
        base:log( 2, lang( 'inf_load_tbl_invalid' ) )
        return false
    end

    id = helper.str:clean( id )

    if not istable( base.p[ mod ] ) or not istable( base.p[ mod ][ id ] ) then return end
    return IsValid( base.p[ mod ][ id ].pnl ) and base.p[ mod ][ id ].pnl or false
end

/*
*   ui :: unregister panel
*
*   removes a registered panel from the library
*
*   @param  : str id
*   @param  : str, tbl mod
*/

function ui:unregister( id, mod )
    if not helper.str:valid( id ) then
        base:log( 2, lang( 'inf_unreg_id_invalid' ) )
        return false
    end

    mod = isstring( mod ) and mod or prefix

    if not istable( base.p ) then
        base:log( 2, lang( 'inf_unreg_tbl_invalid' ) )
        return false
    end

    id = helper.str:clean( id )

    if base.p[ mod ] and base.p[ mod ][ id ] then
        base.p[ mod ][ id ] = nil
        base:log( 6, lang( 'inf_unregister', id ) )
    end
end

/*
*   ui :: create
*
*   utilities vgui.Register as a shortcut
*   used for pnls registered under the rlib:resources( ) method
*
*   if no class provided; defaults to DFrame
*
*   @ex     : ui:create( mod, 'bg', PANEL, 'pnl' )
*           : ui:create( mod, 'bg', PANEL )
*           : ui:create( mod, 'bg', PANEL, 1 )
*           : ui:create( mod, 'bg', PANEL, 2 )
*
*   @param  : tbl mod
*   @param  : str id
*   @param  : pnl pnl
*   @param  : str, int class
*/

function ui:create( mod, id, pnl, class )
    if not id or not pnl then return end

    local call = rlib:resource( mod, 'pnl', id )

    if isnumber( class ) then
        class = helper._vgui_id[ class ]
    elseif isstring( class ) then
        class = ( class and ui.element( class ) )
    else
        class = 'DFrame'
    end

    vgui.Register( call, pnl, class )
end

/*
*   ui :: validate registered pnl
*
*   determines if a registered pnl is valid
*
*   @param  : str panel
*   @return : bool
*/

function ui:ok( panel )
    if not panel then return false end
    return ( panel and self:valid( panel.pnl ) and true ) or false
end

/*
*   ui :: registered :: dispatch
*
*   destroys a registered pnl
*   ensures a pnl is a valid pnl first
*
*   @param  : str id
*   @param  : str, tbl mod
*   @return : void
*/

function ui:dispatch( id, mod )
    if not helper.str:valid( id ) then
        base:log( 2, lang( 'inf_load_id_invalid' ) )
        return
    end

    local pnl = ui:call( id, mod )
    if not pnl then return end

    self:unregister( id, mod )
    self:destroy( pnl )
end

/*
*   ui :: registered :: stage
*
*   shows a registered pnl
*   ensures a pnl is a valid pnl first
*
*   @param  : str id
*   @param  : str, tbl mod
*   @return : void
*/

function ui:stage( id, mod )
    if not helper.str:valid( id ) then
        base:log( 2, lang( 'inf_load_id_invalid' ) )
        return
    end

    local pnl = ui:call( id, mod )
    if not pnl then return end

    self:show( pnl )
end

/*
*   ui :: registered :: unstage
*
*   hides a registered pnl
*   ensures a pnl is a valid pnl first
*
*   @param  : str id
*   @param  : str, tbl mod
*   @return : void
*/

function ui:unstage( id, mod )
    if not helper.str:valid( id ) then
        base:log( 2, lang( 'inf_load_id_invalid' ) )
        return
    end

    local pnl = ui:call( id, mod )
    if not pnl then return end

    self:hide( pnl )
end

/*
*   ui :: create fonts
*
*   creates a generic set of fonts to be used with the library
*
*   @param  : str suffix
*   @param  : str font
*   @param  : int scale [ optional ]
*/

function ui:fonts_register( suffix, font, scale )
    suffix  = isstring( suffix ) and suffix or prefix
    font    = isstring( font ) and font or pid( 'sys.entry.default' )
    scale   = isnumber( scale ) and scale or self:scale( )

    local char_last = string.sub( suffix, -1 )

    local font_sz =
    {
        [ 12 ] = '12',
        [ 14 ] = '14',
        [ 16 ] = '16',
        [ 18 ] = '18',
        [ 20 ] = '20',
        [ 24 ] = '24',
        [ 32 ] = '32',
    }

    local font_wgts =
    {
        [ 400 ] = '400',
        [ 600 ] = '600',
        [ 800 ] = '800',
    }

    if char_last ~= '.' then
        suffix = suffix .. '.'
    end

    for sz, sz_name in pairs( font_sz ) do
        local calc_sz = sz * scale
        surface.CreateFont( suffix .. sz_name, { font = font, size = calc_sz } )
        for wg, wg_name in pairs( font_wgts ) do
            surface.CreateFont( suffix .. sz_name .. '.' .. wg_name, { font = font, size = calc_sz, weight = 600 } )
        end
    end
end

/*
*   ui :: html :: img :: full
*
*   returns an html element supporting outside images
*   typically used for ui backgrounds
*
*   @param  : tbl, str src
*   @param  : bool bRand
*   @return : str
*/

function ui:html_img_full( src, bRand )
    local resp = bRand and table.Random( src ) or isstring( src ) and src
    return [[
		<body style='overflow: hidden; height: auto; width: auto;'>
			<img src=']] .. resp .. [[' style='position: absolute; height: 100%; width: 100%; top: 0%; left: 0%; margin: auto;'>
		</body>
    ]]
end

/*
*   ui :: html :: img
*
*   returns an html element supporting outside images
*   typically used for ui backgrounds
*
*   @param  : tbl, str src
*   @param  : bool bRand
*   @return : str
*/

function ui:html_img( src, bRand )
    local resp = bRand and table.Random( src ) or isstring( src ) and src
    return [[
        <body style='overflow: hidden; height: 100%; width: 100%; margin:0px;'>
            <img width='100%' height='100%' src=']] .. resp .. [['>
        </body>
    ]]
end

/*
*   ui :: html :: size
*
*   returns an html element supporting outside images
*   allows for specific size to be provided
*
*   @param  : str src
*   @param  : int w
*   @param  : int h
*   @return : str
*/

function ui:html_img_sz( src, w, h )
    local resp = isstring( src ) and src or tostring( src )
    h = isnumber( h ) and h or w
    return [[
        <body style='overflow: hidden; height: 100%; width: 100%; margin:0px;'>
            <img width=']] .. w .. [[' height=']] .. h .. [[' src=']] .. resp .. [['>
        </body>
    ]]
end

/*
*   ui :: html :: iframe
*
*   returns an html element supporting outside sites
*   typically used for ui backgrounds / live wallpapers
*
*   @param  : tbl, str src
*   @param  : bool bRand
*   @return : str
*/

function ui:html_iframe( src, bRand )
    local resp = bRand and table.Random( src ) or isstring( src ) and src
    return [[
        <body style='overflow: hidden; height: 100%; width: 100%; margin:0px;'>
            <iframe width='100%' frameborder='0' height='100%' src=']] .. resp .. [['></iframe>
        </body>
    ]]
end

/*
*   ui :: get :: svg
*
*   utilized for svg resources
*
*   @param  : tbl, str src
*   @param  : bool bShow
*   @return : str
*/

function ui:getsvg( src, bShow )
    src = isstring( src ) and src or ''
    local display = not bShow and 'display:none;' or ''
    return [[
        <body style='overflow: hidden; height: 100%; width: 100%; margin:0px;]] .. display .. [['>
            <iframe width='100%' frameborder='0' height='100%' src=']] .. src .. [['></iframe>
        </body>
    ]]
end

/*
*   ui classes
*
*   credit to threebow for the idea as he utilized such a method in tdlib.
*   it makes creating new panels a lot more clean thanks to metatables
*
*   ive obviously made my own changes and taken a slightly different
*   direction, but the original idea is thanks to him
*
*   this dude is the apple to my pie; and the straw to my berry.
*
*   @source :   https://github.com/Threebow/tdlib
*/

local uclass = { }

    /*
    *   ui :: class :: Run
    *
    *   @param  : str name
    *   @param  : func fn
    */

    function uclass.run( pnl, name, fn )
        if not name then return end
        if not isfunction( fn ) then return end

        name = pnl.Override or name

        local orig = pnl[ name ]

        pnl[ name ] = function( s, ... )
            if isfunction( orig ) then orig( s, ... ) end
            fn( s, ... )
        end
    end

    /*
    *   ui :: class :: NoPaint
    */

    function uclass.nopaint( pnl )
        pnl.Paint = nil
    end
    uclass.nostyle    = uclass.nopaint
    uclass.nodraw     = uclass.nopaint

    /*
    *   ui :: class :: paint
    *
    *   @param  : func fn
    */

    function uclass.paint( pnl, fn )
        if not isfunction( fn ) then return end
        uclass.nopaint( pnl )
        pnl[ 'Paint' ] = fn
    end
    uclass.style      = uclass.paint
    uclass.draw       = uclass.paint

    /*
    *   ui :: class :: paint :: save
    *
    *   @param  : func fn
    */

    function uclass.savepaint( pnl )
        pnl.OldPaint = pnl.Paint
    end
    uclass.savedraw = uclass.savepaint

    /*
    *   ui :: class :: paint :: get
    *
    *   @param  : func fn
    */

    function uclass.getpaint( pnl )
        return pnl.OldPaint
    end
    uclass.getdraw = uclass.getpaint

    /*
    *   ui :: class :: SetPaintedManually
    *
    *   @param  : bool b
    */

    function uclass.paintmanual( pnl, b )
        pnl:SetPaintedManually( b )
    end
    uclass.drawmanual = uclass.paintmanual

    /*
    *   ui :: class :: Panel :: Name
    *
    *   @param  : str name
    */

    function uclass.name( pnl, name )
        if not name then return end
        pnl:SetName( name )
    end

    /*
    *   ui :: class :: Panel :: SetConVar
    *
    *   @param  : str cvar
    */

    function uclass.convar( pnl, cvar )
        cvar = isstring( cvar ) and cvar or ''
        pnl:SetConVar( cvar )
    end

    /*
    *   ui :: class :: Panel :: ConVarChanged
    *
    *   @param  : str val
    */

    function uclass.convar_chg( pnl, val )
        val = isstring( val ) and val or ''
        pnl:ConVarChanged( val )
    end

    /*
    *   ui :: class :: Panel :: ConVarNumberThink
    */

    function uclass.convar_think_int( pnl )
        pnl:ConVarNumberThink( )
    end

    /*
    *   ui :: class :: Panel :: ConVarStringThink
    */

    function uclass.convar_think_str( pnl )
        pnl:ConVarStringThink( )
    end

    /*
    *   ui :: class :: convarname
    *
    *   @alias  : cvar
    *
    *   @param  : str id
    */

    function uclass.cvar( pnl, id )
        id = isstring( id ) and id or ''
        pnl.convarname = id
    end

    /*
    *   ui :: class :: route
    *
    *   @alias  : route
    *
    *   @param  : str id
    *   @param  : mix data
    */

    function uclass.route( pnl, id, data )
        if not id then return end
        data = data or ''
        pnl[ id ] = data
    end

    /*
    *   ui :: class :: attach
    *
    *   @alias  : attach
    *
    *   @param  : pnl child
    */

    function uclass.attach( pnl, child )
        if not ui:valid( child ) then return end
        pnl:Attach( child )
    end

    /*
    *   ui :: class :: action
    *
    *   @alias  : action
    *
    *   @param  : func fn
    */

    function uclass.action( pnl, fn )
        if not isfunction( fn ) then return end
        pnl:SetAction( fn )
    end

    /*
    *   ui :: class :: slider :: barcolor
    *
    *   @alias  : clr_bar
    *
    *   @param  : clr clr
    */

    function uclass.clr_bar( pnl, clr )
        if not clr then return end
        pnl.BarColor = clr
    end

    /*
    *   ui :: class :: paint :: over
    *
    *   @alias  : paintover, drawover, po
    *
    *   @param  : func fn
    */

    function uclass.paintover( pnl, fn )
        if not isfunction( fn ) then return end
        pnl[ 'PaintOver' ] = fn
    end
    uclass.drawover   = uclass.paintover
    uclass.po         = uclass.paintover

    /*
    *   ui :: class :: paint :: box
    *
    *   @alias  : paintbox, box, drawbox, pb
    *
    *   @param  : clr clr
    *   @param  : int x
    *   @param  : int y
    *   @param  : int w
    *   @param  : int h
    */

    function uclass.paintbox( pnl, clr, x, y, w, h )
        clr = IsColor( clr ) and clr or Color( 25, 25, 25, 255 )
        x   = isnumber( x ) and x or 0
        y   = isnumber( y ) and y or 0

        local sz_w   = isnumber( w ) and w or 0
        local sz_h   = isnumber( h ) and h or 0

        uclass.nopaint( pnl )
        pnl[ 'Paint' ] = function( s, w2, h2 )
            local def_w = ( sz_w ~= 0 and sz_w ) or w2
            local def_h = ( sz_h ~= 0 and sz_h ) or h2

            design.box( x, y, def_w, def_h, clr )
        end
    end
    uclass.box        = uclass.paintbox
    uclass.drawbox    = uclass.paintbox
    uclass.pb         = uclass.paintbox

    /*
    *   ui :: class :: paint :: entry
    *
    *   @alias  : paintentry, drawentry, pe
    *
    *   @param  : clr clr_text
    *   @param  : clr clr_cur
    *   @param  : clr clr_hl
    */

    function uclass.paintentry( pnl, clr_text, clr_cur, clr_hl )
        clr_text    = IsColor( clr_text ) and clr_text or Color( 255, 255, 255, 255 )
        clr_cur     = IsColor( clr_cur ) and clr_cur or Color( 150, 150, 150, 255 )
        clr_hl      = IsColor( clr_hl ) and clr_hl or Color( 25, 25, 25, 255 )

        pnl[ 'Paint' ] = function( s, w, h )
            s:SetTextColor      ( clr_text      )
            s:SetCursorColor    ( clr_cur       )
            s:SetHighlightColor ( clr_hl        )
            s:DrawTextEntryText ( s:GetTextColor( ), s:GetHighlightColor( ), s:GetCursorColor( ) )
        end
    end
    uclass.drawentry  = uclass.paintentry
    uclass.pe         = uclass.paintentry

    /*
    *   ui :: class :: paint :: rounded box
    *
    *   @alias  : paintrbox, drawrbox, rbox, prb
    *
    *   @param  : clr clr
    *   @param  : int x
    *   @param  : int y
    *   @param  : int w
    *   @param  : int h
    */

    function uclass.paintrbox( pnl, clr, r, x, y, w, h )
        clr = IsColor( clr ) and clr or Color( 25, 25, 25, 255 )
        r   = isnumber( r ) and r or 4
        x   = isnumber( x ) and x or 0
        y   = isnumber( y ) and y or 0

        local sz_w   = isnumber( w ) and w or 0
        local sz_h   = isnumber( h ) and h or 0

        uclass.nopaint( pnl )
        pnl[ 'Paint' ] = function( s, w2, h2 )
            local def_w = ( sz_w ~= 0 and sz_w ) or w2
            local def_h = ( sz_h ~= 0 and sz_h ) or h2

            design.rbox( r, x, y, def_w, def_h, clr )
        end
    end
    uclass.drawrbox   = uclass.paintrbox
    uclass.rbox       = uclass.paintrbox
    uclass.prb        = uclass.paintrbox

    /*
    *   ui :: class :: debug :: where
    *
    *   applies a simple painted box to the specified element to determine
    *   location on the screen
    *
    *   @alias  : debug_where, where
    *
    *   @param  : clr clr
    */

    function uclass.debug_where( pnl, clr )
        clr = IsColor( clr ) and clr or Color( 255, 255, 255, 255 )

        uclass.nopaint( pnl )
        pnl[ 'PaintOver' ] = function( s, w, h )
            design.box( 0, 0, w, h, clr )
        end
    end
    uclass.where = uclass.debug_where

    /*
    *   ui :: class :: PerformLayout
    *
    *   @alias  : performlayout, pl
    *
    *   @param  : func fn
    */

    function uclass.performlayout( pnl, fn )
        if not isfunction( fn ) then return end

        local name = 'PerformLayout'
        local orig = pnl[ name ]

        pnl[ name ] = function( s, ... )
            if isfunction( orig ) then orig( s, ... ) end
            fn( s, ... )
        end
    end
    uclass.pl         = uclass.performlayout

    /*
    *   ui :: class :: onclick
    *
    *   @alias  : onclick, oc
    *
    *   @param  : func fn
    */

    function uclass.onclick( pnl, fn )
        if not isfunction( fn ) then return end

        local name = 'DoClick'
        local orig = pnl[ name ]

        pnl[ name ] = function( s, ... )
            if isfunction( orig ) then orig( s, ... ) end
            fn( s, ... )
        end
    end
    uclass.oc         = uclass.onclick

    /*
    *   ui :: class :: onclick :: rem
    *
    *   @alias  : onclick_r, ocr, click_r
    *
    *   @param  : pnl panel
    *   @param  : bool bHide
    */

    function uclass.onclick_r( pnl, panel, bHide )
        pnl[ 'DoClick' ] = function( s, ... )
            if not ui:valid( panel ) then return end
            if bHide then
                ui:hide( panel )
            else
                ui:destroy( panel )
            end
        end
    end
    uclass.ocr        = uclass.onclick_r
    uclass.click_r    = uclass.onclick_r

    /*
    *   ui :: class :: onclick :: rem visible
    *
    *   @alias  : onclick_rv, ocrv
    *
    *   @param  : pnl panel
    *   @param  : bool bHide
    */

    function uclass.onclick_rv( pnl, panel, bHide )
        pnl[ 'DoClick' ] = function( s, ... )
            if not ui:valid( panel ) then return end
            if bHide then
                ui:hide( panel )
            else
                ui:destroy_visible( panel )
            end
        end
    end
    uclass.ocrv       = uclass.onclick_rv

    /*
    *   ui :: class :: onremove
    *
    *   @alias  : onremove, remove, orem
    *
    *   @param  : func fn
    */

    function uclass.onremove( pnl, fn )
        if not isfunction( fn ) then return end

        local name = 'OnRemove'
        local orig = pnl[ name ]

        pnl[ name ] = function( s, ... )
            if isfunction( orig ) then orig( s, ... ) end
            fn( s, ... )
        end
    end
    uclass.remove     = uclass.onremove
    uclass.orem       = uclass.onremove

    /*
    *   ui :: class :: OnTextChanged
    *
    *   @alias  : ontxtchg, otch
    *
    *   @param  : func fn
    */

    function uclass.ontxtchg( pnl, fn )
        if not isfunction( fn ) then return end

        local name = 'OnTextChanged'
        local orig = pnl[ name ]

        pnl[ name ] = function( s, ... )
            if isfunction( orig ) then orig( s, ... ) end
            fn( s, ... )
        end
    end
    uclass.otch       = uclass.ontxtchg

    /*
    *   ui :: class :: noedit
    *
    *   supplying bUseForce will automatically reset text each time text changed.
    *   used as a workaround for times when SetEditable simply doesnt work.
    *
    *   if bUseForce = true, src contains original text to replace box with
    *
    *   @alias  : noedit, tlock
    *
    *   @param  : func fn
    *   @param  : str src
    *   @param  : bool bUseForce
    */

    function uclass.noedit( pnl, bUseForce, src )
        if not bUseForce then
            pnl:SetEditable( false )
            return
        end
        pnl[ 'OnTextChanged' ] = function( s, ... )
            if not isstring( src ) then return end
            s:SetText( src )
        end
    end
    uclass.tlock  = uclass.noedit

    /*
    *   ui :: class :: openurl
    *
    *   @alias  : openurl, ourl
    *
    *   @param  : str uri
    */

    function uclass.openurl( pnl, uri )
        if not isstring( uri ) then return end
        pnl[ 'DoClick' ] = function( s )
            gui.OpenURL( uri )
        end
    end
    uclass.ourl   = uclass.openurl

    /*
    *   ui :: class :: OnSelect
    *
    *   @alias  : onselect, osel
    *
    *   @param  : func fn
    */

    function uclass.onselect( pnl, fn )
        if not isfunction( fn ) then return end

        local name = 'OnSelect'
        local orig = pnl[ name ]

        pnl[ name ] = function( s, ... )
            if isfunction( orig ) then orig( s, ... ) end
            fn( s, ... )
        end
    end
    uclass.osel = uclass.onselect

    /*
    *   ui :: class :: DComboBox :: doclick
    *
    *   @alias  : cboclick, odc
    *
    *   @param  : func fn
    */

    function uclass.cboclick( pnl, fn )
        if not isfunction( fn ) then return end

        pnl[ 'DoClick' ] = function( s, ... )
            if s:IsMenuOpen( ) then return s:CloseMenu( ) end
            fn( s, ... )
        end
    end
    uclass.odc = uclass.cboclick

    /*
    *   ui :: class :: DComboBox :: OpenMenu
    *
    *   @alias  : omenu
    *
    *   @param  : func fn
    */

    function uclass.omenu( pnl, fn )
        if not isfunction( fn ) then return end

        local name = 'OpenMenu'
        local orig = pnl[ name ]

        pnl[ name ] = function( ... )
            if isfunction( orig ) then orig( ... ) end
            fn( ... )
        end
    end

    /*
    *   ui :: class :: DTextEntry :: m_bLoseFocusOnClickAway
    *
    *   @alias  : onclick_nofocus, ocnf
    *
    *   @param  : bool b
    */

    function uclass.onclick_nofocus( pnl, b )
        pnl.m_bLoseFocusOnClickAway = b or false
    end
    uclass.ocnf = uclass.onclick_nofocus

    /*
    *   ui :: class :: OnGetFocus
    *
    *   @alias  : ongetfocus, ogfo, getfocus
    *
    *   @param  : func fn
    */

    function uclass.ongetfocus( pnl, fn )
        if not isfunction( fn ) then return end

        local name = 'OnGetFocus'
        local orig = pnl[ name ]

        pnl[ name ] = function( s, ... )
            if isfunction( orig ) then orig( s, ... ) end
            fn( s, ... )
        end
    end
    uclass.ogfo       = uclass.ongetfocus
    uclass.getfocus   = uclass.ongetfocus

    /*
    *   ui :: class :: DNum :: OnValueChanged
    *
    *   @alias  : onvaluechanged, ovc
    *
    *   @param  : func fn
    */

    function uclass.onvaluechanged( pnl, fn )
        if not isfunction( fn ) then return end

        local name = 'OnValueChanged'
        local orig = pnl[ name ]

        pnl[ name ] = function( s, ... )
            if isfunction( orig ) then orig( s, ... ) end
            fn( s, ... )
        end
    end
    uclass.ovc = uclass.onvaluechanged

    /*
    *   ui :: class :: DTextEntry :: OnChange
    *
    *   @alias  : onchange, ochg
    *
    *   @param  : func fn
    */

    function uclass.onchange( pnl, fn )
        if not isfunction( fn ) then return end
        pnl[ 'OnChange' ] = fn
    end
    uclass.ochg = uclass.onchange

    /*
    *   ui :: class :: onOptionChanged
    *
    *   @alias  : onoptchange, ooc
    *
    *   @param  : func fn
    */

    function uclass.onoptchange( pnl, fn )
        if not isfunction( fn ) then return end

        local name = 'onOptionChanged'
        local orig = pnl[ name ]

        pnl[ name ] = function( s, ... )
            if isfunction( orig ) then orig( s, ... ) end
            fn( s, ... )
        end
    end
    uclass.ooc = uclass.onoptchange

    /*
    *   ui :: class :: enabled :: check
    *
    *   @alias  : enabled_chk, echk
    *
    *   @param  : func fn
    */

    function uclass.enabled_chk( pnl, fn )
        if not isfunction( fn ) then return end

        local name = 'enabled'
        local orig = pnl[ name ]

        pnl[ name ] = function( s, ... )
            if isfunction( orig ) then orig( s, ... ) end
            fn( s, ... )
        end
    end
    uclass.echk = uclass.enabled_chk

    /*
    *   ui :: class :: onclose
    *
    *   @alias  : onclose
    *
    *   @param  : func fn
    */

    function uclass.onclose( pnl, fn )
        if not isfunction( fn ) then return end

        local name = 'OnClose'
        local orig = pnl[ name ]

        pnl[ name ] = function( s, ... )
            if isfunction( orig ) then orig( s, ... ) end
            fn( s, ... )
        end
    end

    /*
    *   ui :: class :: think
    *
    *   @alias  : think, logic
    *
    *   @param  : func fn
    */

    function uclass.think( pnl, fn )
        if not isfunction( fn ) then return end

        local name = 'Think'
        local orig = pnl[ name ]

        pnl[ name ] = function( s, ... )
            if isfunction( orig ) then orig( s, ... ) end
            fn( s, ... )
        end
    end
    uclass.logic = uclass.think

    /*
    *   ui :: class :: DModelPanel :: norotate
    *
    *   forces dmodelpanel to not auto-rotate the model
    *
    *   @alias  : norotate
    */

    function uclass.norotate( pnl )
        pnl[ 'LayoutEntity' ] = function( s, ... ) return end
    end

    /*
    *   ui :: class :: DModelPanel :: LayoutEntity
    *
    *   @alias  : norotate, le
    */

    function uclass.layoutent( pnl, fn )
        if not isfunction( fn ) then return end

        local name = 'LayoutEntity'
        local orig = pnl[ name ]

        pnl[ name ] = function( s, ... )
            if isfunction( orig ) then orig( s, ... ) end
            fn( s, ... )
        end
    end
    uclass.le = uclass.layoutent

    /*
    *   ui :: class :: DModelPanel :: onmousepress
    *
    *   rerouted action to define particular mouse definitions
    *
    *   @alias  : onmouse, omp
    */

    function uclass.onmouse( pnl )
        pnl[ 'OnMousePressed' ] = function( s, act )
            if pnl:IsHovered( ) or s.hover then
                if act == MOUSE_LEFT and pnl.DoClick then pnl:DoClick( ) end
                if act == MOUSE_RIGHT and pnl.DoRightClick then pnl:DoRightClick( ) end
                if act == MOUSE_MIDDLE and pnl.DoMiddleClick  then pnl:DoMiddleClick( ) end
            end
        end
    end
    uclass.omp            = uclass.onmouse

    /*
    *   ui :: class :: Dock
    *
    *   @alias  : dock, static
    *
    *   @param  : int pos
    */

    function uclass.dock( pnl, pos )
        pos = ( type( pos ) == 'number' and pos ) or ( dock_align[ pos ] ) or FILL
        pnl:Dock( pos )
    end
    uclass.static = uclass.dock

    /*
    *   ui :: class :: Dock :: left
    *
    *   @alias  : left
    */

    function uclass.left( pnl )
        pnl:Dock( LEFT )
    end

    /*
    *   ui :: class :: Dock :: top
    *
    *   @alias  : top
    */

    function uclass.top( pnl )
        pnl:Dock( TOP )
    end

    /*
    *   ui :: class :: Dock :: right
    *
    *   @alias  : right
    */

    function uclass.right( pnl )
        pnl:Dock( RIGHT )
    end

    /*
    *   ui :: class :: Dock :: bottom
    *
    *   @alias  : bottom
    */

    function uclass.bottom( pnl )
        pnl:Dock( BOTTOM )
    end

    /*
    *   ui :: class :: Dock :: fill
    *
    *   @alias  : fill
    */

    function uclass.fill( pnl )
        pnl:Dock( FILL )
    end

    /*
    *   ui :: class :: Dock, DockMargin
    *
    *   @alias  : docker, docker_m
    *
    *   @param  : int pos
    *   @param  : int il
    *   @param  : int it
    *   @param  : int ir
    *   @param  : int ib
    */

    function uclass.docker( pnl, pos, il, it, ir, ib )
        pos = ( type( pos ) == 'number' and pos ) or ( dock_align[ pos ] ) or FILL

        il = isnumber( il ) and il or 0

        if not it then it, ir, ib = il, il, il end
        if not ir then ir, ib = it, it end
        if not ib then ib = ir end

        pnl:Dock( pos )
        pnl:DockMargin( il, it, ir, ib )
    end
    uclass.docker_m = uclass.docker

    /*
    *   ui :: class :: Dock, DockPadding
    *
    *   @alias  : docker_p
    *
    *   @param  : int pos
    *   @param  : int il
    *   @param  : int it
    *   @param  : int ir
    *   @param  : int ib
    */

    function uclass.docker_p( pnl, pos, il, it, ir, ib )
        pos = ( type( pos ) == 'number' and pos ) or ( dock_align[ pos ] ) or FILL

        il = isnumber( il ) and il or 0

        if not it then it, ir, ib = il, il, il end
        if not ir then ir, ib = it, it end
        if not ib then ib = ir end

        pnl:Dock( pos )
        pnl:DockPadding( il, it, ir, ib )
    end

    /*
    *   ui :: class :: DockPadding
    *
    *   @alias  : padding, dock_p
    *
    *   @param  : int il
    *   @param  : int it
    *   @param  : int ir
    *   @param  : int ib
    */

    function uclass.padding( pnl, il, it, ir, ib )
        il = isnumber( il ) and il or 0

        if not it then it, ir, ib = il, il, il end
        if not ir then ir, ib = it, it end
        if not ib then ib = ir end

        pnl:DockPadding( il, it, ir, ib )
    end
    uclass.dock_p = uclass.padding

    /*
    *   ui :: class :: DockMargin
    *
    *   @alias  : margin, dock_m
    *
    *   @param  : int il
    *   @param  : int it
    *   @param  : int ir
    *   @param  : int ib
    */

    function uclass.margin( pnl, il, it, ir, ib )
        il = isnumber( il ) and il or 0

        if not it then it, ir, ib = il, il, il end
        if not ir then ir, ib = it, it end
        if not ib then ib = ir end

        pnl:DockMargin( il, it, ir, ib )
    end
    uclass.dock_m = uclass.margin

    /*
    *   ui :: class :: Panel :: SetPadding
    *
    *   @alias  : offset, oset
    *
    *   @param  : int i
    */

    function uclass.offset( pnl, i )
        i = isnumber( i ) and i or 0
        pnl:SetPadding( i )
    end
    uclass.oset = uclass.offset

    /*
    *   ui :: class :: SetWide
    *
    *   @alias  : wide, width
    *
    *   @param  : int w
    */

    function uclass.wide( pnl, w, err )
        if isstring( w ) and w == 'screen' then
            pnl:SetWide( ScrW( ) )
            return
        end

        w = isnumber( w ) and w or 25
        pnl:SetWide( w )
    end
    uclass.width  = uclass.wide

    /*
    *   ui :: class :: SetMinWidth
    *
    *   @alias  : minwide, wmin
    *
    *   @param  : int w
    */

    function uclass.minwide( pnl, w )
        w = isnumber( w ) and w or 30
        pnl:SetMinWidth( w )
    end
    uclass.wmin = uclass.minwide

    /*
    *   ui :: class :: SetTall
    *
    *   @alias  : tall, height
    *
    *   @param  : int h
    */

    function uclass.tall( pnl, h )
        if isstring( h ) and h == 'screen' then
            pnl:SetTall( ScrH( ) )
            return
        end

        h = isnumber( h ) and h or 25
        pnl:SetTall( h )
    end
    uclass.height = uclass.tall

    /*
    *   ui :: class :: SetMinHeight
    *
    *   @alias  : mintall, hmin
    *
    *   @param  : int h
    */

    function uclass.mintall( pnl, h )
        h = isnumber( h ) and h or 30
        pnl:SetMinHeight( h )
    end
    uclass.hmin = uclass.mintall

    /*
    *   ui :: class :: SetSize
    *
    *   term 'scr' || w, h blank        : autosize fullscreen based on resolution
    *   term 'scr'                      : autosize one particular dimension to full monitor resolution
    *
    *   @alias  : size, sz
    *
    *   @param  : int w, str
    *   @param  : int h, str
    */

    function uclass.size( pnl, w, h )
        if not w or ( isstring( w ) and ( ( w == 'screen' ) or ( w == 'scr' ) ) ) then
            pnl:SetSize( ScrW( ), ScrH( ) )
            return
        end
        w = ( isnumber( w ) and w ) or ( isstring( w ) and ( w == 'screen' or w == 'scr' ) and ScrW( ) ) or 25
        h = ( isnumber( h ) and h ) or ( isstring( h ) and ( h == 'screen' or h == 'scr' ) and ScrH( ) ) or w
        pnl:SetSize( w, h )
    end
    uclass.sz = uclass.size

    /*
    *   ui :: class :: SetPos
    *
    *   @alias  : pos
    *
    *   @param  : int x
    *   @param  : int y
    */

    function uclass.pos( pnl, x, y )
        x = isnumber( x ) and x or 0
        y = isnumber( y ) and y or isnumber( x ) and x or 0
        pnl:SetPos( x, y )
    end

    /*
    *   ui :: class :: SetSpaceX
    *
    *   @alias  : space_x
    *
    *   @param  : int i
    */

    function uclass.space_x( pnl, i )
        i = isnumber( i ) and i or 0
        pnl:SetSpaceX( i )
    end

    /*
    *   ui :: class :: SetSpaceY
    *
    *   @alias  : space_y
    *
    *   @param  : int i
    */

    function uclass.space_y( pnl, i )
        i = isnumber( i ) and i or 0
        pnl:SetSpaceY( i )
    end

    /*
    *   ui :: class :: SetSpaceX, SetSpaceY
    *
    *   @alias  : spacing, space_xy
    *
    *   @param  : int x
    *   @param  : int y
    */

    function uclass.spacing( pnl, x, y )
        x = isnumber( x ) and x or 0
        y = isnumber( y ) and y or isnumber( x ) and x or 0
        pnl:SetSpaceX( x )
        pnl:SetSpaceY( y )
    end
    uclass.space_xy = uclass.spacing

    /*
    *   ui :: class :: DIconLayout :: SetLayoutDir
    *
    *   sets the direction that it will be layed out, using the DOCK_ Enums.
    *   currently only TOP and LEFT are supported.
    *
    *   @alias  : lodir, lod
    *
    *   @param  : int enum
    */

    function uclass.lodir( pnl, enum )
        enum = isnumber( enum ) and enum or LEFT
        pnl:SetLayoutDir( enum )
    end
    uclass.lod    = uclass.lodir

    /*
    *   ui :: class :: SetColor
    *
    *   @alias  : clr, color
    *
    *   @param  : clr clr
    */

    function uclass.clr( pnl, clr )
        clr = IsColor( clr ) and clr or Color( 255, 255, 255, 255 )
        pnl:SetColor( clr )
    end
    uclass.color = uclass.clr

    /*
    *   ui :: class :: DTextEntry :: SetCursorColor
    *
    *   @alias  : cursorclr, cclr
    *
    *   @param  : clr clr
    */

    function uclass.cursorclr( pnl, clr )
        clr = IsColor( clr ) and clr or Color( 255, 255, 255, 255 )
        pnl:SetCursorColor( clr )
    end
    uclass.cclr = uclass.cursorclr

    /*
    *   ui :: class :: DTextEntry :: SetHighlightColor
    *
    *   @alias  : highlightclr, hlclr
    *
    *   @param  : clr clr
    */

    function uclass.highlightclr( pnl, clr )
        clr = IsColor( clr ) and clr or Color( 255, 255, 255, 255 )
        pnl:SetHighlightColor( clr )
    end
    uclass.hlclr = uclass.highlightclr

    /*
    *   ui :: class :: Panel :: CursorPos
    *
    *   @alias  : cursorpos, cpos
    */

    function uclass.cursorpos( pnl )
        pnl:CursorPos( )
    end
    uclass.cpos = uclass.cursorpos

    /*
    *   ui :: class :: Panel :: SetSteamID
    *
    *   @alias  : steamid, sid
    *
    *   @param  : int sid
    *             64bit SteamID of the player to load avatar of
    *
    *   @param  : int size
    *             Size of the avatar to use. Acceptable sizes are 32, 64, 184.
    */

    function uclass.steamid( pnl, sid, size )
        pnl:SetSteamID( sid, size )
    end
    uclass.sid = uclass.steamid

    /*
    *   ui :: class :: Panel :: SetCursor
    *
    *   @alias  : cursor, cur
    *
    *   @param  : str str
    */

    function uclass.cursor( pnl, str )
        str = isstring( str ) and str or 'none'
        pnl:SetCursor( str )
    end
    uclass.cur = uclass.cursor

    /*
    *   ui :: class :: Panel :: SetCursorColor
    *
    *   @alias  : cursor_clr, curclr
    *
    *   @param  : clr clr
    */

    function uclass.cursor_clr( pnl, clr )
        clr = IsColor( clr ) and clr or Color( 255, 255, 255, 255 )
        pnl:SetCursorColor( clr )
    end
    uclass.curclr = uclass.setcursor_clr

    /*
    *   ui :: class :: Panel :: SetCursorColor, SetCursor
    *
    *   @param  : clr clr
    *   @param  : str str
    */

    function uclass.setcursor( pnl, clr, str )
        clr = IsColor( clr ) and clr or Color( 255, 255, 255, 255 )
        str = isstring( str ) and str or 'none'
        pnl:SetCursorColor( clr )
        pnl:SetCursor( str )
    end
    uclass.scur = uclass.setcursor

    /*
    *   ui :: class :: DHTML :: SetScrollbars
    *
    *   @param  : bool b
    */

    function uclass.sbar( pnl, b )
        pnl:SetScrollbars( b or false )
    end

    /*
    *   ui :: class :: DTextEntry, RichText :: SetVerticalScrollbarEnabled
    *
    *   @param  : bool b
    */

    function uclass.vsbar( pnl, b )
        pnl:SetVerticalScrollbarEnabled( b or false )
    end

    /*
    *   ui :: class :: DTextEntry, RichText :: SetVerticalScrollbarEnabled
    *
    *   @param  : bool b
    */

    function uclass.noscroll( pnl )
        pnl:SetVerticalScrollbarEnabled( false )
    end

    /*
    *   ui :: class :: Panel :: SetMultiline
    *
    *   @param  : bool b
    */

    function uclass.multiline( pnl, b )
        pnl:SetMultiline( b or false )
    end
    uclass.mline = uclass.multiline

    /*
    *   ui :: class :: Panel :: focus
    */

    function uclass.focus( pnl )
        pnl:RequestFocus( )
    end

    /*
    *   ui :: class :: OnFocusChanged
    *
    *   @param  : func fn
    */

    function uclass.onfocuschg( pnl, fn )
        if not isfunction( fn ) then return end
        pnl[ 'OnFocusChanged' ] = fn
    end
    uclass.focuschg = uclass.onfocuschg

    /*
    *   ui :: class :: DTextEntry :: SetEditable
    *
    *   @param  : bool b
    */

    function uclass.canedit( pnl, b )
        pnl:SetEditable( b or false )
    end
    uclass.editable = uclass.canedit

    /*
    *   ui :: class :: DTextEntry :: OnEnter
    *
    *   @param  : func fn
    */

    function uclass.onenter( pnl, fn )
        local name = 'OnEnter'
        local orig = pnl[ name ]

        pnl[ name ] = function( s, ... )
            if isfunction( orig ) then orig( s, ... ) end
            fn( s, ... )
        end
    end

    /*
    *   ui :: class :: DProgress :: SetFraction
    *
    *   @param  : int i
    */

    function uclass.fraction( pnl, i )
        i = isnumber( i ) and i or 1
        pnl:SetFraction( i )
    end
    uclass.frac = uclass.fraction

    /*
    *   ui :: class :: DLabel, DTextEntry :: SetFont
    *
    *   @param  : str str
    */

    function uclass.setfont( pnl, str )
        str = isstring( str ) and str or pid( 'sys.entry.default' )
        pnl:SetFont( str )
    end
    uclass.font = uclass.setfont

    /*
    *   ui :: class :: Panel :: SizeToChildren
    *
    *   resizes the panel to fit the bounds of its children
    *
    *   panel must have its layout updated (Panel:InvalidateLayout) for this function to work properly
    *   size_w and size_h parameters are false by default. calling this function with no arguments will result in a no-op.
    *
    *   @param  : int w
    *           : adjust width of pnl
    *
    *   @param  : int h
    *           : adjust height of pnl
    */

    function uclass.autosize_child( pnl, w, h )
        pnl:SizeToChildren( w, h )
    end
    uclass.aszch = uclass.autosize_child

    /*
    *   ui :: class :: Panel :: SizeToContents
    *
    *   resizes the panel so that its width and height fit all of the content inside
    *
    *   must call AFTER setting text/font or adjusting child panels
    */

    function uclass.autosize( pnl )
        pnl:SizeToContents( )
    end
    uclass.asz    = uclass.autosize
    uclass.autosz = uclass.autosize

    /*
    *   ui :: class :: Panel :: SizeToContentsX
    *
    *   resizes the panel objects width to accommodate all child objects/contents
    *
    *   only works on Label derived panels such as DLabel by default, and on any 
    *   panel that manually implemented Panel:GetContentSize method.
    *
    *   must call AFTER setting text/font or adjusting child panels
    *
    *   @param  : int val
    *           : number of extra pixels to add to the width. Can be a negative number, to reduce the width.
    */

    function uclass.autosize_x( pnl, val )
        val = isnumber( val ) and val or 0
        pnl:SizeToContentsX( val )
    end
    uclass.asz_x      = uclass.autosize_x
    uclass.autosz_x   = uclass.autosize_x

    /*
    *   ui :: class :: Panel :: SizeToContentsY
    *
    *   resizes the panel object's height to accommodate all child objects/contents
    *
    *   only works on Label derived panels such as DLabel by default, and on any 
    *   panel that manually implemented Panel:GetContentSize method
    *
    *   must call AFTER setting text/font or adjusting child panels
    *
    *   @param  : int val
    *           : number of extra pixels to add to the height. Can be a negative number, to reduce the height
    */

    function uclass.autosize_y( pnl, val )
        val = isnumber( val ) and val or 0
        pnl:SizeToContentsY( val )
    end
    uclass.asz_y      = uclass.autosize_y
    uclass.autosz_y   = uclass.autosize_y

    /*
    *   ui :: class :: Panel :: SizeTo
    *
    *   uses animation to resize the panel to the specified size
    *
    *   @param  : int w
    *           : arget width of the panel. Use -1 to retain the current width
    *
    *   @param  : int h
    *           : target height of the panel. Use -1 to retain the current height
    *
    *   @param  : int time
    *           : time to perform the animation within
    *
    *   @param  : int delay
    *           : delay before the animation starts
    *
    *   @param  : int ease
    *           : easing of the start and/or end speed of the animation. See Panel:NewAnimation for how this works
    *
    *   @param  : fn cb
    *           : function to be called once the animation finishes. Arguments are:
    *               ( tbl ) : animData - The AnimationData structure that was used
    *               ( pnl ) : panel object that was resized
    */

    function uclass.tosize( pnl, w, h, time, delay, ease, cb )
        pnl:SizeTo( w, h, time, delay, ease, cb )
    end
    uclass.tosz = uclass.tosize

    /*
    *   ui :: class :: Panel :: SetContentAlignment
    *
    *   sets the alignment of the contents
    *
    *   @param  : int int
    *           : direction of the content, based on the number pad.
    *
    *               1   : bottom-left
    *               2   : bottom-center
    *               3   : bottom-right
    *               4   : middle-left
    *               5   : center
    *               6   : middle-right
    *               7   : top-left
    *               8   : top-center
    *               9   : top-right
    */

    function uclass.align( pnl, int )
        int = isnumber( int ) and int or 4
        pnl:SetContentAlignment( int )
    end

    /*
    *   ui :: class :: Panel :: AlignTop
    *
    *   aligns the panel on the top of its parent with the specified offset
    *
    *   @param  : int int
    *           : align offset
    */

    function uclass.aligntop( pnl, int )
        int = isnumber( int ) and int or 0
        pnl:AlignTop( int )
    end

    /*
    *   ui :: class :: Panel :: AlignBottom
    *
    *   aligns the panel on the bottom of its parent with the specified offset
    *
    *   @param  : int int
    *           : align offset
    */

    function uclass.alignbottom( pnl, int )
        int = isnumber( int ) and int or 0
        pnl:AlignBottom( int )
    end

    /*
    *   ui :: class :: Panel :: AlignLeft
    *
    *   aligns the panel on the left of its parent with the specified offset
    *
    *   @param  : int int
    *           : align offset
    */

    function uclass.alignleft( pnl, int )
        int = isnumber( int ) and int or 0
        pnl:AlignLeft( int )
    end

    /*
    *   ui :: class :: Panel :: AlignRight
    *
    *   aligns the panel on the right of its parent with the specified offset
    *
    *   @param  : int int
    *           : align offset
    */

    function uclass.alignright( pnl, int )
        int = isnumber( int ) and int or 0
        pnl:AlignRight( int )
    end

    /*
    *   ui :: class :: Panel :: LocalToScreen
    *
    *   absolute screen position of the position specified relative to the panel.
    *
    *   @param  : int x
    *           : x coordinate of the position on the panel to translate
    *
    *   @param  : int y
    *           : y coordinate of the position on the panel to translate
    */

    function uclass.local2scr( pnl, x, y )
        x = isnumber( x ) and x or 0
        y = isnumber( y ) and y or 0
        pnl:LocalToScreen( x, y )
    end
    uclass.l2s = uclass.local2scr

    /*
    *   ui :: class :: Panel :: ScreenToLocal
    *
    *   translates global screen coordinate to coordinates relative to the panel
    *
    *   @param  : int x
    *           : x coordinate of the screen position to be translated
    *
    *   @param  : int y
    *           : y coordinate of the screed position be to translated
    */

    function uclass.scr2local( pnl, x, y )
        x = isnumber( x ) and x or 0
        y = isnumber( y ) and y or 0
        pnl:ScreenToLocal( x, y )
    end
    uclass.s2l = uclass.scr2local

    /*
    *   ui :: class :: Panel :: SetDrawOnTop
    *
    *   @param  : bool b
    *           : whether or not to draw the panel in front of all others
    */

    function uclass.drawtop( pnl, b )
        pnl:SetDrawOnTop( b or false )
    end

    /*
    *   ui :: class :: DHTML :: SetHTML
    *
    *   set HTML code within a panel
    *
    *   @param  : str str
    *           : html code to set
    */

    function uclass.html( pnl, str )
        pnl:SetHTML( str )
    end

    /*
    *   ui :: class :: DHTML :: AddressBar
    *
    *   sets the address bar for a dhtml panel
    *
    *   @param  : str str
    *           : address to set
    */

    function uclass.addr( pnl, addr )
        if not ui:valid( pnl.AddressBar ) then return end
        pnl.AddressBar:SetText( addr )
    end

    /*
    *   ui :: class :: DHTML :: SetHTML
    *
    *   sets html code in DHTML pnl to display a full-size img from an external site
    *
    *   @param  : str str
    *           : html code to set
    */

    function uclass.imgsrc( pnl, str )
        local code = ui:html_img( str )
        pnl:SetHTML( code )
    end

    /*
    *   ui :: class :: svg
    *
    *   loads an outside svg file
    *   typically used for stats
    *
    *   @param  : str src
    *           : html code to set
    */

    function uclass.svg( pnl, src, bShow )
        src = isstring( src ) and src or ''
        local html = ui:getsvg( src, bShow )
        pnl:SetHTML( html )
    end

    /*
    *   ui :: class :: Panel :: CenterHorizontal
    *
    *   centers the panel horizontally with specified fraction
    *
    *   @param  : flt flt
    *           : center fraction.
    */

    function uclass.center_h( pnl, flt )
        flt = isnumber( flt ) and flt or 0.5
        pnl:CenterHorizontal( flt )
    end

    /*
    *   ui :: class :: Panel :: CenterVertical
    *
    *   centers the panel vertically with specified fraction
    *
    *   @param  : flt flt
    *           : center fraction.
    */

    function uclass.center_v( pnl, flt )
        flt = isnumber( flt ) and flt or 0.5
        pnl:CenterVertical( flt )
    end

    /*
    *   ui :: class :: DTextEntry, DLabel :: SetTextColor
    *
    *   sets the text color of the DLabel. This will take precedence 
    *   over DLabel:SetTextStyleColor
    *
    *   @param  : clr clr
    *           : text color. Uses the Color structure.
    */

    function uclass.textclr( pnl, clr )
        clr = IsColor( clr ) and clr or Color( 255, 255, 255, 255 )
        pnl:SetTextColor( clr )

        pnl[ 'Think' ] = function( s, ... )
            s:SetTextColor( clr )
        end
    end

    /*
    *   ui :: class :: DLabel :: SetText
    *
    *   sets the text value of a panel object containing text, such as a Label,
    *   TextEntry or RichText and their derivatives, such as DLabel, DTextEntry or DButton
    *
    *   @param  : str str
    *           : text value to set.
    *
    *   @param  : bool bautosz
    *           : enables SizeToContents( )
    */

    function uclass.text( pnl, str, bautosz )
        str = isstring( str ) and str or ''
        pnl:SetText( str )
        if bautosz then
            pnl:SizeToContents( )
        end
    end

    /*
    *   ui :: class :: DLabel :: SetText, SetTextColor
    *
    *   set text clr, font, and string
    *
    *   @param  : clr clr
    *           : text color. Uses the Color structure
    *
    *   @param  : str font
    *           : font of the label
    *
    *   @param  : str text
    *           : text to display
    *
    *   @param  : bool bautosz
    *           : enables SizeToContents( )
    *
    *   @param  : int align
    *           : SetContentAlignment( )
    */

    function uclass.txt( pnl, text, clr, font, bautosz, align )
        text    = isstring( text ) and text or ''
        clr     = IsColor( clr ) and clr or Color( 255, 255, 255, 255 )
        font    = isstring( font ) and font or pid( 'sys.entry.default' )

        pnl:SetTextColor( clr )
        pnl:SetFont( font )
        pnl:SetText( text )

        if bautosz then
            pnl:SizeToContents( )
        end

        if align then
            pnl:SetContentAlignment ( align )
        end

        pnl[ 'Think' ] = function( s, ... )
            s:SetTextColor( clr )
        end
    end

    /*
    *   ui :: class :: DLabel :: SetText, SetTextColor
    *
    *   set text clr, font, and string
    *
    *   @param  : clr clr
    *           : text color. Uses the Color structure
    *
    *   @param  : str font
    *           : font of the label
    *
    *   @param  : str text
    *           : text to display
    *
    *   @param  : bool bautosz
    *           : enables SizeToContents( )
    */

    function uclass.textadv( pnl, clr, font, text, bautosz )
        clr     = IsColor( clr ) and clr or Color( 255, 255, 255, 255 )
        font    = isstring( font ) and font or pid( 'sys.entry.default' )
        text    = isstring( text ) and text or ''

        pnl:SetTextColor( clr )
        pnl:SetFont( font )
        pnl:SetText( text )
        if bautosz then
            pnl:SizeToContents( )
        end

        pnl[ 'Think' ] = function( s, ... )
            s:SetTextColor( clr )
        end
    end

    /*
    *   ui :: class :: DLabel :: SetText, SetTextColor
    *
    *   set text clr, font, and string
    *
    *   @param  : str text
    *           : text to display
    *
    *   @param  : clr clr
    *           : text color. Uses the Color structure
    *
    *   @param  : str font
    *           : font of the label
    *
    *   @param  : bool bautosz
    *           : enables SizeToContents( )
    *
    *   @param  : int align
    *           : set content alignment
    */

    function uclass.label( pnl, text, clr, font, bautosz, align )
        text        = isstring( text ) and text or ''
        clr         = IsColor( clr ) and clr or Color( 255, 255, 255, 255 )
        font        = isstring( font ) and font or pid( 'sys.entry.default' )
        bautosz     = bautosz or false
        align       = isnumber( align ) and align or 4

        pnl:SetText             ( text  )
        pnl:SetColor            ( clr   )
        pnl:SetFont             ( font  )

        if bautosz then
            pnl:SizeToContents( )
        end

        if align then
            pnl:SetContentAlignment ( align )
        end

        pnl[ 'Think' ] = function( s, ... )
            s:SetColor( clr )
        end
    end
    uclass.lbl = uclass.label

    /*
    *   ui :: class :: Panel :: AlphaTo
    *
    *   animation to transition the current alpha value of a panel to a new alpha, over a set period of time and after a specified delay.
    *
    *   @param  : int alpha
    *           : alpha value (0-255) to approach
    *
    *   @param  : int dur
    *           : time in seconds it should take to reach the alpha
    *
    *   @param  : int delay
    *           : delay before the animation starts.
    *
    *   @param  : func cb
    *           : function to be called once the animation finishes
    */

    function uclass.alphato( pnl, alpha, dur, delay, cb )
        alpha   = isnumber( alpha ) and alpha or 255
        dur     = isnumber( dur ) and dur or 1
        delay   = isnumber( delay ) and delay or 0

        pnl:AlphaTo( alpha, dur, delay, cb )
    end
    uclass.a2 = uclass.alphato

    /*
    *   ui :: class :: DLabel :: SetText
    *
    *   sets the text value of a panel object containing text, such as a Label, 
    *   TextEntry or RichText and their derivatives, such as DLabel, DTextEntry or DButton
    */

    function uclass.notext( pnl )
        pnl:SetText( '' )
    end

    /*
    *   ui :: class :: Panel :: SetEnabled
    *
    *   Sets the enabled state of a disable-able panel object, such as a DButton or DTextEntry.
    *   See Panel:IsEnabled for a function that retrieves the "enabled" state of a panel
    *
    *   @param  : bool b
    *           : Whether to enable or disable the panel object
    */

    function uclass.enabled( pnl, b )
        pnl:SetEnabled( b or false )
    end
    uclass.on         = uclass.enabled
    uclass.seton      = uclass.enabled
    uclass.enable     = uclass.enabled

    /*
    *   ui :: class :: DMenuBar, DPanel :: SetDisabled
    *
    *   sets whether or not to disable the panel
    *
    *   @param  : bool b
    *           : true to disable the panel (mouse input disabled and background 
    *             alpha set to 75), false to enable it (mouse input enabled and background alpha set to 255).
    */

    function uclass.disabled( pnl, b )
        pnl:SetDisabled( b or false )
    end
    uclass.off        = uclass.disabled
    uclass.setoff     = uclass.disabled

    /*
    *   ui :: class :: Panel :: SetParent
    *
    *   sets the parent of the panel
    *
    *   @param  : pnl parent
    *           : new parent of the panel
    */

    function uclass.parent( pnl, parent )
        pnl:SetParent( parent )
    end

    /*
    *   ui :: class :: Panel :: HasFocus
    *
    *   returns if the panel is focused
    *
    *   @return : bool
    *           : hasFocus
    */

    function uclass.hasfocus( pnl )
        pnl:HasFocus( )
    end

    /*
    *   ui :: class :: Panel :: HasParent
    *
    *   returns whether the panel is a descendent of the given panel
    *
    *   @param  : pnl parent
    *           : parent pnl
    *
    *   @return : bool
    *           : true if the panel is contained within parent
    */

    function uclass.hasparent( pnl, parent )
        pnl:HasParent( parent )
    end

    /*
    *   ui :: class :: Panel :: HasChildren
    *
    *   returns whenever the panel has child panels
    *
    *   @return : bool
    *           : true if the panel has children
    */

    function uclass.haschild( pnl )
        pnl:HasChildren( )
    end

    /*
    *   ui :: class :: Panel :: SetWrap
    *
    *   sets whether text wrapping should be enabled or disabled on Label and 
    *   DLabel panels. Use DLabel:SetAutoStretchVertical to automatically correct 
    *   vertical size; Panel:SizeToContents will not set the correct height
    *
    *   @param  : bool b
    *           : true to enable text wrapping, false otherwise.
    */

    function uclass.wrap( pnl, b )
        pnl:SetWrap( b or false )
    end

    /*
    *   ui :: class :: Label :: SetAutoStretchVertical
    *
    *   automatically adjusts the height of the label dependent of the height of the text inside of it.
    *
    *   @param  : bool b
    *           : true to enable auto stretching, false otherwise.
    */

    function uclass.autoverticle( pnl, b )
        pnl:SetAutoStretchVertical( b or false )
    end

    /*
    *   ui :: class :: Panel :: OnCursorEntered, OnCursorExited
    *
    *   shortcut for oncursor hover functions
    *       : s.hover
    */

    function uclass.onhover( pnl )
        pnl.OnCursorEntered = function( s ) s.hover = true end
        pnl.OnCursorExited = function( s ) s.hover = false end
    end
    uclass.ohover = uclass.onhover
    uclass.ohvr   = uclass.onhover

    /*
    *   ui :: class :: Panel :: OnCursorEntered, OnCursorExited :: dim
    *
    *   dims the btn when mouse cursor hovers
    *
    *   @param  : clr clr
    */

    function uclass.onhover_dim( pnl, clr, x, y, w, h )
        uclass.onhover( pnl )

        clr = IsColor( clr ) and clr or Color( 0, 0, 0, 200 )
        x   = isnumber( x ) and x or 0
        y   = isnumber( y ) and y or x or 0
        w   = isnumber( w ) and w or nil
        h   = isnumber( h ) and h or nil

        pnl.PaintOver = function( s, sz_w, sz_h )
            if s.hover then
                sz_w = isnumber( w ) and w or sz_w
                sz_h = isnumber( h ) and h or sz_h
                design.box( x, y, sz_w, sz_h, clr )
            end
        end
    end
    uclass.ohoverdim  = uclass.onhover_dim
    uclass.ohvrdim    = uclass.onhover_dim
    uclass.odim       = uclass.onhover_dim

    /*
    *   ui :: class :: Panel :: OnDisabled
    *
    *   sets a local pnl var to check if pnl is disabled or not
    *       :   s.disabled
    */

    function uclass.ondisabled( pnl )
        pnl.Think = function( s )
            if s:GetDisabled( ) then
                s.disabled = true
            else
                s.disabled = false
            end
        end
    end

    /*
    *   ui :: class :: Chkbox :: GetChecked
    *
    *   sets a local pnl var to check if pnl is disabled or not
    *       :   s.disabled
    */

    function uclass.onchk( pnl )
        pnl.Think = function( s )
            if s:GetChecked( ) then
                s.chk = true
            else
                s.chk = false
            end
        end
    end
    uclass.ochk = uclass.onchk

    /*
    *   ui :: class :: DButton, DImage :: SetImage
    *
    *   sets an image to be displayed as the button's background.
    *
    *   @param  : str img
    *           : image file to use, relative to /materials. If this is nil, the image background is removed.
    *
    *   @param  : str img2
    *           : backup img
    */

    function uclass.setimg( pnl, img, img2 )
        img2 = isstring( img2 ) and img2 or 'vgui/avatar_default'
        pnl:SetImage( img, img2 )
    end
    uclass.simg = uclass.setimg

    /*
    *   ui :: class :: DTextEntry :: GetUpdateOnType
    *
    *   returns whether the DTextEntry is set to run DTextEntry:OnValueChange every 
    *   time a character is typed or deleted or only when Enter is pressed.
    */

    function uclass.autoupdate( pnl )
        pnl:GetUpdateOnType( )
    end

    /*
    *   ui :: class :: Panel :: SetAllowNonAsciiCharacters
    *
    *   configures a text input to allow user to type characters that are not included in 
    *   the US-ASCII (7-bit ASCII) character set.
    *
    *   characters not included in US-ASCII are multi-byte characters in UTF-8. They can be 
    *   accented characters, non-Latin characters and special characters.
    *
    *   @param  : bool b
    *           : true in order not to restrict input characters.
    */

    function uclass.allowascii( pnl, b )
        pnl:SetAllowNonAsciiCharacters( b or false )
    end
    uclass.ascii = uclass.allowascii

    /*
    *   ui :: class :: DPropertySheet :: AddSheet
    *
    *   adds a new tab.
    *
    *   @param  : str name
    *           : name of the tab
    *
    *   @param  : pnl panel
    *           : panel to be used as contents of the tab. This normally should be a DPanel
    *
    *   @param  : str ico
    *           : icon for the tab. This will ideally be a silkicon, but any material name can be used.
    *
    *   @param  : bool bnostretchx
    *           : should DPropertySheet try to fill itself with given panel horizontally.
    *
    *   @param  : bool bnostretchy
    *           : should DPropertySheet try to fill itself with given panel vertically.
    *
    *   @param  : str tip
    *           : tooltip for the tab when user hovers over it with his cursor
    */

    function uclass.newsheet( pnl, name, panel, ico, bnostretchx, bnostretchy, tip )
        name            = isstring( name ) and name or 'untitled'
        panel           = ui:valid( panel ) and panel or nil
        ico             = isstring( ico ) and ico or ''
        bnostretchx     = bnostretchx or false
        bnostretchy     = bnostretchy or false
        tip             = isstring( tip ) and tip or ''

        pnl:AddSheet( name, panel, ico, bnostretchx, bnostretchy, tip )
    end

    /*
    *   ui :: class :: DColumnSheet :: AddSheet
    *
    *   adds a new column/tab.
    *
    *   @param  : str name
    *           : name of the column/tab
    *
    *   @param  : pnl panel
    *           : panel to be used as contents of the tab. This normally would be a DPanel
    *
    *   @param  : str ico
    *           : icon for the tab. This will ideally be a silkicon, but any material name can be used.
    */

    function uclass.newsheet_col( pnl, name, panel, ico )
        name            = isstring( name ) and name or 'untitled'
        panel           = ui:valid( panel ) and panel or nil
        ico             = isstring( ico ) and ico or ''

        pnl:AddSheet( name, panel, ico )
    end

    /*
    *   ui :: class :: Panel :: Clear
    *
    *   marks all of the panel's children for deletion.
    */

    function uclass.clear( pnl )
        pnl:Clear( )
    end

    /*
    *   ui :: class :: DFrame :: Close
    *
    *   hides or removes DFrame, calls DFrame:OnClose.
    */

    function uclass.close( pnl )
        pnl:Close( )
    end

    /*
    *   ui :: class :: DFrame :: DeleteOnClose
    *
    *   destroys pnl when closed
    *
    *   @param  : bool b
    */

    function uclass.delonclose( pnl, b )
        pnl:SetDeleteOnClose( b )
    end
    uclass.doc = uclass.delonclose

    /*
    *   ui :: class :: DComboBox :: SetValue
    *
    *   sets the text shown in the combo box when the menu is not collapsed.
    *
    *   @param  : str opt
    */

    function uclass.value( pnl, opt )
        pnl:SetValue( opt )
    end
    uclass.val = uclass.value

    /*
    *   ui :: class :: DComboBox :: SetValue
    */

    function uclass.novalue( pnl )
        pnl:SetValue( '' )
    end
    uclass.noval = uclass.novalue

    /*
    *   ui :: class :: DCheckBox :: SetValue
    *
    *   sets checked state of checkbox, calls the checkbox's DCheckBox:OnChange and Panel:ConVarChanged methods.
    *
    *   @param  : bool opt
    */

    function uclass.value_cbox( pnl, b )
        pnl:SetValue( b or false )
    end
    uclass.valcbox = uclass.value_cbox

    /*
    *   ui :: class :: Panel :: GetValue
    *
    *   returns the value the obj holds
    *
    *   @return : str
    */

    function uclass.getvalue( pnl )
        pnl:GetValue( )
    end
    uclass.gval = uclass.getvalue

    /*
    *   ui :: class :: DCheckBox :: SetChecked
    *
    *   sets the checked state of the checkbox. Does not call the checkbox's 
    *   DCheckBox:OnChange and Panel:ConVarChanged methods, unlike DCheckBox:SetValue.
    *
    *   @param  : bool b
    */

    function uclass.checked( pnl, b )
        pnl:SetChecked( b or false )
    end
    uclass.schk       = uclass.checked
    uclass.toggle     = uclass.checked

    /*
    *   ui :: class :: DComboBox :: AddChoice
    *
    *   adds a choice to the combo box.
    *
    *   @param  : str str
    *   @param  : mix data
    *   @param  : bool bsel
    *   @param  : pnl icon
    */

    function uclass.newchoice( pnl, str, data, bsel, icon )
        pnl:AddChoice( str, data, bsel, icon )
    end

    /*
    *   ui :: class :: Panel :: Destroy
    *
    *   completely removes the specified panel
    */

    function uclass.destroy( pnl )
        ui:destroy( pnl )
    end

    /*
    *   ui :: class :: Panel :: Show
    *
    *   shows the specified panel
    */

    function uclass.show( pnl )
        ui:show( pnl )
    end

    /*
    *   ui :: class :: Panel :: Hide
    *
    *   hides the specified panel
    */

    function uclass.hide( pnl )
        ui:hide( pnl )
    end

    /*
    *   ui :: class :: Panel :: MakePopup
    *
    *   focuses the panel and enables it to receive input.
    *   automatically calls Panel:SetMouseInputEnabled and Panel:SetKeyboardInputEnabled and sets them to true.
    */

    function uclass.popup( pnl )
        pnl:MakePopup( )
    end

    /*
    *   ui :: class :: DFrame :: SetDraggable
    *
    *   sets whether the frame should be draggable by the user.
    *   DFrame can only be dragged from its title bar.
    *
    *   @param  : bool b
    */

    function uclass.candrag( pnl, b )
        pnl:SetDraggable( b or false )
    end
    uclass.draggable  = uclass.candrag
    uclass.drag       = uclass.candrag

    /*
    *   ui :: class :: DFrame :: SetDraggable
    *
    *   forces frame to not allow dragging
    */

    function uclass.nodrag( pnl )
        pnl:SetDraggable( false )
    end

    /*
    *   ui :: class :: DFrame :: SetSizable
    *
    *   sets whether or not the DFrame can be resized by the user.
    *   this is achieved by clicking and dragging in the bottom right corner of the frame.
    *
    *   @param  : bool b
    */

    function uclass.canresize( pnl, b )
        pnl:SetSizable( b or false )
    end
    uclass.resizable  = uclass.canresize
    uclass.resize     = uclass.canresize

    /*
    *   ui :: class :: DFrame :: SetScreenLock
    *
    *   sets whether the DFrame is restricted to the boundaries of the screen resolution.
    *
    *   @param  : bool b
    */

    function uclass.lockscreen( pnl, b )
        pnl:SetScreenLock( b or false )
    end
    uclass.ls         = uclass.lockscreen
    uclass.scrlock    = uclass.lockscreen

    /*
    *   ui :: class :: DFrame :: SetPaintShadow
    *
    *   sets whether or not the shadow effect bordering the DFrame should be drawn.
    *
    *   @param  : bool b
    */

    function uclass.shadow( pnl, b )
        pnl:SetPaintShadow( b or false )
    end

    /*
    *   ui :: class :: DFrame :: IsActive
    *
    *   determines if the frame or one of its children has the screen focus.
    */

    function uclass.isactive( pnl )
        pnl:IsActive( )
    end

    /*
    *   ui :: class :: blur
    *
    *   adds blur to the specified pnl
    *
    *   @param  : int amt [ optional ]
    *           : how intense blur will be
    */

    function uclass.blur( pnl, amt )
        amt = isnumber( amt ) and amt or 10

        uclass.nopaint( pnl )
        pnl[ 'Paint' ] = function( s, w, h )
            design.blur( s, amt )
        end
    end

    /*
    *   ui :: class :: blurbox
    *
    *   adds blur and a single box to the pnl paint hook
    *
    *   @param  : clr clr
    *           : clr for box
    *
    *   @param  : int amt [ optional ]
    *           : how intense blur will be
    */

    function uclass.blurbox( pnl, clr, amt )
        clr     = IsColor( clr ) and clr or Color( 0, 0, 0, 200 )
        amt     = isnumber( amt ) and amt or 10

        uclass.nopaint( pnl )
        pnl[ 'Paint' ] = function( s, w, h )
            design.blur( s, amt )
            design.box( 0, 0, w, h, clr )
        end
    end

    /*
    *   ui :: class :: DFrame :: SetBackgroundBlur
    *
    *   blurs background behind the frame.
    *
    *   @param  : bool b
    *           : whether or not to create background blur or not.
    */

    function uclass.blur_bg( pnl, b )
        pnl:SetBackgroundBlur( b or false )
    end

    /*
    *   ui :: class :: DFrane :: SetTitle
    *
    *   sets the title of the frame.
    *
    *   @param  : str str
    *           : text to set as title for frame
    */

    function uclass.title( pnl, str )
        str = isstring( str ) and str or ''
        pnl:SetTitle( str )
    end

    /*
    *   ui :: class :: DFrane :: SetTitle
    *
    *   clears the dframe title
    */

    function uclass.notitle( pnl )
        pnl:SetTitle( '' )
    end

    /*
    *   ui :: class :: DFrame :: ShowCloseButton
    *
    *   determines whether the DFrame's control box (close, minimise and maximise buttons) is displayed.
    *
    *   @param  : bool b
    */

    function uclass.showclose( pnl, b )
        pnl:ShowCloseButton( b or true )
    end
    uclass.canclose = uclass.showclose

    /*
    *   ui :: class :: DFrame :: ShowCloseButton
    *
    *   automatically hides the close button on dframe pnls
    */

    function uclass.noclose( pnl )
        pnl:ShowCloseButton( false )
    end

    /*
    *   ui :: class :: Panel :: SetPaintBackground
    *
    *   sets whether or not to paint/draw the panel background.
    *
    *   @param  : bool b
    */

    function uclass.paintbg( pnl, b )
        pnl:SetPaintBackground( b or false )
    end
    uclass.pbg    = uclass.paintbg
    uclass.drawbg = uclass.paintbg

    /*
    *   ui :: class :: Panel :: SetPaintBackgroundEnabled
    *
    *   sets whenever all the default background of the panel should be drawn or not.
    *
    *   @param  : bool b
    */

    function uclass.paintbg_enabled( pnl, b )
        pnl:SetPaintBackgroundEnabled( b or true )
    end
    uclass.pbg_on     = uclass.paintbg_enabled
    uclass.drawbg_on  = uclass.paintbg_enabled

    /*
    *   ui :: class :: Panel :: SetPaintBorderEnabled
    *
    *   sets whenever all the default border of the panel should be drawn or not.
    *
    *   @param  : bool b
    */

    function uclass.paintborder( pnl, b )
        pnl:SetPaintBorderEnabled( b or true )
    end

    /*
    *   ui :: class :: Panel :: SetPaintBackgroundEnabled, SetPaintBorderEnabled, SetPaintBackground
    *
    *   @param  : bool b
    */

    function uclass.enginedraw( pnl, b )
        pnl:SetPaintBackgroundEnabled( b or true )
        pnl:SetPaintBorderEnabled( b or true )
        pnl:SetPaintBackground( b or true )
    end

    /*
    *   ui :: class :: DFrame :: Center
    *
    *   centers the panel on its parent.
    */

    function uclass.center( pnl )
        pnl:Center( )
    end

    /*
    *   ui :: class :: Panel :: GetParent
    *
    *   returns the parent of the panel, returns nil if there is no parent.
    */

    function uclass.getparent( pnl )
        pnl:GetParent( )
    end

    /*
    *   ui :: class :: Panel :: GetChild
    *
    *   gets a child by its index.
    *
    *   @param  : int id
    */

    function uclass.getchild( pnl, id )
        id = isnumber( id ) and id or 0
        pnl:GetChild( id )
    end

    /*
    *   ui :: class :: Panel :: GetChildren
    *
    *   returns a table with all the child panels of the panel.
    */

    function uclass.getchildren( pnl )
        pnl:GetChildren( )
    end

    /*
    *   ui :: class :: Panel :: InvalidateLayout
    *
    *   causes the panel to re-layout in the next frame. 
    *   during the layout process PANEL:PerformLayout will be called on the target panel.
    *
    *   @param  : bool b
    */

    function uclass.invalidate( pnl, b )
        pnl:InvalidateLayout( b or false )
    end
    uclass.nullify = uclass.invalidate

    /*
    *   ui :: class :: Panel :: InvalidateChildren
    *
    *   invalidates the layout of this panel object and all its children.
    *   this will cause these objects to re-layout immediately, calling PANEL:PerformLayout.
    *   if you want to perform the layout in the next frame, you will have loop manually through 
    *   all children, and call Panel:InvalidateLayout on each.
    *
    *   @param  : bool b
    *           : true = the method will recursively invalidate the layout of all children. Otherwise, only immediate children are affected.
    */

    function uclass.invalidate_childen( pnl, b )
        pnl:InvalidateChildren( b or false )
    end
    uclass.nullify_ch = uclass.invalidate_childen

    /*
    *   ui :: class :: Panel :: InvalidateParent
    *
    *   invalidates the layout of the parent of this panel object.
    *   this will cause it to re-layout, calling PANEL:PerformLayout.
    *
    *   @param  : bool b
    *           : true = the re-layout will occur immediately, otherwise it will be performed in the next frame.
    */

    function uclass.invalidate_parent( pnl, b )
        pnl:InvalidateParent( b or false )
    end
    uclass.nullify_pa = uclass.invalidate_parent

    /*
    *   ui :: class :: Panel :: SetCookieName, SetCookie
    *
    *   @param  : str name
    *   @param  : str val
    */

    function uclass.cookie( pnl, name, val )
        if not name then return end
        pnl:SetCookieName( name )
        pnl:SetCookie( name, val )
    end

    /*
    *   ui :: class :: Panel :: DeleteCookie
    *
    *   @param  : str name
    */

    function uclass.delcookie( pnl, name )
        if not name then return end
        pnl:DeleteCookie( name )
    end

    /*
    *   ui :: class :: Panel :: MoveTo
    *
    *   @param  : int x
    *   @param  : int y
    *   @param  : int time
    *   @param  : int delay
    *   @param  : int ease
    *   @param  : fn cb
    */

    function uclass.moveto( pnl, x, y, time, delay, ease, cb )
        pnl:MoveTo( x, y, time, delay, ease, cb )
    end
    uclass.move = uclass.moveto

    /*
    *   ui :: class :: Panel :: MoveToBack
    *
    *   @param  : bool b
    */

    function uclass.movetoback( pnl, b )
        pnl:MoveToBack( b or false )
    end
    uclass.m2b        = uclass.movetoback
    uclass.back       = uclass.movetoback

    /*
    *   ui :: class :: Panel :: MoveToFront
    */

    function uclass.movetofront( pnl )
        pnl:MoveToFront( )
    end
    uclass.m2f        = uclass.movetofront
    uclass.front      = uclass.movetofront

    /*
    *   ui :: class :: Panel :: MoveToAfter
    *
    *   @param  : pnl panel
    */

    function uclass.movetoafter( pnl, panel )
        if not panel then return end
        pnl:MoveToAfter( panel )
    end
    uclass.m2af       = uclass.movetoafter
    uclass.after      = uclass.movetoafter

    /*
    *   ui :: class :: Panel :: MoveToBefore
    *
    *   @param  : pnl panel
    */

    function uclass.movetobefore( pnl, panel )
        if not panel then return end
        pnl:MoveToBefore( panel )
    end
    uclass.m2bf       = uclass.movetobefore
    uclass.before     = uclass.movetobefore

    /*
    *   ui :: class :: Panel :: MoveBelow
    *
    *   @param  : pnl panel
    */

    function uclass.movebelow( pnl, panel )
        if not panel then return end
        pnl:MoveBelow( panel )
    end
    uclass.mb         = uclass.movebelow
    uclass.below      = uclass.movebelow

    /*
    *   ui :: class :: Panel :: SetZPos
    *
    *   @param  : int pos
    */

    function uclass.zpos( pnl, pos )
        pos = isnumber( pos ) and pos or 1
        pnl:SetZPos( pos )
    end

    /*
    *   ui :: class :: Panel :: SetKeyboardInputEnabled
    *
    *   @param  : bool b
    */

    function uclass.allowkeyboard( pnl, b )
        pnl:SetKeyboardInputEnabled( b or false )
    end
    uclass.keys_ok = uclass.allowkeyboard

    /*
    *   ui :: class :: Panel :: SetMouseInputEnabled
    *
    *   @param  : bool b
    */

    function uclass.allowmouse( pnl, b )
        pnl:SetMouseInputEnabled( b or false )
    end
    uclass.mouse_ok = uclass.allowmouse

    /*
    *   ui :: class :: Panel :: SetRounded
    *
    *   @param  : bool b
    */

    function uclass.rounded( pnl, b )
        pnl:SetRounded( b or false )
    end

    /*
    *   ui :: class :: Panel :: SetOpacity
    *
    *   @param  : int i
    */

    function uclass.opacity( pnl, i )
        i = isnumber( i ) and i or 255
        pnl:SetOpacity( i )
    end

    /*
    *   ui :: class :: Panel :: SetAlpha
    *
    *   @param  : int int
    */

    function uclass.alpha( pnl, int )
        int = isnumber( int ) and int or 255
        pnl:SetAlpha( int )
    end

    /*
    *   ui :: class :: Panel :: SetHeader
    *
    *   @param  : str str
    */

    function uclass.header( pnl, str )
        str = isstring( str ) and str or 'Welcome'
        pnl:SetHeader( str )
    end

    /*
    *   ui :: class :: Panel :: ActionShow
    */

    function uclass.actshow( pnl )
        pnl:ActionShow( )
    end

    /*
    *   ui :: class :: Panel :: ActionHide
    */

    function uclass.acthide( pnl )
        pnl:ActionHide( )
    end

    /*
    *   ui :: class :: Panel :: Param
    *
    *   can be used to call panel child function
    *
    *   @ex     :   func in PANEL file:         PANEL:GetItemID( )
    *           :   call from pmeta:            :param( 'ItemID', 293 )
    *
    *   @alias  : param, define
    *
    *   @param  : str name
    *   @param  : mix val
    */

    function uclass.param( pnl, name, val )
        if not name or not pnl[ name ] then return end
        val = val or ''
        pnl[ name ]( pnl, val )
    end
    uclass.define = uclass.param

    /*
    *   ui :: class :: Panel :: var
    *
    *   @ex     : var( 'health', 0 )
    *
    *   @call   : self.item.health
    *           : item.health
    *
    *   @alias  : var
    *
    *   @param  : str name
    *   @param  : mix val
    */

    function uclass.var( pnl, name, val )
        val = val or ''
        pnl[ name ] = val
    end

    /*
    *   ui :: class :: Panel :: SetTooltip
    *
    *   displays tooltips
    *   to be updated in future for brand new tooltip sys
    *
    *   @alias  : tooltip, tipster, tip
    *
    *   @param  : str str
    */

    function uclass.tooltip( pnl, str )
        str = isstring( str ) and str or ''
        pnl:SetTooltip( str )
    end
    uclass.tipster    = uclass.tooltip
    uclass.tip        = uclass.tooltip

    /*
    *   ui :: class :: DModel :: SetModel
    *
    *   @alias  : model, mdl, setmdl
    *
    *   @param  : str str
    *   @param  : int skin
    *   @param  : str bodygrp
    */

    function uclass.model( pnl, str, skin, bodygrp )
        skin        = isnumber( skin ) and skin or 0
        bodygrp     = isstring( bodygrp ) and bodygrp or ''
        pnl:SetModel( str, skin, bodygrp )
    end
    uclass.mdl    = uclass.model
    uclass.setmdl = uclass.model

    /*
    *   ui :: class :: DModel :: SetFOV
    *
    *   @alias  : fov, setfov
    *
    *   @param  : int i
    */

    function uclass.fov( pnl, i )
        i = isnumber( i ) and i or 120
        pnl:SetFOV( i )
    end
    uclass.setfov = uclass.fov

    /*
    *   ui :: class :: DModel :: SetAmbientLight
    *
    *   @param  : clr clr
    */

    function uclass.light( pnl, clr )
        clr = IsColor( clr ) and clr or Color( 255, 255, 255, 255 )
        pnl:SetAmbientLight( clr )
    end

    /*
    *   ui :: class :: DNum :: SetMin
    *
    *   @alias  : min, setmin
    *
    *   @param  : int min
    */

    function uclass.min( pnl, min )
        min = isnumber( min ) and min or 0
        pnl:SetMin( min )
    end
    uclass.setmin = uclass.min

    /*
    *   ui :: class :: DNum :: SetMax
    *
    *   @alias  : max, setmax
    *
    *   @param  : int max
    */

    function uclass.max( pnl, max )
        max = isnumber( max ) and max or 1000
        pnl:SetMax( max )
    end
    uclass.setmax = uclass.max

    /*
    *   ui :: class :: DNum :: minmax
    *
    *   @alias  : minmax, setminmax
    *
    *   @param  : int min
    *   @param  : int max
    */

    function uclass.minmax( pnl, min, max )
        min = isnumber( min ) and min or 0
        pnl:SetMin( min )
        if max then
            pnl:SetMax( max )
        end
    end
    uclass.setminmax = uclass.minmax

    /*
    *   ui :: class :: DModel :: SetCamPos
    *
    *   @param  : vec pos
    */

    function uclass.cam( pnl, pos )
        pos = isvector( pos ) and pos or Vector( 0, 0, 0 )
        pnl:SetCamPos( pos )
    end

    /*
    *   ui :: class :: DModel :: SetLookAt
    *
    *   @param  : vec pos
    */

    function uclass.look( pnl, pos )
        pos = isvector( pos ) and pos or Vector( 0, 0, 0 )
        pnl:SetLookAt( pos )
    end

    /*
    *   ui :: class :: ItemStore :: SetContainerID
    *
    *   returns iventory id from itemstore addon from gmodstore
    *
    *   @param  : int id
    */

    function uclass.inventory_id( pnl, id )
        id = isnumber( id ) and id or 0
        pnl:SetContainerID( id )
    end
    uclass.inv_id = uclass.inventory_id

    /*
    *   ui :: class :: Panel :: OpenURL
    *
    *   returns iventory id from itemstore addon from gmodstore
    *
    *   @param  : str uri
    */

    function uclass.url( pnl, uri )
        uri = isstring( uri ) and uri or 'http://google.com/'
        pnl:OpenURL( uri )
    end

    /*
    *   ui :: class :: DGrid :: AddItem
    *
    *   @param  : pnl panel
    */

    function uclass.additem( pnl, panel )
        if not panel then return end
        pnl:AddItem( panel )
    end

    /*
    *   ui :: class :: DGrid :: SetCols
    *
    *   number of columns this panel should have.
    *
    *   @param  : int cols
    *           : desired number of columns
    */

    function uclass.col( pnl, cols )
        cols = isnumber( cols ) and cols or 1
        pnl:SetCols( cols )
    end

    /*
    *   ui :: class :: DGrid :: SetColWide
    *
    *   number of columns this panel should have.
    *
    *   @param  : int w
    *           : width of each column.
    */

    function uclass.col_wide( pnl, w )
        w = isnumber( w ) and w or 1
        pnl:SetColWide( w )
    end

    /*
    *   ui :: class :: DGrid :: colstall
    *
    *   height of each row.
    *   cell panels (grid items) will not be resized or centered.
    *
    *   @param  : int h
    *           : height of each column.
    */

    function uclass.col_tall( pnl, h )
        h = isnumber( h ) and h or 20
        pnl:SetRowHeight( h )
    end

    /*
    *   ui :: class :: DHTML :: img url
    *
    *   sets the img url to use for a dhtml element
    *   supports both a string url or a table of strings
    *
    *   @param  : int h
    *           : height of each column.
    */

    function uclass.imgurl( pnl, src, bRand )
        bRand = bRand or false
        local img = ui:html_img_full( src, bRand )
        pnl:SetHTML( img )
    end

    /*
    *   ui :: class :: RichText :: AppendText
    *
    *   @param  : str str
    */

    function uclass.appendtxt( pnl, str )
        str = isstring( str ) and str or ''
        pnl:AppendText( str )
    end

    /*
    *   ui :: class :: RichText :: InsertColorChange
    *
    *   @param  : clr clr
    */

    function uclass.appendclr( pnl, clr )
        clr = IsColor( clr ) and clr or Color( 255, 255, 255, 255 )
        local clr_append = clr
        pnl:InsertColorChange( clr_append.r, clr_append.g, clr_append.b, clr_append.a )
    end

    /*
    *   ui :: class :: RichText :: InsertColorChange
    *
    *   @param  : clr clr
    */

    function uclass.appendfont( pnl, font, clr )
        font    = isstring( font ) and font or ''
        clr     = IsColor( clr ) and clr or Color( 255, 255, 255, 255 )
        pnl[ 'PerformLayout' ] = function( s, ... )
            s:SetFontInternal( font )
            s:SetFGColor( clr )
        end
    end

    /*
    *   ui :: class :: RichText :: InsertColorChange, AppendText
    *
    *   @param  : str str
    *   @param  : clr clr
    */

    function uclass.append( pnl, str, clr )
        str = isstring( str ) and str or ''
        clr = IsColor( clr ) and clr or Color( 255, 255, 255, 255 )
        if IsColor( clr ) then
            local clr_append = clr
            pnl:InsertColorChange( clr_append.r, clr_append.g, clr_append.b, clr_append.a )
        end
        pnl:AppendText( str )
    end

    /*
    *   ui :: class :: fx :: onclick circle
    *
    *   creates a simple onclick animation with a poly expanding outward while becoming transparent
    *   based on mouse position
    *
    *   @param  : clr clr
    *   @param  : int sp_r
    *   @param  : int sp_a
    *   @param  : int r
    */

    function uclass.anim_click_circle( pnl, clr, sp_r, sp_a, r )
        clr         = IsColor( clr ) and clr or Color( 5, 5, 5, 200 )
        sp_r        = isnumber( sp_r ) and sp_r or 2
        sp_a        = isnumber( sp_a ) and sp_a or 1
        r           = 100

        pnl.radius  = 0
        pnl.a       = 0
        pnl.pos_x   = 0
        pnl.pos_y   = 0

        pnl:paintover( function( s, w, h )
            if s.a < 1 then return end

            design.circle_simple( s.pos_x, s.pos_y, s.radius, ColorAlpha( clr, s.a ) )

            s.radius    = Lerp( FrameTime( ) * sp_r, s.radius, r or w )
            s.a         = Lerp( FrameTime( ) * sp_a, s.a, 0 )
        end)

        pnl:onclick( function( cir )
            cir.pos_x, cir.pos_y    = cir:CursorPos( )
            cir.radius              = 0
            cir.a                   = clr.a
        end )
    end
    uclass.anim_cir = uclass.anim_click_circle

    /*
    *   ui :: class :: fx :: onclick circle
    *
    *   creates a simple onclick animation with a poly expanding outward while becoming transparent
    *   based on mouse position
    *
    *   @param  : clr clr
    *   @param  : int sp_r
    *   @param  : int sp_a
    *   @param  : int r
    */

    function uclass.anim_click_ol( pnl, clr, clr2, sp_r, sp_a, r )
        clr         = IsColor( clr ) and clr or Color( 5, 5, 5, 200 )
        clr2        = IsColor( clr2 ) and clr2 or Color( 5, 5, 5, 255 )
        sp_r        = isnumber( sp_r ) and sp_r or 2
        sp_a        = isnumber( sp_a ) and sp_a or 2
        r           = 125

        pnl.radius  = 0
        pnl.a       = 0
        pnl.pos_x   = 0
        pnl.pos_y   = 0

        pnl:paintover( function( s, w, h )
            if s.a < 1 then return end

            design.circle_ol( s.pos_x, s.pos_y, s.radius, ColorAlpha( clr, s.a ), ColorAlpha( clr, s.a ), ColorAlpha( clr, s.a ) )

            s.radius    = Lerp( FrameTime( ) * sp_r, s.radius, r or w )
            s.a         = Lerp( FrameTime( ) * sp_a, s.a, 0 )
        end )

        pnl:onclick( function( cir )
            cir.pos_x, cir.pos_y    = cir:CursorPos( )
            cir.radius              = 0
            cir.a                   = clr.a
        end )
    end
    uclass.anim_cir_ol = uclass.anim_click_ol

    /*
    *   ui :: class :: fx :: anim :: fade light
    *
    *   animates a pnl by setting pnl opacity to X with fade effect
    *
    *   @param  : int alpha
    *   @param  : int time
    *   @param  : fn fn
    */

    function uclass.anim_light( pnl, alpha, time, fn )
        alpha   = isnumber( alpha ) and alpha or 255
        time    = isnumber( time ) and time or 0.5
        pnl:AlphaTo( alpha, time, 0, function( )
            fn( pnl )
        end )
    end
    uclass.anim_l = uclass.anim_light

    /*
    *   ui :: class :: fx :: anim :: dark
    *
    *   animates a pnl by setting pnl opacity to X with fade effect
    *
    *   @param  : int time
    *   @param  : fn fn
    */

    function uclass.anim_dark( pnl, time, fn )
        time    = isnumber( time ) and time or 0.5
        pnl:AlphaTo( 0, time, 0, function( )
            fn( pnl )
        end )
    end
    uclass.anim_d = uclass.anim_dark

    /*
    *   ui :: class :: fx :: anim :: to color
    *
    *   changes pnl color using animated fade
    *
    *   @param  : clr clr
    *   @param  : int time
    *   @param  : fn fn
    */

    function uclass.anim_color( pnl, clr, time, fn )
        clr     = IsColor( clr ) and clr or Color( 255, 255, 255, 255 )
        time    = isnumber( time ) and time or 0.5
        pnl:ColorTo( clr, time, 0, function( )
            fn( pnl )
        end )
    end
    uclass.anim_clr = uclass.anim_color

    /*
    *   ui :: class :: avatar
    *
    *   @param  : ply pl
    *   @param  : int sz
    */

    function uclass.player( pnl, pl, sz )
        if not helper.ok.ply( pl ) then return end
        sz = isnumber( sz ) and sz or 32
        pnl:SetPlayer( pl, sz )
    end
    uclass.ply    = uclass.player

    /*
    *   ui :: class :: DButton :: setup
    *
    *   sets up a button using various classes
    *   should be the first thing executed when creating a new btn element
    */

    function uclass.bsetup( pnl )
        pnl:nopaint     ( )
        pnl:onhover     ( )
        pnl:ondisabled  ( )
        pnl:notext      ( )
    end


/*
*   metatable :: ui
*
*   mt registers new associated classes
*/

function dmeta:ui( )
    self.Class = function( pnl, name, ... )
        local fn = uclass[ name ]
        assert( fn, lang( 'logs_inf_pnl_assert', name ) )

        fn( pnl, ... )

        return pnl
    end

    for k, v in pairs( uclass ) do
        self[ k ] = function( pnl, ... )
            if not pnl then return end
            return pnl:Class( k, ... )
        end
    end

    return self
end

/*
*   ui :: new
*
*   creates a new vgui element
*
*   @note   : deprecated in v3.1
*
*   @param  : str class
*   @param  : pnl panel
*   @param  : str name
*/

function ui.new( class, panel, name )
    if not class then
        base:log( 2, lang( 'logs_inf_regclass_err' ) )
        return
    end

    class       = ui.element( class ) or class
    name        = isstring( name ) and name or 'none'

    local pnl   = vgui.Create( class, panel, name )

    if not ui:valid( pnl ) then return end

    return pnl:ui( )
end
ui.gmod = ui.new

/*
*   ui :: rlib
*
*   creates new pnl for rlib
*   pnl must be registered in the modules env / manifest file
*
*   @ex     : ui.rlib( mod, 'rlib_module_pnl' )
*           : ui.rlib( mod, 'rlib_module_pnl', parent )
*
*   @param  : tbl mod
*   @param  : str id
*   @param  : pnl panel
*   @param  : str name
*/

function ui.rlib( mod, id, panel, name )
    if not id then
        base:log( 2, lang( 'logs_inf_regclass_err' ) )
        return
    end

    local call  = rlib:resource( mod, 'pnl', id )
    name        = isstring( name ) and name or 'none'

    local pnl   = vgui.Create( call, panel, name )
    if not ui:valid( pnl ) then return end

    return pnl:ui( )
end

/*
*   ui :: add
*
*   creates a new vgui element, adds the specified object to the panel.
*   similar to Panel:Add( )
*
*   @param  : str class
*   @param  : pnl parent
*/

function ui.add( class, parent )
    if not class then
        base:log( 2, lang( 'logs_inf_regclass_err' ) )
        return
    end

    class = ui.element( class ) or class

    local pnl = parent:Add( class )
    return pnl:ui( )
end

/*
*   ui :: route // relink
*
*   routes one pnl to another while providing access to metatable classes
*
*   @ex     : mod.pnl.root = ui.route( mod.pnl.root, self )
*           : mod.pnl.root = ui.relink( mod.pnl.root, self )
*
*   @param  : pnl parent
*   @param  : pnl pnl
*/

function ui.route( parent, pnl )
    parent = pnl
    return pnl:ui( )
end
uclass.relink     = uclass.route
uclass.symlink    = uclass.route

/*
*   ui :: get
*
*   returns the metatable for an existing pnl
*   useful for continuing where you left off when setting values for a pnl
*
*   @ex     :   local root_pnl  = ui.get( mod.pnl.root )
*               :wide           ( 100 )
*
*   @param  : pnl pnl
*           : target panel
*/

function ui.get( pnl )
    if not ui:valid( pnl ) then return end
    return pnl:ui( )
end

/*
*   ui :: edit
*
*   allows you to edit a pnl on the fly
*   validates the panel first prior and prevents random
*   nil pnl errors from occuring
*
*   @ex     : ui.edit( mod.pnl.root, 'wide', 500 )
*           : ui.edit( mod.pnl.root, 'zpos', 1 )
*
*   @param  : pnl pnl
*   @param  : str fn_name
*   @param  : vararg ...
*           : target panel
*/

function ui.edit( pnl, fn_name, ... )
    if not ui:valid( pnl ) then return end
    if not isstring( fn_name ) then return end

    uclass[ fn_name ]( pnl, ... )
end