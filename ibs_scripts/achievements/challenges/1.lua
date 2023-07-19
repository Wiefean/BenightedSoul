--乾坤十掷挑战

local mod = Isaac_BenightedSoul
local IBS_Challenge = mod.IBS_Challenge
local BigBooks = mod.IBS_Lib.BigBooks

local LANG = Options.Language


--播放成就纸张动画
local function ShowPaper()
	local paper = "bisaac_up"
	
	--检测语言
	if LANG == "zh" then
		paper = paper.."_zh"
	end
	
	paper = paper..".png"	
	BigBooks:PlayPaper(paper)
end

--解锁条件
local function IsUnlockable(bossLevel)
	local Challenge = Isaac.GetChallenge() == IBS_Challenge.bc1
	local bossRoom = Game():GetRoom():GetType() == RoomType.ROOM_BOSS
	local level = Game():GetLevel():GetStage()

	
	--特定挑战
	if Challenge then
		if bossLevel then --Boss房和楼层判定
			if bossRoom and level == bossLevel then
				return true
			end
		else
			return true
		end	
	end

	return false
end

--10次以撒魂
mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, function()
	if Isaac.GetChallenge() == (IBS_Challenge.bc1) then
		for i = 1,10 do
			Isaac.GetPlayer(0):UseCard(81, UseFlag.USE_NOANIM | UseFlag.USE_NOANNOUNCER | UseFlag.USE_MIMIC)
		end
					
		--移除烟雾特效
		local poof = Isaac.FindByType(EntityType.ENTITY_EFFECT, EffectVariant.POOF01)
		for i = 1, #poof do
			poof[i]:Remove()
		end		
	end
end)

--完成
mod:AddCallback(ModCallbacks.MC_POST_ENTITY_REMOVE , function()
	if IsUnlockable(6) then
		if not IBS_Data.Setting["bc1"] then			
			ShowPaper()
		end
		IBS_Data.Setting["bc1"] = true
		mod:SaveIBSData()
	end
end, EntityType.ENTITY_MOM)

