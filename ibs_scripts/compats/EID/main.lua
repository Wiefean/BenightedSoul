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
local AnotherPage = false --用于切换显示内容
mod:AddCallback(ModCallbacks.MC_POST_RENDER, function()
	for idx = 0,4 do
		if Input.IsActionTriggered(ButtonAction.ACTION_MAP, idx) then
			AnotherPage = not AnotherPage
			break
		end
	end
end)
mod:AddCallback(ModCallbacks.MC_MAIN_MENU_RENDER, function()
	for idx = 0,4 do
		if Input.IsActionTriggered(ButtonAction.ACTION_MAP, idx) then
			AnotherPage = not AnotherPage
			break
		end
	end
end)

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
	for ID = IBS_PlayerID.BIsaac, IBS_PlayerID.BKeeper do
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
		
		THILoaded = true
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
			
			if (Type == 5) and (Variant == 100) and (SubType == IBS_ItemID.TGOJ) then
				local BC4 = mod.IBS_Achiev.Challenge[4]
				if BC4:IsFinished() or BC4:Challenging() then
					return true
				end	
			end
				
			return false
		end

		--添加额外内容
		local function callback(desc)
			local info = Translate('范围内的敌人获得虚弱效果', 'Weaken enemies within range', LANG)
			local add = '#{{ColorGold}}'..info..'{{CR}}'
	
			EID:appendToDescription(desc, add)
			
			return desc
		end
		EID:addDescriptionModifier('ibsTGOJUp'..'_'..LANG, condition, callback)
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

		--索引
		local ToKey = {
			[477] = 'voidUp',
			[706] = 'abyssUp'
		}
		
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
			
			if (Type == 5) and (Variant == 100) and (SubType == 477 or SubType == 706) then
				if mod:GetIBSData('persis')[ToKey[SubType]] then
					return true
				end
			end
				
			return false
		end

		--添加额外内容
		local function callback(desc)
			local info = Translate('对饰品生效', 'Available to trinkets', LANG)
			local add = '#{{IBSMOD}} {{ColorGold}}'..info..'{{CR}}'

			EID:appendToDescription(desc, add)
			
			return desc
		end
		EID:addDescriptionModifier('ibsVoidAbyssUp'..'_'..LANG, condition, callback)
	end

	do --对流层
	
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

			if (Type == 5) and (Variant == 100) and (SubType > 0) then
				if not PlayerManager.AnyoneHasCollectible(IBS_ItemID.Troposphere) then return false end
				local Troposphere = (mod.IBS_Item and mod.IBS_Item.Troposphere)
				if Troposphere and Troposphere:CanSwap(SubType) then
					return true
				end		
			end
				
			return false
		end

		--添加额外内容
		local function callback(desc)
			local add = Translate('允许对流层交换', 'Troposphere Available', LANG)
			add = '#{{Collectible'..(IBS_ItemID.Troposphere)..'}} '..add
			EID:appendToDescription(desc, add)
			return desc
		end
		EID:addDescriptionModifier('ibsTroposphere'..'_'..LANG, condition, callback)
	end	


	do --D4D
		
		--ID转EID贴图
		local function ToIcon(id)
			id = math.floor(id+0.5) --四舍五入
			local icon = ''
			local itemConfig = config:GetCollectible(id)
	
			if itemConfig and itemConfig:IsAvailable() then
				icon = '{{Collectible'..tostring(id)..'}}'
			else
				if Players:AnyHasCollectible(59) then --彼列书
					icon = '{{Collectible51}}'
				else
					icon = Translate('无', 'N/A', LANG)
				end
			end
			
			return icon
		end
		
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
			
			if (Type == 5) and (Variant == 100) and (SubType > 0) then
				return Players:AnyHasCollectible(IBS_ItemID.D4D)
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
			local L = '{{ButtonDLeft}}'
			local R = '{{ButtonDRight}}'
			local U = '{{ButtonDUp}}'
			local D = '{{ButtonDDown}}'
			
			local add = '#{{Collectible'..IBS_ItemID.D4D..'}} '..
						L..col1..';'..R..col2..';'..U..col3..';'..D..col4
						
			EID:appendToDescription(desc, add)
			
			return desc
		end
		EID:addDescriptionModifier('ibsD4D'..'_'..LANG, condition, callback)
	end	
	
	do --亚波伦的伪忆
	
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
			
			if (Type == 5) and (Variant == 300) and (SubType == IBS_PocketID.BApollyon) then
				return true
			end
				
			return false
		end

		--添加额外内容
		local function callback(desc)
			local data = mod:GetIBSData('temp').FalsehoodBApollyon or {41, 41, 41}
		
			if data then
				local add = Translate('#将生成：', '#Will Spawn: ', LANG)
				for _,id in ipairs(data) do
					add = add..'{{Card'..id..'}} '
				end
				EID:appendToDescription(desc, add)
			end

			return desc
		end
		EID:addDescriptionModifier('ibsBApollyonFalsehood'..'_'..LANG, condition, callback)
	end		
	
	do --店主的伪忆
	
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
			
			if (Type == 5) and (Variant == 300) and (SubType == IBS_PocketID.BKeeper) then
				return true
			end
				
			return false
		end

		--添加额外内容
		local function callback(desc)
			local data = mod:GetIBSData('temp').FalsehoodBKeeper
			local times = 0

			if data and data.Points then
				times = data.Points
			end
			
			local add = Translate('#(已捐助次数：', '#(Donation Times: ', LANG)..times..')'
			EID:appendToDescription(desc, add)

			return desc
		end
		EID:addDescriptionModifier('ibsBKeeperFalsehood'..'_'..LANG, condition, callback)
	end		
	
	do --伯大尼的伪忆
	
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
			
			if (Type == 5) and (Variant == 300) and (SubType == IBS_PocketID.BBeth) then
				return true
			end
				
			return false
		end

		--添加额外内容
		local function callback(desc)
			local data = mod:GetIBSData('temp').PhantomRelic or {}
		
			if #data > 0 then
				local add = Translate('#已记录：', '#Recorded: ', LANG)
				for _,id in ipairs(data) do
					add = add..'{{Collectible'..id..'}} '
				end
				EID:appendToDescription(desc, add)
			end

			return desc
		end
		EID:addDescriptionModifier('ibsBBethFalsehood'..'_'..LANG, condition, callback)
	end	
	
	do --牧地挑战
	
		--触发条件
		local function condition(desc)
			local Type = desc.ObjType
			local Variant = desc.ObjVariant		
		
			--检查语言
			local lang = EID:getLanguage()
			if lang ~= 'zh_cn' then lang = 'en_us' end
			if lang ~= LANG then
				return false
			end
			
			if Isaac.GetChallenge() == IBS_ChallengeID[3] then
				if Type == 5 and Variant == 100 then
					return true
				end
			end
				
			return false
		end

		--添加额外内容
		local function callback(desc)
			local id = desc.ObjSubType
						
			--小麦
			if id == IBS_ItemID.Wheat then
				desc.Description = Translate(
					'为周围的山羊提升血量上限并回满血量',
					"Increase nearby goats' Hp", 
					LANG
				)
			end
		
			if id == IBS_ItemID.Goatify then
				desc.Description = Translate(
					'生成一只山羊',
					"Spawn a goat", 
					LANG
				)
			end

			return desc
		end
		EID:addDescriptionModifier('ibsBC3'..'_'..LANG, condition, callback)
	end		
	
	do --表表店硬币饰品额外描述
	
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
			
			if (Type == 5) and (Variant == 350) and Pools:IsPennyTrinket(SubType) and PlayerManager.AnyoneIsPlayerType(IBS_PlayerID.BKeeper) then
				return true
			end
				
			return false
		end

		--添加额外内容
		local function callback(desc)
			local add = Translate('影响乞丐道具池', 'Affect beggar item pools', LANG)
			add = '#{{Player'..(IBS_PlayerID.BKeeper)..'}} '..add
			EID:appendToDescription(desc, add)
			return desc
		end
		EID:addDescriptionModifier('ibsBKeeperPennyTrinket'..'_'..LANG, condition, callback)
	end		
	
	do --表表店乞丐道具池影响
	
		--该死的前期处理
		do
			local Beggar = {
				[4] = {
					Name = Translate('乞丐', 'Beggar', LANG),
					Icon = 'Beggar',
				},
				[5] = {
					Name = Translate('恶魔乞丐', 'Devil Beggar', LANG),
					Icon = 'DemonBeggar',
				},
				[7] = {
					Name = Translate('钥匙大师', 'Key Master', LANG),
					Icon = 'KeyBeggar',
				},
				[9] = {
					Name = Translate('炸弹乞丐', 'Bomb Bum', LANG),
					Icon = 'BombBeggar',
				},
				[13] = {
					Name = Translate('电池乞丐', 'Battery Bum', LANG),
					Icon = 'BatteryBeggar',
				},
				[18] = {
					Name = Translate('腐烂乞丐', 'Rotten Beggar', LANG),
					Icon = 'RottenBeggar',
				},
							
			}
			
			for variant,tbl in pairs(Beggar) do
				EID:addEntity(6, variant, 0, tbl.Name, "", LANG)
				EID:AddIconToObject(6, variant, 0, tbl.Icon)
			end
		end
	
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
			
			--混沌
			if PlayerManager.AnyoneHasCollectible(402) then
				return false
			end				
			
			if not PlayerManager.AnyoneIsPlayerType(IBS_PlayerID.BKeeper) then 
				return false
			end			
			
			if (Type == 6) and Pools:IsBeggar(Variant) and SubType == 0 then
				return true
			end
				
			return false
		end

		--添加额外内容
		local function callback(desc)
			local add = '#{{Player'..(IBS_PlayerID.BKeeper)..'}} '
			local beggarPool = Pools.BeggarToBeggarPool[desc.ObjVariant]
			local cache = {}
			local total = 28

			--硬核计算概率
			if beggarPool and mod.IBS_Player.BKeeper.PoolForPennyTrinket[beggarPool] then
				cache[beggarPool] = 28
			
				for trinket,pools in pairs(mod.IBS_Player.BKeeper.PoolForPennyTrinket[beggarPool]) do
					local mult = PlayerManager.GetTotalTrinketMultiplier(trinket)
					if mult > 0 then
						for i2 = 1,mult do
							for _,v in ipairs(pools) do
								cache[v.Pool] = cache[v.Pool] or 0
								cache[v.Pool] = cache[v.Pool] + v.Times
								total = total + v.Times
							end
						end
					end
				end
				
				for pool,times in pairs(cache) do
					local chance = math.floor(100*(times/total)+0.5)..'% '
				
					if pool == 'Random' then
						add = add..'{{QuestionMark}}:'..chance
					else
						add = add..(EID.ItemPoolTypeToMarkup[pool])..':'..chance
					end
				end

				EID:appendToDescription(desc, add)
			end
			
			return desc
		end
		EID:addDescriptionModifier('ibsBKeeperBeggarDesc'..'_'..LANG, condition, callback)
	end	
	
	do --表表店诅咒硬币
	
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
			
			if (Type == 5) and (Variant == 350) and (SubType == 172) and PlayerManager.AnyoneIsPlayerType(IBS_PlayerID.BKeeper) then
				return true
			end
				
			return false
		end

		--添加额外内容
		local function callback(desc)
			local add = Translate('乞丐有可能返还资源', 'Beggers may return the resources', LANG)
			add = '#{{Player'..(IBS_PlayerID.BKeeper)..'}} '..add
			EID:appendToDescription(desc, add)
			return desc
		end
		EID:addDescriptionModifier('ibsBKeeperCursedPenny'..'_'..LANG, condition, callback)
	end	
	
	
	do --收集癖
	
		local FormList, StompyFrom = Table.HoardingEID.FormList, Table.HoardingEID.StompyFrom

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
			
			--检查道具
			if not PlayerManager.AnyoneHasCollectible(IBS_ItemID.Hoarding) then
				return false
			end
			
			--道具或药丸
			if (Type == 5) and (Variant == 100 or Variant == 70) then
				return true
			end
				
			return false
		end

		--添加额外内容
		local function callback(desc)
			local Variant = desc.ObjVariant
			local SubType = desc.ObjSubType
			local prefix = '#{{Collectible'..(IBS_ItemID.Hoarding)..'}} '
			local add = ''
		
			--道具
			if Variant == 100 then
				local itemConfig = config:GetCollectible(SubType)
				if itemConfig then
					for tag,desc in pairs(FormList) do
						if itemConfig:HasTags(tag) then
							add = add..prefix..desc
						end
					end
					if StompyFrom[SubType] then --践踏套装
						add = add..prefix..(StompyFrom.info)
					end
				end
			end			
		
			--药丸
			if Variant == 70 then
				--成人套装
				if SubType == 9 then
					add = add..prefix..'{{Adult}} '..Translate('+ 1{{EternalHeart}}永恒之心', '+ 1 {{EternalHeart}}Eternal Heart')
				end
				
				--践踏套装
				if SubType == 32 then
					add = add..prefix..(StompyFrom.info)
				end
			end
		
			if add ~= '' then			
				EID:appendToDescription(desc, add)
			end
			
			return desc
		end
		EID:addDescriptionModifier('ibsHoardingTransformation'..'_'..LANG, condition, callback)
	end	


	do --表表游魂额外描述
	
		--箱子描述
		local Chest = LoadDesc('blost')
		
		for variant,tbl in pairs(Chest) do
			local name = Translate(tbl.Name[1], tbl.Name[2], LANG)
			EID:addEntity(5, variant, -1, name, "", LANG)
			for i = 0,100 do			
				EID:addEntity(5, variant, i, name, "", LANG)
				EID:AddIconToObject(5, variant, i, tbl.Icon)
			end
		end
	
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
			
			--道具
			if (Type == 5) and (Variant == 100) and (SubType > 0) and desc.Entity then
				local player = EID:ClosestPlayerTo(desc.Entity)
				if player and player:GetPlayerType() == (IBS_PlayerID.BLost) then
					return true
				end
			end
			
			--箱子
			if (Type == 5) and Chest[Variant] and desc.Entity then
				if Variant == PickupVariant.PICKUP_MEGACHEST then
					return true
				end
			
				local player = EID:ClosestPlayerTo(desc.Entity)
				if player and player:GetPlayerType() == (IBS_PlayerID.BLost) then
					return true
				end
			end

			return false
		end

		--添加额外内容
		local function callback(desc)
			local Variant = desc.ObjVariant
			local SubType = desc.ObjSubType
			local BLost = (mod.IBS_Player and mod.IBS_Player.BLost)
			
			if not BLost then return desc end
			
			--分解道具提示
			if Variant == 100 then
				local itemConfig = config:GetCollectible(SubType)
				if itemConfig and (BLost.DecomposeItem[SubType] or itemConfig:HasTags(ItemConfig.TAG_NO_LOST_BR)) then
					local num = 1 + 2 ^ itemConfig.Quality
					local add = Translate('将被分解为{{Key}}钥匙', 'Would be decomposed into {{Key}}keys', LANG)
					add = '#{{Player'..(IBS_PlayerID.BLost)..'}} '..add..' x '..math.floor(num)
					
					if itemConfig.Quality >= 2 then
						add = add..Translate(' 和箱子', ' and chests', LANG)..' x '..math.floor(itemConfig.Quality - 1)
					end
					
					EID:appendToDescription(desc, add)
				end
			else--箱子描述
				local add = ''
				
				--大箱子钥匙花费温馨提示,拒绝赌狗
				if EID.Config["ShowObjectID"] and Variant == PickupVariant.PICKUP_MEGACHEST and SubType > 0 then
					local keys = ' x '..SubType
					add = Translate('#开启还需{{Key}}钥匙', '#To be open needs {{Key}}keys', LANG)..keys..add
				end
				
				local player = EID:ClosestPlayerTo(desc.Entity)
				local ChestChest = (mod.IBS_Item and mod.IBS_Item.ChestChest)
				if BLost and player and Players:IsHoldingItem(player, IBS_ItemID.ChestChest)
					and ChestChest and ChestChest:CanStore(desc.Entity, player)
				then
					local selection = ChestChest:GetPlayerData(player).Selection
					local megaArmor = (BLost:GetMechaData(player)[2].Chest == 'Mega')
					local descType = ''
					local icon = ''
					
					--大箱护甲吸收箱子
					if megaArmor and selection == 2 then
						local bigger = (Variant == PickupVariant.PICKUP_MEGACHEST or Variant == PickupVariant.PICKUP_MOMSCHEST)
						icon = '#{{MegaChest}} {{IBSBlostArmor}}'
					
						--大箱或妈箱直接回满
						if bigger then
							add = add..icon..Translate(
								'耐久回满',
								'Full durability',
								LANG
							)
						else
							local num = (SubType > 0 and 1) or 0.4
							add = add..icon..Translate(
								'耐久恢复',
								'Durability recovers ',
								LANG
							)..num
						end
						
						--提升耐久上限并降低移速
						local mega = BLost:GetMegaAbsorption(player)
						if not mega[tostring(Variant)] then
							local num = (bigger and 3) or 1
							add = add..icon..Translate(
								'耐久上限提升',
								'Max durability increases ',
								LANG
							)..num
							add = add..icon..Translate(
								'无敌时间提升',
								'Invincible time increases',
								LANG
							)..(0.1*num)..Translate('秒', 's', LANG)
							add = add..icon..Translate(
								'↓{{Speed}}移速 - ',
								'↓{{Speed}}spd - ',
								LANG
							)..(0.1*num)
						end
					else
						if selection == 1 or selection == 3 then
							descType = 'Weapon'
							icon = '{{IBSBlostWeapon}} '						
						elseif selection == 2 then
							descType = 'Armor'
							icon = '{{IBSBlostArmor}} '
						elseif selection >= 4 and selection <= 6 then
							descType = 'Float'
							icon = '{{IBSBlostFloat}} '					
						end
						
						local chestDesc = Chest[Variant][descType]
						if chestDesc then
							for k,v in ipairs(chestDesc[LANG]) do						
								add = add..'#'..icon..v
							end
						end
						
						--贪婪模式特殊描述
						if game:IsGreedMode() and selection ~= 2 then
							if Variant == PickupVariant.PICKUP_REDCHEST then
								add = add..'#'..icon..'{{GreedMode}}'..Translate('贪婪模式：耐久消耗速度减半', 'Greed: Half durability consumption', LANG)
							elseif Variant ~= PickupVariant.PICKUP_ETERNALCHEST then
								add = add..'#'..icon..'{{GreedMode}}'..Translate('贪婪模式：50%概率不消耗耐久', 'Greed: 50% chance not to decrease durability', LANG)
							end
						end
					end
					
				end
				
				EID:appendToDescription(desc, add)
			end
			
			return desc
		end
		EID:addDescriptionModifier('ibsBLost'..'_'..LANG, condition, callback)
	end		
	
	do --募捐箱
	
		--触发条件
		local function condition(desc)
			local Type = desc.ObjType
			local Variant = desc.ObjVariant

			--检查语言
			local lang = EID:getLanguage()
			if lang ~= 'zh_cn' then lang = 'en_us' end
			if lang ~= LANG then
				return false
			end
			
			if (Type == 6) and (Variant == IBS_SlotID.CollectionBox.Variant) then
				return true
			end
				
			return false
		end

		--添加额外内容
		local function callback(desc)
			local CollectionBox = (mod.IBS_Slot and mod.IBS_Slot.CollectionBox)
			local add = '#'

			if CollectionBox then
				local data = CollectionBox:GetData()
				local boxLevel = CollectionBox:GetLevel()

				--升级提示
				if boxLevel < 5 then
					local threshold = CollectionBox.BoxLevelToCoin[boxLevel+1]
					if threshold then
						local coin = threshold - data.Coins
						add = add..Translate(
							'升级还需{{Coin}}硬币 x ', 
							'To upgrade needs {{Coin}}coin x ',
							LANG
						)..coin
					end
				end

				--统计触发事件
				local chance = string.format("%.1f", (math.min(7 + 7 * boxLevel + data.Coins, 250) / 10))
				add = add..'#'..Translate(
					'投入{{Coin}}硬币时，有', 
					'When Insert {{Coin}}coins, ',
					LANG
				)..chance..Translate(
					'%概率触发：', 
					'% chance to trigger:',
					LANG
				)
				
				--消除碎心或加幸运
				add = add..'#'..Translate(
					'消除1{{BrokenHeart}}碎心；若没有则全体角色获得0.5{{Luck}}幸运，最多10', 
					'Clear 1 {{BrokenHeart}}Broken Heart; Or all characters get 0.5 {{Luck}}luck up to 10',
					LANG
				)
					
				--消灭店长和贪婪
				if boxLevel >= 2 then
					add = add..'#'..Translate(
						'消灭贪婪和场景店主', 
						'Destroy Greed and scenery Keeper',
						LANG
					)
				end
				
				--生成乞丐
				if boxLevel >= 3 and not data.BeggerSpawned then
					add = add..'#'..Translate(
						'生成乞丐', 
						'Spawn a beggar',
						LANG
					)
				end
				
				--生成偷来的一年
				if boxLevel >= 4 and not data.CardSpawned then
					add = add..'#'..Translate(
						'生成{{Card'..(IBS_PocketID.StolenYear)..'}}偷来的一年', 
						'Spawn {{Card'..(IBS_PocketID.StolenYear)..'}}Stolen Year',
						LANG
					)
				end				
				
				--生成天梯
				if boxLevel >= 5 and not data.StairSpawned then
					add = add..'#'..Translate(
						'生成天梯实体', 
						'Spawn a stairway entity',
						LANG
					)
				end
				
				EID:appendToDescription(desc, add)
			end
			
			return desc
		end
		EID:addDescriptionModifier('ibsCollectionBox'..'_'..LANG, condition, callback)
	end		

	do --换脸商
	
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
			
			--换脸商或一张张脸
			if (Type == 6) and (Variant == IBS_SlotID.Facer.Variant) then
				return true
			end
			if (Type == 5) and (Variant == 100) and (SubType == IBS_ItemID.AFaces) then
				return true
			end
				
			return false
		end

		--添加额外内容
		local function callback(desc)
			local AFaces = (mod.IBS_Item and mod.IBS_Item.AFaces)
			local add = ''

			if AFaces then
				local cache = {}
				
				for _,id in ipairs(AFaces.TrinketList) do
					if not cache[id] then
						cache[id] = true
						add = add..'{{Trinket'..id..'}}'
					end
				end
				
				EID:appendToDescription(desc, add)
			end
			
			return desc
		end
		EID:addDescriptionModifier('ibsFacer'..'_'..LANG, condition, callback)
	end
	
	do --永乐大典
	
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
			
			if (Type == 5) and (Variant == 100) and (SubType == IBS_ItemID.Yongle) then
				return true
			end
				
			return false
		end

		--添加额外内容
		local function callback(desc)
			local Yongle = (mod.IBS_Item and mod.IBS_Item.Yongle)
		
			if Yongle then
				local add = Translate('#将触发：', '#Books to trigger: ', LANG)
				for _,id in ipairs(Yongle:GetBooks()) do
					add = add..'{{Collectible'..id..'}} '
				end
				EID:appendToDescription(desc, add)
			end

			return desc
		end
		EID:addDescriptionModifier('ibsYongle'..'_'..LANG, condition, callback)
	end	
	
	do --帘锁挖掘
		
		--ID转EID贴图
		local function ToIcon(id)
			local icon = ''
			local itemConfig = config:GetCollectible(id)
	
			if id > 0 and itemConfig and itemConfig:IsAvailable() then
				icon = '{{Collectible'..tostring(id)..'}}'
			else
				icon = Translate('错误道具', 'Error', LANG)
			end
			
			return icon
		end
		
		--触发条件
		local function condition(desc)
			local ent = desc.Entity
			local Type = desc.ObjType
			local Variant = desc.ObjVariant
			local SubType = desc.ObjSubType	
		
			--检查语言
			local lang = EID:getLanguage()
			if lang ~= 'zh_cn' then lang = 'en_us' end
			if lang ~= LANG then
				return false
			end
			
			if ent and (Type == 5) and (Variant == 100) and (SubType > 0) then
				return Players:AnyHasCollectible(IBS_ItemID.VainMiner)
			end
				
			return false
		end

		--添加额外内容
		local function callback(desc)
			local ent = desc.Entity
			local VainMiner = (mod.IBS_Item and mod.IBS_Item.VainMiner)
			if VainMiner and ent then
				local left = mod:GetIBSData('level').VainMinerCount
				
				--检查剩余次数
				if (not left) or left < 1 then
					local id = VainMiner:GetItem(ent.SubType, ent.InitSeed)
					
					local add = '#{{Collectible'..IBS_ItemID.VainMiner..'}} '..
								 Translate('将生成：', 'Next: ', LANG)..
								 ToIcon(id)
								
					EID:appendToDescription(desc, add)				
				end
			end
			return desc
		end
		EID:addDescriptionModifier('ibsVainMiner'..'_'..LANG, condition, callback)
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
		
		--祝福列表
		local BlessList = LoadDesc('my_fruit')
		
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
			
			if (Type == 5) and (Variant == 100) and (SubType == IBS_ItemID.MyFruit) then
				return AnotherPage
			end
				
			return false
		end

		--修改描述
		local function callback(desc)
			if AnotherPage then
				local newDesc = ''
				local greed = game:IsGreedMode()
				local colon = Translate('：', ': ', LANG)
				local greedDisabled = Translate('({{GreedMode}}禁用)', '({{GreedMode}}DISABLED)', LANG)
				
				for _,bless in ipairs(BlessList) do
					local N = mod:ChooseLanguageInTable(bless.name)
					local D = ''
					if (not bless.noGreed) or (not greed) then
						D = mod:ChooseLanguageInTable(bless.desc)
					else
						D = greedDisabled
					end
					newDesc = newDesc..'#'..N..colon..D
				end
				
 				desc.Description = newDesc
			end
			return desc
		end
		EID:addDescriptionModifier('ibsMyFruit'..'_'..LANG, condition, callback)
	end	
	
	
	do --参孙技能描述
	
		local BSamsonEID = Table.BSamsonEID
	
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
			
			if (Type == 5) and (Variant == 300) 
				and ((SubType >= 1 and SubType <= 22) or (SubType >= 56 and SubType <= 77))
				and desc.Entity
			then
				local player = EID:ClosestPlayerTo(desc.Entity)
				if player and player:HasCollectible(IBS_ItemID.Posture, true) then
					return true
				end
			end

			return false
		end

		--添加额外内容
		local function callback(desc)
			local SubType = desc.ObjSubType
			local player = desc.Entity and EID:ClosestPlayerTo(desc.Entity)
			local PostureIcon = '{{Collectible'..(IBS_ItemID.Posture)..'}} '
			local CalmIcon = '{{IBSSamsonCalm}} '
			local WrathIcon = '{{IBSSamsonWrath}} '
			local add = ''
			
			if player and Players:IsHoldingItem(player, IBS_ItemID.Posture) then
				local isBSamson = player:GetPlayerType() == (IBS_PlayerID.BSamson)
				local skill = BSamsonEID[SubType]
				if skill then				
					--暴怒普攻 / 其他角色使用架势
					if isBSamson then
						add = add..'#{{Player'..(IBS_PlayerID.BSamson)..'}} '..(skill.BSamson or skill.Common)
						
						if skill.Calm then
							add = add..'#'..PostureIcon..CalmIcon..skill.Calm						
						end
						if skill.Wrath then						
							add = add..'#'..PostureIcon..WrathIcon..skill.Wrath
						end
					else
						add = add..'#'..PostureIcon..skill.Common
					end
				end
			end
			
			EID:appendToDescription(desc, add)
			
			return desc
		end
		
		EID:addDescriptionModifier('ibsBSamson'..'_'..LANG, condition, callback)
	end
	
	
	do --米迦勒的赐福
	
		local BlessingOfMichaelEID = Table.BlessingOfMichaelEID

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
			
			--道具
			if (Type == 5) and (Variant == 100) and BlessingOfMichaelEID[SubType] and desc.Entity then
				local player = EID:ClosestPlayerTo(desc.Entity)
				if player and player:HasCollectible(IBS_ItemID.BlessingOfMichael) then
					return true
				end
			end
				
			return false
		end

		--添加额外内容
		local function callback(desc)
			local Variant = desc.ObjVariant
			local SubType = desc.ObjSubType
			local prefix = '#{{Collectible'..(IBS_ItemID.BlessingOfMichael)..'}} '
			local add = ''
		
			--道具
			if Variant == 100 then
				local itemConfig = config:GetCollectible(SubType)
				if itemConfig and BlessingOfMichaelEID[SubType] then
					add = add..BlessingOfMichaelEID[SubType]
				end
			end
		
			if add ~= '' then
				EID:appendToDescription(desc, prefix..add)
			end
			
			return desc
		end
		EID:addDescriptionModifier('ibsBlessingOfMichael'..'_'..LANG, condition, callback)
	end	


	do --原初之爪

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
			
			if (Type == 5) and (Variant == 300) and (SubType == 49) and desc.Entity then
				local player = EID:ClosestPlayerTo(desc.Entity)
				if player and player:HasCollectible(IBS_ItemID.SereTalon) then
					return true
				end
			end
				
			return false
		end

		--添加额外内容
		local function callback(desc)
			local Variant = desc.ObjVariant
			local SubType = desc.ObjSubType
			local add = '#{{Collectible'..(IBS_ItemID.SereTalon)..'}} '

			add = add..Translate(
				"改为将道具重置为{{Quality2}}品质2及以上的道具#!!! {{ColorRed}}获得随机{{Quality0}}品质0被动道具{{CR}}",
				"Instead, reroll items into {{Quality2}}Q2-or-above ones#!!! {{ColorRed}}Gain a random {{Quality0}}Q0 passive item{{CR}}",
			LANG)
			EID:appendToDescription(desc, add)		
				
			return desc
		end
		EID:addDescriptionModifier('ibsSereTalon'..'_'..LANG, condition, callback)
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