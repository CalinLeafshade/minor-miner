local Water = {}



function Water:Init()
    self.shader = love.graphics.newPixelEffect [[
        extern number t;
        extern Image dudv;
        extern vec2 camera;
        vec4 effect(vec4 color, Image img, vec2 texture_coords, vec2 pixel_coords) {
            vec4 dist = Texel(dudv,vec2(texture_coords.x + (t/64), texture_coords.y) + camera * 2);
            dist = dist * 2 - 1.0f;
            vec2 tc = vec2(texture_coords.x + (dist.r / 90), texture_coords.y + (dist.g / 90));
            return Texel(img, tc) - 0.05;
        }
    ]]
    self.Rects = {}
    self.Canvas = love.graphics.newCanvas(320,180)
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
    love.graphics.setColor(0,0,0)
    love.graphics.rectangle("fill",0,0,320,180)
    love.graphics.setColor(255,255,255)
end

function Water:Draw()
    
    self.shader:send('t', love.timer.getTime())
    self.shader:send('dudv', self.dudv)
    self.shader:send('camera', {Game.Viewport.x / Room.Current:Width(), Game.Viewport.y / Room.Current:Height()})

    local lg = love.graphics
		lg.setLineStyle("smooth")
    lg.setBlendMode("additive")
    for _,v in ipairs(self.Rects) do
        lg.setColor(121,153,171,50)
        --lg.rectangle("fill",v[1] - Game.Viewport.x, v[2] - Game.Viewport.y, v[3],v[4])
        lg.line(v[1]  - Game.Viewport.x,v[2] - Game.Viewport.y,v[1] + v[3] - Game.Viewport.x, v[2] - Game.Viewport.y)
    end
    
    
    log("time", love.timer.getTime())
    for _,v in ipairs(self.Bubbles) do
        lg.drawq(self.BubbleTexture, lg.newQuad((v.Sprite - 1) * 8, 0, 8, 8,24,8), v.X + math.sin(love.timer.getTime() + v.Life) - Game.Viewport.x, v.Y - Game.Viewport.y)
    end
    lg.setBlendMode("alpha")
    lg.setColor(255,255,255)
    lg.setCanvas(self.oldCanvas)
    lg.draw(self.Canvas,0,0)

    
    lg.setPixelEffect(self.shader)
    for _,v in ipairs(self.Rects) do
        lg.setScissor(v[1] - Game.Viewport.x, v[2] - Game.Viewport.y, v[3],v[4])
        lg.draw(self.Canvas,0,0)
    end
    
    lg.setPixelEffect()
    lg.setScissor()
end

return Water