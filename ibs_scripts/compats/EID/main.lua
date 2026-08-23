--EID

local mod = Isaac_BenightedSoul
local IBS_PlayerID = mod.IBS_PlayerID
local IBS_ChallengeID = mod.IBS_ChallengeID
local IBS_ItemID = mod.IBS_ItemID
local IBS_PocketID = mod.IBS_PocketID
local IBS_SlotID = mod.IBS_SlotID
local Ents = mod.IBS_Lib.Ents
local Players = mod.IBS_Lib.Players
local Pools = mod.IBS_Lib.Pools

local game = Game()
local config = Isaac.GetItemConfig()

--------加载--------
--添加图标
--[[输入:
图标名称(字符串), anm2文件名称(字符串), 动画名称(字符串), 动画帧(整数),
宽(整数), 高(整数), 向右修正(整数), 向下修正(整数)
]]
local function AddIcon(iconName, fileName, animName, animFrame, width, height, offsetX, offsetY)
	local spr = Sprite()
	spr:Load('gfx/ibs/compats/EIDicons/'..fileName..'.anm2', true)
	EID:addIcon(iconName, animName, animFrame, width, height, offsetX, offsetY, spr)
end

AddIcon('IBSMOD', 'ibsmod', 'Idle', 0, 16, 16, 7, 6) --模组图标
AddIcon('IBSIronHeart', 'ironheart', 'Idle', 0, 16, 16, 7, 6) --坚贞之心
AddIcon('IBSMemory', 'memory', 'Idle', 0, 16, 16, 7, 6) --记忆碎片

AddIcon('IBSSamsonCalm', 'bsamson_state', 'Idle', 0, 16, 16, 7, 6) --参孙平静
AddIcon('IBSSamsonWrath', 'bsamson_state', 'Idle', 1, 16, 16, 7, 6) --参孙暴怒

do --角色
	local i = 0
	for ID = IBS_PlayerID.BIsaac, IBS_PlayerID.BForgotten do
		AddIcon('Player'..ID, 'players', 'player', i, 16, 16, 5, 5)
		i = i + 1
	end
end

do --口袋物品
	local i = 0
	for ID = IBS_PocketID.CuZnD6, IBS_PocketID.NeniaDea do
		AddIcon('Card'..ID, 'pocketitems', 'object', i, 16, 16, 7, 7)
		i = i + 1
	end
	
	i = 0

	--伪忆
	for ID = IBS_PocketID.BIsaac, IBS_PocketID.BJBE do
		AddIcon('Card'..ID, 'pocketitems', 'soul', i, 16, 16, 7, 7)
		i = i + 1
	end	
end

do --可互动实体
	AddIcon('IBS_CollectionBox', 'slots', 'slot', 0, 16, 16, 5, 5)
	EID:AddIconToObject(6, IBS_SlotID.CollectionBox.Variant, 0, 'IBS_CollectionBox')
	
	AddIcon('IBS_Albern', 'slots', 'slot', 1, 16, 16, 5, 5)
	EID:AddIconToObject(6, IBS_SlotID.Albern.Variant, 0, 'IBS_Albern')
	
	AddIcon('IBS_Facer', 'slots', 'slot', 2, 16, 16, 5, 5)
	EID:AddIconToObject(6, IBS_SlotID.Facer.Variant, 0, 'IBS_Facer')
	
	AddIcon('IBS_Envoy', 'slots', 'slot', 3, 16, 16, 5, 5)
	EID:AddIconToObject(6, IBS_SlotID.Envoy.Variant, 0, 'IBS_Envoy')
end

do --诅咒
	AddIcon('IBSCurseMoving', 'curses', 'Idle', 0, 16, 16, 7, 6)
	AddIcon('IBSCurseD7', 'curses', 'Idle', 2, 16, 16, 7, 6)
end

do --表表游魂相关
	AddIcon('IBSMomsChest', 'blost_hud', 'Mom', 3, 16, 16, 7, 6)
	AddIcon('IBSBlostWeapon', 'blost_hud', 'Weapon', 3, 16, 16, 7, 6)
	AddIcon('IBSBlostArmor', 'blost_hud', 'Armor', 3, 16, 16, 7, 6)
	AddIcon('IBSBlostFloat', 'blost_hud', 'Float', 3, 16, 16, 7, 6)
end

--展示实体的额外内容
local function EID_ContentForIBS(name, content, T, V, LANG)

	--触发条件
	local function condition(desc)
		local Type = desc.ObjType
		local Variant = desc.ObjVariant
		local SubType = desc.ObjSubType	
	
		--检查语言
		local lang = EID:getLanguage()
		if lang ~= 'zh_cn' then lang = 'en_us' end
		if lang ~= LANG then
			return false
		end
		
		if (Type == T) and (Variant == V) and content[SubType] then
			if content[SubType].extra then
				return true
			end	
		end
			
		return false
	end

	--添加额外内容
	local function callback(desc)
		local SubType = desc.ObjSubType
		local text = content[SubType].extra
		
		if text then
			local add = '#'..text
			EID:appendToDescription(desc, add)
		end
		
		return desc
	end
	EID:addDescriptionModifier(name..'_'..LANG, condition, callback)
end


--为特定角色展示实体的额外内容
local function EID_ContentForPlayer(name, content, T, V, LANG)

	--触发条件
	local function condition(desc)
		local Type = desc.ObjType
		local Variant = desc.ObjVariant
		local SubType = desc.ObjSubType	
	
		--检查语言
		local lang = EID:getLanguage()
		if lang ~= 'zh_cn' then lang = 'en_us' end
		if lang ~= LANG then
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
		
		for i = 0, game:GetNumPlayers(0) - 1 do
			local playerType = Isaac.GetPlayer(i):GetPlayerType()
			local text = content[SubType].player[playerType]
			
			if text then
				local add = '#{{Player'..playerType..'}} '..text
				EID:appendToDescription(desc, add)
			end
		end	

		return desc
	end
	EID:addDescriptionModifier(name..'_'..LANG, condition, callback)
end


--为虚空展示实体的额外内容(目前只用于道具)
local function EID_ContentForVoid(name, content, T, V, LANG)

	--触发条件
	local function condition(desc)
		local Type = desc.ObjType
		local Variant = desc.ObjVariant
		local SubType = desc.ObjSubType		
	
		--检查语言
		local lang = EID:getLanguage()
		if lang ~= 'zh_cn' then lang = 'en_us' end
		if lang ~= LANG then
			return false
		end

		if (Type == T) and (Variant == V) and content[SubType] then
			if content[SubType].void then
				return Players:AnyHasCollectible(477) --虚空
			end	
		end

		return false
	end
	
	--添加额外内容
	local function callback(desc)
		local SubType = desc.ObjSubType
		local text = content[SubType].void
		
		if text then
			local add = '#{{Collectible477}} '..text
			EID:appendToDescription(desc, add)
		end
		
		return desc
	end
	EID:addDescriptionModifier(name..'_'..LANG, condition, callback)
end


--为贪婪模式展示实体的额外内容
local function EID_ContentForGreed(name, content, T, V, LANG)

	--触发条件
	local function condition(desc)
		local Type = desc.ObjType
		local Variant = desc.ObjVariant
		local SubType = desc.ObjSubType		
	
		--检查语言
		local lang = EID:getLanguage()
		if lang ~= 'zh_cn' then lang = 'en_us' end
		if lang ~= LANG then
			return false
		end

		if game:IsGreedMode() then
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
			local add = '#{{GreedMode}} '..text
			EID:appendToDescription(desc, add)
		end
		
		return desc
	end
	EID:addDescriptionModifier(name..'_'..LANG, condition, callback)
end

--东方模组兼容
local SeijaBuffEID = {
	['zh_cn'] = {},
	['en_us'] = {},
}
local SeijaNerfEID = {
	['zh_cn'] = {},
	['en_us'] = {},
}
local RuneSwordEID = {
	['zh_cn'] = {},
	['en_us'] = {},
}

local function EID_ContentForTHI(content, LANG)
	for id,item in pairs(content) do
		if item.seijaBuff then
			SeijaBuffEID[LANG][id] = item.seijaBuff
		end			
		if item.seijaNerf then
			SeijaNerfEID[LANG][id] = item.seijaNerf
		end	
		if item.runeSword then
			RuneSwordEID[LANG][id] = item.runeSword
		end
	end	
end

mod:AddPriorityCallback(ModCallbacks.MC_POST_MODS_LOADED, CallbackPriority.EARLY, function()
	if mod.IBS_Compat.THI:IsEnabled() then
		local seija = THI.Players.Seija
		
		do --正邪增强的道具
			for LANG,Table in pairs(SeijaBuffEID) do
				for id,info in pairs(Table) do
					if EID.descriptions[LANG].reverieSeijaBuffs and EID.descriptions[LANG].reverieSeijaBuffData then
						EID.descriptions[LANG].reverieSeijaBuffs['100.'..id] = info.desc
						EID.descriptions[LANG].reverieSeijaBuffData['100.'..id] = info.data
						seija:AddExceptedModItem(id)
					end
				end	
			end
		end
		
		do --正邪削弱的道具
			for LANG,Table in pairs(SeijaNerfEID) do
				for id,info in pairs(Table) do
					if EID.descriptions[LANG].reverieSeijaNerfs then
						EID.descriptions[LANG].reverieSeijaNerfs['100.'..id] = info
						seija:AddExceptedModItem(id)
					end
				end	
			end
		end
	end
end)

--翻译
local function Translate(text_zh, text_en, LANG)
	return (LANG == 'zh_cn' and text_zh) or text_en
end

--加载描述
local function LoadDesc(fileName)
	return include('ibs_scripts.compats.EID.descriptions.'..fileName)
end

--缓存描述修改器,防止重复加载
local CahcedModifier = {}

--加载描述修改器
local function LoadEIDModifier(fileName, LANG, ...)
	local path = 'ibs_scripts.compats.EID.modifiers.'..fileName
	local func = CahcedModifier[path] or include(path)
	if func then
		func(LANG, ...)
	end
	if not CahcedModifier[path] then
		CahcedModifier[path] = func
	end
end
---------------


--介绍
local IBS_EID = {
	['zh_cn'] = include('ibs_scripts.compats.EID.Chinese'),
	['en_us'] = include('ibs_scripts.compats.EID.English'),
}

for LANG,Table in pairs(IBS_EID) do

	do --角色
		for id,player in pairs(Table.PlayerEID) do
			if player.info then
				EID:addCharacterInfo(id, player.info, player.name, LANG)			
			end
		
			--长子权
			if EID.descriptions[LANG].birthright then
				EID:addBirthright(id, player.br, player.name, LANG)
			end
		end
	end	

	do --犹大福音增强
		LoadEIDModifier('tgoj', LANG)
	end

	do --道具
		for id,item in pairs(Table.ItemEID) do
			if item.name then
				EID:addCollectible(id, item.info, item.name, LANG)
			end
			
			if item.virtue and EID.descriptions[LANG].bookOfVirtuesWisps then
				EID.descriptions[LANG].bookOfVirtuesWisps[id] = item.virtue
			end
			if item.belial and EID.descriptions[LANG].bookOfBelialBuffs then
				EID.descriptions[LANG].bookOfBelialBuffs[id] = item.belial
			end
            if item.bff and EID.descriptions[LANG].BFFSSynergies then
               EID.descriptions[LANG].BFFSSynergies[id] = item.bff
            end
			if item.eater and EID.descriptions[LANG].bingeEaterBuffs then
				EID.descriptions[LANG].bingeEaterBuffs[id] = item.eater
			end
			if item.trans then
				for _,t in pairs(item.trans) do
					EID:assignTransformation('collectible', id, EID.TRANSFORMATION[t])
				end
			end
		end
		EID_ContentForIBS('ibsItemForIBS', Table.ItemEID, 5, 100, LANG)
		EID_ContentForPlayer('ibsItemForPlayer', Table.ItemEID, 5, 100, LANG)
		EID_ContentForVoid('ibsItemForVoid', Table.ItemEID, 5, 100, LANG)
		EID_ContentForGreed('ibsItemForGreed', Table.ItemEID, 5, 100, LANG)
		EID_ContentForTHI(Table.ItemEID, LANG)
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
		EID_ContentForPlayer('ibsTrinketForPlayer', Table.TrinketEID, 5, 350, LANG)
		EID_ContentForGreed('ibsTrinketForGreed', Table.TrinketEID, 5, 350, LANG)
	end

	do --卡牌
		for id,card in pairs(Table.CardEID) do
			EID:addCard(id, card.info, card.name, LANG)
			
			if card.mimic then
				EID:addCardMetadata(id, card.mimic.charge, card.mimic.isRune)
			end	
		end
		EID_ContentForPlayer('ibsCardForPlayer', Table.CardEID, 5, 300, LANG)
		EID_ContentForGreed('ibsCardForGreed', Table.CardEID, 5, 300, LANG)
		EID_ContentForTHI(Table.CardEID, LANG)
	end

	do --可互动实体
		for variant,slot in pairs(Table.SlotEID) do
			if slot.name then
				EID:addEntity(6, variant, 0, slot.name, slot.info, LANG)
				EID:addEntity(6, variant, -1, slot.name, slot.info, LANG)
			end
		end
	end	

	do --虚空/无底坑增强
		LoadEIDModifier('void_abyss', LANG)
	end

	do --对流层
		LoadEIDModifier('troposphere', LANG)
	end	

	do --四维骰
		LoadEIDModifier('d4d', LANG)
	end	
	
	do --亚波伦的伪忆
		LoadEIDModifier('fh_bapollyon', LANG)
	end
	
	do --店主的伪忆
		LoadEIDModifier('fh_bkeeper', LANG)
	end		
	
	do --伯大尼的伪忆
		LoadEIDModifier('fh_bbeth', LANG)
	end	
	
	do --牧地挑战
		LoadEIDModifier('challenge_graze', LANG)
	end	
	
	do --表表店硬币饰品额外描述
		LoadEIDModifier('bkeeper_pennyt', LANG)
	end		
	
	do --表表店乞丐道具池影响
		LoadEIDModifier('bkeeper_beggar', LANG)
	end			
	
	do --收集癖
		LoadEIDModifier('hoarding', LANG)
	end	

	do --表表游魂额外描述
		LoadEIDModifier('blost', LANG)
	end
	
	do --募捐箱
		LoadEIDModifier('collection_box', LANG)
	end		

	do --换脸商
		LoadEIDModifier('facer', LANG)
	end
	
	do --永乐大典
		LoadEIDModifier('yongle', LANG)
	end	
	
	do --帘锁挖掘
		LoadEIDModifier('vain_miner', LANG)
	end
	
	do --符文佩剑(东方模组)	
	
		--触发条件
		local function condition(desc)
			local RuneSword = (THI and THI.Collectibles.RuneSword); if not RuneSword then return false end
			local Type = desc.ObjType
			local Variant = desc.ObjVariant
			local SubType = desc.ObjSubType	
		
			--检查语言
			local lang = EID:getLanguage()
			if lang ~= 'zh_cn' then lang = 'en_us' end
			if lang ~= LANG then
				return false
			end
			
			local player = EID:ClosestPlayerTo(desc.Entity)
			if (not player) or (not player:HasCollectible(RuneSword.Item)) then
				return false
			end

			if (Type == 5) and (Variant == 300) and RuneSwordEID[LANG][SubType] then
				return true
			end
				
			return false
		end

		--添加额外内容
		local function callback(desc)
			local RuneSword = (THI and THI.Collectibles.RuneSword); if not RuneSword then return desc end
			local SubType = desc.ObjSubType	
			local info = RuneSwordEID[LANG][SubType]
			if info then			
				local add = '#{{Collectible'..RuneSword.Item..'}} '..info
				EID:appendToDescription(desc, add)
			end
			return desc
		end
		EID:addDescriptionModifier('ibsRuneSword'..'_'..LANG, condition, callback)	
	end	
	
	do --我果祝福显示
		LoadEIDModifier('my_fruit', LANG)
	end	
	
	do --参孙技能描述
		LoadEIDModifier('bsamson', LANG)
	end
	
	do --米迦勒的赐福
		LoadEIDModifier('blessing_of_michael', LANG)
	end	

	do --原初之爪
		LoadEIDModifier('sere_talon', LANG)
	end	
	
	do --节制之骨增强
		LoadEIDModifier('temperance_bone', LANG)
	end
end


do --女疾女户伪装4级道具

	--触发条件
	local function condition(desc)
		local ent = desc.Entity
		local Type = desc.ObjType
		local Variant = desc.ObjVariant
		
		if ent and (Type == 5) and (Variant == 100) then
			local id = Ents:GetTempData(ent).EnvyDisguise
			if id and (id ~= desc.ObjSubType) then
				return true
			end
		end
			
		return false
	end

	--替换内容
	local function callback(desc)
		local ent = desc.Entity
		local id = Ents:GetTempData(ent).EnvyDisguise
		EID.GlitchedCrownCheck = {}
		return EID:getDescriptionObj(5, 100, id, ent)
	end
	EID:addDescriptionModifier('ibsEnvyDisguise', condition, callback)
end	

do --使者显形前使用乞丐的描述

	--触发条件
	local function condition(desc)
		local ent = desc.Entity
		local Type = desc.ObjType
		local Variant = desc.ObjVariant
		
		if ent and (Type == 6) and (Variant == IBS_SlotID.Envoy.Variant) and ent:ToSlot() then
			return true
		end
			
		return false
	end

	--替换内容
	local function callback(desc)
		local ent = desc.Entity
		local Envoy = (mod.IBS_Slot and mod.IBS_Slot.Envoy)
		if Envoy and not Envoy:IsRevealed(ent:ToSlot()) then
			return EID:getDescriptionObj(6, 4, 0, ent)
		end
		return desc
	end
	EID:addDescriptionModifier('ibsEnvoyDisguise', condition, callback)
end	