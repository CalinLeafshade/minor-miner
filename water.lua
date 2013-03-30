local Water = {}



function Water:Init()
	self.shader = love.graphics.newPixelEffect [[
          extern number t;
          extern Image dudv;
          vec4 effect(vec4 color, Image img, vec2 texture_coords, vec2 pixel_coords){
			//vec2 tc = vec2(gl_FragCoord.x/320 - sin(gl_FragCoord.x/(320/16)*16)/512 + sin(t)/732, gl_FragCoord.y/200 - sin(gl_FragCoord.y/(320/16)*16)/512 + sin(t * 2)/920); 
			vec4 dist = Texel(dudv,vec2(texture_coords.x + (t/64), texture_coords.y));
			dist = dist * 2 - 1.0f;
			vec2 tc = vec2(texture_coords.x + (dist.r / 90), texture_coords.y + (dist.g / 90));
            return Texel(img, tc);
          }
    ]]
	self.Rects = {}
	self.Canvas = love.graphics.newCanvas(320,200)
	self.BubbleTexture = love.graphics.newImage("gfx/bubble.png")
	self.Bubbles = {}
	self.LastBubble = 0
	self.Timer = 0
	self.dudv = love.graphics.newImage("gfx/waterdudv.png")
	self.dudv:setWrap("repeat", "clamp")
	
end

function Water:SpawnBubble(rect,x,y)
	table.insert(self.Bubbles, {Life = 0,Rect = rect, X = x, Y = y, Sprite = math.random(1,3)})
end

function Water:Update(dt)
	self.LastBubble = self.LastBubble - dt
	if Game.Player.InWater and self.LastBubble <= 0 then
		local mx, my = Game.Player.Position.x, Game.Player.Position.y - 9
		mx = Game.Player:Direction() and mx - 5 or mx
		self.LastBubble = math.random(0.5,3)
		self:SpawnBubble({Game.Player.Water:bbox()}, mx, my)
	end
	for i,v in ipairs(self.Bubbles) do
		v.Y = v.Y - dt * 8
		v.Life = v.Life + dt
		if v.Y < v.Rect[2] then
			table.remove(self.Bubbles,i)
		end
	end
end

function Water:ClearRects()
	self.Rects = {}
end

function Water:NewRoom()
	self:ClearRects()
	self.Bubbles = {}
	for i,v in ipairs(Room.Current.Platforms) do
		if v.Mode == "water" then
			self:AddWaterRect(v.Collider:bbox())
		end
	end
end

function Water:AddWaterRect(x,y,x2,y2)
	table.insert(self.Rects, {x,y,x2 - x,y2 - y})
end

function Water:PreDraw()
	self.oldCanvas = love.graphics.getCanvas()
	love.graphics.setCanvas(self.Canvas)
end

function Water:Draw()
	
	self.shader:send('t', love.timer.getTime())
	self.shader:send('dudv', self.dudv)
	love.graphics.setBlendMode("additive")
	for _,v in ipairs(self.Rects) do
		love.graphics.setColor(121,153,171,50)
		--love.graphics.rectangle("fill",v[1] - Game.Viewport.x, v[2] - Game.Viewport.y, v[3],v[4])
		love.graphics.line(v[1]  - Game.Viewport.x,v[2] - Game.Viewport.y,v[1] + v[3] - Game.Viewport.x, v[2] - Game.Viewport.y)
	end
	
	
	log("time", love.timer.getTime())
	for _,v in ipairs(self.Bubbles) do
		love.graphics.drawq(self.BubbleTexture, love.graphics.newQuad((v.Sprite - 1) * 8, 0, 8, 8,24,8), v.X + math.sin(love.timer.getTime() + v.Life) - Game.Viewport.x, v.Y - Game.Viewport.y)
	end
	love.graphics.setBlendMode("alpha")
	love.graphics.setColor(255,255,255)
	love.graphics.setCanvas(self.oldCanvas)
	love.graphics.draw(self.Canvas,0,0)

	
	love.graphics.setPixelEffect(self.shader)
	for _,v in ipairs(self.Rects) do
		love.graphics.setScissor(v[1] - Game.Viewport.x, v[2] - Game.Viewport.y, v[3],v[4])
		love.graphics.draw(self.Canvas,0,0)
	end
	
	love.graphics.setPixelEffect()
	love.graphics.setScissor()
end

return Water