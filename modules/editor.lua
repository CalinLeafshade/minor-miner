--EditorModule

Enemy = require('enemy')

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
    self.Colors["selected"] = {255,255,255,150}
    self.Colors["save"] = {255,255,0}
    self.Colors["breakable"] = {255,0,255}
    self.Colors["trigger"] = {0,255,0}
    self.Colors["water"] = {0,0,255}
end

function Editor:Draw(focus)
    
    if focus then
        love.graphics.setLineWidth(Config.Scale)
        --Draw platforms
        for i,v in ipairs(Room.Current.Platforms) do
            --local c = self.Selected == v and self.Colors["selected"] or self.Colors[v.Mode]
			local c = self.Colors[v.Mode]
            love.graphics.setColor(unpack(c))
            v:Draw(Config.Scale)
			if v == self.Selected then
				love.graphics.setColor(unpack(self.Colors['selected']))
				v:Draw(Config.Scale)
			end
            local x,y = toScreen(v.Collider:center())
            love.graphics.setColor(255,255,255)
            love.graphics.print(tostring(i), x,y)
        end
		
		--draw enemy colliders
		for i,p in pairs(Room.Current.SceneObjects) do
			if p.DebugDraw then
				p:DebugDraw(self.Selected == p)
			elseif p.Collider then
				if self.Selected == p then
					love.graphics.setColor(unpack(self.Colors['selected']))
				else
					love.graphics.setColor(255,0,0)
				end
				self:DrawPolygon(p.Collider._polygon)
			end
		end
        local mx,my = love.mouse.getPosition()
        if self.DrawMode == "box" then -- build verts for drawing
            if self.TopLeft then
                
                local mx, my = toRoom(mx,my, true)
                local v = {self.TopLeft[1], self.TopLeft[2], self.TopLeft[1], my, mx, my, mx, self.TopLeft[2]}
                self.Verts = v
            end
        end
        
		love.graphics.setPointSize(Config.Scale)
		mx,my = toScreen(toRoom(mx,my))
		
		love.graphics.point(mx + Config.Scale / 2, my + Config.Scale / 2)
		
        if #self.Verts > 0 then
            love.graphics.setColor(128,128,128)
            local v = deepcopy(self.Verts)
            for i = 1, #v do
                local x,y = toScreen(v[i],v[i])
                v[i] = i % 2 == 1 and x or y
				v[i] = v[i] + Config.Scale / 2
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

function Editor:DrawPolygon(p)
	local scale = Config.Scale
	local v = {p:unpack()}
	for i = 1, #v do
		if i % 2 == 1 then
			v[i] = v[i] - Game.Viewport.x
		else
			v[i] = v[i] - Game.Viewport.y
		end
		v[i] = v[i] * scale + 2
	end
	love.graphics.polygon("line", unpack(v))
end

function Editor:Update(focus)
	--pinspector.lblPlatformMode = gui.label:new({x=0,y=0,clip = false, text = "Current Mode:"}, pinspector.platformLayout)
	--pinspector.lblPlatformDrawMode = gui.label:new({x=0,y=0,clip = false, text = "Current Draw Mode:"}, pinspector.platformLayout)
	--pinspector.lblPlatformVerts = gui.label:new({x=0,y=0,clip = false, text = "Verts:"}, pinspector.platformLayout)
	
	if self.TopMode == "platform" then
		self.gui.lblPlatformMode.text = "Mode: " .. self.Mode
		self.gui.drawModeSelector.selectedIndex = self.DrawMode == "path" and 1 or 2
		if self.Mode == "select" and self.Selected then
			self.gui.typeSelector.selectedIndex = indexFromValue(self.PlatformTypes, self.Selected.Mode)
		elseif self.Mode == "new" then
			self.gui.typeSelector.selectedIndex = self.CurrentType
		end		
	else
		
		local function enemyCount()
			local c = 0
			for i,v in ipairs(Room.Current.SceneObjects) do
				if v.Type == "enemy" then
					c = c + 1
				end
			end
			return c
		end
		
		self.gui.lblEnemyCount.text = "Enemy count: " .. enemyCount()
	end
	
	if self.dragging then
		local mx,my = toRoom(love.mouse.getPosition())
		self.Selected.Collider:move(mx - self.lastmx, my - self.lastmy)
		self.lastmx, self.lastmy = mx,my
	end
	
	if self.Selected and self.TopMode == "enemy" then
		self.gui.enemySpawnLayout.visible = false
		self.gui.enemySelectLayout.visible = true
		self.gui.txtEnemyX.text,self.gui.txtEnemyY.text = self.Selected.Collider:center()
	else
		self.gui.enemySpawnLayout.visible = true
		self.gui.enemySelectLayout.visible = false
	end
    --log("EditorType", "Current type: " .. self.PlatformTypes[self.CurrentType])
    --log("EditorDrawMode", "Current drawmode: " .. self.DrawMode)
    --log("EditorMode", "Current mode: " .. self.Mode)
end

function Editor:Unlock()  
    self.Locked = nil
end

function Editor:SaveRoom()
	Room.Current:Save()
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

function Editor:InitGUI()
	self.gui = require('guis.pinspector')
	local e = {}
	for i,v in pairs(EnemyTypes or {}) do
		e[#e + 1] = v.Name
	end
	self.gui.spawnSelector.choices = e
	self.gui.spawnSelector.selectedIndex = 1
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

function Editor:NewSelected(s)
	self.gui.enemyParamsLayout:clear()
	if not s then return end
	if s.Parameters then
		for i,v in pairs(s.Parameters) do
			local txt = gui.textbox:new({x=0,y=0,label=i, width = 150, height = 20, text = tostring(v)}, self.gui.enemyParamsLayout)
			txt.type = type(v)
			txt.obj = s
			txt.lostFocus = function(self)
				if txt.type == "number" then
					local n = tonumber(self.text)
					if n then
						self.obj.Parameters[self.label] = n
					else
						self.text = self.obj.Parameters[self.label]
					end
				else
					self.text = self.obj.Parameters[self.label]
				end
			end
		end
	end
end

function Editor:SelectAt(mx,my, t)
    local shapes = Game.CWorld:shapesAt(toRoom(mx,my))
	local last = self.Selected
    if #shapes > 0 then 
		self.Selected = nil
        for i,v in ipairs(shapes) do
			if v.Object and v.Object.Type == t then
				self.Selected = v.Object
				break
			end
		end
    else
        self.Selected = nil
    end
	if last ~= self.Selected then
		self:NewSelected(self.Selected)
	end
end

function Editor:AddVert(x,y)
    self.Verts[#self.Verts + 1] = x
    self.Verts[#self.Verts + 1] = y
end


function Editor:OnClickPlatform(button,mx,my)
	 if self.Mode == "select" then
        if button == "l" then
            self:SelectAt(mx,my,"platform")
        elseif button == "r" then
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

function Editor:OnClickEnemy(button,mx,my)
	self:SelectAt(mx,my,"enemy")
	if self.Selected then
		self.dragging = true
		self.lastmx, self.lastmy = toRoom(love.mouse.getPosition())	
	end
end

function Editor:OnMouseRelease()
	self.dragging = false
end

function Editor:OnClick(button,mx,my)
	if self.TopMode == "platform" then
		self:OnClickPlatform(button,mx,my)
	else
		self:OnClickEnemy(button,mx,my)
	end
    
end

function Editor:GotFocus()
    self.Mode = "select"
    self.Verts = {}
	self.gui.visible = true
	love.mouse.setVisible(true)
	
end

function Editor:LostFocus()
    self.Mode = "select"
    self.Verts = {}
	self.gui.visible = false
    Game:UnlockViewport()
	love.mouse.setVisible(false)
end

function Editor:Finalise()
    if self.DrawMode == "path" then
        if #self.Verts < 6 then
            log("You need at least 3 non-colinear vertices")
        else
            Room.Current:AddPlatform(Platform:new(self.PlatformTypes[self.CurrentType], unpack(self.Verts)))
        end
    elseif self.DrawMode == "box" then
        if not self.BottomRight or not self.TopLeft then
            log("Nope please")
        else
            local v = {self.TopLeft[1], self.TopLeft[2], self.TopLeft[1], self.BottomRight[2], self.BottomRight[1], self.BottomRight[2], self.BottomRight[1], self.TopLeft[2]}
            Room.Current:AddPlatform(Platform:new(self.PlatformTypes[self.CurrentType], unpack(v)))
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

function Editor:Clear()
	local p = Room.Current.Platforms
	for i,v in ipairs(p) do
		Game.CWorld:remove(v.Collider)
	end
	Room.Current.Platforms = {}
end

function Editor:DeleteCollider()
    if self.Selected then
        local p = Room.Current.Platforms
        for i,v in ipairs(p) do
            if v == self.Selected then
                Game.CWorld:remove(v.Collider)
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
