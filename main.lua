-- main.lua
-- Entry point

Input = require('input')
require('util')



function love.load()
	if arg[#arg] == "-debug" then require("mobdebug").start() end
	love.graphics.setDefaultImageFilter("nearest", "nearest")
	Scale = 4
	ModCon = require("ModCon")
	ModCon:Init()
end


function love.quit()
	
end

function love.keypressed(key)
	if key == "q" then
		love.event.push('quit')
	end
	ModCon:OnKeypress(key)
end

function love.mousepressed(x,y,button)
	ModCon:OnClick(x,y,button)
end

function love.keyreleased(key)
	
end

function love.update(dt)
	Input:Update()
	ModCon:Update(dt)
	log("fps", "FPS: " .. love.timer.getFPS())
end

function love.draw()
	ModCon:Draw()
	ModCon:LateDraw()
end