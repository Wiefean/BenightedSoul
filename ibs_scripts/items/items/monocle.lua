--单片镜

local mod = Isaac_BenightedSoul

local Monocle = mod.IBS_Class.Item(mod.IBS_ItemID.Monocle)

local addItemLock

function Monocle:PostAddCollectible(item, charge, firstTime, solt, varData, player)
    if addItemLock then return end
    if not firstTime then return end
    addItemLock = true
    for times = 1, 2 do
        player:AddCollectible(self.ID)
    end
    addItemLock = nil
end
Monocle:AddCallback(ModCallbacks.MC_POST_ADD_COLLECTIBLE, 'PostAddCollectible', Monocle.ID)

function Monocle:OnEvalueateCache(player, flag)
	if player:HasCollectible(self.ID) then
        local num = player:GetCollectibleNum(self.ID)
		self._Stats:Range(player, 1.5 * num)
	end
end
Monocle:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, 'OnEvalueateCache', CacheFlag.CACHE_RANGE)

return Monocle