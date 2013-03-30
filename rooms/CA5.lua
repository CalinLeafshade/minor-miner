-- room CA5
local Room = require("room")

local CA5 = Room:new("CA5")

CA5.PlatformData = {  {"allblock", 319, 197, 0, 197, 0, 181, 319, 181,   },  {"allblock", 301, 9, 319, 9, 319, 135, 301, 135,   },  {"allblock", 0, 0, 299, 0, 299, 20, 0, 20,   },  {"allblock", 0, 20, 20, 20, 20, 135, 0, 135,   },}

CA5:AddExit("left", "CA4")
CA5:AddExit("right", "CA6")

return CA5