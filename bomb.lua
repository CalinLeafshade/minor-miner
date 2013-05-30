
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
	
	local lg = love.graphics
	lg.setLineStyle("rough")
	lg.setBlendMode("additive")
	lg.setColor(234,175,46, 10)
	lg.circle("fill",x,y,5,8)
	lg.setLineWidth(2)
	lg.setColor(234,175,46, 50)
	lg.line(x,y,x - self.Velocity.x / 40, y - self.Velocity.y / 40)
	lg.setColor(234,175,46, 127)
	lg.setLineWidth(1)
	lg.line(x,y,x - self.Velocity.x / 50, y - self.Velocity.y / 50)
	lg.line(x,y,x - self.Velocity.x / 70, y - self.Velocity.y / 70)
	
	lg.line(x,y,x - self.Velocity.x / 90, y - self.Velocity.y / 90)
	lg.setBlendMode("alpha")
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
	o.Animations = 
		{
			bomb = animation:new("gfx/bomb.png", 15, 13, {Speed = 0.5}),
			explosion = animation:new("gfx/explosion.png", 30, 39, {Speed = 0.07, Offset = {15,32}}),
		}
	o.Animation = o.Animations["bomb"]
	o.Velocity = o.Velocity or vector.new(0,0)
	o.Collider = Game.CWorld:addCircle(0,0,5)
	Game.CWorld:addToGroup("bombs", o.Collider)
	o.Width = 10
	o.Height = 10
	o.State = "bomb"
	o.Collider:moveTo(o.x, o.y)
	o.normalVector = vector.new(0,0)
	o.lastSpark = 0
	return o
end

function Bomb:PlatformCollide(v,dx,dy)
	
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
	if self.State == "bomb" then
		if self.lastSpark <= 0 then
			
			Game.PSM:add(Spark:new(xx + self.SparkLoc[self.Animation.Frame][1] - 1, yy + self.SparkLoc[self.Animation.Frame][2], math.random(150) - 75, 0 - math.random(150)))
			Game.PSM:add(Spark:new(xx + self.SparkLoc[self.Animation.Frame][1] - 1, yy + self.SparkLoc[self.Animation.Frame][2], math.random(150) - 75, 0 - math.random(150)))
			self.lastSpark = 0.1
		else
			self.lastSpark = self.lastSpark - dt
		end
	end
	
	if x ~= self.lastX or y ~= self.lastY then -- moved
	
	
		if not self.OnGround then
			self.Velocity = self.Velocity + Game.Gravity * dt
		end
		
		local dx, dy = self.Velocity.x * dt, self.Velocity.y * dt
		if dx ~= dx then dx = 0 end
		if dy ~= dy then dy = 0 end
		
		self.Collider:move(dx,dy)
		
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
	if self.Animation:Update(dt) then
	
		if self.State == "bomb" then
			self:Explode()
		elseif self.State == "explosion" then
			self:Kill()
		end
	end
end

function Bomb:Explode()
	self.Animation = self.Animations['explosion']
	self.State = "explosion"
end

function Bomb:Kill()
	Room.Current:RemoveObject(self)
end

function Bomb:Draw()
	local x,y = self.Collider:center()
	love.graphics.setColor(Color.White:unpack())
	self.Animation:Draw(x,y)
end
