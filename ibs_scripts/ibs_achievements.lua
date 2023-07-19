--成就系统


--加载
local function LoadScripts(scripts)
    for _, v in ipairs(scripts) do
        include("ibs_scripts.achievements."..v)
    end
end

local achiev = {
	"marks",
	"rules",
	
	"challenges.1",
	"challenges.2",
	
	"items.items.d4d_unlocking",
	
	"players.bisaac_unlocking",
	"players.bmaggy_unlocking",
}
LoadScripts(achiev)


local mod = Isaac_BenightedSoul
local IBS_Item = mod.IBS_Item
local IBS_Trinket = mod.IBS_Trinket
local IBS_Pocket = mod.IBS_Pocket
local IBS_Challenge = mod.IBS_Challenge
local IBS_Player = mod.IBS_Player
local BigBooks = mod.IBS_Lib.BigBooks

local LANG = Options.Language

--通过其他方式解锁的道具
local OtherItem = {

["d4dUnlocked"] = (IBS_Item.d4d)

}

--通过打标解锁的道具
local MarkItem = {

["bisaac"] = {
Delirium = (IBS_Item.ld6),
Beast = (IBS_Item.nop),
Greed = (IBS_Item.ssg),
},

["bmaggy"] = {
Delirium = (IBS_Item.gheart),
Beast = (IBS_Item.diamoond),
Greed = (IBS_Item.chocolate),
},

}

--通过打标解锁的饰品
local MarkTrinket = {

["bisaac"] = {
	IBSL = (IBS_Trinket.bottleshard),
	Witness = (IBS_Trinket.dadspromise),
},

["bmaggy"] = {
	IBSL = (IBS_Trinket.divineretaliation),
	Witness = (IBS_Trinket.toughheart),
},

}

--通过打标解锁的口袋物品(不包含药丸)
local MarkPocket = {

["bisaac"] = {
	MegaSatan = (IBS_Pocket.czd6),
},

}

--通过打标解锁的挑战
local MarkChallenge = {

[IBS_Challenge.bc1] = "bisaac",
[IBS_Challenge.bc2] = "bmaggy",

}

do --处理通过打标解锁的物品(不考虑不解锁对应物品的标记)

--将未解锁的道具和饰品从池中移除
mod:AddPriorityCallback(ModCallbacks.MC_POST_GAME_STARTED, CallbackPriority.EARLY, function(_,isContinue)
	local itemPool = Game():GetItemPool()
	
	if not isContinue then
		for key,item in pairs(MarkItem) do --道具
			local mark = IBS_Data.Setting[key]
			if item.IBSL and not (mark.Isaac and mark.BlueBaby and mark.Satan and mark.Lamb) then
				itemPool:RemoveCollectible(item.IBSL)
			end	
			if item.MegaSatan and not mark.MegaSatan then
				itemPool:RemoveCollectible(item.MegaSatan)
			end		
			if item.Delirium and not mark.Delirium then
				itemPool:RemoveCollectible(item.Delirium)
			end
			if item.Witness and not mark.Witness then
				itemPool:RemoveCollectible(item.Witness)
			end		
			if item.Beast and not mark.Beast then
				itemPool:RemoveCollectible(item.Beast)
			end	
			if item.Greed and not mark.Greed then
				itemPool:RemoveCollectible(item.Greed)
			end		
		end
		for key,trinket in pairs(MarkTrinket) do --饰品
			local mark = IBS_Data.Setting[key]
			if trinket.IBSL and not (mark.Isaac and mark.BlueBaby and mark.Satan and mark.Lamb) then
				itemPool:RemoveTrinket(trinket.IBSL)
			end	
			if trinket.MegaSatan and not mark.MegaSatan then
				itemPool:RemoveTrinket(trinket.MegaSatan)
			end		
			if trinket.Delirium and not mark.Delirium then
				itemPool:RemoveTrinket(trinket.Delirium)
			end
			if trinket.Witness and not mark.Witness then
				itemPool:RemoveTrinket(trinket.Witness)
			end		
			if trinket.Beast and not mark.Beast then
				itemPool:RemoveTrinket(trinket.Beast)
			end	
			if trinket.Greed and not mark.Greed then
				itemPool:RemoveTrinket(trinket.Greed)
			end		
		end	
	end
end)

--避免从池中抽取未解锁道具
mod:AddPriorityCallback(ModCallbacks.MC_POST_GET_COLLECTIBLE, CallbackPriority.EARLY, function(_,id,pool,decrease,seed)
	local itemPool = Game():GetItemPool()

	for key,item in pairs(MarkItem) do
		local mark = IBS_Data.Setting[key]
		if item.IBSL and id == item.IBSL and not (mark.Isaac and mark.BlueBaby and mark.Satan and mark.Lamb) then
			itemPool:RemoveCollectible(item.IBSL)
			return itemPool:GetCollectible(pool,decrease,seed)
		end	
		if item.MegaSatan and id == item.MegaSatan and not mark.MegaSatan then
			itemPool:RemoveCollectible(item.MegaSatan)
			return itemPool:GetCollectible(pool,decrease,seed)
		end		
		if item.Delirium and id == item.Delirium and not mark.Delirium then
			itemPool:RemoveCollectible(item.Delirium)
			return itemPool:GetCollectible(pool,decrease,seed)
		end
		if item.Witness and id == item.Witness and not mark.Witness then
			itemPool:RemoveCollectible(item.Witness)
			return itemPool:GetCollectible(pool,decrease,seed)
		end		
		if item.Beast and id == item.Beast and not mark.Beast then
			itemPool:RemoveCollectible(item.Beast)
			return itemPool:GetCollectible(pool,decrease,seed)
		end	
		if item.Greed and id == item.Greed and not mark.Greed then
			itemPool:RemoveCollectible(item.Greed)
			return itemPool:GetCollectible(pool,decrease,seed)
		end		
	end
end)

--避免从池中抽取未解锁饰品
mod:AddPriorityCallback(ModCallbacks.MC_GET_TRINKET, CallbackPriority.EARLY, function(_,id)
	local itemPool = Game():GetItemPool()

	for key,trinket in pairs(MarkTrinket) do
		local mark = IBS_Data.Setting[key]
		if trinket.IBSL and id == trinket.IBSL and not (mark.Isaac and mark.BlueBaby and mark.Satan and mark.Lamb) then
			return itemPool:GetTrinket()
		end		
		if trinket.Witness and id == trinket.Witness and not mark.Witness then
			return itemPool:GetTrinket()
		end		
		if trinket.Beast and id == trinket.Beast and not mark.Beast then
			return itemPool:GetTrinket()
		end		
	end
end)

--避免从池中抽取未解锁口袋物品
mod:AddPriorityCallback(ModCallbacks.MC_GET_CARD, CallbackPriority.EARLY, function(_,rng,id,IncludePlayingCards,IncludeRunes,OnlyRunes)
	local itemPool = Game():GetItemPool()

	for key,card in pairs(MarkPocket) do
		local mark = IBS_Data.Setting[key]
		if card.MegaSatan and id == card.MegaSatan and not mark.MegaSatan then
			return itemPool:GetCard(rng:Next(), IncludePlayingCards, IncludeRunes, OnlyRunes)
		end		
		if card.Delirium and id == card.Delirium and not mark.Delirium then
			return itemPool:GetCard(rng:Next(), IncludePlayingCards, IncludeRunes, OnlyRunes)
		end			
		if card.Greed and id == card.Greed and not mark.Greed then
			return itemPool:GetCard(rng:Next(), IncludePlayingCards, IncludeRunes, OnlyRunes)
		end		
	end
end)

end


do --处理通过其他方式解锁的物品

--将未解锁的道具从池中移除
mod:AddPriorityCallback(ModCallbacks.MC_POST_GAME_STARTED, CallbackPriority.EARLY, function(_,isContinue)
	local itemPool = Game():GetItemPool()
	
	if not isContinue then
		for key,item in pairs(OtherItem) do
			local UNLOCKED = IBS_Data.Setting[key]
			if not UNLOCKED then
				itemPool:RemoveCollectible(item)
			end	
		end
	end
end)

--避免从池中抽取未解锁道具
mod:AddPriorityCallback(ModCallbacks.MC_POST_GET_COLLECTIBLE, CallbackPriority.EARLY, function(_,id,pool,decrease,seed)
	local itemPool = Game():GetItemPool()

	for key,item in pairs(OtherItem) do
		local UNLOCKED = IBS_Data.Setting[k]
		if id == item and not UNLOCKED then
			itemPool:RemoveCollectible(item)
			return itemPool:GetCollectible(pool,decrease,seed)
		end			
	end
end)

end


do--未解锁挑战时开局提醒并退出游戏

--播放未解锁提醒
local function ShowPaper()
	local paper = "LOCKED"
	
	--检测语言
	if LANG == "zh" then
		paper = paper.."_zh"
	end
	
	paper = paper..".png"	
	BigBooks:PlayPaper(paper)
end

--检查解锁状态
local function IsLocked()
	local challenge = Isaac.GetChallenge()
	local mark = nil
	if MarkChallenge[challenge] then
		mark = IBS_Data.Setting[MarkChallenge[challenge]]
		if not (mark.BossRush and mark.Hush) then
			return true
		end
	end	
	return false
end

--分时段触发函数
mod:AddCallback(ModCallbacks.MC_POST_UPDATE, function()

	 --开局
	if (Game():GetFrameCount() <= 1) then
		if IsLocked() then
			for i = 0, Game():GetNumPlayers() -1 do
				Isaac.GetPlayer(i):AddControlsCooldown(999) --禁止控制
			end
		end
	end
	
	 --第1秒
	if (Game():GetFrameCount() == 30) then
		if IsLocked() then
			ShowPaper()
			Game():Fadeout(0.018,2) --逐渐退出游戏
		end	
	end
	
	--第1秒多一点
	if (Game():GetFrameCount() == 50) then
		if IsLocked() then
			Game():End(1) --死亡删档
		end	
	end
end)

end

