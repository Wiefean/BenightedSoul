--设定通用常量

--[[说明书:
新增常量按格式填入对应表即可,不过部分表需要去对应的lua文件里找

新建表请标好注释
]]


--加载
local function LoadScripts(scripts)
    for _, v in ipairs(scripts) do
        include("ibs_scripts.constants."..v)
    end
end

local constants = {
	"callback",
	"item&trinket&pocket",
	"player&challenge",
	"entity"
}
LoadScripts(constants)


local mod = Isaac_BenightedSoul
local json = require("json")

--彩蛋种子黑名单(不能解锁成就的)
mod.EggBlackList = {11,13,16,17,18,19,20,21,24,25,32,33,38,55,57,63,64,65,66,67,68,70,73,77,79}

--诅咒
mod.IBS_Curse = {
moving = 1 << (Isaac.GetCurseIdByName("Curse of the Moving!") - 1),
forgotten = 1 << (Isaac.GetCurseIdByName("Curse of the Forgotten!") - 1),
d7 = 1 << (Isaac.GetCurseIdByName("Curse of D7!") - 1),
binding = 1 << (Isaac.GetCurseIdByName("Curse of the Binding!") - 1),

}

--音效
mod.IBS_Sound = {
devilbonus = Isaac.GetSoundIdByName("恶魔奖励"),
angelbonus = Isaac.GetSoundIdByName("天使奖励"),
ssg_ready = Isaac.GetSoundIdByName("仰望星空冷却完毕"),
ssg_fire = Isaac.GetSoundIdByName("仰望星空发射"),
sword1 = Isaac.GetSoundIdByName("能量剑音效1"),
sword2 = Isaac.GetSoundIdByName("能量剑音效2"),
secretfound = Isaac.GetSoundIdByName("秘密发现"),
falsehood_bjudas_ready = Isaac.GetSoundIdByName("犹大伪忆准备"),

}


--通用函数
do

--即时保存数据
function mod:SaveIBSData()
	if IBS_Data then
		self:SaveData(json.encode(IBS_Data))
	end
end

--读取数据
function mod:GetIBSData(type)
	if IBS_Data then
		if type == "Temp" then
			return IBS_Data.GameState.Temp
		elseif type == "Level" then
			return IBS_Data.GameState.Temp.Level
		elseif type == "Room" then
			return IBS_Data.GameState.Temp.Room		
		elseif type == "Persis" then
			return IBS_Data.GameState.Persis
		elseif type == "Setting" then
			return IBS_Data.Setting
		end	
	end
	
	return nil
end

--检测当前是否继续过游戏
function mod:IsContinue()
	if IBS_Data then
		if IBS_Data.GameState.Temp.IsContinue then
			return true
		end
	end
	
	return false
end

--获取以局内种子为种子的RNG
local IBS_RNG = {}
function mod:GetUniqueRNG(key)
	IBS_RNG[key] = IBS_RNG[key] or RNG()
	return IBS_RNG[key]
end
mod:AddPriorityCallback(ModCallbacks.MC_POST_GAME_STARTED, CallbackPriority.IMPORTANT, function(_,isContinue)
	local seed = Game():GetSeeds():GetStartSeed()
	for k,_ in pairs(IBS_RNG) do
		IBS_RNG[k]:SetSeed(seed, 35)
	end
end)

--延迟触发函数(单位为逻辑帧,30逻辑帧为1秒)
local DelayedFunctions = {}
function mod:DelayFunction(func, frames)
	table.insert(DelayedFunctions, {Function = func, TimeOut = frames})
end
mod:AddCallback(ModCallbacks.MC_POST_UPDATE, function()
    for k,v in pairs(DelayedFunctions) do
        if (v.TimeOut > 0) then
            v.TimeOut = v.TimeOut - 1
        else
			v.Function()
            DelayedFunctions[k] = nil
        end 
    end
end)
	

--检查函数自变量类型
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
local err,mes = mod:CheckArgType(···)
if err then error(mes, 2) end
]]
function mod:CheckArgType(arg, expectedType, typeParaphrase, index, prefix, allowNil)
	local hasError = false
	local argType = type(arg)
	local message = ""

	if arg == nil then
		if not allowNil then hasError = true end
	else
		if argType ~= expectedType then hasError = true end
	end
	
	if hasError then
		expectedType = (typeParaphrase and expectedType.."("..typeParaphrase..")") or expectedType
		index = (index and "#"..tostring(index).." ") or ""
		prefix = (prefix and "["..prefix.."] ") or "[Benighted Soul] "
		message = prefix.."Bad argument "..index..expectedType.." expected, got "..argType
	end
	
	return hasError, message
end

	
end

--函数库
--具体用法在对应lua文件
mod.IBS_Lib = {}

local function SetLib(key, fileName)
	mod.IBS_Lib[key] = include("ibs_scripts.lib."..fileName)
end

SetLib("Translations", "translations")
SetLib("Maths", "maths")
SetLib("Screens", "screens")
SetLib("Pools", "pools")
SetLib("Pickups", "pickups")
SetLib("Ents", "ents")
SetLib("Finds", "finds")
SetLib("Players", "players")
SetLib("Stats", "stats")
SetLib("BigBooks", "bigbooks")



--接口(散落在各个lua文件中,详见模组文件夹中的API文件夹)
mod.IBS_API = {}
