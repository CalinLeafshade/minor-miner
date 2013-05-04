--CA11
local Room = require("room")

local CA11 = Room:new("CA11")

CA11:AddExit("bottom", "CA15")

return CA11