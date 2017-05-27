local Part = require("shipparts/part")
local Engine = require("shipparts/engine")
local AI = require("ai")
local Settings = require("settings")

local AIBlock = {}
AIBlock.__index = AIBlock
setmetatable(AIBlock, Part)

function AIBlock.create(team)
	local self = Part.create()
	setmetatable(self, AIBlock)

	self.image = love.graphics.newImage("res/images/ai.png")
	self.width = self.image:getWidth()
	self.height = self.image:getHeight()
	self.physicsShape = love.physics.newRectangleShape(self.width, self.height)
	self.type = "control"

	self.engine = Engine.create(1, 150, 350)
	self.ai = AI.create(team)

	return self
end

function AIBlock:getTeam()
	return self.ai.team
end

function AIBlock:getOrders(location)
	return self.ai:getOrders(location)
end

function AIBlock:getMenu()
	return self.ai:getMenu()
end

function AIBlock:runMenu(i)
	return self.ai:runMenu(i)
end

function AIBlock:update(dt, partsInfo, location, locationSign, orientation)
	self.location = location
	self.orientation = orientation

	self.engine:update(self, partsInfo.engines, locationSign)
end

return AIBlock
