--CA20.lua

local Room = require("room")

local room = Room:new("CA20")

room:AddExit("left", "CA21")
room:AddExit("top", "CA19")
room:AddExit("right", "DM1")

return room