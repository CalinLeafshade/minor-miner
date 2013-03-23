--CA6
local Room = require("room")

local CA6 = Room:new("CA6")

CA6.PlatformData = {  {"allblock", 317, 199, 0, 199, 0, 181, 317, 181,   },  {"allblock", 317, 180, 300, 180, 300, 0, 317, 0,   },  {"allblock", 0, 1, 299, 1, 299, 20, 0, 20,   },  {"allblock", 0, 20, 20, 20, 20, 135, 0, 135,   },}

CA6:AddExit("left", "CA5")

return CA6