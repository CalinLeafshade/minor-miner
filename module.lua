--- [Module description]
-- @class Table
local Module = {}

--- Creates a new Minor Miner module
-- @param name The name of the module
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

--- Hides the module
function Module:Hide()
    self.Visible = false
end

--- Shows the module
function Module:Show()
    self.Visible = true
end

--- Update function run after all other Updates
-- @param focussed if module is focussed or not
function Module:LateUpdate(focussed)
  
end

--- Update is run every update frame
-- @param focussed If the module is focussed or not
function Module:Update(focussed)

end

--- Draw the module
-- @param focussed If the module is focussed or not
function Module:Draw(focussed)

end

--- LateDraw is run after all Draw functions have return
-- @param focussed If the module is focussed or not
function Module:LateDraw(focussed)

end

--- Called when the module receives focus
function Module:GotFocus()

end

--- Called when the module loses focus
function Module:LostFocus()

end

--- Called when the module receives a keypress
-- This will only be called if the module has focus
-- @param keycode The key being pressed. A string like "x" or "tab"
function Module:OnKeypress(keycode)

end

--- Called when the module receives a mouse click
-- This will only be called if the module has focus
-- @param button The button clicked. An int starting at 0
-- @param mx     The mouse's x position relative to the window
-- @param my     The mouse's y position relative to the window
function Module:OnClick(button, mx, my)

end

return Module