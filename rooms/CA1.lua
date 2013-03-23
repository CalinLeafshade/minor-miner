-- room CA1
local Room = require("room")

local CA1 = Room:new("CA1")

CA1.PlatformData = {  {"allblock", 0, 198, 0, 180, 318, 180, 318, 198,   },  {"allblock", 300, 179, 300, 86, 318, 86, 318, 179,   },  {"allblock", 15, 129, 1, 130, 0, 131, 0, 1, 109, 0, 105, 15, 91, 25, 69, 30, 50, 46, 25, 55, 34, 66, 35, 78, 21, 93, 20, 122,   },  {"allblock", 226, 23, 211, 0, 318, 0, 319, 85, 299, 85, 269, 41, 253, 33,   },}

CA1:AddExit("left", "CA2")

return CA1

