--昧az引导圣光

local mod = Isaac_BenightedSoul
local IBS_EffectID = mod.IBS_EffectID

local sfx = SFXManager()

local BAzazelCrackTheSky = mod.IBS_Class.Effect{
	Variant = IBS_EffectID.BAzazelCrackTheSky.Variant,
	SubType = IBS_EffectID.BAzazelCrackTheSky.SubType,
	Name = {zh = '昧az引导圣光', en = 'BAzazel Crack The Sky'}
}

BAzazelCrackTheSky.SoundPitchInfo = {
	Numerator = 2,
	ScaleOffset = 1,
}

function BAzazelCrackTheSky:GetSoundPitch(effect)
	local info = self.SoundPitchInfo
	return math.min((effect.Scale + info.ScaleOffset) / info.Numerator, 1)
end

function BAzazelCrackTheSky:GetLightData(effect)
	local data = self._Ents:GetTempData(effect)
	data.BAzazelCrackTheSky = data.BAzazelCrackTheSky or {
		HasSpawnedKnife = false,
	}
	return data.BAzazelCrackTheSky
end

--生成自定义圣光;伤害由Hit事件生成的透明刀造成
function BAzazelCrackTheSky:Spawn(position, spawner, damage, scale, color)
	local entity = Isaac.Spawn(EntityType.ENTITY_EFFECT, self.Variant, self.SubType, position, Vector.Zero, spawner)
	local light = entity and entity:ToEffect()
	if not light then return nil end

	light.CollisionDamage = damage or 0
	light.Scale = scale or 1
	if color then light.Color = color end
	return light
end

function BAzazelCrackTheSky:OnInit(effect)
	effect:GetSprite():Play('Spotlight', true)
end
BAzazelCrackTheSky:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, 'OnInit', BAzazelCrackTheSky.Variant)

function BAzazelCrackTheSky:OnUpdate(effect)
	local spr = effect:GetSprite()
	spr.Scale.X = effect.Scale

	if spr:IsEventTriggered('Sound') then
		sfx:Play(SoundEffect.SOUND_LIGHTBOLT, 1, 2, false, self:GetSoundPitch(effect), 0)
	end

	local data = self:GetLightData(effect)
	if not data.HasSpawnedKnife and spr:IsEventTriggered('Hit') then
		data.HasSpawnedKnife = true
		local player = self._Ents:GetSourcePlayer(effect)
		mod.IBS_Knife.BAzazelLightKnife:Spawn(effect, player)
	end

	if spr:IsFinished('Spotlight') then
		effect:Remove()
	end
end
BAzazelCrackTheSky:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, 'OnUpdate', BAzazelCrackTheSky.Variant)

return BAzazelCrackTheSky
