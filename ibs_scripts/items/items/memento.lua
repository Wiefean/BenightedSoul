--某纪念品

local mod = Isaac_BenightedSoul

local Memento = mod.IBS_Class.Item(mod.IBS_ItemID.Memento)

--属性
function Memento:OnPEffectUpdate(player)
	if player:HasCollectible(self.ID) and player.Damage < 7 then
		player.Damage = 7
	end
end
Memento:AddPriorityCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, CallbackPriority.LATE, 'OnPEffectUpdate')

return Memento