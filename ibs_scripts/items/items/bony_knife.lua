--骨刀

local mod = Isaac_BenightedSoul

local BonyKnife = mod.IBS_Class.Item(mod.IBS_ItemID.BonyKnife)


--使用
function BonyKnife:OnUse(item, rng, player, flag, slot)
	local effect = player:GetEffects()
	effect:AddCollectibleEffect(CollectibleType.COLLECTIBLE_MOMS_KNIFE)
	effect:AddCollectibleEffect(self.ID)
	
	--彼列书
	if player:HasCollectible(59) then
		effect:AddCollectibleEffect(CollectibleType.COLLECTIBLE_FIRE_MIND, false)
	end

	return true
end
BonyKnife:AddCallback(ModCallbacks.MC_USE_ITEM, 'OnUse', BonyKnife.ID)

--替换妈刀贴图
function BonyKnife:OnKnifeUpdate(knife)
    if knife.FrameCount < 2 then
		local player = self._Ents:IsSpawnerPlayer(knife, true)
	
		if player and player:GetEffects():HasCollectibleEffect(self.ID) then
			local spr = knife:GetSprite()

			if (knife.Variant == 0) then
				spr:ReplaceSpritesheet(0, "gfx/ibs/knives/BonyKnife.png")
				spr:LoadGraphics()
			elseif (knife.Variant == 2) then
				spr:ReplaceSpritesheet(0, "gfx/ibs/knives/bonyknife_scythe.png")
				spr:LoadGraphics()
			end
		end
    end
end
BonyKnife:AddCallback(ModCallbacks.MC_POST_KNIFE_UPDATE, 'OnKnifeUpdate')

--魂火熄灭
function BonyKnife:OnWispKilled(familiar)
    if (familiar.Variant == FamiliarVariant.WISP and familiar.SubType == (self.ID)) then
		local player = self._Ents:IsSpawnerPlayer(familiar)
		
		if player then
			local effect = player:GetEffects()
			effect:AddCollectibleEffect(CollectibleType.COLLECTIBLE_MOMS_KNIFE)
			effect:AddCollectibleEffect(self.ID)
		end
    end
end
BonyKnife:AddCallback(ModCallbacks.MC_POST_ENTITY_KILL, 'OnWispKilled', EntityType.ENTITY_FAMILIAR)

--攻击下降
function BonyKnife:OnEvaluateCache(player, flag)
	if player:GetEffects():HasCollectibleEffect(self.ID) then
		if flag == CacheFlag.CACHE_DAMAGE then
			player.Damage = player.Damage * 0.75
		end
	end	
end
BonyKnife:AddPriorityCallback(ModCallbacks.MC_EVALUATE_CACHE, CallbackPriority.LATE, 'OnEvaluateCache')


return BonyKnife
