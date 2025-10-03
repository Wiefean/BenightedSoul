--铅制心脏

local mod = Isaac_BenightedSoul
local IronHeart = mod.IBS_Class.IronHeart()
local TempIronHeart = mod.IBS_Class.TempIronHeart()

local game = Game()

local LeadenHeart = mod.IBS_Class.Item(mod.IBS_ItemID.LeadenHeart)

--获得
function LeadenHeart:OnGainItem(item, charge, first, slot, varData, player)
	if first then
		player:AddBrokenHearts(1)
		
		--表表抹
		if player:GetPlayerType() == (mod.IBS_PlayerID.BMaggy) then
			local data = IronHeart:GetData(player)
			data.Extra = data.Extra + 28
		else
			local data = TempIronHeart:GetData(player)
			data.Num = data.Num + 28
		end		
	end
end
LeadenHeart:AddCallback(ModCallbacks.MC_POST_ADD_COLLECTIBLE, 'OnGainItem', LeadenHeart.ID)


--新楼层给予临时铁心
function LeadenHeart:AddIronHeart()
	for i = 0, game:GetNumPlayers() -1 do
		local player = Isaac.GetPlayer(i)
		if player:HasCollectible(self.ID) then
			--表表抹
			if player:GetPlayerType() == (mod.IBS_PlayerID.BMaggy) then
				local data = IronHeart:GetData(player)
				data.Extra = data.Extra + 28
			else
				local data = TempIronHeart:GetData(player)
				data.Num = data.Num + 28
			end
		end
	end
end
LeadenHeart:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, 'AddIronHeart')

--移速下降
function LeadenHeart:OnEvaluateCache(player, flag)
	if (flag == CacheFlag.CACHE_SPEED) and player:HasCollectible(self.ID) then
		self._Stats:Speed(player, -0.15)
	end
end
LeadenHeart:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, 'OnEvaluateCache')


return LeadenHeart
