-- config

require('util')

local Config = {}

function Config:LoadDefaults()
	self.Scale = 3
	self.Fullscreen = false
	self.VSync = true
	self.FSAA = 0
	self:Changed()
	-- TODO load defaults
end

function Config:Save()

	local data = "return {\n"
	for k,v in pairs(self) do
		if type(v) ~= "function" then
			data = data .. k .. " = " .. tostring(v) .. ",\n"
		end
	end
	data = data .. "}"
	
	return love.filesystem.write("cfg.lua", data)

end

function Config:Init()
	if self:Load() then 
		
	else
		
		self:LoadDefaults() 
		self:Save()
	end
end

function Config:InitGfx()

			self.xOffset, self.yOffset = nil, nil
			local w, h = 320 * self.Scale, 180 * self.Scale
			
			if self.Fullscreen then
				local modes = love.graphics.getModes()
				table.sort(modes, function(a,b) return a.width < b.width end)
				for i,v in ipairs(modes) do
					
					local set = false
					if v.width >= w and v.height >= h and v.width / v.height == w / h then
						self.xOffset = ((v.width - w) / 2)
						self.yOffset = ((v.height - h) / 2)
						w = v.width
						h = v.height
					
						set = true
					end
					if set then break end
				end
			end

			love.graphics.setMode(w,h, self.Fullscreen, self.VSync, self.FSAA) 

end

function Config:Changed()
	ModCon:ConfigChanged()
end

function Config:Load()
	if not love.filesystem.exists("cfg.lua") then return false end
	local data = love.filesystem.load("cfg.lua")
  if data then
		table.join(self, data())
		self:Changed()
		return true
	else
		return false
	end

end

return Config