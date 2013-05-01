Platform = 
{
  Type = "platform" 
}

function Platform.Rectangle(x,y,w,h)
    return Platform:new(x,y,x,y + h,x +w, y+h,x + w,y)
end

function Platform:new (...)
    o = {}
    setmetatable(o, self)
    self.__index = self
    local params = {...}
    o.Mode = "allblock"
    if type(params[1]) == "string" then
        o.Mode = params[1]
        table.remove(params,1)
    end
    
    local rw = Room.Current:Width()
    local rh = Room.Current:Height()

    for i,v in ipairs(params) do -- extend platforms
        if i % 2 == 1 then -- x
            if v == 0 then
                params[i] = -5
            elseif v >= rw - 2 then
                params[i] = rw + 5
            end
        else --y
            if v == 0 then
                params[i] = -5
            elseif v >= rh - 2 then
                params[i] = rh + 5
            end
        end
    end
    o.Collider = Game.CWorld:addPolygon(unpack(params))
    o.Collider.Object = o
    return o
end

function Platform:Draw(scale)

    local v = {self.Collider._polygon:unpack()}
    for i = 1, #v do
        if i % 2 == 1 then
            v[i] = v[i] - Game.Viewport.x
        else
            v[i] = v[i] - Game.Viewport.y
        end
        v[i] = v[i] * scale + 2
    end
    love.graphics.polygon("line", unpack(v))
end

return Platform