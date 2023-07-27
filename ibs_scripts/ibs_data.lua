--数据存读系统

--[[说明书:
新增设置,成就或角色索引都要做好兼容
(关联文件: mod_config_menu, ibs_achievements, marks)

在控制台使用luamod指令刷新该mod会重置数据,且模组配置菜单改变解锁状态不会自动保存
所以请分开游戏档和测试档,以及刷新后用菜单更改解锁状态要小退一下

楼层和房间的临时数据已经准备好了

玩家数据需要保存一整局请使用函数库中的Players:GetData(player)
会自动把数据存进PlayerData里
临时保存可以用Ents:GetTempData(ent)

关于如何调用数据请参考其他用到数据的lua文件(懒得写了XD)
]]

local mod = Isaac_BenightedSoul
local json = require("json")

----初始化数据----
local function Temp_Init()
	return {PlayerData={},Room={},Level={},IsContinue=false}
end

local function Persis_Init() --此处可新增永久数据
return {isaacSatanDeath = false,
		maggySacrifice = false,
		maggyTimes = 0
		}
end

local function GameState_Init()
	local Temp = Temp_Init()
	local Persis = Persis_Init()

	return {["Temp"]=Temp,["Persis"]=Persis}
end

local function Mark_Init() --此处可新增角色成就(一般很久才新增)
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

local PlayerKey = {"bisaac", "bmaggy"} --此处可新增角色索引

local function Setting_Init() --此处可新增设置
	local Setting = {
		
		--基础区开始--
		["voidUp"] = false, --虚空增强
		["abyssUp"] = false, --无底坑增强
		["moreCommands"] = false, --更多指令
		--基础区结束--
		
		
		--成就区开始--
		["d4dUnlocked"] = false, --D4D解锁
		
		["bc1"] = false,
		["bc2"] = false,
		
		--["bisaac"] = Mark_Init(), --角色成就自动添加
		--成就区结束--
		}
	
	--角色通关标记
	for _,key in pairs(PlayerKey) do
		Setting[key] = Mark_Init()
	end
	
	return Setting
end

local function Data_Init()
	local GameState = GameState_Init()
	local Setting = Setting_Init()
	
	return {["GameState"]=GameState,["Setting"]=Setting}
end

IBS_Data = Data_Init()
------------------


--保存
local SaveList={
	Data={},
	GameState={},
	Persis = {},	
	Setting={},
}
for key,_ in pairs(Data_Init()) do
	SaveList.Data[key] = true
end
for key,_ in pairs(GameState_Init()) do
	SaveList.GameState[key] = true
end
for key,_ in pairs(Persis_Init()) do
	SaveList.Persis[key] = true
end
for key,_ in pairs(Setting_Init()) do
	SaveList.Setting[key] = true
end
local function SaveWhenExit(_,shouldSave)
	if shouldSave then
		
		--清除保存名单外的数据
		for k,_ in pairs(IBS_Data) do
			if not SaveList.Data[k] then
				IBS_Data[k] = nil
			end
		end		
		for k,_ in pairs(IBS_Data.GameState) do
			if not SaveList.GameState[k] then
				IBS_Data.GameState[k] = nil
			end
		end	
		for k,_ in pairs(IBS_Data.GameState.Persis) do
			if not SaveList.Persis[k] then
				IBS_Data.GameState.Persis[k] = nil
			end
		end		
		for k,_ in pairs(IBS_Data.Setting) do
			if not SaveList.Setting[k] then
				IBS_Data.Setting[k] = nil
			end
		end	
		
		IBS_Data.GameState.Temp.IsContinue = true	--游戏状态调整为继续游戏
		
		mod:SaveData(json.encode(IBS_Data))
	end
end
local function SaveWhenEnd()
		
	--清除保存名单外的数据
	for k,_ in pairs(IBS_Data) do
		if not SaveList.Data[k] then
			IBS_Data[k] = nil
		end
	end		
	for k,_ in pairs(IBS_Data.GameState) do
		if not SaveList.GameState[k] then
			IBS_Data.GameState[k] = nil
		end
	end	
	for k,_ in pairs(IBS_Data.GameState.Persis) do
		if not SaveList.Persis[k] then
			IBS_Data.GameState.Persis[k] = nil
		end
	end		
	for k,_ in pairs(IBS_Data.Setting) do
		if not SaveList.Setting[k] then
			IBS_Data.Setting[k] = nil
		end
	end	
		
	mod:SaveData(json.encode(IBS_Data))
end
mod:AddPriorityCallback(ModCallbacks.MC_PRE_GAME_EXIT, CallbackPriority.LATE, SaveWhenExit)
mod:AddPriorityCallback(ModCallbacks.MC_POST_GAME_END, CallbackPriority.LATE, SaveWhenEnd)

--加载
local function LoadWhenStart(_,isContinue)

	--检测并读取数据
	if mod:HasData() then
		local data = json.decode(mod:LoadData())
		
		--如果有,加载新增的永久数据和设置
		local GameState = GameState_Init()
		local Persis = Persis_Init()
		local Setting = Setting_Init()
		local Mark = Mark_Init()
		if data["GameState"] == nil then
			data["GameState"] = GameState
		end
		if data["Setting"] == nil then
			data["Setting"] = Setting
		end
		for k,_ in pairs(Persis) do
			if data.GameState.Persis[k] == nil then
				data.GameState.Persis[k] = Persis[k]
			end
		end		
		for k,_ in pairs(Setting) do
			if data.Setting[k] == nil then
				data.Setting[k] = Setting[k]
			end
		end	
		for k,_ in pairs(Mark) do
			for _,key in pairs(PlayerKey) do
				if data.Setting[key][k] == nil then
					data.Setting[key][k] = Mark[k]
				end
			end
		end
		
		--新开游戏重置临时数据
		if not isContinue then
			data.GameState.Temp = Temp_Init()
		end
		
		IBS_Data = data
	end
	
	--刷新角色属性
	for i = 0, Game():GetNumPlayers() -1 do
		local player = Isaac.GetPlayer(i)
		player:AddCacheFlags(CacheFlag.CACHE_ALL)
		player:EvaluateItems()
	end

end
mod:AddPriorityCallback(ModCallbacks.MC_POST_GAME_STARTED, CallbackPriority.IMPORTANT, LoadWhenStart)




--重置房间临时数据
local function ResetRoomData()
	IBS_Data.GameState.Temp.Room = {}

	--刷新角色属性
	for i = 0, Game():GetNumPlayers() -1 do
		local player = Isaac.GetPlayer(i)
		player:AddCacheFlags(CacheFlag.CACHE_ALL)
		player:EvaluateItems()
	end
end
mod:AddPriorityCallback(ModCallbacks.MC_POST_NEW_ROOM, CallbackPriority.EARLY, ResetRoomData)

--重置楼层临时数据
local function ResetLevelData()
	IBS_Data.GameState.Temp.Level = {}

	--刷新角色属性
	for i = 0, Game():GetNumPlayers() -1 do
		local player = Isaac.GetPlayer(i)
		player:AddCacheFlags(CacheFlag.CACHE_ALL)
		player:EvaluateItems()
	end
end
mod:AddPriorityCallback(ModCallbacks.MC_POST_NEW_LEVEL, CallbackPriority.EARLY, ResetLevelData)