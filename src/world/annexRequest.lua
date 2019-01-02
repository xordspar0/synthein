local Annex = class()

function Annex:__create(
		bodyUserData, partLocation,
		annexeeBodyUserData, nnexeePartLocation)

	self.denied = false
	self.replied = false
	self.partLocation = partLocation
	self.annexeePartLocation = annexeePartLocation



end

function Annex:deny()
	self.denied = true
end

function Annex:isDenied()
	return self.denied
end

function Annex:hasReplied()
	return self.replied
end

function Annex:getLocations()
	return partLocation, annexeePartLocation
end

function Annex:getRequest()
	local function f(structure)
		self.replied = true
		self.annexee = structure
		return true
	 end
	 return f
end

function Annex:getAtempt()
	local function f(structure)
		if self.annexee then return false end
		structure:annex(
			self.annexee, self.annexeePart,
			self.annexeePartSide,
			self.structurePart, self.structurePartSide)
		return true
end

return Annex
