--解锁昧化参孙

local mod = Isaac_BenightedSoul
local CharacterLock = mod.IBS_Class.CharacterLock

local game = Game()
local sfx = SFXManager()

local BSamson = CharacterLock(mod.IBS_PlayerID.BSamson, {'bsamson_unlock'} )

--进入宝箱房判定
function BSamson:OnNewRoom()
	if self:IsUnlocked() then return end
	if game:IsGreedMode() then return end
	if game:AchievementUnlocksDisallowed() then return end
	if game:GetRoom():GetType() == RoomType.ROOM_TREASURE then	
		local data = mod:GetIBSData("temp")
		data.PauseUnlockingBSamson = true
	end
end
BSamson:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, 'OnNewRoom')


--新层触发
function BSamson:OnNewLevel()
	if self:IsUnlocked() then return end
	if game:IsGreedMode() then return end
	if game:AchievementUnlocksDisallowed() then return end
	if not PlayerManager.AnyoneIsPlayerType(PlayerType.PLAYER_SAMSON) then return end
	local data = mod:GetIBSData("temp")
	
	if not data.PauseUnlockingBSamson then
		data.NoTreasureForBSamsonNum = (data.NoTreasureForBSamsonNum or 0) + 1
	end
	data.PauseUnlockingBSamson = nil
	
	if data.NoTreasureForBSamsonNum and data.NoTreasureForBSamsonNum == 2 then
		self:DelayFunction(function()		
			game:GetHUD():ShowFortuneText(self:ChooseLanguage(
				'妈妈在注视你',
				'Mom is watching you'
			))
			sfx:Play(mod.IBS_Sound.SecretFound, 1.5)
		end, 1)
	end
end
BSamson:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, 'OnNewLevel')

--击败妈腿判定
function BSamson:BeatMom()
	if self:IsUnlocked() then return end
	if game:IsGreedMode() then return end
	if game:AchievementUnlocksDisallowed() then return end
	if game:GetRoom():GetBossID() ~= BossType.MOM then return end
	if not PlayerManager.AnyoneIsPlayerType(PlayerType.PLAYER_SAMSON) then return end
	local data = mod:GetIBSData("temp")

	if data.NoTreasureForBSamsonNum and data.NoTreasureForBSamsonNum >= 2 then
		self:Unlock(true, true)
	end
end
BSamson:AddCallback(ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD, 'BeatMom')

return BSamson