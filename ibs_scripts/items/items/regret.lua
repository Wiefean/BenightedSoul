--死不瞑目

local mod = Isaac_BenightedSoul

local game = Game()
local Stats = mod.IBS_Lib.Stats

local Regret = mod.IBS_Class.Item(mod.IBS_ItemID.Regret)

--死亡加属性
function Regret:OnPlayerKilled(ent)
	local player = ent:ToPlayer()
	if player and player:HasCollectible(self.ID) then
		Stats:PersisSpeed(player, 0.1)
		Stats:PersisTearsModifier(player, 0.35)
		Stats:PersisDamage(player, 1)
		player:AddCacheFlags(CacheFlag.CACHE_ALL, true)
	end
end
Regret:AddCallback(ModCallbacks.MC_POST_ENTITY_KILL, 'OnPlayerKilled', EntityType.ENTITY_PLAYER)


--正邪增强(东方mod)
function Regret:OnNewLevel()
	for i = 0, game:GetNumPlayers() -1 do
		local player = Isaac.GetPlayer(i)
		if player:HasCollectible(self.ID) and mod.IBS_Compat.THI:SeijaBuff(player) then
			local seijaBLevel = mod.IBS_Compat.THI:GetSeijaBLevel(player)
			if seijaBLevel > 1 then
				for i = 1,seijaBLevel-1 do
					player:AddCard(89)
				end
			end
			if not player:HasCollectible(11, true) then			
				player:AddCollectible(11)
			end
		end
	end
end
Regret:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, 'OnNewLevel')



return Regret