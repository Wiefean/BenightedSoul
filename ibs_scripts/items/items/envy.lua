--嫉妒

local mod = Isaac_BenightedSoul
local IBS_Item = mod.IBS_Item
local Stats = mod.IBS_Lib.Stats

local function Replac(pool, decrease, seed)
	for i = 0, Game():GetNumPlayers() -1 do
		local player = Isaac.GetPlayer(i)
		if player:HasCollectible(IBS_Item.envy) then
			local rng = player:GetCollectibleRNG(IBS_Item.envy)
			local num = player:GetCollectibleNum(IBS_Item.envy)
			local chance = 6*num
			if chance > 60 then chance = 60 end

			if rng:RandomInt(99)+1 <= chance then
				return IBS_Item.envy
			end
		end
	end
end
mod:AddPriorityCallback(ModCallbacks.MC_PRE_GET_COLLECTIBLE, CallbackPriority.EARLY, Replac)


mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, function(_,player,flag)
	if player:HasCollectible(IBS_Item.envy) then
		local num = player:GetCollectibleNum(IBS_Item.envy)
		if flag == CacheFlag.CACHE_SPEED then
			Stats:Speed(player, -0.15*num)
		end
		if flag == CacheFlag.CACHE_FIREDELAY then
			Stats:TearsModifier(player, -0.06*num)
		end
		if flag == CacheFlag.CACHE_DAMAGE then
			Stats:Damage(player, num)
		end
	end	
end)

