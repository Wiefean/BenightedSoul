--解锁D4D

local mod = Isaac_BenightedSoul
local IBS_Item = mod.IBS_Item
local EggBlackList = mod.EggBlackList
local BigBooks = mod.IBS_Lib.BigBooks

local LANG = Options.Language


--播放成就纸张动画
local function ShowPaper()
	local paper = "d4d"

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


--检测D4使用
local function RecorD4(_,col,rng,player,flags,slot)
	if (flags & UseFlag.USE_OWNED > 0) then --要求持有
		if not IBS_Data.Setting["d4dUnlocked"] and IsUnlockable() then --未解锁且能解锁成就时才记录 
			local data = mod:GetIBSData("Level")
			data.d4UsedTimes = data.d4UsedTimes or 1
			
			if data.d4UsedTimes < 4 then
				data.d4UsedTimes = data.d4UsedTimes + 1
			else
				ShowPaper()
				player:RemoveCollectible(284, true, slot)
				player:AddCollectible(IBS_Item.d4d)
				Game():ShowHallucination(60, Game():GetRoom():GetBackdropType()) --特效
				IBS_Data.Setting["d4dUnlocked"] = true
				mod:SaveIBSData()
			end
		end
	end	
end
mod:AddCallback(ModCallbacks.MC_USE_ITEM,RecorD4,284)