--黑魔咒

local mod = Isaac_BenightedSoul

local game = Game()

local BlackCharm = mod.IBS_Class.Trinket(mod.IBS_TrinketID.BlackCharm)


--记录诅咒房进入状态
function BlackCharm:OnNewRoom()
	if game:GetRoom():GetType() == RoomType.ROOM_CURSE then
		local data = self:GetIBSData('level')
		if not data.BlackCharmTriggered then
			data.BlackCharmTriggered = true
			
			--刷新属性
			for i = 0, game:GetNumPlayers() - 1 do
				local player = Isaac.GetPlayer(i)
				if player:HasTrinket(self.ID) then
					player:AddCacheFlags(CacheFlag.CACHE_DAMAGE, true)
				end
			end
			
		end
	end
end
BlackCharm:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, 'OnNewRoom')


--属性
function BlackCharm:OnEvaluateCache(player, flag)
	if not player:HasTrinket(self.ID) then return end
	if (flag == CacheFlag.CACHE_DAMAGE) then
		local data = self:GetIBSData('level')
		local dmg = 0
		
		if data.BlackCharmTriggered then
			dmg = dmg + 0.6*player:GetTrinketMultiplier(self.ID)
		end
		
		--有诅咒时
		if game:GetLevel():GetCurses() > 0 then
			dmg = dmg + 2.4
		end
		
		if dmg > 0 then		
			self._Stats:Damage(player, dmg)
		end
	end	
end
BlackCharm:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, 'OnEvaluateCache')


return BlackCharm