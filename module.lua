local Module = {}

function Module:new(name)
  o = {}
  setmetatable(o, self)
  self.__index = self
  o.Name = name
  o.IsModule = true
  o.Visible = false
  o.Priority = 0
  return o
end

function Module:Hide()
  self.Visible = false
end

function Module:Show()
  self.Visible = true
end

function Module:LateUpdate(focussed)
  
end

function Module:Update(focussed)
  
end

function Module:Draw(focussed)
  
end

function Module:LateDraw(focussed)
  
end

function Module:GotFocus()
  
end

function Module:LostFocus()
  
end


function Module:OnKeypress(keycode)
  
end

function Module:OnClick(button, mx, my)
  
end

return Module