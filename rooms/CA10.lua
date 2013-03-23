-- room CA10
local Room = require("room")

local CA10 = Room:new("CA10")

CA10.PlatformData = {  {"allblock", 301, 112, 301, 1, 319, 1, 319, 112,   },  {"allblock", 0, 15, 0, 0, 300, 0, 300, 15,   },  {"allblock", 0, 198, 0, 16, 18, 16, 18, 198,   },  {"allblock", 318, 182, 318, 198, 19, 198, 19, 182,   },  {"allblock", 319, 150, 319, 181, 301, 181, 301, 150,   },  {"save", 210, 181, 114, 181, 114, 73, 210, 73,   },}

CA10:AddExit("right", "CA4")

return CA10