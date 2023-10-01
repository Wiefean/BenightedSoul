--割礼

local mod = Isaac_BenightedSoul
local IBS_Item = mod.IBS_Item
local Stats = mod.IBS_Lib.Stats

mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, function(_,player,flag)
	if player:HasCollectible(IBS_Item.circumcision) then
		local num = player:GetCollectibleNum(IBS_Item.circumcision)
		if flag == CacheFlag.CACHE_SPEED then
			Stats:Speed(player, -0.7*num)
		end
		if flag == CacheFlag.CACHE_FIREDELAY then
			Stats:TearsMultiples(player, 2)
		end
		if flag == CacheFlag.CACHE_LUCK then
			Stats:Luck(player, 2*num)
		end
	end	
end)

