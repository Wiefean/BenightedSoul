--活动肌肉

local mod = Isaac_BenightedSoul

local Flex = mod.IBS_Class.Item(mod.IBS_ItemID.Flex)

local game = Game()

--清理房间切换触发状态
function Flex:OnRoomCleaned()
	for i = 0, game:GetNumPlayers() - 1 do
		local player = Isaac.GetPlayer(i)
		if player:HasCollectible(self.ID) then
			local data = self._Players:GetData(player)
			data.FlexPause = (not data.FlexPause)
			player:AddCacheFlags(CacheFlag.CACHE_DAMAGE, true)
		end
	end
end
Flex:AddCallback(ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD, 'OnRoomCleaned')

--属性
function Flex:OnEvaluateCache(player, flag)
	if player:HasCollectible(self.ID) then
		if flag == CacheFlag.CACHE_DAMAGE then		
			player.Damage = player.Damage + 0.5
			if not self._Players:GetData(player).FlexPause then			
				player.Damage = player.Damage + 2
			end
		end
	end	
end
Flex:AddPriorityCallback(ModCallbacks.MC_EVALUATE_CACHE, 200, 'OnEvaluateCache')


return Flex
