--昧az圣光标记

local mod = Isaac_BenightedSoul
local IBS_EffectID = mod.IBS_EffectID

local BAzazelCrackTheSkyMark = mod.IBS_Class.Effect{
	Variant = IBS_EffectID.BAzazelCrackTheSkyMark.Variant,
	SubType = IBS_EffectID.BAzazelCrackTheSkyMark.SubType,
	Name = {zh = '昧az圣光标记', en = 'BAzazel Crack The Sky Mark'}
}

BAzazelCrackTheSkyMark.Duration = 5 * 30
BAzazelCrackTheSkyMark.DamageMultiplier = 2
BAzazelCrackTheSkyMark.DamageBonus = 3
BAzazelCrackTheSkyMark.NonHolyDamageBonus = 0.3

--印记扩展由全场任意持有长子权的昧az启用,不限于施加标记的玩家
function BAzazelCrackTheSkyMark:GetBirthrightBAzazel()
	local game = Game()
	for i = 0, game:GetNumPlayers() - 1 do
		local player = Isaac.GetPlayer(i)
		if player:GetPlayerType() == mod.IBS_PlayerID.BAzazel
		and player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT) then
			return player
		end
	end
	return nil
end

function BAzazelCrackTheSkyMark:GetMarkData(effect)
	local data = self._Ents:GetTempData(effect)
	data.BAzazelCrackTheSkyMark = data.BAzazelCrackTheSkyMark or {
		Time = self.Duration,
		Removing = false,
	}
	return data.BAzazelCrackTheSkyMark
end

--目标与标记互相引用;失效引用不参与刷新或伤害判定
function BAzazelCrackTheSkyMark:GetStoredMark(target)
	if not target then return nil end
	local effect = self._Ents:GetTempData(target).BAzazelCrackTheSkyMarkEffect
	if effect and effect:Exists() and not effect:IsDead() then
		return effect
	end
	return nil
end

function BAzazelCrackTheSkyMark:GetMark(target)
	local effect = self:GetStoredMark(target)
	if not effect or self:GetMarkData(effect).Removing then return nil end
	return effect
end

function BAzazelCrackTheSkyMark:GetPosition(target)
	return target.Position + Vector(0, -target.Size * 3 - 10)
end

function BAzazelCrackTheSkyMark:ClearTargetReference(effect)
	local target = self:GetMarkData(effect).Target
	if not target then return end
	local targetData = self._Ents:GetTempData(target)
	if self._Ents:IsTheSame(targetData.BAzazelCrackTheSkyMarkEffect, effect) then
		targetData.BAzazelCrackTheSkyMarkEffect = nil
	end
end

--重复施加刷新持续时间;若正在淡出,则重新播放Spawn并恢复标记
--长子名分额外在敌人位置落下一道圣光,首次施加标记时不触发
function BAzazelCrackTheSkyMark:Apply(target, spawner, sourceTear)
	if not target then return nil end
	local effect = self:GetStoredMark(target)
	if effect then
		local data = self:GetMarkData(effect)
		data.Time = self.Duration
		if data.Removing then
			data.Removing = false
			effect:GetSprite():Play('Spawn', true)
		end

		local birthright = self:GetBirthrightBAzazel()
		if birthright then
			local player = self._Ents:GetSourcePlayer(spawner) or birthright
			local damage = player.Damage
			if sourceTear then
				damage = mod.IBS_Tear.InvertedCrossTear:GetHolyLightDamage(sourceTear, player)
			end
			mod.IBS_Effect.BAzazelCrackTheSky:Spawn(target.Position, player, damage, 1)
		end
		return effect
	end

	local entity = Isaac.Spawn(EntityType.ENTITY_EFFECT, self.Variant, self.SubType,
		self:GetPosition(target), Vector.Zero, spawner or target)
	effect = entity and entity:ToEffect()
	if not effect then return nil end

	local data = self:GetMarkData(effect)
	data.Target = target
	data.Time = self.Duration
	data.Removing = false
	self._Ents:GetTempData(target).BAzazelCrackTheSkyMarkEffect = effect
	return effect
end

function BAzazelCrackTheSkyMark:StartRemove(effect)
	local data = self:GetMarkData(effect)
	if data.Removing then return end
	data.Removing = true
	data.Time = 0
	effect:GetSprite():Play('Remove', true)
end

function BAzazelCrackTheSkyMark:OnInit(effect)
	effect.DepthOffset = 99
	effect:GetSprite():Play('Spawn', true)
end
BAzazelCrackTheSkyMark:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, 'OnInit', BAzazelCrackTheSkyMark.Variant)

function BAzazelCrackTheSkyMark:OnUpdate(effect)
	local data = self:GetMarkData(effect)
	local spr = effect:GetSprite()

	--开始Remove即失去增伤效果,保留短暂淡出动画后再移除实体
	if data.Removing then
		if spr:IsFinished('Remove') then
			self:ClearTargetReference(effect)
			effect:Remove()
		end
		return
	end

	local target = data.Target
	if not target or not target:Exists() or target:IsDead() then
		self:StartRemove(effect)
		return
	end

	effect.Velocity = Vector.Zero
	if spr:IsFinished('Spawn') then
		spr:Play('Idle', true)
	end

	data.Time = math.max(0, (data.Time or self.Duration) - 1)
	if data.Time <= 0 then
		self:StartRemove(effect)
	end
end
BAzazelCrackTheSkyMark:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, 'OnUpdate', BAzazelCrackTheSkyMark.Variant)

--在NPC渲染阶段同步头顶位置,避免逻辑帧与渲染帧之间出现位置偏差
function BAzazelCrackTheSkyMark:OnNPCRender(npc)
	local effect = self:GetStoredMark(npc)
	if effect then
		effect.Position = self:GetPosition(npc)
	end
end
BAzazelCrackTheSkyMark:AddCallback(ModCallbacks.MC_POST_NPC_RENDER, 'OnNPCRender')

function BAzazelCrackTheSkyMark:IsCustomLightKnife(entity)
	if not entity or not entity:Exists() then return false end
	local knifeID = mod.IBS_KnifeID.BAzazelLightKnife
	if entity.Type == EntityType.ENTITY_KNIFE and entity.Variant == knifeID.Variant
	and entity.SubType == knifeID.SubType then
		local parent = entity.Parent
		return parent ~= nil and parent:Exists() and parent.Type == EntityType.ENTITY_EFFECT
		and parent.Variant == IBS_EffectID.BAzazelCrackTheSky.Variant
	end
	return false
end

--只识别原版圣光、BigLight以及昧az圣光本体或透明刀,不放大其他来源伤害
function BAzazelCrackTheSkyMark:IsHolyLightSource(entity)
	if not entity or not entity:Exists() then return false end
	if entity.Type == EntityType.ENTITY_EFFECT then
		return entity.Variant == EffectVariant.CRACK_THE_SKY
		or entity.Variant == IBS_EffectID.BAzazelCrackTheSky.Variant
		or entity.Variant == IBS_EffectID.BigLight.Variant
	end
	return self:IsCustomLightKnife(entity)
end

function BAzazelCrackTheSkyMark:GetMarkedDamage(target, damage)
	return damage * self.DamageMultiplier + self.DamageBonus
end

--圣光伤害及全场长子权沿用原增幅;无长子权时非圣光伤害附加施加者30%面板
function BAzazelCrackTheSkyMark:OnTakeDamage(entity, amount, flag, source, countdown)
	if amount <= 0 or not self._Ents:IsEnemy(entity) then return end
	local mark = self:GetMark(entity)
	if not mark then return end

	local sourceEntity = source and source.Entity
	--自定义透明刀在恢复Scale伤害时统一结算标记,此处跳过以避免重复放大
	if self:IsCustomLightKnife(sourceEntity) then return end

	local isHolyLight = self:IsHolyLightSource(sourceEntity)
	if isHolyLight or self:GetBirthrightBAzazel() then
		return {Damage = self:GetMarkedDamage(entity, amount)}
	end

	local owner = self._Ents:GetSourcePlayer(mark)
	local bonus = owner and owner:Exists() and owner.Damage * self.NonHolyDamageBonus or 0
	return {Damage = amount + bonus}
end
BAzazelCrackTheSkyMark:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, 'OnTakeDamage')

return BAzazelCrackTheSkyMark
