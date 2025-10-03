--魂火之灵

local mod = Isaac_BenightedSoul

local Wisper = mod.IBS_Class.Item(mod.IBS_ItemID.Wisper)

Wisper.FamiliarVariant = mod.IBS_Familiar.Wisper.Variant

--拾取对应道具生成跟班
function Wisper:OnEvaluateCache(player, flag)
    if flag == CacheFlag.CACHE_FAMILIARS then
		local boxUse = player:GetEffects():GetCollectibleEffectNum(357) --朋友盒
		local num = player:GetCollectibleNum(self.ID)
		local numFamiliars = (num > 0 and num + boxUse) or 0
		player:CheckFamiliar(self.FamiliarVariant, numFamiliars, player:GetCollectibleRNG(self.ID), Isaac.GetItemConfig():GetCollectible(self.ID))
	end
end
Wisper:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, 'OnEvaluateCache')


return Wisper