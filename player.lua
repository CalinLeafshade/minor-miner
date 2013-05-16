--player.lua
local vector = require('vector')
local animation = require('animation')
local Game = ModCon.ByName["game"]

local Dust = {}

function Dust:new(x,y)
	local o = {}
	setmetatable(o, self)
	self.__index = self
	o.x = x
	o.y = y
	o.life = 0
	o.shade = math.random(100,150)
	return o
end

function Dust:update(dt)
	self.life = self.life + dt * 2
	self.y = self.y - 3 * dt
end

function Dust:draw()
	local alpha = lerp(255,0,self.life)
	if alpha < 0 then
		self.dead = true
		return
	end
	love.graphics.setColor(self.shade,self.shade,self.shade,alpha)
	love.graphics.setLineStyle("rough")
	love.graphics.line(self.x,self.y,self.x + 0.5,self.y + 0.5)
end

local Player = 
{
    CollVec = vector.new(0,0),
    Position = vector.new(160,100),
    Velocity = vector.new(0,0),
    Acceleration = vector.new(0,0),
    Collider = Game.CWorld:addRectangle(160,100, 10,20),
    Animations = 
    {
        stand=animation:new("gfx/miner/stand.png",20,20),
        run=animation:new("gfx/miner/run.png",20,20),
        hurt=animation:new("gfx/miner/hurt.png",20,20),
        inair=animation:new("gfx/miner/inair.png",20,20),
        skid=animation:new("gfx/miner/skid.png",20,20),
        ["melee-ground"]=animation:new("gfx/miner/melee-ground.png",40,20, {Speed = 0.045,Loop=false,Delays={[1]=0.1,[6]=0.2}}),
        somersault=animation:new("gfx/miner/somersault.png",20,20, {Speed=0.06,Loop=false}),
    },
    Animation = "stand",
    TerminalVel = 500,
    OnGround = false,
    Speed = 300,
    JumpPower = 200,
    AirSpeed = 0.066,
    MaxSpeed = 150,
    AirDrag = 0.97,
    GroundDrag = 0.93,
    HP = 25,
    MaxHP = 25,
    Power = 100,
    InvTimer = 0,
		lastDust = 0
}

function Player:CanSave()
    local shapes = Game.CWorld:shapesAt(Player.Collider:center()) or {}
    for i,v in ipairs(shapes) do
        if v.Object and v.Object.Mode == "save" then
            return true
        end
    end
    return false
end

function Player:CanMove()
    return not self.Attacking and not self.hurt
end

function Player:CanAttack()
    return self.OnGround and not self.Attacking and not self.Somersaulting
end

function Player:CanJump()
    return self:CanMove() and not self.Attacking and self.OnGround
end

function Player:CanDoubleJump()
    return self.CanDJump
end

function Player:Melee()
    self.Attacking = true
    self.Animation = "melee-ground"
    self.Animations["melee-ground"]:Reset()
end

function Player:Jump()
    self.OnGround = false
    self.Velocity.y = -self.JumpPower
    self.JumpTimer = 0.25
    self.CanDJump = true;
    if self.Skidding then
        self.Velocity.y = -self.JumpPower
        self.Somersaulting = true
        self.Animations["somersault"].Frame = 1
        self.Velocity.x = -self.Velocity.x * 0.8
		end
		self.Skidding = false
end

function Player:DoubleJump()
    self.CanDJump = false
    self.Somersaulting = true
    self.Animations["somersault"].Frame = 1
    self.Velocity.y = -self.JumpPower * 1.5
end


function Player:CollideWithPlatform(object, dx, dy)   
    self.CollVec.x = dx
    self.CollVec.y = dy
    self.CollVec:normalize()
    local resolve = false;
    if object.Mode ~= trigger then

        if object.Mode == "allblock" then
            resolve = true
        elseif object.Mode == "water" then
            self.InWater = true
            self.Water = object.Collider
        elseif object.Mode == "downonly" then
            if ((dy < 0 and self.Velocity.y >= 0) or self.OnGround) then
                resolve = true
            end
        end
        
        if resolve then 
            if math.abs(dy / dx) > 1 and dy < 0 and self.Velocity.y >= 0 then
                self.OnGround = true
                self.Somersaulting = false
                self.CanDJump = false
                self.Hurt = false
                self.Ground = object.Collider
                self.Velocity.y = 0
            elseif (math.abs(self.CollVec.x) > 0.5) then
                if (dx < 0 and self.Velocity.x > 0) or (dx > 0 and self.Velocity.x < 0) then
                    self.Velocity.x = 0
                end
            end
          
            if math.abs(dy / dx) > 1 then 
                self.Collider:move(0, dy) 
            else 
                self.Collider:move(dx, dy) 
            end
        end
        
        if (self.CollVec.y > 0.5 and object.Mode == "allblock") then
            if self.Velocity.y < 0 then 
                self.Velocity.y = 30 
            end
            self.JumpTimer = 0
        end
    end
end

function Player:ThrowBack(dx, dy, invTime)
	self.Velocity.x = dx
	self.Velocity.y = dy
	self.Hurt = true
	self.Invulnerable = true
	self.OnGround = false
	self.InvTimer = invTime or 3
end

function Player:CollideWithEnemy(object, dx, dy)
    
    if self.Invulnerable then return end -- no effect
    
    self.Collider:move(dx,dy)
    self:ThrowBack(dx > 0 and 300 or -300, -300, 5)
    --self:Damage(1)
end

function Player:Collide(shape, dx, dy)
    local object = shape.Object
		if not object then return end
    if object.Type == "platform" then
        self:CollideWithPlatform(object, dx, dy)
    elseif object.Type == "enemy" then
        self:CollideWithEnemy(object, dx, dy)
    end
end

function Player:CheckCollisions()
  
    --platforms first
		
    for v in pairs(self.Collider:neighbors()) do
		
        local c,dx,dy = v:collidesWith(self.Collider)
        if c then
            self:Collide(v,-dx,-dy)
        end
    end
		
  --TODO Enemy collision
end

function Player:Direction()
  
    if self.Acceleration.x < 0 then
        self.lastDir = true
        return true
    elseif self.Acceleration.x > 0 then
        self.lastDir = false
        return false
    elseif self.Velocity.x < 0 then
        self.lastDir = true
        return true
    elseif self.Velocity.x > 0 then
        self.lastDir = false
        return false
    end
    return self.lastDir
end

function Player:Animate(dt)
    
    local d = self:Direction()

    if self.OnGround then  
        if self.Attacking then
            self.Velocity.x = 0
            self.Animation = "melee-ground"
        end
        if not self.Attacking then
            if self.Velocity.x == 0 and self.Acceleration.x == 0 then
                self.Animation = "stand"
                self.Skidding = false
            elseif (math.abs(self.Velocity.x) > 0.2) and ((self.Velocity.x < 0 and self.Acceleration.x > 0) or (self.Velocity.x > 0 and self.Acceleration.x < 0)) then -- skidding
                self.Animation = "skid"
                self.Skidding = true
            else
                self.Skidding = false
                self.Animation = "run"
                self.Animations[self.Animation].Speed = 0.2 - math.abs(self.Velocity.x) / 1200
            end 
        end
    elseif self.Somersaulting then
        self.Animation = "somersault"
    elseif self.Hurt then
        self.Animation = "hurt"
    else
        self.Animation = "inair"
    end

    self.Animations[self.Animation].Flipped = d
    
    if self.Animations[self.Animation]:Update(dt) then
        if self.Animation == "somersault" then
            self.Somersaulting = false
        elseif self.Animation == "melee-ground" then
            self.Attacking = false
        end
    end

end

function Player:Bomb(throw)
	local v = throw and vector.new(100 * (self:Direction() and -1 or 1), -100) or vector.new(0,0)
	local x,y = self.Collider:center()
	Room.Current:AddObject(Bomb:new({Velocity = v, x=x,y=y}))
end


function Player:Update(dt)

    if Input:Is("melee") then
        if self:CanAttack() then self:Melee() end
    end
  
		if Input:Is("bomb") then
			self:Bomb(not Input:Is("down"))
		end
		
    if Input:Is("up") and self.CanSave() then
        Game:Save()
    end

    if Input:Is("jump") then
        if (self:CanJump()) then
            self:Jump()
        elseif self:CanDoubleJump() then
            self:DoubleJump()
        end
    elseif not Input:IsKeyDown("jump") then
        self.JumpTimer = 0
    end
  
		if self.Skidding then
			if self.lastDust <= 0 then
				local x,y = self.Collider:center()
				Game.PSM:add(Dust:new(math.random() + x + (self:Direction() and 7 or -7), math.random() + y + 10))
				Game.PSM:add(Dust:new(math.random() + x + (self:Direction() and 7 or -7), math.random() + y + 10))
				self.lastDust = 0.01
			else
				self.lastDust = self.lastDust - dt
			end
		end
		
    --Gravity
    
    if not self.OnGround and self.JumpTimer <= 0 then
        self.Velocity = self.Velocity + Game.Gravity * dt
    end
    
    if not self.OnGround and self.InWater then
        self.Velocity = self.Velocity - (Game.Gravity * 0.3) * dt
    end
        
      
    if self:CanMove() then
        self.Acceleration.x = 0
        if Input:Is("left") then
            self.Acceleration.x = -self.Speed
        elseif Input:Is("right") then
            self.Acceleration.x = self.Speed
        elseif not self.Hurt then
            local drag = self.OnGround and self.GroundDrag or self.AirDrag
            drag = 1 - ((1 - drag) * dt) * 60
            self.Velocity.x = self.Velocity.x * drag
            if math.abs(self.Velocity.x) < 0.7 then self.Velocity.x = 0 end
        end
    end
  
    if self.JumpTimer > 0 then
        self.JumpTimer = self.JumpTimer - dt
    end


    if self.InWater then 
        self.Acceleration.x = self.Acceleration.x * 0.5
        self.Acceleration.y = self.Acceleration.y * 0.75
    end
  
    self.Velocity = self.Velocity + self.Acceleration * dt
  
    local maxS = self.InWater and self.MaxSpeed * 0.5 or self.MaxSpeed
        
    if math.abs(self.Velocity.x) > maxS then
        self.Velocity.x = (self.Velocity.x / math.abs(self.Velocity.x)) * maxS
    elseif math.abs(self.Velocity.x) < 20 and math.abs(self.Acceleration.x) == 0 then
        self.Velocity.x = 0
    end
    
    local termV = self.InWater and self.TerminalVel * 0.25 or self.TerminalVel
    
    self.Velocity.y = math.min(self.Velocity.y, termV)
    
    self.Collider:move(self.Velocity.x * dt, self.Velocity.y * dt)

    if self.OnGround and math.abs(self.Velocity.x) > 0 then
        local x,y = self.Collider:center()
        y = y + 10
        local ychange = 0
        local doMove = false
        
        for i=1,5 do
            if not (self.Ground:contains(x,y + ychange) or self.Ground:contains(x - 4,y + ychange) or self.Ground:contains(x + 4,y + ychange)) then
                ychange = ychange + 1
            else
                doMove = true
                break;
            end
        end
    
        if doMove then
            self.Collider:move(0, math.max(ychange - 1,0))
            log("ychange", "ychnge", ychange - 1)
        else
            self.OnGround = false
        end
    end
    
    self.InWater = false -- assume left water, let CheckCollisions refresh it
    self.Water = nil
    self:CheckCollisions()
    
    self:Animate(dt)
    
    self.Position.x, self.Position.y = self.Collider:center()

    if self.InvTimer > 0 and not self.Hurt then
        self.InvTimer = self.InvTimer - dt
    elseif self.InvTimer <= 0 then
        self.Invulnerable = false
    end

end


function Player:Draw()
    if self.Animation then
        local alpha = self.Invulnerable and (math.sin(love.timer.getTime() * 30) + 1) / 2 * 255 or 255
        local tint = Room.Current.Tint or White
        love.graphics.setColor(tint[1],tint[2],tint[3], alpha)  
        self.Animations[self.Animation]:Draw(self.Collider:center())
    end
end

return Player