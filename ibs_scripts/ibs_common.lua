--设定通用值


--加载常量
local function LoadConstants(scripts)
    for _,v in ipairs(scripts) do
        include('ibs_scripts.commons.constants.id_'..v)
    end
end

LoadConstants{
	'sound&music',
	'callback',
	'item&trinket&pocket',
	'player&challenge',
	'entity',
	'curse',
}

local mod = Isaac_BenightedSoul
local ModName = mod.Name

local json = require('json')
local game = Game()

--API接口(散落在各个lua文件中,详见模组文件夹中的API文件夹)
mod.IBS_API = {}

------数据存读系统相关------
include('ibs_scripts.commons.data')

--即时保存数据
function mod:SaveIBSData()
	self:SaveData(json.encode(self.IBS_Data))
end

--读取数据
function mod:GetIBSData(type)
	if type == 'temp' then
		return self.IBS_Data.Temp
	elseif type == 'level' then
		return self.IBS_Data.Temp.Level
	elseif type == 'room' then
		return self.IBS_Data.Temp.Room
	elseif type == 'rng' then
		return self.IBS_Data.Temp.RNG
	elseif type == 'pdata' then
		return self.IBS_Data.Temp.PlayerData
	elseif type == 'persis' then
		return self.IBS_Data.Persis
	end	
	
	return {}
end

--是否为开局
function mod:IsStartingRun()
	if game:GetFrameCount() <= 0 then
		local level = game:GetLevel()
		--非第一层,非回溯线
		if level:GetStage() == 1 and not level:IsAscent() then
			return true
		end
	end	
	return false
end

--是否继续过游戏
function mod:IsGameContinued()
	return self.IBS_Data.Temp.IsContinued
end

--RNG种子修正(自动填写)
local RNG_SEED_OFFSET = {}

--注册RNG名称
local A = 1
function mod:RegisterRNG(name)
	if RNG_SEED_OFFSET[name] == nil then
		RNG_SEED_OFFSET[name] = A
		A = A + 1
	else
		error(mod:Message('#1 RNG name exists'), 2)
	end	
end

--获取RNG(获取之前要先用上一函数注册名称)
--[[
又要能被发光沙漏回溯,又要尽量随机一些,只能对种子下手了

用此函数获取的RNG,应该用"RandomInt"而不应该用"RandomFloat"获取随机数,
因为"RandomFloat"在种子差异较小的情况下获取的随机数差异也较小
]]
function mod:GetRNG(name)
	local offset = RNG_SEED_OFFSET[name]

	if offset == nil then
		mod:RegisterRNG(name)
		offset = RNG_SEED_OFFSET[name]
	end

	if offset ~= nil then
		local initSeed = game:GetSeeds():GetStartSeed() - offset --初始种子
		local data = mod:GetIBSData('rng')
		local seed = data[name] or initSeed
		local rng = RNG()
		rng:SetSeed(seed, 35)

		--调整并保存种子
		seed = seed - offset
		if seed <= 0 then seed = initSeed end
		data[name] = seed

		return rng
	end
end

----------------------------


----------------------------------------
-------------以下为通用函数-------------
----------------------------------------


--根据语言选择字符串
function mod:ChooseLanguage(text_zh, text_en)
	return (mod.Language == "zh" and text_zh) or text_en
end

--根据语言选择表中的字符串
function mod:ChooseLanguageInTable(tbl)
	return (tbl ~= nil and tbl[self.Language]) or nil
end

--打乱表内容顺序
function mod:ShuffleTable(tbl, seed)
	local rng = RNG(seed)
	for i = #tbl, 2, -1 do
		local j = rng:RandomInt(1, i)
		tbl[i], tbl[j] = tbl[j], tbl[i]
	end
	return tbl
end

--检查函数参数类型(主要用于错误定位)
function mod:CheckArgType(arg, expectedType, typeParaphrase, index, prefix, allowNil)
	local hasError = false
	local argType = type(arg)
	local message = ''

	if arg == nil then
		if not allowNil then hasError = true end
	else
		if argType ~= expectedType then hasError = true end
	end
	
	if hasError then
		expectedType = '"'..((typeParaphrase and expectedType..'('..typeParaphrase..')') or expectedType)..'"'
		index = (index and '#'..tostring(index)..' ') or ''
		prefix = (prefix and '['..prefix..'] ') or '['..(mod.NameStr)..'] '
		argType = '"'..argType..'"'
		message = prefix.. self:ChooseLanguage(
			'参数类型错误 '..index..expectedType..' 才是对的, 而不是 '..argType,
			'Bad argument '..index..expectedType..' expected, got '..argType
		)
	end
	
	return hasError, message
end
--[[输入:
变量(任意类型), 应该类型(字符串), 类型解释(字符串), 自变量位置(整数),
报错信息的前缀(字符串), 允许自变量为nil(是否)


变量类型:
"nil" -- 空值
"number" -- 数字
"string" -- 字符串
"boolean" -- 是否
"table" -- 表
"function" -- 函数
"thread" -- 线程
"userdata" -- 自定义(如Sprite,Entity,Vector等)

由于屑官方没有给判断自定义类型的API,需要多打一个类型解释(当然也可以为nil)

利用这个函数返回的结果搭配error函数才能实现在其他文件的错误定位(实在想不到更好的方法):
local err,mes = mod:CheckArgType(···) if err then error(mes, 2) end
]]

--(只是为了方便输出带前缀的信息)
function mod:Message(message, prefix)
	prefix = (prefix and '['..prefix..'] ') or '['..(mod.NameStr)..'] '
	message = prefix..message
	return message
end

--深度复制(主要用于复制一个表)
local function DeepCopy(value)
    local copy = nil

    if type(value) == 'table' then
        copy = {}
        for k,v in pairs(value) do
            copy[DeepCopy(k)] = DeepCopy(v)
        end
        setmetatable(copy, getmetatable(value))
    else
        copy = value
    end

    return copy
end
function mod:DeepCopy(value)
	return DeepCopy(value)
end

--延迟触发函数(单位为逻辑帧,30逻辑帧为1秒)
--[[
"waitCondition"是一个用于判断是否应该计时的函数,返回true或false
"noRewind"为true时,被延迟的函数不会被发光沙漏回溯
发光沙漏兼容在底下
]]
local DelayedFunctions = {}
local DelayedFunctions_NoRewind = {}
function mod:DelayFunction(func, frames, waitCondition, noRewind)
	if noRewind then
		table.insert(DelayedFunctions_NoRewind, {Function = func, Timeout = frames, WaitCondition = waitCondition})
	else
		table.insert(DelayedFunctions, {Function = func, Timeout = frames, WaitCondition = waitCondition})
	end
end
mod:AddCallback(ModCallbacks.MC_POST_UPDATE, function()
	if not mod.Rewinding then
		for k,v in pairs(DelayedFunctions) do
			if (not v.WaitCondition) or v.WaitCondition() then
				if v.Timeout and (v.Timeout > 0) then
					v.Timeout = v.Timeout - 1
				else
					v.Function()
					DelayedFunctions[k] = nil
				end 
			end	
		end
	end	
	for k,v in pairs(DelayedFunctions_NoRewind) do
		if (not v.WaitCondition) or v.WaitCondition() then
			if v.Timeout and (v.Timeout > 0) then
				v.Timeout = v.Timeout - 1
			else
				v.Function()
				DelayedFunctions_NoRewind[k] = nil
			end 
		end	
    end
end)

--延迟触发函数,且无视游戏暂停(单位为渲染帧,60渲染帧为1秒)
--[[
"waitCondition"是一个用于判断是否应该计时的函数,返回true或false
"noRewind"为true时,被延迟的函数不会被发光沙漏回溯
发光沙漏兼容在底下
]]
local DelayedFunctions2 = {}
local DelayedFunctions2_NoRewind = {}
function mod:DelayFunction2(func, frames, waitCondition, noRewind)
	if noRewind then
		table.insert(DelayedFunctions2_NoRewind, {Function = func, Timeout = frames, WaitCondition = waitCondition})
	else
		table.insert(DelayedFunctions2, {Function = func, Timeout = frames, WaitCondition = waitCondition})
	end
end
mod:AddCallback(ModCallbacks.MC_POST_RENDER, function()
	if not mod.Rewinding then
		for k,v in pairs(DelayedFunctions2) do
			if (not v.WaitCondition) or v.WaitCondition() then
				if v.Timeout and (v.Timeout > 0) then
					v.Timeout = v.Timeout - 1
				else
					v.Function()
					DelayedFunctions2[k] = nil
				end
			end	
		end
	end	
	for k,v in pairs(DelayedFunctions2_NoRewind) do
		if (not v.WaitCondition) or v.WaitCondition() then
			if v.Timeout and (v.Timeout > 0) then
				v.Timeout = v.Timeout - 1
			else
				v.Function()
				DelayedFunctions2_NoRewind[k] = nil
			end
		end	
    end
end)

--退出游戏时立刻触发被延迟的函数
mod:AddCallback(ModCallbacks.MC_PRE_GAME_EXIT, function()
	for k,v in pairs(DelayedFunctions) do
		v.Function()
		DelayedFunctions2[k] = nil
	end
	for k,v in pairs(DelayedFunctions_NoRewind) do
		v.Function()
		DelayedFunctions2_NoRewind[k] = nil
    end
	for k,v in pairs(DelayedFunctions2) do
		v.Function()
		DelayedFunctions2[k] = nil
	end
	for k,v in pairs(DelayedFunctions2_NoRewind) do
		v.Function()
		DelayedFunctions2_NoRewind[k] = nil
    end
end)


--函数库
--具体用法在对应lua文件
mod.IBS_Lib = {}

--设立函数库
--(用于调整设立顺序,因为部分函数库中用到了其他函数库中的函数)
local function SetLib(key, fileName)
	mod.IBS_Lib[key] = include('ibs_scripts.commons.lib.'..fileName)
end

SetLib('Translations', 'translations')
SetLib('Maths', 'maths')
SetLib('Screens', 'screens')
SetLib('Pools', 'pools')
SetLib('Ents', 'ents')
SetLib('Finds', 'finds')
SetLib('Players', 'players')
SetLib('Tears', 'tears')
SetLib('Pickups', 'pickups')
SetLib('Stats', 'stats')
SetLib('Levels', 'levels')


--Class
--具体用法在对应lua文件
mod.IBS_Class = {}

--创建Class
function mod.Class(base, ctor, arg_check_tbl)
	local class = {}

	--实现"base"的省略
	if type(base) == 'function' then
		ctor = base
		arg_check_tbl = ctor
	elseif type(base) == 'table' then
		for k,v in pairs(base) do
			class[k] = v
		end
	end

	class.__index = class
	class._ctor = ctor

	local mt = {}
	mt.__call = function(_, ...)
		local obj = {}
		setmetatable(obj, class)
		if class._ctor then

			--检测是否有变量类型错误并定位
			if arg_check_tbl ~= nil then
				for k,v in ipairs({...}) do
					local info = arg_check_tbl[k]
					if info then
						local err,mes = mod:CheckArgType(v, info.expectedType, info.typeParaphrase, k, info.mesPrefix, info.allowNil)
						if err then error(mes, 2) end
					end
				end
			end

		   class._ctor(obj, ...)
		end
		return obj
	end

	setmetatable(class, mt)

	return class
end
--[[
"base"是模版,一般是其他的Class,用于让新Class继承功能
"ctor"是构造函数,用于生成表
"arg_check_tbl"是用来检测输入参数的类型是否有误的表

arg_check_tbl的索引是对应参数位置的数字(不包含"base"和"ctor"),
值是包含以下内容的表:
{
expectedType, --应该类型(字符串)
typeParaphrase = nil, --类型解释(字符串)
mesPrefix = '愚昧', --报错前缀(字符串)
allowNil = false --允许为nil
}


"base"可省略

参考自https://atjiu.github.io/dstmod-tutorial/#/class
]]
--[[使用例:

--非继承Class
A = Class(function(self, a, b, c)
    self.key_a = a
    self.key_b = b
    self.key_c = c
end)

table1 = A(1,2,3) --相当于 table1 = {key_a = 1, key_b = 2, key_c = 3}


--继承Class
B = Class(A, function(self, a, b, c, d)
    A._ctor(self, a, b, c) --让"B"继承"A"的元素
    self.key_d = d
end)

table2 = B(1,2,3,4) --相当于 table2 = {key_a = 1, key_b = 2, key_c = 3, key_d = 4}
]]


--设立通用Class(Class不一定要通用,对吧)
local function CommonClass(key, fileName)
	mod.IBS_Class[key] = include('ibs_scripts.commons.classes.'..fileName)
end

CommonClass('Component', 'component')
CommonClass('Damage', 'damage')
CommonClass('Callback', 'callback')
CommonClass('Callbacks', 'callbacks')
CommonClass('Achievement', 'achievement')
CommonClass('Marks', 'marks')
CommonClass('Entity', 'entity')
CommonClass('Tear', 'tear')
CommonClass('Familiar', 'familiar')
CommonClass('Pickup', 'pickup')
CommonClass('Slot', 'slot')
CommonClass('Projectile', 'projectile')
CommonClass('Effect', 'effect')
CommonClass('Character', 'character')
CommonClass('CharacterLock', 'CharacterLock')
CommonClass('Challenge', 'challenge')
CommonClass('Item', 'item')
CommonClass('Trinket', 'trinket')
CommonClass('Pocket', 'pocket')
CommonClass('Curse', 'curse')
CommonClass('IronHeart', 'iron_heart')
CommonClass('TempIronHeart', 'iron_heart_temp')
CommonClass('Memories', 'memories')
CommonClass('CustomPool', 'custom_pool')
CommonClass('Room', 'room')

--------------------------------------------
----------------发光沙漏兼容----------------
--------------------------------------------
--[[说明:
包含与本模组数据(IBS_Data)的兼容(不可选是否兼容)
包含与"Ents"函数库中获取临时实体数据函数的兼容(可选是否兼容)
包含与"延迟触发函数"的兼容(可选是否兼容)
]]
--[[关于临时实体数据:
对于玩家,跟班和具有实体标签"EntityFlag.FLAG_PERSISTENT"的实体,
其临时数据在关闭游戏后清除
除他们之外的所有实体,其临时数据在离开房间后清除,
故只需兼容他们的临时实体数据
]]

mod.Rewinding = false --正在使用发光沙漏
local DataBackup = nil --游戏状态数据备份
local DelayedFunctionsBackup = nil --延迟触发函数备份
local DelayedFunctions2Backup = nil --延迟触发函数备份

--备份数据
local function BackUpData()
	DataBackup = DeepCopy(mod.IBS_Data)
	DelayedFunctionsBackup = DeepCopy(DelayedFunctions)
	DelayedFunctions2Backup = DeepCopy(DelayedFunctions2)

	--备份临时实体数据
	for _,ent in pairs(Isaac.GetRoomEntities()) do
		local typ = ent.Type
		if (typ == 1) or (typ == 3) or ent:HasEntityFlags(EntityFlag.FLAG_PERSISTENT) then
			local data = ent:GetData()
			data[ModName] = data[ModName] or {}
			data[ModName.." Backup"] = DeepCopy(data[ModName])
		end
	end
end

--还原数据
local function RecoverData()
	if DataBackup ~= nil then
		mod.IBS_Data = DeepCopy(DataBackup)
	end
	if DelayedFunctionsBackup ~= nil then
		DelayedFunctions = DeepCopy(DelayedFunctionsBackup)
	end
	if DelayedFunctions2Backup ~= nil then
		DelayedFunctions2 = DeepCopy(DelayedFunctions2Backup)
	end

	--还原临时实体数据
	for _,ent in pairs(Isaac.GetRoomEntities()) do
		local typ = ent.Type
		if (typ == 1) or (typ == 3) or ent:HasEntityFlags(EntityFlag.FLAG_PERSISTENT) then
			local data = ent:GetData()
			if data[ModName.." Backup"] then
				data[ModName] = DeepCopy(data[ModName.." Backup"])
			end
		end
	end

	--刷新角色属性
	for i = 0, game:GetNumPlayers() -1 do
		local player = Isaac.GetPlayer(i)
		player:AddCacheFlags(CacheFlag.CACHE_ALL)
		player:EvaluateItems()
	end
end

--检测发光沙漏使用
mod:AddCallback(ModCallbacks.MC_USE_ITEM, function()
	local data = mod:GetIBSData('persis')
	if data['rewindCompat'] then --检查是否关闭发光沙漏兼容
		local level = game:GetLevel()
		
		--回溯线 或 非第一层初始房间
		--(在非回溯线第一层初始房间,使用发光沙漏会传到家层而不触发原效果)
		if level:IsAscent() or not (level:GetStage() == 1 and level:GetStartingRoomIndex() == level:GetCurrentRoomIndex()) then
			mod.Rewinding = true
		end
	else
		mod.Rewinding = false
	end	
end, CollectibleType.COLLECTIBLE_GLOWING_HOUR_GLASS)

--离开房间时创建备份
mod:AddPriorityCallback(ModCallbacks.MC_PRE_ROOM_EXIT, -10^7, function()
	local data = mod:GetIBSData('persis')
	if data['rewindCompat'] then --检查是否关闭发光沙漏兼容
		if not mod.Rewinding then	
			BackUpData()
		end
	end	
end)

--进入新房间尝试还原备份
mod:AddPriorityCallback(ModCallbacks.MC_POST_NEW_ROOM, -10^7, function()
	local data = mod:GetIBSData('persis')
	if data['rewindCompat'] then --检查是否关闭发光沙漏兼容
		if mod.Rewinding then --发光沙漏次数用完后,效果会变为沙漏,所以要检测房间帧数
			mod:DelayFunction2(function()
				if mod.Rewinding then
					if (game:GetRoom():GetFrameCount() <= 1) then
						RecoverData()
					end
				end
				mod.Rewinding = false
			end, 1, nil, true)
		else	
			BackUpData()
		end
	else
		mod.Rewinding = false
	end	
end)