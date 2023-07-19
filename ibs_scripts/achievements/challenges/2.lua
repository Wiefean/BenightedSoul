--易碎品挑战
--(铁心部分代码写在bmaggy.lua)

local mod = Isaac_BenightedSoul
local IBS_Challenge = mod.IBS_Challenge
local BigBooks = mod.IBS_Lib.BigBooks

local LANG = Options.Language

--将其他主动道具移出道具池
local config = Isaac.GetItemConfig()
local function GetActiveItems()
	local results = {}
	local size = config:GetCollectibles().Size
	for i = 1,size do
		local itemConfig = config:GetCollectible(i)
		if (itemConfig and itemConfig.Type == ItemType.ITEM_ACTIVE) then
			table.insert(results, itemConfig.ID)
		end
	end
	
	return results
end
mod:AddPriorityCallback(ModCallbacks.MC_POST_GAME_STARTED, CallbackPriority.EARLY, function(_,isContinue)
	if (Isaac.GetChallenge() == IBS_Challenge.bc2) then
		local itemPool = Game():GetItemPool()
		if not isContinue then
			for _,item in pairs(GetActiveItems()) do
				itemPool:RemoveCollectible(item)
			end
		end
	end	
end)

--去美心化运动
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, function(_,player)
    if (Isaac.GetChallenge() == IBS_Challenge.bc2) then
        local game = Game()
        if player:GetActiveItem(2) == 45 then
            player:SetPocketActiveItem(0, ActiveSlot.SLOT_POCKET, false)
        end
    end
end)

--播放成就纸张动画
local function ShowPaper()
	local paper = "bmaggy_up"
	
	--检测语言(有必要吗)
	if LANG == "zh" then
		paper = paper.."_zh"
	end
	
	paper = paper..".png"	
	BigBooks:PlayPaper(paper)
end

--解锁条件
local function IsUnlockable(bossLevel)
	local Challenge = Isaac.GetChallenge() == IBS_Challenge.bc2
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

--完成
mod:AddCallback(ModCallbacks.MC_POST_NPC_DEATH , function()
	if IsUnlockable(8) then
		if not IBS_Data.Setting["bc2"] then			
			ShowPaper()
		end
		IBS_Data.Setting["bc2"] = true
		mod:SaveIBSData()
	end
end, EntityType.ENTITY_MOMS_HEART)

