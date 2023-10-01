--EID

local mod = Isaac_BenightedSoul
local IBS_Player = mod.IBS_Player
local IBS_Item = mod.IBS_Item
local IBS_Pocket = mod.IBS_Pocket

--------加载--------

do --角色
	local player_spr = Sprite()
	player_spr:Load("ibsEIDicons/players.anm2", true)
	EID:addIcon("Player"..(IBS_Player.bisaac), "player", 0, 32, 32, 5, 5, player_spr)
	EID:addIcon("Player"..(IBS_Player.bmaggy), "player", 1, 32, 32, 5, 5, player_spr)
	EID:addIcon("Player"..(IBS_Player.bjudas), "player", 3, 32, 32, 5, 5, player_spr)
end

--铜锌合金骰
do
	local spr = Sprite()
	spr:Load("ibsEIDicons/pickups.anm2", true)
	EID:addIcon("Card"..(IBS_Pocket.czd6), "object", 0, 8, 8, 7, 7, spr)
end

--金色祈者
do
	local spr = Sprite()
	spr:Load("ibsEIDicons/pickups.anm2", true)
	EID:addIcon("Card"..(IBS_Pocket.goldenprayer), "object", 1, 8, 8, 7, 7, spr)
end


--为特定角色展示实体的额外内容
local function EID_ContentForPlayer(name, content, T, V, LANG)

	--触发条件
	local function condition(desc)
		local Type = desc.ObjType
		local Variant = desc.ObjVariant
		local SubType = desc.ObjSubType	
	
		--检查语言
		if EID:getLanguage() ~= LANG then
			return false
		end
		
		if (Type == T) and (Variant == V) and content[SubType] then
			if content[SubType].player then
				return true
			end	
		end
			
		return false
	end

	--添加额外内容
	local function callback(desc)
		local SubType = desc.ObjSubType
		
		for i = 0, Game():GetNumPlayers(0) - 1 do
			local playerType = Isaac.GetPlayer(i):GetPlayerType()
			local text = content[SubType].player[playerType]
			
			if text then
				local add = "#{{Player"..playerType.."}} "..text
				EID:appendToDescription(desc, add)
			end
		end	

		return desc
	end
	EID:addDescriptionModifier(name.."_"..LANG, condition, callback)
end


--为贪婪模式展示实体的额外内容
local function EID_ContentForGreed(name, content, T, V, LANG)

	--触发条件
	local function condition(desc)
		local Type = desc.ObjType
		local Variant = desc.ObjVariant
		local SubType = desc.ObjSubType		
	
		--检查语言
		if EID:getLanguage() ~= LANG then
			return false
		end

		if Game():IsGreedMode() then
			if (Type == T) and (Variant == V) and content[SubType] then
				if content[SubType].greed then
					return true
				end	
			end
		end

		return false
	end
	
	--添加额外内容
	local function callback(desc)
		local SubType = desc.ObjSubType
		local text = content[SubType].greed
		
		if text then
			local add = "#{{GreedMode}} "..text
			EID:appendToDescription(desc, add)
		end
		
		return desc
	end
	EID:addDescriptionModifier(name.."_"..LANG, condition, callback)
end

--正邪(东方模组)
local SeijaBuffEID = {
	["zh_cn"] = {},
	["en_us"] = {},
	["en_us_detailed"] = {}
}
local SeijaNerfEID = {
	["zh_cn"] = {},
	["en_us"] = {},
	["en_us_detailed"] = {}
}

local function EID_ContentForSeija(content, LANG)
	for id,item in pairs(content) do
		if item.seijaBuff then
			SeijaBuffEID[LANG][id] = item.seijaBuff
		end			
		if item.seijaNerf then
			SeijaNerfEID[LANG][id] = item.seijaNerf
		end	
	end	
end
mod:AddPriorityCallback(ModCallbacks.MC_POST_GAME_STARTED, CallbackPriority.EARLY, function(_,isContinue)
	if (not isContinue) and mod:CheckTHI() then
		local seija = THI.Players.Seija
		
		do --正邪增强的道具
			for LANG,Table in pairs(SeijaBuffEID) do
				for id,info in pairs(Table) do
					if EID.descriptions[LANG].reverieSeijaBuffs then
						EID.descriptions[LANG].reverieSeijaBuffs["100."..id] = info
						
						if not seija:IsExceptedModItem(id) then
							seija:AddExceptedModItem(id)
						end	
					end
				end	
			end
		end
		
		do --正邪削弱的道具
			for LANG,Table in pairs(SeijaNerfEID) do
				for id,info in pairs(Table) do
					if EID.descriptions[LANG].reverieSeijaNerfs then
						EID.descriptions[LANG].reverieSeijaNerfs["100."..id] = info

						if not seija:IsExceptedModItem(id) then
							seija:AddExceptedModItem(id)
						end	
					end
				end	
			end
		end	
	end
end)

--翻译
local function Translate(text_zh, text_en, LANG)
	return (LANG == "zh_cn" and text_zh) or text_en
end
---------------


--介绍
local IBS_EID = {
	["zh_cn"] = include("ibs_scripts.compats.EID.Chinese"),
	["en_us"] = include("ibs_scripts.compats.EID.English"),
	["en_us_detailed"] = include("ibs_scripts.compats.EID.English")
}

for LANG,Table in pairs(IBS_EID) do

	do --长子权
		for id,br in pairs(Table.BirthrightEID) do
			if EID.descriptions[LANG].birthright then
				EID:addBirthright(id, br.info, br.name, LANG)
			end	
		end
	end	

	do --道具
		for id,item in pairs(Table.ItemEID) do
			EID:addCollectible(id, item.info, item.name, LANG)
			
			if item.virtue and EID.descriptions[LANG].bookOfVirtuesWisps then
				EID.descriptions[LANG].bookOfVirtuesWisps[id] = item.virtue
			end
			if item.belial and EID.descriptions[LANG].bookOfBelialBuffs then
				EID.descriptions[LANG].bookOfBelialBuffs[id] = item.belial
			end
			if item.trans then
				for _,t in pairs(item.trans) do
					EID:assignTransformation("collectible", id, EID.TRANSFORMATION[t])
				end
			end
		end
		EID_ContentForPlayer("ibsItemForPlayer", Table.ItemEID, 5, 100, LANG)
		EID_ContentForGreed("ibsItemForGreed", Table.ItemEID, 5, 100, LANG)
		EID_ContentForSeija(Table.ItemEID, LANG)
	end	

	do --饰品
		for id,trinket in pairs(Table.TrinketEID) do
			EID:addTrinket(id, trinket.info, trinket.name, LANG)
			
			if trinket.mult then
				if trinket.mult.findReplace and (EID.GoldenTrinketData and EID.descriptions[LANG].goldenTrinketEffects) then
					EID.GoldenTrinketData[id] = {findReplace = true}
					EID.descriptions[LANG].goldenTrinketEffects[id] = trinket.mult.findReplace
				else
					local append = trinket.mult.append or nil
					local numberToMultiply = trinket.mult.numberToMultiply or 1
					local maxMultiplier = trinket.mult.maxMultiplier or 3
					EID:addGoldenTrinketMetadata(id, append, numberToMultiply, maxMultiplier, LANG)
				end
			end
		end
		EID_ContentForPlayer("ibsTrinketForPlayer", Table.TrinketEID, 5, 350, LANG)
		EID_ContentForGreed("ibsTrinketForGreed", Table.TrinketEID, 5, 350, LANG)
	end

	do --卡牌
		for id,card in pairs(Table.CardEID) do
			EID:addCard(id, card.info, card.name, LANG)
			
			if card.mimic then
				EID:addCardMetadata(id, card.mimic.charge, card.mimic.isRune)
			end	
		end
		EID_ContentForPlayer("ibsCardForPlayer", Table.CardEID, 5, 300, LANG)
		EID_ContentForGreed("ibsCardForGreed", Table.CardEID, 5, 300, LANG)
	end

	do --D4D
		
		--比列书
		local function Belial()
			for i = 0, Game():GetNumPlayers(0) - 1 do
				local player = Isaac.GetPlayer(i)
				if player:HasCollectible(59) then
					return true
				end
			end
			return false
		end
		
		--ID转EID贴图
		local function ToIcon(id)
			local MAX = Isaac.GetItemConfig():GetCollectibles().Size
			local icon = id
			
			id = math.floor(id+0.5) --四舍五入
			if id > 0 and id < MAX then
				id = tostring(id)
				icon = "{{Collectible"..id.."}}"
			elseif Belial() then
				icon = "{{Collectible51}}"
			else
				icon = Translate("无", "N/A", LANG)
			end
			
			return icon
		end
		
		--触发条件
		local function condition(desc)
			local Type = desc.ObjType
			local Variant = desc.ObjVariant
			local SubType = desc.ObjSubType	
		
			--检查语言
			if EID:getLanguage() ~= LANG then
				return false
			end
			
			if (Type == 5) and (Variant == 100) and (SubType > 0) then
				for i = 0, Game():GetNumPlayers(0) - 1 do
					local player = Isaac.GetPlayer(i)
					if player:HasCollectible(IBS_Item.d4d) then
						return true
					end
				end
			end
				
			return false
		end

		--添加额外内容
		local function callback(desc)
			local id = desc.ObjSubType
			local col1 = ToIcon(id+1)
			local col2 = ToIcon(id-1)
			local col3 = ToIcon(id*2)
			local col4 = ToIcon(id/2)
			local L = "{{ButtonDLeft}}"
			local R = "{{ButtonDRight}}"
			local U = "{{ButtonDUp}}"
			local D = "{{ButtonDDown}}"
			
			local add = "#{{Collectible"..IBS_Item.d4d.."}} "..
						L..col1..";"..R..col2..";"..U..col3..";"..D..col4
						
			EID:appendToDescription(desc, add)
			
			return desc
		end
		EID:addDescriptionModifier("ibsD4D".."_"..LANG, condition, callback)
	end	

	do --虚空/无底坑增强
		
		--索引
		local ToKey = {
			[477] = "voidUp",
			[706] = "abyssUp"
		}
		
		--触发条件
		local function condition(desc)
			local Type = desc.ObjType
			local Variant = desc.ObjVariant
			local SubType = desc.ObjSubType	
		
			--检查语言
			if EID:getLanguage() ~= LANG then
				return false
			end
			
			if (Type == 5) and (Variant == 100) and (SubType == 477 or SubType == 706) then
				if IBS_Data.Setting[ToKey[SubType]] then
					return true
				end	
			end
				
			return false
		end

		--添加额外内容
		local function callback(desc)
			local id = desc.ObjSubType
			local info = Translate("对饰品生效", "Available to trinkets", LANG)
			local add = "#{{ColorGold}}"..info.."{{CR}}"
	
			EID:appendToDescription(desc, add)
			
			return desc
		end
		EID:addDescriptionModifier("ibsVoidAbyssUp".."_"..LANG, condition, callback)
	end
	
	do --虚空/无底坑增强	
	
		--触发条件
		local function condition(desc)
			local Type = desc.ObjType
			local Variant = desc.ObjVariant
			local SubType = desc.ObjSubType	
		
			--检查语言
			if EID:getLanguage() ~= LANG then
				return false
			end
			
			if (Type == 5) and (Variant == 100) and (SubType == IBS_Item.tgoj) then
				if IBS_Data.Setting["bc3"] then
					return true
				end	
			end
				
			return false
		end

		--添加额外内容
		local function callback(desc)
			local id = desc.ObjSubType
			local info = Translate("范围内的敌人获得虚弱效果", "Weaken enemies within range", LANG)
			local add = "#{{ColorGold}}"..info.."{{CR}}"
	
			EID:appendToDescription(desc, add)
			
			return desc
		end
		EID:addDescriptionModifier("ibsTGOJUp".."_"..LANG, condition, callback)
	end	
end

