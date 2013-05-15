-- particle system

local psm = {}



function psm:update(dt)
	local dead = {}
	for i, v in ipairs(self.particles) do
		v:update(dt)
		if v.dead then
			table.remove(self.particles, i)
		end
	end
	log("partcount", "Particle Count ", #self.particles)
end

function psm:draw()
	for i = 1,#self.particles do
		self.particles[i]:draw()
	end
end

function psm:add(p)
	self.particles[#self.particles + 1] = p
end

function psm:clear()
	self.particles = {}
end

return psm


