local PhysicsReferences = require("world/physicsReferences")

local Shield = class()



function Shield:__create(body)
	self.partLocations = {}
	self.body = body
	self.health = 5

	self.shader = love.graphics.newShader[[
		vec4 effect( vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords ){
			return vec4(screen_coords.x/255,1 - texture_coords.y/25,0,1);
		}
	  ]]
end

--[[
	extern number partX;
	extern number partY;
		  number dx = texture_coords.x - partX;
		  number dy = texture_coords.y - partY;
		  number distanceSq = (dx*dx + dy*dy);
		  number total = 0.25/distanceSq;
		  return vec4(texture_coords.x,texture_coords.y,screen_coords.x/255,1);
--]]

function Shield:addPart(x, y)
	if self.fixture then self.fixture:destroy() end
	table.insert(self.partLocations, {x, y})

	self.points = {x - 2.5, y - 2.5, 5, 5}
	self.part = {x, y}

	local shape = love.physics.newRectangleShape(x,
												 y,
												 5, 5)
	self.fixture = love.physics.newFixture(self.body, shape)
	self.fixture:setUserData(self)
	PhysicsReferences.setFixtureType(self.fixture, "shield")
end

function Shield:collision()
end

function Shield:damage()
	self.health = self.health - 1
	if self.health <= 0 then
		self.fixture:destroy()
		self.fixture = nil
	end
end

function Shield:draw()
	love.graphics.setShader(self.shader)
	--self.shader:send("partX", self.part[1])
	--self.shader:send("partY", self.part[2])
	local x, y, width, height = unpack(self.points)
	love.graphics.rectangle("fill", x- 10, y - 10, width + 20, height + 20)
	love.graphics.setShader()

	--local x, y, width, height = unpack(self.points)
	love.graphics.setLineWidth(.4)
	love.graphics.rectangle("line", x, y, width, height)
end

return Shield
