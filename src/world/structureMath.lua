local StructureMath = {}

StructureMath.unitVectors = {{0, 1}, {-1, 0}, {0, -1}, {1, 0}}
StructureMath.multipliers = {{1, 1}, {-1, 1}, {-1, -1},{1, -1}}
StructureMath.swap = {false, true, false, true}

function StructureMath.toDirection(value)
	return (value - 2) % 4 + 1
end

function StructureMath.addUnitVector(vector, direction)
	return {vector[1] + StructureMath.unitVectors[direction][1],
			vector[2] + StructureMath.unitVectors[direction][2],
			vector[3]}
end

function StructureMath.rotateVector(vector, rotation)
	if StructureMath.swap[rotation] then
		vector = {vector[2], vector[1]}
	end
	local mult = StructureMath.multipliers[rotation]
	vector = {mult[1] * vector[1],
			  mult[2] * vector[2]}
	return vector
end

function StructureMath.sumVectors(vectorA, vectorB)
	local rotation = StructureMath.toDirection(vectorA[3] + vectorB[3])
	local vector = StructureMath.rotateVector(vectorB, vectorA[3])
	vector[1] = vectorA[1] + vector[1]
	vector[2] = vectorA[2] + vector[2]
	vector[3] = rotation
	return vector
end

function StructureMath.subtractVectors(vectorA, vectorB)
	local rotation = StructureMath.toDirection(vectorA[3] - vectorB[3])
	local vector = StructureMath.rotateVector(vectorB, rotation)
	vector[1] = vectorA[1] - vector[1]
	vector[2] = vectorA[2] - vector[2]
	vector[3] = rotation
	return vector
end

function StructureMath.annexBaseVector(structureLocation, structurePartSide, annexeelocation, annexeePartSide)
	local structureSide = StructureMath.toDirection(structurePartSide + structureLocation[3])

	local structureVector = {}
	structureVector[1] = structureLocation[1]
	structureVector[2] = structureLocation[2]
	structureVector[3] = structureSide

	local annexeeBaseVector = {}
	annexeeBaseVector[1] = annexeelocation[1]
	annexeeBaseVector[2] = annexeelocation[2]
	annexeeBaseVector[3] = StructureMath.toDirection(annexeePartSide + annexeelocation[3])

	structureVector = StructureMath.addUnitVector(structureVector, structureSide)
	return StructureMath.subtractVectors(structureVector, annexeeBaseVector)
end

return StructureMath
