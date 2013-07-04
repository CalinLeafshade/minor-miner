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
	o.Parameters = 
	{
		minX = 0,
		maxX = 320
	}
	return o
end

function Mushroom:HitWall(dx)
	self.Velocity.x = -self.Velocity.x 
	self.Animation.Flipped = self.Velocity.x < 0
end

function Mushroom:DebugDraw(s)
	Editor:DrawPolygon(self.Collider._polygon)
	if s then
		love.graphics.setLineWidth(Config.Scale)
		local x,y = toScreen(self.Collider:center())
		local mnx,mxx = toScreen(self.Parameters.minX, self.Parameters.maxX)
		love.graphics.line(mnx,y,mxx,y)
		love.graphics.line(mnx,y - 10, mnx, y + 10)
		love.graphics.line(mxx,y - 10, mxx, y + 10)
	end
end

function Mushroom:Update(dt)
	self.Animation:Update(dt)
	self:ResolveAndMove(dt)
	local x,y = self.Collider:center()
	if x < self.Parameters.minX then
		self.Collider:move((self.Parameters.minX - x) * 2,0)
		self.Velocity.x = -self.Velocity.x 
		self.Animation.Flipped = self.Velocity.x < 0
	elseif x > self.Parameters.maxX then
		self.Collider:move((x - self.Parameters.maxX) * -2,0)
		self.Velocity.x = -self.Velocity.x 
		self.Animation.Flipped = self.Velocity.x < 0
	end
end

return Mushroom