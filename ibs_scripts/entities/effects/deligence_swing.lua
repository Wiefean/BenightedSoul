--勤勤扫荡特效

local mod = Isaac_BenightedSoul
local IBS_EffectID = mod.IBS_EffectID

local game = Game()

local DeligenceSwing = mod.IBS_Class.Effect{
	Variant = IBS_EffectID.DeligenceSwing.Variant,
	SubType = IBS_EffectID.DeligenceSwing.SubType,
	Name = {zh = '勤勤扫荡', en = 'Deligence Swing'}
}

--生成
function DeligenceSwing:Spawn(pos, rotation, spawner)
	local effect = Isaac.Spawn(1000, self.Variant, 0, pos, Vector.Zero, spawner):ToEffect()
	effect:GetSprite().Rotation = rotation
	return effect
end

--初始化
function DeligenceSwing:OnEffectInit(effect)
	effect:GetSprite():Play('Swing'..math.random(1,2), true)
	effect.DepthOffset = 10 --使图层处于上层
end
DeligenceSwing:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, 'OnEffectInit', DeligenceSwing.Variant)

--更新
function DeligenceSwing:OnEffectUpdate(effect)
	local spr = effect:GetSprite()
	if spr:IsFinished('Swing1') or spr:IsFinished('Swing2') then
		effect:Remove()
	end
end
DeligenceSwing:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, 'OnEffectUpdate', DeligenceSwing.Variant)


return DeligenceSwing