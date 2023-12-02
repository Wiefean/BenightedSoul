--常量,回调函数及其提供的参数

Isaac_BenightedSoul.IBS_Callback = {


--镜子被破坏
MIRROR_BROKEN = "IBS_CALLBACK_MIRROR_BROKEN",


--变身昧化角色
--[[可输入参数:角色ID]]
--[[提供参数:玩家(实体), 角色ID]]
BENIGHTED_HENSHIN = "IBS_CALLBACK_BENIGHED_HENSHIN",


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


--从道具池中抽取道具之前
--[[提供参数:道具池ID, 是否减少在道具池的权重(是否), 种子(整数), 之前是否有结果(是否)]]
--[[说明:
返回道具ID以改变抽取结果,之后的结果会覆盖之前的结果
有函数返回过结果后,"之前是否有结果"为true,否则为false
]]
PRE_GET_COLLECTIBLE = "IBS_CALLBACK_PRE_GET_COLLECTIBLE",


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
--[[提供参数:道具ID, 玩家(实体), 主动槽(整数), 已充能数, 满充能数, 充能类型(整数)]]
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
	IgnoreSharpPlug --是否无视锋利插头 [false] (按太快还是会触发)

可添加的使用标签(位面):
	UseFlag.USE_NOANIM --不播放举起动画
	UseFlag.USE_NOCOSTUME --不添加服装
	UseFlag.USE_OWNED --拥有(已经自动添加)
	UseFlag.USE_ALLOWWISPSPAWN --允许生成魂火(搭配上面的NOANIM使用) 

直接返回true或false时,只改变CanUse
之后的结果会覆盖之前的结果

已充能数包括了魂心和红心充能
当充能类型为自充时,充能数的单位为逻辑帧数而不是格数

这个回调主要是在道具未满充能时,用来触发使用道具回调的,对错误道具无效
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


--尝试握住主动
--[[可输入参数:道具ID]]
--[[提供参数:道具ID, 玩家(实体), 使用标签(位面), 主动槽(整数), 正在握住的道具ID]]
--[[说明:
主动槽:
   -1 -- 无
	0 -- 第一主动
	1 -- 第二主动
	2 -- 副手主动

使用标签:详见 https://moddingofisaac.com/docs/rep/enums/UseFlag.html?h=usefla
		 (生肉)

这个在使用道具回调(ModCallbacks.MC_USE_ITEM)触发的时候触发
已经通过这个回调握住一个主动的时则不会触发

添加的函数中返回包含以下内容的表,则可以决定是否握住主动(没有填入项时,将采用中括号内的默认值):
	CanHold -- 是否可握住 [false]
	NoLiftAnim -- 不播放握住道具的动画 [false]
	NoHideAnim -- 不播放收起道具的动画 [false]
	CanCancel -- 允许手动取消 [false] (已经握住对应主动时,再尝试握住则取消)
	AllowHurt -- 受伤不取消 [false]
	AllowNewRoom -- 新房间不取消 [false]
	TimeOut -- 限时 [-1] (60为1秒, -1代表不限时)

直接返回true或false时,只改变CanHold
之后的结果会覆盖之前的结果

对错误道具无效

成功握住主动将触发下面的"正在握住主动"回调
]]
TRY_HOLD_ITEM = "IBS_CALLBACK_TRY_HOLD_ITEM",


--正在握住主动
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
		 
这个回调每秒触发60次

对错误道具无效

一旦有一个函数返回false,就会结束握住状态
限时结束,受伤或进入新房间,也会结束掉握住状态

在握住状态下不能攻击,不能拾取物品,点击丢弃键无效(长按仍有效)

结束握住握住状态时,触发下面的"结束握住主动"回调
]]
HOLDING_ITEM = "IBS_CALLBACK_HOLDING_ITEM",


--结束握住主动
--[[可输入参数:道具ID]]
--[[提供参数:
道具ID, 玩家(实体), 使用标签(位面), 主动槽(整数),
因手动取消而结束(是否), 因限时而结束(是否), 
因受伤而结束(是否), 因进入新房间而结束(是否)
]]
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

