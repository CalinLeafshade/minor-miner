-- room CA4
local Room = require("room")

local CA4 = Room:new("CA4")

CA4.PlatformData = {  {"allblock", 319, 396, 21, 396, 21, 381, 319, 381,   },  {"allblock", 85, 325, 218, 325, 218, 336, 85, 336,   },  {"allblock", 62, 276, 21, 276, 21, 265, 62, 265,   },  {"allblock", 84, 210, 129, 210, 129, 221, 84, 221,   },  {"allblock", 60, 160, 20, 160, 20, 150, 60, 150,   },  {"allblock", 83, 95, 129, 95, 129, 104, 83, 104,   },  {"allblock", 60, 49, 21, 49, 21, 40, 60, 40,   },  {"allblock", 130, 0, 218, 0, 218, 324, 130, 324,   },  {"allblock", 219, 305, 219, 292, 254, 292, 254, 305,   },  {"allblock", 318, 181, 318, 304, 298, 304, 298, 181,   },  {"allblock", 297, 244, 297, 257, 268, 257, 268, 244,   },  {"allblock", 219, 211, 219, 200, 256, 200, 256, 211,   },  {"allblock", 319, 135, 219, 135, 219, 0, 319, 0,   },  {"allblock", 0, 0, 20, 0, 20, 112, 0, 112,   },  {"allblock", 20, 389, 0, 389, 0, 150, 20, 150,   },}

CA4:AddExit("top", "CA3")
CA4:AddExit("left", "CA10", 0)
CA4:AddExit("right", "CA5", 0)
CA4:AddExit("right", "CA7", 1)

return CA4

