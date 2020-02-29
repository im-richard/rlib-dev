/*
*   @package        : rlib
*   @module         : rcore
*   @author         : Richard [http://steamcommunity.com/profiles/76561198135875727]
*   @copyright      : (c) 2018 - 2020
*   @since          : 1.0.0
*   @website        : https://rlib.io
*   @docs           : https://docs.rlib.io
*   @file           : sh_config.lua
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
*	standard tables and localization
*/

rcore 					= rcore or { }
local base      		= rcore
local cfg  				= base.settings

/*
* 	core :: workshop enabled
* 
* 	Determines if a predefined table of workshop collection ids should be mounted when the server
*   is started and when a client connects. This forces the client to download the workshop and 
*   prevents users from getting missing models, textures, etc.
* 
* 	@source		: autorun\_rcore_loader.lua
*	@default	: true
*	@type		: boolean
*/

	cfg.useworkshop = true

/*
* 	core :: resources enabled
* 
* 	Enabling this will force the script to utilize 'resource.AddFile'
*   Adds the specified files to the files the client should download.
*   This is an alternative to steam workshops and is used as/with FastDL
* 
* 	@source		: autorun\_rcore_loader.lua
*	@default	: true
*	@type		: boolean
*/

	cfg.useresources = true

/*
* 	core :: module priority
* 
* 	This table can list modules that should take priority in loading
*   before other modules are set to be initialized. Usually the only
*   module that needs to go first is the base module since certain
*   config settings may be needed for other scripts.
* 
*	@type	: table
*/

	cfg.loadpriority =
	{
		[ 'base' ] = true,
	}