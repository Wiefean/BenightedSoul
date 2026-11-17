--火刑架

local mod = Isaac_BenightedSoul

local game = Game()

local OnThePyre = mod.IBS_Class.Item(mod.IBS_ItemID.OnThePyre)

OnThePyre.MarkDuration = 10 * 30
OnThePyre.LockRange = 128
OnThePyre.LightDamageMultiplier = 5
OnThePyre.LightInterval = 15
OnThePyre.OrangeLightColor = Color(1, 0.5, 0, 1, 0, 0, 0)
OnThePyre.FlameDamageMultiplier = 4
OnThePyre.FlameScale = 1.5
OnThePyre.WispRadius = 40
OnThePyre.WispOrbitSpeed = 0.05
OnThePyre.WispVariants = {FamiliarVariant.WISP, FamiliarVariant.ITEM_WISP}
OnThePyre.BlackHeartChance = 10

function OnThePyre:GetPedestalData(pickup)
	local data = self._Ents:GetTempData(pickup)
	data.OnThePyre = data.OnThePyre or {}
	return data.OnThePyre
end

function OnThePyre:IsOurPedestal(pickup, data)
	return pickup and pickup:Exists() and not pickup:IsDead()
	and pickup.Variant == PickupVariant.PICKUP_COLLECTIBLE
	and pickup.SubType == self.ID and data.Active
end

function OnThePyre:FindNearestEnemy(position)
	local result
	local nearest = self.LockRange * self.LockRange
	for _, entity in ipairs(Isaac.FindInRadius(position, self.LockRange, EntityPartition.ENEMY)) do
		if self._Ents:IsEnemy(entity) then
			local distance = entity.Position:DistanceSquared(position)
			if distance <= nearest then
				result = entity
				nearest = distance
			end
		end
	end
	return result
end

function OnThePyre:GetOwnerPlayer(pickup, data)
	local spawner = pickup.SpawnerEntity
	local player = spawner and spawner:Exists() and spawner:ToPlayer() or nil
	if player then return player end
	if data.Owner and data.Owner:Exists() then return data.Owner end
	return game:GetNearestPlayer(pickup.Position)
end

function OnThePyre:SpawnPyreFlame(pickup, data)
	local player = self:GetOwnerPlayer(pickup, data)
	local damage = player and player.Damage * self.FlameDamageMultiplier or 14
	local entity = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.RED_CANDLE_FLAME, 0,
		pickup.Position + Vector(0, 8), Vector.Zero, player or pickup)
	local flame = entity and entity:ToEffect()
	if not flame then return nil end

	flame.Parent = pickup
	flame.CollisionDamage = damage
	flame.LifeSpan = 999999
	flame:SetTimeout(5)
	local scale = self.FlameScale
	flame.Scale = scale

	local flameData = self._Ents:GetTempData(flame)
	flameData.OnThePyreFlame = true
	flameData.OnThePyreDamageOwner = player
	flameData.OnThePyrePedestal = pickup
	return flame
end

function OnThePyre:LockFlameScale(flame)
	local flameData = self._Ents:GetTempData(flame)
	if not flameData.OnThePyreFlame then return end

	local pickup = flameData.OnThePyrePedestal
	if not pickup or not pickup:Exists() or pickup:IsDead()
	or pickup.Variant ~= PickupVariant.PICKUP_COLLECTIBLE
	or pickup.SubType ~= self.ID then
		local pickupData = pickup and self._Ents:GetTempData(pickup).OnThePyre
		if pickupData then
			self:CleanupPedestal(pickup, pickupData)
		else
			self:RemovePyreFlame(flame)
		end
		return
	end

	local scale = self.FlameScale
	flame.Scale = scale
	flame:SetTimeout(5)
end
OnThePyre:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, 'LockFlameScale',
	EffectVariant.RED_CANDLE_FLAME)

function OnThePyre:FindPedestalForWisp(wisp)
	local wispPlayer = wisp.Player or Isaac.GetPlayer(0)
	if not wispPlayer then return nil end

	local playerHash = GetPtrHash(wispPlayer)
	for _, entity in ipairs(Isaac.FindByType(EntityType.ENTITY_PICKUP,
		PickupVariant.PICKUP_COLLECTIBLE, self.ID)) do
		local pickup = entity:ToPickup()
		if pickup and pickup:Exists() and not pickup:IsDead() then
			local data = self._Ents:GetTempData(pickup).OnThePyre or {}
			local owner = self:GetOwnerPlayer(pickup, data)
			if owner and GetPtrHash(owner) == playerHash then
				return pickup
			end
		end
	end
end

function OnThePyre:AssignWisps(pickup, data)
	local player = self:GetOwnerPlayer(pickup, data)
	if not player then return end

	local playerHash = GetPtrHash(player)
	for _, variant in ipairs(self.WispVariants) do
		for _, entity in ipairs(Isaac.FindByType(EntityType.ENTITY_FAMILIAR,
			variant, self.ID)) do
			local wisp = entity:ToFamiliar()
			local wispPlayer = wisp and (wisp.Player or player)
			if wispPlayer and GetPtrHash(wispPlayer) == playerHash then
				local wispData = self._Ents:GetTempData(wisp)
				wispData.OnThePyrePedestal = pickup
			end
		end
	end
end

function OnThePyre:OnWispInit(wisp)
	if wisp.SubType ~= self.ID then return end
	wisp:AddToOrbit(0)
	wisp.OrbitDistance = Vector(self.WispRadius, self.WispRadius)
	wisp.OrbitSpeed = self.WispOrbitSpeed
end
OnThePyre:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, 'OnWispInit',
	FamiliarVariant.WISP)
OnThePyre:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, 'OnWispInit',
	FamiliarVariant.ITEM_WISP)

function OnThePyre:SetWispOrbit(wisp, center, wisps)
	table.sort(wisps, function(a, b)
		return a.Index < b.Index
	end)

	local index
	for i, entity in ipairs(wisps) do
		if GetPtrHash(entity) == GetPtrHash(wisp) then
			index = i
			break
		end
	end
	index = index or 1

	wisp:AddToOrbit(0)
	wisp.OrbitDistance = Vector(self.WispRadius, self.WispRadius)
	wisp.OrbitSpeed = self.WispOrbitSpeed
	wisp.OrbitAngleOffset = (index - 1) * math.pi * 2 / #wisps
	wisp.Velocity = wisp:GetOrbitPosition(center) - wisp.Position
end

function OnThePyre:OnWispUpdate(wisp)
	if wisp.SubType ~= self.ID then return end

	local wispData = self._Ents:GetTempData(wisp)
	local pickup = wispData.OnThePyrePedestal
	if not pickup or not pickup:Exists() or pickup:IsDead()
	or pickup.Variant ~= PickupVariant.PICKUP_COLLECTIBLE
	or pickup.SubType ~= self.ID then
		pickup = self:FindPedestalForWisp(wisp)
	end

	if pickup then
		wispData.OnThePyrePedestal = pickup
		local wisps = {}
		for _, variant in ipairs(self.WispVariants) do
			for _, entity in ipairs(Isaac.FindByType(EntityType.ENTITY_FAMILIAR,
				variant, self.ID)) do
				if self._Ents:GetTempData(entity).OnThePyrePedestal == pickup then
					table.insert(wisps, entity)
				end
			end
		end
		self:SetWispOrbit(wisp, pickup.Position, wisps)
		return
	end

	wispData.OnThePyrePedestal = nil
	local wispPlayer = wisp.Player or Isaac.GetPlayer(0)
	if not wispPlayer then return end

	local playerHash = GetPtrHash(wispPlayer)
	local wisps = {}
	for _, variant in ipairs(self.WispVariants) do
		for _, entity in ipairs(Isaac.FindByType(EntityType.ENTITY_FAMILIAR,
			variant, self.ID)) do
			local candidate = entity:ToFamiliar()
			if candidate then
				local candidateData = self._Ents:GetTempData(candidate)
				local candidatePlayer = candidate.Player or Isaac.GetPlayer(0)
				if not candidateData.OnThePyrePedestal and candidatePlayer
				and GetPtrHash(candidatePlayer) == playerHash then
					table.insert(wisps, candidate)
				end
			end
		end
	end
	self:SetWispOrbit(wisp, wispPlayer.Position, wisps)
end
OnThePyre:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, 'OnWispUpdate',
	FamiliarVariant.WISP)
OnThePyre:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, 'OnWispUpdate',
	FamiliarVariant.ITEM_WISP)

function OnThePyre:SpawnHolyLight(pickup, data)
	local target = self:FindNearestEnemy(pickup.Position)
	if not target then return end

	local player = self:GetOwnerPlayer(pickup, data)
	if not player then return end
	local damage = player.Damage * self.LightDamageMultiplier
	local light = mod.IBS_Effect.BAzazelCrackTheSky:Spawn(target.Position, player,
		damage, 1, self.OrangeLightColor)
	if not light then return end

	local lightData = self._Ents:GetTempData(light)
	lightData.OnThePyreDamageOwner = player
	lightData.OnThePyrePedestal = pickup
end

function OnThePyre:ApplyInitialMarks(player)
	for _, entity in ipairs(Isaac.GetRoomEntities()) do
		if self._Ents:IsEnemy(entity, true) then
			mod.IBS_Effect.BAzazelCrackTheSkyMark:Apply(entity, player, nil,
				self.MarkDuration)
		end
	end
end

function OnThePyre:InitializePedestal(pickup, player)
	local data = self:GetPedestalData(pickup)
	data.Active = true
	data.Owner = player
	data.Flame = self:SpawnPyreFlame(pickup, data)
	self:AssignWisps(pickup, data)
	self:SpawnHolyLight(pickup, data)
end

function OnThePyre:RemovePyreFlame(flame)
	if not flame then return end

	local flameData = self._Ents:GetTempData(flame)
	if not flameData.OnThePyreFlame then return end

	flameData.OnThePyreFlame = nil
	flameData.OnThePyreDamageOwner = nil
	flameData.OnThePyrePedestal = nil

	if flame:Exists() then
		flame:Die()
	end
end

function OnThePyre:RemovePedestalFlames(pickup, knownFlame)
	self:RemovePyreFlame(knownFlame)

	for _, entity in ipairs(Isaac.FindByType(EntityType.ENTITY_EFFECT,
		EffectVariant.RED_CANDLE_FLAME)) do
		local flame = entity:ToEffect()
		if flame and flame ~= knownFlame then
			local flameData = self._Ents:GetTempData(flame)
			if flameData.OnThePyreFlame and flameData.OnThePyrePedestal == pickup then
				self:RemovePyreFlame(flame)
			end
		end
	end
end

function OnThePyre:CleanupPedestal(pickup, data)
	data.Active = nil
	data.Owner = nil
	self:RemovePedestalFlames(pickup, data.Flame)
	data.Flame = nil

	local pickupData = self._Ents:GetTempData(pickup)
	pickupData.OnThePyre = nil
end

function OnThePyre:OnPedestalUpdate(pickup)
	local data = self:GetPedestalData(pickup)
	if pickup.SubType ~= self.ID then
		if data.Active then
			self:CleanupPedestal(pickup, data)
		end
		return
	end

	if not data.Active then
		self:InitializePedestal(pickup, self:GetOwnerPlayer(pickup, data))
		return
	end

	if not self:IsOurPedestal(pickup, data) then
		self:CleanupPedestal(pickup, data)
		return
	end

	if not data.Flame or not data.Flame:Exists() then
		data.Flame = self:SpawnPyreFlame(pickup, data)
	else
		data.Flame.Position = pickup.Position + Vector(0, 8)
	end

	self:AssignWisps(pickup, data)
	if pickup:IsFrame(self.LightInterval, 0) then
		self:SpawnHolyLight(pickup, data)
	end
end
OnThePyre:AddCallback(ModCallbacks.MC_POST_PICKUP_UPDATE, 'OnPedestalUpdate',
	PickupVariant.PICKUP_COLLECTIBLE)

function OnThePyre:PrePedestalMorph(pickup, lastType, variant, subtype)
	if pickup.Variant ~= PickupVariant.PICKUP_COLLECTIBLE
	or pickup.SubType ~= self.ID then
		return
	end
	if variant == PickupVariant.PICKUP_COLLECTIBLE and subtype == self.ID then
		return
	end

	local data = self._Ents:GetTempData(pickup).OnThePyre
	if data then
		self:CleanupPedestal(pickup, data)
	else
		self:RemovePedestalFlames(pickup)
	end
end
OnThePyre:AddCallback(ModCallbacks.MC_PRE_PICKUP_MORPH, 'PrePedestalMorph')

function OnThePyre:PrePickupCollision(pickup, collider)
	if pickup.Variant == PickupVariant.PICKUP_COLLECTIBLE
	and pickup.SubType == self.ID
	and not game:GetRoom():IsClear() then
		return false
	end
end
OnThePyre:AddPriorityCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, -100000,
	'PrePickupCollision')

function OnThePyre:GetPyreDamageOwner(sourceEntity)
	if not sourceEntity then return nil end

	local data = self._Ents:GetTempData(sourceEntity)
	local owner = data.OnThePyreDamageOwner
	if owner then return owner end

	if sourceEntity.Type == EntityType.ENTITY_KNIFE and sourceEntity.Parent then
		local light = sourceEntity.Parent:ToEffect()
		if light then
			return self._Ents:GetTempData(light).OnThePyreDamageOwner
		end
	end
end

function OnThePyre:OnEntityTakeDMG(entity, amount, flag, source)
	if amount <= 0 or not self._Ents:IsEnemy(entity) then return end

	local owner = self:GetPyreDamageOwner(source and source.Entity)
	if not owner or not owner:Exists() then return end

	local data = self._Ents:GetTempData(entity)
	data.OnThePyreKillOwner = owner
end
OnThePyre:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, 'OnEntityTakeDMG')

function OnThePyre:OnEntityKilled(entity)
	local data = self._Ents:GetTempData(entity)
	local owner = data.OnThePyreKillOwner
	if owner and owner:Exists()
	and owner:GetPlayerType() == PlayerType.PLAYER_JUDAS
	and owner:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT) then
		local rng = owner:GetCollectibleRNG(self.ID)
		if rng:RandomInt(100) < self.BlackHeartChance then
			Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_HEART,
				HeartSubType.HEART_BLACK, entity.Position, Vector.Zero, owner)
		end
	end
	data.OnThePyreKillOwner = nil
end
OnThePyre:AddCallback(ModCallbacks.MC_POST_ENTITY_KILL, 'OnEntityKilled')

function OnThePyre:OnEntityRemove(entity)
	local pickup = entity:ToPickup()
	if not pickup then return end
	local data = self._Ents:GetTempData(pickup).OnThePyre
	if data and data.Active then
		self:CleanupPedestal(pickup, data)
	end
end
OnThePyre:AddCallback(ModCallbacks.MC_POST_ENTITY_REMOVE, 'OnEntityRemove',
	EntityType.ENTITY_PICKUP)

function OnThePyre:FindDroppedPedestal(player)
	local pickup = player:DropCollectible(self.ID)
	local result = pickup and pickup:ToPickup()
	if result then return result end

	local nearest = 100 * 100
	for _, entity in ipairs(Isaac.FindByType(EntityType.ENTITY_PICKUP,
		PickupVariant.PICKUP_COLLECTIBLE, self.ID)) do
		local candidate = entity:ToPickup()
		local distance = candidate.Position:DistanceSquared(player.Position)
		if distance <= nearest then
			result = candidate
			nearest = distance
		end
	end
	return result
end

function OnThePyre:OnUse(item, rng, player, flag, slot)
	self:ApplyInitialMarks(player)

	self:DelayFunction(function()
		if not player:Exists() then return end
		local pickup = self:FindDroppedPedestal(player)
		if pickup then
			pickup.Wait = 15
		end
	end, 0)

	return {ShowAnim = false, Discharge = true}
end
OnThePyre:AddCallback(ModCallbacks.MC_USE_ITEM, 'OnUse', OnThePyre.ID)

return OnThePyre
