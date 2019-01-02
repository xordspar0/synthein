local Util = require("util")

local Building = {}
Building.__index = Building

function Building.create(world, camera)
	local self = {}
	setmetatable(self, Building)

	self.pointerImage = love.graphics.newImage("res/images/pointer.png")
	self.pointerWidth = self.pointerImage:getWidth()
	self.world = world
	self.camera = camera

	self.structure = nil
	self.structurePartIndex = nil
	self.structurePartSide = nil
	self.annexee = nil
	self.annexeePartIndex = nil
	self.annexeePartSide = nil
	self.mode = 1

	return self
end

function Building:setAnnexee(structure, part)
	self.annexee = structure
	self.annexeePart = part
	self.mode = 2
end

function Building:setStructure(structure, part)
	if self.annexee == structure then
		return true
	end
	self.structure = structure
	self.structurePart = part
	self.mode = 4
	return false
end

function Building:setSide(partSide)
	if self.mode == 2 then
		if self.annexeePart.connectableSides[partSide] then
			self.annexeePartSide = partSide
			self.mode = 3
			return false
		else
			return true
		end
	elseif self.mode == 4 then
		if self.structurePart.connectableSides[partSide] then
			self.structurePartSide = partSide
			if self.annexee and self.annexeePart and self.annexeePartSide
				and self.structure and self.structurePart
				and self.structurePartSide then
				self.structure:annex(self.annexee, self.annexeePart,
							self.annexeePartSide,
							self.structurePart, self.structurePartSide)
			end
		end
		return true
	end
end

function Building.getStrengthTable(part, partSide)
	local connectableSides = part.connectableSides
	local strength = {}
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
	return strength
end

function Building:draw()
	if self.annexeePart and self.annexeePartSide then
		local x, y, partAngle = self.annexeePart:getWorldLocation():getXYA()
		local angle = self.annexeePartSide * math.pi/2 + partAngle
		local offsetX, offsetY = Util.vectorComponents(.5, angle)
		self.camera:draw(self.pointerImage,
						 x + offsetX,
						 y + offsetY,
						 angle,
						 1/20, 1/20, self.pointerWidth/2, self.pointerWidth/2)
	end
end

return Building
