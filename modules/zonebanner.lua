--Zonebanner module
ZoneBanner = require('module'):new("zonebanner")
ZoneBanner.Priority = -99999

function ZoneBanner:Init()
    self.Sizes = {12,16,100,128,160}
    self.YOffset = {0,0,150,180,220}
    
end

function ZoneBanner:ConfigChanged()
	self.Font = love.graphics.newFont("fonts/banner.ttf", self.Sizes[Config.Scale])
end

function ZoneBanner:Update(dt)
    if not Room.Current then return end
    if Room.Current.Zone and Room.Current.Zone ~= Game.State.LastZone then -- new zone
        if not Game.State.Visited then
            Game.State.Visited = {}
        end
        if Game.State.Visited[Room.Current.Zone] then
            return
        end
        Game.State.Visited[Room.Current.Zone] = true
        log(false, "New Zone")
        Game.State.LastZone = Room.Current.Zone
        self.Running = true
        self.Co = coroutine.create(function()
            self.Alpha = 0
            while self.Alpha < 255 do
                self.Alpha = math.min(self.Alpha + (coroutine.yield() * (255 / 1)),255)
            end
            Wait(4)
            while self.Alpha > 0 do
                self.Alpha = math.max(self.Alpha - (coroutine.yield() * (255 / 1)),0)
            end 
            self.Running = false
        end)
    end
    if self.Running then
        coroutine.resume(self.Co, dt)
    end
end



function ZoneBanner:Draw()
	local Scale = Config.Scale
    if self.Running then
        love.graphics.setColor(0,0,0,self.Alpha / 2)
        love.graphics.rectangle("fill", 0, 120 * Scale, smoothlerp(0,320 * Scale,self.Alpha / 255), 50 * Scale)
        love.graphics.setColor(255,255,255,self.Alpha)
        love.graphics.setFont(self.Font)
        love.graphics.printf(Game.State.LastZone, 0, 140 * Scale - self.YOffset[Scale], 320 * Scale, "center")
    end

end

return ZoneBanner