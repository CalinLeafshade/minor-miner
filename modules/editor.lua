--EditorModule

Editor = require('module'):new("editor")
Editor.Priority = -500
function Editor:Init()
    self.Status = ""
    self.Mode = "select"
    self.DrawMode = "path"
    self.Verts = {}
    self.PlatformTypes = {"allblock", "instakill", "downonly", "save", "breakable", "trigger", "water"}
    self.CurrentType = 1
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
        --love.graphics.setLineWidth(Scale)
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
                local mx,my = love.mouse.getPosition()
                local mx, my = toRoom(mx,my, true)
                local v = {self.TopLeft[1], self.TopLeft[2], self.TopLeft[1], my, mx, my, mx, self.TopLeft[2]}
                self.Verts = v
            end
        end
        
        if #self.Verts > 0 then
            love.graphics.setColor(128,128,128)
            local v = deepcopy(self.Verts)
            for i = 1, #v do
                local x,y = toScreen(v[i],v[i])
                v[i] = i % 2 == 1 and x or y
            end

            if #v == 2 then 
                love.graphics.point(unpack(v)) 
            elseif #v == 4 then 
                love.graphics.line(unpack(v)) 
            else
                love.graphics.polygon("line", unpack(v))
            end

        end
        
    end
end

function Editor:Update(focus)
    log("EditorType", "Current type: " .. self.PlatformTypes[self.CurrentType])
    log("EditorDrawMode", "Current drawmode: " .. self.DrawMode)
    log("EditorMode", "Current mode: " .. self.Mode)
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

function Editor:NextPlatformType()
    self.CurrentType = self.CurrentType + 1
    if self.CurrentType > #self.PlatformTypes then
        self.CurrentType = 1
    end
end

function Editor:PrevPlatformType()
    self.CurrentType = self.CurrentType - 1
    if self.CurrentType < 1 then
        self.CurrentType = #self.PlatformTypes
    end
end

function Editor:OnKeypress(key)
    if key == "tab" then
        ModCon:Defocus()
    elseif key == "return" then
        if self.Mode == "new" then self:Finalise() end
    elseif key == "[" then
        self:PrevPlatformType()
    elseif key == "]" then
        self:NextPlatformType()
    elseif key == "m" then
        self.DrawMode = self.DrawMode == "path" and "box" or "path"
    elseif key == "x" then
        --self:LockX()
    elseif key == "y" then
        --self:LockY()
    elseif key == "n" then
        self:NewCollider()
    elseif key == "delete" then
        self:DeleteCollider()
    elseif key == "left" then
        Game:LockViewport(Game.Viewport.x - 5, Game.Viewport.y)
    elseif key == "right" then
        Game:LockViewport(Game.Viewport.x + 5, Game.Viewport.y)
    elseif key == "up" then
        Game:LockViewport(Game.Viewport.x, Game.Viewport.y - 5)
    elseif key == "down" then
        Game:LockViewport(Game.Viewport.x, Game.Viewport.y + 5)
    elseif key == "u" then
        Game:UnlockViewport()
    end
    Game:ClampViewport()
end

function Editor:SelectAt(mx,my)
    local shapes = Game.CWorld:shapesAt(toRoom(mx,my))
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
        if button == "l" then
            self:SelectAt(mx,my)
        elseif button == 2 then
            self.Selected = nil
        end    
    elseif self.Mode == "new" then
        if button == "l" then
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
        elseif button == "r" then
            self:Undo()
        end
    end
    
end

function Editor:GotFocus()
    self.Mode = "select"
    self.Verts = {}
end

function Editor:LostFocus()
    self.Mode = "select"
    self.Verts = {}
    Game:UnlockViewport()
end

function Editor:Finalise()
    if self.DrawMode == "path" then
        if #self.Verts < 6 then
            log("You need at least 3 non-colinear vertices")
        else
            Room.Current.Platforms[#Room.Current.Platforms + 1] = Platform:new(self.PlatformTypes[self.CurrentType], unpack(self.Verts))          
        end
    elseif self.DrawMode == "box" then
        if not self.BottomRight or not self.TopLeft then
            log("Nope please")
        else
            local v = {self.TopLeft[1], self.TopLeft[2], self.TopLeft[1], self.BottomRight[2], self.BottomRight[1], self.BottomRight[2], self.BottomRight[1], self.TopLeft[2]}
            Room.Current.Platforms[#Room.Current.Platforms + 1] = Platform:new(self.PlatformTypes[self.CurrentType], unpack(v))           
            self.TopLeft = nil
            self.TopRight = nil
        end
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
        local p = Room.Current.Platforms
        for i,v in ipairs(p) do
            if v == self.Selected then
                Game.CWorld:remove(p.Collider)
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
