-- TitleScreenModule

TitleScreenModule = require('module'):new("titlescreen")

function TitleScreenModule:Init()
    self.Selected = 1
    ModCon:Focus(self)
end

function TitleScreenModule:Update()
    
end

function TitleScreenModule:Up()
    self.Selected = self.Selected - 1
    if self.Selected < 1 then
        self.Selected = 2
    end
end

function TitleScreenModule:Down()
    self.Selected = self.Selected + 1
    if self.Selected > 2 then
        self.Selected = 1
    end
end

function TitleScreenModule:Draw(focus)
    if not focus then return end
    local c = self.Selected == 1 and {255,255,255} or {128,128,128}
    love.graphics.setColor(unpack(c))
    love.graphics.print("Start", 400,400)
    local c = self.Selected == 2 and {255,255,255} or {128,128,128}
    love.graphics.setColor(unpack(c))
    love.graphics.print("Continue", 400,450)
end

function TitleScreenModule:Select()
    if self.Selected == 1 then
        Game:NewGame(1)
        Game:Start()
        ModCon:Focus(Game)
    elseif self.Selected == 2 then
        if Game:Load(1) then
            Game:Start()
            ModCon:Focus(Game)
        end
    end
end


function TitleScreenModule:OnKeypress(key)

    if key == "up" then
        self:Up()
    elseif key == "down" then
        self:Down()
    elseif key == "return" then
        self:Select()
    end

end

return TitleScreenModule