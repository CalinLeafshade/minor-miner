--util.lua
math.randomseed( os.time() )
math.random(); math.random(); math.random()

function round(num, idp)
  local mult = 10^(idp or 0)
  return math.floor(num * mult + 0.5) / mult
end

function saturate(val)
  if val < -1 then return -1 
  elseif val > 1 then return 1
  else return val
  end
end

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

function clamp(val, mn, mx)
  if val < mn then return mn
  elseif val > mx then return mx
  else return val
  end
end

function lerp (a, b, t)
	return a + (b - a) * t
end 

function smoothstep(edge0, edge1, x)
	x = saturate((x - edge0) / (edge1 - edge0))
	return x * x * (3 - 2 * x)
end

function smoothlerp(a,b,t)
	return lerp(a,b,smoothstep(0,1,t))
end

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

function Wait(secs)
  while secs > 0 do
    secs = secs - coroutine.yield(true)
  end
end

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

function toRoom(x,y,useScale)
	useScale = useScale or true
	local scale = useScale and Scale or 1
	return (x / scale) + Game.Viewport.x, (y / scale) + Game.Viewport.y
end

function toScreen(x,y)
	return (x - Game.Viewport.x) * Scale, (y - Game.Viewport.y) * Scale
end