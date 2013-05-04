--mushroom

local animation = require('animation')

Mushroom = require('enemy'):new("mushroom")

function Mushroom:new()
	local o = {}
	setmetatable(o, self)
    self.__index = self
	o.Animation = animation:new("gfx/enemies/mushroom.png", 14,13, {Speed = 0.17})
	o.Collider = Game.CWorld:addRectangle(0,0,14,13)
	o.Collider.Object = o
	o.Width = 14
	o.Height = 13
	o.CollVec = vector.new(0,0)
	o.Velocity = vector.new(50,0)
	return o
end

function Mushroom:HitWall(dx)
	self.Velocity.x = -self.Velocity.x 
	self.Animation.Flipped = self.Velocity.x < 0
end

function Mushroom:Update(dt)
	self.Animation:Update(dt)
	self:ResolveAndMove(dt)
end

return Mushroom