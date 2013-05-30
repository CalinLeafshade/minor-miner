-- main.lua
-- Entry point

Fonts = require('fonts')
Input = require('input')
require('util')
require('color')
require('collisions')
Config = require('config')
GuiManager = require('guimanager')



function love.load()
    
    if arg[#arg] == "-debug" then require("mobdebug").start() end
    love.graphics.setDefaultImageFilter("nearest", "nearest")
    love.mouse.setVisible(false)
    ModCon = require("ModCon")
		ModCon:LoadModules()
		Config:Init()
		Config:InitGfx()
		ModCon:Init()
		
end



function love.quit()

end

function love.keypressed(key)
    if key == "q" then
        love.event.push('quit')
    end
		
	if key == "d" then
		Logger:Toggle()
	end
		if not GuiManager:OnKeypress(key) then
			ModCon:OnKeypress(key)
		end
end

function love.mousepressed(x,y,button)
		if not GuiManager:OnClick(x,y,button) then -- gui caught it
			ModCon:OnClick(x,y,button)
		end
end

function love.mousereleased(x,y,button)
	if not GuiManager:OnMouseRelease(x,y,button) then -- gui caught it
    ModCon:OnMouseRelease(x,y,button)
	end
end

function love.keyreleased(key)
    
end

function love.update(dt)
    Input:Update()
	GuiManager:Update(dt)
    ModCon:Update(dt)
    log("fps", "FPS: " .. love.timer.getFPS())
end

function love.draw()
    ModCon:Draw()
    ModCon:LateDraw()
	GuiManager:Draw()
end