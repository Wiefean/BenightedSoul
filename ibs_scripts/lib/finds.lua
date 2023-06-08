--查找实体相关函数

local Finds = {}


--最近的敌人
function Finds:ClosestEnemy(pos)
	local entities = Isaac.GetRoomEntities()
	local closestEnt = nil
	local closestDist = 2^32

	for i = 1, #entities do
		if entities[i]:IsEnemy() and entities[i]:IsVulnerableEnemy() and entities[i]:HasEntityFlags(EntityFlag.FLAG_FRIENDLY) == false then
			local dist = (entities[i].Position - pos):LengthSquared()
			if dist < closestDist then
				closestDist = dist
				closestEnt = entities[i]
			end
		end
	end

	return closestEnt
end


--最近的道具
function Finds:ClosestCollectible(pos)
	local entities = Isaac.FindByType(5,100)
	local closestEnt = nil
	local closestDist = 2^32

	for i = 1, #entities do
		local dist = (entities[i].Position - pos):LengthSquared()
		if entities[i].SubType ~=0 and dist < closestDist then
			closestDist = dist
			closestEnt = entities[i]
		end
	end

	return closestEnt
end


--最近的玩家(不包括玩家宝宝和玩家鬼魂)
function Finds:ClosestPlayer(pos)
	local entities = Isaac.FindByType(1,0)
	local closestEnt = nil
	local closestDist = 2^32

	for i = 1, #entities do
		local dist = (entities[i].Position - pos):LengthSquared()
		if dist < closestDist and not entities[i]:ToPlayer():IsCoopGhost() then
			closestDist = dist
			closestEnt = entities[i]
		end
	end

	return closestEnt
end





return Finds