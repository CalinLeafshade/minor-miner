local Room = require("room")

local CA16 = Room:new("CA16")

CA16:AddExit("right", "CA3")

return CA16