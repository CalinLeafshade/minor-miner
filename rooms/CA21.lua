local Room = require("room")

local room = Room:new("CA21")

room:AddExit("top", "CA22",1,0)
room:AddExit("right", "CA20")

return room