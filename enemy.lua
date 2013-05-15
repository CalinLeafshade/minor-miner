--enemy
local vector = require('vector')

EnemyTypes = {}

Enemy = 
{
	Type = "enemy"
}

function Enemy:GetTypes()
	local files = love.filesystem.enumerate("enemies")
    for _,v in ipairs(files) do
        local e = love.filesystem.load("enemies/" .. v)()
		EnemyTypes[e.Name] = e
    end
end

function Enemy:new(name)
	o = {}
    setmetatable(o, self)
    self.__index = self
	o.Name = name
	
	return o
end

function Enemy:HitWall(dx)
	
end

function Enemy:PlatformCollide(object,dx,dy)
	self.CollVec.x = dx
    self.CollVec.y = dy
    self.CollVec:normalize()
    local resolve = false;
    if object.Mode ~= trigger then
        if object.Mode == "allblock" then
            resolve = true
        elseif object.Mode == "downonly" then
            if ((dy < 0 and self.Velocity.y >= 0) or self.OnGround) then
                resolve = true
            end
        end
        
        if resolve then 
            if math.abs(dy / dx) > 1 and dy < 0 and self.Velocity.y >= 0 then
                self.OnGround = true
                self.Ground = object.Collider
                self.Velocity.y = 0
            elseif (math.abs(self.CollVec.x) > 0.5) then
                if (dx < 0 and self.Velocity.x > 0) or (dx > 0 and self.Velocity.x < 0) then
                    self:HitWall(dx)
                end
            end
          
            if math.abs(dy / dx) > 1 then 
                self.Collider:move(0, dy) 
            else 
                self.Collider:move(dx, dy) 
            end
        end

    end
end

function Enemy:Remove()
	for i, v in 	pairs(Room.Current.Enemies or {}) do
		if v == self then
			table.remove(Room.Current.Enemies, i)
			break
		end
	end
end

function Enemy:ResolveAndMove(dt)
	if not self.Collider then return end
	
	if not self.OnGround then
		self.Velocity = self.Velocity + Game.Gravity * dt
	end
	
	self.Collider:move(self.Velocity.x * dt, self.Velocity.y * dt)
	
	for i,v in pairs(Room.Current.Platforms or {}) do
        local c,dx,dy = v.Collider:collidesWith(self.Collider)
        if c then
            self:PlatformCollide(v,-dx,-dy)
        end
    end
	
	if self.OnGround and math.abs(self.Velocity.x) > 0 then
        local x,y = self.Collider:center()
        y = y + self.Height / 2
        local ychange = 0
        local doMove = false
        
        for i=1,5 do
            if not (self.Ground:contains(x,y + ychange) or self.Ground:contains(x - self.Width / 2,y + ychange) or self.Ground:contains(x + self.Width / 2,y + ychange)) then
                ychange = ychange + 1
            else
                doMove = true
                break;
            end
        end
    
        if doMove then
            self.Collider:move(0, math.max(ychange - 1,0))
        else
            self.OnGround = false
        end
    end
	
		
end

function Enemy:Update(dt)
	self:ResolveAndMove(dt)
end

function Enemy:Draw(dt)
	if self.Animation then
		local x,y = self.Collider:center()
		love.graphics.setColor(Color.White:unpack())
		self.Animation:Draw(x,y)
	elseif self.Collider then
		self.Collider:Draw()
	end
end

function Enemy:MoveTo(x,y)
	if self.Collider then
		self.Collider:moveTo(x,y)
	end
end

function Enemy.Spawn(name, x, y)
	local e = EnemyTypes[name]:new()
	e:MoveTo(x,y)
	Room.Current:AddObject(e)
end


return Enemy