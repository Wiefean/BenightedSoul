--昧az终末天启兼容:复刻原版教条光球的开放、蓄力和八向神圣激光表现

local mod = Isaac_BenightedSoul
local IBS_EffectID = mod.IBS_EffectID

local game = Game()
local sfx = SFXManager()

local BAzazelDogmaOrb = mod.IBS_Class.Effect{
	Variant = IBS_EffectID.BAzazelDogmaOrb.Variant,
	SubType = IBS_EffectID.BAzazelDogmaOrb.SubType,
	Name = {zh = '昧az教条光球', en = 'BAzazel Dogma Orb'}
}

local ANM2 = 'gfx/ibs/effects/dogma_orb.anm2'
local ORB_DATA = 'BAzazelDogmaOrb'
local SWIRL_DATA = 'BAzazelDogmaOrbSwirl'
local LASER_DATA = 'BAzazelDogmaOrbLaser'

BAzazelDogmaOrb.Defaults = {
	Damage = 3.5,
	LaserDuration = 30,
	LaserCount = 8,
	AngleOffset = 0,
	MaxDistance = 0,
	IdleFrames = 30,
	FireFrame = -1,
	Scale = 1,
	SwirlScale = 1,
	SwirlSpeed = 36,
	SwirlAlpha = 150 / 255,
	LaserOffsetSaturation = 0,
}

function BAzazelDogmaOrb:GetOrbData(effect)
	local data = self._Ents:GetTempData(effect)
	data[ORB_DATA] = data[ORB_DATA] or {}
	return data[ORB_DATA]
end

function BAzazelDogmaOrb:GetSwirlData(effect)
	local data = self._Ents:GetTempData(effect)
	data[SWIRL_DATA] = data[SWIRL_DATA] or {}
	return data[SWIRL_DATA]
end

function BAzazelDogmaOrb:CopyConfig(overrides)
	local config = {}
	for key, value in pairs(self.Defaults) do
		config[key] = value
	end
	for key, value in pairs(overrides or {}) do
		if config[key] ~= nil then
			config[key] = value
		end
	end
	return config
end

--保留亮度，按饱和度参数压低 RGB offset;仅作用于本模块生成的神圣激光
function BAzazelDogmaOrb:ApplyLaserOffset(laser, saturation)
	local color = laser.Color
	local value = math.max(color.RO, color.GO, color.BO)
	color:SetOffset(value + (color.RO - value) * saturation,
		value + (color.GO - value) * saturation,
		value + (color.BO - value) * saturation)
	laser.Color = color
end

function BAzazelDogmaOrb:BeginDeath(effect, state)
	state.Phase = 'Death'
	effect:GetSprite():Play('Death', true)
end

function BAzazelDogmaOrb:FireLasers(effect, state)
	state.Fired = true
	local owner = state.Owner
	if not owner or not owner:Exists() or owner:IsDead() then return end

	sfx:Play(SoundEffect.SOUND_DOGMA_LIGHT_RAY_FIRE, 0.3, 2, false, 1, 0)
	local config = state.Config
	for i = 0, config.LaserCount - 1 do
		local entity = Isaac.Spawn(EntityType.ENTITY_LASER, LaserVariant.LIGHT_BEAM, 0,
			effect.Position, Vector.Zero, owner)
		local laser = entity and entity:ToLaser()
		if laser then
			laser.AngleDegrees = config.AngleOffset + i * 360 / config.LaserCount
			laser.CollisionDamage = config.Damage
			laser.DisableFollowParent = true
			if config.MaxDistance > 0 then
				laser:SetMaxDistance(config.MaxDistance)
			end
			laser:SetTimeout(config.LaserDuration)
			self._Ents:GetTempData(laser)[LASER_DATA] = config.LaserOffsetSaturation
			self:ApplyLaserOffset(laser, config.LaserOffsetSaturation)
		end
	end
	sfx:Stop(SoundEffect.SOUND_ANGEL_BEAM)
end

--生成光球;owner必须是玩家，返回的EntityEffect可主动Remove取消
function BAzazelDogmaOrb:Spawn(position, owner, overrides)
	if not owner or not owner:Exists() or not owner:ToPlayer() then return nil end

	local config = self:CopyConfig(overrides)
	local entity = Isaac.Spawn(EntityType.ENTITY_EFFECT, self.Variant, self.SubType,
		position, Vector.Zero, owner)
	local effect = entity and entity:ToEffect()
	if not effect then return nil end

	sfx:Play(SoundEffect.SOUND_DOGMA_LIGHT_APPEAR, 0.2, 30, false, 0.7, 0)
	effect.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
	effect.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NONE
	effect.SpriteScale = Vector(config.Scale, config.Scale)

	local state = self:GetOrbData(effect)
	state.Config = config
	state.Owner = owner
	state.Phase = 'Open'
	state.Fired = false

	local sprite = effect:GetSprite()
	sprite:Load(ANM2, true)
	sprite:Play('Open', true)

	local swirlEntity = Isaac.Spawn(EntityType.ENTITY_EFFECT, self.Variant, self.SubType,
		position, Vector.Zero, owner)
	local swirl = swirlEntity and swirlEntity:ToEffect()
	if swirl then
		local swirlState = self:GetSwirlData(swirl)
		swirlState.Orb = effect
		swirlState.StartFrame = game:GetFrameCount()

		swirl.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
		swirl.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NONE
		swirl.DepthOffset = effect.DepthOffset - 1
		swirl.SpriteScale = Vector(config.Scale, config.Scale) * config.SwirlScale

		local swirlSprite = swirl:GetSprite()
		swirlSprite:Load(ANM2, true)
		swirlSprite:Play('Swirl', true)
		swirlSprite.Color = Color(1, 1, 1, config.SwirlAlpha)
		state.Swirl = swirl
	end

	return effect
end

function BAzazelDogmaOrb:OnUpdate(effect)
	local swirlState = self:GetSwirlData(effect)
	if swirlState.Orb then
		local orb = swirlState.Orb
		if not orb or not orb:Exists() then
			effect:Remove()
			return
		end

		local state = self:GetOrbData(orb)
		if not state.Config then
			effect:Remove()
			return
		end

		local config = state.Config
		local fade = 1
		if state.Phase == 'Death' then
			fade = math.max(0, math.min(1, (44 - orb:GetSprite():GetFrame()) / 32))
		end
		effect.Position = orb.Position
		effect.Velocity = Vector.Zero
		effect.DepthOffset = orb.DepthOffset - 1
		effect.SpriteScale = orb.SpriteScale * config.SwirlScale

		local sprite = effect:GetSprite()
		sprite.Rotation = ((game:GetFrameCount() - swirlState.StartFrame) * config.SwirlSpeed) % 360
		sprite.Color = Color(1, 1, 1, config.SwirlAlpha * fade)
		return
	end

	local state = self:GetOrbData(effect)
	if not state.Config then
		effect:Remove()
		return
	end

	local sprite = effect:GetSprite()
	local config = state.Config
	effect.Velocity = Vector.Zero

	if state.Phase == 'Open' and sprite:IsFinished('Open') then
		if config.IdleFrames == 0 then
			self:BeginDeath(effect, state)
		else
			state.Phase = 'Idle'
			state.IdleEndFrame = game:GetFrameCount() + config.IdleFrames
			sprite:Play('Idle', true)
		end
	elseif state.Phase == 'Idle' and game:GetFrameCount() >= state.IdleEndFrame then
		self:BeginDeath(effect, state)
	end

	if state.Phase == 'Death' then
		local shouldFire
		if config.FireFrame == -1 then
			shouldFire = sprite:IsEventTriggered('Shoot') or sprite:WasEventTriggered('Shoot')
		else
			shouldFire = sprite:GetFrame() >= config.FireFrame or sprite:IsFinished('Death')
		end
		if not state.Fired and shouldFire then
			self:FireLasers(effect, state)
		end
		if sprite:IsFinished('Death') then
			effect:Remove()
		end
	end
end
BAzazelDogmaOrb:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, 'OnUpdate', BAzazelDogmaOrb.Variant)

function BAzazelDogmaOrb:OnLaserUpdate(laser)
	local saturation = self._Ents:GetTempData(laser)[LASER_DATA]
	if saturation ~= nil then
		self:ApplyLaserOffset(laser, saturation)
	end
end
BAzazelDogmaOrb:AddCallback(ModCallbacks.MC_POST_LASER_UPDATE, 'OnLaserUpdate', LaserVariant.LIGHT_BEAM)

--外部主动取消光球时同步移除底层螺旋
function BAzazelDogmaOrb:OnEntityRemove(entity)
	if entity.Variant ~= self.Variant then return end

	local swirlState = self:GetSwirlData(entity)
	if swirlState.Orb then return end

	local state = self:GetOrbData(entity)
	if state.Swirl and state.Swirl:Exists() then
		state.Swirl:Remove()
	end
end
BAzazelDogmaOrb:AddCallback(ModCallbacks.MC_POST_ENTITY_REMOVE, 'OnEntityRemove')

return BAzazelDogmaOrb
