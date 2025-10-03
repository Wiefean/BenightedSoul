--日寄

local mod = Isaac_BenightedSoul

local Diecry = mod.IBS_Class.Item(mod.IBS_ItemID.Diecry)


--使用
function Diecry:OnUse(item, rng, player, flag, slot)
	local effect = player:GetEffects()
	effect:AddCollectibleEffect(CollectibleType.COLLECTIBLE_SAD_ONION, false)
	
	--碎照片,仅用于装扮
	if not effect:HasCollectibleEffect(CollectibleType.COLLECTIBLE_TORN_PHOTO) then	
		effect:AddCollectibleEffect(CollectibleType.COLLECTIBLE_TORN_PHOTO)
	end
	
	--彼列书
	if player:HasCollectible(59) then
		effect:AddCollectibleEffect(CollectibleType.COLLECTIBLE_SAD_ONION, false)
	end

	return true
end
Diecry:AddCallback(ModCallbacks.MC_USE_ITEM, 'OnUse', Diecry.ID)


return Diecry
