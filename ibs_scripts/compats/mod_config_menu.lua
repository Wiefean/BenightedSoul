--模组配置菜单

local mod = Isaac_BenightedSoul
local ModName = mod.Name
local ModVersion = mod.ModVersion

local mcm = ModConfigMenu

local BasicSettings = "Basic" --基础板块
local AchievSettings1 = "Achiev1" --成就板块1
local AchievSettings2 = "Achiev2" --成就板块2

mcm.SetCategoryInfo(ModName, "Still Testing (v"..ModVersion..")") --设置模组名称和基本信息

--添加是否型
local function AddBool(
column, --板块名称
KEY, --存读系统的索引
INFO,--说明(一个元素为字符串的表或字符串)
display, --选项显示
onDis, --选项为"是"时的显示
offDis --选项为"否"时的显示
)
	local onDisplay = (onDis and ":"..onDis) or ":On"
	local offDisplay = (offDis and ":"..offDis) or ":Off"
	
	local setting = mcm.AddBooleanSetting(
		ModName, --模组名称
		column, --板块名称
		KEY, --该设置表的索引,为方便与存读系统的索引统一
		IBS_Data.Setting[KEY], --默认值,为方便与存读系统统一
		"", --该设置字符显示1(无用)
		{[true]="On",[false]="Off"}, --该设置字符显示2(无用)
		INFO --说明
	)
	setting.Display = function() --真正的显示
		local dis = display
		if IBS_Data.Setting[KEY] then
			dis = dis..onDisplay
		else
			dis = dis..offDisplay
		end
		return dis
	end
	setting.OnChange = function(value) --更改设置
		IBS_Data.Setting[KEY] = not IBS_Data.Setting[KEY]
		mod:SaveIBSData()
	end
end

--添加角色的是否型
local function AddCharacterBool(
column,
PlayerKey, --角色索引
KEY,
INFO,
display,
onDis,
offDis
)
	local onDisplay = (onDis and ":"..onDis) or ":Yep"
	local offDisplay = (offDis and ":"..offDis) or ":Nope"
	
	local setting = mcm.AddBooleanSetting(
		ModName, 
		column, 
		PlayerKey..KEY, --角色索引加数据索引等于设置索引(天才
		IBS_Data.Setting[PlayerKey][KEY], --默认值
		"",
		{[true]="Change",[false]="Change"},
		INFO or "No achievement yet"
	)
	setting.Display = function()
		local dis = display or KEY
		if IBS_Data.Setting[PlayerKey][KEY] then
			dis = dis..onDisplay
		else
			dis = dis..offDisplay
		end
		return dis
	end		
	setting.OnChange = function(value) 
		IBS_Data.Setting[PlayerKey][KEY] = not IBS_Data.Setting[PlayerKey][KEY]
		mod:SaveIBSData()
	end
end



--基础板块开始--
do	--未来
	mcm.AddTitle(ModName, BasicSettings, "Future")
	AddBool(BasicSettings, "voidUp", "Available to trinkets", "Void Up")
	AddBool(BasicSettings, "abyssUp", "Available to trinkets", "Abyss Up")
end

mcm.AddSpace(ModName, BasicSettings) --添加空行

do	--诅咒
	mcm.AddTitle(ModName, BasicSettings, "Curses")
	AddBool(BasicSettings, "curse_moving", "Move or die", "The Moving")
	AddBool(BasicSettings, "curse_forgotten", "You may lose something when entering the same room again", "The Forgotten")
	AddBool(BasicSettings, "curse_d7", "You may clear the same room", "D7")
	AddBool(BasicSettings, "curse_binding", "The binding of Isaac", "The Binding")
end

mcm.AddSpace(ModName, BasicSettings)

do	--测试
	mcm.AddTitle(ModName, BasicSettings, "Debug")
	AddBool(BasicSettings, "moreCommands", {"For debug console","(See the text file for more)"}, "More Commands")
end
--基础板块结束--



--成就板块1开始--
do	--物品
	mcm.AddTitle(ModName, AchievSettings1, "Items")
	AddBool(AchievSettings1, "d4dUnlocked", "Use D4 4 times in a level to unlock", "D4D", "Yep", "Nope")
	AddBool(AchievSettings1, "dreggypieUnlocked", "You know how to do it, right?", "Dreggy Pie", "Yep", "Nope")
end

mcm.AddSpace(ModName, AchievSettings1)

do	--挑战
	mcm.AddTitle(ModName, AchievSettings1, "Challenges")
	AddBool(AchievSettings1, "bc1", "Finish it for Isaac up", "Rolling Destiny", "Yep", "Nope")
	AddBool(AchievSettings1, "bc2", "Finish it for Magdalene up", "The Fragile", "Yep", "Nope")
	AddBool(AchievSettings1, "bc4", "Finish it for Judas and The Gospel Of Judas up", "Passover", "Yep", "Nope")
end
--成就板块1结束--



--成就板块2开始--
do	--昧化以撒
	local PlayerKey = "bisaac" --角色索引
	local IBSL_INFO = "One of four marks for Bottle Shard" --以撒蓝人撒旦羔羊标记说明
	local BRH_INFO = "One of two marks for a challenge" --BR和死寂标记说明
	
	mcm.AddTitle(ModName, AchievSettings2, "Benighted Isaac")
	AddCharacterBool(AchievSettings2, PlayerKey, "Unlocked", "Is this character unlocked")
	AddCharacterBool(AchievSettings2, PlayerKey, "Heart", "Mark that does not has its own achievement")
	AddCharacterBool(AchievSettings2, PlayerKey, "Isaac", IBSL_INFO)
	AddCharacterBool(AchievSettings2, PlayerKey, "BlueBaby", IBSL_INFO)
	AddCharacterBool(AchievSettings2, PlayerKey, "Satan", IBSL_INFO)
	AddCharacterBool(AchievSettings2, PlayerKey, "Lamb", IBSL_INFO)
	AddCharacterBool(AchievSettings2, PlayerKey, "MegaSatan", "Mark for Cu Zn D6")
	AddCharacterBool(AchievSettings2, PlayerKey, "BossRush", BRH_INFO)
	AddCharacterBool(AchievSettings2, PlayerKey, "Hush", BRH_INFO)
	AddCharacterBool(AchievSettings2, PlayerKey, "Delirium", "Mark for The Light D6")
	AddCharacterBool(AchievSettings2, PlayerKey, "Witness", "Mark for Dad's Promise")
	AddCharacterBool(AchievSettings2, PlayerKey, "Beast", "Mark for No Options")
	AddCharacterBool(AchievSettings2, PlayerKey, "Greed", "Mark for Shooting Stars Gazer")	
	AddCharacterBool(AchievSettings2, PlayerKey, "FINISHED", {"For a mini boss","This only affects its single achievement"})
end	

mcm.AddSpace(ModName, AchievSettings2) --添加空行

do	--昧化抹大拉
	local PlayerKey = "bmaggy"
	local IBSL_INFO = "One of four marks for Divine Retaliation"
	local BRH_INFO = "One of two marks for a challenge"
	
	mcm.AddTitle(ModName, AchievSettings2, "Benighted Magdalene")
	AddCharacterBool(AchievSettings2, PlayerKey, "Unlocked", "Is this character unlocked")
	AddCharacterBool(AchievSettings2, PlayerKey, "Heart", "Mark that does not has its own achievement")
	AddCharacterBool(AchievSettings2, PlayerKey, "Isaac", IBSL_INFO)
	AddCharacterBool(AchievSettings2, PlayerKey, "BlueBaby", IBSL_INFO)
	AddCharacterBool(AchievSettings2, PlayerKey, "Satan", IBSL_INFO)
	AddCharacterBool(AchievSettings2, PlayerKey, "Lamb", IBSL_INFO)
	AddCharacterBool(AchievSettings2, PlayerKey, "MegaSatan", "Mark for Golden Prayer")
	AddCharacterBool(AchievSettings2, PlayerKey, "BossRush", BRH_INFO)
	AddCharacterBool(AchievSettings2, PlayerKey, "Hush", BRH_INFO)
	AddCharacterBool(AchievSettings2, PlayerKey, "Delirium", "Mark for Glowing Heart")
	AddCharacterBool(AchievSettings2, PlayerKey, "Witness", "Mark for Tough Heart")
	AddCharacterBool(AchievSettings2, PlayerKey, "Beast", "Mark for Diamoond")
	AddCharacterBool(AchievSettings2, PlayerKey, "Greed", "Mark for Valentinus Chocolate")	
	AddCharacterBool(AchievSettings2, PlayerKey, "FINISHED", {"For a mini boss","This only affects its single achievement"})			
end	

mcm.AddSpace(ModName, AchievSettings2)

do	--昧化犹大
	local PlayerKey = "bjudas"
	local IBSL_INFO = "One of four marks for Chaotic Belief"
	local BRH_INFO = "One of two marks for a challenge"
	
	mcm.AddTitle(ModName, AchievSettings2, "Benighted Judas")
	AddCharacterBool(AchievSettings2, PlayerKey, "Unlocked", "Is this character unlocked")
	AddCharacterBool(AchievSettings2, PlayerKey, "Heart", "Mark that does not has its own achievement")
	AddCharacterBool(AchievSettings2, PlayerKey, "Isaac", IBSL_INFO)
	AddCharacterBool(AchievSettings2, PlayerKey, "BlueBaby", IBSL_INFO)
	AddCharacterBool(AchievSettings2, PlayerKey, "Satan", IBSL_INFO)
	AddCharacterBool(AchievSettings2, PlayerKey, "Lamb", IBSL_INFO)
	AddCharacterBool(AchievSettings2, PlayerKey, "MegaSatan", "No achievement yet")
	AddCharacterBool(AchievSettings2, PlayerKey, "BossRush", BRH_INFO)
	AddCharacterBool(AchievSettings2, PlayerKey, "Hush", BRH_INFO)
	AddCharacterBool(AchievSettings2, PlayerKey, "Delirium", "Mark for The Gospel Of Judas")
	AddCharacterBool(AchievSettings2, PlayerKey, "Witness", "Mark for Throny Ring")
	AddCharacterBool(AchievSettings2, PlayerKey, "Beast", "Mark for Sword of Siberite")
	AddCharacterBool(AchievSettings2, PlayerKey, "Greed", "Mark for Reserved Nail")	
	AddCharacterBool(AchievSettings2, PlayerKey, "FINISHED", {"No achievement yet","This only affects its single achievement"})			
end	

--成就板块2结束--


--汉化
if mcm.i18n == "Chinese" then
	mcm.SetCategoryNameTranslate(ModName, "愚昧") --模组名称
	mcm.SetCategoryInfoTranslate(ModName, "测试中 (v"..ModVersion..")") --基本信息
	
	--基础板块开始--
	do
		mcm.SetSubcategoryNameTranslate(ModName, BasicSettings,"基础")
		mcm.TranslateOptionsDisplayTextWithTable(ModName, BasicSettings, {
			["Future"] = "未来",
			["Curses"] = "诅咒",
			["Debug"] = "测试",
		})		
		mcm.TranslateOptionsDisplayWithTable(ModName, BasicSettings, { 
			{"Void Up", "虚空增强"},
			{"Abyss Up", "无底坑增强"},
			{"The Moving", "动人诅咒"},
			{"The Forgotten", "遗忘诅咒"},
			{"D7", "七面骰诅咒"},
			{"The Binding", "绑定诅咒"},
			{"More Commands", "更多指令"},
			{"On", "开"},
			{"Off", "关"}			
		})
		mcm.TranslateOptionsInfoTextWithTable(ModName, BasicSettings, {
			["Available to trinkets"] = "对饰品生效",
			["Move or die"] = "不动会死",
			["You may lose something when entering the same room again"] = "重新进入一个房间时 , 可能会失去某些东西",
			["You may clear the same room"] = "可能需要清理同一个房间",
			["The binding of Isaac"] = "以撒的绑定",
			["For debug console"] = "用于控制台",
			["(See the text file for more)"] = "(详见txt文件)"
		})	
	end
	--基础板块结束--
	
	
	--成就板块1开始--
	do
		mcm.SetSubcategoryNameTranslate(ModName, AchievSettings1,"成就1")
		mcm.TranslateOptionsDisplayTextWithTable(ModName, AchievSettings1, {
			["Items"] = "物品",
			["Challenges"] = "挑战",
		})		
		mcm.TranslateOptionsDisplayWithTable(ModName, AchievSettings1, {
			{"D4D", "四维骰"},
			{"Dreggy Pie", "掉渣饼"},
			{"Rolling Destiny", "乾坤十掷"},
			{"The Fragile", "易碎品"},
			{"Passover", "逾越节"},
			{"Yep", "是"},
			{"Nope", "否"},	
		})
		mcm.TranslateOptionsInfoTextWithTable(ModName, AchievSettings1, {
			["Use D4 4 times in a level to unlock"] = "单层使用四面骰4次以解锁",
			["You know how to do it, right?"] = "你懂的，对吧?",
			["Finish it for Isaac up"] = "完成以强化以撒",
			["Finish it for Magdalene up"] = "完成以强化抹大拉",
			["Finish it for Judas and The Gospel Of Judas up"] = "完成以强化犹大和犹大福音",
		})
	end
	--成就板块1结束--
	
	
	--成就板块2开始--
	do
		mcm.SetSubcategoryNameTranslate(ModName, AchievSettings2,"成就2")
		mcm.TranslateOptionsDisplayTextWithTable(ModName, AchievSettings2, {
			["Benighted Isaac"] = "昧化以撒",
			["Benighted Magdalene"] = "昧化抹大拉",
			["Benighted Judas"] = "昧化犹大",
		})		
		mcm.TranslateOptionsDisplayWithTable(ModName, AchievSettings2, {
			{"Unlocked", "人物解锁"},
			{"Heart", "妈心"},
			{"Isaac", "以撒"},
			{"BlueBaby", "蓝宝"},
			{"Satan", "撒但"},
			{"Lamb", "羔羊"},
			{"Mega", "超级"},
			{"BossRush", "头目车轮战"},
			{"Hush", "死寂"},
			{"Delirium", "精神错乱"},
			{"Witness", "见证者"},
			{"Beast", "祸兽"},
			{"Greed", "贪婪"},
			{"FINISHED", "全标记完成"},	
			{"Yep", "是"},
			{"Nope", "否"},	
		})
		mcm.TranslateOptionsInfoTextWithTable(ModName, AchievSettings2, {
			["Is this character unlocked"] = "该人物的解锁状态",
			["Mark that does not has its own achievement"] = "无专属成就",
			["No achievement yet"] = "暂无成就",
			["One of two marks for a challenge"] = "1/2解锁一个挑战",
			["For a mini boss"] = "解锁一个小头目",
			["This only affects its single achievement"] = "改动此项仅影响对应的单个成就",
			
			["One of four marks for Bottle Shard"] = "1/4解锁酒瓶碎片",
			["Mark for Dad's Promise"] = "解锁爸爸的约定",
			["Mark for Cu Zn D6"] = "解锁铜锌合金骰",
			["Mark for The Light D6"] = "解锁光辉六面骰",
			["Mark for No Options"] = "解锁拒绝选择",
			["Mark for Shooting Stars Gazer"]= "解锁仰望星空",
			
			["One of four marks for Divine Retaliation"] = "1/4解锁神圣反击",
			["Mark for Tough Heart"] = "解锁硬的心",
			["Mark for Golden Prayer"] = "解锁金色祈者",
			["Mark for Glowing Heart"] = "解锁发光的心",
			["Mark for Diamoond"] = "解锁钻石",
			["Mark for Valentinus Chocolate"] = "解锁瓦伦丁巧克力",
			
			["One of four marks for Chaotic Belief"] = "1/4解锁混沌信仰",
			["Mark for Throny Ring"] = "解锁荆棘指环",
			["Mark for golden prayer"] = "解锁金色祈者",
			["Mark for The Gospel Of Judas"] = "解锁犹大福音",
			["Mark for Sword of Siberite"] = "解锁紫电护主之刃",
			["Mark for Reserved Nail"] = "解锁备用钉子",
		})
	end	
	--成就板块2结束--	
end

