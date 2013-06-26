local Room = require("room")

local room = Room:new("CA17")

room:AddExit("left", "CA9",1,2)
room:AddExit("bottom", "CA18")

return room