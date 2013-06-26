--CA15
local Room = require("room")

local CA15 = Room:new("CA15")

CA15:AddExit("left", "CA8")
CA15:AddExit("right", "CA9")
CA15:AddExit("top", "CA11")
CA15:AddExit("bottom", "CA19")

return CA15