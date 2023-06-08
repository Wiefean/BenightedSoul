--模组配置菜单

local mod = Isaac_BenightedSoul
local ModName = mod.Name
local ModVersion = mod.ModVersion

local mcm = ModConfigMenu

local BasicSettings = "Basic" --基础板块
local AchievSettings1 = "Achiev1" --成就板块1
local AchievSettings2 = "Achiev2" --成就板块2


mcm.SetCategoryInfo(ModName, "Still Testing (v"..ModVersion..")") --设置模组名称和基本信息


--基础板块开始--
do	--未来
	mcm.AddTitle(ModName, BasicSettings, "Future")
	do	--虚空增强
		local KEY = "voidUp"
		local INFO = {"Available to trinkets"}
		
		local setting = mcm.AddBooleanSetting(
			ModName, --模组名称
			BasicSettings, --板块名称
			KEY, --该设置表的索引,为方便与存读系统的索引统一
			IBS_Data.Setting[KEY], --默认值,为方便与存读系统统一
			"Void Up", --该设置字符显示1(无用)
			{[true]="On",[false]="Off"}, --该设置字符显示2(无用)
			INFO --说明
		)
		setting.Display = function() --真正的显示
			local dis = "Void Up"
			if IBS_Data.Setting[KEY] then
				dis = dis..":On"
			else
				dis = dis..":Off"
			end
			return dis
		end
		setting.OnChange = function(value) --更改设置
			IBS_Data.Setting[KEY] = not IBS_Data.Setting[KEY]
			mod:SaveIBSData()
		end	
	end	
	
	do	--无底坑增强
		local KEY = "abyssUp"
		local INFO = {"Available to trinkets"}
		
		local setting = mcm.AddBooleanSetting(
			ModName, 
			BasicSettings,
			KEY,
			IBS_Data.Setting[KEY], 
			"Abyss Up", 
			{[true]="On",[false]="Off"},
			INFO 
		)
		setting.Display = function()
			local dis = "Abyss Up"
			if IBS_Data.Setting[KEY] then
				dis = dis..":On"
			else
				dis = dis..":Off"
			end
			return dis
		end
		setting.OnChange = function(value)
			IBS_Data.Setting[KEY] = not IBS_Data.Setting[KEY]
			mod:SaveIBSData()
		end	
	end	
end

mcm.AddSpace(ModName, BasicSettings) --添加空行

do	--更多指令
	mcm.AddTitle(ModName, BasicSettings, "Debug")
	local KEY = "moreCommands"
	local INFO = {"For debug console","(See the text file for more)"}
	
	local setting = mcm.AddBooleanSetting(
		ModName, --模组名称
		BasicSettings, --板块名称
		KEY, --该设置表的索引,为方便与存读系统的索引统一
		IBS_Data.Setting[KEY], --默认值,为方便与存读系统统一
		"More Commands", --该设置字符显示1(无用)
		{[true]="On",[false]="Off"}, --该设置字符显示2(无用)
		INFO --说明
	)
	setting.Display = function() --真正的显示
		local dis = "More Commands"
		if IBS_Data.Setting[KEY] then
			dis = dis..":On"
		else
			dis = dis..":Off"
		end
		return dis
	end
	setting.OnChange = function(value) --更改设置
		IBS_Data.Setting[KEY] = not IBS_Data.Setting[KEY]
		mod:SaveIBSData()
	end	
end
--基础板块结束--

--成就板块1开始--
do	--物品
	mcm.AddTitle(ModName, AchievSettings1, "Items")
	do	--D4D
		local KEY = "d4dUnlocked"
		local INFO = {"Use D4 40 times in a run to unlock"}
		
		local setting = mcm.AddBooleanSetting(
			ModName,
			AchievSettings1,
			KEY, 
			IBS_Data.Setting[KEY], 
			"D4D", 
			{[true]="On",[false]="Off"}, 
			INFO
		)
		setting.Display = function()
			local dis = "D4D"
			if IBS_Data.Setting[KEY] then
				dis = dis..":Yep"
			else
				dis = dis..":Nope"
			end
			return dis
		end
		setting.OnChange = function(value)
			IBS_Data.Setting[KEY] = not IBS_Data.Setting[KEY]
			mod:SaveIBSData()
		end	
	end
end

mcm.AddSpace(ModName, AchievSettings1)

do	--挑战
	mcm.AddTitle(ModName, AchievSettings1, "Challenges")
	do	--bc1
		local KEY = "bc1"
		local INFO = {"Finish it for Isaac up"}
		
		local setting = mcm.AddBooleanSetting(
			ModName,
			AchievSettings1,
			KEY, 
			IBS_Data.Setting[KEY], 
			"bc1", 
			{[true]="On",[false]="Off"}, 
			INFO
		)
		setting.Display = function()
			local dis = "Rolling Destiny"
			if IBS_Data.Setting[KEY] then
				dis = dis..":Yep"
			else
				dis = dis..":Nope"
			end
			return dis
		end
		setting.OnChange = function(value)
			IBS_Data.Setting[KEY] = not IBS_Data.Setting[KEY]
			mod:SaveIBSData()
		end	
	end
end
--成就板块1结束--


--成就板块2开始--
do	--昧化以撒
	mcm.AddTitle(ModName, AchievSettings2, "Benighted Isaac")
	local PlayerKey = "bisaac" --角色索引
	
	do	--人物解锁状态
		local KEY = "Unlocked" --与数据存读系统中的标记索引同名
		local INFO = {"Is this character unlocked"} --信息
		
		local setting = mcm.AddBooleanSetting(
			ModName, 
			AchievSettings2, 
			PlayerKey..KEY, --角色索引加数据索引等于设置索引(天才
			IBS_Data.Setting[PlayerKey][KEY], --默认值
			KEY, --这里是显示字符,为方便与索引同名
			{[true]="Change",[false]="Change"},
			INFO 
		)
		setting.Display = function()
			local dis = KEY
			if IBS_Data.Setting[PlayerKey][KEY] then
				dis = dis..":Yep"
			else
				dis = dis..":Nope"
			end
			return dis
		end		
		setting.OnChange = function(value) 
			IBS_Data.Setting[PlayerKey][KEY] = not IBS_Data.Setting[PlayerKey][KEY]
			mod:SaveIBSData()
		end	
	end
	
	do	--心脏标记
		local KEY = "Heart"
		local INFO = {"Mark that does not has its own achievement"}
		
		local setting = mcm.AddBooleanSetting(
			ModName, 
			AchievSettings2, 
			PlayerKey..KEY, 
			IBS_Data.Setting[PlayerKey][KEY], 
			KEY, 
			{[true]="Change",[false]="Change"},
			INFO 
		)
		setting.Display = function()
			local dis = KEY
			if IBS_Data.Setting[PlayerKey][KEY] then
				dis = dis..":Yep"
			else
				dis = dis..":Nope"
			end
			return dis
		end
		setting.OnChange = function(value) 
			IBS_Data.Setting[PlayerKey][KEY] = not IBS_Data.Setting[PlayerKey][KEY]
			mod:SaveIBSData()
		end	
	end
	
	do	--以撒标记
		local KEY = "Isaac"
		local INFO = {"One of four marks for bottle shard"}
		
		local setting = mcm.AddBooleanSetting(
			ModName, 
			AchievSettings2, 
			PlayerKey..KEY, 
			IBS_Data.Setting[PlayerKey][KEY], 
			KEY, 
			{[true]="Change",[false]="Change"},
			INFO 
		)
		setting.Display = function()
			local dis = KEY
			if IBS_Data.Setting[PlayerKey][KEY] then
				dis = dis..":Yep"
			else
				dis = dis..":Nope"
			end
			return dis
		end		
		setting.OnChange = function(value) 
			IBS_Data.Setting[PlayerKey][KEY] = not IBS_Data.Setting[PlayerKey][KEY]
			mod:SaveIBSData()
		end	
	end

	do	--蓝人标记
		local KEY = "BlueBaby"
		local INFO = {"One of four marks for bottle shard"}
		
		local setting = mcm.AddBooleanSetting(
			ModName, 
			AchievSettings2, 
			PlayerKey..KEY, 
			IBS_Data.Setting[PlayerKey][KEY], 
			KEY, 
			{[true]="Change",[false]="Change"},
			INFO 
		)
		setting.Display = function()
			local dis = KEY
			if IBS_Data.Setting[PlayerKey][KEY] then
				dis = dis..":Yep"
			else
				dis = dis..":Nope"
			end
			return dis
		end		
		setting.OnChange = function(value) 
			IBS_Data.Setting[PlayerKey][KEY] = not IBS_Data.Setting[PlayerKey][KEY]
			mod:SaveIBSData()
		end	
	end

	do	--撒旦标记
		local KEY = "Satan"
		local INFO = {"One of four marks for bottle shard"}
		
		local setting = mcm.AddBooleanSetting(
			ModName, 
			AchievSettings2, 
			PlayerKey..KEY, 
			IBS_Data.Setting[PlayerKey][KEY], 
			KEY, 
			{[true]="Change",[false]="Change"},
			INFO 
		)
		setting.Display = function()
			local dis = KEY
			if IBS_Data.Setting[PlayerKey][KEY] then
				dis = dis..":Yep"
			else
				dis = dis..":Nope"
			end
			return dis
		end		
		setting.OnChange = function(value) 
			IBS_Data.Setting[PlayerKey][KEY] = not IBS_Data.Setting[PlayerKey][KEY]
			mod:SaveIBSData()
		end	
	end

	do	--羔羊标记
		local KEY = "Lamb"
		local INFO = {"One of four marks for bottle shard"}
		
		local setting = mcm.AddBooleanSetting(
			ModName, 
			AchievSettings2, 
			PlayerKey..KEY, 
			IBS_Data.Setting[PlayerKey][KEY], 
			KEY, 
			{[true]="Change",[false]="Change"},
			INFO 
		)
		setting.Display = function()
			local dis = KEY
			if IBS_Data.Setting[PlayerKey][KEY] then
				dis = dis..":Yep"
			else
				dis = dis..":Nope"
			end
			return dis
		end		
		setting.OnChange = function(value) 
			IBS_Data.Setting[PlayerKey][KEY] = not IBS_Data.Setting[PlayerKey][KEY]
			mod:SaveIBSData()
		end	
	end

	do	--超级撒旦标记
		local KEY = "MegaSatan"
		local INFO = {"Mark for Cu Zn D6"}
		
		local setting = mcm.AddBooleanSetting(
			ModName, 
			AchievSettings2, 
			PlayerKey..KEY, 
			IBS_Data.Setting[PlayerKey][KEY], 
			KEY, 
			{[true]="Change",[false]="Change"},
			INFO 
		)
		setting.Display = function()
			local dis = KEY
			if IBS_Data.Setting[PlayerKey][KEY] then
				dis = dis..":Yep"
			else
				dis = dis..":Nope"
			end
			return dis
		end		
		setting.OnChange = function(value) 
			IBS_Data.Setting[PlayerKey][KEY] = not IBS_Data.Setting[PlayerKey][KEY]
			mod:SaveIBSData()
		end	
	end

	do	--BR标记
		local KEY = "BossRush"
		local INFO = {"One of two marks for a challenge"}
		
		local setting = mcm.AddBooleanSetting(
			ModName, 
			AchievSettings2, 
			PlayerKey..KEY, 
			IBS_Data.Setting[PlayerKey][KEY], 
			KEY, 
			{[true]="Change",[false]="Change"},
			INFO 
		)
		setting.Display = function()
			local dis = KEY
			if IBS_Data.Setting[PlayerKey][KEY] then
				dis = dis..":Yep"
			else
				dis = dis..":Nope"
			end
			return dis
		end		
		setting.OnChange = function(value) 
			IBS_Data.Setting[PlayerKey][KEY] = not IBS_Data.Setting[PlayerKey][KEY]
			mod:SaveIBSData()
		end	
	end
	
	do	--死寂标记
		local KEY = "Hush"
		local INFO = {"One of two marks for a challenge"}
		
		local setting = mcm.AddBooleanSetting(
			ModName, 
			AchievSettings2, 
			PlayerKey..KEY, 
			IBS_Data.Setting[PlayerKey][KEY], 
			KEY, 
			{[true]="Change",[false]="Change"},
			INFO 
		)
		setting.Display = function()
			local dis = KEY
			if IBS_Data.Setting[PlayerKey][KEY] then
				dis = dis..":Yep"
			else
				dis = dis..":Nope"
			end
			return dis
		end		
		setting.OnChange = function(value) 
			IBS_Data.Setting[PlayerKey][KEY] = not IBS_Data.Setting[PlayerKey][KEY]
			mod:SaveIBSData()
		end	
	end	
	
	do	--精神错乱标记
		local KEY = "Delirium"
		local INFO = {"Mark for light D6"}
		
		local setting = mcm.AddBooleanSetting(
			ModName, 
			AchievSettings2, 
			PlayerKey..KEY, 
			IBS_Data.Setting[PlayerKey][KEY], 
			KEY, 
			{[true]="Change",[false]="Change"},
			INFO 
		)
		setting.Display = function()
			local dis = KEY
			if IBS_Data.Setting[PlayerKey][KEY] then
				dis = dis..":Yep"
			else
				dis = dis..":Nope"
			end
			return dis
		end		
		setting.OnChange = function(value) 
			IBS_Data.Setting[PlayerKey][KEY] = not IBS_Data.Setting[PlayerKey][KEY]
			mod:SaveIBSData()
		end	
	end		
	
	do	--见证者标记
		local KEY = "Witness"
		local INFO = {"Mark for Dad's Promise"}
		
		local setting = mcm.AddBooleanSetting(
			ModName, 
			AchievSettings2, 
			PlayerKey..KEY, 
			IBS_Data.Setting[PlayerKey][KEY], 
			KEY, 
			{[true]="Change",[false]="Change"},
			INFO 
		)
		setting.Display = function()
			local dis = KEY
			if IBS_Data.Setting[PlayerKey][KEY] then
				dis = dis..":Yep"
			else
				dis = dis..":Nope"
			end
			return dis
		end		
		setting.OnChange = function(value) 
			IBS_Data.Setting[PlayerKey][KEY] = not IBS_Data.Setting[PlayerKey][KEY]
			mod:SaveIBSData()
		end	
	end	
	
	do	--祸兽标记
		local KEY = "Beast"
		local INFO = {"Mark for No Options"}
		
		local setting = mcm.AddBooleanSetting(
			ModName, 
			AchievSettings2, 
			PlayerKey..KEY, 
			IBS_Data.Setting[PlayerKey][KEY], 
			KEY, 
			{[true]="Change",[false]="Change"},
			INFO 
		)
		setting.Display = function()
			local dis = KEY
			if IBS_Data.Setting[PlayerKey][KEY] then
				dis = dis..":Yep"
			else
				dis = dis..":Nope"
			end
			return dis
		end		
		setting.OnChange = function(value) 
			IBS_Data.Setting[PlayerKey][KEY] = not IBS_Data.Setting[PlayerKey][KEY]
			mod:SaveIBSData()
		end	
	end		
	
	do	--贪婪标记
		local KEY = "Greed"
		local INFO = {"Mark for Shooting Stars Gazer"}
		
		local setting = mcm.AddBooleanSetting(
			ModName, 
			AchievSettings2, 
			PlayerKey..KEY, 
			IBS_Data.Setting[PlayerKey][KEY], 
			KEY, 
			{[true]="Change",[false]="Change"},
			INFO 
		)
		setting.Display = function()
			local dis = KEY
			if IBS_Data.Setting[PlayerKey][KEY] then
				dis = dis..":Yep"
			else
				dis = dis..":Nope"
			end
			return dis
		end		
		setting.OnChange = function(value) 
			IBS_Data.Setting[PlayerKey][KEY] = not IBS_Data.Setting[PlayerKey][KEY]
			mod:SaveIBSData()
		end	
	end		
	
	do	--全红
		local KEY = "FINISHED"
		local INFO = {"For a mini boss","This only affects its single achievement"}
		
		local setting = mcm.AddBooleanSetting(
			ModName, 
			AchievSettings2, 
			PlayerKey..KEY, 
			IBS_Data.Setting[PlayerKey][KEY], 
			KEY, 
			{[true]="Change",[false]="Change"},
			INFO 
		)
		setting.Display = function()
			local dis = KEY
			if IBS_Data.Setting[PlayerKey][KEY] then
				dis = dis..":Yep"
			else
				dis = dis..":Nope"
			end
			return dis
		end		
		setting.OnChange = function(value) 
			IBS_Data.Setting[PlayerKey][KEY] = not IBS_Data.Setting[PlayerKey][KEY]
			mod:SaveIBSData()
		end	
	end			
	
end	

mcm.AddSpace(ModName, AchievSettings2) --添加空行

do	--昧化抹大拉
	mcm.AddTitle(ModName, AchievSettings2, "Benighted Magdalene")
	local PlayerKey = "bmaggy" --角色索引
	
	do	--人物解锁状态
		local KEY = "Unlocked"
		local INFO = {"Is this character unlocked"} 
		
		local setting = mcm.AddBooleanSetting(
			ModName, 
			AchievSettings2, 
			PlayerKey..KEY,
			IBS_Data.Setting[PlayerKey][KEY],
			KEY,
			{[true]="Change",[false]="Change"},
			INFO 
		)
		setting.Display = function()
			local dis = KEY
			if IBS_Data.Setting[PlayerKey][KEY] then
				dis = dis..":Yep"
			else
				dis = dis..":Nope"
			end
			return dis
		end		
		setting.OnChange = function(value) 
			IBS_Data.Setting[PlayerKey][KEY] = not IBS_Data.Setting[PlayerKey][KEY]
			mod:SaveIBSData()
		end	
	end
	
	do	--心脏标记
		local KEY = "Heart"
		local INFO = {"Mark that does not has its own achievement"}
		
		local setting = mcm.AddBooleanSetting(
			ModName, 
			AchievSettings2, 
			PlayerKey..KEY, 
			IBS_Data.Setting[PlayerKey][KEY], 
			KEY, 
			{[true]="Change",[false]="Change"},
			INFO 
		)
		setting.Display = function()
			local dis = KEY
			if IBS_Data.Setting[PlayerKey][KEY] then
				dis = dis..":Yep"
			else
				dis = dis..":Nope"
			end
			return dis
		end
		setting.OnChange = function(value) 
			IBS_Data.Setting[PlayerKey][KEY] = not IBS_Data.Setting[PlayerKey][KEY]
			mod:SaveIBSData()
		end	
	end
	
	do	--以撒标记
		local KEY = "Isaac"
		local INFO = {"No achievement yet"}
		
		local setting = mcm.AddBooleanSetting(
			ModName, 
			AchievSettings2, 
			PlayerKey..KEY, 
			IBS_Data.Setting[PlayerKey][KEY], 
			KEY, 
			{[true]="Change",[false]="Change"},
			INFO 
		)
		setting.Display = function()
			local dis = KEY
			if IBS_Data.Setting[PlayerKey][KEY] then
				dis = dis..":Yep"
			else
				dis = dis..":Nope"
			end
			return dis
		end		
		setting.OnChange = function(value) 
			IBS_Data.Setting[PlayerKey][KEY] = not IBS_Data.Setting[PlayerKey][KEY]
			mod:SaveIBSData()
		end	
	end

	do	--蓝人标记
		local KEY = "BlueBaby"
		local INFO = {"No achievement yet"}
		
		local setting = mcm.AddBooleanSetting(
			ModName, 
			AchievSettings2, 
			PlayerKey..KEY, 
			IBS_Data.Setting[PlayerKey][KEY], 
			KEY, 
			{[true]="Change",[false]="Change"},
			INFO 
		)
		setting.Display = function()
			local dis = KEY
			if IBS_Data.Setting[PlayerKey][KEY] then
				dis = dis..":Yep"
			else
				dis = dis..":Nope"
			end
			return dis
		end		
		setting.OnChange = function(value) 
			IBS_Data.Setting[PlayerKey][KEY] = not IBS_Data.Setting[PlayerKey][KEY]
			mod:SaveIBSData()
		end	
	end

	do	--撒旦标记
		local KEY = "Satan"
		local INFO = {"No achievement yet"}
		
		local setting = mcm.AddBooleanSetting(
			ModName, 
			AchievSettings2, 
			PlayerKey..KEY, 
			IBS_Data.Setting[PlayerKey][KEY], 
			KEY, 
			{[true]="Change",[false]="Change"},
			INFO 
		)
		setting.Display = function()
			local dis = KEY
			if IBS_Data.Setting[PlayerKey][KEY] then
				dis = dis..":Yep"
			else
				dis = dis..":Nope"
			end
			return dis
		end		
		setting.OnChange = function(value) 
			IBS_Data.Setting[PlayerKey][KEY] = not IBS_Data.Setting[PlayerKey][KEY]
			mod:SaveIBSData()
		end	
	end

	do	--羔羊标记
		local KEY = "Lamb"
		local INFO = {"No achievement yet"}
		
		local setting = mcm.AddBooleanSetting(
			ModName, 
			AchievSettings2, 
			PlayerKey..KEY, 
			IBS_Data.Setting[PlayerKey][KEY], 
			KEY, 
			{[true]="Change",[false]="Change"},
			INFO 
		)
		setting.Display = function()
			local dis = KEY
			if IBS_Data.Setting[PlayerKey][KEY] then
				dis = dis..":Yep"
			else
				dis = dis..":Nope"
			end
			return dis
		end		
		setting.OnChange = function(value) 
			IBS_Data.Setting[PlayerKey][KEY] = not IBS_Data.Setting[PlayerKey][KEY]
			mod:SaveIBSData()
		end	
	end

	do	--超级撒旦标记
		local KEY = "MegaSatan"
		local INFO = {"No achievement yet"}
		
		local setting = mcm.AddBooleanSetting(
			ModName, 
			AchievSettings2, 
			PlayerKey..KEY, 
			IBS_Data.Setting[PlayerKey][KEY], 
			KEY, 
			{[true]="Change",[false]="Change"},
			INFO 
		)
		setting.Display = function()
			local dis = KEY
			if IBS_Data.Setting[PlayerKey][KEY] then
				dis = dis..":Yep"
			else
				dis = dis..":Nope"
			end
			return dis
		end		
		setting.OnChange = function(value) 
			IBS_Data.Setting[PlayerKey][KEY] = not IBS_Data.Setting[PlayerKey][KEY]
			mod:SaveIBSData()
		end	
	end

	do	--BR标记
		local KEY = "BossRush"
		local INFO = {"No achievement yet"}
		
		local setting = mcm.AddBooleanSetting(
			ModName, 
			AchievSettings2, 
			PlayerKey..KEY, 
			IBS_Data.Setting[PlayerKey][KEY], 
			KEY, 
			{[true]="Change",[false]="Change"},
			INFO 
		)
		setting.Display = function()
			local dis = KEY
			if IBS_Data.Setting[PlayerKey][KEY] then
				dis = dis..":Yep"
			else
				dis = dis..":Nope"
			end
			return dis
		end		
		setting.OnChange = function(value) 
			IBS_Data.Setting[PlayerKey][KEY] = not IBS_Data.Setting[PlayerKey][KEY]
			mod:SaveIBSData()
		end	
	end
	
	do	--死寂标记
		local KEY = "Hush"
		local INFO = {"No achievement yet"}
		
		local setting = mcm.AddBooleanSetting(
			ModName, 
			AchievSettings2, 
			PlayerKey..KEY, 
			IBS_Data.Setting[PlayerKey][KEY], 
			KEY, 
			{[true]="Change",[false]="Change"},
			INFO 
		)
		setting.Display = function()
			local dis = KEY
			if IBS_Data.Setting[PlayerKey][KEY] then
				dis = dis..":Yep"
			else
				dis = dis..":Nope"
			end
			return dis
		end		
		setting.OnChange = function(value) 
			IBS_Data.Setting[PlayerKey][KEY] = not IBS_Data.Setting[PlayerKey][KEY]
			mod:SaveIBSData()
		end	
	end	
	
	do	--精神错乱标记
		local KEY = "Delirium"
		local INFO = {"No achievement yet"}
		
		local setting = mcm.AddBooleanSetting(
			ModName, 
			AchievSettings2, 
			PlayerKey..KEY, 
			IBS_Data.Setting[PlayerKey][KEY], 
			KEY, 
			{[true]="Change",[false]="Change"},
			INFO 
		)
		setting.Display = function()
			local dis = KEY
			if IBS_Data.Setting[PlayerKey][KEY] then
				dis = dis..":Yep"
			else
				dis = dis..":Nope"
			end
			return dis
		end		
		setting.OnChange = function(value) 
			IBS_Data.Setting[PlayerKey][KEY] = not IBS_Data.Setting[PlayerKey][KEY]
			mod:SaveIBSData()
		end	
	end		
	
	do	--见证者标记
		local KEY = "Witness"
		local INFO = {"No achievement yet"}
		
		local setting = mcm.AddBooleanSetting(
			ModName, 
			AchievSettings2, 
			PlayerKey..KEY, 
			IBS_Data.Setting[PlayerKey][KEY], 
			KEY, 
			{[true]="Change",[false]="Change"},
			INFO 
		)
		setting.Display = function()
			local dis = KEY
			if IBS_Data.Setting[PlayerKey][KEY] then
				dis = dis..":Yep"
			else
				dis = dis..":Nope"
			end
			return dis
		end		
		setting.OnChange = function(value) 
			IBS_Data.Setting[PlayerKey][KEY] = not IBS_Data.Setting[PlayerKey][KEY]
			mod:SaveIBSData()
		end	
	end	
	
	do	--祸兽标记
		local KEY = "Beast"
		local INFO = {"No achievement yet"}
		
		local setting = mcm.AddBooleanSetting(
			ModName, 
			AchievSettings2, 
			PlayerKey..KEY, 
			IBS_Data.Setting[PlayerKey][KEY], 
			KEY, 
			{[true]="Change",[false]="Change"},
			INFO 
		)
		setting.Display = function()
			local dis = KEY
			if IBS_Data.Setting[PlayerKey][KEY] then
				dis = dis..":Yep"
			else
				dis = dis..":Nope"
			end
			return dis
		end		
		setting.OnChange = function(value) 
			IBS_Data.Setting[PlayerKey][KEY] = not IBS_Data.Setting[PlayerKey][KEY]
			mod:SaveIBSData()
		end	
	end		
	
	do	--贪婪标记
		local KEY = "Greed"
		local INFO = {"No achievement yet"}
		
		local setting = mcm.AddBooleanSetting(
			ModName, 
			AchievSettings2, 
			PlayerKey..KEY, 
			IBS_Data.Setting[PlayerKey][KEY], 
			KEY, 
			{[true]="Change",[false]="Change"},
			INFO 
		)
		setting.Display = function()
			local dis = KEY
			if IBS_Data.Setting[PlayerKey][KEY] then
				dis = dis..":Yep"
			else
				dis = dis..":Nope"
			end
			return dis
		end		
		setting.OnChange = function(value) 
			IBS_Data.Setting[PlayerKey][KEY] = not IBS_Data.Setting[PlayerKey][KEY]
			mod:SaveIBSData()
		end	
	end		
	
	do	--全红
		local KEY = "FINISHED"
		local INFO = {"No achievement yet"}
		
		local setting = mcm.AddBooleanSetting(
			ModName, 
			AchievSettings2, 
			PlayerKey..KEY, 
			IBS_Data.Setting[PlayerKey][KEY], 
			KEY, 
			{[true]="Change",[false]="Change"},
			INFO 
		)
		setting.Display = function()
			local dis = KEY
			if IBS_Data.Setting[PlayerKey][KEY] then
				dis = dis..":Yep"
			else
				dis = dis..":Nope"
			end
			return dis
		end		
		setting.OnChange = function(value) 
			IBS_Data.Setting[PlayerKey][KEY] = not IBS_Data.Setting[PlayerKey][KEY]
			mod:SaveIBSData()
		end	
	end			
	
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
			["Debug"] = "测试",
		})		
		mcm.TranslateOptionsDisplayWithTable(ModName, BasicSettings, { 
			{"Void Up", "虚空增强"},
			{"Abyss Up", "无底坑增强"},
			{"More Commands", "更多指令"},
			{"On", "开"},
			{"Off", "关"}			
		})
		mcm.TranslateOptionsInfoTextWithTable(ModName, BasicSettings, {
			["Available to trinkets"] = "对饰品生效",
			["For debug console"] = "用于控制台",
			["(See the text file for more)"] = "(详见txt文件)"
		})	
	end	
	--基础板块结束--
	
	--成就板块1开始--
		mcm.SetSubcategoryNameTranslate(ModName, AchievSettings1,"成就1")
		mcm.TranslateOptionsDisplayTextWithTable(ModName, AchievSettings1, {
			["Items"] = "物品",
			["Challenges"] = "挑战",
		})		
		mcm.TranslateOptionsDisplayWithTable(ModName, AchievSettings1, {
			{"D4D", "四维骰"},
			{"Rolling Destiny", "乾坤十掷"},
			{"Yep", "是"},
			{"Nope", "否"},	
		})
		mcm.TranslateOptionsInfoTextWithTable(ModName, AchievSettings1, {
			["Use D4 40 times in a run to unlock"] = "单局使用四面骰40次以解锁",
			["Finish it for Isaac up"] = "完成以强化以撒",
		})	
	--成就板块1结束--
	
	--成就板块2开始--
	do
		mcm.SetSubcategoryNameTranslate(ModName, AchievSettings2,"成就2")
		mcm.TranslateOptionsDisplayTextWithTable(ModName, AchievSettings2, {
			["Benighted Isaac"] = "昧化以撒",
			["Benighted Magdalene"] = "昧化抹大拉",
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
			--{"Change", "更改"},	
			{"Yep", "是"},
			{"Nope", "否"},	
		})
		mcm.TranslateOptionsInfoTextWithTable(ModName, AchievSettings2, {
			["Is this character unlocked"] = "该人物的解锁状态",
			["Mark that does not has its own achievement"] = "无专属成就",
			["No achievement yet"] = "暂无成就",
			["One of four marks for bottle shard"] = "1/4解锁酒瓶碎片",
			["Mark for Dad's Promise"] = "解锁爸爸的约定",
			["Mark for Cu Zn D6"] = "解锁铜锌合金骰",
			["One of two marks for a challenge"] = "1/2解锁一个挑战",
			["Mark for light D6"] = "解锁光辉六面骰",
			["Mark for No Options"] = "解锁拒绝选择",
			["Mark for Shooting Stars Gazer"]= "解锁仰望星空",
			["For a mini boss"] = "解锁一个小头目",
			["This only affects its single achievement"] = "改动此项仅影响对应的单个成就",
		})	
	end	
	--成就板块2结束--	
end