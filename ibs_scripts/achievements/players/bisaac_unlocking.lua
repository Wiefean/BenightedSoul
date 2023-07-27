--解锁昧化以撒

local mod = Isaac_BenightedSoul
local IBS_Item = mod.IBS_Item
local IBS_Player = mod.IBS_Player
local IBS_Sound = mod.IBS_Sound
local EggBlackList = mod.EggBlackList
local BigBooks = mod.IBS_Lib.BigBooks

local sfx = SFXManager()

local LANG = Options.Language


--播放成就纸张动画
local function ShowPaper()
	local paper = "bisaac_unlock"

	--检测语言
	if LANG == "zh" then
		paper = paper.."_zh"
	end
	
	paper = paper..".png"	
	BigBooks:PlayPaper(paper)
end

--检测解锁条件
local function IsUnlockable()
	local notInChallenge = Isaac.GetChallenge() <= 0
	local notCustomSeed = Game():GetSeeds():IsCustomRun() == false
	local notInLap = Game():GetVictoryLap() <= 0
	local bossRoom = Game():GetRoom():GetType() == RoomType.ROOM_BOSS
	local level = Game():GetLevel():GetStage()
	
	--考虑不能达成成就的彩蛋种子
	for _,egg in ipairs(EggBlackList) do
		if (Game():GetSeeds():HasSeedEffect(egg)) then
			return false
		end
	end
	
	--非自定种子,非挑战,非跑圈
	if notCustomSeed and notInChallenge and notInLap then
		return true
	end

	return false
end

--以撒死在撒但房间判定
local function TIsaacDeathInSatanRoom(_,isLose)
	if isLose then
		if Game():GetRoom():GetBossID() == 24 then
			for i = 0, Game():GetNumPlayers() -1 do
				local playerType = Isaac.GetPlayer(i):GetPlayerType()
				if (playerType == 0) or (playerType == 21) then
					IBS_Data.GameState.Persis.isaacSatanDeath = true
					break
				end
			end
		end
	end	
end
mod:AddCallback(ModCallbacks.MC_POST_GAME_END, TIsaacDeathInSatanRoom)


--检测下一局玩家一是否为以撒
local function IsIsaac(_,player)
	if IBS_Data.GameState.Persis.isaacSatanDeath then
		if IsUnlockable() then
			local playerType = Isaac.GetPlayer(0):GetPlayerType()
			if (playerType ~= 0) and (playerType ~= 21) then
				IBS_Data.GameState.Persis.isaacSatanDeath = false
				mod:SaveIBSData() --保存,以防万一
			else
				sfx:Play(IBS_Sound.angelbonus)
			end
		end	
	end	
end
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, IsIsaac)

--以撒击败撒旦判定
local function IsaacBeatSatan()
	if IBS_Data.GameState.Persis.isaacSatanDeath then
		if Game():GetRoom():GetBossID() == 24 then
			if IsUnlockable() then
				for i = 0, Game():GetNumPlayers() -1 do
					local playerType = Isaac.GetPlayer(i):GetPlayerType()
					if (playerType == 0) or (playerType == 21) then
						if not IBS_Data.Setting["bisaac"]["Unlocked"] then
							ShowPaper()
						end
						IBS_Data.GameState.Persis.isaacSatanDeath = false
						IBS_Data.Setting["bisaac"]["Unlocked"] = true
						mod:SaveIBSData()
						break
					end
				end
			end
		end
	end
end
mod:AddCallback(ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD, IsaacBeatSatan)