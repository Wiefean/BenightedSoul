--解锁昧化以撒

local mod = Isaac_BenightedSoul
local CharacterLock = mod.IBS_Class.CharacterLock

local game = Game()
local sfx = SFXManager()

local BIsaac = CharacterLock(mod.IBS_PlayerID.BIsaac, {'bisaac_unlock', 'bc1'} )


--以撒死在撒但房间判定
function BIsaac:IsaacSatanDeath(isLose)
	local data = mod:GetIBSData("persis")

	if (not data.isaacSatanDeath) and self:IsLocked() and isLose and (game:GetRoom():GetBossID() == BossType.SATAN) then
		for i = 0, game:GetNumPlayers() -1 do
			local playerType = Isaac.GetPlayer(i):GetPlayerType()

			if (playerType == PlayerType.PLAYER_ISAAC) or (playerType == PlayerType.PLAYER_ISAAC_B) then
				data.isaacSatanDeath = true
				break
			end
		end
	end	
end
BIsaac:AddCallback(ModCallbacks.MC_POST_GAME_END, 'IsaacSatanDeath')


--检测下一局玩家一是否为表里以撒
function BIsaac:SeeIsaac(isContinue)
	if (not isContinue) and self:IsLocked() and not game:AchievementUnlocksDisallowed() then
		local data = mod:GetIBSData("persis")

		if data.isaacSatanDeath then
			local playerType = Isaac.GetPlayer(0):GetPlayerType()

			if (playerType ~= PlayerType.PLAYER_ISAAC) and (playerType ~= PlayerType.PLAYER_ISAAC_B) then
				data.isaacSatanDeath = false
				mod:SaveIBSData()
			else
				sfx:Play(mod.IBS_Sound.SecretFound, 1.5)
			end
		end
	end	
end
BIsaac:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, 'SeeIsaac')

--以撒击败撒旦判定
function BIsaac:IsaacBeatSatan()
	if self:IsLocked() and not game:AchievementUnlocksDisallowed()  then
		local data = mod:GetIBSData("persis")

		if data.isaacSatanDeath and (game:GetRoom():GetBossID() == BossType.SATAN) then
			for i = 0, game:GetNumPlayers() -1 do
				local playerType = Isaac.GetPlayer(i):GetPlayerType()

				if (playerType == PlayerType.PLAYER_ISAAC) or (playerType == PlayerType.PLAYER_ISAAC_B) then
					data.isaacSatanDeath = false
					self:Unlock(true, true)
					break
				end
			end
		end
	end
end
BIsaac:AddCallback(ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD, 'IsaacBeatSatan')


return BIsaac