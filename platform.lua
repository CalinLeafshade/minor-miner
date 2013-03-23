Platform = 
{
  Type = "platform"
  
}

function Platform.Rectangle(x,y,w,h)
  return Platform:new(x,y,x,y + h,x +w, y+h,x + w,y)
end

function Platform:new (...)
  o = {}
  setmetatable(o, self)
  self.__index = self
  local params = {...}
  o.Mode = "allblock"
  if type(params[1]) == "string" then
    o.Mode = params[1]
    table.remove(params,1)
  end
	local rw = Room.Current:Width()
	local rh = Room.Current:Height()
	for i,v in ipairs(params) do -- extend platforms
		if i % 2 == 1 then -- x
			if v == 0 then
				params[i] = -5
			elseif v >= rw - 2 then
				params[i] = rw + 5
			end
		else --y
			if v == 0 then
				params[i] = -5
			elseif v >= rh - 2 then
				params[i] = rh + 5
			end
		end
	end
  o.Collider = Game.CWorld:addPolygon(unpack(params))
  --RoomShapes[#RoomShapes + 1] = o.Collider
  o.Collider.Object = o
  return o
end

function Platform:Draw(scale)

	local v = {self.Collider._polygon:unpack()}
	for i = 1, #v do
		if i % 2 == 1 then
			v[i] = v[i] - Game.Viewport.x
		else
			v[i] = v[i] - Game.Viewport.y
		end
		v[i] = v[i] * scale
		
	end
	love.graphics.polygon("line", unpack(v))
	
end

return Platform

--PlatformEditor = 
--{
--  On = false,
--  Verts = {},
--  GUI = ags.gEditor
--  
--}
--
--function PlatformEditor:Click(button)
--    if self.Drawing then
--      local x,y = ags.Mouse.GetPosition()
--      x = x + ags.GetViewportX()
--      y = y + ags.GetViewportY()
--      self.Verts[#self.Verts + 1] = x
--      self.Verts[#self.Verts + 1] = y
--    end
--end
--
--function PlatformEditor:Finalise()
--  if #self.Verts < 6 then
--    ags.Display("You need at least 3 non-colinear vertices")
--  else
--    CurrentRoom().Platforms[#CurrentRoom().Platforms + 1] = Platform:new(unpack(self.Verts))
--  end
--  self.Verts = {}
--  self.Drawing = false
--end
--
--function PlatformEditor:Enable()
--  self.GUI.Visible = true
--  self.On = true
--end
--
--function PlatformEditor:Disable()
--  self.GUI.Visible = false
--  self.On = false
--end
--
--function PlatformEditor:Toggle()
--  if self.On then
--    self:Disable()
--  else
--    self:Enable()
--  end
--end
--
--function PlatformEditor:Keypress(keycode)
--  if (keycode == ags.eKeyD) then
--    Platform.DebugDraw = not Platform.DebugDraw
--  end
--  if (keycode == ags.eKeyE) then
--    self:Toggle()
--  end
--  if (keycode == ags.eKeyReturn) then
--    PlatformEditor:Finalise()
--  end
--  if (keycode == ags.eKeyX and self.On) then
--    local closest = 10000
--    for i=1, #self.Verts - 1, 2 do
--      if math.abs(ags.mouse.x - closest) > math.abs(ags.mouse.x - self.Verts[i]) then
--        closest = self.Verts[i]
--      end
--    end
--    ags.Mouse.SetPosition(closest, ags.mouse.y)
--  end
--  if (keycode == ags.eKeyY and self.On) then
--    local closest = 10000
--    for i=2, #self.Verts, 2 do
--      if math.abs(ags.mouse.y - closest) > math.abs(ags.mouse.y - self.Verts[i]) then
--        closest = self.Verts[i]
--      end
--    end
--     ags.Mouse.SetPosition(ags.mouse.x,closest)
--  end
--end
--
--
--
--