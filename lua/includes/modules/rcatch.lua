/*
*   @package        : rlib
*   @module         : rcatch
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

local VERSION 	= '1.0.0'
require( 'rclass' )
local CLASS 	= include( 'rclass.lua' )
				if SERVER then AddCSLuaFile( 'includes/modules/rclass.lua' ) end

				assert( CLASS, 'rCatch: missing rClass' )

/*
*   try
*
*	@param	: funcs fn
*/

local function try( fn )
	local _try, _catch, _throw = fn[ 1 ], fn[ 2 ], fn[ 3 ]
	assert( _try, '[ rcatch ] :: missing func for try( )' )

	local status, result = pcall( _try )
	if not status and _catch then
		_catch( result )
	end

	if _throw then _throw( ) end
	return result
end

/*
*   catch
*
*	@param	: funcs f
*/

local function catch( fn )
	return fn[ 1 ]
end

/*
*   throw
*
*	@param	: funcs f
*/

local function throw( fn )
	return fn[ 1 ]
end

/*
*   error instance
*/

local Error 			= rClass( nil, { name = 'Error Instance' } )
Error.__version 		= VERSION
Error.DEFAULT_PF 		= 'ERROR: '
Error.DEFAULT_MSG 		= 'There was an error'

/*
*   __new__
*/

function Error:__new__( msg, params )
	msg 			= msg or self.DEFAULT_MSG
	params 			= params or { }
	params.pf 		= params.pf or self.DEFAULT_PF

	if self.is_class then return end

	self.pf 		= params.pf
	self.msg 		= msg
	self.traceback 	= debug.traceback( )
end

/*
*   __tostring__
*/

function Error:__tostring__( id )
	return table.concat( { self.pf, self.msg, '\n', self.traceback } )
end

/*
*   declare
*/

_G.try 		= try
_G.catch 	= catch
_G.throw 	= throw

/*
*   ret
*/

return Error