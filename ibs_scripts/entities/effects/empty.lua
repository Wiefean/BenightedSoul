--空效果,一般用于播放其他实体的动画

local mod = Isaac_BenightedSoul
local IBS_EffectID = mod.IBS_EffectID

local Empty = mod.IBS_Class.Effect{
	Variant = IBS_EffectID.Empty.Variant,
	SubType = IBS_EffectID.Empty.SubType,
	Name = {zh = '空', en = 'Empty'}
}

function Empty:OnEffectUpdate(effect)
    if (effect.Timeout <= 0) and (effect.Timeout ~= -1) then
        effect:Remove()
    end
end
Empty:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, 'OnEffectUpdate', Empty.Variant)


return Empty