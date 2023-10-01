--查找实体相关函数

local mod = Isaac_BenightedSoul
local Ents = mod.IBS_Lib.Ents

local Finds = {}


--最近的敌人
--(可选是否包括无敌的敌人,友好敌人,忽略Boss)
function Finds:ClosestEnemy(pos, includeInvulnerable, includeFriendly, ignoreBoss)
	local entities = Isaac.GetRoomEntities()
	local closestEnt = nil
	local closestDist = 2^32

	for i = 1, #entities do
		if Ents:IsEnemy(entities[i], includeInvulnerable, includeFriendly, ignoreBoss) then
			local dist = (entities[i].Position - pos):LengthSquared()
			if dist < closestDist then
				closestDist = dist
				closestEnt = entities[i]
			end
		end
	end

	return closestEnt
end


--最近的道具(不包括空底座)
function Finds:ClosestCollectible(pos)
	local entities = Isaac.FindByType(5,100)
	local closestEnt = nil
	local closestDist = 2^32

	for i = 1, #entities do
		local dist = (entities[i].Position - pos):LengthSquared()
		if entities[i].SubType ~= 0 and dist < closestDist then
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

--最近的实体(无限制条件)
function Finds:ClosestEntity(pos, type, variant, subType)
	local entities = Isaac.FindByType(type or -1, variant or -1, subType or -1)
	local closestEnt = nil
	local closestDist = 2^32

	for i = 1, #entities do
		local dist = (entities[i].Position - pos):LengthSquared()
		if dist < closestDist then
			closestDist = dist
			closestEnt = entities[i]
		end
	end

	return closestEnt
end



return Finds