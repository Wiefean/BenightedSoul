--某纪念品

local mod = Isaac_BenightedSoul

local Memento = mod.IBS_Class.Item(mod.IBS_ItemID.Memento)

--属性
function Memento:OnEvaluateCache(player, flag)
	if (flag & CacheFlag.CACHE_DAMAGE > 0) and player:HasCollectible(self.ID) then
		if player.Damage < 7 then
			player.Damage = 7
		end
	end
end
Memento:AddPriorityCallback(ModCallbacks.MC_EVALUATE_CACHE, CallbackPriority.LATE, 'OnEvaluateCache')

return Memento