--诅咒屏障

local mod = Isaac_BenightedSoul
local Damage = mod.IBS_Class.Damage()

local game = Game()
local config = Isaac.GetItemConfig()

local CursedMantle = mod.IBS_Class.Item(mod.IBS_ItemID.CursedMantle)

--尝试使用(用于提示可用)
function CursedMantle:OnTryUse(slot, player)
	return 2
end
CursedMantle:AddCallback(ModCallbacks.MC_PLAYER_GET_ACTIVE_MIN_USABLE_CHARGE, 'OnTryUse', CursedMantle.ID)


--直接使用无效
function CursedMantle:OnUse()
	return {ShowAnim = false, Discharge = false}
end
CursedMantle:AddCallback(ModCallbacks.MC_USE_ITEM, 'OnUse', CursedMantle.ID)

--是否应该保护
function CursedMantle:ShouldProtect(player, flag, source)
	return Damage:CanHurtPlayer(player, flag, source) and not Damage:IsPlayerSelfDamage(player, flag, source)
end

--在即将受伤时生效
function CursedMantle:PrePlayerTakeDMG(player, dmg, flag, source)
	if dmg <= 0 then return end
	if not self:ShouldProtect(player, flag, source) then return end
	
	for slot = 0,2 do
		if player:GetActiveItem(slot) == (self.ID) then
			local discharge = 2
			if player:HasCollectible(116) then discharge = discharge - 1 end --9伏特

			--成功消耗充能才触发效果
			if self._Players:DischargeSlot(player, slot, discharge) then
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

				SFXManager():Play(SoundEffect.SOUND_HOLY_MANTLE, 1, 2, false, 0.666)

				--尝试恢复上限骰(东方mod)
				if slot ~= 2 then
					mod.IBS_Compat.THI:TryRestoreDice(player, CursedMantle.ID, slot)
				end

				return false
			end
		end
	end	
end
CursedMantle:AddCallback(ModCallbacks.MC_PRE_PLAYER_TAKE_DMG, 'PrePlayerTakeDMG')

--占据第一主动槽(美德书或黑蜡烛可避免)
function CursedMantle:Occupation(pickup, other)
	local player = other:ToPlayer()
	if player and (pickup.SubType > 0) then
		local itemConfig = config:GetCollectible(pickup.SubType) 
		local active = itemConfig and (itemConfig.Type == ItemType.ITEM_ACTIVE)
		
		if active then
			if player:GetActiveItem(0) == self.ID and not (player:HasCollectible(260) or player:HasCollectible(584)) then
				return false
			end
		end
	end	
end
CursedMantle:AddPriorityCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, 666, 'Occupation', PickupVariant.PICKUP_COLLECTIBLE)

--虚空吸收诅咒屏障后获得神圣屏障效果
function CursedMantle:VoidMantle()
	for i = 0, game:GetNumPlayers() -1 do
		local player = Isaac.GetPlayer(i)
		local num = self._Players:GetVoidCollectibleNum(player, self.ID)

		if num > 0 then
			player:GetEffects():AddCollectibleEffect(313, true, num)
		end
	end	
end
CursedMantle:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, 'VoidMantle')


return CursedMantle