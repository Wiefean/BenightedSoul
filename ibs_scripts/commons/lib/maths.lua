--数学计算相关函数

local Maths = {}

--精确到小数位数
function Maths:Cut(num, reference)
	return tonumber(string.format('%.'..reference..'f', num))
end

--向量转方向
function Maths:VectorToDirection(vector)
	local angle = vector:GetAngleDegrees()

	if (angle < 45 and angle > -45) then
		return Direction.RIGHT
	elseif (angle <= -45 and angle >= -135) then
		return Direction.UP
	elseif (angle >= 45 and angle <= 135) then
		return Direction.DOWN
	end

	return Direction.LEFT
end

--方向转向量
local ToVector = {
	[Direction.NO_DIRECTION] = Vector(0, 1),
	[Direction.LEFT] = Vector(-1, 0),
	[Direction.UP] = Vector(0, -1),
	[Direction.RIGHT] = Vector(1, 0),
	[Direction.DOWN] = Vector(0, 1)
}
function Maths:DirectionToVector(direction)
	return ToVector[direction]
end

--眼泪伤害转眼泪大小
function Maths:TearDamageToScale(dmg)
    return dmg ^ 0.5 * 0.23 + dmg * 0.01 + 0.55
end

--在房间内移动位置(硬核方法)
function Maths:MoveInRoom(vector, offset, margin)
	margin = margin or 0
	local originOffset = offset
	local times = 0
	local room = Game():GetRoom()


	while (not room:IsPositionInRoom(Vector(vector.X + offset.X, vector.Y), margin)) do
		offset = Vector(offset.X - originOffset.X * 0.1, offset.Y)
		times = times + 1

		if times >= 100 then
			times = 0
			break
		end
	end

	while (not room:IsPositionInRoom(Vector(vector.X, vector.Y + offset.Y), margin)) do
		offset = Vector(offset.X, offset.Y - originOffset.Y * 0.1)
		times = times + 1

		if times >= 100 then
			break
		end
	end

	if room:IsPositionInRoom(vector + offset, margin) then
		vector = vector + offset
	end

	return vector
end


return Maths