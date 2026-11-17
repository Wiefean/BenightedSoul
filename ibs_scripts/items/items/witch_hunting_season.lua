--猎巫时节

local mod = Isaac_BenightedSoul
local IBS_TearID = mod.IBS_TearID

local WitchHuntingSeason = mod.IBS_Class.Item(mod.IBS_ItemID.WitchHuntingSeason)

WitchHuntingSeason.BaseTearChance = 20
WitchHuntingSeason.MaxTearChance = 100
WitchHuntingSeason.MaxChanceLuck = 10
WitchHuntingSeason.MarkRadius = 80
WitchHuntingSeason.DeathLightCount = 5
WitchHuntingSeason.DeathLightDamageMultiplier = 3
WitchHuntingSeason.DeathLightRadius = 50
WitchHuntingSeason.DeathLightDelay = 3

function WitchHuntingSeason:GetTearChance(player, tear)
	local luck = math.max(0, math.min(self.MaxChanceLuck, player.Luck))
	local chanceRange = self.MaxTearChance - self.BaseTearChance
	return self.BaseTearChance + chanceRange * luck / self.MaxChanceLuck
end

WitchHuntingSeason.ExcludedTearVariants = {
	[TearVariant.FETUS] = true, --剖腹产
	[TearVariant.MULTIDIMENSIONAL] = true,
	[IBS_TearID.DiligenceHammerTear.Variant] = true,
	[IBS_TearID.InvertedCrossTear.Variant] = true,
	[IBS_TearID.BAzazelFakeKnife.Variant] = true,
	[IBS_TearID.WitchHuntingSeasonTear.Variant] = true,
}

--非泪弹来源需要溯源到持有道具的玩家;按需在此扩展
WitchHuntingSeason.AllowedNonTearSourceTypes = {
	[EntityType.ENTITY_LASER] = true,
	[EntityType.ENTITY_KNIFE] = true,
	[EntityType.ENTITY_PROJECTILE] = true,
	[EntityType.ENTITY_PLAYER] = true,
}

function WitchHuntingSeason:CanReplaceTear(tear)
	return not self.ExcludedTearVariants[tear.Variant]
end

function WitchHuntingSeason:RollTearChance(player, tear)
	local chance = math.max(0, math.min(100, self:GetTearChance(player, tear)))
	return player:GetCollectibleRNG(self.ID):RandomFloat() * 100 < chance
end

function WitchHuntingSeason:PostFireTear(tear)
	local player = self._Ents:IsSpawnerPlayer(tear, true)
	if not player or not player:HasCollectible(self.ID) then return end

	local weapon = player:GetWeapon(1)
	if not weapon or weapon:GetWeaponType() ~= WeaponType.WEAPON_TEARS then return end
	if not self:CanReplaceTear(tear) or not self:RollTearChance(player, tear) then return end

	tear:ChangeVariant(IBS_TearID.WitchHuntingSeasonTear.Variant)
	mod.IBS_Tear.WitchHuntingSeasonTear:PlaySizeAnimation(tear)
end
WitchHuntingSeason:AddCallback(ModCallbacks.MC_POST_FIRE_TEAR, 'PostFireTear')

function WitchHuntingSeason:ApplyMark(target, player, sourceEntity)
	local mark = mod.IBS_Effect.BAzazelCrackTheSkyMark
	local sourceTear = sourceEntity and sourceEntity:ToTear() or nil
	local seed = sourceTear and sourceTear.InitSeed or (sourceEntity and sourceEntity.InitSeed)
	for _, enemy in ipairs(Isaac.FindInRadius(target.Position, self.MarkRadius, EntityPartition.ENEMY)) do
		if self._Ents:IsEnemy(enemy) then
			mark:Apply(enemy, player, sourceTear)
			if seed then
				self._Ents:GetTempData(enemy).WitchHuntingSeasonLightSeed = seed
			end
		end
	end
end

function WitchHuntingSeason:OnEntityTakeDMG(entity, amount, flag, source)
	if amount <= 0 or not self._Ents:IsEnemy(entity) then return end

	local sourceEntity = source and source.Entity
	if not sourceEntity then return end

	local sourceTear = sourceEntity:ToTear()
	if sourceTear then
		if sourceTear.Variant ~= IBS_TearID.WitchHuntingSeasonTear.Variant then return end
		local player = self._Ents:IsSpawnerPlayer(sourceTear, true)
		if not player then return end
		self:ApplyMark(entity, player, sourceTear)
		return
	end

	if not self.AllowedNonTearSourceTypes[sourceEntity.Type] then return end
	local player = self._Ents:GetSourcePlayer(sourceEntity)
	if not player or not player:HasCollectible(self.ID) then return end
	if not self:RollTearChance(player, sourceEntity) then return end
	self:ApplyMark(entity, player, sourceEntity)
end
WitchHuntingSeason:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, 'OnEntityTakeDMG')

function WitchHuntingSeason:OnEntityKilled(entity)
	if not PlayerManager.AnyoneHasCollectible(self.ID) then return end
	
	local mark = mod.IBS_Effect.BAzazelCrackTheSkyMark:GetMark(entity)
	if not mark then return end

	local data = self._Ents:GetTempData(entity)
	if data.WitchHuntingSeasonDeathTriggered then return end
	data.WitchHuntingSeasonDeathTriggered = true

	local player = self._Ents:GetSourcePlayer(mark)
	if not player or not player:Exists() then return end

	local rng = RNG(data.WitchHuntingSeasonLightSeed or entity.InitSeed)
	local deathPosition = entity.Position
	local damage = player.Damage * self.DeathLightDamageMultiplier
	local positions = {}
	for index = 0, self.DeathLightCount - 1 do
		local angle = rng:RandomFloat() * 360
		local radius = rng:RandomFloat() * self.DeathLightRadius
		positions[index + 1] = deathPosition + Vector.FromAngle(angle) * radius
	end

	for index, position in ipairs(positions) do
		self:DelayFunction(function()
			if player:Exists() then
				mod.IBS_Effect.BAzazelCrackTheSky:Spawn(position, player, damage, 1)
			end
		end, (index - 1) * self.DeathLightDelay)
	end
end
WitchHuntingSeason:AddCallback(ModCallbacks.MC_POST_ENTITY_KILL, 'OnEntityKilled')

return WitchHuntingSeason
