-- TitleScreenModule

TitleScreenModule = require('module'):new("titlescreen")

local tsm = TitleScreenModule
local Menus = {}

function Menus:GetItemByName(name, num)
	local function findInMenu(name, num)
		for k,v in ipairs(self[num].Items) do
			if v.Name == name then
				return v
			end
		end
	end
	if num then return findInMenu(name, num) end
	
	for i=1, #Menus do
		local item = findInMenu(name, i)
		if item then return item end
	end
	
	
end

Menus[1] = 
{
	Name = "main",
	Items =
	{
		{ 
			Text = "Start Game",
			Type = "label",
			OnActivate = function()
				Game:NewGame(1)
        Game:Start()
        ModCon:Focus(Game)
			end
		},
		{ 
			Text = "Continue",
			Type = "label",
			OnActivate = function()
				if Game:Load(1) then
            Game:Start()
            ModCon:Focus(Game)
        end
			end
		},
		{ 
			Text = "Options",
			Type = "label",
			OnActivate = function()
				tsm:ShowMenu("options")
			end
		},
		{ 
			Text = "Quit Game",
			Type = "label",
			OnActivate = function()
				love.event.push("quit")
			end
		}
	}
}

Menus[2] = 
{
	Name = "options",
	OnShow = function()
		local item
		item = Menus:GetItemByName("scale")
		item.Value = Config.Scale
		item = Menus:GetItemByName("fullscreen")
		item.Value = Config.Fullscreen and 1 or 2
		item = Menus:GetItemByName("vsync")
		item.Value = Config.VSync and 1 or 2
	end,
	Items =
	{
		{ 
			Name = "scale",
			Text = "Scale Factor",
			Type = "selector",
			Choices = {1,2,3,4,5}
		},
		{ 
			Name = "fullscreen",
			Text = "Fullscreen",
			Type = "selector",
			Choices = {"Yes", "No"}
		},
		{ 
			Name = "vsync",
			Text = "VSync",
			Type = "selector",
			Choices = {"Yes", "No"}
		},
		{
			Type = "spacer"
		},
		{ 
			Text = "Apply and Return",
			Type = "label",
			OnActivate = function()
				local item
				item = Menus:GetItemByName("scale")
				Config.Scale = item.Choices[item.Value or 1]
				item = Menus:GetItemByName("fullscreen")
				Config.Fullscreen = (item.Value or 1) == 1
				item = Menus:GetItemByName("vsync")
				Config.VSync = (item.Value or 1) == 1
				Config:Save()
				Config:InitGfx()
				Config:Changed()
				tsm:ShowMenu(Menus[tsm.lastMenu].Name)
			end
		},
		{ 
			Text = "Discard and Return",
			Type = "label",
			OnActivate = function()
				tsm:ShowMenu(Menus[tsm.lastMenu].Name)
			end
		}
	}
}

Menus[3] = 
{
	Name = "pause",
	Items =
	{
		{ 
			Text = "Resume",
			Type = "label",
			OnActivate = function()
				ModCon:Defocus()
			end
		},
		{ 
			Text = "New Game",
			Type = "label",
			OnActivate = function()
				Game:NewGame(1)
        Game:Start()
        ModCon:Focus(Game)
			end
		},
		{ 
			Text = "Options",
			Type = "label",
			OnActivate = function()
				tsm:ShowMenu("options")
			end
		},
		{ 
			Text = "Quit Game",
			Type = "label",
			OnActivate = function()
				love.event.push("quit")
			end
		}
	}
}



function TitleScreenModule:Init()
    self.Menu = 1
		self.Selected = 1
		self:ShowMenu("main")
    ModCon:Focus(self)
end

function TitleScreenModule:Update()
    
end

function TitleScreenModule:ShowMenu(name)
	local menus = {main = 1, options = 2, pause = 3}
	self.lastMenu = self.Menu
	self.Menu = menus[name]
	self.Selected = 1
	if Menus[self.Menu].OnShow then Menus[self.Menu]:OnShow() end
end

function TitleScreenModule:Up()
    self.Selected = self.Selected - 1
    if self.Selected < 1 then
        self.Selected = #Menus[self.Menu].Items
    end
		local item = self:SelectedItem()
		while item.Type == "spacer" do
			self:Up()
			item = self:SelectedItem()
		end
end

function TitleScreenModule:Down()
    self.Selected = self.Selected + 1
    if self.Selected > #Menus[self.Menu].Items then
        self.Selected = 1
    end
		local item = self:SelectedItem()
		while item.Type == "spacer" do
			self:Down()
			item = self:SelectedItem()
		end
end

function TitleScreenModule:Draw(focus)
    if not focus then return end
		local spacing = 15
		local w = 320 * Config.Scale
		local h = 200 * Config.Scale
		love.graphics.setColor(0,0,0,128)
		love.graphics.rectangle("fill",0,0,w,h)
		for i,v in ipairs(Menus[self.Menu].Items) do
			local c = self.Selected == i and {255,255,255} or {128,128,128}
			love.graphics.setColor(unpack(c))
			if v.Type == "label" then
				love.graphics.printf(v.Text, 0, 100 + (spacing * i), 320 * Config.Scale, "center")
			elseif v.Type == "selector" then
				local text = v.Text .. "   -   " .. v.Choices[v.Value or 1]
				love.graphics.printf(text, 0, 100 + (spacing * i), 320 * Config.Scale, "center")
				--love.graphics.print(v.Text, w/2 - 50, 100 + (spacing * i))
				--love.graphics.print(v.Choices[v.Value or 1], w/2 + 50, 100 + (spacing * i))
			end
		end
end

function TitleScreenModule:Select()
	local item = self:SelectedItem()
	if item.OnActivate then item:OnActivate() end
end

function TitleScreenModule:SelectedItem()
	return Menus[self.Menu].Items[self.Selected]
end

function TitleScreenModule:Left()
	local item = self:SelectedItem()
	if item.Type == "selector" then
		item.Value = loop(item.Value - 1, 1, #item.Choices)
	end
end

function TitleScreenModule:Right()
	local item = self:SelectedItem()
	if item.Type == "selector" then
		item.Value = loop(item.Value + 1, 1, #item.Choices)
	end
end

function TitleScreenModule:OnKeypress(key)

    if key == "up" then
        self:Up()
    elseif key == "down" then
        self:Down()
		elseif key == "left" then
        self:Left()
		elseif key == "right" then
        self:Right()
    elseif key == "return" then
        self:Select()
    end

end

return TitleScreenModule