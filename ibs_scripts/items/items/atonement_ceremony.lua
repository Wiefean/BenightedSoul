--赎罪仪式

local mod = Isaac_BenightedSoul

local game = Game()
local sfx = SFXManager()
local RitualSprite = Sprite('gfx/ibs/tears/inverted_cross_tear.anm2')
RitualSprite:Play('Idle', true)
RitualSprite.Scale = Vector(1.25, 1.25)

local AtonementCeremony = mod.IBS_Class.Item(mod.IBS_ItemID.AtonementCeremony)

AtonementCeremony.RitualDuration = 60
AtonementCeremony.SpeedBonus = 1
AtonementCeremony.HolyLightInterval = 3
AtonementCeremony.HolyLightDamageMultiplier = 3
AtonementCeremony.LightRange = 20
AtonementCeremony.DamageBonus = 1
AtonementCeremony.DamageDecay = 0.25
AtonementCeremony.DamageDecayInterval = 15
AtonementCeremony.EndKnockbackRadius = 120
AtonementCeremony.EndKnockbackStrength = 10
AtonementCeremony.EndInvincibleFrames = 30
AtonementCeremony.RitualTrailRadius = 0.1
AtonementCeremony.RitualTrailScale = Vector(2, 2)

AtonementCeremony.BlockedInputActions = {
	[ButtonAction.ACTION_SHOOTLEFT] = true,
	[ButtonAction.ACTION_SHOOTRIGHT] = true,
	[ButtonAction.ACTION_SHOOTUP] = true,
	[ButtonAction.ACTION_SHOOTDOWN] = true,
	[ButtonAction.ACTION_BOMB] = true,
	[ButtonAction.ACTION_ITEM] = true,
	[ButtonAction.ACTION_PILLCARD] = true,
}

function AtonementCeremony:GetData(player)
	local entityData = self._Ents:GetTempData(player)
	local data = entityData.AtonementCeremony
	if not data then
		data = {
			Ritual = false,
			Time = 0,
		}
		entityData.AtonementCeremony = data
	end

	return data
end

function AtonementCeremony:RemoveRitualWisps(player)
	local playerHash = GetPtrHash(player)
	for _, entity in ipairs(Isaac.FindByType(EntityType.ENTITY_FAMILIAR,
		FamiliarVariant.WISP, self.ID)) do
		local familiar = entity:ToFamiliar()
		if familiar and familiar.Player
		and GetPtrHash(familiar.Player) == playerHash then
			familiar:Remove()
		end
	end
end

function AtonementCeremony:SpawnRitualTransitionEffect(player, starting)
	local entity = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF02, 1,
		player.Position, Vector.Zero, player)
	local poof = entity and entity:ToEffect()
	if poof then
		poof.Color = Color(1, 1, 1, 1, 0.5, 0.5, 0.7)
	end

	local sound = SoundEffect.SOUND_DIVINE_INTERVENTION
	sfx:Play(sound, 2, 2, false, 1, 0)
end

function AtonementCeremony:GetRitualCenterPosition(player)
	local offset = player.SpriteScale.Y * 24 + 4
	return player.Position + Vector(0, -offset)
end

function AtonementCeremony:UpdateRitualTrail(player, data)
	local trail = data.RitualTrail
	if not trail or not trail:Exists() then
		local entity = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.SPRITE_TRAIL, 0,
			self:GetRitualCenterPosition(player), Vector.Zero, player)
		trail = entity and entity:ToEffect()
		if not trail then return end

		trail.MinRadius = self.RitualTrailRadius
		trail.MaxRadius = self.RitualTrailRadius
		trail.SpriteScale = self.RitualTrailScale
		trail.Parent = player
		trail:SetColor(Color(1, 1, 1, 1), -1, 0)
		data.RitualTrail = trail
	end

	trail.Position = self:GetRitualCenterPosition(player)
end

function AtonementCeremony:RemoveRitualTrail(data)
	if data.RitualTrail and data.RitualTrail:Exists() then
		data.RitualTrail:Remove()
	end
	data.RitualTrail = nil
end

function AtonementCeremony:ApplyEndRitualBurst(player)
	for _, enemy in ipairs(Isaac.FindInRadius(player.Position,
		self.EndKnockbackRadius, EntityPartition.ENEMY)) do
		if self._Ents:IsEnemy(enemy, false, false, true) then
			local direction = (enemy.Position - player.Position):Normalized()
			if direction:Length() <= 0 then
				direction = Vector.FromAngle(Random() % 360)
			end
			enemy:AddVelocity(direction * self.EndKnockbackStrength)
		end
	end
	player:SetMinDamageCooldown(self.EndInvincibleFrames)
end

function AtonementCeremony:StartRitual(player)
	local data = self:GetData(player)
	if data.Ritual then return end

	data.Ritual = true
	data.Time = self.RitualDuration
	data.LastTimeFrame = nil
	data.OriginalColor = player:GetColor()
	RitualSprite:Play('Idle', true)
	self:SpawnRitualTransitionEffect(player, true)
	self:UpdateRitualTrail(player, data)
	player:SetColor(Color(1, 1, 1, 0), self.RitualDuration, 0, false, true)
	player:AddCacheFlags(CacheFlag.CACHE_ALL, true)
	player:EvaluateItems()
end

function AtonementCeremony:EndRitual(player, cleanupOnly)
	local data = self:GetData(player)
	if not data.Ritual then return end

	data.Ritual = false
	data.Time = 0
	data.LastTimeFrame = nil
	if not cleanupOnly then
		self:SpawnRitualTransitionEffect(player, false)
		self:ApplyEndRitualBurst(player)
	end
	self:RemoveRitualTrail(data)
	player:SetColor(data.OriginalColor or Color(1, 1, 1, 1), 0, 0, false, true)
	data.OriginalColor = nil
	self:RemoveRitualWisps(player)
	player:AddCacheFlags(CacheFlag.CACHE_ALL, true)
	player:EvaluateItems()
	
	if player:HasCollectible(59) then
		player:UseActiveItem(705, false, false)
	end
end

function AtonementCeremony:OnUse(item, rng, player, flag, slot)
	local data = self:GetData(player)
	if data.Ritual then
		return {ShowAnim = false, Discharge = false}
	end

	self:StartRitual(player)
	return {ShowAnim = false, Discharge = true}
end
AtonementCeremony:AddCallback(ModCallbacks.MC_USE_ITEM, 'OnUse', AtonementCeremony.ID)

function AtonementCeremony:OnEvaluateCache(player, flag)
	local data = self:GetData(player)

	if data.Ritual then
		if flag & CacheFlag.CACHE_SPEED > 0 then
			player.MoveSpeed = player.MoveSpeed + self.SpeedBonus
		end
	end

end
AtonementCeremony:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, 'OnEvaluateCache')

function AtonementCeremony:ClearNearbyProjectiles(player)
	for _, entity in ipairs(Isaac.FindInRadius(player.Position,
		player.Size + self.LightRange, EntityPartition.BULLET)) do
		local projectile = entity:ToProjectile()
		if projectile
		and not projectile:HasProjectileFlags(ProjectileFlags.CANT_HIT_PLAYER)
		and self._Ents:GetSourceEnemy(projectile) then
			projectile:Die()
		end
	end
end

function AtonementCeremony:OnPlayerUpdate(player)
	local data = self:GetData(player)

	if not data.Ritual then return end
	local frame = game:GetFrameCount()
	if data.LastTimeFrame == frame then return end
	data.LastTimeFrame = frame

	self:UpdateRitualTrail(player, data)
	data.Time = math.max(0, data.Time - 1)
	self:ClearNearbyProjectiles(player)

	if player:IsFrame(self.HolyLightInterval, 0) then
		mod.IBS_Effect.BAzazelCrackTheSky:Spawn(player.Position, player,
			player.Damage * self.HolyLightDamageMultiplier, 1)
	end

	if data.Time <= 0 then
		self:EndRitual(player)
	end
end
AtonementCeremony:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, 'OnPlayerUpdate', 0)

function AtonementCeremony:OnPlayerRender(player, offset)
	if game:GetRoom():GetRenderMode() == RenderMode.RENDER_WATER_REFLECT then return end
	local data = self:GetData(player)
	if not data.Ritual then return end

	if not game:IsPaused() then
		RitualSprite:Update()
	end
	local centerOffset = player.SpriteScale.Y * 24 - 4
	local position = self._Screens:GetEntityRenderPosition(player, offset + Vector(0, -centerOffset))
	RitualSprite:Render(position)
end
AtonementCeremony:AddCallback(ModCallbacks.MC_POST_PLAYER_RENDER, 'OnPlayerRender', 0)

function AtonementCeremony:CheckInput(ent, hook, action)
	local player = ent and ent:ToPlayer()
	if not player or not self:GetData(player).Ritual then return end
	if not self.BlockedInputActions[action] then return end

	if hook == InputHook.IS_ACTION_PRESSED or hook == InputHook.IS_ACTION_TRIGGERED then
		return false
	elseif hook == InputHook.GET_ACTION_VALUE then
		return 0
	end
end
AtonementCeremony:AddPriorityCallback(ModCallbacks.MC_INPUT_ACTION, -9999, 'CheckInput')

function AtonementCeremony:PrePlayerTakeDMG(player, amount, flag, source)
	if amount > 0 and player:ToPlayer() and self:GetData(player).Ritual then
		return false
	end
end
AtonementCeremony:AddPriorityCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, -100000,
	'PrePlayerTakeDMG', EntityType.ENTITY_PLAYER)

function AtonementCeremony:PrePlayerCollision(player)
	if not self:GetData(player).Ritual then return end
	return true
end
AtonementCeremony:AddPriorityCallback(ModCallbacks.MC_PRE_PLAYER_COLLISION, -100000,
	'PrePlayerCollision')

function AtonementCeremony:PrePickupCollision(pickup, collider)
	local player = collider and collider:ToPlayer()
	if player and self:GetData(player).Ritual then
		return false
	end
end
AtonementCeremony:AddPriorityCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, -100000,
	'PrePickupCollision')

function AtonementCeremony:PreNPCCollision(npc, collider)
	local player = collider and collider:ToPlayer()
	if player and self:GetData(player).Ritual then
		return false
	end
end
AtonementCeremony:AddPriorityCallback(ModCallbacks.MC_PRE_NPC_COLLISION, -100000,
	'PreNPCCollision')

function AtonementCeremony:PreSlotCollision(slot, collider)
	local player = collider and collider:ToPlayer()
	if player and self:GetData(player).Ritual then
		return false
	end
end
AtonementCeremony:AddPriorityCallback(ModCallbacks.MC_PRE_SLOT_COLLISION, -100000,
	'PreSlotCollision')

function AtonementCeremony:OnWispTakeDMG(entity, amount, flag, source)
	local familiar = entity:ToFamiliar()
	if not familiar or familiar.Variant ~= FamiliarVariant.WISP
	or familiar.SubType ~= self.ID or not familiar.Player then return end
	if self:GetData(familiar.Player).Ritual then
		return false
	end
end
AtonementCeremony:AddPriorityCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, -100000,
	'OnWispTakeDMG', EntityType.ENTITY_FAMILIAR)

function AtonementCeremony:CloseRituals()
	for index = 0, game:GetNumPlayers() - 1 do
		self:EndRitual(Isaac.GetPlayer(index), true)
	end
end
AtonementCeremony:AddCallback(ModCallbacks.MC_PRE_GAME_EXIT, 'CloseRituals')
AtonementCeremony:AddCallback(ModCallbacks.MC_POST_GAME_END, 'CloseRituals')

return AtonementCeremony
