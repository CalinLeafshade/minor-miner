--animation
local Animation = {}

function Animation:new(filename, width, height, opts)
    o = opts or {}
    setmetatable(o, self)
    self.__index = self
	if type(filename) == "string" then
		o.Image = love.graphics.newImage(filename)
	else
		o.Image = filename
	end
    o.Count = o.Image:getWidth() / width 
    o.Width = width
    o.Height = height
		o.Offset = o.Offset or {math.floor(o.Width / 2), math.floor(o.Height / 2)}
    o.Frame = 1
    o.Counter = 0
    o.Flipped = o.Flipped == nil and false or o.Flipped
    o.Loop = o.Loop == nil and true or o.Loop
    o.Speed = o.Speed or 1
    o.Delays = o.Delays or {}
    o:GenQuads()
    return o
end

function Animation:Reset()
    self.Frame = 1
    self.Counter = 0
end

function Animation:GenQuads()
    self.Quads = {}
    for i = 1, self.Count + 1 do
        self.Quads[i] = love.graphics.newQuad((i-1) * self.Width, 0, self.Width, self.Height, self.Image:getWidth(), self.Image:getHeight())
    end
end

function Animation:Advance()
    if self.Frame == self.Count then 
        if self.Loop then self.Frame = 1 end
        return true
    else
        self.Frame = self.Frame + 1
        return false
    end
end

function Animation:Update(dt)
    self.Counter = self.Counter + dt
    if self.Counter > self.Speed + (self.Delays[self.Frame] or 0) then
        self.Counter = self.Counter - self.Speed
        return self:Advance()
    end
    return false
end

function Animation:Draw(x,y)
    if self.Frame > self.Count then self.Frame = 1 end
    local flip = self.Flipped and -1 or 1
    love.graphics.drawq(self.Image, self.Quads[self.Frame], x, y,0,flip,1,self.Offset[1], self.Offset[2])
end

return Animation