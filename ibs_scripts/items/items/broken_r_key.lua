--损坏的R键

local mod = Isaac_BenightedSoul
local Pools = mod.IBS_Lib.Pools

local game = Game()
local config = Isaac.GetItemConfig()

local BrokenRKey = mod.IBS_Class.Item(mod.IBS_ItemID.BrokenRKey)

--获取准备移除的道具列表
function BrokenRKey:GetItemsToRemove(player, seed)
	local result = {}
	local cache = {}
	local count = game:GetLevel():GetStage()

	for id,num in pairs(player:GetCollectiblesList()) do
		if num > 0 then
			local itemConfig = config:GetCollectible(id)
			if itemConfig and itemConfig.Type ~= 3 and not itemConfig:HasTags(ItemConfig.TAG_QUEST) then	
				table.insert(cache, id)
			end
		end
	end
			
	--打乱顺序
	self:ShuffleTable(cache, seed)
	
	for _,id in ipairs(cache) do
		table.insert(result, id)
		
		count = count - 1
		if count <= 0 then
			break
		end
	end
	
	return result
end

--使用效果
function BrokenRKey:OnUse(item, rng, player, flags, slot)
	if (flags & UseFlag.USE_OWNED > 0 or flags & UseFlag.USE_VOID > 0) and (flags & UseFlag.USE_CARBATTERY <= 0) then
		local room = game:GetRoom()
		local itemPool = game:GetItemPool()
		local virtue = player:HasCollectible(584) and (flags & UseFlag.USE_NOANIM <= 0 or flags & UseFlag.USE_ALLOWWISPSPAWN > 0)
		
		game.TimeCounter = 0
		
		--移除道具并生成道具
		for _,id in ipairs(self:GetItemsToRemove(player, rng:Next())) do
			local seed = rng:Next()
			local pos = room:FindFreePickupSpawnPosition(player.Position, 1, true)
			local pool = itemPool:GetPoolForRoom(RoomType.ROOM_ERROR, seed)
			local pickup = Isaac.Spawn(5, 100, id, pos, Vector.Zero, nil):ToPickup()
			pickup:Morph(5, 100, id, true, true, true) --防止被某些特殊效果重置
			player:RemoveCollectible(id, true)

			--美德书
			if virtue and RNG(seed):RandomInt(100) < 28 then
				pool = ItemPoolType.POOL_ANGEL
			end

			--添加道具进入轮换
			local id = itemPool:GetCollectible(pool, false, seed)
			if id == 0 then
				id = itemPool:GetCollectible(0, false, seed)
			end
			pickup:AddCollectibleCycle(id)
		end
		
		--彼列书
		if player:HasCollectible(59) then
			player:AddCollectible(51)
		end
		
		local MAX = config:GetCollectibles().Size - 1
		for id = 1, MAX do
			local itemConfig = config:GetCollectible(id)
			if itemConfig then
				itemPool:ResetCollectible(id)
			end
		end		
		
		game:GetHUD():ShowFortuneText("???")
		
		return {ShowAnim = true, Remove = true}
	end
end
BrokenRKey:AddCallback(ModCallbacks.MC_USE_ITEM, 'OnUse', BrokenRKey.ID)



return BrokenRKey