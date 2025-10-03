--地质学博士证

local mod = Isaac_BenightedSoul

local game = Game()

local GHD = mod.IBS_Class.Item(mod.IBS_ItemID.GHD)

--获得时生成倒塔
function GHD:OnGainItem(item, charge, first, slot, varData, player)
	if first then
		local room = game:GetRoom()
		local pos = room:FindFreePickupSpawnPosition(player.Position, 0, true)
		Isaac.Spawn(5, 300, 72, pos, Vector.Zero, nil)
	end
end
GHD:AddCallback(ModCallbacks.MC_POST_ADD_COLLECTIBLE, 'OnGainItem', GHD.ID)

--障碍物更新
function GHD:OnRockUpdate(gridEnt)
	if not PlayerManager.AnyoneHasCollectible(self.ID) then return end
	local gridType = gridEnt:GetType()

	--高亮标记石头
	if gridType == 4 or gridType == 22 then
		local spr = gridEnt:GetSprite()
		spr.Color.A = 3
	end	
end
GHD:AddCallback(ModCallbacks.MC_POST_GRID_ENTITY_ROCK_UPDATE, 'OnRockUpdate')

--游戏更新
function GHD:OnUpdate()
	if not PlayerManager.AnyoneHasCollectible(self.ID) then return end
	local room = game:GetRoom()
	local gridEnt = room:GetGridEntity(room:GetDungeonRockIdx())
	if gridEnt then
		local spr = gridEnt:GetSprite()
		spr.Color.A = 3	
	end
end
GHD:AddCallback(ModCallbacks.MC_POST_UPDATE, 'OnUpdate')

--是否为障碍物
local function IsObstacle(gridType)
	if gridType >= 2 and gridType <= 6 then
		return true
	end
	if gridType == 11 or (gridType >= 22 and gridType <= 27) then
		return true
	end
	return false
end

--摧毁障碍物时触发
--[[AltRock
1罐子
2蘑菇
3头骨
4肉瘤
5水桶
]]
function GHD:OnRockDestory(gridEnt, gridType)
	if not IsObstacle(gridType) then return end
	if not PlayerManager.AnyoneHasCollectible(self.ID) then return end
	local pos = gridEnt.Position
	local rng = Isaac.GetPlayer(0):GetCollectibleRNG(self.ID)

	--30%硬币
	if rng:RandomInt(100) < 30 then
		Isaac.Spawn(5, 20, 0, pos, RandomVector(), nil)
	end
	
	--标记石头额外魂心
	if gridType == 4 or gridType == 22 then
		Isaac.Spawn(5, 10, 3, pos, RandomVector(), nil)
	end
	
	if gridType == 6 then
		local itemPool = game:GetItemPool()
		local altType = gridEnt:GetAltRockType(game:GetRoom():GetBackdropType())
	
		--罐子/水桶额外1硬币,10%饰品
		if altType == 1 or altType == 5 then
			Isaac.Spawn(5, 20, 0, pos, RandomVector(), nil)
			if rng:RandomInt(100) < 10 then
				Isaac.Spawn(5, 350, itemPool:GetTrinket(), pos, RandomVector(), nil)
			end
		elseif altType == 2 then --蘑菇20%药丸
			if rng:RandomInt(100) < 20 then
				Isaac.Spawn(5, 70, itemPool:GetPill(rng:Next()), pos, RandomVector(), nil)
			end
		elseif altType == 3 then --头骨15%卡牌
			if rng:RandomInt(100) < 15 then
				Isaac.Spawn(5, 300, itemPool:GetCard(rng:Next(), true, true, false), pos, RandomVector(), nil)
			end		
		elseif altType == 4 then --肉瘤半红心
			Isaac.Spawn(5, 10, 2, pos, RandomVector(), nil)
		end
	end
end
GHD:AddCallback(ModCallbacks.MC_POST_GRID_ROCK_DESTROY, 'OnRockDestory')


return GHD