--愤怒的悠悠

local mod = Isaac_BenightedSoul

local game = Game()

local MMS = mod.IBS_Class.Trinket(mod.IBS_TrinketID.MMS)

function MMS:OnNPCDeath(npc)
	if npc.Type ~= 271 and npc.Type ~= 272 then return end
	if npc.Variant > 1 then return end
	
	local data = self:GetIBSData("level")
	if not data.MMSActivated then
		data.MMSActivated = true	
		for i = 0, game:GetNumPlayers() - 1 do
			local player = Isaac.GetPlayer(i)
			if player:HasTrinket(self.ID) then
				player:AddCacheFlags(CacheFlag.CACHE_DAMAGE, true)
			end
		end
	end
end
MMS:AddCallback(ModCallbacks.MC_POST_NPC_DEATH, "OnNPCDeath")

--伤害加成
function MMS:OnEvaluateCache(player, flag)
	if (flag == CacheFlag.CACHE_DAMAGE) and player:HasTrinket(self.ID) then
		if self:GetIBSData("level").MMSActivated then		
			local mult = player:GetTrinketMultiplier(self.ID)
			self._Stats:Damage(player, 4*mult)
		end
	end
end
MMS:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, 'OnEvaluateCache')

return MMS