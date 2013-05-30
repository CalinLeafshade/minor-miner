--Collisions




Collisions =
{
	standard = function(obj,col,dx,dy)
		
	end,
	bounce = function(obj,col,dx,dy, bc)
		local normal = vector.new(dx,dy):normalized()
		obj.Collider:move(dx,dy)
		obj.Velocity = obj.Velocity:reflect(normal) * bc
		if obj.Velocity:len() < 1 then
			obj.Velocity.x, obj.Velocity.y = 0,0
			obj.OnGround = true
			obj.Ground = col.Collider
		end
	end,
	handle = function(dt,obj,colType,...)
		
		if type(colType) == "string" then
			colType = Collisions[colType] or Collisions["standard"]
		end
		
		if not obj.OnGround then
			obj.Velocity = obj.Velocity + Game.Gravity * dt
		end
		
		local dx, dy = obj.Velocity.x * dt, obj.Velocity.y * dt
		if dx ~= dx then dx = 0 end
		if dy ~= dy then dy = 0 end
		
		obj.Collider:move(dx,dy)
		
		--for i,v in ipairs(Room.Current.Platforms or {}) do
		for v in pairs(obj.Collider:neighbors()) do
			
				if v.Object and v.Object.Type == "platform" then
					local c,dx,dy = v:collidesWith(obj.Collider)
					if c then
							colType(obj, v.Object,-dx,-dy, ...)
					end
				end
		end
	end
	
}
	
	
