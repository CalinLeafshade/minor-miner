--Zonebanner module
ZoneBanner = require('module'):new("zonebanner")
ZoneBanner.Priority = -99999

function ZoneBanner:Init()
    --self.Sizes = {12,16,100,128,160}
    --self.YOffset = {0,0,150,180,220}
    
end

function ZoneBanner:ConfigChanged()
	self.Font = love.graphics.newFont("fonts/banner.ttf", 16)
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
				local lg = love.graphics
				lg.push()
				lg.scale(Config.Scale)
        lg.setColor(0,0,0,self.Alpha / 2)
        lg.rectangle("fill", 0, 120, smoothlerp(0,320,self.Alpha / 255), 50)
        lg.setColor(255,255,255,self.Alpha)
        lg.setFont(self.Font)
        lg.printf(Game.State.LastZone, 0, 120, 320, "center")
				lg.pop()
    end

end

return ZoneBanner