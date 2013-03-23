--CA2

--def

local Room = require("room")

local CA2 = Room:new("CA2")

CA2.PlatformData = {  {"allblock", 7, 180, 319, 180, 319, 198, 7, 198,   },  {"allblock", 69, 170, 110, 170, 110, 179, 69, 179,   },  {"allblock", 46, 159, 92, 159, 92, 169, 46, 169,   },  {"allblock", 0, 150, 75, 150, 75, 158, 0, 158,   },  {"allblock", 318, 0, 318, 132, 309, 132, 297, 124, 300, 97, 298, 49, 279, 35, 241, 39, 238, 34, 209, 52, 205, 34, 142, 34, 119, 39, 92, 52, 61, 47, 54, 33, 55, 49, 42, 58, 41, 71, 25, 82, 25, 92, 22, 98, 0, 98, 0, 0,   },}

CA2:AddExit("right", "CA1")
CA2:AddExit("left", "CA3")

--funcs

function CA2:Enter()
	if not self.Lighting then
		self.Lighting = love.graphics.newImage("gfx/backgrounds/CA2-Lighting.png")
	end
end

function CA2:Update(dt)
	self.Timer = self.Timer or 0
	self.LightAlpha = self.LightAlpha or 200
	self.Timer = self.Timer + dt
	if self.Timer > 0.1 then
		self.Timer = self.Timer - 0.1
		self.LightAlpha = clamp(self.LightAlpha + math.random(50) - 25,150,230)
	end
end

function CA2:PrePlayerDraw()
	love.graphics.setColor(255,255,255,self.LightAlpha)
	love.graphics.draw(self.Lighting,0,0)
	love.graphics.setColor(255,255,255)
end


return CA2