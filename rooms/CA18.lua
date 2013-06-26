local Room = require("room")

local room = Room:new("CA18")

room:AddExit("top", "CA17")


return room