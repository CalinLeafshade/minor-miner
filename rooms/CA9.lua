--CA9
local Room = require("room")

local CA9 = Room:new("CA9")

CA9:AddExit("left", "CA15")
CA9:AddExit("right", "CA17")

return CA9