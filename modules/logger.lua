-- logger

Logger = require('module'):new("logger")
Logger.Priority = -999999999
function Logger:Init()
	self.Messages = {}
	self.Enabled = true
	self.Font = love.graphics.newFont(14)
end

function Logger:Update(dt)
	for i,v in pairs(self.Messages) do
		v.countdown = v.countdown - dt
		if v.countdown <= 0 then
			self.Messages[i] = nil
		end
	end
end

function Logger:Draw()
	local message = ""
	for i,v in pairs(self.Messages) do
		message = message .. v.text .. '\n'
	end
	love.graphics.setFont(self.Font)
	love.graphics.setColor(255,255,255)
	love.graphics.print(message,0,0)
end

function Logger:Add(token, ...)
	if not token then token = UUID() end
	self.Messages[token] = { text = table.concat({...}, ",  "), countdown = 8 }	
end

function log(token, ...)
	Logger:Add(token, ...)
end

return Logger