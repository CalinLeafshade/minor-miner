--runner

--bat

local animation = require('animation')

Runner = require('enemy'):new("runner")

function Runner:new()
	local o = {}
	setmetatable(o, self)
    self.__index = self
	o.Animation = animation:new("gfx/enemies/runner.png",15,20)
	o.Collider = Game.CWorld:addRectangle(0,0,15,15)
	o.Collider.Object = o
	o.Width = 14
	o.Height = 13
	o.CollVec = vector.new(0,0)
	o.Velocity = vector.new(0,0)
	o.State = "rest"
	o.Rotation = 0
	o.Parameters = 
	{
		speed = 20,
		platform = -1,
	}
	return o
end

function Runner:DebugDraw(selected)
	Editor:DrawPolygon(self.Collider._polygon)
	if self.vertex then
		Editor:DrawLine(self.vertex.x, self.vertex.y, self.nextVertex.x, self.nextVertex.y)
		local l = self.Direction:perpendicular() * 5
		local x,y = self.Collider:center()
		Editor:DrawLine(x,y,x +l.x, y + l.y)
	end
end

function Runner:setNextVertex()
	local p = Room.Current.Platforms[self.Parameters.platform]
	local verts = {p.Collider._polygon:unpack()}
	self.vertexIndex = self.vertexIndex + 2
	if self.vertexIndex > #verts then
		self.vertexIndex = 1
	end
	local vi = self.vertexIndex
	self.vertex = vector(verts[vi], verts[vi + 1])
	self.nextVertex = vector(verts[vi + 2] or verts[1], verts[vi + 3] or verts[2])
	self.Direction = (self.nextVertex - self.vertex):normalized()
	self.Rotation = vector.angle(self.Direction:perpendicular(), vector(0,1))
	local test = self.Direction + self.Direction:perpendicular()
	if self.Direction:perpendicular().x < 0 then 
		--self.Rotation = self.Rotation - math.pi
	end
	self.Animation.Rotation = self.Rotation
	log("rot", self.Rotation)
end

function Runner:resetPlatform()
	local p = Room.Current.Platforms[self.Parameters.platform]
	if p then
		local verts = {p.Collider._polygon:unpack()}
		self.vertexIndex = -1 -- +2 = 1
		self:setNextVertex()
		self:MoveTo(verts[1], verts[2])
		self.vertexIndex = 1
	end
end

function Runner:ParameterChanged(name)
	if name == "platform" then
		self:resetPlatform()
	end
end

function Runner:Update(dt)
	if not self.vertex then
		self:resetPlatform()
	else
		local p = vector(self.Collider:center())
		local d = vector.distance(p, self.nextVertex)
		
		if d <= 2 then
			self:MoveTo(self.nextVertex.x, self.nextVertex.y)
			self:setNextVertex()
		else
			self.Velocity = self.Direction * self.Parameters.speed
			self.Collider:move(self.Velocity.x * dt, self.Velocity.y * dt)
		end
		log(self, "Vertex: " .. tostring(self.vertex) .. " Next: " .. tostring(self.nextVertex))
	end
end

return Runner