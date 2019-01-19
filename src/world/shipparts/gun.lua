local Timer = require("timer")

local Gun = class()

function Gun:__create()
	self.charged = true
	self.rechargeTimer = Timer(0.5)

	return self
end

function Gun.process(orders)
	shoot = false
	for _, order in ipairs(orders) do
		if order == "shoot" then shoot = true end
	end
	return shoot
end

function Gun:update(dt, shoot, getPart)
	if not self.charged then
		if self.rechargeTimer:ready(dt) then
			self.charged = true
		end
	else
		if shoot then
			-- Check if there is a part one block infront of the gun.

			if not getPart({0, 1}) then
				self.charged = false
				-- Spawn Shot
				return {"shot", {0, 0, 1}, getPart({0,0})}
			end
		end
	end
end

return Gun
