--扫荡特效

local mod = Isaac_BenightedSoul
local IBS_EffectID = mod.IBS_EffectID

local game = Game()

local Swing = mod.IBS_Class.Effect{
	Variant = IBS_EffectID.Swing.Variant,
	SubType = IBS_EffectID.Swing.SubType,
	Name = {zh = '扫荡', en = 'Swing'}
}

--生成
function Swing:Spawn(pos, rotation, spawner)
	local effect = Isaac.Spawn(1000, self.Variant, 0, pos, Vector.Zero, spawner):ToEffect()
	effect:GetSprite().Rotation = rotation
	return effect
end

--初始化
function Swing:OnEffectInit(effect)
	effect:GetSprite():Play('Swing'..math.random(1,2), true)
	effect.DepthOffset = 10 --使图层处于上层
end
Swing:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, 'OnEffectInit', Swing.Variant)

--更新
function Swing:OnEffectUpdate(effect)
	local spr = effect:GetSprite()
	if spr:IsFinished('Swing1') or spr:IsFinished('Swing2') then
		effect:Remove()
	end
end
Swing:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, 'OnEffectUpdate', Swing.Variant)


return Swing