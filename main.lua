--main.lua
Input = require('input')
require('util')


local love_timer_sleep = love.timer.sleep -- in s (like >=0.8.0)
if love._version:find("^0%.[0-7]%.") then -- if version < 0.8.0
   -- love.timer.sleep in ms
   love_timer_sleep = function(s) love.timer.sleep(s*1000) end
end

function love.load()
	if arg[#arg] == "-debug" then require("mobdebug").start() end
	love.graphics.setDefaultImageFilter("nearest", "nearest")
	Scale = 4
	ModCon = require("ModCon")
	ModCon:Init()
	min_dt = 1/120
	next_time = love.timer.getMicroTime()
	
	
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
	next_time = next_time + min_dt
	Input:Update()
	ModCon:Update(dt)
	log("fps", "FPS: " .. love.timer.getFPS())
end

function love.draw()
	ModCon:Draw()
	ModCon:LateDraw()
	
	local cur_time = love.timer.getMicroTime()
  if next_time <= cur_time then
    next_time = cur_time
    return
  end
  --love_timer_sleep(next_time - cur_time)
end