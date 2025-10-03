--AKEY47

local mod = Isaac_BenightedSoul

local AKEY47 = mod.IBS_Class.Item(mod.IBS_ItemID.AKEY47)

AKEY47.FamiliarVariant = mod.IBS_Familiar.AKEY47.Variant

--生成
function AKEY47:OnEvaluateCache(player, flag)
    if flag == CacheFlag.CACHE_FAMILIARS then
		local num = player:GetCollectibleNum(self.ID)
		if num > 1 then num = 1 end
		player:CheckFamiliar(self.FamiliarVariant, num, player:GetCollectibleRNG(self.ID), Isaac.GetItemConfig():GetCollectible(self.ID))
	end
end
AKEY47:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, 'OnEvaluateCache')


return AKEY47