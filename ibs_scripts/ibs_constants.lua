--设定通用常量

--[[说明书:
新增常量按格式填入对应表即可

新建表请标好注释
]]

local mod = Isaac_BenightedSoul
local json = require("json")

--彩蛋种子黑名单(不能解锁成就的)
mod.EggBlackList = {11,13,16,17,18,19,20,21,24,25,32,33,38,55,57,63,64,65,66,67,68,70,73,77,79}


--回调函数及其提供的参数
mod.IBS_Callback = {

--贪婪模式新波次
--[[提供参数:波次(整数)]]
GREED_NEW_WAVE = "IBS_CALLBACK_GREED_NEW_WAVE",


--贪婪模式波次完成
--[[
提供参数:状态(整数)
状态:
	1 -- 小怪波次完成
	2 -- Boss波次完成
	3 -- 额外Boss波次完成
]]
GREED_WAVE_END_STATE = "IBS_CALLBACK_GREED_WAVE_END_STATE",


--拾取道具
--[[可输入参数:道具ID]]
--[[提供参数:玩家(实体), 道具ID, 道具是否被摸过(是否)]]
PICK_COLLECTIBLE = "IBS_CALLBACK_PICK_COLLECTIBLE",


--获得道具
--[[可输入参数:道具ID]]
--[[提供参数:玩家(实体), 道具ID, 数量, 道具是否被摸过(是否), 是否正在举起该道具(是否)]]
GAIN_COLLECTIBLE = "IBS_CALLBACK_GAIN_COLLECTIBLE",


--失去道具
--[[可输入参数:道具ID]]
--[[提供参数:玩家(实体), 道具ID, 数量]]
LOSE_COLLECTIBLE = "IBS_CALLBACK_LOSE_COLLECTIBLE",


--拾取饰品
--[[可输入参数:饰品ID]]
--[[提供参数:玩家(实体), 饰品ID, 是否为金饰品(是否), 饰品是否被摸过(是否)]]
PICK_TRINKET = "IBS_CALLBACK_PICK_TRINKET",


--拾取口袋物品(不包含药丸)
PICK_CARD = "IBS_CALLBACK_PICK_CARD",


--双击按键
--[[
提供参数:玩家(实体), 按键类型(整数), 按键ID或射击方向(整数)
按键类型:
	0 -- 行走
	1 -- 射击
	2 -- 其他

按键ID(类型为行走或其他时使用):
	0 -- 左
	1 -- 右
	2 -- 上
	3 -- 下
	8 -- 炸弹
	9 -- 主动
	10 -- 副主动
	11 -- 丢弃/切换
	13 -- 展开地图
	
射击方向(类型为射击时使用):	
	0 -- 左
	1 -- 上
	2 -- 右
	3 -- 下
]]
PLAYER_DOUBLE_TAP = "IBS_CALLBACK_PLAYER_DOUBLE_TAP",


--尝试使用主动
--[[
提供参数:道具ID, 玩家(实体), 主动槽(整数), 已充能数, 满充能数, 充能类型(整数)
可输入参数:道具ID
主动槽:
	0 -- 第一主动
	2 -- 副手主动

充能类型:
	0 -- 普通
	1 -- 自充
	2 -- 特殊

已充能数包括魂心/红心充能

在充能类型为自充时,充能单位是逻辑帧而不是格,30逻辑帧为1秒

添加的函数中返回包含以下内容的表,则可以尝试在充能未满时使用主动(没有填入项时,将采用中括号内的默认值):
	CanUse -- 是否可使用 [false]
	DisCharge --可使用时消耗的充能数 [默认为所有已充能数]
	EvenFullCharge --即使充能已满,仍然通过该回调消耗充能和使用主动 [false]
	UseFlags --添加使用标签 [默认已经添加标签"拥有"]
	AutoCheckVirtue --是否自动尝试生成魂火 [true]
	IncludeSpecial --是否包括特殊充能主动 [false]
	IgnoreSoulCharge --忽略魂心充能(用于消耗充能) [false]
	IgnoreBloodCharge --忽略红心充能(用于消耗充能) [false]

可添加的使用标签(标签为位运算形式):
	UseFlag.USE_NOANIM --不播放举起动画
	UseFlag.USE_NOCOSTUME --不添加服装
	UseFlag.USE_OWNED --拥有(已经自动添加)
	UseFlag.USE_ALLOWWISPSPAWN --生成魂火(一般在AutoCheckVirtue为false时使用) 
	
{CanUse, DisCharge, EvenFullCharge, UseFlags, AutoCheckVirtue, IncludeSpecial, IgnoreSoulCharge, IgnoreBloodCharge}

直接返回true或false时,将改变CanUse,其他项使用默认值
一旦CanUse为true,将不再检测之后的函数返回的值

通过该回调使用主动并不会跳过而是跳转使用道具回调(MC_USE_ITEM)
所以当EvenFullCharge为true时,在相应使用道具回调(MC_USE_ITEM)中应返回{DisCharge = false},
否则会消耗两次充能,使用两次主动
]]
TRY_USE_ITEM = "IBS_CALLBACK_TRY_USE_ITEM",

}

--道具
mod.IBS_Item = {
ld6 = Isaac.GetItemIdByName("The Light D6"),
nop = Isaac.GetItemIdByName("No Options"),
d4d = Isaac.GetItemIdByName("D4D"),
ssg = Isaac.GetItemIdByName("Shooting Stars Gazer"),
waster = Isaac.GetItemIdByName("The Waster"),
envy = Isaac.GetItemIdByName("Ennnnnnvyyyyyy"),
gheart = Isaac.GetItemIdByName("Glowing Heart"),
pb = Isaac.GetItemIdByName("Purple Bubbles"),
cmantle = Isaac.GetItemIdByName("Cursed Mantle"), 

}

--饰品
mod.IBS_Trinket = {
bottleshard = Isaac.GetTrinketIdByName("Bottle Shard"),
dadspromise = Isaac.GetTrinketIdByName("Dad's Promise"),

}

--口袋物品(不包含药丸)
mod.IBS_Pocket = {
czd6 = Isaac.GetCardIdByName("ibs_czd6"),

}

--角色
mod.IBS_Player = {
bisaac = Isaac.GetPlayerTypeByName("Benighted Isaac"),
bmaggy = Isaac.GetPlayerTypeByName("Benighted Magdalene"),

}

--挑战
mod.IBS_Challenge = {
bc1 = Isaac.GetChallengeIdByName("BC1 Rolling Destiny"),

}

--音效
mod.IBS_Sound = {
devilbonus = Isaac.GetSoundIdByName("恶魔奖励"),
angelbonus = Isaac.GetSoundIdByName("天使奖励"),
ssg_ready = Isaac.GetSoundIdByName("仰望星空冷却完毕"),
ssg_fire = Isaac.GetSoundIdByName("仰望星空发射"),

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
	if not isContinue then
		local seed = Game():GetSeeds():GetStartSeed()	
		for k,_ in pairs(IBS_RNG) do
			IBS_RNG[k]:SetSeed(seed, 35)
		end
	end
end)

end

--函数库
--具体用法在对应lua文件
mod.IBS_Lib = {
Translations = include("ibs_scripts.lib.translations"),
Maths = include("ibs_scripts.lib.maths"),
Pools = include("ibs_scripts.lib.pools"),
Finds = include("ibs_scripts.lib.finds"),
Players = include("ibs_scripts.lib.players"),
Stats = include("ibs_scripts.lib.stats"),
BigBooks = include("ibs_scripts.lib.bigbooks"),
Ents = include("ibs_scripts.lib.ents"),

}