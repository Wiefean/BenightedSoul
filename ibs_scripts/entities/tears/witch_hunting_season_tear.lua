--猎巫时节特效眼泪

local mod = Isaac_BenightedSoul
local IBS_TearID = mod.IBS_TearID

local WitchHuntingSeasonTear = mod.IBS_Class.Tear{
	Variant = IBS_TearID.WitchHuntingSeasonTear.Variant,
	SubType = IBS_TearID.WitchHuntingSeasonTear.SubType,
	Name = {zh = '猎巫时节特效眼泪', en = 'Witch-Hunting Season Tear'}
}

--动画名称来自witch_hunting_season_tear.anm2
WitchHuntingSeasonTear.SizeAnimations = {
	{MaxSize = 3.85, Name = 'Tear1'},
	{MaxSize = 5.6, Name = 'Tear2'},
	{MaxSize = 7.35, Name = 'Tear3'},
	{MaxSize = 9.975, Name = 'Tear4'},
	{MaxSize = 13.475, Name = 'Tear5'},
	{MaxSize = 17.85, Name = 'Tear6'},
	{Name = 'Tear7'},
}

function WitchHuntingSeasonTear:GetSpriteAnimation(size)
	for _, info in ipairs(self.SizeAnimations) do
		if not info.MaxSize or size <= info.MaxSize then
			return info.Name
		end
	end
	return 'Tear7'
end

function WitchHuntingSeasonTear:PlaySizeAnimation(tear)
	tear:GetSprite():Play(self:GetSpriteAnimation(tear.Size), true)
end

function WitchHuntingSeasonTear:OnTearInit(tear)
	self:PlaySizeAnimation(tear)
end
WitchHuntingSeasonTear:AddCallback(ModCallbacks.MC_POST_TEAR_INIT, 'OnTearInit', WitchHuntingSeasonTear.Variant)

function WitchHuntingSeasonTear:OnTearUpdate(tear)
	self:PlaySizeAnimation(tear)
end
WitchHuntingSeasonTear:AddCallback(ModCallbacks.MC_POST_TEAR_UPDATE, 'OnTearUpdate', WitchHuntingSeasonTear.Variant)

--落地特效与音效
function WitchHuntingSeasonTear:OnRemove(entity)
	local tear = entity:ToTear()
	if not tear or tear.Variant ~= WitchHuntingSeasonTear.Variant then return end

	local entity = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.SCYTHE_BREAK, 0,
		tear.Position, Vector.Zero, tear)
	local effect = entity and entity:ToEffect()
	if not effect then return end

	local sprite = effect:GetSprite()
	sprite.Scale = Vector(tear.Scale, tear.Scale) * 0.7
	sprite:SetFrame(2)
	sprite.Color = tear.Color

	SFXManager():Play(SoundEffect.SOUND_SCYTHE_BREAK, 0.5, 2, false, 15 / (tear.Size + 3), 0)
end
WitchHuntingSeasonTear:AddCallback(ModCallbacks.MC_POST_ENTITY_REMOVE, 'OnRemove', EntityType.ENTITY_TEAR)

return WitchHuntingSeasonTear
