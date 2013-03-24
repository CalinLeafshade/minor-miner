--GameModule.lua

require("bloom")
Room = require("room")
Platform = require("platform")
Game = require("module"):new("game")
vector = require("vector")
require('gamestate')
local HC = require("hardoncollider")

function on_collide()
	
end

function stop_colliding()
	
end

function Game:ChangeRoom(roomName, edge, enMult, exMult)
	enMult = enMult or 0
	exMult = exMult or 0
	if not Room.Rooms[roomName] then
			Room.Rooms[roomName] = require("rooms." .. roomName)
	end
	
	assert(Room.Rooms[roomName], "Room does not exist")
	
	
	local last = Room.Current
	Room.Current = Room.Rooms[roomName]
	Room.Current:Init()
	
	if last then
		local w = Room.Current:Width()
		local h = Room.Current:Height()
		
		if edge == "left" then
			self.Player.Collider:move(w, (exMult - enMult) * 200)
		elseif edge == "right" then
			self.Player.Collider:move(-last:Width(), (exMult - enMult) * 200)
		elseif edge == "top" then
			self.Player.Collider:move((exMult - enMult) * 320, h)
		elseif edge == "bottom" then
			self.Player.Collider:move((exMult - enMult) * 320, -last:Height())
		end
		
		last:Leave()
		last:Clean()
	end
	
	self.Water:NewRoom()
	Room.Current:Enter()
end

function Game:Init()
	self.CWorld = HC(100, on_collide, stop_colliding)
	self.Player = require("player")
	self.Viewport = {x=0,y=0}
	self.Water = require('water')
	self.Water:Init()
	self.Gravity = vector.new(0,1200)
	self.Canvas = love.graphics.newCanvas(320,200)
	self.Canvas:setFilter("nearest", "nearest")
	self:ChangeRoom("CA8")
end

function Game:CheckExits()
	
	local r = Room.Current
	local x,y = self.Player.Collider:center()
	local multY = math.floor(y / 200)
	local multX = math.floor(x / 320)
	local exit = ""
	local mult = 0
	if x < 0 then
		exit = "left"
		mult = multY
	elseif x > r:Width() then
		exit = "right"
		mult = multY
	elseif y < 0 then   
		exit = "top"
		mult = multX
	elseif y > r:Height() then
		exit = "bottom"
		mult = multX
	end
	if r.Exits[exit] and r.Exits[exit][mult] then
		self:ChangeRoom(r.Exits[exit][mult].Room, exit, mult, r.Exits[exit][mult].ExitMult)
	end
  
end

function Game:Update(dt, focus)
  if focus and not self.Paused then
      self.Player:Update(dt)

			self:CheckExits()
			self.Water:Update(dt)
			Room.Current:Update(dt)
			if not self.Viewport.Locked then
				self.Viewport.x = clamp(self.Player.Position.x - 160,0,Room.Current:Width() - 320)
				self.Viewport.y = clamp(self.Player.Position.y - 100,0,Room.Current:Height() - 200)
			end
  end
end

function Game:LockViewport(x,y)
	self.Viewport.x = x
	self.Viewport.y = y
	self.Viewport.Locked = true
end

function Game:UnlockViewport()
	self.Viewport.Locked = false
end

function Game:NewGame(slot)
	self.State = GameState:new(slot)
end

function Game:Draw(focus)
	if self.Visible then		
		love.graphics.setCanvas(self.Canvas)
		love.graphics.clear()
		love.graphics.push()
		love.graphics.translate(-self.Viewport.x, -self.Viewport.y)
		love.graphics.setColor(255,255,255)
		self.Water:PreDraw()
		if Room.Current then
			love.graphics.draw(Room.Current.Background,0,0)
			Room.Current:PrePlayerDraw()
			self.Player:Draw()
			Room.Current:PostPlayerDraw()
		end
		
		love.graphics.pop()	
		self.Water:Draw()
		if Room.Current.Overlay then love.graphics.draw(Room.Current.Overlay,0,0) end
		love.graphics.setCanvas()
		love.graphics.push()
		love.graphics.scale(Scale, Scale) 
		love.graphics.draw(self.Canvas,0,0)
		love.graphics.pop()	
	end
end

function Game:Save()
	ModCon:Focus(GameSaveModule)
end

function Game:Load(slot)
	self.State = GameState.Load(slot)
	if not self.State then return false end
	self.Player.Collider:moveTo(self.State.PlayerX, self.State.PlayerY)
	self.Player.MaxHP = self.State.HP
	self.Player.HP = self.MaxHP
	return true
end

function Game:OnKeypress(keycode)
  if keycode == "tab" then
		ModCon:Focus(Editor)
	elseif keycode == "l" then
		self:Load(1)
	end
	
	
--elseif keycode == ags.eKeyP then
--    self.Paused = not self.Paused
--	elseif keycode == ags.eKeyF9 then
--		ags.RestartGame()
--	elseif keycode == ags.eKeyS then
--		self:Save()
--	elseif keycode == ags.eKeyL then
--		GameState:Load(1)
--	elseif keycode == ags.eKeyCtrlC then
--		ModCon:Focus(ConsoleModule)
--	elseif keycode == ags.eKeyCtrlX then
--		Player.Collider:moveTo(160,100)
--		ags.Debug(3,0)
--  end
  
end

function Game:Start()
	self:ChangeRoom(self.State.Room)
	self.Visible = true
end

function Game:GotFocus()
	if not self.State then self.State = GameState:new(1) end
end


function Game:LostFocus()
--	HealthBar.Visible = false
--	ags.Debug(4,0)
end




return Game