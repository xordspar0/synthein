Annex = class()

function Annex:__create(team)
	self.stage = 0
	self.abort = false
	self.team = team


	local structureHandle = {}
	function structureHandle.Abort()
		self.abort
end

function Annex:abort()
	self.abort = true
end

function Annex:getRequest()
	local stage = self.stage
	if     stage == 0 then
		-- check for part and connectableSides
	elseif stage == 1 then
	elseif stage == 2 then
	elseif stage == 3 then
	elseif stage == 4 then
	elseif stage ==


end

return Annex
