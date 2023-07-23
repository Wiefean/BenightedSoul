--用于播放掉落物拾取动画

local mod = Isaac_BenightedSoul

local Variant = Isaac.GetEntityVariantByName("IBS_PickingUp")

mod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, function(_,effect)
    if (effect:GetSprite():IsFinished("Collect")) then
        effect:Remove()
    end
end, Variant)
