
local vector = require('vector')
local animation = require('animation')
Spark = {}

function Spark:new(x,y,vx,vy)
	local o = {}
	setmetatable(o, self)
	self.__index = self
	o.Collider = Game.CWorld:addPoint(x,y)
	Game.CWorld:addToGroup("particles", o.Collider)
	o.life = 0
	o.Velocity = vector.new(vx or 0, vy or 0)
	return o
end

function Spark:update(dt)
	self.life = self.life + dt
	if self.life > 5 then
		self:kill()
		return
	end
	
	for v in pairs(self.Collider:neighbors()) do
		if v.Object and v.Object.Type and v.Object.Type == "platform" then
			local c,dx,dy = v:collidesWith(self.Collider)
			if c then
				self:kill()
			end
		end
	end
	
	self.Velocity.y = self.Velocity.y + Game.Gravity.y * dt
	local dx,dy = self.Velocity.x * dt, self.Velocity.y * dt
	if dx ~= dx then
		dx = 0
	end
	if dy ~= dy then
		dy = 0
	end
	self.Collider:move(dx,dy)
	
end

function Spark:draw()
	local x,y = self.Collider:center()
	love.graphics.setLineStyle("rough")
	love.graphics.setColor(234,175,46, 127)
	love.graphics.setBlendMode("additive")
	love.graphics.line(x,y,x - self.Velocity.x / 50, y - self.Velocity.y / 50)
	love.graphics.setBlendMode("alpha")
end

function Spark:kill()
	self.dead = true
	Game.CWorld:remove(self.Collider)
end

Bomb = 
{
	SparkLoc = 
	{
		{4,3},
		{4,5},
		{5,6},
		{7,7},
		{8,6},
		{9,5},
		{11,6},
		{12,8},
		{11,10}
	}
}

function Bomb:new(o)
	local o = o or {}
	setmetatable(o, self)
	self.__index = self
	o.Animation = animation:new("gfx/bomb.png", 15, 13, {Speed = 0.5})
	o.Velocity = o.Velocity or vector.new(0,0)
	o.Collider = Game.CWorld:addCircle(0,0,5)
	Game.CWorld:addToGroup("bombs", o.Collider)
	o.Width = 10
	o.Height = 10
	o.Collider:moveTo(o.x, o.y)
	o.normalVector = vector.new(0,0)
	o.lastSpark = 0
	return o
end

function Bomb:PlatformCollide(v,dx,dy)
	log(self, "collision")
	local normal = vector.new(dx,dy):normalized()
	self.Collider:move(dx,dy)
	self.Velocity = self.Velocity:reflect(normal) * 0.5
	if self.Velocity:len() < 1 then
		self.Velocity.x,self.Velocity.y = 0,0
		self.OnGround = true
		self.Ground = v
	end
end

function Bomb:Update(dt)
	
	if not self.Collider then return end
	
	local x,y = self.Collider:center()
	local xx,yy = self.Collider:bbox()
	if self.lastSpark <= 0 then
		
		Game.PSM:add(Spark:new(xx + self.SparkLoc[self.Animation.Frame][1] - 1, yy + self.SparkLoc[self.Animation.Frame][2], math.random(150) - 75, 0 - math.random(150)))
		Game.PSM:add(Spark:new(xx + self.SparkLoc[self.Animation.Frame][1] - 1, yy + self.SparkLoc[self.Animation.Frame][2], math.random(150) - 75, 0 - math.random(150)))
		self.lastSpark = 0.1
	else
		self.lastSpark = self.lastSpark - dt
	end
	
	
	if x ~= self.lastX or y ~= self.lastY then -- moved
	
	
		if not self.OnGround then
			self.Velocity = self.Velocity + Game.Gravity * dt
		end
		
		self.Collider:move(self.Velocity.x * dt, self.Velocity.y * dt)
		
		--for i,v in ipairs(Room.Current.Platforms or {}) do
		for v in pairs(self.Collider:neighbors()) do
			
				if v.Object and v.Object.Type == "platform" then
					local c,dx,dy = v:collidesWith(self.Collider)
					if c then
							self:PlatformCollide(v.Object,-dx,-dy)
					end
				end
		end
	
	end
	self.lastX, self.lastY = x,y
	self.Animation:Update(dt)
end

function Bomb:Draw()
	local x,y = self.Collider:center()
	love.graphics.setColor(Color.White:unpack())
	self.Animation:Draw(x,y)
	
end