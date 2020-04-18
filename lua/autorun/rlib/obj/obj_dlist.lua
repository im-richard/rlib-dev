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

rlib                        = rlib or { }
local base                  = rlib
local cfg                   = base.settings
local helper                = base.h
local design                = base.d
local ui                    = base.i
local konsole			    = base.k

/*
*   PANEL
*/

local PANEL = { }

/*
*   AccessorFunc
*/

AccessorFunc( PANEL, 'm_bSizeToContents',		'AutoSize' )
AccessorFunc( PANEL, 'm_bStretchHorizontally',	'StretchHorizontally' )
AccessorFunc( PANEL, 'm_bNoSizing',				'NoSizing' )
AccessorFunc( PANEL, 'm_bSortable',				'Sortable' )
AccessorFunc( PANEL, 'm_fAnimTime',				'AnimTime' )
AccessorFunc( PANEL, 'm_fAnimEase',				'AnimEase' )
AccessorFunc( PANEL, 'm_strDraggableName',		'DraggableName' )

AccessorFunc( PANEL, 'Spacing', 'Spacing' )
AccessorFunc( PANEL, 'Padding', 'Padding' )

/*
*   Init
*/

function PANEL:Init( )

    self:SetDraggableName( 'GlobalDPanel' )

    self.pnlCanvas = vgui.Create( 'DPanel', self )
    self.pnlCanvas:SetPaintBackground( false )
    self.pnlCanvas.OnMousePressed = function( s, code ) s:GetParent( ):OnMousePressed( code ) end
    self.pnlCanvas.OnChildRemoved = function( ) self:OnChildRemoved( ) end
    self.pnlCanvas:SetMouseInputEnabled( true )
    self.pnlCanvas.InvalidateLayout = function( ) self:InvalidateLayout( ) end

    self.Items          			= { }
    self.YOffset        			= 0
    self.m_fAnimTime    			= 0
    self.m_fAnimEase    			= -1
    self.m_iBuilds      			= 0
    self.Alpha          			= 255

    self.VBar 						= vgui.Create( 'rlib.ui.scrollbar', self )
    self.VBar:Dock					( RIGHT )
    self.VBar:SetWide				( 25 )
    self.VBar:DockMargin			( 0, 0, 6, 0 )

    self:SetPadding					( 0 )
    self:SetMouseInputEnabled		( true )

    -- This turns off the engine drawing
    self:SetPaintBackgroundEnabled	( false )
    self:SetPaintBorderEnabled		( false )
    self:SetPaintBackground			( false )

end

/*
*   OnModified
*/

function PANEL:OnModified( ) end

/*
*   SizeToContents
*/

function PANEL:SizeToContents( )
    self:SetSize( self.pnlCanvas:GetSize( ) )
end

/*
*   GetVBar
*/

function PANEL:GetVBar( )
    return self.VBar
end

/*
*   GetItems
*/

function PANEL:GetItems( )
    return self.Items
end

/*
*   EnableHorizontal
*/

function PANEL:EnableHorizontal( bHoriz )
    self.Horizontal = bHoriz
end

/*
*   EnableVerticalScrollbar
*/

function PANEL:EnableVerticalScrollbar( )
    if self.VBar then return end

    self.Alpha = 255

    self.VBar = vgui.Create( 'rlib.ui.scrollbar', self )
    self.VBar:Dock( RIGHT )
    self.VBar:SetWide( 25 )
    self.VBar:DockMargin( 0, 0, 6, 0 )
end

/*
*   GetCanvas
*/

function PANEL:GetCanvas( )
    return self.pnlCanvas
end

/*
*   Clear
*/

function PANEL:Clear( bDelete )
    for k, panel in pairs( self.Items ) do
        if not IsValid( panel ) then continue end

        panel:SetVisible( false )

        if bDelete then
            panel:Remove( )
        end
    end

    self.Items = { }
end

/*
*   AddItem
*/

function PANEL:AddItem( item, strLineState )
    if not IsValid( item ) then return end

    item:SetVisible( true )
    item:SetParent( self:GetCanvas( ) )
    item.m_strLineState = strLineState or item.m_strLineState
    table.insert( self.Items, item )

    item:SetSelectable( self.m_bSelectionCanvas )

    self:InvalidateLayout( )
end

/*
*   InsertBefore
*/

function PANEL:InsertBefore( before, insert, strLineState )
    table.RemoveByValue( self.Items, insert )

    self:AddItem( insert, strLineState )

    local key = table.KeyFromValue( self.Items, before )

    if key then
        table.RemoveByValue( self.Items, insert )
        table.insert( self.Items, key, insert )
    end
end

/*
*   InsertAfter
*/

function PANEL:InsertAfter( before, insert, strLineState )
    table.RemoveByValue( self.Items, insert )
    self:AddItem( insert, strLineState )

    local key = table.KeyFromValue( self.Items, before )

    if key then
        table.RemoveByValue( self.Items, insert )
        table.insert( self.Items, key + 1, insert )
    end
end

/*
*   InsertAtTop
*/

function PANEL:InsertAtTop( insert, strLineState )
    table.RemoveByValue( self.Items, insert )
    self:AddItem( insert, strLineState )

    local key = 1
    if key then
        table.RemoveByValue( self.Items, insert )
        table.insert( self.Items, key, insert )
    end
end

/*
*   DropAction
*/

function PANEL.DropAction( Slot, RcvSlot )

    local pnl2move = Slot.Panel
    if ( dragndrop.m_MenuData == 'copy' ) then
        if ( pnl2move.Copy ) then
            pnl2move = Slot.Panel:Copy( )
            pnl2move.m_strLineState = Slot.Panel.m_strLineState
        else
            return
        end
    end

    pnl2move:SetPos( RcvSlot.Data.pnlCanvas:ScreenToLocal( gui.MouseX( ) - dragndrop.m_MouseLocalX, gui.MouseY( ) - dragndrop.m_MouseLocalY ) )

    if ( dragndrop.DropPos == 4 or dragndrop.DropPos == 8 ) then
        RcvSlot.Data:InsertBefore( RcvSlot.Panel, pnl2move )
    else
        RcvSlot.Data:InsertAfter( RcvSlot.Panel, pnl2move )
    end

end

/*
*   RemoveItem
*/

function PANEL:RemoveItem( item, bDontDelete )
    for k, panel in pairs( self.Items ) do
        if ( panel == item ) then
            self.Items[ k ] = nil

            if not bDontDelete then
                panel:Remove( )
            end

            self:InvalidateLayout( )
        end
    end
end

/*
*   CleanList
*/

function PANEL:CleanList( )
    for k, panel in pairs( self.Items ) do
        if not IsValid( panel ) or panel:GetParent( ) ~= self.pnlCanvas then
            self.Items[k] = nil
        end
    end
end

/*
*   Rebuild
*/

function PANEL:Rebuild( )

    local Offset = 0
    self.m_iBuilds = self.m_iBuilds + 1

    self:CleanList( )

    if ( self.Horizontal ) then

        local x, y = self.Padding, self.Padding
        for k, panel in pairs( self.Items ) do

            if ( panel:IsVisible( ) ) then

                local OwnLine = ( panel.m_strLineState and panel.m_strLineState == 'ownline' )
                local w = panel:GetWide( )
                local h = panel:GetTall( )

                if ( x > self.Padding and ( x + w > self:GetWide( ) or OwnLine ) ) then

                    x 	= self.Padding
                    y 	= y + h + self.Spacing

                end

                if ( self.m_fAnimTime > 0 and self.m_iBuilds > 1 ) then
                    panel:MoveTo( x, y, self.m_fAnimTime, 0, self.m_fAnimEase )
                else
                    panel:SetPos( x, y )
                end

                x 		= x + w + self.Spacing
                Offset 	= y + h + self.Spacing

                if ( OwnLine ) then

                    x = self.Padding
                    y = y + h + self.Spacing

                end

            end

        end

    else

        for k, panel in pairs( self.Items ) do
            if ( panel:IsVisible( ) ) then
                if ( self.m_bNoSizing ) then
                    panel:SizeToContents( )
                    if ( self.m_fAnimTime > 0 and self.m_iBuilds > 1 ) then
                        panel:MoveTo( ( self:GetCanvas( ):GetWide( ) - panel:GetWide( ) ) * 0.5, self.Padding + Offset, self.m_fAnimTime, 0, self.m_fAnimEase )
                    else
                        panel:SetPos( ( self:GetCanvas( ):GetWide( ) - panel:GetWide( ) ) * 0.5, self.Padding + Offset )
                    end
                else
                    panel:SetSize( self:GetCanvas( ):GetWide( ) - self.Padding * 2, panel:GetTall( ) )
                    if ( self.m_fAnimTime > 0 and self.m_iBuilds > 1 ) then
                        panel:MoveTo( self.Padding, self.Padding + Offset, self.m_fAnimTime, self.m_fAnimEase )
                    else
                        panel:SetPos( self.Padding, self.Padding + Offset )
                    end
                end
                panel:InvalidateLayout( true )
                Offset = Offset + panel:GetTall( ) + self.Spacing
            end
        end

        Offset = Offset + self.Padding

    end

    self:GetCanvas( ):SetTall( Offset + self.Padding - self.Spacing )

    if ( self.m_bNoSizing and self:GetCanvas( ):GetTall( ) < self:GetTall( ) ) then
        self:GetCanvas( ):SetPos( 0, ( self:GetTall( ) - self:GetCanvas( ):GetTall( ) ) * 0.5 )
    end

end

/*
*   OnMouseWheeled
*/

function PANEL:OnMouseWheeled( dlta )
    return self.VBar:OnMouseWheeled( dlta )
end

/*
*   Paint
*/

function PANEL:Paint( w, h )
    derma.SkinHook( 'Paint', 'PanelList', self, w, h )
    return true
end

/*
*   OnVScroll
*/

function PANEL:OnVScroll( iOffset )
    self.pnlCanvas:SetPos( 0, iOffset )
end

/*
*   PerformLayout
*/

function PANEL:PerformLayout( )

    local Wide = self:GetWide( )
    local Tall = self.pnlCanvas:GetTall( )
    local YPos = 0

    if not self.Rebuild then
        debug.Trace( )
    end

    self:Rebuild( )

    self.VBar:SetUp( self:GetTall( ), self.pnlCanvas:GetTall( ) )
    YPos = self.VBar:GetOffset( )

    if ( self.VBar.Enabled ) then Wide = Wide - self.VBar:GetWide( ) end

    self.pnlCanvas:SetPos( 0, YPos )
    self.pnlCanvas:SetWide( Wide )

    self:Rebuild( )

    if self:GetAutoSize( ) then
        self:SetTall( self.pnlCanvas:GetTall( ) )
        self.pnlCanvas:SetPos( 0, 0 )
    end

    if Tall ~= self.pnlCanvas:GetTall( ) then
        self.VBar:SetScroll( self.VBar:GetScroll( ) )
    end

end

/*
*   OnChildRemoved
*/

function PANEL:OnChildRemoved( )
    self:CleanList( )
    self:InvalidateLayout( )
end

/*
*   ScrollToChild
*/

function PANEL:ScrollToChild( pnl )
    local x, y 	= self.pnlCanvas:GetChildPosition( pnl )
    local w, h 	= pnl:GetSize( )
    y 			= y + h * 0.5
    y 			= y - self:GetTall( ) * 0.5

    self.VBar:AnimateTo( y, 0.5, 0, 0.5 )
end

/*
*   SortByMember
*/

function PANEL:SortByMember( key, desc )
    desc = desc or true

    table.sort( self.Items, function( a, b )
        if ( desc ) then
            local ta 	= a
            local tb 	= b
            a 			= tb
            b 			= ta
        end

        if a[ key ] == nil then return false end
        if b[ key ] == nil then return true end

        return a[ key ] > b[ key ]
    end )
end

/*
*   DefineControl
*/

derma.DefineControl( 'rlib.ui.dlist', 'rlib dlist', PANEL, 'DPanel' )