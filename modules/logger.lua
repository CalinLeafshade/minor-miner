-- logger
require("util")

Logger = require('module'):new("logger")
Logger.Priority = -999999999
Logger.Messages = {}
Logger.Enabled = true
Logger.Font = love.graphics.newFont(14)
function Logger:Init()
   self.on = true
end

function Logger:Toggle()
	self.on = not self.on
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
	if not self.on then return end
    local message = ""
    for i,v in pairs(self.Messages) do
        message = message .. v.text .. '\n'
    end
	love.graphics.push()
	love.graphics.translate(0,0)
    love.graphics.setFont(self.Font)
    love.graphics.setColor(0,0,0)
    love.graphics.print(message,1,1)
    love.graphics.setColor(255,255,255)
    love.graphics.print(message,0,0)
	love.graphics.pop()
end

function Logger:Add(token, ...)
    if not token then token = UUID() end
    self.Messages[token] = { text = table.concat({...}, ",  "), countdown = 8 } 
end

function log(token, ...)
    Logger:Add(token, ...)
end

return Logger