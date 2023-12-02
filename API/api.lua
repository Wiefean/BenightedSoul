--API

--[[说明书 / Read Me:
如果你的模组比该模组先加载,那么标注"!!!CHECK_THE_ORDER!!!"的函数需要在
"ModCallbacks.MC_POST_GAME_STARTED"中调用。
If your mod is loaded before this mod, please call the functions marked "!!!CHECK_THE_ORDER!!!" in
"ModCallbacks.MC_POST_GAME_STARTED".

模组按其名称首字母/符号的顺序来加载,在游戏模组列表中的排序即为加载顺序。
Mods are loaded in the order of the first initial/symbol of their names,
the order can be seen in the list of mods.

"整数"和"浮点数"其实都是"数字",但多数情况下要求输入整数时,不能使用浮点数
Both "Integer" and "Float" are "Number" in fact, but mostly "Float" can't be used when "Integer" is required

30逻辑帧 = 1秒
30 logical frames = 1 second

60渲染帧 = 1秒
60 render frames = 1 second

查看该模组的常量:
To view constants of this mod:
/ibs_scripts/constants
/ibs_scripts/ibs_constants.lua

修改这个文件不会造成任何影响
Modifying this file has no effect
]]


--目录
Contents = {
	[1] = {
			"如何通过这个模组添加一个昧化角色",
			"How to add a benighted character through this mod",
			"/ibs_scripts/entities/benighting.lua"
	},
	[2] = {
			"[道具] 仰望星空",
			"[Collectible] Shooting Stars Gazer",
			"/ibs_scripts/items/items/shooting_stars_gazer.lua"
	},
	[3] = {
			"[道具] 节制之骨",
			"[Collectible] Bone of Temperance",
			"/ibs_scripts/items/items/bone_of_temperance.lua"
	},
	[4] = {
			"[道具] 犹大福音",
			"[Collectible] The Gospel Of Judas",
			"/ibs_scripts/items/items/the_gospel_of_judas.lua"
	},
	[5] = {
			"[道具] 尘埃炸弹",
			"[Collectible] Dusty Bomb",
			"/ibs_scripts/items/items/dustybomb.lua"
	},
	[6] = {
			"[角色] 昧化该隐&亚伯",
			"[Character] Benighted Cain & Abel",
			"/ibs_scripts/players/bcain_and_babel.lua"
	},

}


local MOD = Isaac_BenightedSoul
local IBS_API = MOD.IBS_API


::API1::
--添加可昧化的角色
--Add a character that can become benighted one
--!!!CHECK_THE_ORDER!!!
IBS_API:RegisterBenightableCharacter(id, gfxPath = nil, condition = nil)
--[[
输入: 角色ID (整数), 贴图路径 (字符串), 额外条件 (函数)
Input: character ID (Integer), png path (String), extra condition (Function)

-------------------------------

"贴图路径"指向的贴图尺寸为96x96,用于在光柱展示变身条件
"png path" needs a sprite sized 96x96, which is used to show the condition of the benighted character

"额外条件"是一个带参数[玩家 (实体)]的函数,需要返回true或者false,示例:
"extra condition" is a function with parameter[player (Entity)], returning true or false, e.g.:
local function Condition(player)
	if player:GetBombs() > 0 then
		return true
	end
	return false
end

"额外条件"返回false时,光柱会消失
If the "extra condition" returns false, the light pillar will disappear
]]
--[[注意 / Attention:
这个函数只是添加可昧化的角色,
使其站在光柱下可以触发回调该模组的回调"IBS_CALLBACK_BENIGHED_HENSHIN",
这个回调具有参数[玩家 (实体)]和选择性参数[角色ID (整数)]

It only adds a character that can become benighted one,
making the character can trigger a callback from this mod, "IBS_CALLBACK_BENIGHED_HENSHIN",
which has parameter[player (Entity)] and optional parameter[character ID (Integer)]

因此,使角色'昧化'需要使用该回调,示例:
So,you need to use the callback to 'benight' a character, e.g.:
(昧化以撒 / Benighted Isaac)
mod:AddCallback("IBS_CALLBACK_BENIGHED_HENSHIN", function(_, player)
	player:ChangePlayerType(Isaac_BenightedSoul.IBS_Player.bisaac)
end, PlayerType.PLAYER_ISAAC)
]]



::API2::
local SSG = IBS_API.SSG

---是否为仰望星空的眼泪/激光引物
--Is the first tear or laser from SSG
SSG:IsFirstTearOrLaser(tearOrLaser)
--[[
输入: 眼泪或激光 (实体)
Input: tear or laser (Entity) 

输出: 是否
Output: Bool
]]


--是否为仰望星空的掉落的眼泪
--Is the falling tear from SSG
SSG:IsFallingTear(tear)
--[[
输入: 眼泪 (实体)
Input: tear (Entity) 

输出: 是否
Output: Bool
]]


--是否为仰望星空硫磺火柱
--Is the brimestone pillar from SSG
SSG:IsBrimestonePillar(effect)
--[[
输入: 效果 (实体)
Input: effect (Entity)

输出: 是否
Output: Bool

-------------------------------

硫磺火柱其实是死寂的
Brimestone pillars are originally Hush's
(Type:1000, Variant:101, SubType:0)
]]


--查找仰望星空硫磺火柱
--Find brimestone pillars form SSG
SSG:FindBrimestonePillars(player)
--[[
输入: 玩家 (实体)
Input: player (Entity)

输出: 表
Output: Table

-------------------------------

硫磺火柱的碰撞伤害可以被改变(默认: math.max(player.Damage / 2, 2))
The pillars' collision damage can be changed(Default: math.max(player.Damage / 2, 2))
]]




::API3::
local BOT = IBS_API.BOT

--添加条件,用于判断是否让眼泪获得节制之骨的效果
--Add a condition that determines whether to apply BOT effect to tears
--!!!CHECK_THE_ORDER!!!
BOT:AddTearCondition(condition, name)
--[[
输入: 条件 (函数), 名称 (字符串)
Input: condition (Function), name (String)

-------------------------------

"条件"是一个带输入值(tear)的函数,需要返回true或者false,示例:
"condition" is a function with input(tear), returning true or false, e.g.:
local function Condition(tear)
	if tear.CollisionDamage > 123 then
		return false
	end
	return true
end

"条件"返回false时,眼泪将不会获得节制之骨的效果
If the "condition" returns false, the tear won't gain BOT effect

为了避免冲突,"名称"要有特色
Personalize "name" to avoid conflicts
]]


--眼泪是否有节制之骨的效果
--Does the tear have BOT effect
BOT:TearHasEffect(tear)
--[[
输入: 眼泪 (实体)
Input: tear (Entity) 

输出: 是否
Output: Bool

-------------------------------

这个函数对科技X的激光环同样有效
It also works with laser rings of Tech X
]]


--获取眼泪节制之骨效果的持续时间
--Get the duration of BOT effect
BOT:GetTearTimeOut(tear)
--[[
输入: 眼泪 (实体)
Input: tear (Entity)

输出: 逻辑帧 (整数)
Output: logical frames (Integer)

-------------------------------

这个函数对科技X的激光环同样有效
It also works with laser rings of Tech X

眼泪没有节制之骨的效果则返回0
It returns 0 if the tear doesn't has BOT effect
]]


--为眼泪设置节制之骨效果的持续时间,若没有效果则添加效果
--Set the duration of BOT effect for a tear, and if not having effect then apply effect
BOT:SetTearTimeOut(tear, frames = 210)
--[[
输入: 眼泪 (实体), 逻辑帧 (整数)
Input: tear (Entity), logical frames (Integer)

-------------------------------

这个函数对科技X的激光环同样有效
It also works with laser rings of Tech X
]]


--为眼泪添加节制之骨效果的持续时间,若没有效果则添加效果
--Add the duration of BOT effect for a tear, and if not having effect then apply effect
BOT:AddTearTimeOut(tear, frames)
--[[
输入: 眼泪 (实体), 逻辑帧 (整数)
Input: tear (Entity), logical frames (Integer)

-------------------------------

"逻辑帧"为负数则减少持续时间
Negative "logical frames" decrease the duration

这个函数对科技X的激光环同样有效
It also works with laser rings of Tech X
]]


--让眼泪停滞,若没有节制之骨的效果则添加效果
--Stop a tear, and if not having BOT effect then apply effect
BOT:StopTear(tear)
--[[
输入: 眼泪 (实体)
Input: tear (Entity)

-------------------------------

节制之骨效果的持续时间默认为7秒,结束后则回收眼泪
The duration or BOT effect is 7 seconds as default, and the tear will be recycled

这个函数对科技X的激光环同样有效
It also works with laser rings of Tech X
]]


::API4::
local TGOJ = IBS_API.TGOJ

--查找书本实体
--Find book entities
TGOJ:FindBooks(player, slot = nil)
--[[
输入: 玩家 (实体), 主动槽 (整数)
Input: player (Entity), active slot (Integer)

输出: 表
Output: Table

-------------------------------

"主动槽"对应犹大福音的主动槽位,用于查找相应的书本实体
"active slot" is the active slot of TGOJ and used to find the corresponding book entities

若没有输入"主动槽",则书本实体没有主动槽位的限制
If not "active slot", book entities are not restricted by active slot

书本的碰撞伤害可以被改变(默认: 6.5)
The books' collision damage can be changed(Default: 6.5)
]]


--生成书本实体
--Spawn a book entity
TGOJ:SpawnBook(player, spawnPos, targetPos = spawnPos, timeOut = 240, flyingDMG = 6.5)
--[[
输入: 玩家 (实体), 生成位置 (矢量), 目标位置 (矢量), 持续逻辑帧 (整数), 飞行时碰撞伤害 (浮点数)
Input: player (Entity), Vector, Vector, logical frames (Integer), collision DMG when flying (Float)

输出: 效果 (实体)
Output: effect (Entity)

-------------------------------

书本的碰撞伤害可以被改变(默认: 6.5)
The book's collision damage can be changed(Default: 6.5)
]]


--获取书本数据
--Get the data of the book entity
TGOJ:GetBookData(effect)
--[[
输入: 效果 (实体)
Input: effect (Entity)

输出: 数据 (表)
Output: data (Table)

-------------------------------

"数据"可以被改动
"data" can be changed

data = {
	State, -- 状态 (字符串) / (String)
	TimeOut, -- 持续时间 (整数) / (Integer)
	Slot, -- 主动槽 (整数) / (Integer)
	TargetPosition -- 目标位置 (矢量) / (Vector)
}

状态包括:
"State" includes:
	"Go" -- 出发
	"Opening" -- 正在打开
	"Idle" -- 静止
	"Recycle" -- 回收

"持续时间"只有在"状态"为"静止"时减少,为0时"状态"变为"回收"
"TimeOut" decreases only when "State" is "Idle", and when it is 0, "State" will become "Recycle"

"主动槽"对应犹大福音的主动槽位,-1表示无
"Slot" is the active slot of TGOJ, and -1 indicates none
]]


--书本实体是否在飞行
--Is the book entity flying
TGOJ:IsBookFlying(effect)
--[[
输入: 效果 (实体)
Input: effect (Entity)

输出: 是否
Output: Bool
]]



::API5::
local DB = IBS_API.DB

--炸弹是否有尘埃炸弹效果
--Does the bomb has DB effect
DB:IsDustyBomb(bomb)
--[[
输入: 炸弹 (实体)
Input: bomb (Entity)

输出: 是否
Output: Bool
]]


--设置尘埃炸弹效果
--Apply DB effect to a bomb
DB:ApplyEffect(bomb, noCostume)
--[[
输入: 炸弹 (实体), 不更改外观 (是否)
Input: bomb (Entity), do not change the bomb's costume (Bool)

输出: 是否
Output: Bool
]]


--移除尘埃炸弹效果
--Remove DB effect from a bomb
DB:RemoveEffect(bomb)
--[[
输入: 炸弹 (实体)
Input: bomb (Entity)
]]



::API6::
local BCBA = {}

--添加处于副角色状态时不临时移除的主动道具
--Add an active item to whitelist so that it won't be temporarily removed from second player
IBS_API.BCBA:AddExcludedActiveItem(item)
--[[
输入: 道具ID (整数)
Input: collectible ID (Integer) 
]]


--任意主副角色拥有道具
--Is main or second player has the collectible
BCBA:AnyHasCollectible(player, item)
--[[
输入: 玩家 (实体), 道具ID (整数)
Input: player (Entity), collectible ID (Integer)

输出: 是否
Output: Bool
]]

--获取昧化该隐或亚伯的匹配玩家
--Get another player matched with benighted cain or abel
BCBA:GetOtherTwin(player)
--[[
输入: 玩家 (实体)
Input: player (Entity) 

输出: 玩家 (实体)
Output: player (Entity)

-------------------------------

没有相关数据时,返回nil
If no relevant data, it returns nil

没有找到对应玩家时,返回nil
If can't find the player, it returns nil

由于特性,输入和输出的玩家类型不一定需要是昧化该隐&亚伯
Due to the feature, the input or output player's type need unnecessarily to be benighted cain or abel
]]


--昧化该隐或亚伯是否为主玩家
--Is benighted cain or abel main player
BCBA:IsMainPlayer(player)
--[[
输入: 玩家 (实体)
Input: player (Entity) 

输出: 是否为主玩家 (是否)
Output: Is main player (Bool)

-------------------------------

没有相关数据时,返回nil
If no relevant data, it returns nil

由于特性,输入的玩家类型不一定需要是昧化该隐&亚伯
Due to the feature, the input player's type need unnecessarily to be benighted cain or abel
]]


--昧化该隐或亚伯是否为副玩家,用法同上
--Is benighted cain or abel second player, similar to last function
BCBA:IsSecondPlayer(player)

