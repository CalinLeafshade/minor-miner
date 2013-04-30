--GameModule.lua

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

--- Game:ChangeRoom
-- Continued description
-- @param param  param description 
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
    
    if last and Room.Current ~= last then
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

    if not self.State.Visited[Room.Current.Name] then
        self.State.Visited[Room.Current.Name] = true
        Room.Current:FirstEnter()
        self.State.Map[Room.Current.Name] = {Name = Room.Current.Name, Exits = Room.Current.Exits, Width = Room.Current:Width(), Height = Room.Current:Height()}
        
    end

    self.Player.OnGround = false
    self.Player.Ground = nil
    Room.Current:Enter()
    self.NewRoom = true
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
    if self.NewRoom then
        self.NewRoom = false
        dt = 0
    end
    if focus and not self.Paused then
        self.CWorld:update(dt)
        self.Player:Update(dt)
        self:CheckExits()
        self.Water:Update(dt)
				Room.Current:BaseUpdate(dt)
        Room.Current:Update(dt)
        if not self.Viewport.Locked then
            local x, y = self.Player.Collider:center()
            self.Viewport.x = x - 160
            self.Viewport.y = y - 100
        end
        self:ClampViewport()
        log("viewport", "viewport: ", self.Viewport.x, self.Viewport.y)
    end
end

function Game:ClampViewport()
    self.Viewport.x = clamp(self.Viewport.x,0,Room.Current:Width() - 320)
    self.Viewport.y = clamp(self.Viewport.y,0,Room.Current:Height() - 200)
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
        love.graphics.setColor(0,0,0)
        love.graphics.rectangle("fill",0,0,320,200)
        love.graphics.push()
        love.graphics.translate(-self.Viewport.x, -self.Viewport.y)
        love.graphics.setColor(255,255,255)
        self.Water:PreDraw()
        if Room.Current then
            Room.Current:PreBackgroundDraw()
            Room.Current:DrawBackground()
            Room.Current:PrePlayerDraw()
            self.Player:Draw()
            Room.Current:PostPlayerDraw()
        end
        
        love.graphics.pop() 
        self.Water:Draw()
        if Room.Current.Overlay then 
            love.graphics.draw(Room.Current.Overlay,0,0) 
        end
        love.graphics.setCanvas()
        love.graphics.push()
				love.graphics.translate(Config.xOffset or 0, Config.yOffset or 0)
        love.graphics.scale(Config.Scale, Config.Scale) 
        --love.graphics.draw(self.Canvas,Config.xOffset or 0, Config.yOffset or 0)
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
    elseif keycode == "m" then
        ModCon:Focus(MapScreen)
		elseif keycode == "escape" then
				TitleScreenModule:ShowMenu("pause")
        ModCon:Focus(TitleScreenModule)
    end
end

function Game:Start()
    self:ChangeRoom(self.State.Room)
    self.Visible = true
end

function Game:GotFocus()
    if not self.State then self.State = GameState:new(1) end
end


function Game:LostFocus()
--  HealthBar.Visible = false
--  ags.Debug(4,0)
end

return Game