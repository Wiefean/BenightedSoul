--我过

local mod = Isaac_BenightedSoul
local IBS_PlayerID = mod.IBS_PlayerID
local Damage = mod.IBS_Class.Damage()
local EveBaby = mod.IBS_Familiar.EveBaby

local MyFault = mod.IBS_Class.Item(mod.IBS_ItemID.MyFault)

local sfx = SFXManager()

--查找目标
function MyFault:FindTargets(pos, range)
	local result = {}

	for _,ent in ipairs(Isaac.GetRoomEntities()) do
		if ent.Position:Distance(pos) <= range + ent.Size then
			if self._Ents:IsEnemy(ent, true) then
				table.insert(result, ent)
			end
		end
	end
		
	return result
end

--血波
function MyFault:BloodWave(dmg, pos, spawner, range)
	for _,target in ipairs(self:FindTargets(pos, range)) do
		if self._Ents:LoseHP(target, dmg, true) then
			target:SetBossStatusEffectCooldown(0)
			target:AddBleeding(EntityRef(spawner), 240)
			if target:GetBleedingCountdown() < 240 then
				target:SetBleedingCountdown(240)
			end
		end
	end
	
	--清除敌弹
	for _,ent in ipairs(Isaac.FindInRadius(pos, range + 10, EntityPartition.BULLET)) do
		local proj = ent:ToProjectile()
		if proj and not proj:HasProjectileFlags(ProjectileFlags.CANT_HIT_PLAYER) then
			proj:Die()
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
	local range = 70

	for _,target in ipairs(self:FindTargets(player.Position, range)) do
		if target:HasEntityFlags(EntityFlag.FLAG_BLEED_OUT) then	
			self:BloodWave(dmg, target.Position, player, range)
			target:SetBleedingCountdown(0)
		end
	end
	
	self:BloodWave(dmg, player.Position, player, range)
	
	for _,ent in pairs(Isaac.FindByType(3, EveBaby.Variant, EveBaby.SubType.Single)) do
		for _,target in ipairs(self:FindTargets(ent.Position, range)) do
			if target:HasEntityFlags(EntityFlag.FLAG_BLEED_OUT) then	
				self:BloodWave(dmg, target.Position, player, range)
				target:SetBleedingCountdown(0)
			end
		end
		self:BloodWave(dmg, ent.Position, player, range)
	end
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
