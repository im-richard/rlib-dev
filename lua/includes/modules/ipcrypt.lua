/*
*   @package        : rlib
*   @module         : ipcrypt
*   @requires       : rbit
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

ipcrypt = { }

function ipcrypt.Dig2Str( i )
   local ret = rbit:band( rbit:rshift( i, 24 ), 0xFF ) .. '.' .. rbit:band( rbit:rshift( i, 16 ), 0xFF ) .. '.' .. rbit:band( rbit:rshift( i, 8 ), 0xFF ) .. '.' .. rbit:band( i, 0xFF )
   return ret
end

function ipcrypt.Str2Dig( ipstr )
   local ret = 0
   for d in string.gmatch( ipstr, '%d+' ) do
       ret = ret * 256 + d
   end
   return ret
end

return ipcrypt