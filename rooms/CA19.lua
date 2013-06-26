--CA19.lua

local Room = require("room")

local CA19 = Room:new("CA19")

CA19:AddExit("left", "CA22")
CA19:AddExit("top", "CA15")
CA19:AddExit("bottom", "CA20")

return CA19