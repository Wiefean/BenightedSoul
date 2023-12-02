--解锁昧化犹大

local mod = Isaac_BenightedSoul
local IBS_Callback = mod.IBS_Callback
local IBS_Item = mod.IBS_Item
local IBS_Player = mod.IBS_Player
local IBS_Sound = mod.IBS_Sound
local EggBlackList = mod.EggBlackList
local BigBooks = mod.IBS_Lib.BigBooks

local sfx = SFXManager()

local LANG = Options.Language


--播放成就纸张动画
local function ShowPaper()
	for i = 1,2 do
		local paper = "bjudas_unlock"
		if i == 2 then paper = "bc4" end

		--检测语言
		if LANG == "zh" then
			paper = paper.."_zh"
		end
		
		paper = paper..".png"	
		BigBooks:PlayPaper(paper)
	end
end

--是否为犹大
local function IsJudas(player)
	local playerType = player:GetPlayerType()
	return (playerType == 3) or (playerType == 12) or (playerType == 24)
end

--摧毁镜子进入解锁流程及提示音效
local function EndPersonator()
	if not IBS_Data.Setting["bjudas"]["Unlocked"] then
		for i = 0, Game():GetNumPlayers() -1 do
			local player = Isaac.GetPlayer(i)
			if IsJudas(player) then
				sfx:Play(IBS_Sound.secretfound)
				break
			end	
		end		
	end	
end
mod:AddCallback(IBS_Callback.MIRROR_BROKEN, EndPersonator)

--检测解锁条件
local function IsUnlockable(bossLevel)
	local notInChallenge = Isaac.GetChallenge() <= 0
	local notCustomSeed = Game():GetSeeds():IsCustomRun() == false
	local notInLap = Game():GetVictoryLap() <= 0
	local level = Game():GetLevel():GetStage()
	
	--考虑不能达成成就的彩蛋种子
	for _,egg in ipairs(EggBlackList) do
		if (Game():GetSeeds():HasSeedEffect(egg)) then
			return false
		end
	end
	
	--非自定种子,非挑战,非跑圈
	if notCustomSeed and notInChallenge and notInLap then
		if bossLevel then --楼层判定
			if level == bossLevel then
				return true
			end
		else
			return true
		end	
	end

	return false
end

--犹大击败教条判定
local function EndPersonator2(_,ent)
	if (ent.Variant == 0 or ent.Variant == 1) and (ent.SubType == 0) then
		if IsUnlockable(13) then
			for i = 0, Game():GetNumPlayers() -1 do
				local player = Isaac.GetPlayer(i)
				if IsJudas(player) then
					if mod:GetIBSData("Temp").MirrorBroken then
						if not IBS_Data.Setting["bjudas"]["Unlocked"] then
							ShowPaper()
						end
						IBS_Data.Setting["bjudas"]["Unlocked"] = true
						mod:SaveIBSData()	
					end
					break
				end
			end
		end	
	end	
end
mod:AddCallback(ModCallbacks.MC_POST_ENTITY_KILL, EndPersonator2, EntityType.ENTITY_DOGMA)
mod:AddCallback(ModCallbacks.MC_POST_NPC_DEATH, EndPersonator2, EntityType.ENTITY_DOGMA)
