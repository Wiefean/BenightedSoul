--紫电能量剑

local mod = Isaac_BenightedSoul

local Sword = mod.IBS_Class.Item(mod.IBS_ItemID.Sword)

Sword.FamiliarVariant = mod.IBS_Familiar.Sword.Variant


--生成
function Sword:OnEvaluateCache(player, flag)
    if flag == CacheFlag.CACHE_FAMILIARS then
		local boxUse = player:GetEffects():GetCollectibleEffectNum(357) --朋友盒
		local num = player:GetCollectibleNum(self.ID)
		local numFamiliars = (num > 0 and num + boxUse) or 0
		
		player:CheckFamiliar(self.FamiliarVariant, numFamiliars, player:GetCollectibleRNG(self.ID), Isaac.GetItemConfig():GetCollectible(self.ID))
	end
end
Sword:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, 'OnEvaluateCache')


return Sword