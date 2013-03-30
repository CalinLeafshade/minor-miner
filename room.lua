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

return Room