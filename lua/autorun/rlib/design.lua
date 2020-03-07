/*
*   @package        rlib
*   @author         Richard [http://steamcommunity.com/profiles/76561198135875727]
*   @copyright      (C) 2018 - 2020
*   @since          1.0.0
*   @website        https://rlib.io
*   @docs           https://docs.rlib.io
*   @file           design.lua
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
local helper            = base.h
local design            = base.d
local ui                = base.i
local access            = base.a
local materials         = base.m
local konsole           = base.k

/*
*   Localized lua funcs
*
*   i absolutely hate having to do this, but for squeezing out every bit of performance, we need to.
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
local string            = string
local sf                = string.format
local table             = table
local player            = player
local math              = math
local surface           = surface
local draw              = draw
local render            = render

/*
*   Localized translation func
*/

local function lang( ... )
    return base:lang( ... )
end

/*
*	prefix ids
*/

local function pref( str, suffix )
    local state = not suffix and mod or isstring( suffix ) and suffix or false
    return rlib.get:pref( str, state )
end

/*
*   constants
*
*   text align
*/

RLIB_TALIGN_L       = 4
RLIB_TALIGN_C       = 5
RLIB_TALIGN_R       = 6
RLIB_TALIGN_T       = 8
RLIB_TALIGN_B       = 2

/*
*   metatables
*/

local dmeta = FindMetaTable( 'Panel' )

/*
*   design :: blur
*
*   @param  : pnl pnl
*   @param  : int amt
*   @param  : int amplify
*/

local blur = Material( helper._mat[ 'pp_blur' ] )
function design.blur( pnl, amt, amplify )
    if not IsValid( pnl ) then return end

    amt         = isnumber( amt ) and amt or 6
    amplify     = isnumber( amplify ) and amplify or 3

    local x, y = pnl:LocalToScreen( 0, 0 )
    local scr_w, scr_h = ScrW( ), ScrH( )

    surface.SetDrawColor( 255, 255, 255, 255 )
    surface.SetMaterial( blur )

    for i = 1, ( amplify ) do
        blur:SetFloat( '$blur', ( i / amplify ) * amt )
        blur:Recompute( )

        if render then render.UpdateScreenEffectTexture( ) end
        surface.DrawTexturedRect( x * -1, y * -1, scr_w, scr_h )
    end
end

/*
*   design :: blur :: self
*
*   @param  : clr clr
*   @param  : int amt
*   @param  : int amplify
*/

function design.blurself( clr, amt, amplify )
    local x, y, frac = 0, 0, 1

    clr         = IsColor( clr ) and clr or Color( 5, 5, 5, 200 )
    amt         = isnumber( amt ) and amt or 6
    amplify     = isnumber( amplify ) and amplify or 3

    DisableClipping( true )

    surface.SetMaterial( blur )
    surface.SetDrawColor( 255, 255, 255, 255 )

    for i = 1, ( amplify ) do
        blur:SetFloat( '$blur', ( i / amplify ) * amt )
        blur:Recompute( )

        if render then render.UpdateScreenEffectTexture( ) end
        surface.DrawTexturedRect( x * -1, y * -1, ScrW( ), ScrH( ) )
    end

    surface.SetDrawColor( clr.a, clr.g, clr.b, clr.a * frac )
    surface.DrawRect( x * -1, y * -1, ScrW(), ScrH() )

    DisableClipping( false )
end

/*
*   design :: box
*
*   @param  : int x
*   @param  : int y
*   @param  : int w
*   @param  : int h
*   @param  : clr clr
*/

function design.box( x, y, w, h, clr )
    h   = isnumber( h ) and h or w
    clr = IsColor( clr ) and clr or Color( 0, 0, 0, 255 )

    surface.SetDrawColor( clr )
    surface.DrawRect( x, y, w, h )
end

/*
*   design :: box :: 3d
*
*   @param  : int w
*   @param  : int min
*   @param  : int max
*   @param  : clr clr
*/

function design.box3d( w, min, max, clr )
    local offset                = Vector( 2, 2, 2 )
    local mid, lmin, lmax       = calc.pos.midpoint( min, max )
    local angle_zero            = Angle( 0, 0, 0 )

    render.DrawBeam( min, Vector( min.x, max.y, min.z ), w, 0, 0, clr )  -- Back Face Top
    render.DrawBeam( min, Vector( max.x, min.y, min.z ), w, 0, 0, clr ) -- Left Face Top
    render.DrawBeam( min, Vector( min.x, min.y, max.z ), w, 0, 0, clr ) -- Left Face Left

    render.DrawBeam( max, Vector( max.x, max.y, min.z ), w, 0, 0, clr ) -- Front Face Right
    render.DrawBeam( max, Vector( max.x, min.y, max.z ), w, 0, 0, clr ) -- Front Face Bottom
    render.DrawBeam( max, Vector( min.x, max.y, max.z ), w, 0, 0, clr ) -- Right Face Bottom

    render.DrawBeam( Vector( min.x, min.y, max.z ), Vector( min.x, max.y, max.z ), w, 0, 0, clr ) -- Front Face Bottom
    render.DrawBeam( Vector( min.x, min.y, max.z ), Vector( max.x, min.y, max.z ), w, 0, 0, clr ) -- Left Face Bottom
    render.DrawBeam( Vector( max.x, min.y, max.z ), Vector( max.x, min.y, min.z ), w, 0, 0, clr ) -- Front Face Left

    render.DrawBeam( Vector( min.x, max.y, max.z ), Vector( min.x, max.y, min.z ), w, 0, 0, clr ) -- Back Face Right
    render.DrawBeam( Vector( max.x, max.y, min.z ), Vector( min.x, max.y, min.z ), w, 0, 0, clr ) -- Right Face Top
    render.DrawBeam( Vector( max.x, max.y, min.z ), Vector( max.x, min.y, min.z ), w, 0, 0, clr ) -- Front Face Top

    clr.a = clr.a - 50

    render.DrawBox( mid, angle_zero, lmin, lmax, clr )
    render.DrawBox( min, angle_zero, -offset, offset, Color( 0, 255, 255, 200 ), true )
    render.DrawBox( max, angle_zero, -offset, offset, Color( 255, 0, 0,200 ), true )

    return mid, lmin, lmax
end

/*
*   design :: material
*
*   @param  : int x
*   @param  : int y
*   @param  : int w
*   @param  : int h
*   @param  : str, imaterial mat
*   @param  : clr clr
*/

function design.mat( x, y, w, h, mat, clr )
    local src = materials:valid( mat ) and mat or istable( mat ) and mat.material or isstring( mat ) and mat
    src = isstring( src ) and Material( src, 'noclamp smooth' ) or src or Material( 'pp/colour' )
    clr = IsColor( clr ) and clr or Color( 255, 255, 255, 255 )

    surface.SetMaterial( src )
    surface.SetDrawColor( clr )
    surface.DrawTexturedRect( x, y, w, h )
end

/*
*   design :: material rotated
*
*   @param  : int x
*   @param  : int y
*   @param  : int w
*   @param  : int h
*   @param  : int r
*   @param  : str, imaterial mat
*   @param  : clr clr
*/

function design.mat_r( x, y, w, h, r, mat, clr )
    r   = isnumber( r ) and r or 0
    mat = isstring( mat ) and Material( mat, 'noclamp smooth' ) or mat
    clr = IsColor( clr ) and clr or Color( 255, 255, 255, 255 )

    surface.SetMaterial( mat )
    surface.SetDrawColor( clr )
    surface.DrawTexturedRectRotated( x, y, w, h, r )
end

/*
*   design :: rounded box
*
*   @param  : int r
*   @param  : int x
*   @param  : int y
*   @param  : int w
*   @param  : int h
*   @param  : clr clr
*/

function design.rbox( r, x, y, w, h, clr )
    r = r or 0
    x = x or 0
    y = y or 0
    w = w or ScrW( )
    h = h or ScrH( )
    clr = IsColor( clr ) and clr or Color( 0, 0, 0, 255 )

    if r <= 0 then
        design.box( x, y, w, h, clr )
        return
    end

    draw.RoundedBox( r, x, y, w, h, clr )
end

/*
*   design :: rounded box :: advanced
*
*   @param  : int bsize
*   @param  : int x
*   @param  : int y
*   @param  : int w
*   @param  : int h
*   @param  : clr clr
*   @param  : bool tl
*   @param  : bool tr
*   @param  : bool bl
*   @param  : bool br
*/

function design.rbox_adv( bsize, x, y, w, h, clr, tl, tr, bl, br )

    clr = IsColor( clr ) and clr or Color( 0, 0, 0, 255 )

    surface.SetDrawColor( clr.r, clr.g, clr.b, clr.a )

    if bsize <= 0 then
        surface.DrawRect( x, y, w, h )
        return
    end

    x = math.Round( x )
    y = math.Round( y )
    w = math.Round( w )
    h = math.Round( h )

    bsize = math.min( math.Round( bsize ), math.floor( w / 2 ) )

    surface.DrawRect( x + bsize, y, w - bsize * 2, h )
    surface.DrawRect( x, y + bsize, bsize, h - bsize * 2 )
    surface.DrawRect( x + w - bsize, y + bsize, bsize, h - bsize * 2 )

    local tex_id = helper._corners[ 'corner_8' ]
    if ( bsize > 8 ) then tex_id = helper._corners[ 'corner_16' ] end
    if ( bsize > 16 ) then tex_id = helper._corners[ 'corner_32' ] end
    if ( bsize > 32 ) then tex_id = helper._corners[ 'corner_64' ] end
    if ( bsize > 64 ) then tex_id = helper._corners[ 'corner_512' ] end

    local tex = surface.GetTextureID( tex_id )
    surface.SetTexture( tex )

    if tl then
        surface.DrawTexturedRectUV( x, y, bsize, bsize, 0, 0, 1, 1 )
    else
        surface.DrawRect( x, y, bsize, bsize )
    end

    if tr then
        surface.DrawTexturedRectUV( x + w - bsize, y, bsize, bsize, 1, 0, 0, 1 )
    else
        surface.DrawRect( x + w - bsize, y, bsize, bsize )
    end

    if bl then
        surface.DrawTexturedRectUV( x, y + h -bsize, bsize, bsize, 0, 1, 1, 0 )
    else
        surface.DrawRect( x, y + h - bsize, bsize, bsize )
    end

    if br then
        surface.DrawTexturedRectUV( x + w - bsize, y + h - bsize, bsize, bsize, 1, 1, 0, 0 )
    else
        surface.DrawRect( x + w - bsize, y + h - bsize, bsize, bsize )
    end

end

/*
*   design :: outlined box
*
*   @param  : int x
*   @param  : int y
*   @param  : int w
*   @param  : int h
*   @param  : clr m_clr
*   @param  : clr b_clr
*/

function design.obox( x, y, w, h, m_clr, b_clr )
    local i, n = 1, 2
    m_clr = IsColor( m_clr ) and m_clr or Color( 0, 0, 0, 255 )
    b_clr = IsColor( b_clr ) and b_clr or Color( 255, 255, 255, 255 )

    surface.SetDrawColor        ( m_clr )
    surface.DrawRect            ( x + i, y + i, w - n, h - n )
    surface.SetDrawColor        ( b_clr )
    surface.DrawOutlinedRect    ( x, y, w, h )
end

/*
*   design :: outlined box thick
*
*   @param  : int x
*   @param  : int y
*   @param  : int w
*   @param  : int h
*   @param  : clr m_clr
*   @param  : int b_wide
*/

function design.obox_th( x, y, w, h, m_clr, b_wide )
    m_clr   = IsColor( m_clr ) and m_clr or Color( 0, 0, 0, 255 )
    b_wide  = isnumber( b_wide ) and b_wide or 1

    surface.SetDrawColor( m_clr )
    for i = 0, b_wide - 1 do
        surface.DrawOutlinedRect( x + i, y + i, w - i * 2, h - i * 2 )
    end
end

/*
*   design :: text
*
*   ::  align enums
*       0   ::  TEXT_ALIGN_LEFT
*       1   ::  TEXT_ALIGN_CENTER
*       2   ::  TEXT_ALIGN_RIGHT
*       3   ::  TEXT_ALIGN_TOP
*       4   ::  TEXT_ALIGN_BOTTOM
*    
*   @param  : str text
*   @param  : int x
*   @param  : int y
*   @param  : clr clr
*   @param  : str fnt
*   @param  : enum align_x
*   @param  : enum align_y
*   @return : w, h
*/

function design.text( text, x, y, clr, fnt, align_x, align_y )
    text        = tostring( text ) or 'missing text'
    x           = isnumber( x ) and x or 0
    y           = isnumber( y ) and y or 0
    clr         = IsColor( clr ) and clr or Color( 255, 255, 255, 255 )
    fnt         = isstring( fnt ) and fnt or ( pref( 'sys.text.default' ) )
    align_x     = align_x or TEXT_ALIGN_LEFT
    align_y     = align_y or TEXT_ALIGN_TOP

    surface.SetFont( fnt )
    local w, h = surface.GetTextSize( text )

    if ( align_x == TEXT_ALIGN_CENTER or align_x == RLIB_TALIGN_C ) then
        x = x - w / 2
    elseif ( align_x == TEXT_ALIGN_RIGHT or align_x == RLIB_TALIGN_R ) then
        x = x - w
    end

    if ( align_y == TEXT_ALIGN_CENTER or align_y == RLIB_TALIGN_C ) then
        y = y - h / 2
    elseif ( align_y == TEXT_ALIGN_BOTTOM or align_y == RLIB_TALIGN_B ) then
        y = y - h
    end

    surface.SetTextPos( math.ceil( x ), math.ceil( y ) )

    if IsColor( clr ) then
        local alpha = 255
        if ( clr.a ) then alpha = clr.a end
        surface.SetTextColor( clr.r, clr.g, clr.b, alpha )
    else
        surface.SetTextColor( 255, 255, 255, 255 )
    end

    surface.DrawText( text )

    return w, h
end

/*
*   design :: text_adv
*
*   works like design.text but with newlines & tabs
*   originally part of gmod lib
*
*   ::  align enums
*       0   ::  TEXT_ALIGN_LEFT
*       1   ::  TEXT_ALIGN_CENTER
*       2   ::  TEXT_ALIGN_RIGHT
*       3   ::  TEXT_ALIGN_TOP
*       4   ::  TEXT_ALIGN_BOTTOM
*    
*   @param  : str text
*   @param  : int x
*   @param  : int y
*   @param  : clr clr
*   @param  : enum align_x
*   @return : pos_x, pos_y
*/

function design.text_adv( text, x, y, clr, fnt, align_x )

    text        = tostring( text ) or 'missing text'
    x           = isnumber( x ) and x or 0
    y           = isnumber( y ) and y or 0
    clr         = IsColor( clr ) and clr or Color( 255, 255, 255, 255 )
    fnt         = isstring( fnt ) and fnt or ( pref( 'sys.text.default' ) )
    align_x     = align_x or TEXT_ALIGN_LEFT

    local pos_x, pos_y = x, y

    surface.SetFont( fnt )
    local size_w, size_h = surface.GetTextSize( '\n' )
    local tab_w = 50

    for str in string.gmatch( text, '[^\n]*' ) do
        if #str > 0 then
            if string.find( str, '\t' ) then
                for tabs, str_alt in string.gmatch( str, '(\t*)([^\t]*)' ) do
                    pos_x = math.ceil( ( pos_x + tab_w * math.max( #tabs - 1, 0 ) ) / tab_w ) * tab_w

                    if #str_alt > 0 then
                        design.text( str_alt, pos_x, pos_y, clr, fnt, align_x )

                        local w, _ = surface.GetTextSize( str_alt )
                        pos_x = pos_x + w
                    end
                end
            else
                design.text( str, pos_x, pos_y, clr, fnt, align_x )
            end
        else
            pos_x = x
            pos_y = pos_y + ( size_h / 2 )
        end
    end

    return pos_x, pos_y

end

/*
*   design :: title boxcat
*
*   displays a title and sets a category-style box to display to the right of the title with text being
*   autosized to fit within
*
*   @todo   : make a little more simple for next version
*
*   @param  : str title
*   @param  : str title_font
*   @param  : str cat
*   @param  : str cat_font
*   @param  : clr t_clr
*   @param  : clr b_clr
*   @param  : clr t_clr
*   @param  : int pos_x
*   @param  : int pos_y
*   @param  : int offset_x
*   @param  : int offset_y
*   @param  : int cat_w_os
*   @param  : int text_os_w
*/

function design.title_boxcat( title, title_fnt, cat, cat_fnt, t_clr, b_clr, c_clr, pos_x, pos_y, offset_x, offset_y, cat_w_os, text_os_w )
    if not title then return end
    if not title_fnt then return end

    cat         = isstring( cat ) and cat or 'no category'
    cat_fnt     = isstring( cat_fnt ) and cat_fnt or title_fnt
    t_clr       = IsColor( t_clr ) and t_clr or Color( 255, 255, 255, 255 )
    b_clr       = IsColor( b_clr ) and b_clr or Color( 0, 73, 156, 255 )
    c_clr       = IsColor( c_clr ) and c_clr or Color( 255, 255, 255, 255 )
    pos_x       = pos_x or 0
    pos_y       = pos_y or 15
    offset_x    = offset_x or 0
    offset_y    = offset_y or 0
    cat_w_os    = cat_w_os or 20
    text_os_w   = text_os_w or 0

    /*
    *   title variables
    */

    surface.SetFont( title_fnt )

    title                   = isstring( title ) and title or tostring( title )
    local title_w, title_h  = surface.GetTextSize( title )
    title_w                 = title_w + offset_x + 10

    /*
    *   cat variables
    */

    surface.SetFont( cat_fnt )

    cat                     = isstring( cat ) and cat or tostring( cat )
    local cat_w, cat_h      = surface.GetTextSize( cat )
    cat_h                   = cat_h + offset_y
    cat_w                   = cat_w + cat_w_os

    /*
    *   draw
    */

    draw.SimpleText( title, title_fnt, pos_x, pos_y, t_clr, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
    draw.RoundedBox( 4, pos_x + title_w, pos_y - ( cat_h / 2 ), cat_w, cat_h, b_clr )
    draw.SimpleText( cat:upper( ), cat_fnt, pos_x + title_w + ( cat_w / 2 ) - text_os_w, pos_y, c_clr, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
end

/*
*   design :: bokeh eff
*
*   @param  : int amt
*   @param  : int, tbl isize
*   @param  : int, tbl ispeed
*   @param  : clr, str clr
*   @return : int amt, tbl fx_bokeh
*/

function design:bokeh( amt, isize, ispeed, clr, alpha )
    amt = amt or 25

    if istable( isize ) then
        size_min, size_max = isize[ 1 ], isize[ 2 ]
    elseif isnumber( isize ) then
        size_min, size_max = isize, isize
    else
        size_min, size_max = 25, 25
    end

    if istable( ispeed ) then
        speed_min, speed_max = ispeed[ 1 ], ispeed[ 2 ]
    elseif isnumber( ispeed ) then
        speed_min, speed_max = ispeed, ispeed
    else
        speed_min, speed_max = 20, 20
    end

    alpha = isnumber( alpha ) and alpha or 100

    local fx_bokeh = { }

    local clr_r, clr_g, clr_b, clr_a = 255, 255, 255, alpha
    if ( amt >= 1 ) then
        local wsize, hsize = ScrW( ), ScrH( )
        for n = 1, amt do
            if IsColor( clr ) then
                clr_r, clr_g, clr_b, clr_a = clr.r, clr.g, clr.b, alpha
            elseif clr == 'random' then
                clr_r, clr_g, clr_b, clr_a = math.random( 0, 255 ), math.random( 0, 255 ), math.random( 0, 255 ), alpha
            end
            fx_bokeh[ n ] =
            {
                xpos    = math.random( 0, wsize ),
                ypos    = math.random( -hsize, hsize ),
                size    = math.random( size_min, size_max ),
                clr     = Color( clr_r, clr_g, clr_b, clr_a ),
                speed   = math.random( speed_min, speed_max ),
                area    = math.Round( math.random( -50, 150 ) ),
            }
        end
        return amt, fx_bokeh
    end
end

/*
*   design :: bokeh fx
*
*   @assoc  : helper._bokehfx
*
*   @param  : int w
*   @param  : int h
*   @param  : int amt
*   @param  : tbl object
*   @param  : tbl fx
*   @param  : str selected
*   @param  : int speed
*   @param  : int offset
*/

function design:bokehfx( w, h, amt, object, fx, selected, speed, offset )
    fx = fx or helper._bokehfx
    local fx_type = fx[ selected or 'gradients' ]

    if not fx_type then return end

    speed = speed or 30
    offset = offset or 0

    surface.SetMaterial( Material( fx_type, 'noclamp smooth' ) )

    local count = table.Count( object )
    if count > 0 then
        for n = 1, amt do
            object[ n ].xpos = object[ n ].xpos + ( object[ n ].area * math.cos( n ) / count )
            object[ n ].ypos = object[ n ].ypos + ( math.sin( offset ) / ( speed + 10 ) + object[ n ].speed / speed )

            -- generate new fx when others go outside screen h
            if object[ n ].ypos > h then
                object[ n ].ypos = math.random( -100, 0 )
                object[ n ].xpos = math.random( 0, w )
            end
        end

        for n = 1, amt do
            local clr_r, clr_g, clr_b, clr_a = object[ n ].clr.r, object[ n ].clr.g, object[ n ].clr.b, object[ n ].clr.a
            surface.SetDrawColor( Color( clr_r, clr_g, clr_b, clr_a ) or Color( 255, 255, 255, 5 ) )
            surface.DrawTexturedRect( object[ n ].xpos, object[ n ].ypos, object[ n ].size, object[ n ].size )
        end
    end
end

/*
*   design :: arc
*
*   @param  : int x
*   @param  : int y
*   @param  : int radius
*   @param  : int thickness
*   @param  : int pos_s
*   @param  : int pos_e
@   @param  : clr
*/

function design.arc( x, y, radius, thickness, pos_s, pos_e, clr )
    local cir_o     = { }
    local cir_i     = { }
    pos_s           = math.floor( pos_s )
    pos_e           = math.floor( pos_e )
    clr             = IsColor( clr ) and clr or Color( 0, 0, 0, 255 )

    if pos_s > pos_e then
        local swap  = pos_e
        pos_e       = pos_s
        pos_s       = swap
    end

    local inr = radius - thickness
    for i = pos_s, pos_e do
        local a = math.rad( i )
        table.insert( cir_i, { x = x + ( math.cos( a ) ) * inr, y = y + ( -math.sin( a ) ) * inr } )
    end

    for i = pos_s, pos_e do
        local a = math.rad( i )
        table.insert( cir_o, { x = x + ( math.cos( a ) ) * radius, y = y + ( -math.sin( a ) ) * radius } )
    end

    local comcir = { }
    for i = 0, #cir_i * 2 do
        local p, q, r
        p       = cir_o[ math.floor( i / 2 ) + 1 ]
        r       = cir_i[ math.floor( ( i + 1 ) / 2 ) + 1 ]
        if i % 2 == 0 then
            q   = cir_o[ math.floor( ( i + 1 ) / 2 ) ]
        else
            q   = cir_i[ math.floor( ( i + 1 ) / 2 ) ]
        end
        table.insert( comcir, { p, q, r } )
    end

    draw.NoTexture( )
    surface.SetDrawColor( clr )

    for k, v in ipairs( comcir ) do
        surface.DrawPoly( v )
    end

end

/*
*   design :: arc :: circle
*
*   @param  : int x
*   @param  : int y
*   @param  : int radius
*/

function design.arc_circle( x, y, radius )
    local cir   = { }
    local seg   = 100
    table.insert( cir, { x = x, y = y, u = 0.5, v = 0.5 } )
    for i = 0, seg do
        local a = math.rad( ( i / seg ) * -360 )
        table.insert( cir, { x = x + math.sin( a ) * radius, y = y + math.cos( a ) * radius, u = math.sin( a ) / 2 + 0.5, v = math.cos( a ) / 2 + 0.5 } )
    end

    local a = math.rad( 0 )
    table.insert( cir, { x = x + math.sin( a ) * radius, y = y + math.cos( a ) * radius, u = math.sin( a ) / 2 + 0.5, v = math.cos( a ) / 2 + 0.5 } )

    surface.DrawPoly( cir )
end

/*
*   design :: arc :: tri
*
*   @param  : int posx
*   @param  : int posy
*   @param  : int radius
*   @param  : int thickness
*   @param  : int roughness
@   @param  : clr
*/

function design.arc_tri( posx, posy, radius, thickness, startang, endang, roughness )
    local triarc    = { }
    local deg2rad   = math.pi / 180

    local startang, endang = startang or 0, endang or 0
    if startang < endang then
        local temp  = startang
        startang    = endang
        endang      = temp
        temp        = nil
    end

    roughness           = math.max( roughness or 1, 1 )
    local step          = roughness
    step                = math.abs( roughness ) * -1

    local inner = { }
    local r = radius - thickness
    for deg = startang, endang, step do
        local rad = deg2rad * deg
        table.insert( inner,
        {
            x = posx + ( math.sin( rad ) * r ),
            y = posy - ( math.cos( rad ) * r )
        })
    end

    local outer = { }
    for deg = startang, endang, step do
        local rad = deg2rad * deg
        table.insert( outer, {
            x = posx + ( math.sin( rad ) * radius ),
            y = posy - ( math.cos( rad ) * radius )
        })
    end

    for tri = 1, table.Count( inner ) * 2 do
        local p1, p2, p3
        p1 = outer[ math.floor( tri / 2 ) + 1 ]
        p3 = inner[ math.floor( ( tri + 1 ) / 2 ) + 1 ]
        if tri % 2 == 0 then
            p2 = outer[ math.floor( ( tri + 1 ) / 2 ) ]
        else
            p2 = inner[ math.floor( ( tri + 1 ) / 2 ) ]
        end

        table.insert( triarc, {p1, p2, p3} )
    end

    return triarc

end

/*
*   design :: arc :: tri :: draw poly
*/

function design.arc_drawpoly( arc )
	for k, v in ipairs( arc ) do
		surface.DrawPoly( v )
	end
end

/*
*   design :: triarc :: draw
*/

function design.arc_tri_draw( posx, posy, radius, thickness, startang, endang, roughness, color )
	design.arc_drawpoly( design.arc_tri( posx, posy, radius, thickness, startang, endang, roughness ) )
end

/*
*   design :: circle
*
*   @param  : int x
*   @param  : int y
*   @param  : int radius
*   @param  : int seg
@   @param  : clr
*/

function design.circle( x, y, radius, seg, clr )
    y       = isnumber( y ) and y or 0
    x       = isnumber( x ) and x or 0
    radius  = isnumber( radius ) and radius or 10
    seg     = isnumber( seg ) and seg or 20
    clr     = IsColor( clr ) and clr or Color( 0, 0, 0, 255 )

    local cir = { }
    table.insert( cir, { x = x, y = y, u = 0.5, v = 0.5 } )
    for i = 0, seg do
        local a = math.rad( ( i / seg ) * -360 )
        table.insert( cir, { x = x + math.sin( a ) * radius, y = y + math.cos( a ) * radius, u = math.sin( a ) / 2 + 0.5, v = math.cos( a ) / 2 + 0.5 } )
    end

    local a = math.rad( 0 )
    table.insert( cir, { x = x + math.sin( a ) * radius, y = y + math.cos( a ) * radius, u = math.sin( a ) / 2 + 0.5, v = math.cos( a ) / 2 + 0.5 } )

    surface.SetDrawColor( clr )
    draw.NoTexture( )
    surface.DrawPoly( cir )
end

/*
*   design :: circle stencil
*
*   @param  : int x
*   @param  : int y
*   @param  : int radius
*   @param  : clr clr
*/

function design.circle_sten( x, y, radius, clr )
    local p = { }
    local a = 40
    local c = 360
    local r = radius

    for n = 0, a do
        p[ n + 1 ] =
        {
            x = math.sin(-math.rad( n / a * c ) ) * r + x,
            y = math.cos(-math.rad( n / a * c ) ) * r + y
        }
    end

    draw.NoTexture( )
    surface.SetDrawColor( clr )
    surface.DrawPoly( p )
end

/*
*   design :: circle_t2_g
*
*   used in conjunction with ct2
*
*   @param  : int xpos
*   @param  : int ypos
*   @param  : int radius
*   @param  : int seg
*/

function design.circle_t2_g( xpos, ypos, radius, seg )
    local c = { }
    local u = 0.5
    local v = 0.5
    local s = seg
    local r = radius

    surface.SetTexture( 0 )
    table.insert( c,
    {
        x = xpos,
        y = ypos,
        u = u,
        v = v
    })

    for n = 0, s do
        local a = math.rad( (n / s ) * -360 )
        table.insert( c,
        {
            x = xpos + math.sin( a ) * r,
            y = ypos + math.cos( a ) * r,
            u = math.sin( a ) / 2 + u,
            v = math.cos( a ) / 2 + v
        })
    end

    local a = math.rad( 0 )
    table.insert( c,
    {
        x = xpos + math.sin( a ) * r,
        y = ypos + math.cos( a ) * r,
        u = math.sin( a ) / 2 + u,
        v = math.cos( a ) / 2 + v
    })

    return c
end

/*
*   design :: circle_t2
*
*   used in conjunction with circle_t2_g
*
*   @param  : int x
*   @param  : int y
*   @param  : int radius
*   @param  : int seg
*   @param  : clr clr
*/

function design.circle_t2( x, y, radius, seg, clr )
    surface.SetDrawColor( clr or Color( 0, 0, 0, 0 ) )
    surface.DrawPoly( design.circle_t2_g( x, y, radius, seg ) )
end

/*
*   design :: circle_anim_g
*
*   used in conjunction with circle_anim
*
*   @param  : int x
*   @param  : int y
*   @param  : int radius
*   @param  : int seg
*   @param  : int frac
*/

function design.circle_anim_g( x, y, radius, seg, frac )
    frac = frac or 1
    local poly = { }

    surface.SetTexture( 0 )
    table.insert( poly, { x = x, y = y, u = 0.5, v = 0.5 } )

    for i = 0, seg do
        local a = math.rad( ( i / seg ) * -360 * frac )
        table.insert( poly, { x = x + math.sin( a ) * radius, y = y + math.cos( a ) * radius, u = math.sin( a ) / 2 + 0.5, v = math.cos( a ) / 2 + 0.5 } )
    end

    local a = math.rad( 0 )
    table.insert( poly, { x = x, y = y, u = math.sin( a ) / 2 + 0.5, v = math.cos( a ) / 2 + 0.5 } )

    return poly
end

/*
*   design :: circle_anim
*
*   used in conjunction with circle_anim_g
*
*   @note   : frac = curr / 100
*
*   @param  : int x
*   @param  : int y
*   @param  : int radius
*   @param  : int seg
*   @param  : clr clr
*   @param  : int frac
*/

function design.circle_anim( x, y, radius, seg, clr, frac )
    surface.SetDrawColor( clr or Color( 0, 0, 0, 0 ) )
    surface.DrawPoly( design.circle_anim_g( x, y, radius, seg, frac ) )
end

/*
*   design :: circle :: simple
*
*   draws a simple circle without performance impact
*
*   @param  : int x
*   @param  : int y
*   @param  : int radius
*   @param  : clr clr
*/

function design.circle_simple( x, y, radius, clr )
    local diam, poly = 360, { }

    x           = isnumber( x ) and x or 0
    y           = isnumber( y ) and y or 0
    radius      = isnumber( radius ) and radius or 30

    for n = 1, diam do
        poly[ n ] = { }
        poly[ n ].x = x + math.cos( math.rad( n * diam ) / diam ) * radius
        poly[ n ].y = y + math.sin( math.rad( n * diam ) / diam ) * radius
    end

    if clr then
        surface.SetDrawColor( clr or Color( 0, 0, 0, 255 ) )
        draw.NoTexture( )
    end

    surface.DrawPoly( poly )
end

/*
*   design :: circle :: simple
*
*   draws a circle with numerous layers pushing outward
*
*   @param  : int x
*   @param  : int y
*   @param  : int radius
*   @param  : clr clr
*   @param  : clr clr2
*   @param  : clr clr3
*/

function design.circle_ol( x, y, radius, clr, clr2, clr3 )
    local diam, poly, poly2, poly3 = 360, { }, { }, { }

    x           = isnumber( x ) and x or 0
    y           = isnumber( y ) and y or 0
    radius      = isnumber( radius ) and radius or 30
    
    for n = 1, diam do
        poly[ n ] = { }
        poly[ n ].x = x + math.cos( math.rad( n * diam ) / diam ) * radius
        poly[ n ].y = y + math.sin( math.rad( n * diam ) / diam ) * radius
    end

    for n = 1, diam do
        poly2[ n ] = { }
        poly2[ n ].x = x + math.cos( math.rad( n * diam ) / diam ) * ( radius - 10 )
        poly2[ n ].y = y + math.sin( math.rad( n * diam ) / diam ) * ( radius - 10 )
    end

    for n = 1, diam do
        poly3[ n ] = { }
        poly3[ n ].x = x + math.cos( math.rad( n * diam ) / diam ) * ( radius - 20 )
        poly3[ n ].y = y + math.sin( math.rad( n * diam ) / diam ) * ( radius - 20 )
    end

    if clr then
        surface.SetDrawColor( clr )
        draw.NoTexture( )
    end

    surface.DrawPoly( poly )

    if clr2 then
        surface.SetDrawColor( clr2 )
        draw.NoTexture( )
    end

    surface.DrawPoly( poly2 )

    if clr3 then
        surface.SetDrawColor( clr3 )
        draw.NoTexture( )
    end

    surface.DrawPoly( poly3 )

end

/*
*   design :: stencils
*/

function design.StencilStart( v )
    render.ClearStencil( )
    render.SetStencilEnable( true )
    render.SetStencilWriteMask( 1 )
    render.SetStencilTestMask( 1 )
    render.SetStencilFailOperation( STENCILOPERATION_REPLACE )
    render.SetStencilPassOperation( STENCILOPERATION_ZERO )
    render.SetStencilZFailOperation( STENCILOPERATION_ZERO )
    render.SetStencilCompareFunction( STENCILCOMPARISONFUNCTION_NEVER )
    render.SetStencilReferenceValue( v or 1 )
end

function design.StencilReplace( v )
    render.SetStencilFailOperation( STENCILOPERATION_ZERO )
    render.SetStencilPassOperation( STENCILOPERATION_REPLACE )
    render.SetStencilZFailOperation( STENCILOPERATION_ZERO )
    render.SetStencilCompareFunction( STENCILCOMPARISONFUNCTION_EQUAL )
    render.SetStencilReferenceValue( v or 1 )
end

function design.StencilEnd( )
    render.SetStencilEnable( false )
end

/*
*   design :: indicator
*
*   @param  : str text
*   @param  : str uid
*   @param  : str, imat mat
*   @param  : int ftop
*   @param  : int ttop
*   @param  : str font
*   @param  : int dur
*/

function design.indicator( text, uid, mat, ftop, ttop, font, dur )
    if not isstring( text ) then return end

    uid     = uid or helper.new.id( 10 )
    mat     = mat or nil
    ftop    = ftop or -20
    ttop    = ttop or 85
    font    = font or pref( 'sys.hud.indicator' )
    dur     = isnumber( dur ) and dur or 3

    local fade_time     = 0.3
    local start_time    = CurTime( )
    local alpha         = 255

    local mat_indicator = mat and Material( mat, 'noclamp smooth' ) or Material( 'gui/gradient_up', 'noclamp smooth' )
    local function draw2screen( )
        local anim_time = CurTime( ) - start_time
        if alpha < 0 then alpha = 0 end

        if anim_time > dur then
            hook.Remove( 'HUDPaint', uid .. 'd2s.indicator' )
            return
        end

        if ( fade_time - anim_time ) > 0 then
            alpha = ( fade_time - anim_time ) / fade_time
            alpha = 1 - alpha
            alpha = alpha * 255
        end

        if ( dur - anim_time ) < fade_time then
            alpha = ( dur - anim_time ) / fade_time
            alpha = alpha * 255
        end

        local clr_alpha = math.Clamp( alpha, 0, 255 )

        if mat_indicator then
            surface.SetDrawColor( Color( 255, 255, 255, clr_alpha ) )
            surface.SetMaterial( mat_indicator )
            surface.DrawTexturedRect( ScrW( ) / 2 - ( 200 / 2 ), ftop, 200, 200 )
        end

        draw.SimpleText( text, font, ScrW( ) / 2, ttop, Color( 255, 255, 255, clr_alpha ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
    end
    hook.Add( 'HUDPaint', uid .. 'd2s.indicator', draw2screen )
end

/*
*   design :: indicator :: type 2
*
*   indicator that slides in bars from top and bottom, with text in the middle
*
*   @param  : str text
*   @param  : str text_sub
*   @param  : str uid
*   @param  : str font
*   @param  : str font2
*   @param  : int dur
*/

function design.indicator_t2( text, text_sub, uid, font, font2, dur )
    if not isstring( text ) then return end

    uid     = uid or helper.new.id( 10 )
    font    = font or pref( 'sys.hud.s2.indicator' )
    font2   = font2 or pref( 'sys.hud.s2.indicator.sub' )
    dur     = isnumber( dur ) and dur or 8

    /*
    *   load materials
    */

    local mat_top       = Material( 'rlib/interface/grunge/deco/dividers/glow_w_full_02.png', 'noclamp smooth' )
    local mat_btm       = Material( 'rlib/interface/grunge/deco/dividers/glow_w_full_02.png', 'noclamp smooth' )
    local grad          = Material( 'gui/center_gradient', 'noclamp smooth' )

    local fade_time     = 2
    local start_time    = CurTime( )
    local alpha         = 255

    local tbar_pos      = 0
    local bbar_pos      = ScrH( )

    local bar_top_pos_s = 0
    local bar_top_pos_e = ScrH( ) / 2 - 100

    local bar_btm_pos_s = ScrH( )
    local bar_btm_pos_e = ScrH( ) / 2 + 100

    local function draw2screen( )
        local anim_time = CurTime( ) - start_time
        if alpha < 0 then alpha = 0 end

        bar_top_pos_s = math.Approach( bar_top_pos_s, bar_top_pos_e, FrameTime( ) * 500 )
        bar_btm_pos_s = math.Approach( bar_btm_pos_s, bar_btm_pos_e, FrameTime( ) * 500 )

        if anim_time > dur then
            hook.Remove( 'HUDPaint', uid .. 'd2s.indicator' )
            return
        end

        if ( fade_time - anim_time ) > 0 then
            alpha = ( fade_time - anim_time ) / fade_time
            alpha = 1 - alpha
            alpha = alpha * 255
        end

        if ( dur - anim_time ) < fade_time then
            alpha = ( dur - anim_time ) / fade_time
            alpha = alpha * 255
        end

        local clr_alpha = math.Clamp( alpha, 0, 255 )

        design.mat(  ( ScrW( ) / 2 ) - ( ScrW( ) / 2 ), ( ScrH( ) / 2 ) - ( 200 / 2 ) + ( 36 / 2 ), ScrW( ), 200, grad, Color( 5, 5, 5, clr_alpha ) )
        design.mat( ( ScrW( ) / 2 ) - ( 512 / 2 ), bar_top_pos_s, 512, 36, mat_top, Color( 255, 255, 255, clr_alpha ) )
        draw.SimpleText( text, font, ScrW( ) / 2, ScrH( ) / 2 - 10, Color( 255, 255, 255, clr_alpha ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
        draw.SimpleText( text_sub, font2, ScrW( ) / 2, ScrH( ) / 2 + 40, Color( 195, 136, 45, clr_alpha ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
        design.mat( ( ScrW( ) / 2 ) - ( 512 / 2 ), bar_btm_pos_s, 512, 36, mat_btm, Color( 255, 255, 255, clr_alpha ) )

    end
    hook.Add( 'HUDPaint', uid .. 'd2s.indicator', draw2screen )
end

/*
*   design :: notify
*
*   displays a simple slide-in notification box that will allow players to see when something has happened.
*   param 'startpos' determines pos to start from
*       1   : top
*       2   : bottom
*       3   : middle
*
*   param bFull will force width of notification to be full-screen
*
*   @call   : SERVER        pmeta:notify( ... )
*           : CLIENT        design:notify( 1, 'Message', 5, 2 )
*
*   @param  : int, str, tbl, clr mtype
*   @param  : str msg
*   @param  : int duration
*   @param  : int startpos
*   @param  : bool bFull
*/

function design:notify( mtype, msg, duration, startpos, bFull )

    /*
    *   destroy existing
    */

    ui:destroy_visible( rlib.notify )

    /*
    *   mtype colorization
    */

    local clr_bg, clr_text = Color( 30, 30, 30, 255 ), Color( 255, 255, 255, 255 )
    if mtype and mtype ~= 'def' then
        if IsColor( mtype ) then
            clr_bg = mtype
        elseif isnumber( mtype ) then
            clr_bg = base._def.lc_rgb[ mtype ]
        elseif istable( mtype ) and not IsColor( mtype ) then
            clr_bg = mtype.clr_bg or Color( 30, 30, 30, 255 )
            clr_text = mtype.clr_text or Color( 255, 255, 255, 255 )
        end
    end

    if not msg then
        mtype, msg = 2, 'an error occured'
    end

    duration = isnumber( duration ) and duration or 10
    startpos = isnumber( startpos ) and startpos or 1

    surface.SetFont( pref( 'sys.notify.text' ) )

    local ui_w, ui_h    = ScrW( ), draw.GetFontHeight( pref( 'sys.notify.text' ) ) + 18
    local sz_w, sz_h    = bFull and ScrW( ) or surface.GetTextSize( msg )
    sz_w                = ( bFull and sz_w ) or ( sz_w + 100 )

    local pos_w         = ( ui_w / 2 ) - ( sz_w / 2 )
    local pos_h         = ( startpos == 2 and ( ScrH( ) - ui_h ) ) or ( startpos == 3 and ScrH( ) / 3 ) or 5
    local pos_m2        = ( startpos == 2 and ( ScrH( ) ) ) or ( startpos == 3 and d ) or -ui_h

    /*
    *   btn :: close
    */

    local obj       = ui.new( 'btn'         )
    :bsetup         (                       )
    :size           ( sz_w, ui_h            )
    :pos            ( pos_w, pos_h          )
    :front          (                       )
    :aligntop       ( pos_m2                )
    :textadv        ( clr_text, pref( 'sys.notify.text' ), msg )
    :m2f            (                       )

                    :oc( function ( s )
                        if s.action_close then return end
                        s.action_close = true
                        s:Stop( )
                        s:MoveTo( pos_w, pos_m2, 0.5, 0, -1, function( )
                            ui:destroy_visible( s )
                        end )
                    end )

                    :draw( function( s, w, h )
                        local pulse     = math.abs( math.sin( CurTime( ) * 2 ) * 255 )
                        pulse           = math.Clamp( pulse, 125, 175 )

                        design.box( 3, 2, w - 6, h - 4, Color( 0, 0, 0, 200 ) )
                        design.box( 4, 3, w - 8, h - 6, clr_bg )
                        design.box( 4, 3, w - 8, h - 6, Color( 0, 0, 0, pulse ) )
                    end )

                    :think( function( s )
                        s:SetZPos( 5000 )
                    end )

    /*
    *  notice sound
    */

    surface.PlaySound( cfg.dialogs.audio )

    /*
    *  display notice
    */

    if ui:valid( obj ) then
        rlib.notify = obj

        obj:MoveTo( pos_w, pos_h, 0.5, 0, -1, function( )
            obj:MoveTo( pos_w, pos_m2, 0.5, duration, -1, function( )
                ui:destroy_visible( obj )
            end )
        end )
    end
end

/*
*   design :: notify :: adv
*
*   an advanced notification feature which displays a msg on-screen with borders on top and bottom
*   has the ability to hold TAB in order to close out the notification before the destroy timer actually
*   expires.
*
*   will temp disable the scoreboard while active so that the KEY_TAB actually closes the notification
*   instead of toggling the scoreboard. this however wont be needed if the server owner decides to change
*   the key to something else besides the default tab key
*
*   @param  : str icon
*   @param  : str title
    @param  : str message
*   @param  : int delay
*/

function design.notify_adv( icon, title, message, delay )

    if not title then return end
    if not message then return end

    local msg               = helper.str:crop( message, 300, pref( 'sys.dialog.msg' ) )
    local text_w, text_h    = surface.GetTextSize( msg )
    local timer_id          = prefix .. 'notice.timer'

    timex.expire( timer_id )

    /*
    *   localized vars
    */

    local fadein_run	    = 1             -- time to fade in
    local fadeout_run	    = 0.5           -- time to fade out
    local alpha			    = 255           -- starting alpha
    local start			    = CurTime( )    -- start time
    local m_ctime           = CurTime( )
    local dtime			    = 0
    local key_convert 	    = input.GetKeyName( KEY_TAB )

    delay = delay or 8

    /*
    *   think
    *
    *   check to see if notice panel is valid and that binded cancel key is pressed. if both are true,
    *   kill timers, hooks, and the panel to cancel the entire active notice action
    */

    hook.Add( 'Think', prefix .. 'design.key.cancel', function( )
        if input.IsKeyDown( KEY_TAB ) and ui:visible( ui.ui_notifyadv ) then
            timex.expire( timer_id )
            hook.Remove( 'Think', prefix .. 'design.key.cancel' )
            hook.Remove( 'ScoreboardShow', prefix .. 'design.key.cancel.scoreboard' )
            ui:destroy( ui.ui_notifyadv )
        end
    end )

    /*
    *	scoreboardshow
    *
    *	while a dialog is active, disallow the scoreboard from showing when the default cancel key 
    *   is pressed ( KEY_TAB ). once the action has completed, return the scoreboard functionality back
    *   to normal.
    *
    *	this hook isnt needed if the server owner changes the default keybind to any other key besides
    *   the default one ENUM:( KEY_TAB )
    */

    hook.Add( 'ScoreboardShow', prefix .. 'design.key.cancel.scoreboard', function( )
        if ui:valid( ui.ui_notifyadv ) and input.IsKeyDown( KEY_TAB ) then
            return false
        end
        return true
    end )

    /*
    *   draw to screen
    *
    *   displays the dialog for player
    */

    local function draw2screen( )
        ui:destroy_visible( ui.ui_notifyadv )

        ui.ui_notifyadv = vgui.Create( 'DPanel' )
        ui.ui_notifyadv:SetSize( ScrW( ), ScrH( ) )
        ui.ui_notifyadv:SetPos( 0, 0 )
        ui.ui_notifyadv:MoveToFront( )
        ui.ui_notifyadv:MakePopup( )
        ui.ui_notifyadv.Paint = function( s, w, h )
            delay = math.Clamp( delay, 0, delay )
            dtime = CurTime( ) - start
            if alpha < 0 then
                alpha = 0
            end

            -- fade in math
            if fadein_run - dtime > 0 then
                alpha = ( fadein_run - dtime ) / fadein_run -- 0 to 1
                alpha = 1 - alpha -- Reverse
                alpha = alpha * 255
            end

            -- fade out math
            if delay - dtime < fadeout_run then
                alpha = ( delay - dtime ) / fadeout_run + fadeout_run -- 0 to 1
                alpha = alpha * 255
            end

            local c_alpha           = math.Clamp( alpha, 0, 255 )
            local c_alpha_box       = math.Clamp( alpha, 0, 255 )
            local c_alpha_obox      = math.Clamp( alpha, 0, 100 )
            local grad_m            = Material( cfg.dialogs.mat_gradient or 'gui/center_gradient' )
            local grad_w, grad_h    = w * 0.70, 70

            local clr_primary = cfg.dialogs.clrs.primary
            design.mat( w / 2 - ( grad_w / 2 ), h / 2 - ( grad_h / 2 ), grad_w, grad_h, grad_m, Color( clr_primary.r, clr_primary.g, clr_primary.b, c_alpha ) )

            -- top and bottom primary rect
            design.box( 0, 0, w, h * .10, Color( clr_primary.r, clr_primary.g, clr_primary.b, c_alpha_box ) )
            design.box( 0, h - h * .10, w, h * .10, Color( clr_primary.r, clr_primary.g, clr_primary.b, c_alpha_box ) )

            -- 10% rect on edge of primary boxes
            local brder_h = 4
            local clr_secondary = cfg.dialogs.clrs.secondary
            design.box( 0, h * .10 - brder_h, w, brder_h, Color( clr_secondary.r, clr_secondary.g, clr_secondary.b, c_alpha_obox ) )
            design.box( 0, h - h * .10, w, brder_h, Color( clr_secondary.r, clr_secondary.g, clr_secondary.b, c_alpha_obox ) )

            -- icons
            if icon then
                local clr_icon = cfg.dialogs.clrs.icons
                design.mat( w / 2 - 32, h / 2 - 100, 64, 64, icon, Color( clr_icon.r, clr_icon.g, clr_icon.b, c_alpha ) )
            end

            -- text
            local clr_text = cfg.dialogs.clrs.primary_text
            design.text( title, w / 2, h / 2 - 13, Color( clr_text.r, clr_text.g, clr_text.b, c_alpha ), pref( 'sys.dialog.title' ), 1, 1 )
            design.text( message, w / 2, h / 2 + 17, Color( clr_text.r, clr_text.g, clr_text.b, c_alpha ), pref( 'sys.dialog.msg' ), 1, 1 )
            design.text( lang( 'dialog_key_close', key_convert ), w / 2, h - h * .10 / 2 + 15, Color( clr_text.r, clr_text.g, clr_text.b, c_alpha ), pref( 'sys.dialog.qclose' ), 1, 1 )

            local time          = math.Remap( CurTime( ) - m_ctime, 0, delay, w, 0 )
            local blk_w         = time * 0.20
            local blk_center    = w / 2 - ( blk_w / 2 )
            local clr_prog      = cfg.dialogs.clrs.progress

            design.box( blk_center, h - h * .10 / 2 - 10, blk_w, 10, Color( clr_prog.r, clr_prog.g, clr_prog.b, c_alpha ) )

        end
    end
    draw2screen( )

    /*
    *  notice sound
    */

    surface.PlaySound( cfg.dialogs.audio )

    /*
    *   destroy hudpaint hook when timer has elapsed
    *
    *   @param  : bool bForce
    */

    local function destroy_timer( bForce )
        if timex.exists( timer_id ) and not bForce then return end
        timex.create( timer_id, delay + 1, 1, function( )
            timex.expire( timer_id )
            hook.Remove( 'Think', prefix .. 'design.key.cancel' )
            hook.Remove( 'ScoreboardShow', prefix .. 'design.key.cancel.scoreboard' )
            ui:destroy( ui.ui_notifyadv )
        end )
    end
    destroy_timer( )

end

/*
*   design :: notify :: inform ( slider )
*
*   displays a notification that slides in from the right; shows for a set duration, and then
*   slides back out to the right
*
*   @call   : design:inform( 1, 'example msg', 'mytitle', 5 )
*
*   @param  : int, str, tbl, clr mtype
*   @param  : str msg
*   @param  : str title
*   @param  : int duration
*/

function design:inform( mtype, msg, title, duration )

    /*
    *   destroy existing
    */

    ui:destroy( rlib.notify )

    /*
    *   mtype colorization
    */

    local clr_bg, clr_text = Color( 30, 30, 30, 255 ), Color( 255, 255, 255, 255 )
    if mtype and mtype ~= 'def' then
        if IsColor( mtype ) then
            clr_bg      = mtype
        elseif isnumber( mtype ) then
            clr_bg      = base._def.lc_rgb[ mtype ]
        elseif istable( mtype ) and not IsColor( mtype ) then
            clr_bg      = mtype.clr_bg or Color( 30, 30, 30, 255 )
            clr_text    = mtype.clr_text or Color( 255, 255, 255, 255 )
        end
    end

    if not msg then
        mtype, msg = 2, 'an error occured'
    end

    title                   = isstring( title ) and title or lang( 'notify_title_def' )
    duration                = isnumber( duration ) and duration or 10

    local message           = helper.str:crop( msg, ui:cscale( true, 220, 250, 260, 250, 260, 260, 270 ), pref( 'sys.dialog.slider.msg' ) )
    local text_w, text_h    = helper.str:len( message, pref( 'sys.dialog.slider.msg' ) )
    local m_ctime           = CurTime( )
    local val_max           = 300

    local pos_w, pos_h      = text_w + 90, 50 + text_h + 15
    pos_w                   = math.Clamp( pos_w, 230, val_max )

    /*
    *   pnl :: parent
    */

    local obj               = ui.new( 'pnl'                 )
    :size                   ( pos_w, pos_h                  )
    :pos                    ( ScrW( ), 200                  )

                            :draw( function( s, w, h )
                                design.box( 0, 0, w, h, Color( 35, 35, 35, 255 ) )
                            end )

    /*
    *   pnl :: header
    */

    local hdr               = ui.new( 'pnl', obj            )
    :static                 ( TOP                           )
    :margin                 ( 0                             )
    :tall                   ( 30                            )

                            :draw( function( s, w, h )
                                design.box( 0, 0, w, h, Color( 206, 129, 28, 150 ) )
                            end )

    /*
    *   pnl :: header :: sub
    */

    local hdr_sub           = ui.new( 'pnl', hdr            )
    :static                 ( FILL                          )
    :margin                 ( 0, 0, 6, 0                    )

                            :draw( function( s, w, h )
                                draw.SimpleText( title, pref( 'sys.dialog.slider.title' ), w / 2 + 3, 30 / 2 + 1, Color( 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
                            end )

    /*
    *   btn :: close
    */

    local b_close           = ui.new( 'btn', hdr_sub        )
    :bsetup                 (                               )
    :static                 ( RIGHT                         )
    :margin                 ( 5, 5, 5, 5                    )
    :size                   ( 21                            )
    :onhover                (                               )
    :textadv                ( Color( 255, 255, 255, 255 ), pref( 'sys.dialog.slider.exit' ), helper.get:utf8( 'close' ) )

                            :draw( function( s, w, h )
                                if s.hover then
                                    s:SetTextColor( Color( 25, 25, 25, 255 ) )
                                end
                            end )

                            :oc( function ( s )
                                gui.EnableScreenClicker( false )
                                ui:destroy( obj )
                            end )

    /*
    *   pnl :: body
    */

    local body              = ui.new( 'pnl', obj            )
    :nopaint                (                               )
    :static                 ( FILL                          )

    /*
    *   pnl :: body :: sub
    */

    local body_sub          = ui.new( 'pnl', body           )
    :nopaint                (                               )
    :static                 ( FILL                          )

    /*
    *   lbl :: msg
    */

    local contents          = ui.new( 'lbl', body_sub       )
    :static                 ( FILL                          )
    :margin                 ( 0, 3, 0, 0                    )
    :notext                 (                               )
    :align                  ( 5                             )

                            :draw( function( s, w, h )
                                draw.DrawText( message, pref( 'sys.dialog.slider.msg' ), s:GetWide() / 2, 10, Color( 255, 255, 255, 255 ) , TEXT_ALIGN_CENTER )
                            end )

    /*
    *   pnl :: ftr
    */

    local ftr               = ui.new( 'pnl', obj            )
    :nopaint                (                               )
    :static                 ( BOTTOM                        )
    :tall                   ( 6                             )

                            :draw( function( s, w, h )
                                local time          = math.Remap( CurTime( ) - m_ctime, 0, duration, w, 0 )
                                local blk_w         = time * 1
                                local blk_center    = w / 2 - ( blk_w / 2 )
                                local clr_prog      = cfg.dialogs.clrs.progress

                                design.box( blk_center, h - h * .10 / 2 - 10, blk_w, 10, clr_prog )
                            end )

    /*
    *  notice sound
    */

    surface.PlaySound( cfg.dialogs.audio )

    /*
    *  display notice
    */

    if ui:valid( obj ) then
        rlib.notify = obj

        obj:MoveTo( ScrW( ) - obj:GetWide( ) - 5, 200, 0.5, 0, -1, function( )
            obj:MoveTo( ScrW( ), 200, 0.5, duration, -1, function( )
                ui:destroy( obj )
            end )
        end )
    end

end

/*
*   design :: animted scrolling text
*
*   displays text from a starting position and forces the text to scroll upward as time passes with
*   fade in/out effects as it enters/leaves
*
*   returns the atime to a specified var which is used as the expiration time as part of the paint call.
*
*   @param  : str text
*   @param  : str uid
    @param  : tbl src
*   @param  : str font
*   @param  : clr clr
*   @param  : int dist
*   @param  : int atime
*   @return : int atime
*/

function design.anim_scrolltext( text, uid, src, font, clr, dist, atime )
    if not isstring( text ) then return end

    uid     = uid or helper.new.id( 10 )
    src     = istable( src ) and src or { }
    font    = font or pref( 'sys.draw.textscroll' )
    clr     = IsColor( clr ) and clr or Color( 255, 255, 255, 255 )
    dist    = isnumber( dist ) and dist or 0.5
    atime   = isnumber( atime ) and atime or 2

    local fade_time, start_time, alpha = 0.5, CurTime( ), 255
    local dur = atime

    local function draw2screen( )
        if not istable( src ) or #src < 1 then
            alpha, start_time, dur = 255, CurTime( ), atime
            return
        end

        local anim_time = CurTime( ) - start_time
        if alpha < 0 then alpha = 0 end

        if ( fade_time - anim_time ) > 0 then
            alpha = ( fade_time - anim_time ) / fade_time
            alpha = 1 - alpha
            alpha = alpha * 255
        end

        if ( dur - anim_time ) < fade_time then
            alpha = ( dur - anim_time ) / fade_time
            alpha = alpha * 255
        end

        local clr_alpha = math.Clamp( alpha, 0, 255 )

        for i = 1, #src do
            local item = src[ i ]

            if not item then return end

            design.text( text, item.x, item.y, Color( clr.r, clr.g, clr.b, clr_alpha ), font, 1, 1 )

            item.x = item.pos
            item.y = item.y - dist

            if item.expires <= CurTime( ) then
                helper:table_remove( src, i )
            end
        end
    end
    hook.Add( 'DrawOverlay', uid .. 'd2s.scrolltext', draw2screen )

    return atime
end

/*
*   design :: rsay
*
*   displays text from a starting position and forces the text to scroll upward as time passes with
*   fade in/out effects as it enters/leaves
*
*   returns the atime to a specified var which is used as the expiration time as part of the paint call.
*
*   @param  : str msg
*   @param  : clr clr
*   @param  : int duration
*   @param  : int fade
*/

function design.rsay( msg, clr, duration, fade )
    msg         = msg or 'missing msg'
    clr         = clr or Color( 255, 255, 255, 255 )
    duration    = duration or 10
    fade        = fade or 0.5

    local msg_table     = istable( msg ) and true or false
    local start         = CurTime( )

    local function rsay_draw( )
        local alpha = 255
        local dtime = CurTime( ) - start

        if dtime > duration then
            hook.Remove( 'HUDPaint', prefix .. 'rsay.draw' )
            return
        end

        if fade - dtime > 0 then
            alpha = ( fade - dtime ) / fade
            alpha = 1 - alpha
            alpha = alpha * 255
        end

        if duration - dtime < fade then
            alpha = ( duration - dtime ) / fade
            alpha = alpha * 255
        end
        clr.a  = alpha

        if not msg_table then
            design.text( msg, ScrW( ) * 0.5, ScrH( ) * 0.25, clr, pref( 'sys.rsay.text' ), 1 )
        else
            design.text( msg[ 1 ], ScrW( ) * 0.5, ScrH( ) * 0.25 - 15, clr, pref( 'sys.rsay.text' ), 1 )
            design.text( msg[ 2 ], ScrW( ) * 0.5, ScrH( ) * 0.25 + 15, clr, pref( 'sys.rsay.text.sub' ), 1 )
        end
    end

    hook.Add( 'HUDPaint', prefix .. 'rsay.draw', rsay_draw )
end

/*
*   netlib :: rsay
*/

local function netlib_rsay( )
    local msg   = net.ReadString( )
    local clr   = net.ReadColor( )
    local dur   = net.ReadInt( 8 )
    local fade  = net.ReadInt( 8 )

    design.rsay( msg, clr, dur, fade )

end
net.Receive( 'rlib.rsay', netlib_rsay )