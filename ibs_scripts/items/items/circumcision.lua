--割礼

local mod = Isaac_BenightedSoul
local Stats = mod.IBS_Lib.Stats

local Circumcision = mod.IBS_Class.Item(mod.IBS_ItemID.Circumcision)

function Circumcision:OnEvaluateCache(player, flag)
	if player:HasCollectible(self.ID) then
		local num = player:GetCollectibleNum(self.ID)
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
end
Circumcision:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, 'OnEvaluateCache')


return Circumcision
