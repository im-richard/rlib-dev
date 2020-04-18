/*
*   @package        : rlib
*   @module         : hook
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
*   @package        : srlion's hook library
*   @author         : Richard [http://steamcommunity.com/profiles/76561198261855442]
*   @copyright      : (C) 2019 - 2020
*   @website        : https://github.com/Srlion/Hook-Library/tree/master
*
*   MIT License
*
*   Copyright (c) 2020 Srlion
*
*   Permission is hereby granted, free of charge, to any person obtaining a copy
*   of this software and associated documentation files (the "Software"), to deal
*   in the Software without restriction, including without limitation the rights
*   to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
*   copies of the Software, and to permit persons to whom the Software is
*   furnished to do so, subject to the following conditions:
*
*   The above copyright notice and this permission notice shall be included in all
*   copies or substantial portions of the Software.
*
*   THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
*   IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
*   FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
*   AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
*   LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
*   OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
*   SOFTWARE.
*/

/*
*   standard tables and localization
*/

rlib                    = rlib or { }
local base              = rlib

local gmod 	            = gmod
local debug             = debug
local pairs             = pairs
local gmt 	            = getmetatable
local smt 	            = setmetatable

/*
*   register module
*/

module( 'hook' )

/*
*   declarations
*/

local storage = { }

local CreateEvent
do
    local Event     = { }
    local meta      = { __index = Event }

    CreateEvent = function( )
        return smt(
        {
            n 		= 0,
            keys 	= { },
        }, meta )
    end

    /*
    *   event :: add
    */

    function Event:Add( name, fn, obj )

        local pos = self.keys[ name ]
        if ( pos ) then

            /*
            *   hook exists -> update
            */

            self[ pos + 1 ]     = fn
            self[ pos + 2 ]     = obj

        else

            local n             = self.n

            self[ n + 1 ]       = name
            self[ n + 2 ]       = fn
            self[ n + 3 ]       = obj
            self.keys[ name ]   = n + 1 -- ref to hook position

            self.n              = n + 3

        end

    end

    /*
    *   event :: remove
    */

    function Event:Remove( name )
        local i = self.keys[ name ]
        if not i then return end

        self[ i ]           = nil -- name
        self[ i + 1 ]       = nil -- fn
        self[ i + 2 ]       = nil -- obj
        self.keys[ name ]   = nil
    end

    /*
    *   event :: gethooks
    */

    function Event:GetHooks( )
        local hooks     = { }
        local i, n      = 1, self.n

        ::loop::
        local name = self[ i ]
        if name then
            hooks[ name ] = self[ i + 1 ] -- fn
        end

        i = i + 3
        if i <= n then goto loop end

        return hooks
    end
end

do
    local strMeta = gmt( '' )
    local function isstring( val )
        return gmt( val ) == strMeta
    end

    local funcMeta = gmt( isstring ) or { }
    if not gmt( isstring ) then
        debug.setmetatable( isstring, funcMeta )
    end

    local function isfunction( val )
        return gmt( val ) == funcMeta
    end

    /*
    *   add
    *
    *   add a hook to listen to the specified event.
    *
    *   @param  : str event_name
    *   @param  : str name
    *   @param  : func fn
    */

    function Add( event_name, name, fn )
        if not isstring( event_name ) then return end
        if not isfunction( fn ) then return end
        if not name then return end

        local obj = false
        if not isstring( name ) then
            obj = name
        end

        local event = storage[ event_name ]
        if not event then
            event = CreateEvent( )
            storage[ event_name ] = event
        end

        event:Add( name, fn, obj )
    end
end

/*
*   Remove
*
*   removes the hook with the given indentifier.
*
*   @param  : str event_name
*   @param  : str name
*/

function Remove( event_name, name )
    local event = storage[ event_name ]
    if ( event ) then
        event:Remove( name )
    end
end

/*
*   GetTable
*
*   returns list of all available hooks
*/

function GetTable( )
    local new_events = { }

    for event_name, event in pairs( storage ) do
        new_events[ event_name ] = event:GetHooks( )
    end

    return new_events
end

/*
*   call
*
*   calls hooks associated with the hook name.
*
*   @param  : str event_name
*   @param  : tbl gm
*   @param  : varg ...
*/

function Call( event_name, gm, ... )

    local event = storage[ event_name ]
    if ( event ) then

        local i, n = 2, event.n

        ::loop::
        local fn = event[ i ]
        if fn then
            local obj = event[ i + 1 ]
            if ( obj ) then

                if ( obj.IsValid and obj:IsValid( ) ) then
                    local a, b, c, d, e, f = fn( obj, ... )
                    if ( a ~= nil ) then
                        return a, b, c, d, e, f
                    end
                else
                    event:Remove( event[ i - 1 ] )
                end

            else
                local a, b, c, d, e, f = fn( ... )
                if ( a ~= nil ) then
                    return a, b, c, d, e, f
                end
            end

            i = i + 3
        else

            local _n, _i = n, i

            if event.n ~= n then
                _n  = event.n
                i   = i + 3
            else
                n   = n - 3
            end

            local new_name = event[_n - 2 --[[name]]]
            if new_name then
                --[[name]] --[[fn]] --[[obj]]
                event[ _i - 1 ], event[ _i ], event[ _i + 1 ] = new_name, event[ _n - 1 ], event[ _n ]
                event[ _n - 2 ], event[ _n - 1 ], event[ _n ] = nil, nil, nil
                event.keys[ new_name ] = _i - 1 -- update hook pos
            end

            event.n = event.n - 3

            if event.n == 0 then
                storage[ event_name ] = nil
            end
        end

        if i <= n then goto loop end

    end

    /*
    *   check :: gamemode
    */

    if not gm then return end

    local gm_fn = gm[ event_name ]
    if not gm_fn then return end

    return gm_fn( gm, ... )
end

/*
*   run
*
*   calls hooks associated with the hook name.
*
*   @param  : str name
*   @param  : varg ...
*/

function Run( name, ... )
    return Call( name, gmod and gmod.GetGamemode( ) or nil, ... )
end