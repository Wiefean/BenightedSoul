--面包

local mod = Isaac_BenightedSoul
local Stats = mod.IBS_Lib.Stats

local Bread = mod.IBS_Class.Item(mod.IBS_ItemID.Bread)

--属性
function Bread:OnEvaluateCache(player, flag)
	if player:HasCollectible(self.ID) then
		local num = player:GetCollectibleNum(self.ID)
		if flag == CacheFlag.CACHE_SPEED then
			Stats:Speed(player, -0.02*num)
		end
		if flag == CacheFlag.CACHE_DAMAGE then
			Stats:Damage(player, 0.3*num)
		end	
		if flag == CacheFlag.CACHE_SHOTSPEED then
			Stats:ShotSpeed(player, -0.03*num)
		end		
		if flag == CacheFlag.CACHE_LUCK then
			Stats:Luck(player, 0.5*num)
		end
	end	
end
Bread:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, 'OnEvaluateCache')


return Bread
