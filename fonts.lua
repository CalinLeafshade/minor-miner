--Fonts

local s = ""
for i=32,127 do
	s = s .. string.char(i)
end



local fonts = 
{
	betterPixels = love.graphics.newImageFont(love.graphics.newImage("fonts/betterpixels.png"), s),
	tiny = love.graphics.newImageFont(love.graphics.newImage("fonts/tiny.png"), " abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789")

}

return fonts