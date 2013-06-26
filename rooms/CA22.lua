local Room = require("room")

local room = Room:new("CA22")

room:AddExit("bottom", "CA21",0,1)
room:AddExit("right", "CA19")

return room