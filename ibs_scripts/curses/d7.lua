--七面骰诅咒

local mod = Isaac_BenightedSoul

local D7 = mod.IBS_Class.Curse(mod.IBS_CurseID.D7)

local game = Game()


--为每个房间使用特定种子
local rng = RNG()
rng:SetSeed(1)
function D7:RefreshSeed()
	rng:SetSeed(self._Levels:GetRoomUniqueSeed())
end
D7:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, 'RefreshSeed')


--重置房间
function D7:RerollRoom()
	if not game:IsGreedMode() then
		local room = game:GetRoom()
		if self:IsApplied() and (room:GetType() == RoomType.ROOM_DEFAULT) then
			if rng:RandomInt(100) < 25 then
				room:RespawnEnemies()

				--撞脸预防
				for _,ent in ipairs(Isaac.GetRoomEntities()) do
					if self._Ents:IsEnemy(ent, true, true) then
						ent:AddEntityFlags(EntityFlag.FLAG_AMBUSH)
					end
				end			
			end
		end
	end	
end
D7:AddCallback(ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD, 'RerollRoom')



return D7