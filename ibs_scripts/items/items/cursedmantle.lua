--诅咒屏障

local mod = Isaac_BenightedSoul
local IBS_Callback = mod.IBS_Callback
local IBS_Item = mod.IBS_Item
local Players = mod.IBS_Lib.Players

local config = Isaac.GetItemConfig()
local sfx = SFXManager()

--直接使用无效
mod:AddCallback(ModCallbacks.MC_USE_ITEM, function()
	return {ShowAnim = false, Discharge = false}	
end, IBS_Item.cmantle)

--在即将受伤时生效
local function PreTakeDMG(_,ent, amount, flag, source)
	local player = ent:ToPlayer()
	if player then
		for slot = 0,2 do
			if player:GetActiveItem(slot) == (IBS_Item.cmantle) then
				local discharge = 2
				if player:HasCollectible(116) then discharge = discharge - 1 end --9伏特
				
				--成功消耗充能才触发效果
				if Players:DischargeSlot(player, slot, discharge, false, false) then
					player:SetMinDamageCooldown(66)
					player:UseActiveItem(705, false, false)
					
					--车载电池兼容
					if player:HasCollectible(356) then
						player:UseActiveItem(705)
					end
					
					--比列书兼容
					if player:HasCollectible(59) then
						player:UseActiveItem(34, false, false)
					end			
					
					--5毛钱特效
					local effect = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF02, 11, player.Position, Vector(0,0), player):ToEffect()
					effect:FollowParent(player)
					effect.Timeout = 66
					effect.SpriteScale = player.SpriteScale
					effect:GetSprite().Color = Color(0,0,0,1)
					effect:Update()
				
					sfx:Play(SoundEffect.SOUND_HOLY_MANTLE, 1, 2, false, 0.666)
					
					return false
				end
			end
		end	
	end
end
mod:AddPriorityCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, 10, PreTakeDMG)

--占据第一主动槽
local function Occupation(_,pickup, other)
	local player = other:ToPlayer()
	if player and (pickup.SubType > 0) then
		local itemConfig = config:GetCollectible(pickup.SubType) 
		local active = itemConfig and (itemConfig.Type == ItemType.ITEM_ACTIVE)
		
		if active then
			if player:GetActiveItem(0) == (IBS_Item.cmantle) and not (player:HasCollectible(260) or player:HasCollectible(584)) then
				return false
			end
		end
	end	
end
mod:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, Occupation, PickupVariant.PICKUP_COLLECTIBLE)

