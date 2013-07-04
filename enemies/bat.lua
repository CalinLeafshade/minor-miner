--bat

local animation = require('animation')

Bat = require('enemy'):new("bat")

function Bat:new()
	local o = {}
	setmetatable(o, self)
    self.__index = self
	o.Animations = 
	{
		rest = animation:new("gfx/enemies/batrest.png", 15,15, {Speed = 0.5}),
		chasing = animation:new("gfx/enemies/bat.png", 15,15, {Speed = 0.2}),
	}	
	o.Animation = o.Animations.rest
	o.Collider = Game.CWorld:addRectangle(0,0,15,15)
	o.Collider.Object = o
	o.Width = 14
	o.Height = 13
	o.CollVec = vector.new(0,0)
	o.Velocity = vector.new(0,0)
	o.State = "rest"
	o.Parameters = 
	{
		speed = 20,
		wakeDistance = 50
	}
	return o
end

function Bat:DebugDraw(selected)
	
	if selected then
		local x,y = self.Collider:center()
		x,y = toScreen(x,y)
		love.graphics.circle("line",x,y,self.Parameters.wakeDistance * Config.Scale)
	end
	Editor:DrawPolygon(self.Collider._polygon)
end

function Bat:Update(dt)
	self.Animation = self.Animations[self.State]
	self.Animation:Update(dt)
	if self.State == "rest" then
		if vector.distance(Game.Player:Position(), self:Position()) <= self.Parameters.wakeDistance then
			self.State = "chasing"
		end
	else
		self.Velocity = (Game.Player:Position() - self:Position()):normalize() * self.Parameters.speed
		self.Collider:move(self.Velocity.x * dt,self.Velocity.y * dt)
		self:CheckCollisions(function(v,dx,dy)
				
				if v.Mode == "allblock" or v.Mode == "water" then
					self.Collider:move(dx,dy)
				end
				
			end)
	end
end

return Bat