manager = require('guimanager')

gui = 
{
    x = 0,
    y = 0,
    width = 100,
    height = 100,
    bgColor = {100,100,100},
		fgColor = {255,255,255},
    borderColor = {200,200,200},
    titleBarHeight = 20,
}

function gui:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    o.visible = true
    o.controls = {}
    manager:add(o)
    return o
end

function gui:mouseLeave()

end

function gui:mouseEnter()
    -- body
end

function gui:mouseUp()

end

function gui:keyDown(key)
	return false
end

function gui:keyUp(key)

end

function gui:mouseDown(x,y,mb)
    if y < self.titleBarHeight then
        self.dragging = true
        manager.dragging = self
        self.offset = {x,y}
    end
end

function gui:clampToScreen()
    local w = love.graphics.getWidth()
    local h = love.graphics.getHeight()
    self.x = clamp(self.x,0,w - self.width)
    self.y = clamp(self.y,0,h - self.height)
end

function gui:getControl(x,y)
    for i,v in ipairs(self.controls) do
        if v.x < x and x < v.x + v.width and v.y < y and y < v.y + v.height then
            if v.getControl then 
							return v:getControl(x - v.x, y - v.y) or v
						else
							return v
						end
        end
    end
end

function gui:update( dt )
    if self.dragging then
        local x,y = love.mouse.getPosition()
        self.x = x - self.offset[1]
        self.y = y - self.offset[2]
    end
    self:clampToScreen()
    for i,v in ipairs(self.controls or {}) do
        v:update(dt)
    end
end

function gui:show()
    self.visible = true
end

function gui:hide()
    self.visible = false
end

function gui:addControl(c)
    table.insert(self.controls, c)
end

function gui:absolutePos()
	return self.x, self.y
end

function gui.__tostring()
	return "GUI"
end

function gui:draw() 
    if not self.visible then return end
    local lg = love.graphics
    if self.background then
        lg.setScissor(self.x,self.y,self.width,self.height)
        lg.draw(self.background, self.x,self.y)
        lg.setScissor()
    else
        lg.setColor(self.bgColor[1],self.bgColor[2],self.bgColor[3])
        lg.rectangle("fill", self.x,self.y,self.width,self.height)
        lg.setColor(self.borderColor[1],self.borderColor[2],self.borderColor[3])
        lg.rectangle("line", self.x,self.y,self.width,self.height)
        lg.rectangle("fill", self.x,self.y,self.width,self.titleBarHeight)
				if self.text then
					lg.setColor(self.fgColor[1],self.fgColor[2],self.fgColor[3])
					lg.print(self.text, self.x + 4, self.y + 2)
				end
    end
    for i,v in ipairs(self.controls or {}) do
        v:draw(self.x, self.y)
    end
end

-- gui control

gui.control = 
{
    x = 0,
    y = 0,
    width = 30,
    height = 10,
    bgColor = {128,128,128,255},
    fgColor = {255,255,255,255},
    hlColor = {200,255,255,255},
    font = love.graphics.newFont(14),
    text = ""
}

function gui.control:new(o)    
    local nullFunc = function() end
    o = o or {}
    o.update = nullFunc
    o.draw = nullFunc
    o.mouseOver = nullFunc
    o.mouseEnter = nullFunc
    o.mouseLeave = nullFunc
    o.mouseDown = nullFunc
    o.mouseUp = nullFunc
    o.keyDown = nullFunc
		o.type = "control"
		o.visible = true
    setmetatable(o, { __index = self})
    return o
end

function gui.control.__tostring()
	return self.type .. " - " .. (self.name or "")
end

function gui.control:parentTo(parent)
    parent:addControl(self)
    self.parent = parent
end

function gui.control:focus()
    manager:setFocus(self)
end

function gui.control:isFocussed()
    return manager.focussedControl == self
end

function gui.control:absolutePos()
    local x,y = self.x, self.y
    local p = self.parent
		local xx,yy = p:absolutePos()
		x,y = xx + x, yy +y
    return x,y
end

-- gui button

gui.button = gui.control:new()
gui.button.type = "button"
--setmetatable(gui.button, { __index = gui.control} )

function gui.button:new(o, parent)
    o = o or {}
    setmetatable(o, { __index = self })
    o:parentTo(parent)
    return o
end

function gui.button:mouseEnter()
    self.isMouseOver = true
end

function gui.button:mouseLeave()
    self.isMouseOver = false
    self.isPressed = false
end

function gui.button:mouseDown(x,y,mb)
    if mb == "l" then
        self.isPressed = true
    end
end

function gui.button:mouseUp(x,y,mb)
    if mb == "l" and self.isPressed then
        self:onClick()
        self.isPressed = false
    end
end

function gui.button:onClick( ... )
    -- body
end

function gui.button:draw(x,y)
    x,y = self.x + x, self.y + y
    local lg = love.graphics
    lg.setColor(self.bgColor[1],self.bgColor[2],self.bgColor[3],self.bgColor[4])
    lg.rectangle("fill",x,y,self.width, self.height)
    local low = {75,75,75,255}
    local high = {255,255,255,255}
    
    if self.isPressed then
        lg.setColor(unpack(low))
    else
        lg.setColor(unpack(high))
    end
    lg.line(x,y + self.height,x, y, x + self.width, y)
    if self.isPressed then
        lg.setColor(unpack(high))
    else
        lg.setColor(unpack(low))
    end
    lg.line(x,y + self.height,x + self.width, y + self.height, x + self.width, y)
    lg.setFont(self.font)
    local yt = y + self.height / 2 - self.font:getHeight() / 2
    lg.printf(self.text, x, yt, self.width, "center")
end

gui.label = gui.control:new()
gui.label.type = "label"

function gui.label:new( o,parent )
    o = o or {}
    setmetatable(o, { __index = self })
    o:parentTo(parent)
    o.alignment = o.alignment or "left"
    return o
end

function gui.label:draw(x,y)
    x,y = self.x + x, self.y + y
    love.graphics.setScissor(x,y,self.width,self.height)
    love.graphics.printf(self.text, x, y, self.width, self.alignment)
    love.graphics.setScissor()
end

-- gui textbox

gui.textbox = gui.control:new()
gui.textbox.type = "textbox"

function gui.textbox:new(o, parent)
    o = o or {}
    setmetatable(o, { __index = self })
    o:parentTo(parent)
    return o
end

function gui.textbox:keyDown(key)
    if key:len() == 1 then
        if love.keyboard.isDown("capslock") then
            key = key:upper()
        end
        self.text = self.text .. key
    elseif key == "backspace" and self.text:len() > 0 then
        self.text = self.text:sub(1, self.text:len() - 1)
    end
end

function gui.textbox:draw(x,y)
    x,y = x + self.x, y + self.y
    local lg = love.graphics
    lg.setColor(unpack(self.bgColor))
    lg.rectangle("fill", x, y, self.width, self.height)
    if self:isFocussed() then
        lg.setColor(unpack(self.hlColor))
    else
        lg.setColor(unpack(self.fgColor))
    end
    lg.rectangle("line", x, y, self.width, self.height)
    lg.setScissor(x,y,self.width, self.height)
    lg.setColor(unpack(self.fgColor))
    lg.print(self.text, x + 2, y + 2)
    if self:isFocussed() then
        self.caret = math.floor(love.timer.getTime() * 2) % 2 < 1
        
        if self.caret then
            local textWidth = self.font:getWidth(self.text)
            local textHeight = self.font:getHeight()
            lg.line(x + 3 + textWidth, y + 4, x + 3 + textWidth, y + 2 + textHeight - 2)
        end
    end
    lg.setScissor()
end

-- gui imagebox

gui.imagebox = gui.control:new()
gui.imagebox.type = "imagebox"

function gui.imagebox:new(o, parent)
    o = o or {}
    setmetatable(o, { __index = self })
    o:parentTo(parent)
    return o
end

function gui.imagebox:draw()
    if not self.image then return end
    local lg = love.graphics
    local x,y = self:absolutePos()
    if self.clipped then
        lg.setScissor(x,y,self.width, self.height)
    end
    lg.draw(self.image,x,y)
    lg.setScissor()
end

-- gui layout

gui.layout = gui.control:new()
gui.layout.type = "layout"

function gui.layout:new(o, parent)
	o = o or {}
	setmetatable(o, { __index = self })
  o:parentTo(parent)
	o.direction = o.direction or "vertical"
	o.drawX = o.x
	o.drawY = o.y
	o.margin = 5
	o.spacing = 5
	o.controls = {}
  return o
end

function gui.layout.__tostring()
	return "layout"
end

function gui.layout:addControl(con)
	table.insert(self.controls, con)
end

--function gui.layout:absolutePos()
--local xx,yy = self.parent:absolutePos()
	--return xx + self.drawX, yy + self.drawY
--end

function gui.layout:getControl(x,y)
	for g,v in pairs(self.positions or {}) do
		if v[1] < x and x < v[1] + v[3] and v[2] < y and y < v[2] + v[4] then
			if g.getControl then 
				return g:getControl(x - v[1], y - v[2]) or g
			else
				return g
			end
		end
	end
end

function gui.layout:draw(x,y)
	if not self.visible then return end
	self.drawX = x + self.x + self.margin
	self.drawY = y + self.y + self.margin
	if self.text and self.text ~= "" and self.direction == "vertical" then
		love.graphics.setColor(self.fgColor[1],self.fgColor[2],self.fgColor[3])
		love.graphics.print(self.Text, self.x + 3, self.y + 3)
		self.drawY = self.drawY + 15
	end
	self.positions = {}
	self.maxHeight = 0
	self.maxWidth = 0
	local drawnOne = false
	for i,v in ipairs(self.controls or {}) do
		if drawnOne and v.visible then
			if self.direction == "vertical" then
				self.drawY = self.drawY + self.spacing
			else
				self.drawX = self.drawX + self.spacing
			end
		end
		v:draw(self.drawX, self.drawY)
		drawnOne = true
		if v.visible then
			self.positions[v] = {self.drawX - x - self.x, self.drawY - y - self.y, v.width, v.height}
			if self.direction == "vertical" then
				self.drawY = self.drawY + v.height
				self.maxWidth = math.max(self.maxWidth, v.width)
			else
				self.drawX = self.drawX + v.width
				self.maxHeight = math.max(self.maxHeight, v.height)
			end
		end
	end
	if self.direction == "vertical" then
		self.height = self.drawY + self.margin - y - self.y
		self.width = self.maxWidth + self.margin * 2
	else
		self.width = self.drawX + self.margin - x - self.x
		self.height = self.maxHeight + self.margin * 2
	end
	love.graphics.setColor(unpack(self.fgColor))
	love.graphics.rectangle("line",self.x + x, self.y + y, self.width, self.height)
end

return gui