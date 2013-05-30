--Fonts

local s = ""
for i=32,127 do
	s = s .. string.char(i)
end

local fonts = 
{
	betterPixels = love.graphics.newImageFont("fonts/betterpixels.png", s)

}

return fonts