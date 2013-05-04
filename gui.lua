manager = require('guimanager')

gui = 
{
    x = 0,
    y = 0,
    width = 100,
    height = 100,
    bgColor = Color.DarkGrey,
	fgColor = Color.White,
    borderColor = Color.LightGrey,
    titleBarHeight = 20,
	font = love.graphics.newFont(12)
}

function gui:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    o.visible = o.visible == null and true or false
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
        lg.setColor(self.bgColor:unpack())
        lg.rectangle("fill", self.x,self.y,self.width,self.height)
        lg.setColor(self.borderColor:unpack())
        lg.rectangle("line", self.x,self.y,self.width,self.height)
        lg.rectangle("fill", self.x,self.y,self.width,self.titleBarHeight)
				if self.text then
					lg.setColor(self.fgColor:unpack())
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
    bgColor = Color.DarkGrey,
    fgColor = Color.White,
    hlColor = Color.Blue,
    font = love.graphics.newFont(10),
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
    lg.setColor(self.bgColor:unpack())
    lg.rectangle("fill",x,y,self.width, self.height)
    local low = {self.bgColor.r * 0.5, self.bgColor.g  * 0.5, self.bgColor.b * 0.5,255}
	local high = 
	{
		clamp(self.bgColor.r * 1.5,0,255), 
		clamp(self.bgColor.g * 1.5,0,255), 
		clamp(self.bgColor.b * 1.5,0,255),
		255
	}
    
    if self.isPressed or self.toggled then
		low,high = high,low
    end
    lg.setColor(unpack(high))
    lg.line(x,y + self.height,x, y, x + self.width, y)
    lg.setColor(unpack(low))
    lg.line(x,y + self.height,x + self.width, y + self.height, x + self.width, y)
	lg.setColor(self.fgColor:unpack())
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
	o.clip = o.clip or false
    return o
end

function gui.label:draw(x,y)
    x,y = self.x + x, self.y + y
	love.graphics.setColor(self.fgColor:unpack())
    if self.clip then 
		love.graphics.setScissor(x,y,self.width,self.height)
		love.graphics.printf(self.text, x, y, self.width + 1, self.alignment)
		love.graphics.setScissor()
	else
		local lines = self.text:split("\n")
		local w = 0
		for _,v in ipairs(lines) do
			local lw = self.font:getWidth(v)
			w = w > lw and w or lw
		end
		self.width = w
		local _, linecount = string.gsub(self.text, "\n", "")
		linecount = linecount + 1
		self.height = self.font:getHeight() * linecount
		love.graphics.printf(self.text, x, y, self.width + 1, self.alignment)
	end
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
	local w,h = self.width, self.height
	
    local lg = love.graphics
	
	if self.label then
		lg.setColor(self.fgColor:unpack())
		lg.setFont(self.font)
		lg.print(self.label,x,y + 3)
		local ext = self.font:getWidth(self.label) + 5
		x = x + ext
		w = w - ext
	end
	
	
	
    lg.setColor(self.bgColor:unpack())
    lg.rectangle("fill", x, y, w,h)
    if self:isFocussed() then
        lg.setColor(self.hlColor:unpack())
    else
        lg.setColor(self.fgColor:unpack())
    end
    lg.rectangle("line", x, y, w,h)
    lg.setScissor(x,y,w,h)
    lg.setColor(self.fgColor:unpack())
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
	o.margin = o.margin or 5
	o.spacing = o.spacing or 5
	o.border = o.border == null and true or o.border
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

function gui.layout:update(dt)
	for i,v in ipairs(self.controls or {}) do
		v:update(dt)
	end
end

function gui.layout:draw(x,y)
	if not self.visible then return end
	self.drawX = x + self.x + self.margin
	self.drawY = y + self.y + self.margin
	if self.text and self.text ~= "" and self.direction == "vertical" then
		love.graphics.setColor(self.fgColor:unpack())
		love.graphics.print(self.text, self.drawX, self.drawY)
		self.drawY = self.drawY + self.font:getHeight() + self.spacing
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
	if self.border then
		love.graphics.setColor(self.fgColor:unpack())
		love.graphics.rectangle("line",self.x + x, self.y + y, self.width, self.height)
	end
end

gui.hline = gui.control:new()
gui.hline.type = "hline"

function gui.hline:new(o, parent)
	o = o or {}
	o.x = o.x or 0
	o.y = o.y or 0
	o.height = 0
	setmetatable(o, { __index = self })
    o:parentTo(parent)

	
end

function gui.hline:draw(x,y)
	love.graphics.setColor(self.fgColor:unpack())
	love.graphics.line(x,y,x + self.parent.width - 10, y)
end

gui.selector = {}

function gui.selector:new(o,parent)
	o.choices = o.choices or {}
	local lo = gui.layout:new({direction = "horizontal"}, parent)
	lo.label = gui.label:new({text = o.text, y = 2, x =0}, lo)
	lo.left = gui.button:new({text = "<", x=0,y=0, width = 15, height = 15}, lo)
	lo.choice = gui.label:new({alignment = "center", text = o.choices[1], clip = true,width = 65, x=0,y=2,height = 15}, lo)
	lo.right = gui.button:new({text = ">", x=0,y=0, width = 15, height = 15}, lo)
	lo.selectedIndex = 1
	lo.left.onClick = function()
		lo.selectedIndex = loop(lo.selectedIndex - 1,1,#lo.choices)
		lo.choice.text = lo.choices[lo.selectedIndex]
		if lo.onChange and type(lo.onChange == "function") then
			lo.onChange(lo)
		end
	end
	lo.right.onClick = function()
		lo.selectedIndex = loop(lo.selectedIndex + 1,1,#lo.choices)
		lo.choice.text = lo.choices[lo.selectedIndex]
		if lo.onChange and type(lo.onChange == "function") then
			lo.onChange(lo)
		end
	end
	lo.update = function(dt)
		gui.layout.update(self,dt)
		lo.choice.text = lo.choices[lo.selectedIndex]
	end
	
	lo.choices = o.choices
	return lo
end

return gui