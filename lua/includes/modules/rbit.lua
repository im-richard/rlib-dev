/*
*   @package        : rlib
*   @module         : rbit
*   @author         : Richard [http://steamcommunity.com/profiles/76561198135875727]
*   @copyright      : (c) 2020 - 2020
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
*   rbit :: setup
*/

rbit =
{
    data32 = { }
}

for i = 1, 32 do
    rbit.data32[ i ] = 2 ^ ( 32 - i )
end

/*
*   rbit :: d2b
*/

function rbit:d2b( arg )
    local tr = { }
    for i = 1, 32 do
        if arg >= self.data32[ i ] then
            tr[ i ] = 1
            arg     = arg - self.data32[ i ]
        else
            tr[ i ] = 0
        end
    end
    return tr
end

/*
*   rbit :: b2d
*/

function rbit:b2d( arg )
    local nr = 0
    for i = 1, 32 do
        if arg[ i ] == 1 then
            nr = nr + 2 ^ ( 32 - i )
        end
    end
    return nr
end

/*
*   rbit :: bxor
*/

function rbit:bxor( a, b )
    local op1   = self:d2b( a )
    local op2   = self:d2b( b )
    local r     = { }

    for i = 1, 32 do
        if op1[ i ] == op2 [ i ] then
            r[ i ] = 0
        else
            r[ i ] = 1
        end
    end
    return self:b2d( r )
end

/*
*   rbit :: band
*/

function rbit:band( a, b )
    local op1   = self:d2b( a )
    local op2   = self:d2b( b )
    local r     = { }

    for i = 1, 32 do
        if op1[ i ] == 1 and op2[ i ] == 1  then
            r[ i ] = 1
        else
            r[ i ] = 0
        end
    end

    return self:b2d( r )
end

/*
*   rbit :: bor
*/

function rbit:bor( a, b )
    local op1   = self:d2b( a )
    local op2   = self:d2b( b )
    local r     = { }

    for i = 1, 32 do
        if  op1[ i ] == 1 or   op2[ i ] == 1 then
            r[ i ] = 1
        else
            r[ i ] = 0
        end
    end

    return self:b2d( r )
end

/*
*   rbit :: bnot
*/

function rbit:bnot( a )
    local op1   = self:d2b( a )
    local r     = { }

    for i = 1, 32 do
        if  op1[ i ] == 1   then
            r[ i ] = 0
        else
            r[ i ] = 1
        end
    end

    return self:b2d( r )
end

/*
*   rbit :: rshift
*/

function rbit:rshift( a, n )
    if n == 0 then return a end

    local op1   = self:d2b( a )
    local r     = self:d2b( 0 )

    if n < 32 and n > 0 then
        for i = 1, n do
            for i = 31, 1, -1 do
                op1[ i + 1 ] = op1[ i ]
            end
            op1[ 1 ] = 0
        end
        r = op1
    end

    return self:b2d( r )
end

/*
*   rbit :: lshift
*/

function rbit:lshift( a, n )
    if n == 0 then return a end

    local op1   = self:d2b( a )
    local r     = self:d2b( 0 )

    if n < 32 and n > 0 then
        for i = 1, n do
            for i = 1, 31 do
                op1[ i ] = op1[ i + 1 ]
            end
            op1[ 32 ] = 0
        end
        r = op1
    end

    return self:b2d( r )
end

/*
*   rbit :: print
*/

function rbit:print( ta )
    local sr = ''
    for i = 1, 32 do
        sr = sr .. ta[ i ]
    end

    print( sr )
end

/*
*   ret
*/

return rbit