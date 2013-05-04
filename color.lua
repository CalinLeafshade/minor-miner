-- color

Color = {}

Color.mt = {}

Color.mt.__index = function(t,v)
	if v == "r" or v == "g" or v == "b" or v == "a" then
			return t.rawColor[v]
		else
			return Color[v]
		end
	end

Color.mt__newindex = function(t,k,v)
	if k == "r" or k == "g" or k == "b" or k == "a" then
		t.rawColor[k] = clamp(v,0,255)
	else
		t[k] = v
	end
end

function Color.FromRGBA(r,g,b,a)
	local o = {}
	setmetatable(o, Color.mt)
	o.rawColor = {}
	o.rawColor.r = r
	o.rawColor.g = g
	o.rawColor.b = b
	o.rawColor.a = a or 255
	return o
end

function Color:unpack()
	return self.r, self.g, self.b, self.a
end

Color.DarkRed = Color.FromRGBA(128,0,0)
Color.DarkGreen = Color.FromRGBA(0,128,0)
Color.DarkBlue = Color.FromRGBA(0,0,128)
Color.LightGrey = Color.FromRGBA(200,200,200)
Color.DarkGrey = Color.FromRGBA(100,100,100)
Color.White = Color.FromRGBA(255,255,255)

