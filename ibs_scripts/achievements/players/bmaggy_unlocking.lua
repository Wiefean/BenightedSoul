--解锁昧化抹大拉

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
	local paper = "bmaggy_unlock"

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

--抹大拉死在献祭房判定
local function TMaggyDeath(_,isLose)
	if isLose then
		if Game():GetRoom():GetType() == RoomType.ROOM_SACRIFICE then
			for i = 0, Game():GetNumPlayers() -1 do
				local playerType = Isaac.GetPlayer(i):GetPlayerType()
				if (playerType == 1) or (playerType == 22) then
					IBS_Data.GameState.Persis.maggySacrifice = true
					break
				end
			end
		end
	end	
end
mod:AddCallback(ModCallbacks.MC_POST_GAME_END, TMaggyDeath)

--检测下一局玩家一是否为抹大拉
local function IsMaggy(_,player)
	if IBS_Data.GameState.Persis.maggySacrifice then
		if IsUnlockable() then
			local playerType = Isaac.GetPlayer(0):GetPlayerType()
			if (playerType ~= 1) and (playerType ~= 22) then
				IBS_Data.GameState.Persis.maggySacrifice = false
				IBS_Data.GameState.Persis.maggyTimes = 0
				mod:SaveIBSData() --保存,以防万一
			else
				sfx:Play(IBS_Sound.angelbonus)
			end
		end	
	end	
end
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, IsMaggy)


--是否为自伤
local function IsSelfDamage(flag, source)
	if (flag & DamageFlag.DAMAGE_NO_PENALTIES > 0) then
		if (flag & DamageFlag.DAMAGE_RED_HEARTS > 0) or ((flag & DamageFlag.DAMAGE_CURSED_DOOR <= 0) and (flag & DamageFlag.DAMAGE_CHEST <= 0)) then 
			return true
		end
	end

	if (flag & DamageFlag.DAMAGE_IV_BAG > 0) then
		return true
	end

	if (flag & DamageFlag.DAMAGE_FAKE > 0) then
		return true
	end

	if source and source.Type == EntityType.ENTITY_SLOT then
		return true
	end	
	
	return false
end

--抹大拉自伤判定
local function MaggyTakeDMG(_,ent, amount, flag, source)
	local player = ent:ToPlayer()
	
	if player then
		local playerType = player:GetPlayerType()
		if (playerType == 1) or (playerType == 22) then
			if IBS_Data.GameState.Persis.maggySacrifice and IsSelfDamage(flag, source) and IsUnlockable() then
				local times = IBS_Data.GameState.Persis.maggyTimes
				
				if times < 26 then
					IBS_Data.GameState.Persis.maggyTimes = IBS_Data.GameState.Persis.maggyTimes + 1
				else
					if not IBS_Data.Setting["bmaggy"]["Unlocked"] then
						ShowPaper()
					end
					IBS_Data.GameState.Persis.maggySacrifice = false
					IBS_Data.GameState.Persis.maggyTimes = 0
					IBS_Data.Setting["bmaggy"]["Unlocked"] = true
					mod:SaveIBSData()
				end
			end
		end	
	end
end
mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, MaggyTakeDMG)



