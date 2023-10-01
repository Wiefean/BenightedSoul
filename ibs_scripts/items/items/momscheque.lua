--妈妈的支票

local mod = Isaac_BenightedSoul
local IBS_Item = mod.IBS_Item
local Stats = mod.IBS_Lib.Stats

--直接使用无效
mod:AddCallback(ModCallbacks.MC_USE_ITEM, function()
	return {ShowAnim = false, Discharge = false}	
end, IBS_Item.momscheque)

--新层给钱
mod:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, function()
	local num = 0
	
	for i = 0, Game():GetNumPlayers() -1 do
		local player = Isaac.GetPlayer(i)
		if player:HasCollectible(IBS_Item.momscheque) then
			num = num + player:GetCollectibleNum(IBS_Item.momscheque)
		end
	end
	
	if num > 0 then Isaac.GetPlayer(0):AddCoins(7*num) SFXManager():Play(SoundEffect.SOUND_CASH_REGISTER) end
end)

--属性
mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, function(_,player, flag)
	if player:HasCollectible(IBS_Item.momscheque) then
		local num = player:GetCollectibleNum(IBS_Item.momscheque)
		if flag == CacheFlag.CACHE_LUCK then
			Stats:Luck(player, num)
		end
	end	
end)


