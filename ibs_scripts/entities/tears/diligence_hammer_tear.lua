--劳锤眼泪

local mod = Isaac_BenightedSoul
local IBS_TearID = mod.IBS_TearID
local Pickups = mod.IBS_Lib.Pickups

local game = Game()
local sfx = SFXManager()

local DiligenceHammerTear = mod.IBS_Class.Tear{
	Variant = IBS_TearID.DiligenceHammerTear.Variant,
	SubType = IBS_TearID.DiligenceHammerTear.SubType,
	Name = {zh = '劳锤眼泪', en = 'Diligence Hammer Tear'}
}

--更新
function DiligenceHammerTear:OnTearUpdate(tear)
	tear.SpriteRotation = tear.FrameCount * 5

	--根据方向决定是否翻转
	local dir = -1
	dir = self._Maths:VectorToDirection(tear.Velocity:Normalized())

	if dir == Direction.LEFT or dir == Direction.UP then 
		tear.FlipX = true
	else
		tear.FlipX = false
	end		
end
DiligenceHammerTear:AddCallback(ModCallbacks.MC_POST_TEAR_UPDATE, 'OnTearUpdate', DiligenceHammerTear.Variant)


--落地释放震荡波
function DiligenceHammerTear:OnRemove(ent)
	if (ent.Variant ~= DiligenceHammerTear.Variant or game:GetRoom():GetFrameCount() <= 0) then return end
	local tear = ent:ToTear()

	local shockwave = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.SHOCKWAVE, 0, tear.Position, Vector.Zero, tear.SpawnerEntity):ToEffect()
	shockwave:SetRadii(0, 35)
	shockwave:SetTimeout(10)
	shockwave.Parent = tear.SpawnerEntity
	game:ShakeScreen(10)

	--特效
	local effect = Isaac.Spawn(1000, 97, 0, tear.Position, Vector.Zero, tear):ToEffect()
	effect.SpriteScale = Vector(tear.Scale, tear.Scale)
	effect:GetSprite().Color = Color(1,1,0,1)
	sfx:Play(SoundEffect.SOUND_SCYTHE_BREAK, 1, 2, false, 0.5)
end
DiligenceHammerTear:AddCallback(ModCallbacks.MC_POST_ENTITY_REMOVE, 'OnRemove', EntityType.ENTITY_TEAR)


return DiligenceHammerTear