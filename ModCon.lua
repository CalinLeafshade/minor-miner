-- Module Controller

local ModCon = 
{
    Modules = {},
    ByName = {}
}

function ModCon:Add(mod)
    assert(mod.IsModule, "mod Must be a module")
    self.ByName[mod.Name] = mod
    self.Modules[#self.Modules + 1] = mod
    table.sort(self.Modules, function(a,b)
        return a.Priority > b.Priority 
    end)
end

function ModCon:Defocus()
    ModCon:Focus(self.LastActive)
end

function ModCon:Focus(mod)
    assert(mod and mod.IsModule, "mod Must be a module and not nil")
    if self.Active then self.Active:LostFocus() end
    self.LastActive = self.Active
    self.Active = mod
    self.Active:GotFocus()
end

function ModCon:LoadModules()
    local files = love.filesystem.enumerate("modules")
    for _,v in ipairs(files) do
        self:Add(love.filesystem.load("modules/" .. v)())
    end
end

function ModCon:Init()
    self:LoadModules()
    for i,v in ipairs(self.Modules or {}) do
        v:Init()
    end
end

function ModCon:Update(dt)
    for i,v in ipairs(self.Modules or {}) do
        v:Update(dt, v == self.Active)
    end
end

function ModCon:LateUpdate()
    for i,v in ipairs(self.Modules or {}) do
        v:LateUpdate(v == self.Active)
    end
end

function ModCon:LateDraw()
    for i,v in ipairs(self.Modules or {}) do
        v:LateDraw(v == self.Active)
    end
end

function ModCon:Draw()
    for i,v in ipairs(self.Modules or {}) do
        v:Draw(v == self.Active)
    end
end

function ModCon:OnKeypress(keycode)
    if self.Active then
        self.Active:OnKeypress(keycode)
    end 
end

function ModCon:OnClick(x,y,button)
    if self.Active then
        self.Active:OnClick(button, x,y)
    end
end

return ModCon
