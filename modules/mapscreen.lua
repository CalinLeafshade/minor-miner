-- Map screen

MapScreen = require('module'):new("mapscreen")

function MapScreen:Init()
    self.Scale = 0.04
end

function MapScreen:BuildMap()

    local function addRoom(map, room, x, y, exit, lastRoom, enmult, exmult)
        if exit == "left" then
            x = x - room.Width
            y = y - exmult * 200
            y = y + enmult * 200
        elseif exit == "right" then
            x = x + lastRoom.Width
            y = y - exmult * 200
            y = y + enmult * 200
        elseif exit == "bottom" then
            y = y + lastRoom.Height
        elseif exit == "top" then
            y = y - room.Height
        end

        map[room.Name] = {Name = room.Name, X = x, Y = y, Width = room.Width, Height = room.Height}
        for i,v in pairs(room.Exits or {}) do
            for ii,vv in pairs(v) do
                if not map[vv.Room] and Game.State.Visited[vv.Room] then addRoom(map,Game.State.Map[vv.Room], x, y, i, room, ii, vv.ExitMult) end
            end
        end
    end

    local _,r = next(Game.State.Map)
    self.Map = {}

    addRoom(self.Map, r, 0,0)

    local xmin,xmax,ymin,ymax = 9999,-9999,9999,-9999

    for i,v in pairs(self.Map) do
        xmin = math.min(xmin, v.X)
        xmax = math.max(xmax, v.X + v.Width)
        ymin = math.min(ymin, v.Y)
        ymax = math.max(ymax, v.Y + v.Height)
    end

    self.X = xmin
    self.Y = ymin
    self.Width = xmax - xmin
    self.Height = ymax - ymin

end

function MapScreen:GotFocus()
    self:BuildMap()
end


function MapScreen:OnKeypress( key )
    ModCon:Defocus()
end

function MapScreen:Draw(focus)

    if not focus then return end

    local lg = love.graphics
	local Scale = Config.Scale
	
    lg.setColor(0,0,0,128)
    lg.rectangle("fill",0,0,lg.getWidth(), lg.getHeight())

    lg.push()
	lg.scale(Config.Scale)
    lg.translate(160 + (-self.X  * self.Scale - self.Width * self.Scale / 2), 90) -- centre map
    --lg.translate(160 + (-self.X  - self.Width), 100) -- centre map
	lg.setLineStyle("rough")
    for i,v in pairs(self.Map) do
        lg.setColor(0,0,255)
        lg.rectangle("fill", v.X * self.Scale, v.Y * self.Scale, v.Width * self.Scale, v.Height * self.Scale)
        
        if i == Room.Current.Name then
            lg.setColor(0,128,255, (math.sin(love.timer.getTime() * 4) + 1) / 2 * 255)
            lg.rectangle("fill", v.X * self.Scale, v.Y * self.Scale, v.Width * self.Scale, v.Height * self.Scale)
        end
		lg.setColor(255,255,255)
        lg.rectangle("line", v.X * self.Scale, v.Y * self.Scale, v.Width * self.Scale, v.Height * self.Scale)
		
    end

    --now draw the exits

    lg.setColor(0,0,255)
    for i,v in pairs(self.Map) do 
        local r = Game.State.Map[i]
        for ii,vv in pairs(r.Exits or {}) do
            for iii,vvv in pairs(vv) do
                local x = v.X
                local y = v.Y
                local x2 = x
                local y2 = y

                if ii == "left" then
                    y = y + iii * 200
                    y = y + 200 / 4
                    y2 = y + 200 / 2
                elseif ii == "right" then
                    y = y + iii * 200 
                    y = y + 200 / 4
                    y2 = y + 200 / 2
                    x = x + v.Width 
                    x2 = x
                end
                    lg.line(x * self.Scale,y * self.Scale,x2 * self.Scale,y2 * self.Scale)
                                
            end
        end
    end


    lg.pop()

end

return MapScreen