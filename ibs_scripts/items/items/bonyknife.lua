--骨刀

local mod = Isaac_BenightedSoul
local IBS_Item = mod.IBS_Item
local IBS_Sound = mod.IBS_Sound
local Ents = mod.IBS_Lib.Ents

local sfx = SFXManager()

--使用
local function OnUse(_,item, rng, player, flag, slot)
	local effect = player:GetEffects()
	effect:AddCollectibleEffect(CollectibleType.COLLECTIBLE_MOMS_KNIFE)
	effect:AddCollectibleEffect(IBS_Item.bonyknife)
	
	--彼列书
	if player:HasCollectible(59) then
		effect:AddCollectibleEffect(CollectibleType.COLLECTIBLE_FIRE_MIND)
		player:RemoveCostume(Isaac.GetItemConfig():GetCollectible(CollectibleType.COLLECTIBLE_FIRE_MIND))
	end
	
	return true
end
mod:AddCallback(ModCallbacks.MC_USE_ITEM, OnUse, IBS_Item.bonyknife)

--替换妈刀贴图
local function ReplaceKnifeSprite(_,knife)
    if knife.FrameCount < 2 then
		local player = Ents:IsSpawnerPlayer(knife, true)
	
		if player and player:GetEffects():HasCollectibleEffect(IBS_Item.bonyknife) then
			local spr = knife:GetSprite()
			
			if (knife.Variant == 0) then
				spr:ReplaceSpritesheet(0, "gfx/ibs/knives/bonyknife.png")
				spr:LoadGraphics()
			elseif (knife.Variant == 2) then
				spr:ReplaceSpritesheet(0, "gfx/ibs/knives/bonyknife_scythe.png")
				spr:LoadGraphics()
			end
		end
    end
end
mod:AddCallback(ModCallbacks.MC_POST_KNIFE_UPDATE, ReplaceKnifeSprite)

--魂火熄灭
local function WispKilled(_,familiar)
    if (familiar.Variant == FamiliarVariant.WISP and familiar.SubType == (IBS_Item.bonyknife)) then
		local player = Ents:IsSpawnerPlayer(familiar)
		
		if player then
			local effect = player:GetEffects()
			effect:AddCollectibleEffect(CollectibleType.COLLECTIBLE_MOMS_KNIFE)
			effect:AddCollectibleEffect(IBS_Item.bonyknife)
		end
    end
end
mod:AddCallback(ModCallbacks.MC_POST_ENTITY_KILL, WispKilled, EntityType.ENTITY_FAMILIAR)

--攻击下降
mod:AddPriorityCallback(ModCallbacks.MC_EVALUATE_CACHE, CallbackPriority.LATE, function(_,player,flag)
	if player:GetEffects():HasCollectibleEffect(IBS_Item.bonyknife) then
		if flag == CacheFlag.CACHE_DAMAGE then
			player.Damage = player.Damage * 0.75
		end
	end	
end)
