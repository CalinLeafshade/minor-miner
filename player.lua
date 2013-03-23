--player.lua
local vector = require('vector')
local animation = require('animation')
local Game = ModCon.ByName["game"]

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
	Power = 100
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
  --self.JumpTimer = 10 / (1/60)
  --if self.InWater then self.VelY = -self.JumpPower * 0.6
	--else self.VelY = -self.JumpPower
	--end
	
	self.Velocity.y = -self.JumpPower
	self.JumpTimer = 0.25
  self.CanDJump = true;
  if self.Skidding then
    self.Velocity.y = -self.JumpPower
    self.Somersaulting = true
		self.Animations["somersault"].Frame = 1
    self.Velocity.x = -self.Velocity.x * 0.8
  end
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
	log("grad", "dy/dx: " .. dy/dx .. " dy: " .. dy .. " dx: " .. dx)
	log("vec", "vec: " .. tostring(self.CollVec))
	local resolve = false;
  if object.Mode ~= trigger then
    if object.Mode == "allblock" then
      resolve = true
    end
    if object.Mode == "water" then
      self.InWater = true
			self.Water = object.Collider
    end
    if object.Mode == "downonly" then
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
      
      if math.abs(dy / dx) > 1 then self.Collider:move(0, dy) 
      else self.Collider:move(dx, dy) 
      end
    end
    
    if (self.CollVec.y > 0 and object.Mode == "allblock") then
      if self.Velocity.y < 0 then self.Velocity.y = 30 end
      self.JumpTimer = 0
    end
  end
end

function Player:CollideWithEnemy(object, dx, dy)
  if self.Invulnerable then return end
  self.Collider:move(dx,dy)
  
  if self.VelY - object.VelY > 0 then
    Player.VelY = ags.IsKeyPressed(ags.eKeySpace) and -5 or -4
    object:Damage(1)
  else
    self.Invulnerable = true
    self.InvTimer = 40
    if (dx < 0) then self.VelX = -2
    else self.VelX = 2
    end
    --self.VelX = dx * 200
    self.VelY = -4
    self.Hurt = true
    self.OnGround = false
    self:Damage(1)
  end
end

function Player:Collide(shape, dx, dy)
  
  local object = shape.Object
  if object.Type == "platform" then
    self:CollideWithPlatform(object, dx, dy)
  elseif object.Type == "enemy" then
    self:CollideWithEnemy(object, dx, dy)
  end
  
end

function Player:CheckCollisions()
  
  --platforms first
  for i,v in pairs(Room.Current.Platforms or {}) do
    local c,dx,dy = v.Collider:collidesWith(self.Collider)
    if c then
      Player:Collide(v.Collider,-dx,-dy)
    end
  end
  
  --enemies
  
  --for i,v in pairs(EnemyManager.ActiveEnemies) do
--    local c,dx,dy = v.Collider:collidesWith(self.Collider)
--    if c then
--      Player:Collide(v.Collider,-dx,-dy)
--    end
--  end
  
end

function Player:Direction()
  
	if self.Acceleration.x < 0 then
		lastDir = true
		return true
	elseif self.Acceleration.x > 0 then
		lastDir = false
		return false
	elseif self.Velocity.x < 0 then
		lastDir = true
		return true
	elseif self.Velocity.x > 0 then
		lastDir = false
		return false
	end
	return lastDir
end

function Player:Animate(dt)
    -- now for the view frame
  
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
	local done = self.Animations[self.Animation]:Update(dt)
	if done then
		if self.Animation == "somersault" then
			self.Somersaulting = false
		elseif self.Animation == "melee-ground" then
			self.Attacking = false
		end
	end
end


function Player:Update(dt)

  if Input:Is("melee") then
      if self:CanAttack() then self:Melee() end
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
    else
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
  
	local maxS = self.MaxSpeed
  if self.InWater then maxS = maxS * 0.5 end
	
	if math.abs(self.Velocity.x) > maxS then
		self.Velocity.x = (self.Velocity.x / math.abs(self.Velocity.x)) * maxS
	elseif math.abs(self.Velocity.x) < 20 and math.abs(self.Acceleration.x) == 0 then
		self.Velocity.x = 0
	end
	
	local termV = self.TerminalVel
  if self.InWater then termV = termV * 0.25 end
  self.Velocity.y = math.min(self.Velocity.y, termV)
	
	self.Collider:move(self.Velocity.x * dt, self.Velocity.y * dt)

	
	
	
 -- local maxS = self.MaxSpeed
--  if self.InWater then maxS = maxS * 0.5 end
--  if math.abs(self.VelX) > maxS then
--    self.VelX = self.VelX < 0 and -maxS or maxS
--  end
--
--  local termV = self.TerminalVel
--  if self.InWater then termV = termV * 0.25 end
--  if self.VelY > termV then self.VelY = termV end
--  self.Collider:move(self.VelX, self.VelY)
-- 
  if self.OnGround and math.abs(self.Velocity.x) > 0 then
		local x,y = self.Collider:center()
		y = y + 10
		local ychange = 0
		local doMove = false
		
		for i=1,5 do
			if not (self.Ground:contains(x,y + ychange) or self.Ground:contains(x - 5,y + ychange) or self.Ground:contains(x + 5,y + ychange))then
			--if not self.Ground:contains(x,y + ychange) then
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
	
	self.InWater = false
	self.Water = nil
	self:CheckCollisions()
	
	self:Animate(dt)
	
--    --self.Collider:move(0, 1)
--  end
--
--  if self.InvTimer > 0 and not self.Hurt then
--    self.InvTimer = self.InvTimer - 1
--  elseif self.InvTimer == 0 then
--    self.Invulnerable = false
--  end
--  
--  self.InWater = false
--  self:CheckCollisions()
-- 
--  self:Animate()
end


function Player:Draw()

	self.Position.x, self.Position.y = self.Collider:center()
	--self.Position.x = round(self.Position.x)
	--self.Position.y = round(self.Position.y)
	log("playerspeed", tostring(self.Velocity))
	if self.Animation then
		self.Animations[self.Animation]:Draw(self.Position:unpack())
	end
	--self.Collider:draw()
end

return Player