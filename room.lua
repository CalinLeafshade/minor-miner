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

function Room:AddObject(o)
	self.SceneObjects[#self.SceneObjects + 1] = o
end

function Room:Save()
	-- build table
	local data = {}
	data.platforms = {}
	
	for _,v in ipairs(self.Platforms) do
		data.platforms[#data.platforms + 1] = {mode = v.Mode, verts = {v.Collider._polygon:unpack()}}
	end
	
	data.enemies = {}
	
	data = DataDumper(data)
	
	local filename = love.filesystem.getWorkingDirectory() .. "/rooms/" .. self.Name .. "def.lua"
	local f,err = io.open(filename,"w")
	f:write("-- Generated At " .. os.date("%I:%M:%S") .. "\n")
	f:write(data)
	f:close()
	log("Room saved!")
	return true
	
end

function Room:FirstEnter()

end

function Room:Enter()

end

function Room:Update(dt)

end

function Room:Leave()

end

function Room:PreBackgroundDraw()

end

function Room:PrePlayerDraw()

end

function Room:PostPlayerDraw()

end



function Room:BaseUpdate(dt)
	if self.Lighting then
		self.Timer = self.Timer or 0
		self.Timer = self.Timer + dt
		if self.Timer > 0.1 then
			self.Timer = self.Timer - 0.1
			self.LightAlpha = clamp(self.LightAlpha + math.random(20) - 10,self.LightMin, self.LightMax)
		end
	end
end

function Room:DrawSceneObjects()
	for i,v in ipairs(self.SceneObjects) do
		v:Draw()
	end
end

function Room:DrawBackground()
    if self.Layers then
        for i = 1, #self.Layers do
            local l = self.Layers[i]
            local x = self:Width() == 320 and 0 or lerp(0, -(l:getWidth() - 320), Game.Viewport.x / (self:Width() - 320)) + Game.Viewport.x
            local y = self:Height() == 200 and 0 or lerp(0, -(l:getHeight() - 200), Game.Viewport.y / (self:Height() - 200)) + Game.Viewport.y
            love.graphics.draw(l,x,y)
            
        end
    end
    love.graphics.draw(Room.Current.Background,0,0)
		if self.Lighting then			
			love.graphics.setColor(255,255,255,self.LightAlpha)
			love.graphics.draw(self.Lighting,0,0)
			love.graphics.setColor(255,255,255)
		end
		
end

function Room:Init()

    local f = love.filesystem.exists("gfx/backgrounds/" .. self.Name .. "-Final.png") and "gfx/backgrounds/" .. self.Name .. "-Final.png" or "gfx/backgrounds/" .. self.Name .. ".png"
    self.Background = love.graphics.newImage(f)
    if love.filesystem.exists("gfx/backgrounds/" .. self.Name .. "-Layer1.png") then
        self.Layers = {}
        local loop = true
        local layerNum = 1
        while loop do
            local f = "gfx/backgrounds/" .. self.Name .. "-Layer" .. layerNum .. ".png"
            if love.filesystem.exists(f) then
                self.Layers[layerNum] = love.graphics.newImage(f)
            else
                loop = false
            end
            layerNum = layerNum + 1
        end
    end
		if love.filesystem.exists("gfx/backgrounds/" .. self.Name .. "-Lighting.png") then
			self.Lighting = love.graphics.newImage("gfx/backgrounds/" .. self.Name .. "-Lighting.png")
			self.LightMin = self.LightMin or 200
			self.LightMax = self.LightMax or 255
			self.LightAlpha = (self.LightMin + self.LightMax) / 2
			
		end
    if love.filesystem.exists("gfx/backgrounds/" .. self.Name .. "-Overlay.png") then
        self.Overlay = love.graphics.newImage("gfx/backgrounds/" .. self.Name .. "-Overlay.png")
    end
	if love.filesystem.exists("rooms/" .. self.Name .. "def.lua") then
		local data = love.filesystem.load("rooms/" .. self.Name .. "def.lua")()
		self:InitPlatforms(data)
	else
		self:InitialisePlatforms()
	end
	self.SceneObjects = {}
end

function Room:InitPlatforms(data)
	local p = data.platforms
	self.Platforms = {}
    self.Shapes = {}
	for i,v in ipairs(p) do
		self:AddPlatform(Platform:new(v.mode, unpack(v.verts)))
	end
end

function Room:AddPlatform(p)
	local i = #self.Platforms + 1
	self.Platforms[i] = p
	self.Shapes[i] = p.Collider
end

function Room:Clean()
    self.Background = nil
    self.Layers = nil
    self.Overlay = nil
    Game.CWorld:remove(unpack(self.Shapes))
		for i,v in ipairs(self.SceneObjects) do
			if v.Collider then
				Game.CWorld:remove(v.Collider)
			end
		end
		self.SceneObjects = nil
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

return Room