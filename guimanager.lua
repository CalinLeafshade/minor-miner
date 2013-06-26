--GuiManager

GuiManager = 
{
		guis = {}
}

function GuiManager:add(gui)
    table.insert(self.guis, gui)
end

function GuiManager:guiAtXY(x,y)
    for i=1,#self.guis do
        local g = self.guis[i]
        if g.x < x and x < g.x + g.width and g.y < y and y < g.y + g.height then
            return g
        end
    end
end

function GuiManager:OnKeypress(key)
    if self.focussedControl then
       return self.focussedControl:keyDown(key)
    end
		return false
end

function GuiManager:OnMouseRelease(x,y,mb)
    if self.dragging then
        self.dragging.dragging = false
        self.dragging = nil
    end
    local g = self:guiAtXY(x,y)
    if g then
        local control = g:getControl(x - g.x, y - g.y)
        if control then
            control:mouseUp(x - g.x, y - g.y, mb)
        else
            g:mouseUp(x - g.x, y - g.y,mb)
        end
				return true
    end
		return false
end

function GuiManager:OnClick(x,y,mb)
    local g = self:guiAtXY(x,y)
    if g then
        local control = g:getControl(x - g.x, y - g.y)
        if control then
            control:mouseDown(x - g.x, y - g.y, mb)
            self:setFocus(control)
						log("mouseclick", "clicked " .. control.type)
        else
            g:mouseDown(x - g.x, y - g.y,mb)
            self:setFocus(g)
        end
				return true
    end
		return false
end

function GuiManager:setFocus(control)
    self.focussedControl = control
end


function GuiManager:Update(dt)
    table.sort(self.guis, function (a,b)
        return a.zOrder > b.zOrder
    end)
    for i,v in ipairs(self.guis) do
        v:update(dt)
    end
    local x,y = love.mouse.getPosition()
    local g = self:guiAtXY(x,y)
    if g then
        local control = g:getControl(x - g.x, y - g.y)
        if control then
            if self.lastOver ~= control then
                control:mouseEnter()
                if self.lastOver then self.lastOver:mouseLeave() end
                self.lastOver = control
            end
        elseif self.lastOver ~= g then
            g:mouseEnter()
            if self.lastOver then self.lastOver:mouseLeave() end
            self.lastOver = g
        end
    end
end

function GuiManager:Draw()
	love.graphics.setLineWidth(1)
    for i,v in ipairs(self.guis) do
        v:draw()
    end
end

return GuiManager

