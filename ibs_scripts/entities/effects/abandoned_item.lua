--遗弃道具

local mod = Isaac_BenightedSoul
local IBS_EffectID = mod.IBS_EffectID

local game = Game()

local AbandonedItem = mod.IBS_Class.Effect{
	Variant = IBS_EffectID.AbandonedItem.Variant,
	SubType = IBS_EffectID.AbandonedItem.SubType,
	Name = {zh = '遗弃道具', en = 'Abandoned Item'}
}

--生成
function AbandonedItem:Spawn(pos, gfx, velocity, spawner)
	local effect = Isaac.Spawn(1000, self.Variant, 0, pos, velocity or Vector.Zero, spawner):ToEffect()
	effect:GetSprite():ReplaceSpritesheet(0, gfx, true)
	return effect
end

--初始化
function AbandonedItem:OnEffectInit(effect)
	effect:GetSprite():Play('Disappear', true)
end
AbandonedItem:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, 'OnEffectInit', AbandonedItem.Variant)

--更新
function AbandonedItem:OnEffectUpdate(effect)
	local spr = effect:GetSprite()
	
	--闪烁
	if spr:IsEventTriggered('Blink') then
		spr.Color.A = 0.3
	else
		spr.Color.A = 1
	end
	
	if spr:IsFinished('Disappear') then
		effect:Remove()
	end
end
AbandonedItem:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, 'OnEffectUpdate', AbandonedItem.Variant)


return AbandonedItem