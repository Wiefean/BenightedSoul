--纸质硬币

local mod = Isaac_BenightedSoul

local game = Game()
local config = Isaac.GetItemConfig()

local PaperPenny = mod.IBS_Class.Trinket(mod.IBS_TrinketID.PaperPenny)

--获取随机书主动的ID
function PaperPenny:GetBookActiveID(seed)
	seed = seed or 1
	local result = 33
	local cache = {}

	for id = 1, config:GetCollectibles().Size do
		local itemConfig = config:GetCollectible(id)
		if itemConfig and itemConfig:IsAvailable() and (itemConfig.Type == ItemType.ITEM_ACTIVE) and itemConfig:HasTags(ItemConfig.TAG_BOOK) and not itemConfig:HasTags(ItemConfig.TAG_QUEST) then
			table.insert(cache, id)
		end
	end	

	--抽取一个
	if #cache > 0 then
		result = cache[RNG(seed):RandomInt(1, #cache)] or 33
	end

	return result
end

--拾取硬币时
function PaperPenny:OnCoinCollision(pickup, other)
	local player = other:ToPlayer()
	if player and player:HasTrinket(self.ID) and self._Pickups:CanCollect(pickup, player) then
		local rng = RNG(pickup.InitSeed)
		local value = pickup:GetCoinValue()
		
		for i = 1,player:GetTrinketMultiplier(self.ID) do
			if rng:RandomInt(100) < 15 + 5*value then
				local id = self:GetBookActiveID(pickup.InitSeed)
				player:AddWisp(id, player.Position, true)
			end
		end
	end	
end
PaperPenny:AddPriorityCallback(ModCallbacks.MC_POST_PICKUP_COLLISION, CallbackPriority.LATE, 'OnCoinCollision', PickupVariant.PICKUP_COIN)

return PaperPenny