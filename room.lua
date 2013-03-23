Room =
{
 Rooms = {} 
}

function Room:new(name)
  o = {}
  setmetatable(o, self)
  self.__index = self
  o.Name = name
  o.Platforms = {}
  o.Exits = {}
	Room.Rooms[name] = o
  return o
end

function Room:Width()
	return self.Background:getWidth()
end

function Room:Height()
	return self.Background:getHeight()
end

function Room:SavePlatforms()
  local filename = "lscripts/Rooms/Platforms" .. self.ID .. ".lua"
  local f,err = io.open(filename,"w")
  f:write("-- Generated At " .. os.date("%I:%M:%S") .. "\n")
  f:write("PlatformData[" .. self.ID .. "] = {")
  PlatformData[self.ID] = {}
  for i,v in ipairs(self.Platforms or {}) do
    f:write("  {")
    f:write("\"" .. v.Mode .. "\"")
    f:write(", ")
    PlatformData[self.ID][#PlatformData[self.ID] + 1] = {v.Collider._polygon:unpack()}
    for _,p in pairs({v.Collider._polygon:unpack()}) do
      f:write(p .. ", ")
    end
    f:write("  },")
  end
  f:write("}")
  f:close()
  log(false, "Room saved")

end

function Room:FirstEnter()

end

function Room:Enter()

end

function Room:Update(dt)

end

function Room:Leave()
	
end

function Room:PrePlayerDraw()
	
end

function Room:PostPlayerDraw()
	
end


function Room:Init()
	local f = love.filesystem.exists("gfx/backgrounds/" .. self.Name .. "-Final.png") and "gfx/backgrounds/" .. self.Name .. "-Final.png" or "gfx/backgrounds/" .. self.Name .. ".png"
	self.Background = love.graphics.newImage(f)
	if love.filesystem.exists("gfx/backgrounds/" .. self.Name .. "-Overlay.png") then
		self.Overlay = love.graphics.newImage("gfx/backgrounds/" .. self.Name .. "-Overlay.png")
	end
	self:InitialisePlatforms()
end

function Room:Clean()
	self.Background = nil
	Game.CWorld:remove(unpack(self.Shapes))
end

function Room:InitialisePlatforms()
  self.Platforms = {}
	self.Shapes = {}
  for i,v in ipairs(self.PlatformData or {}) do
    self.Platforms[i] = Platform:new(unpack(v))
		self.Shapes[i] = self.Platforms[i].Collider
  end
end

function Room:AddExit(edge, roomTo, enmult, exmult)
	enmult = enmult or 0
	exmult = exmult or 0
	
  local e = self.Exits or {}
	if not e[edge] then e[edge] = {} end
  e[edge][enmult] = {Room = roomTo, ExitMult = exmult}
  self.Exits = e
end

function InitialiseRoom(roomNum)
	local filename = "lscripts/Rooms/Room" .. roomNum .. ".lua"
  local f,err = io.open(filename,"w")
	f:write("-- Generated At " .. os.date("%I:%M:%S") .. "\n")
	f:write("Rooms[" .. roomNum .. "] = Room:new(" .. roomNum .. ")\n")
	f:write("Rooms[" .. roomNum .. "].Width = " .. ags.Room.Width .. "\n")
	f:write("Rooms[" .. roomNum .. "].Height = " .. ags.Room.Height .. "\n")
	f:close()
	dofile(filename)
	return filename
end

--RegisterEvent("repeatedly_execute", function()
--  if Room.CheckExits then
--    local r = CurrentRoom()
--    local x,y = Player.Collider:center()
--		local multY = math.floor(y / 200)
--		local multX = math.floor(x / 320)
--		local exit = ""
--		local mult = 0
--    if x < 0 then
--			exit = "left"
--			mult = multY
--    elseif x > ags.Room.Width then
--			exit = "right"
--			mult = multY
--    elseif y < 0 then   
--			exit = "top"
--			mult = multX
--    elseif y > ags.Room.Height then
--			exit = "bottom"
--			mult = multX
--    end
--		if r.Exits[exit] and r.Exits[exit][mult] then
--			Player:ChangeRoom(r.Exits[exit][mult].Room, exit, mult, r.Exits[exit][mult].ExitMult)
--		end
--  end
--end)
--
--RegisterEvent("EnterRoomBeforeFadein", function()
--	if ags.GetRoomProperty("IsPlayRoom") == 0 then
--		return
--	end
--	if not GameState.State.Visited then GameState.State.Visited = {} end
--	
--	
--  CurrentRoom():InitialisePlatforms()
--  CurrentRoom().LastRegion = ags.Region.GetAtRoomXY(Player.Character.x, Player.Character.y)
--
--  
--  
--  local t = CurrentRoom().Tint
--  if t then
--    Player.Character:Tint(t[1],t[2],t[3],25,75)
--  end
--	if not GameState.State.Visited[CurrentRoom().ID] then
--			log("firstenter", "First enter room: " .. CurrentRoom().ID)
--			CurrentRoom():FirstEnter()
--	end
--  CurrentRoom():Enter()
--  Room.CheckExits = true
--	GameState.State.Visited[CurrentRoom().ID] = true
--end)

return Room