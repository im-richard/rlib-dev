/*
*   @package        : rlib
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

/*
*   standard tables and localization
*/

rlib                    = rlib or { }
local base              = rlib
local mf                = base.manifest
local prefix            = mf.prefix
local cfg               = base.settings

/*
*   localized rlib routes
*/

local helper            = base.h

/*
*   simplifiy funcs
*/

local function log( ... ) base:log( ... ) end

/*
*	prefix :: create id
*/

local function cid( id, suffix )
    local affix = istable( suffix ) and suffix.id or isstring( suffix ) and suffix or prefix
    affix = affix:sub( -1 ) ~= '.' and string.format( '%s.', affix ) or affix

    id = isstring( id ) and id or 'noname'
    id = id:gsub( '[%c%s]', '.' )

    return string.format( '%s%s', affix, id )
end

/*
*	prefix ids
*/

local function pid( str, suffix )
    local state = ( isstring( suffix ) and suffix ) or ( base and base.manifest.prefix ) or false
    return cid( str, state )
end

/*
*   base :: register :: particle
*
*   @param  : str, tbl src
*   @return : void
*/

function base.register:particle( src )
    if not isstring( src ) then return end
    if string.GetExtensionFromFilename( src ) ~= 'pcf' then
        PrecacheParticleSystem( src )
        log( RLIB_LOG_CACHE, '+ ptc [ %s ]', src )
    else
        game.AddParticles( src )
        log( RLIB_LOG_CACHE, '+ ptc [ %s ] ', src )
    end
end

/*
*   base :: register :: sound
*
*   @param  : str, tbl src
*   @return : void
*/

function base.register:sound( src )
    if not src then return end
    if string.GetExtensionFromFilename( src ) ~= 'wav' and string.GetExtensionFromFilename( src ) ~= 'mp3' and string.GetExtensionFromFilename( src ) ~= 'ogg' then
        rlib:log( RLIB_LOG_CACHE, '- snd skip ( [ %s ] )', src )
        return
    end
    util.PrecacheSound( src )
    log( RLIB_LOG_CACHE, '+ snd [ %s ]', src )
end

/*
*   base :: register :: model
*
*   limited to 4096 unique models. when it reaches the limit the game will crash.
*
*   @param  : str, tbl src
*   @param  : bool bIsValid
*   @return : void
*/

function base.register:model( src, bIsValid )
    if not src then return end
    if string.GetExtensionFromFilename( src ) ~= 'mdl' then
        rlib:log( RLIB_LOG_CACHE, '- mdl skip ( [ %s ] )', src )
        return
    end
    if bIsValid and not util.IsValidModel( src ) then return end
    util.PrecacheModel( src )
    log( RLIB_LOG_CACHE, '+ mdl [ %s ]', src )
end

/*
*   base :: register :: darkrp models
*
*   will precache ply mdls if gamemode is derived from darkrp
*   only executes if cfg.cache.darkrp_mdl = true in lib config file
*/

function base.register:rpmodels( )
    if not cfg.cache.darkrp_mdl then return end
    if not istable( RPExtraTeams ) then return end

    local i = 0
    for v in helper.get.data( RPExtraTeams ) do
        if istable( v.model ) then
            for mdl in helper.get.data( v.model ) do
                if string.GetExtensionFromFilename( mdl ) ~= 'mdl' then continue end
                util.PrecacheModel( mdl )
                if cfg.cache.debug_listall then
                    log( RLIB_LOG_CACHE, '+ darkrp mdl [ %s ]', mdl )
                end
                i = i + 1
            end
        else
            if string.GetExtensionFromFilename( v.model ) ~= 'mdl' then continue end
            util.PrecacheModel( v.model )
            if cfg.cache.debug_listall then
                log( RLIB_LOG_CACHE, '+ darkrp mdl [ %s ]', v.model )
            end
            i = i + 1
        end
    end

    log( RLIB_LOG_CACHE, '+ darkrp mdl [ %s total ]', tostring( i ) )
end
hook.Add( 'InitPostEntity', pid( 'register.rpmdl' ), base.register.rpmodels )