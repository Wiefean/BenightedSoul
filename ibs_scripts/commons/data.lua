--数据存读系统

--[[说明书:
只能长久保存lua的部分数据类型(json的原因):
数字(Number),字符串(String),表(Table),是否(Bool)
数字不能作为表的索引，除非是连续正整数(用tostring()把数字换成字符串形式就没问题了)

长久保存以撒自定义的数据类型只能通过间接方式,
想办法创建独特的索引,或保存可以保存的数值,
如对于矢量(Vector),可以保存其X坐标和Y坐标;
对于实体(Entity),可以用其初始种子(InitSeed)的字符串形式作为索引;
这里的"RNG"其实就是保存了RNG的种子

特别地,玩家数据需要保存一整局请使用函数库中的Players:GetData(player),
会自动把数据存进这里的"PlayerData"里

楼层和房间的临时数据已经准备好了,分别会在新层,新房间自动重置

关于如何调用数据请参考"ibs_commons"相关函数以及其他用到数据的lua文件(懒得写了XD)

新增非成就长久数据记得去"ibs_imgui"注册一下非成就表,
防止一键解锁成就功能干扰数据

发光沙漏兼容部分在"ibs_commons"(十分硬核)
]]

local mod = Isaac_BenightedSoul
local json = require('json')
local game = Game()


----初始化数据----
local function Temp_Init()
	return {PlayerData={},Room={},Level={},RNG={},IsContinued=false}
end

local function Mark_Init() --角色成就
return {Unlocked = false,
		Heart = false,
		Isaac = false,
		BlueBaby = false,
		Satan = false,
		Lamb = false,
		MegaSatan = false,
		BossRush = false,
		Hush = false,
		Delirium = false,
		Witness = false,
		Beast = false,
		Greed = false,
		FINISHED = false
		}
end


local function Persis_Init() --此处可新增长久数据
	local Persis = {
		isaacSatanDeath = false, --用于表表以撒解锁
		maggySloth = false, --用于表表抹解锁
		maggyLust = false, --用于表表抹解锁
		maggyWrath = false, --用于表表抹解锁
		maggyGluttony = false, --用于表表抹解锁
		maggyGreed = false, --用于表表抹解锁
		maggyEnvy = false, --用于表表抹解锁
		maggyPride = false, --用于表表抹解锁
		lostDeath = 0, --用于表表游魂解锁
		
		
		troposphere = 515, --用于对流层
		

		----------------------
		-------成就部分-------
		----------------------
		--(角色成就自动添加)

		--物品区开始--
		dreggyPieUnlocked = false, --掉渣饼
		geUnlocked = false, --黄金体验
		--物品区结束--


		--挑战区开始--
		bc1 = false,
		bc2 = false,
		bc3 = false,
		bc4 = false,
		bc5 = false,
		bc10 = false,
		bc11 = false,
		bc13 = false,
		--挑战区结束--


		----------------------
		-------设置部分-------
		----------------------

		--难度区开始--
		difficulty_enemy_hp_up = false, --敌人血量增长
		difficulty_enemy_level_mult = 0.3, --敌人血量每层增长
		difficulty_boss_level_mult = 0.2, --boss敌人血量每层增长
		--难度区结束--

		--诅咒区开始--
		curse_moving = true, --动人诅咒
		curse_d7 = true, --D7诅咒
		--诅咒区结束--
		
		
		--可互动实体区开始--
		slot_collectionBox = true, --募捐箱
		slot_albern = true, --真理小子
		slot_facer = true, --换脸商
		slot_envoy = true, --使者
		--可互动实体区结束--
		
		
		--头目区开始--
		boss_deligence_diligence = true, --勤劳
		boss_fortitude = true, --坚韧
		boss_temperance = true, --节制
		boss_generosity = true, --慷慨
		boss_humility = true, --谦逊
		--头目区结束--		
		
		
		--杂项区开始--
		voidUp = false, --虚空增强
		abyssUp = false, --无底坑增强
		envyDisguise = true, --女疾女户伪装
		envyJS = true, --女疾女户跳脸
		otto = false, --女疾女户OTTO硅胶
		envyRemove = false, --从池中移除女疾女户
		tipI = true, --角色菜单提示
		rewindCompat = true, --发光沙漏兼容
		--杂项区结束--

	}

	--角色通关标记
	for _,key in pairs(mod.IBS_PlayerKey) do
		Persis[key] = Persis[key] or Mark_Init()
	end

	return Persis
end


local function Data_Init()
	return {Temp=Temp_Init(),Persis=Persis_Init()}
end

mod.IBS_Data = Data_Init()
------------------


--保存
local SaveList={
	Data={},
	Persis = {},
}
for key,_ in pairs(Data_Init()) do
	SaveList.Data[key] = true
end
for key,_ in pairs(Persis_Init()) do
	SaveList.Persis[key] = true
end
local function SaveWhenExit(_,shouldSave) --退出游戏时保存
	if shouldSave then
		
		--清除保存名单外的数据
		for k,_ in pairs(mod.IBS_Data) do
			if not SaveList.Data[k] then
				mod.IBS_Data[k] = nil
			end
		end
		for k,_ in pairs(mod.IBS_Data.Persis) do
			if not SaveList.Persis[k] then
				mod.IBS_Data.Persis[k] = nil
			end
		end
		
		mod.IBS_Data.Temp.IsContinued = true --游戏状态调整为继续游戏
		
		mod:SaveData(json.encode(mod.IBS_Data))
	end
end
local function SaveWhenEnd() --游戏结束时保存

	--清除保存名单外的数据
	for k,_ in pairs(mod.IBS_Data) do
		if not SaveList.Data[k] then
			mod.IBS_Data[k] = nil
		end
	end
	for k,_ in pairs(mod.IBS_Data.Persis) do
		if not SaveList.Persis[k] then
			mod.IBS_Data.Persis[k] = nil
		end
	end
		
	mod:SaveData(json.encode(mod.IBS_Data))
end
mod:AddPriorityCallback(ModCallbacks.MC_PRE_GAME_EXIT, 10^7, SaveWhenExit)
mod:AddPriorityCallback(ModCallbacks.MC_POST_GAME_END, 10^7, SaveWhenEnd)


--加载
local function LoadWhenSaveslotSelected() --选中存档槽时加载
	--检测并读取数据
	if mod:HasData() then
		mod.IBS_Data = json.decode(mod:LoadData())
		
		--如果有,加载新增的永久数据和设置
		local _Data = Data_Init()
		local _Persis = Persis_Init()
		for k,_ in pairs(_Data) do
			if mod.IBS_Data[k] == nil then
				mod.IBS_Data[k] = _Data[k]
			end
		end		
		for k,_ in pairs(_Persis) do
			if mod.IBS_Data.Persis[k] == nil then
				mod.IBS_Data.Persis[k] = _Persis[k]
			end
		end		
	end	
end
local function LoadWhenStart(_,isContinued) --开始游戏时加载
	--检测并读取数据
	if mod:HasData() then
		mod.IBS_Data = json.decode(mod:LoadData())

		--如果有,加载新增的永久数据和设置
		local _Data = Data_Init()
		local _Persis = Persis_Init()
		for k,_ in pairs(_Data) do
			if mod.IBS_Data[k] == nil then
				mod.IBS_Data[k] = _Data[k]
			end
		end		
		for k,_ in pairs(_Persis) do
			if mod.IBS_Data.Persis[k] == nil then
				mod.IBS_Data.Persis[k] = _Persis[k]
			end
		end	

		--新开游戏重置临时数据
		if not isContinued then
			mod.IBS_Data.Temp = Temp_Init()
		end
	end

	--刷新角色属性
	for i = 0, game:GetNumPlayers() -1 do
		local player = Isaac.GetPlayer(i)
		player:AddCacheFlags(CacheFlag.CACHE_ALL, true)
	end
end
mod:AddPriorityCallback(ModCallbacks.MC_POST_SAVESLOT_LOAD, -10^7, LoadWhenSaveslotSelected)
mod:AddPriorityCallback(ModCallbacks.MC_POST_GAME_STARTED, -10^7, LoadWhenStart)


--重置房间临时数据
local function ResetRoomData()
	mod.IBS_Data.Temp.Room = mod.IBS_Data.Temp.Room or {}
	for k,_ in pairs(mod.IBS_Data.Temp.Room) do
		mod.IBS_Data.Temp.Room[k] = nil
	end

	--刷新角色属性
	for i = 0, game:GetNumPlayers() -1 do
		local player = Isaac.GetPlayer(i)
		player:AddCacheFlags(CacheFlag.CACHE_ALL, true)
	end
end
mod:AddPriorityCallback(ModCallbacks.MC_POST_NEW_ROOM, -10^7, ResetRoomData)

--重置楼层临时数据
local function ResetLevelData()
	mod.IBS_Data.Temp.Level = mod.IBS_Data.Temp.Level or {}
	for k,_ in pairs(mod.IBS_Data.Temp.Level) do
		mod.IBS_Data.Temp.Level[k] = nil
	end

	--刷新角色属性
	for i = 0, game:GetNumPlayers() -1 do
		local player = Isaac.GetPlayer(i)
		player:AddCacheFlags(CacheFlag.CACHE_ALL, true)
	end
end
mod:AddPriorityCallback(ModCallbacks.MC_POST_NEW_LEVEL, -10^7, ResetLevelData)

