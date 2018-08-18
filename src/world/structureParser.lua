local GridTable = require("gridTable")
local PartRegistry = require("world/shipparts/partRegistry")
local Util = require("util")

local StructureParser = {}

function StructureParser.loadShipFromFile(ship)
	local contents, size
	if ship then
		local file = string.format("res/ships/" .. ship .. ".txt")
		contents, size = love.filesystem.read(file)
		return contents, size
	end
	return nil, nil
end

function StructureParser.shipUnpack(appendix, shipData)
	local shipString, stringLength
	if string.match(appendix, "[*\n]") then
		shipString = appendix
		stringLength = #appendix
	else
		shipString, stringLength = StructureParser.loadShipFromFile(appendix)
	end

	local shipTable = {parts = GridTable()}
	local player = false

	if not shipString then return end

	local baseX
	local y = 0
	for line in shipString:gmatch(".-\n") do
		y = y + 1
		local find = line:find("*")
		if find then
			baseX = find - 1
			break
		end
	end

	for line in shipString:gmatch(".-\n") do
		y = y - 1
		local length = #line
		local m = line:find("[.%[\n]") or length + 1
		local types = line:sub(1, m - 1)
		local dataString = line:sub(m, length)

		local dataTable = {}
		for partData in dataString:gmatch("[.%[]([^.%[%]\n]*)%]?") do
			partDataTable = {}
			for number in partData:gmatch("[^,]") do
				table.insert(partDataTable, tonumber(number))
			end
			table.insert(dataTable, partDataTable)
		end

		local partCounter = 0
		for i = 1, #types - 1 do
			if types:sub(i, i + 1):match("%a[1234*]") then
				local c = types:sub(i,i)
				local nc = types:sub(i + 1, i + 1)

				local part, ifPlayer = PartRegistry.createPart(c, shipData)

				-- Data handling.
				partCounter = partCounter + 1
				local partData = dataTable[partCounter]
				if partData then part:loadData(partData) end

				-- Location handling.
				local x = (i - baseX)/2
				local orientation
				if nc == '*' then
					if part.getTeam then
						shipTable.corePart = part
						player = ifPlayer
					end
					orientation = 1
				else
					orientation = tonumber(nc)
				end
				part:setLocation({x, y, orientation})

				-- Add to grid table
				shipTable.parts:index(x, y, part)
			end
		end
	end

	return shipTable, player
end

function StructureParser.shipPack(structure, saveThePartData)
	PartRegistry.setPartChars()
	local string = ""
	local xLow, xHigh, yLow, yHigh = 0, 0, 0, 0
	local parts = structure.gridTable:loop()
	local stringTable = {}
	for _, part in ipairs(parts) do
		local x = part.location[1]
		local y = part.location[2]
			print(y, x)
		if     x < xLow  then
			xLow = x
		elseif x > xHigh then
			xHigh = x
		end
		if y < yLow  then
			yLow = y
		elseif y > yHigh then
			yHigh = y
		end
	end
	for i = 1, (yHigh - yLow + 1) do
		table.insert(stringTable, {})
		for _ = 1, (xHigh - xLow + 1) do
			table.insert(stringTable[i], {"  "})
		end
	end
	for i, part in ipairs(parts) do
		local x = part.location[1]
		local y = part.location[2]
		local tempString, a, b
--		local loadData = {}

		a = part.partChar
--[[
		--Find the string representation of the part.
		if     getmetatable(part) == Block then a = "b"
		elseif getmetatable(part) == EngineBlock then a = "e"
		elseif getmetatable(part) == GunBlock then a = "g"
		elseif getmetatable(part) == AIBlock then a = "a"
		elseif getmetatable(part) == PlayerBlock then a = "p"
		elseif getmetatable(part) == Anchor then a = "n"
		end
--]]

		if part == structure.corePart or (not structure.corePart and i==1) then
			b = "*"
		else
			b = tostring(part.location[3])
		end
		tempString = a .. b
		--Add data to table
		if saveThePartData then
			stringTable[y - yLow + 1][x - xLow + 1] = {tempString, part:saveData()}
		else
			stringTable[y - yLow + 1][x - xLow + 1] = {tempString}
		end
	end
	--Put strings together
	local dataString = ""
	for i = 1,#stringTable do
		local ii = #stringTable - i + 1
		for j = 1,#stringTable[ii] do
			string = string .. stringTable[ii][j][1]
			if stringTable[ii][j][2]then
				dataString = dataString ..
							 Util.packLocation({j + xLow - 1, ii + yLow - 1}) ..
							 Util.packData(stringTable[ii][j][2]) ..
							 --Tserial.pack(stringTable[i][j][2], nil, true) ..
							 "\n"
			end
		end
		string = string .. "\n"
	end
	string = string .. "\n" .. dataString
	return string
end

return StructureParser
