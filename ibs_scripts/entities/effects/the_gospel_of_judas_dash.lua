--犹大福音冲刺特效

local mod = Isaac_BenightedSoul
local IBS_EffectID = mod.IBS_EffectID

local game = Game()
local sfx = SFXManager()

local TGOJDash = mod.IBS_Class.Effect{
	Variant = IBS_EffectID.TGOJDash.Variant,
	SubType = IBS_EffectID.TGOJDash.SubType,
	Name = {zh = '犹大福音冲刺特效', en = 'The Gospel Of Judas Dash'}
}

--初始化
function TGOJDash:OnEffectInit(effect)
	effect:GetSprite():Play('Start', true)
	effect.DepthOffset = 65 --使图层处于上层
end
TGOJDash:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, 'OnEffectInit', TGOJDash.Variant)

--更新
function TGOJDash:OnEffectUpdate(effect)
	local spr = effect:GetSprite()

	if spr:IsFinished('Start') then
		spr:Play('Idle')
	end
	
	if not effect.Parent then
		spr:Play('End')
	end

	if spr:IsFinished('End') then
		effect:Remove()
	end
end
TGOJDash:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, 'OnEffectUpdate', TGOJDash.Variant)


return TGOJDash