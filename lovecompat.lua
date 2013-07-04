--lovecompat

if love._version:find("^0%.[0-8]%.") then return end

love.graphics.setDefaultImageFilter = love.graphics.setDefaultFilter