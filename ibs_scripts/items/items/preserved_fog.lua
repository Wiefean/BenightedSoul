--腌制活雾

local mod = Isaac_BenightedSoul
local Pools = mod.IBS_Lib.Pools
local IBS_CallbackID = mod.IBS_CallbackID
local AbandonedItem = mod.IBS_Effect.AbandonedItem

local game = Game()
local config = Isaac.GetItemConfig()
local sfx = SFXManager()

local PreservedFog = mod.IBS_Class.Item(mod.IBS_ItemID.PreservedFog)

--获取品质最低的道具
function PreservedFog:GetLowestQualityItem(seed)
	local itemPool = game:GetItemPool()
	local lowest = 3
	local lastLowest = 3
	local result = {}

	local pool = self._Pools:GetRoomPool(self._Levels:GetRoomUniqueSeed())
	for _,v in ipairs(itemPool:GetCollectiblesFromPool(pool)) do
		local id = v.itemID
		if itemPool:HasCollectible(id) then
			local itemConfig = config:GetCollectible(id)
			if itemConfig and itemConfig:IsAvailable() and not itemConfig:HasTags(ItemConfig.TAG_QUEST) then
				if itemConfig.Quality < lowest then
					lowest = itemConfig.Quality
					
					--如果比之前的品质更低,重置表
					if lowest < lastLowest then
						for key,value in pairs(result) do
							result[key] = nil
						end
					end
					lastLowest = lowest
					
					table.insert(result, id)
				end
			end	
		end
	end

	--抽取一个
	if #result > 0 then
		return result[RNG(seed):RandomInt(1, #result)] or result[1]
	end
	
	--默认返回早餐
	return 25
end

--拾取道具
function PreservedFog:OnPickItem(player, item, touched)
	if touched then return end 
	if player:HasCollectible(self.ID) or item == self.ID then
		local itemPool = game:GetItemPool()
	
		for i = 1,3 do
			local rng = player:GetCollectibleRNG(self.ID)
			local id = self:GetLowestQualityItem(rng:Next())
			local itemConfig = config:GetCollectible(id)

			if itemConfig and itemConfig.GfxFileName then
				itemPool:RemoveCollectible(id)
				
				--特效
				if itemConfig.GfxFileName then
					AbandonedItem:Spawn(player.Position, itemConfig.GfxFileName, RandomVector() * 0.1 * math.random(10, 15))
				end
			end
		end
		
		sfx:Play(267)
	end
end
PreservedFog:AddPriorityCallback(IBS_CallbackID.PICK_COLLECTIBLE, CallbackPriority.LATE, 'OnPickItem')

--第一个道具变成黑符文
function PreservedFog:OnPickupInit(pickup)
	if not PlayerManager.AnyoneHasCollectible(self.ID) then return end
	local data = self:GetIBSData("level")
	
	self:DelayFunction(function()	
		if not data.PreservedFogTriggered then
			Isaac.Spawn(5, 300, 41, pickup.Position, Vector.Zero, nil)
			Isaac.Spawn(1000, 15, 0, pickup.Position, Vector.Zero, nil)
			pickup:Remove()
			data.PreservedFogTriggered = true
		end
	end, 1)
end
PreservedFog:AddCallback(ModCallbacks.MC_POST_PICKUP_INIT, 'OnPickupInit', 100)

return PreservedFog