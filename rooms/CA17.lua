local Room = require("room")

local room = Room:new("CA17")

room:AddExit("left", "CA9",0,0)
room:AddExit("bottom", "CA18")

return room