-- 狻猊碎片

local mod = Isaac_BenightedSoul

local Memento = mod.IBS_Class.Item(mod.IBS_ItemID.Memento)

function Memento:PostPeffectUpdate(player)
	if not player:HasCollectible(self.ID) then return end
    if player.Damage < 7 then
        player.Damage = 7
    end
end
Memento:AddPriorityCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, CallbackPriority.LATE, 'PostPeffectUpdate')

return Memento