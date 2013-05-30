-- health and mana bar

local bars = {
	healthBar =
	{
		texture = love.graphics.newImage("gfx/healthbar.png"),
		quads =
		{
			start = love.graphics.newQuad(0,0,2,8,7,8),
			bar = love.graphics.newQuad(2,0,1,8,7,8),
			red = love.graphics.newQuad(3,0,1,8,7,8),
			endRed = love.graphics.newQuad(4,0,1,8,7,8),
			endCap = love.graphics.newQuad(5,0,2,8,7,8)
		},
		x = 252,
		y = 5,
		font = Fonts.tiny,
		width = 60,
		val = 0
	}
}

function bars.healthBar:update(dt)
	self.val = math.max(self.val + (Game.Player.HP - self.val) * (dt * 2), 0)
end

function bars.healthBar:draw()
	local lg = love.graphics
	lg.drawq(self.texture, self.quads.start, self.x, self.y)
	
	local w = self.val / Game.Player.MaxHP * self.width
	
	lg.drawq(self.texture, self.quads.red,self.x + 1,self.y,0,w + 1,1)
	lg.drawq(self.texture, self.quads.endRed,self.x + 2 + w,self.y)
	lg.drawq(self.texture, self.quads.bar,self.x + 2,self.y,0,self.width,1)
	lg.drawq(self.texture, self.quads.endCap, self.x + 2 + self.width,self.y)
	lg.setFont(self.font)
	lg.setColor(Color.White:unpack())
	lg.print(round(self.val), self.x + self.width / 2 - 2, self.y)
end

function bars:draw()
	self.healthBar:draw()
end

function bars:update(dt)
	self.healthBar:update(dt)
end


return bars
