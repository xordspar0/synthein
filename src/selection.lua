local Building = require("building")
local CircleMenu = require("circleMenu")
local Util = require("util")

local Selection = {}
Selection.__index = Selection

function Selection.create(world, team, camera)
	local self = {}
	setmetatable(self, Selection)

	self.world = world
	self.team = team
	self.camera = camera
	self.circleMenu = CircleMenu.create(self.camera)

	self.build = nil
	self.sturcture = nil
	self.partIndex = nil

	return self
end

function Selection:pressed(cursorX, cursorY, order)
	local structure, body, fixture = self.world:getObject(cursorX, cursorY)
	--if structure then part, partSide = structure:findPart(cursorX, cursorY) end

	if structure and structure.type == "structure" and body and fixture then
		local part = fixture:getUserData()
		local x, y = body:getLocalPoint(cursorX, cursorY)
		local roundedX = math.floor(x + .5)
		local roundedY = math.floor(y + .5)

		if self.build then
			if order == "build" then
				if self.build.mode == 3 then
					if not structure.corePart or
							structure.corePart:getTeam() == self.team then
						self.structure = structure
						self.part = part
						if self.build:setStructure(structure, part) then
							self.structure = nil
							self.part = nil
							self.build = nil
						end
					end
				end
			elseif order == "destroy" then
				self.structure = nil
				self.part = nil
				self.build = nil
			end
		else
			if order == "build" then
				if structure.getTeam() == 0 then
					self.build = Building.create(self.world, self.camera)
					self.build:setAnnexee(structure, part, body)
					self.structure = structure
					self.body = body
					self.part = part
					self.location = {roundedX, roundedY}
				elseif structure.getTeam() == self.team then
					self.structure = structure
					self.part = {roundedX, roundedY}
				end
			elseif order == "destroy" then
				if not structure.buildRequest then
					local buildRequest = {}
					buildRequest.type = 1
					buildRequest.disconnect = true
					buildRequest.team = self.team
					buildRequest.aPart = {roundedX, roundedY}

					structure.buildRequest = buildRequest
				end
			end
		end

	else
		if order == "destroy" then
			self.structure = nil
			self.part = nil
			self.build = nil
		end
	end
end

local function getpartSide(body, partLocation, cursorX, cursorY)
	local cursorX, cursorY = body:getLocalPoint(cursorX, cursorY)
	local netX , netY = cursorX - partLocation[1], cursorY - partLocation[2]
	local netXSq, netYSq = netX * netX, netY * netY

	local a, b = 0, 0
	if netXSq > netYSq then a = 1 end
	if netY - netX < 0 then b = 2 end
	return 1 + a + b, netXSq <= .25 and netYSq <= .25
end

function Selection:released(cursorX, cursorY)
	if self.structure and self.part then
		local body = self.body
		local l = self.part.location
		local partSide, withinPart = getpartSide(body, l, cursorX, cursorY)
		local x, y = body:getWorldPoints(l[1], l[2])
		if not withinPart then
			if self.build then
				if self.build:setSide(partSide) then
					self.build = nil
				end
			else
				local strength = self.part:getMenu()
				local newAngle = Util.vectorAngle(cursorX - x, cursorY - y)
				local index = self.angleToIndex(newAngle, #strength)
				self.part:runMenu(index)
			end
			self.structure = nil
			self.partSide = nil
		else
			if not self.build then
				self.structure = nil
				self.partSide = nil
			end
		end
	end
end

function Selection.angleToIndex(angle, length)
	local index = math.floor(((-angle/math.pi + 0.5) * length + 1)/2 % length + 1)
	return index
end

function Selection:draw(cursorX, cursorY)
	if self.structure and self.part and self.location then
		local body = self.body
		local part = self.part
		local l = part.location

		local x, y = body:getWorldPoints(l[1], l[2])
		local angle = (l[3] - 1) * math.pi/2 + body:getAngle()
		local partSide = getpartSide(body, l, cursorX, cursorY)

		local strength, lables
		if self.build then
			local connectableSides = part.connectableSides
			strength = {}
			for i = 1, 4 do
				if connectableSides[i] then
					if i == partSide then
						table.insert(strength, 2)
					else
						table.insert(strength, 1)
					end
				else
					table.insert(strength, 0)
				end
			end
			local strengthX = strength[2]
			strength[2] = strength[4]
			strength[4] = strengthX
		else
			angle = 0
			strength, lables = self.part:getMenu()
			local newAngle = Util.vectorAngle(cursorX - x, cursorY - y)
			local index = self.angleToIndex(newAngle, #strength)
			if strength[index] == 1 then
				strength[index] = 2
			end
		end
		if strength then
			self.circleMenu:draw(x, y, angle, 1, strength, lables)
		end
	end
	if self.build then
		self.build:draw(self.body)
	end
end

return Selection
