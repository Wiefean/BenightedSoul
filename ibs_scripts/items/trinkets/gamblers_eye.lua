--赌徒之眼

local mod = Isaac_BenightedSoul

local game = Game()
local config = Isaac.GetItemConfig()

local GamblersEye = mod.IBS_Class.Trinket(mod.IBS_TrinketID.GamblersEye)

--接触时尝试重置道具
function GamblersEye:PrePickupCollision(pickup, other)
	if pickup.SubType == 668 then return end --忽略爸条
	if pickup.Wait > 0 then return end
	local player = other:ToPlayer()
	if not player or not player:HasTrinket(self.ID) then return end
	local quality = (player:GetTrinketMultiplier(self.ID) > 1 and 2) or 1

	local itemConfig = config:GetCollectible(pickup.SubType)		
	if itemConfig and itemConfig.Quality < quality and not itemConfig:HasTags(ItemConfig.TAG_QUEST) then 
		--移除或重置
		if player:GetTrinketRNG(self.ID):RandomInt(100) < 20 then
			pickup:TryRemoveCollectible()
		else
			local seed = self._Levels:GetRoomUniqueSeed()
			local pool = self._Pools:GetRoomPool(seed)
			local id = game:GetItemPool():GetCollectible(pool, true, seed, 25)
			pickup:Morph(5, 100, id, true, true)
		end
		pickup.Wait = 30

		return false
	end
end
GamblersEye:AddPriorityCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, -10, 'PrePickupCollision', 100)



return GamblersEye