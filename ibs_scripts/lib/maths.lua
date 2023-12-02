--数学计算相关函数

local Maths = {}


--向量转方向
function Maths:VectorToDirection(vector)
	local angle = vector:GetAngleDegrees()

	if (angle < 45 and angle >= -45) then
		return Direction.RIGHT
	elseif (angle < -45 and angle >= -135) then
		return Direction.UP
	elseif (angle > 45 and angle <= 135) then
		return Direction.DOWN
	end

	return Direction.LEFT
end

--方向转向量
local ToVector = {
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


return Maths