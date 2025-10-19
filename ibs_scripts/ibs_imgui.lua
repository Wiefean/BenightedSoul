--忏悔龙特色调试菜单

local mod = Isaac_BenightedSoul
local IBS_PlayerKey = mod.IBS_PlayerKey
local IBS_Curse = mod.IBS_Curse
local Screens = mod.IBS_Lib.Screens
local Ents = mod.IBS_Lib.Ents
local Stats = mod.IBS_Lib.Stats
local Levels = mod.IBS_Lib.Levels

local game = Game()

local _Menu = mod.Name..'_' --主菜单

--创建主菜单
ImGui.CreateMenu(_Menu, '\u{f654} '..(mod.NameStr))

--选择语言
local function Language(text_zh, text_en)
	return mod:ChooseLanguage(text_zh, text_en)
end

--是否在主界面
local function IsInMainMenu(disableTip)
	local inMainMenu, menuType = pcall(MenuManager.GetActiveMenu)
	
	if not disableTip then
		ImGui.PushNotification(Language('请回到主界面', 'Please come back to main menu'), ImGuiNotificationType.ERROR, 2500)
		return false
	end
	
	return inMainMenu
end

--是否在对局中
local function IsInRun(disableTip)
	local inRun = Isaac.IsInGame()
	if not inRun and not disableTip then
		ImGui.PushNotification(Language('请先进入对局', 'Please start a run first'), ImGuiNotificationType.ERROR, 2500)
	end
	return inRun
end

--存档栏是否已加载
local function IsSaveslotLoaded(disableTip)
	local inMainMenu, menuType = pcall(MenuManager.GetActiveMenu)

	if not inMainMenu then
		return true
	end

	if menuType <= 2 and not disableTip then
		ImGui.PushNotification(Language('请先加载存档', 'Please select a saveslot first'), ImGuiNotificationType.ERROR, 2500)
		return false
	end
	
	return true
end

--创建勾选框
--[[
"KEY"是数据存读系统中对应的索引,不适用于角色成就
"paperView"指的是对应的成就纸张贴图
]]
local function MakeCheckBox(parentId, KEY, name, help, paperView)
	local box = parentId..'_'..KEY
	ImGui.AddCheckbox(parentId, box, name)
	ImGui.AddCallback(box, ImGuiCallback.Render, function()
		ImGui.UpdateData(box, ImGuiData.Value, mod:GetIBSData('persis')[KEY])
	end)
	ImGui.AddCallback(box, ImGuiCallback.Edited, function()
		if not IsSaveslotLoaded() then
			return
		end

		local data = mod:GetIBSData('persis')
		data[KEY] = (not data[KEY])
		mod:SaveIBSData()
	end)
	
	if help then
		ImGui.SetHelpmarker(box, help)
	end	
	
	--浏览成就纸张按钮
	if paperView then
		ImGui.AddElement(parentId, '', ImGuiElement.SameLine)
		ImGui.AddButton(parentId, parentId..'_viewbtn_'..KEY, '\u{f06e}', function()
			if IsInMainMenu(true) then
				for _,paper in ipairs(paperView) do					
					Screens:PlayPaperOnMainMenu(paper)
				end
			elseif IsInRun(true) then
				for _,paper in ipairs(paperView) do					
					Screens:PlayPaper(paper)
				end
			end
			ImGui.Hide()
		end)
	end	
end


--------↓成就板块↓--------
local _Achiev =  _Menu..'Achiev' --成就板块
local _AchievWindow =  _Menu..'AchievWindow' --成就窗口
local _AchievTabBar = _Menu..'AchievTabBar' --成就点选框
local _AchievTab1 = _Menu..'AchievTab1' --角色栏
local _AchievTab2 = _Menu..'AchievTab2' --挑战栏
local _AchievTab3 = _Menu..'AchievTab3' --物品栏

ImGui.AddElement(_Menu, _Achiev, ImGuiElement.MenuItem, '\u{f091}'..(Language('成就', 'Achievements')) )
ImGui.CreateWindow(_AchievWindow, '\u{f091}'..(Language('成就', 'Achievements')) )
ImGui.LinkWindowToElement(_AchievWindow, _Achiev)

ImGui.AddTabBar(_AchievWindow, _AchievTabBar)
ImGui.AddTab(_AchievTabBar, _AchievTab1, Language('角色', 'Characters') )
ImGui.AddTab(_AchievTabBar, _AchievTab2, Language('挑战', 'Challenges') )
ImGui.AddTab(_AchievTabBar, _AchievTab3, Language('物品', 'Items') )


----↓角色栏相关↓----
do

--角色成就
local Marks = {
	'Unlocked',
	'Heart',
	'Isaac',
	'BlueBaby',
	'Satan',
	'Lamb',
	'MegaSatan',
	'BossRush',
	'Hush',
	'Delirium',
	'Witness',
	'Beast',
	'Greed',
	'FINISHED'
}

--角色成就名称
local Name = {
	Unlocked = Language('角色解锁状态', 'Character Unlocked'),
	Heart = Language('心脏', 'Heart'),
	Isaac = Language('以撒', 'Isaac'),
	BlueBaby = Language('???', '???'),
	Satan = Language('撒但', 'Satan'),
	Lamb = Language('羔羊', 'Lamb'),
	MegaSatan = Language('超级撒但', 'Mega Satan'),		
	BossRush = Language('头目车轮战', 'Boss Rush'),		
	Hush = Language('死寂', 'Hush'),		
	Delirium = Language('精神错乱', 'Delirium'),
	Witness = Language('母亲', 'Mother'),
	Beast = Language('祸兽', 'Beast'),
	Greed = Language('究极贪婪', 'Ultra Greed'),
	FINISHED = Language('全标记达成', 'ALL MARKS FINISHED'),
}

--创建角色成就栏
local function MakeCharacterBar(playerKey, name, marksDesc, paperView)
	local header = _AchievTab1..'_'..playerKey
	ImGui.AddElement(_AchievTab1, header, ImGuiElement.CollapsingHeader, name )
	
	--创建勾选框
	for _,mark in ipairs(Marks) do
		local box = header..'_'..mark
		ImGui.AddCheckbox(header, box, Name[mark])
		ImGui.AddCallback(box, ImGuiCallback.Render, function()
			ImGui.UpdateData(box, ImGuiData.Value, mod:GetIBSData('persis')[playerKey][mark])
		end)
		ImGui.AddCallback(box, ImGuiCallback.Edited, function()
			if not IsSaveslotLoaded() then
				return
			end

			local data = mod:GetIBSData('persis')
			data[playerKey][mark] = (not data[playerKey][mark])
			mod:SaveIBSData()
		end)

		--解锁物说明
		local help = marksDesc[mark]
		if mark == 'Hush' then --死寂
			help = Language('解锁对应伪忆', 'Falsehood')
		end
		if help then
			if mark == 'FINISHED' then
				help = help..Language('\n(改动此项仅影响单个成就)', '\n(Only affects single achievement)')
			end
			ImGui.SetHelpmarker(box, help)
		end

		--浏览成就纸张按钮
		if paperView then
			local tbl = paperView[mark]
			if tbl then			
				ImGui.AddElement(header, '', ImGuiElement.SameLine)
				ImGui.AddButton(header, header..'_viewbtn_'..mark, '\u{f06e}', function()
					if IsInMainMenu(true) then
						for _,paper in ipairs(tbl) do					
							Screens:PlayPaperOnMainMenu(paper)
						end
					elseif IsInRun(true) then
						for _,paper in ipairs(tbl) do					
							Screens:PlayPaper(paper)
						end
					end
					ImGui.Hide()
				end)
			end
		end	

	end	
end

MakeCharacterBar(IBS_PlayerKey.BIsaac, Language('以撒', 'Isaac'), 
{
	Unlocked = Language('在以撒/堕化以撒死于撒但房间的下一局，再次使用以撒/堕化以撒击败撒但以解锁', 'In a run next the one Isaac / Tainted Isaac died in Satan\'s room, Isaac / Tainted Isaac beat Satan to unlock'),
	Heart = Language('解锁 "成套收集"', 'For "Hoarding"'),
	Isaac = Language('解锁 "爸爸的约定"', 'For "Dad\'s Promise"'),
	BlueBaby = Language('解锁 "嗝屁猫砂盆"', 'For "Guppys Potty"'),
	Satan = Language('解锁 "酒瓶碎片"', 'For "Bootle Shard"'),
	Lamb = Language('解锁 "赌徒之眼"', 'For "Gamblers Eye"'),
	MegaSatan = Language('解锁 "六面骰黄金典藏版"', 'For "The Great Golden Collectible -- D6"'),	
	BossRush = Language('解锁 "骰影仪"', 'For "Dice Projector"'),
	Delirium = Language('解锁 "光辉六面骰"', 'For "The Light D6"'),
	Witness = Language('解锁 "骨猪一掷"', 'For "Bacon Saver"'),
	Beast = Language('解锁 "拒绝选择"', 'For "No Options"'),
	Greed = Language('解锁 "仰望星空"', 'For "Shooting Stars Gazer"'),
	FINISHED = Language('解锁 "节制"', 'For "Temperance"'),
},
{
	Unlocked = {'bisaac_unlock', 'bc1'},
	Heart = {'hoarding'},
	Isaac = {'dads_promise'},
	BlueBaby = {'guppys_potty'},
	Satan = {'bottle_shard'},
	Lamb = {'gamblers_eye'},
	MegaSatan = {'czd6'},	
	BossRush = {'dice_projector'},
	Hush = {'bisaac_falsehood'},
	Delirium = {'light_d6'},
	Witness = {'bacon_saver'},
	Beast = {'no_options'},
	Greed = {'ssg'},
	FINISHED = {'boss_temperance'},
})
MakeCharacterBar(IBS_PlayerKey.BMaggy, Language('抹大拉', 'Magdalene'), {
	Unlocked = Language('抹大拉/堕化抹大拉重新进入一个未使用的献祭房并完成遭遇战(每层最多一次)，重复7次以解锁', 'Magdalene / Tainted Magdalene re-enters an unused Sacrifice Room and finishes the encounter(only once for a level) for 7 times to unlock'),
	Heart = Language('解锁 "铅制心脏"', 'For "Leaden Heart"'),
	Isaac = Language('解锁 "教堂玻璃窗"', 'For "Cathedral Window"'),
	BlueBaby = Language('解锁 "瓷"', 'For "China"'),
	Satan = Language('解锁 "神圣反击"', 'For "Divine Retaliation"'),
	Lamb = Language('解锁 "硬的心"', 'For "Tough Heart"'),
	MegaSatan = Language('解锁 "金色祈者"', 'For "Golden Prayer"'),	
	BossRush = Language('解锁 "银色手镯"', 'For "Silver Bracelet"'),
	Delirium = Language('解锁 "发光的心"', 'For "Glowing Heart"'),
	Witness = Language('解锁 "月桂枝"', 'For "Lunar Twigs"'),
	Beast = Language('解锁 "钻石"', 'For "Diamoond"'),
	Greed = Language('解锁 "瓦伦丁巧克力"', 'For "Valentine Chocolate"'),
	FINISHED = Language('解锁 "坚韧"', 'For "Fortitude"'),
},
{
	Unlocked = {'bmaggy_unlock', 'bc2'},
	Heart = {'leaden_heart'},
	Isaac = {'cathedral_window'},
	BlueBaby = {'china'},
	Satan = {'divine_retaliation'},
	Lamb = {'tough_heart'},
	MegaSatan = {'golden_prayer'},
	BossRush = {'silver_bracelet'},
	Hush = {'bmaggy_falsehood'},
	Delirium = {'glowing_heart'},
	Witness = {'lunar_twigs'},
	Beast = {'diamoond'},
	Greed = {'chocolate'},
	FINISHED = {'boss_fortitude'},
})
MakeCharacterBar(IBS_PlayerKey.BCBA, Language('该隐&亚伯', 'Cain & Abel'), {
	Unlocked = Language('该隐/堕化该隐单层献祭12次获取道具死亡回放，并携带亚伯在之后暗室的墓地使用死亡回味以解锁', 'Cain / Tainted Cain sacrifices for 12 times to gain Re-death, and then use Re-death in the graveyard of Dark Room with Abel to unlock'),
	Heart = Language('解锁 "死亡回放"', 'For "Re-death"'),
	Isaac = Language('解锁 "兔头"', 'For "Rabbit Head"'),
	BlueBaby = Language('解锁 "不受欢迎的祭品"', 'For "Unwelcome Sacrifice"'),
	Satan = Language('解锁 "左断脚"', 'For "Left Foot"'),
	Lamb = Language('解锁 "受欢迎的祭品"', 'For "Welcome Sacrifice"'),
	MegaSatan = Language('解锁 "种子袋"', 'For "Seed Bag"'),
	BossRush = Language('解锁 "以太之云"', 'For "Ether"'),
	Delirium = Language('解锁 "移动农场", "变羊术" 和 "小麦种子"', 'For "Portable Farm", "Goatify" and "Wheat Seeds"'),
	Witness = Language('解锁 "天谴报应"', 'For "Nemesis"'),
	Beast = Language('解锁 "核能电罐"', 'For "Super B"'),
	Greed = Language('解锁 "贫瘠"', 'For "Barren"'),
	FINISHED = Language('解锁 "勤勤 & 劳劳"', 'For "Deligence & Diligence"'),
},
{
	Unlocked = {'bcain_babel_unlock'},
	Heart = {'redeath'},
	Isaac = {'rabbit_head'},
	BlueBaby = {'sacrifice'},
	Satan = {'left_foot'},
	Lamb = {'sacrifice2'},
	MegaSatan = {'seed_bag'},
	BossRush = {'ether'},
	Hush = {'bcain_babel_falsehood'},
	Delirium = {'farm'},
	Witness = {'nemesis'},
	Beast = {'superb'},
	Greed = {'barren'},
	--FINISHED = {''},
})
MakeCharacterBar(IBS_PlayerKey.BJudas, Language('犹大', 'Judas'), {
	Unlocked = Language('使用犹大在第一层进入隐藏房花费3硬币获取圣经后，在撒但房间使用圣经以解锁', 'Judas pays 3 coins for The Bible in the Secret Room of the first level, and then use The Bible in Satan\'s room to unlock'),
	Heart = Language('解锁 "晦涩之心"', 'For "Tenebrosity"'),
	Isaac = Language('解锁 "表观思维"', 'For ""Presentational Mind'),
	BlueBaby = Language('解锁 "出口产品"', 'For "Export"'),
	Satan = Language('解锁 "混沌信仰"', 'For "Chaotic Belief"'),
	Lamb = Language('解锁 "规则书"', 'For "Rules Book"'),
	MegaSatan = Language('解锁 "募捐箱"和"偷来的一年"', 'For "Collection Box" and "Stolen Year"'),	
	BossRush = Language('解锁 "偷来的十年"', 'For "Stolen Decade"'),
	Delirium = Language('解锁 "犹大福音"', 'For "The Gospel Of Judas"'),
	Witness = Language('解锁 "荆棘指环"', 'For "Throny Ring"'),
	Beast = Language('解锁 "紫电护主之刃"', 'For "Sword of Siberite"'),
	Greed = Language('解锁 "备用钉子"', 'For "Reserved Nail"'),
	FINISHED = Language('解锁 "谦逊"', 'For "Humility"'),
},
{
	Unlocked = {'bjudas_unlock', 'bc4'},
	Heart = {'tenebrosity'},
	Isaac = {'presentational_mind'},
	BlueBaby = {'export'},
	Satan = {'chaotic_belief'},
	Lamb = {'rules_book'},
	MegaSatan = {'collectionbox'},
	BossRush = {'stolen_decade'},
	Hush = {'bjudas_falsehood'},
	Delirium = {'tgoj'},
	Witness = {'throny_ring'},
	Beast = {'sword'},
	Greed = {'nail'},
	--FINISHED = {''},
})
MakeCharacterBar(IBS_PlayerKey.BXXX, Language('???', '???'), {
	Unlocked = Language('使用???/堕化???进入家层的红房间获取薇艺以解锁', '??? / Tainted ??? gets Falowerse in the red room of Home to unlock'),
	Heart = Language('解锁 "割礼"', 'For "Circumcision"'),
	Isaac = Language('解锁 "金针菇"', 'For "Needle Mushroom"'),
	BlueBaby = Language('解锁 "悼歌之冬"和"挽歌儿小姐"', 'For "Elegiast Winter" and "Nenia Dea"'),
	Satan = Language('解锁 "筵宴之杯"', 'For "Grail"'),
	Lamb = Language('解锁 "蜕变之蛾"', 'For "Moth"'),
	MegaSatan = Language('解锁 "美德七面骰"', 'For "V7"'),	
	BossRush = Language('解锁 "俗世的武器"', 'For "Profane Weapon"'),
	Delirium = Language('解锁 "薇艺"', 'For "Falowerse"'),
	Witness = Language('解锁 "腐蚀套牌"', 'For "Corrupted Deck"'),
	Beast = Language('解锁 "白日之铸"', 'For "Forge"'),
	Greed = Language('解锁 "流亡之刃"', 'For "Edge"'),
	FINISHED = Language('解锁 "浪游秘史"', 'For "Secret Histories"'),
},
{
	Unlocked = {'bxxx_unlock'},
	Heart = {'circumcision'},
	Isaac = {'needle_mushroom'},
	BlueBaby = {'elegiast_winter'},
	Satan = {'grail'},
	Lamb = {'moth'},
	MegaSatan = {'v7'},
	BossRush = {'profane_weapon'},
	Hush = {'bxxx_falsehood'},
	Delirium = {'falowerse'},
	Witness = {'corrupted_deck'},
	Beast = {'forge'},
	Greed = {'edge'},
	FINISHED = {'secret_histories'},
})
MakeCharacterBar(IBS_PlayerKey.BEve, Language('夏娃', 'Eve'), {
	Unlocked = Language('使用夏娃，在不激活巴比伦大淫妇 (包括皇后卡牌的效果) 的情况下死亡以解锁', 'Eve dies without activating Whore of Babylon (Tarot Card Queen included) to unlock'),
	Heart = Language('解锁 "禁断之果"', 'For "The Forbidden Fruit"'),
	Isaac = Language('解锁 "真实之眼"', 'For "The Eye of Truth"'),
	BlueBaby = Language('解锁 "永乐大典"', 'For "Yongle"'),
	-- Satan = Language('解锁 ""', 'For ""'),
	-- Lamb = Language('解锁 ""', 'For ""'),
	-- MegaSatan = Language('解锁 ""', 'For ""'),
	BossRush = Language('解锁 "套作"', 'For "Reused Story"'),
	Delirium = Language('解锁 "我果"和"我过"', 'For "My Fruit" and "My Fault"'),
	Witness = Language('解锁 "偏方"', 'For "Folk Prescription"'),
	Beast = Language('解锁 "焚烧不焚之神"', 'For "Burning of Unburnt God"'),
	Greed = Language('解锁 "索斯星"', 'For "Zoth"'),
	-- FINISHED = Language('解锁 ""', 'For ""'),
},
{
	Unlocked = {'beve_unlock'},
	Heart = {'ffruit'},
	Isaac = {'the_eye_of_truth'},
	BlueBaby = {'yongle'},
	-- Satan = {'vein_miner'},
	-- Lamb = {'vain_miner'},
	-- MegaSatan = {'v7'},
	BossRush = {'reused_story'},
	Hush = {'beve_falsehood'},
	Delirium = {'my_fruit_fault'},
	Witness = {'folk_prescription'},
	Beast = {'burning_of_unburnt_god'},
	Greed = {'zoth'},
	-- FINISHED = {'secret_histories'},
})
MakeCharacterBar(IBS_PlayerKey.BEden, Language('伊甸', 'Eden'), {
	Unlocked = Language('伊甸/堕化伊甸在开局留在初始房间等待2分钟左右以解锁', 'Eden / Tainted Eden stays in the starting room at the start of a run for about 2 minutes to unlock'),
	Heart = Language('解锁 "21点"', 'For "Blackjack"'),
	Isaac = Language('解锁 "区间"', 'For "Interval"'),
	BlueBaby = Language('解锁 "分子植物"', 'For "Molekale"'),
	Satan = Language('解锁 "炖蛇羹"', 'For "Ssstew"'),
	Lamb = Language('解锁 "写生"', 'For "Sketch"'),
	MegaSatan = Language('解锁 "存档修正": 错误道具和错误技将在重进房间后被重置', 'For "Corrected Data": Error Items and TMTrainer will be rerolled when re-entering the room'),	
	BossRush = Language('解锁 "超紧急按钮"', 'For "Super Panic Button"'),
	Delirium = Language('解锁 "已定义"', 'For "Defined"'),
	Witness = Language('解锁 "源数之力"', 'For "Numeron Force"'),
	Beast = Language('解锁 "超立方"', 'For "Hypercube"'),
	Greed = Language('解锁 "全知之书"', 'For "Book of Seen"'),
	FINISHED = Language('解锁 "四维骰"', 'For "D4D"'),
},
{
	Unlocked = {'beden_unlock'},
	Heart = {'blackjack'},
	Isaac = {'interval'},
	BlueBaby = {'molekale'},
	Satan = {'ssstew'},
	Lamb = {'sketch'},
	MegaSatan = {'corrected_data'},
	BossRush = {'super_panic_button'},
	Hush = {'beden_falsehood'},
	Delirium = {'defined'},
	Witness = {'numeron_force'},
	Beast = {'hypercube'},
	Greed = {'book_of_seen'},
	FINISHED = {'d4d'},
})
MakeCharacterBar(IBS_PlayerKey.BLost, Language('游魂', 'The Lost'), {
	Unlocked = Language('使用游魂/堕化游魂，在一层被炸弹棉花怪杀死，在三层被炸弹杀死，在六层被妈妈杀死，最后在十层被撒但杀死以解锁', 'Play as The Lost / Tainted Lost, die from Mulliboom at stage 1, a bomb at stage 3, Mom at stage 6 and Satan at stage 10 to unlock'),
	Heart = Language('解锁 "宝库钥匙"', 'For "Treasure Key"'),
	Isaac = Language('解锁 "迷途之镜"', 'For "Wildering Mirror"'),
	BlueBaby = Language('解锁 "双角斧"', 'For "The Horned-Axe"'),
	Satan = Language('解锁 "月下异巷"', 'For "Moon Streets"'),
	Lamb = Language('解锁 "AKEY-47"', 'For "AKEY-47"'),
	MegaSatan = Language('解锁 "真理小子"和"真理宝箱"', 'For "Brother Albern" and "Truth Chest"'),	
	BossRush = Language('解锁 "怪异钥匙"', 'For "Odd Key"'),
	Delirium = Language('解锁 "箱中箱宝库"', 'For "Chest Chest"'),
	Witness = Language('解锁 "三色杯"', 'For "For "Neopolitan"'),
	Beast = Language('解锁 "洞开之启"', 'For "Knock"'),
	Greed = Language('解锁 "北落师门"', 'For "Fomalhunt"'),
	FINISHED = Language('解锁 "银之钥"', 'For "The Silver Key"'),
},
{
	Unlocked = {'blost_unlock'},
	Heart = {'treasure_key'},
	Isaac = {'wildering_mirror'},
	BlueBaby = {'the_horned_axe'},
	Satan = {'moon_streets'},
	Lamb = {'akey47'},
	MegaSatan = {'brother_albern'},
	BossRush = {'odd_key'},
	Hush = {'blost_falsehood'},
	Delirium = {'chest_chest'},
	Witness = {'neopolitan'},
	Beast = {'knock'},
	Greed = {'fomalhunt'},
	FINISHED = {'the_silver_key'},
})
MakeCharacterBar(IBS_PlayerKey.BKeeper, Language('店主', 'The Keeper'), {
	Unlocked = Language('将捐款机捐至999，并将贪婪捐款机归零以解锁', 'Donate to Donation Machine till 999 and make Greed Donation Machine return to zero to unlock'),
	Heart = Language('解锁 "施粥处"', 'For "Alms"'),
	Isaac = Language('解锁 "万能药"', 'For "Panacea"'),
	BlueBaby = Language('解锁 "接触的G"，"增殖的G"，"潜伏的G"，"对峙的G"和"应战的G"', 'For "Contact C", "Maxx C", "Sneaky C", "Confronting C" and "RetaliatingC"'),
	Satan = Language('解锁 "小小角恶魔"', 'For "Mini Horn"'),
	Lamb = Language('解锁 "富饶矿脉"', 'For "Rich Mines"'),
	MegaSatan = Language('解锁 "错误硬币"，"星空硬币"，"纸质硬币"，"古老硬币"和"慷慨一些": 贪婪商店中更可能出现捐款机', 'For "Glitched Penny", "Starry Penny", "Paper Penny", "Old Penny" and "Generous-er": Donation Machine tends to appear in Shop in Greed Mode'),	
	BossRush = Language('解锁 "邪教徒头套"，"蛇的头"，"牧师的脸"，"恩洛斯的脸"，"地精容貌"和"换脸商"', 'For "Cultist Mask", "Ssserpent Head", "Cleric Face", "Nloths Mask", "Gremlin Mask" and "Facer"'),
	Delirium = Language('解锁"异业"', 'For "Another Karma"'),
	Witness = Language('解锁 "018"', 'For "018"'),
	Beast = Language('解锁 "只剩亿点"', 'For "Multiplication"'),
	Greed = Language('解锁 "大师组合包", "增殖"和"微笑世界"', 'For "Master Pack", "Multiply" and "Smile World"'),
	FINISHED = Language('解锁 "慷慨"', 'For "Generosity"'),
},
{
	Unlocked = {'bkeeper_unlock'},
	Heart = {'alms'},
	Isaac = {'panacea'},
	BlueBaby = {'contact_c'},
	Satan = {'minihorn'},
	Lamb = {'rich_mines'},
	MegaSatan = {'generouser'},
	BossRush = {'faces'},
	Hush = {'bkeeper_falsehood'},
	Delirium = {'another_karma'},
	Witness = {'scp'},
	Beast = {'multiplication'},
	Greed = {'master_pack'},
	--FINISHED = {''},
})


end
----↑角色栏相关↑----


----↓挑战栏相关↓----
do
	MakeCheckBox(_AchievTab2, 'bc1', Language('乾坤十掷', 'Rolling Destiny'), Language('完成以强化昧化以撒', 'Finish it to boost Benighted Isaac'), {'bisaac_up'} )
	MakeCheckBox(_AchievTab2, 'bc2', Language('易碎品', 'The Fragile'), Language('完成以强化昧化抹大拉', 'Finish it to boost Benighted Magdalene'), {'bmaggy_up'} )
	MakeCheckBox(_AchievTab2, 'bc3', Language('牧地 !', 'Graze !'), Language('完成以强化昧化该隐&亚伯', 'Finish it to boost Benighted Cain & Abel'), {'bcain_babel_up'} )
	MakeCheckBox(_AchievTab2, 'bc4', Language('逾越节', 'Passover'), Language('完成以强化昧化犹大', 'Finish it to boost Benighted Judas'), {'bjudas_up'} )
	MakeCheckBox(_AchievTab2, 'bc5', Language('双重释放', 'Dualcast'), Language('完成以强化昧化???', 'Finish it to boost Benighted ???'), {'bxxx_up'} )
	MakeCheckBox(_AchievTab2, 'bc6', Language('池沼魔谷', 'Marsh Rooms'), Language('完成以强化昧化夏娃', 'Finish it to boost Benighted Eve'), {'beve_up'} )
	
	MakeCheckBox(_AchievTab2, 'bc10', Language('天妒英才', 'Envery'), Language('完成以强化昧化伊甸', 'Finish it to boost Benighted Eden'), {'beden_up'} )
	MakeCheckBox(_AchievTab2, 'bc11', Language('钥匙变炸弹', 'Keys are bomb'), Language('完成以强化昧化游魂', 'Finish it to boost Benighted Lost'), {'blost_up'} )
	
	MakeCheckBox(_AchievTab2, 'bc13', Language('慷慨模式', 'Generosity Mode'), Language('完成以强化昧化店主', 'Finish it to boost Benighted Keeper'), {'bkeeper_up'} )
end
----↑挑战栏相关↑----


----↓物品栏相关↓----
do
	ImGui.AddElement(_AchievTab3, '', ImGuiElement.SeparatorText, Language('道具', 'Collectibles') )
	MakeCheckBox(_AchievTab3, 'dreggyPieUnlocked', Language('掉渣饼', 'Dreggie Pie'), Language('问问雅阁怎么解锁', 'To unlock, ask Jacob'), {'dreggy_pie'} )
	MakeCheckBox(_AchievTab3, 'geUnlocked', Language('黄金体验', 'Gold Experience'), Language('店主或堕化店主死在硬币旁以解锁', 'Keeper or Tainted Keeper dies near a coin to unlock'), {'ge'} )
end
----↑物品栏相关↑----

--------↑成就板块↑--------




--------↓设置板块↓--------
do

local _Setting =  _Menu..'Setting' --设置板块
local _SettingWindow =  _Menu..'SettingWindow' --设置窗口
local _SettingTabBar = _Menu..'SettingTabBar' --设置点选框
local _SettingTabD = _Menu..'SettingTabD' --难度栏
local _SettingTabC = _Menu..'SettingTabC' --诅咒栏
local _SettingTabS = _Menu..'SettingTabS' --可互动实体栏
local _SettingTabB = _Menu..'SettingTabB' --头目栏
local _SettingTabG = _Menu..'SettingTabG' --杂项栏

ImGui.AddElement(_Menu, _Setting, ImGuiElement.MenuItem, '\u{f013}'..(Language('设置', 'Settings')) )
ImGui.CreateWindow(_SettingWindow, '\u{f013}'..(Language('设置', 'Settings')) )
ImGui.LinkWindowToElement(_SettingWindow, _Setting)

ImGui.AddTabBar(_SettingWindow, _SettingTabBar)
ImGui.AddTab(_SettingTabBar, _SettingTabD, Language('难度', 'Difficulty') )
ImGui.AddTab(_SettingTabBar, _SettingTabC, Language('诅咒', 'Curses') )
ImGui.AddTab(_SettingTabBar, _SettingTabS, Language('可互动实体', 'Slots') )
ImGui.AddTab(_SettingTabBar, _SettingTabB, Language('头目', 'Bosses') )
ImGui.AddTab(_SettingTabBar, _SettingTabG, Language('杂项', 'Groceries') )


----↓难度栏相关↓----
do
	--创建小数输入框
	local function MakeFloatInput(parentId, KEY, name, step)
		local input = parentId..KEY
		ImGui.AddInputFloat(parentId, input, name, nil, 0, step, step)
		ImGui.AddCallback(input, ImGuiCallback.Render, function()
			ImGui.UpdateData(input, ImGuiData.Value, mod:GetIBSData('persis')[KEY])
		end)	
		ImGui.AddCallback(input, ImGuiCallback.DeactivatedAfterEdit, function(value)
			if not IsSaveslotLoaded() then
				return
			end	
			value = math.max(0, value)
			local data = mod:GetIBSData('persis')
			data[KEY] = value	
			mod:SaveIBSData()
			ImGui.UpdateData(_DebugTab1_Input, ImGuiData.Value, value)
		end)		
	end

	MakeCheckBox(_SettingTabD, 'difficulty_enemy_hp_up', Language('敌人血量增长', 'Enemy Hp Increaser'), Language('将按层数增长', 'Increase by levels') )
	MakeFloatInput(_SettingTabD, 'difficulty_enemy_level_mult', Language('普通敌人增长倍率', 'Mult For Non-boss'), 0.05)
	MakeFloatInput(_SettingTabD, 'difficulty_boss_level_mult', Language('头目增长倍率', 'Mult For Boss'), 0.05)
	
	--敌人血量增长
	local cache = {}
	local function EnemyHpUp(npc)
		if not mod:GetIBSData('persis')["difficulty_enemy_hp_up"] then return end
		local key = GetPtrHash(npc) + npc.Type + npc.Variant + npc.SubType
		if npc:IsActiveEnemy(false) and not cache[key] then
			local mult = 0.3
			if npc:IsBoss() then
				mult = mod:GetIBSData('persis')["difficulty_boss_level_mult"] or mult
			else
				mult = mod:GetIBSData('persis')["difficulty_enemy_level_mult"] or mult
			end
			
			mult = mult * math.max(0, game:GetLevel():GetStage() - 1) + 1
			npc.MaxHitPoints = math.ceil(npc.MaxHitPoints * mult)
			npc.HitPoints = math.ceil(npc.HitPoints * mult)
			
			cache[key] = EntityPtr(npc)
		end
	end
	mod:AddPriorityCallback(ModCallbacks.MC_POST_NPC_INIT, -1000, function(_,npc)
		EnemyHpUp(npc)
	end)
	mod:AddPriorityCallback(ModCallbacks.MC_NPC_UPDATE, -1000, function(_,npc)	
		EnemyHpUp(npc)
	end)
	mod:AddPriorityCallback(ModCallbacks.MC_POST_UPDATE, -1000, function()
		--清理缓存
		for k,v in pairs(cache) do
			local ent = v.Ref
			if ent ~= nil then
				if not ent:Exists() or ent:IsDead() then
					cache[k] = nil
				end
			else
				cache[k] = nil
			end
		end
	end)
end
----↑诅咒栏相关↑----


----↓诅咒栏相关↓----
do
	MakeCheckBox(_SettingTabC, 'curse_moving', Language('动人诅咒', 'Curse Of Moving') )
	MakeCheckBox(_SettingTabC, 'curse_d7', Language('七面骰诅咒', 'Curse Of D7') )
end
----↑诅咒栏相关↑----


----↓可互动实体栏相关↓----
do
	MakeCheckBox(_SettingTabS, 'slot_collectionBox', Language('募捐箱', 'Collectio Box') )
	MakeCheckBox(_SettingTabS, 'slot_albern', Language('真理小子', 'Brother Albern') )
	MakeCheckBox(_SettingTabS, 'slot_facer', Language('换脸商', 'Facer') )
	MakeCheckBox(_SettingTabS, 'slot_envoy', Language('使者', 'Envoy') )
end
----↑可互动实体相关↑----	
	
	
----↓头目栏相关↓----
do
	MakeCheckBox(_SettingTabB, 'boss_deligence_diligence', Language('勤勤 & 劳劳', 'Deligence & Diligence') )
	MakeCheckBox(_SettingTabB, 'boss_fortitude', Language('坚韧', 'Fortitude') )
	MakeCheckBox(_SettingTabB, 'boss_temperance', Language('节制', 'Temperance') )
	MakeCheckBox(_SettingTabB, 'boss_generosity', Language('慷慨', 'Generosity') )
	MakeCheckBox(_SettingTabB, 'boss_humility', Language('谦逊', 'Humility') )
end
----↑头目栏相关↑----
	
	
----↓杂项栏相关↓----
do
	MakeCheckBox(_SettingTabG, 'voidUp', Language('虚空增强', 'Void Up'), Language('对饰品生效', 'Can absrob trinkets') )
	MakeCheckBox(_SettingTabG, 'abyssUp', Language('无底坑增强', 'Abyss Up'), Language('对饰品生效', 'Can absrob trinkets') )
	MakeCheckBox(_SettingTabG, 'envyDisguise', Language('女疾女户伪装', "Ennnnnnvyyyyyy's disguise") )
	MakeCheckBox(_SettingTabG, 'envyJS', Language('女疾女户跳脸', "Ennnnnnvyyyyyy's jump scare") )
	MakeCheckBox(_SettingTabG, 'otto', Language('女疾女户特殊跳脸音效', "Ennnnnnvyyyyyy's special jump scare sfx") )
	MakeCheckBox(_SettingTabG, 'envyRemove', Language('将女疾女户移出道具池', "Remove Ennnnnnvyyyyyy from item pools") )
	MakeCheckBox(_SettingTabG, 'tipI', Language('角色菜单按键提示', 'Character menu control tip') )
	MakeCheckBox(_SettingTabG, 'rewindCompat', Language('发光沙漏兼容', 'Glowing Hour Glass compatibility'), Language('对控制台指令"rewind"无效', 'No effect on CMD "rewind"') )
	
	--虚空增强(吸收饰品)
	local function VoidUp(_,item, rng, player, flags)
		if mod:GetIBSData('persis')["voidUp"] then
			for _,ent in ipairs(Isaac.FindByType(5, 350)) do
				local trinket = ent:ToPickup()
				if trinket.SubType > 0 and trinket.Price == 0 then
					player:AddSmeltedTrinket(trinket.SubType, trinket.Touched)
					Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, trinket.Position, Vector.Zero, nil)						
					trinket:Remove()
				end
			end
		end
	end
	mod:AddCallback(ModCallbacks.MC_USE_ITEM, VoidUp, 477)


	--无底坑增强(吸收饰品)
	local function AbyssUp(_,item, rng, player, flags)
		if mod:GetIBSData('persis')["abyssUp"] then
			for _,ent in ipairs(Isaac.FindByType(5, 350)) do
				local trinket = ent:ToPickup()
				if trinket.SubType > 0 and trinket.Price == 0 then
					local locust = Isaac.Spawn(3, FamiliarVariant.ABYSS_LOCUST, 2, trinket.Position, Vector.Zero, player):ToFamiliar()
					locust.Player = player
					Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, trinket.Position, Vector.Zero, nil)						
					trinket:Remove()
				end
			end		
		end
	end
	mod:AddCallback(ModCallbacks.MC_USE_ITEM, AbyssUp, 706)	
end
----↑杂项栏相关↑----

end
--------↑设置板块↑--------




--------↓测试板块↓--------
do

local _Debug = _Menu..'Debug' --测试板块
local _DebugWindow = _Menu..'DebugWindow' --测试窗口
local _DebugTabBar = _Menu..'DebugTabBar' --测试栏点选框
local _DebugTab1 = _Menu..'DebugTab1' --资源栏
local _DebugTab2 = _Menu..'DebugTab2' --属性栏
local _DebugTab3 = _Menu..'DebugTab3' --诅咒栏
local _DebugTab4 = _Menu..'DebugTab4' --传送栏
local _DebugTabG = _Menu..'DebugTabG' --杂项栏

ImGui.AddElement(_Menu, _Debug, ImGuiElement.MenuItem, '\u{f492}'..Language('测试', 'Debug') )
ImGui.CreateWindow(_DebugWindow, '\u{f492}'..Language('测试', 'Debug') )
ImGui.LinkWindowToElement(_DebugWindow, _Debug)

--玩家号数点选
local playerIdx = 0
ImGui.AddElement(_DebugWindow, '', ImGuiElement.SeparatorText, Language('玩家号数', 'Player Index') )
ImGui.AddRadioButtons(_DebugWindow, _DebugWindow..'_PlayerIdx', function(i)
	playerIdx = i
end, {'1', '2', '3', '4', '5', '6', '7', '8', '9', '10'})

--数值调整模式点选
local modifier = '+'
ImGui.AddElement(_DebugWindow, '', ImGuiElement.SeparatorText, Language('数值调整模式', 'Modifier') )
ImGui.AddRadioButtons(_DebugWindow, _DebugWindow..'_Modifier', function(i)
	if i == 0 then
		modifier = '+'
	elseif i == 1 then
		modifier = '-'
	else
		modifier = '='
	end
end, { Language('增', 'Plus'), Language('减', 'Subtract'), Language('改', 'Change') } )
ImGui.SetHelpmarker(_DebugWindow..'_Modifier', Language('请注意, 游戏将黑心视为魂心', 'Attention please, Black Hearts count toward to Soul Hearts'))

ImGui.AddTabBar(_DebugWindow, _DebugTabBar)
ImGui.AddTab(_DebugTabBar, _DebugTab1, Language('资源', 'Resources') )
ImGui.AddTab(_DebugTabBar, _DebugTab2, Language('属性', 'Stats') )
ImGui.AddTab(_DebugTabBar, _DebugTab3, Language('诅咒', 'Curses') )
ImGui.AddTab(_DebugTabBar, _DebugTab4, Language('传送', 'Teleport') )
ImGui.AddTab(_DebugTabBar, _DebugTabG, Language('杂项', 'Groceries') )


----↓资源栏相关↓----
do
	local INT = 0

	--输入框
	local _DebugTab1_Input = _DebugTab1..'_Input'
	ImGui.AddInputText(_DebugTab1, _DebugTab1_Input, '', nil, '', Language('仅非负整数有效', 'Non-negative Integer Only') )
	ImGui.AddCallback(_DebugTab1_Input, ImGuiCallback.DeactivatedAfterEdit, function(str)
		str = string.gsub(str, '%D', '') --将非数字替换为空

		if str == '' then
			INT = 0
		else
			INT = tonumber(str)
		end

		ImGui.UpdateData(_DebugTab1_Input, ImGuiData.Value, str)
	end)

	--金饰品按钮
	ImGui.AddButton(_DebugTab1, _DebugTab1..'_GoldenTrinket', Language('金饰品', 'Golden Trinket'), function()	
		if not IsInRun() then
			return
		end

		local room = game:GetRoom()
		Isaac.Spawn(5, 350, INT+32768, room:FindFreePickupSpawnPosition(room:GetCenterPos(), 0, true), Vector.Zero, nil)
	end)

	ImGui.AddElement(_DebugTab1, '', ImGuiElement.SameLine)

	--次要主动按钮
	ImGui.AddButton(_DebugTab1, _DebugTab1..'PocketActive', Language('次要主动道具', 'Pocket Active Item'), function()	
		if not IsInRun() then
			return
		end

		local player = Isaac.GetPlayer(playerIdx)
		player:SetPocketActiveItem(INT, ActiveSlot.SLOT_POCKET, true)
	end)

	--硬币按钮
	ImGui.AddButton(_DebugTab1, _DebugTab1..'_Coin', Language('硬币', 'Coin'), function()
		if not IsInRun() then
			return
		end
		
		local player = Isaac.GetPlayer(playerIdx)

		if modifier == '+' then
			player:AddCoins(INT)
		elseif modifier == '-' then
			player:AddCoins(-INT)
		else
			player:AddCoins(-player:GetNumCoins())
			player:AddCoins(INT)
		end	
	end)

	ImGui.AddElement(_DebugTab1, '', ImGuiElement.SameLine)

	--炸弹按钮
	ImGui.AddButton(_DebugTab1, _DebugTab1..'_Bomb', Language('炸弹', 'Bomb'), function()
		if not IsInRun() then
			return
		end
		
		local player = Isaac.GetPlayer(playerIdx)

		if modifier == '+' then
			player:AddBombs(INT)
		elseif modifier == '-' then
			player:AddBombs(-INT)
		else
			player:AddBombs(-player:GetNumBombs())
			player:AddBombs(INT)
		end	
	end)

	ImGui.AddElement(_DebugTab1, '', ImGuiElement.SameLine)

	--钥匙按钮
	ImGui.AddButton(_DebugTab1, _DebugTab1..'_Key', Language('钥匙', 'Key'), function()
		if not IsInRun() then
			return
		end
		
		local player = Isaac.GetPlayer(playerIdx)

		if modifier == '+' then
			player:AddKeys(INT)
		elseif modifier == '-' then
			player:AddKeys(-INT)
		else
			player:AddKeys(-player:GetNumKeys())
			player:AddKeys(INT)
		end	
	end)

	--心容按钮
	ImGui.AddButton(_DebugTab1, _DebugTab1..'_HealthContainer', Language('心之容器', 'Health Container'), function()
		if not IsInRun() then
			return
		end
		
		local player = Isaac.GetPlayer(playerIdx)

		if modifier == '+' then
			player:AddMaxHearts(INT*2)
		elseif modifier == '-' then
			player:AddMaxHearts(-INT*2)
		else
			player:AddMaxHearts(-player:GetMaxHearts())
			player:AddMaxHearts(INT*2)
		end	
	end)

	ImGui.AddElement(_DebugTab1, '', ImGuiElement.SameLine)

	--红心按钮
	ImGui.AddButton(_DebugTab1, _DebugTab1..'_Heart', Language('红心', 'Red Heart'), function()
		if not IsInRun() then
			return
		end
		
		local player = Isaac.GetPlayer(playerIdx)

		if modifier == '+' then
			player:AddHearts(INT)
		elseif modifier == '-' then
			player:AddHearts(-INT)
		else
			if player:GetPlayerType() == PlayerType.PLAYER_BETHANY_B then
				player:SetBloodCharge(0)
			else
				player:AddHearts(-player:GetHearts())
			end	
			player:AddHearts(INT)
		end	
	end)

	ImGui.AddElement(_DebugTab1, '', ImGuiElement.SameLine)

	--魂心按钮
	ImGui.AddButton(_DebugTab1, _DebugTab1..'_SoulHeart', Language('魂心', 'Soul Heart'), function()
		if not IsInRun() then
			return
		end
		
		local player = Isaac.GetPlayer(playerIdx)

		if modifier == '+' then
			player:AddSoulHearts(INT)
		elseif modifier == '-' then
			player:AddSoulHearts(-INT)
		else
			if player:GetPlayerType() == PlayerType.PLAYER_BETHANY then
				player:SetSoulCharge(0)
			else
				player:AddSoulHearts(-player:GetSoulHearts())
			end
			player:AddSoulHearts(INT)
		end	
	end)

	ImGui.AddElement(_DebugTab1, '', ImGuiElement.SameLine)

	--黑心按钮
	ImGui.AddButton(_DebugTab1, _DebugTab1..'_BlackHeart', Language('黑心', 'Black Heart'), function()
		if not IsInRun() then
			return
		end
		
		local player = Isaac.GetPlayer(playerIdx)

		if modifier == '+' then
			player:AddBlackHearts(INT)
		elseif modifier == '-' then
			player:AddBlackHearts(-INT)
		else
			if player:GetPlayerType() == PlayerType.PLAYER_BETHANY then
				player:SetSoulCharge(0)
			else
				player:AddBlackHearts(-9999)
			end	
			player:AddBlackHearts(INT)
		end	
	end)

	ImGui.AddElement(_DebugTab1, '', ImGuiElement.SameLine)

	--白心按钮
	ImGui.AddButton(_DebugTab1, _DebugTab1..'_EternalHeart', Language('永恒之心', 'Eternal Heart'), function()
		if not IsInRun() then
			return
		end
		
		local player = Isaac.GetPlayer(playerIdx)

		if modifier == '+' then
			player:AddEternalHearts(INT)
		elseif modifier == '-' then
			player:AddEternalHearts(-INT)
		else
			player:AddEternalHearts(-player:GetEternalHearts())
			player:AddEternalHearts(INT)
		end	
	end)

	--金心按钮
	ImGui.AddButton(_DebugTab1, _DebugTab1..'_GoldenHeart', Language('金心', 'Golden Heart'), function()
		if not IsInRun() then
			return
		end
		
		local player = Isaac.GetPlayer(playerIdx)

		if modifier == '+' then
			player:AddGoldenHearts(INT)
		elseif modifier == '-' then
			player:AddGoldenHearts(-INT)
		else
			player:AddGoldenHearts(-player:GetGoldenHearts())
			player:AddGoldenHearts(INT)
		end	
	end)

	ImGui.AddElement(_DebugTab1, '', ImGuiElement.SameLine)

	--骨心按钮
	ImGui.AddButton(_DebugTab1, _DebugTab1..'_BoneHeart', Language('骨心', 'Bone Heart'), function()
		if not IsInRun() then
			return
		end
		
		local player = Isaac.GetPlayer(playerIdx)

		if modifier == '+' then
			player:AddBoneHearts(INT)
		elseif modifier == '-' then
			player:AddBoneHearts(-INT)
		else
			player:AddBoneHearts(-player:GetBoneHearts())
			player:AddBoneHearts(INT)
		end	
	end)

	ImGui.AddElement(_DebugTab1, '', ImGuiElement.SameLine)

	--腐心按钮
	ImGui.AddButton(_DebugTab1, _DebugTab1..'_RottenHeart', Language('腐心', 'Rotton Heart'), function()
		if not IsInRun() then
			return
		end
		
		local player = Isaac.GetPlayer(playerIdx)

		if modifier == '+' then
			player:AddRottenHearts(INT)
		elseif modifier == '-' then
			player:AddRottenHearts(-INT)
		else
			player:AddRottenHearts(-player:GetRottenHearts())
			player:AddRottenHearts(INT)
		end	
	end)

	ImGui.AddElement(_DebugTab1, '', ImGuiElement.SameLine)

	--碎心按钮
	ImGui.AddButton(_DebugTab1, _DebugTab1..'_BrokenHeart', Language('碎心', 'Broken Heart'), function()
		if not IsInRun() then
			return
		end
		
		local player = Isaac.GetPlayer(playerIdx)

		if modifier == '+' then
			player:AddBrokenHearts(INT)
		elseif modifier == '-' then
			player:AddBrokenHearts(-INT)
		else
			player:AddBrokenHearts(-player:GetBrokenHearts())
			player:AddBrokenHearts(INT)
		end	
	end)

end
----↑资源栏相关↑----


----↓属性栏相关↓----
do
	local cachedStats = {}
	local function GetCache(player)
		local ptr = GetPtrHash(player)
	
		if not cachedStats[ptr] then
			cachedStats[ptr] = {
				spd = 0,
				tears = 0,
				dmg = 0,
				range = 0,
				sspd = 0,
				luck = 0
			}
		end
		
		return cachedStats[ptr]
	end

	--进退游戏重置
	local function Reset()
		for k,v in pairs(cachedStats) do
			cachedStats[k] = nil
		end
		for i = 0, game:GetNumPlayers() -1 do
			local player = Isaac.GetPlayer(i)
			player:AddCacheFlags(CacheFlag.CACHE_ALL, true)
		end
	end
	mod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, Reset)
	mod:AddCallback(ModCallbacks.MC_PRE_GAME_EXIT, Reset)
	mod:AddCallback(ModCallbacks.MC_POST_GAME_END, Reset)

	--属性变动
	mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, function(_,player, flag)
		local cache = GetCache(player)
	
		if flag == CacheFlag.CACHE_SPEED then
			Stats:Speed(player, cache.spd, true)
		end
		if flag == CacheFlag.CACHE_FIREDELAY then
			Stats:TearsModifier(player, cache.tears, true)
		end
		if flag == CacheFlag.CACHE_DAMAGE then
			Stats:Damage(player, cache.dmg, true)
		end
		if flag == CacheFlag.CACHE_RANGE then
			Stats:Range(player, cache.range, true)
		end
		if flag == CacheFlag.CACHE_SHOTSPEED then
			Stats:ShotSpeed(player, cache.sspd, true)
		end	
		if flag == CacheFlag.CACHE_LUCK then
			Stats:Luck(player, cache.luck, true)
		end
	end)

	local NUM = 0

	--输入框
	local _DebugTab2_Input = _DebugTab2..'_Input'
	ImGui.AddInputText(_DebugTab2, _DebugTab2_Input, '', nil, '', Language('仅数字有效', 'Number Only') )
	ImGui.AddCallback(_DebugTab2_Input, ImGuiCallback.DeactivatedAfterEdit, function(str)
		local num = tonumber(str)

		if num ~= nil then
			NUM = num
		else
			NUM = 0
			str = ''
		end

		ImGui.UpdateData(_DebugTab2_Input, ImGuiData.Value, str)
	end)
	
	--移速按钮
	ImGui.AddButton(_DebugTab2, _DebugTab2..'_Speed', Language('移速加成', 'Speed Up'), function()
		if not IsInRun() then
			return
		end

		local player = Isaac.GetPlayer(playerIdx)
		local cache = GetCache(player)

		if modifier == '+' then
			cache.spd = cache.spd + NUM
		elseif modifier == '-' then
			cache.spd = cache.spd - NUM
		else
			cache.spd = NUM
		end
		
		player:AddCacheFlags(CacheFlag.CACHE_SPEED, true)
	end)
	
	ImGui.AddElement(_DebugTab2, '', ImGuiElement.SameLine)
	
	--射速按钮
	ImGui.AddButton(_DebugTab2, _DebugTab2..'_Tears', Language('射速加成', 'Tears Up'), function()
		if not IsInRun() then
			return
		end

		local player = Isaac.GetPlayer(playerIdx)
		local cache = GetCache(player)

		if modifier == '+' then
			cache.tears = cache.tears + NUM
		elseif modifier == '-' then
			cache.tears = cache.tears - NUM
		else
			cache.tears = NUM
		end

		player:AddCacheFlags(CacheFlag.CACHE_FIREDELAY, true)
	end)
		
	ImGui.AddElement(_DebugTab2, '', ImGuiElement.SameLine)
	
	--伤害按钮
	ImGui.AddButton(_DebugTab2, _DebugTab2..'_Damage', Language('伤害加成', 'Damage Up'), function()
		if not IsInRun() then
			return
		end

		local player = Isaac.GetPlayer(playerIdx)
		local cache = GetCache(player)

		if modifier == '+' then
			cache.dmg = cache.dmg + NUM
		elseif modifier == '-' then
			cache.dmg = cache.dmg - NUM
		else
			cache.dmg = NUM
		end

		player:AddCacheFlags(CacheFlag.CACHE_DAMAGE, true)
	end)
		
	ImGui.AddElement(_DebugTab2, '', ImGuiElement.SameLine)
	
	--射程按钮
	ImGui.AddButton(_DebugTab2, _DebugTab2..'_Range', Language('射程加成', 'Range Up'), function()
		if not IsInRun() then
			return
		end

		local player = Isaac.GetPlayer(playerIdx)
		local cache = GetCache(player)

		if modifier == '+' then
			cache.range = cache.range + NUM
		elseif modifier == '-' then
			cache.range = cache.range - NUM
		else
			cache.range = NUM
		end

		player:AddCacheFlags(CacheFlag.CACHE_RANGE, true)
	end)
		
	ImGui.AddElement(_DebugTab2, '', ImGuiElement.SameLine)

	--弹速按钮
	ImGui.AddButton(_DebugTab2, _DebugTab2..'_ShotSpeed', Language('弹速加成', 'Shot Speed Up'), function()
		if not IsInRun() then
			return
		end

		local player = Isaac.GetPlayer(playerIdx)
		local cache = GetCache(player)

		if modifier == '+' then
			cache.sspd = cache.sspd + NUM
		elseif modifier == '-' then
			cache.sspd = cache.sspd - NUM
		else
			cache.sspd = NUM
		end

		player:AddCacheFlags(CacheFlag.CACHE_SHOTSPEED, true)
	end)

	ImGui.AddElement(_DebugTab2, '', ImGuiElement.SameLine)

	--幸运按钮
	ImGui.AddButton(_DebugTab2, _DebugTab2..'_Luck', Language('幸运加成', 'Luck Up'), function()
		if not IsInRun() then
			return
		end

		local player = Isaac.GetPlayer(playerIdx)
		local cache = GetCache(player)

		if modifier == '+' then
			cache.luck = cache.luck + NUM
		elseif modifier == '-' then
			cache.luck = cache.luck - NUM
		else
			cache.luck = NUM
		end

		player:AddCacheFlags(CacheFlag.CACHE_LUCK, true)
	end)

end
----↑属性栏相关↑----


----↓诅咒栏相关↓----
do
	--缓存诅咒,用于启用迷宫诅咒或大房间诅咒
	local cachedCurses = nil
	mod:AddPriorityCallback(ModCallbacks.MC_POST_CURSE_EVAL, CallbackPriority.IMPORTANT, function(curses)
		if cachedCurses ~= nil then
			curses = cachedCurses
			cachedCurses = nil
			return curses
		end
	end)

	--诅咒列表
	local Curses = {
		--原版
		{ curse = LevelCurse.CURSE_OF_DARKNESS, name = Language('黑暗诅咒', 'Dark') },
		{ curse = LevelCurse.CURSE_OF_LABYRINTH, reloadStage = true, help = Language('重置楼层; 在虚空会崩溃', 'Reloads stage; Crashes in The Void'), name = Language('迷宫诅咒', 'Labyrinth') },
		{ curse = LevelCurse.CURSE_OF_THE_LOST, name = Language('迷途诅咒', 'Lost') },
		{ curse = LevelCurse.CURSE_OF_THE_UNKNOWN, name = Language('未知诅咒', 'Unknown') },
		{ curse = LevelCurse.CURSE_OF_THE_CURSED, help = Language('进入新房间以刷新效果', 'Refreshes when entering a new room'), name = Language('诅咒诅咒', 'Cursed') },
		{ curse = LevelCurse.CURSE_OF_MAZE, name = Language('混乱诅咒', 'Maze') },
		{ curse = LevelCurse.CURSE_OF_BLIND, name = Language('致盲诅咒', 'Blind') },
		{ curse = LevelCurse.CURSE_OF_GIANT, reloadStage = true, help = Language('重置楼层; 很可能崩溃', 'Reloads stage; Crashes mostly'), name = Language('大房间诅咒', 'Giant') },
		
		--愚昧
		{ curse = IBS_Curse.Moving.Bitmask, help = Language('不动会死', 'Move or die'), name = Language('动人诅咒', 'Moving') },
		{ curse = IBS_Curse.D7.Bitmask, help = Language('清理房间后25%概率重置房间', '25% chance to reroll the current room cleared'), name = Language('七面骰诅咒', 'D7') },
	}

	for k,v in ipairs(Curses) do
		if k == 1 then
			ImGui.AddElement(_DebugTab3, '', ImGuiElement.SeparatorText, Language('原版', 'Vanilla') )
		elseif k == 9 then
			ImGui.AddElement(_DebugTab3, '', ImGuiElement.SeparatorText, mod.NameStr )
		end
	
		local curse = v.curse
		local box = _DebugTab3..'_Curse'..tostring(curse)
		ImGui.AddCheckbox(_DebugTab3, box, v.name)
		ImGui.AddCallback(box, ImGuiCallback.Render, function()
			ImGui.UpdateData(box, ImGuiData.Value, game:GetLevel():GetCurses() & curse > 0)
		end)
		
		if v.reloadStage then
			ImGui.AddCallback(box, ImGuiCallback.Edited, function(bool)
				if not IsInRun() then
					return
				end

				local level = game:GetLevel()
				if bool then
					cachedCurses = level:GetCurses() | curse
					Levels:Reload()
				else
					cachedCurses = level:GetCurses() &~ curse
					Levels:Reload()
				end
			end)
		else
			ImGui.AddCallback(box, ImGuiCallback.Edited, function(bool)
				if not IsInRun() then
					return
				end

				local level = game:GetLevel()
				if bool then
					level:AddCurse(curse, false)
				else
					level:RemoveCurses(curse)
				end

				--显示愚昧的诅咒
				if k >= 9 then
					IBS_Curse._Emphasize()
				end
			end)
		end

		if v.help then
			ImGui.SetHelpmarker(box, v.help)
		end
	end

end
----↑诅咒栏相关↑----


----↓传送栏相关↓----
do
	--初始房间传送按钮
	ImGui.AddButton(_DebugTab4, _DebugTab4..'_Fool', Language('初始房间', 'Starting Room'), function()	
		if not IsInRun() then
			return
		end
		game:StartRoomTransition(game:GetLevel():GetStartingRoomIndex(), Direction.NO_DIRECTION, RoomTransitionAnim.TELEPORT, Isaac.GetPlayer(playerIdx))
	end)

	--可传送房间列表
	local Rooms = {
		{Type = RoomType.ROOM_BOSS, Name = 'Boss' },
		{Type = RoomType.ROOM_SHOP, Name = Language('商店', 'Shop') },
		{Type = RoomType.ROOM_TREASURE, Name = Language('宝箱房', 'Treasure') },
		{Type = RoomType.ROOM_SECRET, Name = Language('隐藏', 'Secret') },
		{Type = RoomType.ROOM_SUPERSECRET, Name = Language('超隐', 'Super Secret') },
		{Type = RoomType.ROOM_ULTRASECRET, Name = Language('红隐', 'Ultra Secret') },
		{Type = RoomType.ROOM_CURSE, Name = Language('诅咒', 'Curse') },

		{Type = RoomType.ROOM_DEVIL, Name = Language('恶魔/天使', 'Devil / Angel') },
		{Type = RoomType.ROOM_SACRIFICE, Name = Language('献祭', 'Sacrifice') },
		{Type = RoomType.ROOM_LIBRARY, Name = Language('图书馆', 'Library') },
		{Type = RoomType.ROOM_ARCADE, Name = Language('赌博房', 'Arcade') },
		{Type = RoomType.ROOM_CHALLENGE, Name = Language('挑战房', 'Challenge') },
		{Type = RoomType.ROOM_CHEST, Name = Language('藏宝阁', 'Chest') },
		{Type = RoomType.ROOM_DICE, Name = Language('骰子房', 'Dice') },

		{Idx = GridRooms.ROOM_ERROR_IDX, Name = Language('错误房', 'Error')},
		{Idx = GridRooms.ROOM_DUNGEON_IDX, Name = Language('夹层', 'Dungeon')},
		{Idx = GridRooms.ROOM_BLACK_MARKET_IDX, Name = Language('黑市', 'Black Market')},
		{Idx = GridRooms.ROOM_SECRET_SHOP_IDX, Name = Language('高级商店', 'Secret Shop')},
		{Idx = GridRooms.ROOM_ANGEL_SHOP_IDX, Name = Language('天使商店', 'Angel Shop')},
	}

	for k,v in ipairs(Rooms) do
		if k ~= 8 and k ~= 15 then
			ImGui.AddElement(_DebugTab4, '', ImGuiElement.SameLine)
		end
		
		if v.Type then
			ImGui.AddButton(_DebugTab4, _DebugTab4..'_'..k, v.Name, function()
				if not IsInRun() then
					return
				end

				local idx = game:GetLevel():QueryRoomTypeIndex(v.Type, false, RNG(Random()), true)
				game:StartRoomTransition(idx, Direction.NO_DIRECTION, RoomTransitionAnim.TELEPORT, Isaac.GetPlayer(playerIdx))
			end)
		elseif v.Idx then
			ImGui.AddButton(_DebugTab4, _DebugTab4..'_'..k, v.Name, function()
				if not IsInRun() then
					return
				end
				game:StartRoomTransition(v.Idx, Direction.NO_DIRECTION, RoomTransitionAnim.TELEPORT, Isaac.GetPlayer(playerIdx))
			end)		
		end
	end

end
----↑传送栏相关↑----


----↓杂项栏相关↓----
do
	local INT = 0

	--输入框
	local _DebugTabG_Input = _DebugTabG..'_Input'
	ImGui.AddInputText(_DebugTabG, _DebugTabG_Input, '', nil, '', Language('仅非负整数有效', 'Non-negative Integer Only') )
	ImGui.AddCallback(_DebugTabG_Input, ImGuiCallback.DeactivatedAfterEdit, function(str)
		str = string.gsub(str, '%D', '') --将非数字替换为空

		if str == '' then
			INT = 0
		else
			INT = tonumber(str)
		end

		ImGui.UpdateData(_DebugTabG_Input, ImGuiData.Value, str)
	end)

	--对角色造成伤害按钮
	ImGui.AddButton(_DebugTabG, _DebugTabG..'DamageIsaac', Language('对角色造成伤害', 'Damage Isaac'), function()	
		if not IsInRun() then
			return
		end
		Isaac.GetPlayer(playerIdx):TakeDamage(INT, 0, EntityRef(nil), 0)
	end)

	ImGui.AddElement(_DebugTabG, '', ImGuiElement.SameLine)

	--更换角色按钮
	ImGui.AddButton(_DebugTabG, _DebugTabG..'ChangeCharacter', Language('更换角色', 'Change Character'), function()	
		if not IsInRun() then
			return
		end
		Isaac.GetPlayer(playerIdx):ChangePlayerType(INT)
	end)
	
	ImGui.AddElement(_DebugTabG, '', ImGuiElement.SeparatorText)

	--揭示全图按钮
	ImGui.AddButton(_DebugTabG, _DebugTabG..'MapReveal', Language('揭示全图', 'Map Reveal'), function()	
		if not IsInRun() then
			return
		end	

		local level = game:GetLevel()

		for i = 0,168 do
			local roomDesc = level:GetRoomByIdx(i)
			if roomDesc then
				roomDesc.DisplayFlags = roomDesc.DisplayFlags | (1<<0) | (1<<1) | (1<<2)
			end
		end

		level:UpdateVisibility()
	end)

	ImGui.AddElement(_DebugTabG, '', ImGuiElement.SameLine)

	--使用该隐魂石按钮
	ImGui.AddButton(_DebugTabG, _DebugTabG..'CainSoul', Language('使用该隐魂石', 'Soul of Cain'), function()	
		if not IsInRun() then
			return
		end
		Isaac.GetPlayer(playerIdx):UseCard(83, UseFlag.USE_NOANIM | UseFlag.USE_NOANNOUNCER | UseFlag.USE_MIMIC)
	end)

	ImGui.AddElement(_DebugTabG, '', ImGuiElement.SameLine)

	--使用发光沙漏按钮
	ImGui.AddButton(_DebugTabG, _DebugTabG..'C422', Language('使用发光沙漏', 'Glowing Hourglass'), function()	
		if not IsInRun() then
			return
		end
		Isaac.GetPlayer(playerIdx):UseActiveItem(422, false, false)
	end)

	ImGui.AddElement(_DebugTabG, '', ImGuiElement.SameLine)
	
	--显示/隐藏HUD按钮
	ImGui.AddButton(_DebugTabG, _DebugTabG..'HUD', Language('显示/隐藏 HUD', 'Show / Hide HUD'), function()	
		if not IsInRun() then
			return
		end	
	
		local hud = game:GetHUD()
		if hud:IsVisible() then
			hud:SetVisible(false)
		else
			hud:SetVisible(true)
		end
	end)

	ImGui.AddElement(_DebugTabG, '', ImGuiElement.SeparatorText)
	ImGui.AddElement(_DebugTabG, '', ImGuiElement.SeparatorText)
	ImGui.AddElement(_DebugTabG, '', ImGuiElement.SeparatorText)
	ImGui.AddElement(_DebugTabG, '', ImGuiElement.SeparatorText)
	ImGui.AddElement(_DebugTabG, '', ImGuiElement.SeparatorText)
	ImGui.AddElement(_DebugTabG, '', ImGuiElement.SeparatorText)
	ImGui.AddElement(_DebugTabG, '', ImGuiElement.SeparatorText, mod.NameStr)

	--非成就索引
	local NonAchiev = {
		isaacSatanDeath = true, --用于表表以撒解锁
		maggySloth = true, --用于表表抹解锁
		maggyLust = true, --用于表表抹解锁
		maggyWrath = true, --用于表表抹解锁
		maggyGluttony = true, --用于表表抹解锁
		maggyGreed = true, --用于表表抹解锁
		maggyEnvy = true, --用于表表抹解锁
		maggyPride = true, --用于表表抹解锁
		maggyPride = true, --用于表表抹解锁
		lostDeath = 0, --用于表表游魂解锁
		
		troposphere = 515, --用于对流层
		
		--设置部分
		difficulty_enemy_hp_up = false, --敌人血量增长
		difficulty_enemy_level_mult = 0.2, --敌人血量每层增长
		difficulty_boss_level_mult = 0.1, --boss敌人血量每层增长		
		curse_moving = true, --动人诅咒
		curse_d7 = true, --D7诅咒
		slot_collectionBox = true, --募捐箱
		slot_albern = true, --真理小子
		slot_facer = true, --换脸商
		slot_envoy = true, --使者	
		boss_deligence_diligence = true, --勤劳
		boss_fortitude = true, --坚韧
		boss_temperance = true, --节制
		boss_generosity = true, --慷慨
		boss_humility = true, --谦逊		
		voidUp = true, --虚空增强
		abyssUp = true, --无底坑增强
		envyDisguise = true, --女疾女户伪装
		envyJS = true, --女疾女户跳脸
		--otto = false, --女疾女户OTTO硅胶(故意保留了这一部分)
		envyRemove = true, --从池中移除女疾女户
		tipI = true, --角色菜单提示
		rewindCompat = true, --发光沙漏兼容
	}
	
	--一键全成就按钮
	ImGui.AddButton(_DebugTabG, _DebugTabG..'UnlockAll', Language('一键全成就', 'UNLOCK All'), function()	
		if not IsSaveslotLoaded() then
			return
		end	

		local data = mod:GetIBSData('persis')

		for KEY,v in pairs(data) do
			
			--角色成就
			if IBS_PlayerKey[KEY] ~= nil then
				for k,_ in pairs(v) do
					v[k] = true
				end
			elseif NonAchiev[KEY] == nil and type(data[KEY]) == 'boolean' then
				data[KEY] = true
			end
		end
		
		mod:SaveIBSData()
	end)
	
	ImGui.AddElement(_DebugTabG, '', ImGuiElement.SameLine)
	
	--清空成就按钮
	ImGui.AddButton(_DebugTabG, _DebugTabG..'LockAll', Language('一键清空成就', 'LOCK All'), function()	
		if not IsSaveslotLoaded() then
			return
		end	

		local data = mod:GetIBSData('persis')

		for KEY,v in pairs(data) do
			--角色成就
			if IBS_PlayerKey[KEY] ~= nil then
				for k,_ in pairs(v) do
					v[k] = false
				end
			elseif NonAchiev[KEY] == nil and type(data[KEY]) == 'boolean' then
				data[KEY] = false
			end
		end

		mod:SaveIBSData()
	end)
end
----↑杂项栏相关↑----
end
--------↑测试板块↑--------







