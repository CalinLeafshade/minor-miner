-- Game Save Module
GameSaveModule = require('module'):new("gamesave")

function GameSaveModule:Init()
	self.Font = love.graphics.newFont(16)
	self.Alpha = 0
end

function GameSaveModule:GotFocus()
	Game.Player.HP = Game.Player.MaxHP
	Game.Player.Power = 100
	Game.State:Save()
	self.Co = coroutine.create(function()
			local gsm = GameSaveModule
			self.Alpha = 255
			Wait(5)					
			self.Alpha = 0
			self.Co = nil
		end)
	
	ModCon:Defocus()
end

function GameSaveModule:Done()
	
end

function GameSaveModule:Update(dt, focus)
	if self.Co then coroutine.resume(self.Co, dt) end
end

function GameSaveModule:Draw(focus)
	if self.Alpha > 0 then
		love.graphics.setColor(255,255,255,self.Alpha)
		love.graphics.printf("Game Saved",0,100 * Scale,320 * Scale,"center")
	end
end

return GameSaveModule