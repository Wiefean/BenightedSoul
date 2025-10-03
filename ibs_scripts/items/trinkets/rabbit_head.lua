--兔头

local mod = Isaac_BenightedSoul

local RabbitHead = mod.IBS_Class.Trinket(mod.IBS_TrinketID.RabbitHead)

--幸运加成
function RabbitHead:OnEvaluateCache(player, flag)
	if Game():GetRoom():GetType() == RoomType.ROOM_DEFAULT then
		if (flag == CacheFlag.CACHE_LUCK) and player:HasTrinket(self.ID) then
			local mult = player:GetTrinketMultiplier(self.ID)
			self._Stats:Luck(player, 3.5*mult)
		end	
	end
end
RabbitHead:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, 'OnEvaluateCache')


return RabbitHead