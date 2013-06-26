--input

local Input = 
{
    Keys =
    {
        jump="z",
        melee="x",
		bomb="c",
        left="left",
        right="right",
		down="down",
        menu="escape",
        up = "up",
		jetpack="a",
    },
    state = {},
    lastState = {}
}

function Input:Update()
    self.lastState = self.state
    self.state = {}
    for k,v in pairs(self.Keys) do
        self.state[k] = love.keyboard.isDown(v)
    end
end

function Input:IsKeyDown(key)
    return self.state[key]
end

function Input:NewKeyDown(key)
    return self.state[key] and not self.lastState[key]
end

function Input:Is(command)
    if command == "jump" then
        return self:NewKeyDown("jump")
    elseif command == "melee" then 
        return self:NewKeyDown("melee")
		elseif command == "bomb" then 
        return self:NewKeyDown("bomb")
    else 
        return love.keyboard.isDown(self.Keys[command])
    end
end

return Input