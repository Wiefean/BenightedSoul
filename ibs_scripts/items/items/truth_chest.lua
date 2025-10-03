--真理宝箱(其他效果在真理小子albern.lua文件)

local mod = Isaac_BenightedSoul
local Stats = mod.IBS_Lib.Stats

local TruthChest = mod.IBS_Class.Item(mod.IBS_ItemID.TruthChest)

--属性
function TruthChest:OnEvaluateCache(player, flag)
	if player:HasCollectible(self.ID) then
		local num = player:GetCollectibleNum(self.ID)
		if flag == CacheFlag.CACHE_RANGE then
			Stats:Range(player, 1.5*num)
		end
		if flag == CacheFlag.CACHE_LUCK then
			Stats:Luck(player, 3*num)
		end
	end	
end
TruthChest:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, 'OnEvaluateCache')


return TruthChest
