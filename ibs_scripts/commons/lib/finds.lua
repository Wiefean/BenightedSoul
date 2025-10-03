--查找实体相关函数

local mod = Isaac_BenightedSoul
local Ents = mod.IBS_Lib.Ents

local game = Game()

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

	return (closestEnt and closestEnt:ToPickup()) or nil
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

	return (closestEnt and closestEnt:ToPlayer()) or nil
end

--最近的实体(可附加限制条件)
--(条件是一个返回true或false的函数,以实体为参数)
function Finds:ClosestEntity(pos, type, variant, subType, condition)
	local entities = Isaac.FindByType(type or -1, variant or -1, subType or -1)
	local closestEnt = nil
	local closestDist = 2^32

	for i = 1, #entities do
		local dist = (entities[i].Position - pos):LengthSquared()
		if (dist < closestDist) and (not condition or condition(entities[i])) then
			closestDist = dist
			closestEnt = entities[i]
		end
	end

	return closestEnt
end

--实体表内最近的实体(可附加限制条件)
--(条件是一个返回true或false的函数,以实体为参数)
function Finds:ClosestEntityInTable(pos, Table, condition)
	local closestEnt = nil
	local closestDist = 2^32
	local key = nil

	for k,ent in pairs(Table) do
		local dist = (ent.Position - pos):LengthSquared()
		if (dist < closestDist) and (not condition or condition(ent)) then
			closestDist = dist
			closestEnt = ent
			key = k
		end
	end

	return closestEnt,key
end


--最近的门
function Finds:ClosestDoor(pos)
	local room = game:GetRoom()
	local closest = nil
	local closestDist = 2^32

	for slot = 0,7 do
		local door = room:GetDoor(slot)
		if door then
			local dist = (door.Position - pos):LengthSquared()
			if (dist < closestDist) then
				closestDist = dist
				closest = door
			end
		end
	end

	return closest
end


return Finds