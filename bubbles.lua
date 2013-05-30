-- numberbubbles

local bubbles =
{
	bubbles = {},
	lifeTime = 1,
	riseSpeed = 10,
	font = Fonts.tiny
}

function bubbles:add(t, x, y, r,g,b)
	r = r or 255
	g = g or 255
	b = b or 255
	table.insert(self.bubbles, {text = t, life = 0, x = x, y = y,r = r, g = g, b = b})
end

function bubbles:update(dt)
	for i,v in ipairs(self.bubbles) do
		v.life = v.life + dt
		if v.life > self.lifeTime then
			table.remove(self.bubbles, i)
		end
		v.y = v.y - self.riseSpeed * dt
	end
	
end

function bubbles:clear()
	self.bubbles = {}
end

function bubbles:draw()
	local lg = love.graphics 
	lg.setFont(self.font)
	for i,v in ipairs(self.bubbles) do
		lg.setColor(v.r,v.g,v.b, lerp(255,0,v.life / self.lifeTime))
		lg.printf(v.text,v.x - 50,v.y,100,"center")
	end
end

function addBubble(t,x,y,r,g,b)
	bubbles:add(t,x,y,r,g,b)
end

return bubbles