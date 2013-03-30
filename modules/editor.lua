--EditorModule

Editor = require('module'):new("editor")
Editor.Priority = -500
function Editor:Init()
    self.Status = ""
    self.Mode = "select"
    self.DrawMode = "path"
    self.Verts = {}
    self.Colors = {}
    self.Colors["allblock"] = {128,128,0}
    self.Colors["instakill"] = {255,0,0}
    self.Colors["downonly"] = {128,0,128}
    self.Colors["selected"] = {255,255,255}
    self.Colors["save"] = {255,255,0}
    self.Colors["breakable"] = {255,0,255}
    self.Colors["trigger"] = {0,255,0}
    self.Colors["water"] = {0,0,255}
end

function Editor:Draw(focus)
    
    if focus then
            
        --Draw platforms
        for i,v in ipairs(Room.Current.Platforms) do
            local c = self.Selected == v and self.Colors["selected"] or self.Colors[v.Mode]
            love.graphics.setColor(unpack(c))
            v:Draw(Scale)
            local x,y = toScreen(v.Collider:center())
            love.graphics.setColor(255,255,255)
            love.graphics.print(tostring(i), x,y)
        end
        
        if self.DrawMode == "box" then -- build verts for drawing
            if self.TopLeft then
                local mx, my = toRoom(love.mouse.getPosition(), true)
                local v = {self.TopLeft[1], self.TopLeft[2], self.TopLeft[1], my, mx, my, mx, self.TopLeft[2]}
                self.Verts = v
            end
        end
        
        if #self.Verts > 3 then
            love.graphics.setColor(128,128,128)
            local v = deepcopy(self.Verts)
            for i = 1, #v do
                local x,y = toScreen(v[i],v[i])
                v[i] = i % 2 == 1 and x or y
            end
            love.graphics.polygon("line", unpack(v))
        elseif #self.Verts > 1 then
            love.graphics.setColor(128,128,128)
            love.graphics.point(v[1],v[2])
        end
        
    end
end

function Editor:Update(focus)
    self.Status = "No Selection"
    if self.Selected then
            self.Status = "Selected collider:[" .. self.Selected.Mode
    end
    
end

function Editor:Unlock()  
    self.Locked = nil
end

function Editor:LockY()
    if #self.Verts < 2 then return end
    if self.Locked == "y" then self:Unlock() return end
    self.Locked = "y"
    ags.Mouse.SetBounds(0,self.Verts[#self.Verts],320,self.Verts[#self.Verts])
end

function Editor:LockX()
    if #self.Verts < 2 then return end
    if self.Locked == "x" then self:Unlock() return end
    self.Locked = "x"
    ags.Mouse.SetBounds(self.Verts[#self.Verts - 1],0,self.Verts[#self.Verts - 1], 200)
end

function Editor:OnKeypress(key)
    if key == "tab" then
        ModCon:Defocus()
    --elseif key == ags.eKeyReturn then
--    if self.Mode == "new" then self:Finalise() end
--  elseif key == ags.eKeyX then
--    self:LockX()
--  elseif key == ags.eKeyY then
--    self:LockY()
--  elseif key == ags.eKeyN then
--      self:NewCollider()
--  elseif key == ags.eKeyDelete then
--      self:DeleteCollider()
--  elseif key == ags.eKeyLeftArrow then
--      ags.SetViewport(ags.GetViewportX() - 5, ags.GetViewportY())
--  elseif key == ags.eKeyRightArrow then
--      ags.SetViewport(ags.GetViewportX() + 5, ags.GetViewportY())
--  elseif key == ags.eKeyUpArrow then
--      ags.SetViewport(ags.GetViewportX(), ags.GetViewportY() - 5)
--  elseif key == ags.eKeyDownArrow then
--      ags.SetViewport(ags.GetViewportX(), ags.GetViewportY() + 5)
--  elseif key == ags.eKeyU then
--      ags.ReleaseViewport()
    end
    
end

function Editor:SelectAt(mx,my)
    local shapes = CWorld:shapesAt(toRoom(mx,my))
    if #shapes > 0 then 
        local o = shapes[1].Object
        self.Selected = o
    else
        self.Selected = nil
    end
end

function Editor:AddVert(x,y)
    self.Verts[#self.Verts + 1] = x
    self.Verts[#self.Verts + 1] = y
end


function Editor:OnClick(button,mx,my)
    if self.Mode == "select" then
        if button == 1 then
            self:SelectAt(mx,my)
        elseif button == 2 then
            self.Selected = nil
        end    
    elseif self.Mode == "new" then
        if button == 1 then
            if self.DrawMode == "path" then     
                self:AddVert(toRoom(mx,my))
            elseif self.DrawMode == "box" then
                if self.TopLeft then
                    self.BottomRight = {toRoom(mx,my)}
                    self:Finalise()
                else 
                    self.TopLeft = {toRoom(mx,my)}
                end         
            end
        elseif button == 2 then
            self:Undo()
        end
    end
    
end

function Editor:GotFocus()
    log(false,"got focus")
end

function Editor:LostFocus()
    self.Mode = "select"
    self.Verts = {}
    --self:Unlock()
end

function Editor:Finalise()
    if self.DrawMode == "path" then
        if #self.Verts < 6 then
            ags.Display("You need at least 3 non-colinear vertices")
        else
            CurrentRoom().Platforms[#CurrentRoom().Platforms + 1] = Platform:new(self.List.Items[self.List.SelectedIndex], unpack(self.Verts))          
        end
    elseif self.DrawMode == "box" then
        if not self.BottomRight or not self.TopLeft then
            ags.Display("Nope please")
        end
        local v = {self.TopLeft[1], self.TopLeft[2], self.TopLeft[1], self.BottomRight[2], self.BottomRight[1], self.BottomRight[2], self.BottomRight[1], self.TopLeft[2]}
        CurrentRoom().Platforms[#CurrentRoom().Platforms + 1] = Platform:new(self.List.Items[self.List.SelectedIndex], unpack(v))           
        self.TopLeft = nil
        self.TopRight = nil
    end
    self.Verts = {}
    self:Unlock()
    self.Mode = "select"
end

function Editor:NewCollider()
    self.Verts = {}
    self.Mode = "new"
end

function Editor:DeleteCollider()
    if self.Selected then
        local p = CurrentRoom().Platforms
        for i,v in ipairs(p) do
            if v == self.Selected then
                CWorld:remove(p.Collider)
                table.remove(p,i)
            end
        end
    end
end

function Editor:Undo()
    if self.DrawMode == "path" then
        if #self.Verts > 1 then
            table.remove(self.Verts)
            table.remove(self.Verts)
        end
    elseif self.DrawMode == "box" then
        self.TopLeft = nil
        self.BottomRight = nil
    end

end

function Editor:ChangeDrawMode()
    self.DrawMode = self.DrawMode == "box" and "path" or "box"
    log("eddrawmode", "Draw mode changed to " .. self.DrawMode)
    self.Verts = {}
end

return Editor
