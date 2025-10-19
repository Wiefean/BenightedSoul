--我过

local mod = Isaac_BenightedSoul
local IBS_PlayerID = mod.IBS_PlayerID
local Damage = mod.IBS_Class.Damage()

local MyFault = mod.IBS_Class.Item(mod.IBS_ItemID.MyFault)

local sfx = SFXManager()

--血波
function MyFault:BloodWave(dmg, pos, spawner, range)
	for _,target in pairs(Isaac.FindInRadius(pos, range, EntityPartition.ENEMY)) do
		if self._Ents:IsEnemy(target, true) then				
			target.HitPoints = target.HitPoints - dmg
			if target.HitPoints <= 0 then
				target:Kill()
			end
			target:SetBossStatusEffectCooldown(0)
			target:AddBleeding(EntityRef(spawner), 240)
			if target:GetBleedingCountdown() < 240 then
				target:SetBleedingCountdown(240)
			end
		end
	end
	
	--特效
	for subType = 3,4 do
		local effect = Isaac.Spawn(1000,16, subType, pos, Vector.Zero, spawner)
	end
	sfx:Play(SoundEffect.SOUND_DEATH_BURST_LARGE, 0.5, 0, false, 1.3)
end

--触发效果
function MyFault:TriggerEffect(player)
	--犹大长子权
	if player:HasCollectible(59) then
		player:SetMinDamageCooldown(60)
	else	
		player:SetMinDamageCooldown(30)
	end

	local dmg = player.Damage * 2
	local range = 80

	for _,target in pairs(Isaac.FindInRadius(player.Position, range, EntityPartition.ENEMY)) do
		if self._Ents:IsEnemy(target, true) and target:HasEntityFlags(EntityFlag.FLAG_BLEED_OUT) then	
			self:BloodWave(dmg, target.Position, player, range)
			target:SetBleedingCountdown(0)
		end
	end
	
	self:BloodWave(dmg, player.Position, player, range)
end

--使用
function MyFault:OnUse(item, rng, player, flag, slot)
	self:TriggerEffect(player, true, true)
	return {ShowAnim = false, Discharge = true}
end
MyFault:AddCallback(ModCallbacks.MC_USE_ITEM, 'OnUse', MyFault.ID)

--清理魂火
function MyFault:CleanWisps()
	for _,wisp in pairs(Isaac.FindByType(3,206, self.ID)) do
		wisp:Remove()	
	end
end
MyFault:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, 'CleanWisps')


--昧化夏娃长子权,在即将受伤时生效
function MyFault:PrePlayerTakeDMG(player, dmg, flag, source)
	if dmg <= 0 then return end
	if not Damage:IsPenalt(player, flag, source) then return end
	if player:GetPlayerType() ~= IBS_PlayerID.BEve then return end
	if not player:HasCollectible(619) then return end
	
	for slot = 0,2 do
		if player:GetActiveItem(slot) == (self.ID) then
			local discharge = 90
			if player:HasCollectible(116) then discharge = 45 end --9伏特

			--成功消耗充能才触发效果
			if self._Players:DischargeTimedSlot(player, slot, discharge) then
				self:TriggerEffect(player, true, true)
				return false
			end
		end
	end	
end
MyFault:AddPriorityCallback(ModCallbacks.MC_PRE_PLAYER_TAKE_DMG, -200, 'PrePlayerTakeDMG')


return MyFault
