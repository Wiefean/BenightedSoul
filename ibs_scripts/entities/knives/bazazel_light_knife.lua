--昧az圣光透明刀;仅提供一帧伤害判定,不引用贴图

local mod = Isaac_BenightedSoul
local IBS_KnifeID = mod.IBS_KnifeID

local BAzazelLightKnife = mod.IBS_Class.Entity{
	Type = EntityType.ENTITY_KNIFE,
	Variant = IBS_KnifeID.BAzazelLightKnife.Variant,
	SubType = IBS_KnifeID.BAzazelLightKnife.SubType,
	Name = {zh = '昧az圣光透明刀', en = 'BAzazel Light Knife'}
}

BAzazelLightKnife.BaseRadius = 20 --一个网格为40像素,直径40即可覆盖一个网格
--距离倍率由引弹统一计算,透明刀不能以圣光父实体为原点再次进行原生距离结算
BAzazelLightKnife.SuppressedTearFlags = TearFlags.TEAR_SHRINK | TearFlags.TEAR_GROW
BAzazelLightKnife.MulliganInfo = {
	GuppyRollRange = 2,
	MulliganRollRange = 6,
}

function BAzazelLightKnife:Spawn(light, player)
	if not light then return nil end

	local entity = Isaac.Spawn(self.Type, self.Variant, self.SubType, light.Position, Vector.Zero, light)
	local knife = entity and entity:ToKnife()
	if not knife then return nil end

	knife.Parent = light
	knife.Size = self.BaseRadius * light.Scale
	if player then
		knife:AddTearFlags(player.TearFlags)
	end
	knife:ClearTearFlags(self.SuppressedTearFlags)
	--AddTearFlags后重新写入,并保留供受击回调覆盖原生刀固定结算的准确数值
	knife.CollisionDamage = light.CollisionDamage
	local data = self._Ents:GetTempData(knife)
	data.BAzazelLightDamage = light.CollisionDamage
	data.BAzazelLightPlayer = player
	return knife
end

--只按存活时间移除,不检测碰撞是否完成
function BAzazelLightKnife:OnUpdate(knife)
	local parent = knife.Parent
	local light = parent:ToEffect()
	if light and light:Exists() then
		knife.Position = light.Position
		knife.Size = self.BaseRadius * light.Scale
		knife:ClearTearFlags(self.SuppressedTearFlags)
		knife.CollisionDamage = light.CollisionDamage
		self._Ents:GetTempData(knife).BAzazelLightDamage = light.CollisionDamage
	end
	if knife.FrameCount >= 1 then
		knife:Remove()
	end
end
BAzazelLightKnife:AddCallback(ModCallbacks.MC_POST_KNIFE_UPDATE, 'OnUpdate', BAzazelLightKnife.SubType)

--猫套存在时覆盖虫群复击;两种效果都由刀实际造成伤害时触发
function BAzazelLightKnife:TrySpawnMulliganFly(player)
	if not player or not player:Exists() then return end

	local hasGuppy = player:HasPlayerForm(PlayerForm.PLAYERFORM_GUPPY)
	if not hasGuppy and not player:HasCollectible(CollectibleType.COLLECTIBLE_MULLIGAN) then return end

	local rngItem = CollectibleType.COLLECTIBLE_MULLIGAN
	local rollRange = self.MulliganInfo.MulliganRollRange
	if hasGuppy then
		rngItem = CollectibleType.COLLECTIBLE_GUPPYS_HEAD
		rollRange = self.MulliganInfo.GuppyRollRange
	end
	if player:GetCollectibleRNG(rngItem):RandomInt(rollRange) == 0 then
		player:AddBlueFlies(1, player.Position, nil)
	end
end

--原生刀碰撞会忽略已写入的CollisionDamage并重新结算;仅对本刀恢复圣光传入值
--标记增伤在此一并结算,标记模块会跳过本刀,避免覆盖或重复放大
function BAzazelLightKnife:OnTakeDamage(entity, amount, flag, source, countdown)
	local sourceEntity = source and source.Entity
	if not sourceEntity or sourceEntity.Type ~= EntityType.ENTITY_KNIFE
	or sourceEntity.Variant ~= self.Variant or sourceEntity.SubType ~= self.SubType then return end

	local data = self._Ents:GetTempData(sourceEntity)
	local damage = data.BAzazelLightDamage
	if damage then
		local mark = mod.IBS_Effect.BAzazelCrackTheSkyMark
		if mark and mark:GetMark(entity) then
			damage = mark:GetMarkedDamage(entity, damage)
		end
		local player = data.BAzazelLightPlayer
		self:TrySpawnMulliganFly(player)
		return {Damage = damage}
	end
end
BAzazelLightKnife:AddPriorityCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, 1000, 'OnTakeDamage')

return BAzazelLightKnife
