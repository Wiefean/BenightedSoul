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
--[[提供参数:玩家(实体), 按键类型(整数), 按键ID或射击方向(整数)]]
--[[说明:
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
--[[可输入参数:道具ID]]
--[[提供参数:道具ID, 玩家(实体), 主动槽(整数), 已充能数, 充能类型(整数)]]
--[[说明:
主动槽:
	0 -- 第一主动
	2 -- 副手主动

充能类型:
	0 -- 普通
	1 -- 自充
	2 -- 特殊

添加的函数中返回包含以下内容的表,则可以尝试在充能未满时使用主动(没有填入项时,将采用中括号内的默认值):
	CanUse -- 是否可使用 [false]
	UseFlags --添加使用标签 [默认已经添加标签"拥有"]

可添加的使用标签(位面):
	UseFlag.USE_NOANIM --不播放举起动画
	UseFlag.USE_NOCOSTUME --不添加服装
	UseFlag.USE_OWNED --拥有(已经自动添加)
	UseFlag.USE_ALLOWWISPSPAWN --允许生成魂火(搭配上面的NOANIM使用) 

直接返回true或false时,只改变CanUse
之后的结果会覆盖之前的结果

已充能数包括了魂心和红心充能
当充能类型为自充时,充能数的单位为逻辑帧数而不是格数

这个回调主要是在道具未满充能时,用来触发使用道具回调的,对零充主动和错误道具无效
在相应使用道具回调(ModCallbacks.MC_USE_ITEM)中应返回{DisCharge = false}
之后的充能消耗和魂火生成要自行添加
]]
TRY_USE_ITEM = "IBS_CALLBACK_TRY_USE_ITEM",


--主动槽渲染
--[[可输入参数:道具ID]]
--[[提供参数:道具ID, 玩家(实体), 主动槽(整数), 主动槽位置(矢量), 主动槽缩放比例(矢量)]]
--[[说明:
主动槽:
	0 -- 第一主动
	1 -- 第二主动
	2 -- 副手主动

第一主动和P1玩家副手主动的贴图缩放比例为Vector(1,1),也就是大小不变
第二主动和非P1玩家副手主动的贴图是缩小一半的,缩放比例为Vector(0.5,0.5)

对错误道具无效

贴图通过该回调进行渲染会显示在HUD上层
]]
ACTIVE_SLOT_RENDER = "IBS_CALLBACK_ACTIVE_SLOT_RENDER",


--尝试握住主动(尚不完善)
--[[可输入参数:道具ID]]
--[[提供参数:道具ID, 玩家(实体), 使用标签(位面), 主动槽(整数)]]
--[[说明:
主动槽:
   -1 -- 无
	0 -- 第一主动
	1 -- 第二主动
	2 -- 副手主动

使用标签:详见 https://moddingofisaac.com/docs/rep/enums/UseFlag.html?h=usefla
		 (生肉)

这个在使用道具回调(ModCallbacks.MC_USE_ITEM)触发的时候触发
当然正在握住一个主动的时候不会触发

添加的函数中返回包含以下内容的表,则可以决定是否握住主动(没有填入项时,将采用中括号内的默认值):
	CanHold -- 是否可握住 [false]
	NoAnim -- 不播放握住和收起道具的动画 [false]
	TimeOut -- 限时 [-1] (60为一秒, -1代表不限时)
	CanCancel -- 允许取消 [false] (在已经握住相同主动的情况下再尝试握住则取消握住)

直接返回true或false时,只改变CanHold
之后的结果会覆盖之前的结果

对错误道具无效

这个回调可以触发下面的"正在握住主动"回调
]]
TRY_HOLD_ITEM = "IBS_CALLBACK_TRY_HOLD_ITEM",


--正在握住主动(尚不完善)
--[[可输入参数:道具ID]]
--[[提供参数:道具ID, 玩家(实体), 使用标签(位面), 主动槽(整数)]]
--[[说明:
主动槽:
   -1 -- 无
	0 -- 第一主动
	1 -- 第二主动
	2 -- 副手主动
	
使用标签:详见 https://moddingofisaac.com/docs/rep/enums/UseFlag.html?h=usefla
		 (生肉)
		 
对错误道具无效

一旦有一个函数返回false,就会结束握住状态

受伤会结束掉握住状态
在握住状态下不能攻击,丢弃键无效

这个回调在握住主动时每秒触发60次,结束握住主动时触发下面的"结束握住主动"回调
]]
HOLDING_ITEM = "IBS_CALLBACK_HOLDING_ITEM",


--结束握住主动(尚不完善)
--[[可输入参数:道具ID]]
--[[提供参数:道具ID, 玩家(实体), 使用标签(位面), 主动槽(整数)]]
--[[说明:
主动槽:
   -1 -- 无
	0 -- 第一主动
	1 -- 第二主动
	2 -- 副手主动
	
使用标签:详见 https://moddingofisaac.com/docs/rep/enums/UseFlag.html?h=usefla
		 (生肉)
		 
对错误道具无效
]]
END_HOLD_ITEM = "IBS_CALLBACK_END_HOLD_ITEM",

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
hypercube = Isaac.GetItemIdByName("Hypercube"), 
defined = Isaac.GetItemIdByName("Defined"), 
chocolate = Isaac.GetItemIdByName("Valentinus Chocolate"),
diamoond = Isaac.GetItemIdByName("Diamoond"),
cranium = Isaac.GetItemIdByName("Weird Cranium"),
ether = Isaac.GetItemIdByName("Ether"),
wisper = Isaac.GetItemIdByName("Wisper"),
bone = Isaac.GetItemIdByName("Bone of Temperance"),
guard = Isaac.GetItemIdByName("Guard of Fortitude"),
v7 = Isaac.GetItemIdByName("V7"),
tgoj = Isaac.GetItemIdByName("The Gospel Of Judas"),


}

--饰品
mod.IBS_Trinket = {
bottleshard = Isaac.GetTrinketIdByName("Bottle Shard"),
dadspromise = Isaac.GetTrinketIdByName("Dad's Promise"),
divineretaliation = Isaac.GetTrinketIdByName("Divine Retaliation"),
toughheart = Isaac.GetTrinketIdByName("Tough Heart"),

}

--口袋物品(不包含药丸)
mod.IBS_Pocket = {
czd6 = Isaac.GetCardIdByName("ibs_czd6"),
goldenprayer = Isaac.GetCardIdByName("ibs_goldenprayer"),

}

--角色
mod.IBS_Player = {
bisaac = Isaac.GetPlayerTypeByName("Benighted Isaac"),
bmaggy = Isaac.GetPlayerTypeByName("Benighted Magdalene"),

}

--挑战
mod.IBS_Challenge = {
bc1 = Isaac.GetChallengeIdByName("BC1 Rolling Destiny"),
bc2 = Isaac.GetChallengeIdByName("BC2 The Fragile"),

}

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
mod.IBS_Lib = {}

local function SetLib(key, fileName)
	mod.IBS_Lib[key] = include("ibs_scripts.lib."..fileName)
end

SetLib("Translations", "translations")
SetLib("Maths", "maths")
SetLib("Pools", "pools")
SetLib("Finds", "finds")
SetLib("Ents", "ents")
SetLib("Players", "players")
SetLib("Stats", "stats")
SetLib("BigBooks", "bigbooks")