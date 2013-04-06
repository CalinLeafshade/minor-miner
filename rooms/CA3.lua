-- room CA3

require("shaders")
require("vector")

local Room = require("room")

local CA3 = Room:new("CA3")

CA3.PlatformData = {  {"allblock", 319, 199, 82, 199, 82, 181, 319, 181,   },  {"allblock", 319, 180, 249, 180, 249, 150, 319, 150,   },  {"allblock", 0, 124, 20, 124, 20, 199, 0, 199,   },  {"allblock", 0, 108, 110, 108, 110, 123, 0, 123,   },  {"allblock", 291, 83, 285, 75, 289, 60, 290, 47, 286, 32, 262, 32, 249, 26, 235, 29, 215, 29, 203, 21, 186, 26, 169, 21, 148, 27, 121, 41, 100, 30, 49, 29, 33, 48, 28, 48, 23, 60, 0, 60, 0, 0, 319, 1, 318, 98, 311, 94, 305, 95,   },}

CA3.Zone = "The Caverns"

CA3:AddExit("right", "CA2")
CA3:AddExit("bottom", "CA4")

return CA3

