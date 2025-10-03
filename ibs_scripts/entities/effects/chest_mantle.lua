--箱子斗篷

local mod = Isaac_BenightedSoul
local IBS_EffectID = mod.IBS_EffectID

local game = Game()

local ChestMantle = mod.IBS_Class.Effect{
	Variant = IBS_EffectID.ChestMantle.Variant,
	SubType = IBS_EffectID.ChestMantle.SubType,
	Name = {zh = '箱子斗篷', en = 'Chest Mantle'}
}

--生成
function ChestMantle:Spawn(spawner)
	local effect = Isaac.Spawn(1000, self.Variant, self.SubType, spawner.Position, Vector.Zero, spawner):ToEffect()
	effect:FollowParent(spawner)
	effect.SpriteScale = 1.25 * spawner.SpriteScale
	effect:Update()
	return effect
end

--初始化
function ChestMantle:OnEffectInit(effect)
	effect:GetSprite():Play('Idle')
	effect.DepthOffset = 10 --使图层处于上层
end
ChestMantle:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, 'OnEffectInit', ChestMantle.Variant)

--更新
function ChestMantle:OnEffectUpdate(effect)
	local spr = effect:GetSprite()
	if spr:IsFinished('Idle') then
		effect:Remove()
	end
end
ChestMantle:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, 'OnEffectUpdate', ChestMantle.Variant)


return ChestMantle