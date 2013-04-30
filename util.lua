--util.lua
math.randomseed( os.time() )
math.random(); math.random(); math.random()

White = {255,255,255}

function loop(val, min, max)
	if val > max then return min end
	if val < min then return max end
	return val
	
end

--- Joins two tables
function table.join(first_table, second_table)
	for k,v in pairs(second_table) do first_table[k] = v end
end

--- Round a value
-- @param  num Value to round
-- @param  idp Number of decimal place (default 0)
-- @return     The rounded value
function round(num, idp)
    local mult = 10^(idp or 0)
    return math.floor(num * mult + 0.5) / mult
end

--- Saturates a value
-- Saturate clamps a value to -1 =< val >= 1
-- @param  val Value to saturate
-- @return     Saturated value
function saturate(val)
    if val < -1 then return -1 
    elseif val > 1 then return 1
    else return val
    end
end

--- Deep copy a table
-- @param  t Table to copy
-- @return   A copy of table t
function deepcopy(t)
    if type(t) ~= 'table' then return t end
    local mt = getmetatable(t)
    local res = {}
    for k,v in pairs(t) do
        if type(v) == 'table' then
            v = deepcopy(v)
        end
    res[k] = v
    end
    setmetatable(res,mt)
    return res
end

--- Clamp a value
-- @param  val Value to clamp
-- @param  mn  Minimum value
-- @param  mx  Maximum value
-- @return     Clamped value
function clamp(val, mn, mx)
    if val < mn then return mn
    elseif val > mx then return mx
    else return val
    end
end

--- Lerps a value
-- @param  a Lower value
-- @param  b Upper value
-- @param  t Needle
-- @return   A lerped value
function lerp (a, b, t)
    return a + (b - a) * t
end 

--- Smoothsteps a value
-- @param  edge0 Lower edge
-- @param  edge1 Upper edge
-- @param  x     Needle
-- @return       The smoothed value
function smoothstep(edge0, edge1, x)
    x = saturate((x - edge0) / (edge1 - edge0))
    return x * x * (3 - 2 * x)
end

--- Lerps a value with a smoothed needle
-- @param  a Lower edge
-- @param  b Upper edge
-- @param  t Needle
-- @return   A smoothly lerped value
function smoothlerp(a,b,t)
    return lerp(a,b,smoothstep(0,1,t))
end

--- Dumps a table to a string for debug
-- @param  o Table to dump
-- @return   A non-lua, human readable string representing the dumped table
function dump(o)
    if type(o) == 'table' then
        local s = '{['
        for k,v in pairs(o) do
            if type(k) ~= 'number' then k = '"'..k..'"' end
            s = s .. '('..k..') = ' .. dump(v) .. ',['
        end
        return s .. '}['
    else
        return tostring(o)
    end
end

--- A Wait coroutine
-- @param secs Number of seconds to wait
function Wait(secs)
    while secs > 0 do
        secs = secs - coroutine.yield(true)
    end
end

--- A UUID function
-- @return   A UUID as a string
function UUID()
    local chars = {"0","1","2","3","4","5","6","7","8","9","A","B","C","D","E","F"}
    local uuid = {[9]="-",[14]="-",[15]="4",[19]="-",[24]="-"}
    local r, index
    for i = 1,36 do
        if(uuid[i]==nil)then
            r = math.random (16)
            index = r
            uuid[i] = chars[index]
        end
    end
    return table.concat(uuid)
end 

function try(f, catch_f)
	local status, exception = pcall(f)
	if not status then
		catch_f(exception)
	end
end


--- Converts screen coordinates to room coordinates
-- @param  x        X coord
-- @param  y        Y coord
-- @param  useScale Whether or not to account for the games scale (Default: true)
-- @return          The translated [and scaled] X coord
-- @return          The translated [and scaled] Y coord
function toRoom(x,y,useScale)
    useScale = useScale or true
    local scale = useScale and Config.Scale or 1
    return (x / scale) + Game.Viewport.x, (y / scale) + Game.Viewport.y
end

--- Converts room coordinates to screen coordinates
-- @param  x X
-- @param  y Y
-- @return   Scaled and translated X
-- @return   Scaled and translated Y
function toScreen(x,y)
    return (x - Game.Viewport.x) * Config.Scale, (y - Game.Viewport.y) * Config.Scale
end