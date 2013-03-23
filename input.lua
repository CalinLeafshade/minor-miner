--input

local Input = 
{
	Keys =
	{
		jump="z",
		melee="x",
		left="left",
		right="right",
		menu="escape",
		up = "up"
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
	else 
		return love.keyboard.isDown(self.Keys[command])
	end
end

return Input