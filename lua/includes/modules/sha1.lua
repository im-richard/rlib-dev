/*
*   @package        : rlib
*   @module         : sha1
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
*   @package        : sha1
*   @author         : Enrique García Cota + Eike Decker + Jeffrey Friedl
*   @copyright      : (C) 2013
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
*   manifest
*/

sha1 =
{
    version = { 1, 0, 0 },
    url     = 'https://github.com/kikito/sha.lua',
    desc = [[
        SHA-1 secure hash computation, and HMAC-SHA1 signature computation in Lua (5.1)
        Based on code originally by Jeffrey Friedl (http://regex.info/blog/lua/sha1)
        And modified by Eike Decker - (http://cube3d.de/uploads/Main/sha1.txt)
    ]],
    license = [[
        MIT LICENSE

        Copyright (c) 2013 Enrique García Cota + Eike Decker + Jeffrey Friedl

        Permission is hereby granted, free of charge, to any person obtaining a
        copy of this software and associated documentation files (the
        "Software"), to deal in the Software without restriction, including
        without limitation the rights to use, copy, modify, merge, publish,
        distribute, sublicense, and/or sell copies of the Software, and to
        permit persons to whom the Software is furnished to do so, subject to
        the following conditions:

        The above copyright notice and this permission notice shall be included
        in all copies or substantial portions of the Software.

        THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
        OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
        MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
        IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
        CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
        TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
        SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
    ]]
}

/*
*   declarations
*/

local bPrecache     = true
local block_sz      = 64 -- 512 bits

/*
*   localizations
*/

local string        = string
local math          = math
local char          = string.char
local sf            = string.format
local rep           = string.rep
local floor         = math.floor
local modf          = math.modf
local smt           = setmetatable
local tonumber      = tonumber
local select        = select

/*
*   bytes_to_w32
*
*   merge 4 bytes to an 32 bit word
*
*   @param  : byte a
*   @param  : byte b
*   @param  : byte c
*   @param  : byte d 
*/

local function bytes_to_w32( a, b, c, d )
    return a * 0x1000000 + b * 0x10000 + c * 0x100 + d
end

/*
*   w32_to_bytes
*
*   split 32-bit word to four 8-bit numbers
*
*   @param  : byte i
*/

local function w32_to_bytes( i )
    return floor( i / 0x1000000 ) % 0x100, floor( i / 0x10000 ) % 0x100, floor( i / 0x100 ) % 0x100, i % 0x100
end

/*
*   w32_rot
*
*   shift the bits of a 32 bit word. Don't use negative values for "bits"
*
*   @param  : int bits
*   @param  : int a
*   @return : int
*/

local function w32_rot( bits, a )
    local b2      = 2 ^ ( 32 - bits )
    local a, b    = modf( a / b2 )

    return a + b * b2 * ( 2 ^ ( bits ) )
end

/*
*   cache2arg
*
*   caching function for functions that accept 2 arguments, both of values between
*   0 and 255. The function to be cached is passed, all values are calculated
*   during loading and a function is returned that returns the cached values (only)
*
*   @param  : func fn
*/

local function cache2arg( fn )
    if not bPrecache then return fn end
    local lut = { }
    for i = 0, 0xffff do
        local a, b = floor( i / 0x100 ), i % 0x100
        lut[ i ] = fn( a, b )
    end
    return function( a, b )
        return lut[ a * 0x100 + b ]
    end
end

/*
*   byte_to_bits
*
*   splits an 8-bit number into 8 bits, returning all 8 bits as booleans
*
*   @param  : int b
*/

local function byte_to_bits( b )
    local b = function( n )
        local b = floor( b / n )
        return b % 2 == 1
    end
    return b( 1 ), b( 2 ), b( 4 ), b( 8 ), b( 16 ), b( 32 ), b( 64 ), b( 128 )
end

/*
*   bits_to_byte
*
*   builds an 8bit number from 8 booleans
*
*   @param  : int a
*   @param  : int b
*   @param  : int c
*   @param  : int d
*   @param  : int e
*   @param  : int f
*   @param  : int g
*   @param  : int h
*/

local function bits_to_byte( a, b, c, d, e, f, g, h )
    local function n( b, i ) return b and i or 0 end
    return n( a, 1 ) + n( b, 2 ) + n( c, 4 ) + n( d, 8 ) + n( e, 16 ) + n( f, 32 ) + n( g, 64 ) + n( h, 128 )
end

/*
*   bitwise "and" function for 2 8bit number
*
*   @param  : int a
*   @param  : int b
*/

local band = cache2arg( function( a, b )
    local A, B, C, D, E, F, G, H = byte_to_bits( b )
    local a, b, c, d, e, f, g, h = byte_to_bits( a )
    return bits_to_byte(
        A and a, B and b, C and c, D and d,
        E and e, F and f, G and g, H and h )
end )

/*
*   bitwise "or" function for 2 8bit numbers
*
*   @param  : int a
*   @param  : int b
*/

local bor = cache2arg( function( a, b )
    local A, B, C, D, E, F, G, H = byte_to_bits( b )
    local a, b, c, d, e, f, g, h = byte_to_bits( a )

    return bits_to_byte( A or a, B or b, C or c, D or d, E or e, F or f, G or g, H or h )
end )

/*
*   bitwise "xor" function for 2 8bit numbers
*
*   @param  : int a
*   @param  : int b
*/

local bxor = cache2arg( function( a, b )
    local A, B, C, D, E, F, G, H = byte_to_bits( b )
    local a, b, c, d, e, f, g, h = byte_to_bits( a )

    return bits_to_byte( A ~= a, B ~= b, C ~= c, D ~= d, E ~= e, F ~= f, G ~= g, H ~= h )
end )

/*
*   bnot
*
*   bitwise complement for one 8bit number
*
*   @param  : int i
*/

local function bnot( i )
    return 255 - ( i % 256 )
end

/*
*   w32_comb
*
*   creates a function to combine to 32bit numbers using an 8bit combination function
*
*   @param  : func fn
*/

local function w32_comb( fn )
    if not fn then return end

    return function( a, b )
        local aa, ab, ac, ad = w32_to_bytes( a )
        local ba, bb, bc, bd = w32_to_bytes( b )

        return bytes_to_w32( fn( aa, ba ), fn( ab, bb ), fn( ac, bc ), fn( ad, bd ) )
    end
end

/*
*   create functions for and, xor and or, all for 2 32bit numbers
*/

local w32_and   = w32_comb( band )
local w32_xor   = w32_comb( bxor )
local w32_or    = w32_comb( bor )

/*
*   w32_xor_n
*
*   xor function that may receive a variable number of arguments
*
*   @param  : int a
*   @param  : varg { ... }
*/

local function w32_xor_n( a, ... )
    local aa, ab, ac, ad = w32_to_bytes( a )
    for i = 1, select( '#', ... ) do
        local ba, bb, bc, bd = w32_to_bytes( select( i, ... ) )
        aa, ab, ac, ad = bxor( aa, ba ), bxor( ab, bb ), bxor( ac, bc ), bxor( ad, bd )
    end
    return bytes_to_w32( aa, ab, ac, ad )
end

/*
*   w32_xor_n
*
*   combining 3 32bit numbers through binary "or" operation
*
*   @param  : int a
*   @param  : int b
*   @param  : int c
*/

local function w32_or3( a, b, c )
    local aa, ab, ac, ad = w32_to_bytes( a )
    local ba, bb, bc, bd = w32_to_bytes( b )
    local ca, cb, cc, cd = w32_to_bytes( c )

    return bytes_to_w32(
        bor( aa, bor( ba, ca ) ), bor( ab, bor( bb, cb ) ), bor( ac, bor( bc, cc ) ), bor( ad, bor( bd, cd ) )
    )
end

/*
*   w32_not
*
*   binary complement for 32bit numbers
*
*   @param  : int a
*/

local function w32_not( a )
    return 4294967295 - ( a % 4294967296 )
end

/*
*   w32_add
*
*   adding 2x32bit numbers, cutting off the remainder on 33th bit
*
*   @param  : int a
*   @param  : int b
*   @return : int
*/

local function w32_add( a, b )
    return ( a + b ) % 4294967296
end

/*
*   w32_add_n
*
*   adding n 32bit numbers, cutting off the remainder (again)
*
*   @param  : int a
*   @param  : varg { ... }
*/

local function w32_add_n( a, ... )
    for i = 1, select( '#' , ... ) do
        a = ( a + select( i, ... ) ) % 4294967296
    end
    return a
end

/*
*   w32_to_hexstring
*
*   int to hexadec str
*
*   @param  : int w
*/

local function w32_to_hexstring( w )
    return sf( '%08x', w )
end

/*
*   hex_to_binary
*
*   hexadec to bin
*
*   @param  : str hex
*/

local function hex_to_binary( hex )
    return hex:gsub( '..', function( hexval )
        return char( tonumber( hexval, 16 ) )
    end )
end

/*
*   prepare ref tables
*/

local xor_0x5c, xor_0x36 = { }, { }
for i = 0, 0xff do
    xor_0x5c[ char( i ) ] = char( bxor( i, 0x5c ) )
    xor_0x36[ char( i ) ] = char( bxor( i, 0x36 ) )
end

/*
*   sha1 :: encrypt
*
*   convert str to sha1
*
*   @call   : sha1.encrypt( 'the msg' )
*
*   @param  : str msg
*   @return : str
*/

function sha1.encrypt( msg )
    if not msg then return end

    local h0, h1, h2, h3, h4    = 0x67452301, 0xEFCDAB89, 0x98BADCFE, 0x10325476, 0xC3D2E1F0
    local msg_len_in_bits       = #msg * 8
    local first_append          = char( 0x80 )

    local nzero_msg_bytes       = #msg + 1 + 8 -- the +1 is the appended bit 1, the +8 are for the final appended length
    local current_mod           = nzero_msg_bytes % 64
    local second_append         = current_mod > 0 and rep( char( 0 ), 64 - current_mod ) or ''

    /*
    *   append len as 64-bit
    */

    local b1, r1    = modf( msg_len_in_bits / 0x01000000 )
    local b2, r2    = modf( 0x01000000 * r1 / 0x00010000 )
    local b3, r3    = modf( 0x00010000 * r2 / 0x00000100 )
    local b4        = 0x00000100 * r3

    local len64     = char( 0 ) .. char( 0 ) .. char( 0 ) .. char( 0 ) -- high 32 bits
    .. char( b1 ) .. char( b2 ) .. char( b3 ) .. char( b4 ) --  low 32 bits

    msg = msg .. first_append .. second_append .. len64

    assert( #msg % 64 == 0 )

    local chunks, chunk, W = #msg / 64, 0, { }
    local start, A, B, C, D, E, f, K, TEMP

    while chunk < chunks do
        start, chunk = chunk * 64 + 1, chunk + 1

        for t = 0, 15 do
            W[ t ] = bytes_to_w32( msg:byte( start, start + 3 ) )
            start = start + 4
        end

        for t = 16, 79 do
            W[ t ] = w32_rot( 1, w32_xor_n( W[ t - 3 ], W[ t - 8 ], W[ t - 14 ], W[ t - 16 ] ) )
        end

        A, B, C, D, E = h0, h1, h2, h3, h4

        for t = 0, 79 do
            if t <= 19 then
                f = w32_or( w32_and( B, C ), w32_and( w32_not( B ), D ) )
                K = 0x5A827999
            elseif t <= 39 then
                f = w32_xor_n( B, C, D )
                K = 0x6ED9EBA1
            elseif t <= 59 then
                f = w32_or3( w32_and( B, C ), w32_and( B, D ), w32_and( C, D ) )
                K = 0x8F1BBCDC
            else
                f = w32_xor_n( B, C, D )
                K = 0xCA62C1D6
            end

            A, B, C, D, E = w32_add_n( w32_rot( 5, A ), f, E, W[ t ], K ),
            A, w32_rot( 30, B ), C, D
        end

        h0, h1, h2, h3, h4 = w32_add( h0, A ), w32_add( h1, B ), w32_add( h2, C ), w32_add( h3, D ), w32_add( h4, E )
    end

    local f = w32_to_hexstring

    return f( h0 ) .. f( h1 ) .. f( h2 ) .. f( h3 ) .. f( h4 )
end

/*
*   sha1 :: binary
*
*   @param  : str msg
*/

function sha1.binary( msg )
    return hex_to_binary( sha1.encrypt( msg ) )
end

/*
*   sha1 :: hmac
*
*   @param  : str key
*   @param  : str text
*/

function sha1.hmac( key, text )
    assert( type( key )  == 'string', 'key passed to sha1.hmac should be a string' )
    assert( type( text ) == 'string', 'text passed to sha1.hmac should be a string' )

    if #key > block_sz then
        key = sha1.binary( key )
    end

    local xord_0x36 = key:gsub( '.', xor_0x36 ) .. rep( char( 0x36 ), block_sz - #key )
    local xord_0x5c = key:gsub( '.', xor_0x5c ) .. rep( char( 0x5c ), block_sz - #key )

    return sha1.encrypt( xord_0x5c .. sha1.binary( xord_0x36 .. text ) )
end

/*
*   sha1 :: hmac_binary
*
*   @param  : str key
*   @param  : str text
*/

function sha1.hmac_binary( key, text )
    return hex_to_binary( sha1.hmac( key, text ) )
end

/*
*   setmetatable
*/

smt( sha1,
{
    __call = function( _, msg )
        return sha1.encrypt( msg )
    end
})

/*
*   ret
*/

return sha1