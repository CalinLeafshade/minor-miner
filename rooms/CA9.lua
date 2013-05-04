--CA9
local Room = require("room")

local CA9 = Room:new("CA9")

CA9.PlatformData = {  {"allblock", 0, 54, 40, 54, 40, 154, 0, 154,   },  {"allblock", 41, 74, 56, 74, 56, 129, 41, 129,   },  {"allblock", 58, 158, 57, 110, 90, 110, 116, 117, 182, 117, 182, 159,   },  {"allblock", 182, 194, 183, 159, 275, 159, 371, 168, 639, 168, 638, 197, 189, 194,   },  {"allblock", 261, 121, 242, 115, 242, 100, 273, 100, 325, 110, 364, 111, 391, 100, 473, 100, 516, 122, 639, 122, 639, 167, 622, 167, 622, 130, 495, 130, 466, 116, 391, 116, 369, 127, 369, 135, 274, 136,   },  {"allblock", 639, 0, 637, 25, 615, 29, 581, 29, 552, 26, 524, 30, 512, 34, 496, 32, 474, 32, 468, 30, 442, 23, 414, 28, 396, 29, 355, 29, 318, 26, 291, 21, 258, 19, 249, 25, 217, 25, 205, 26, 191, 21, 172, 20, 144, 18, 60, 20, 18, 20, 0, 15, 0, 0,   },  {"water", 621, 168, 183, 168, 183, 133, 621, 133,   },}

CA9:AddExit("left", "CA15")

return CA9