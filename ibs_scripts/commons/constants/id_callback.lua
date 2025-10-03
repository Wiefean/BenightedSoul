--常量,回调函数ID

Isaac_BenightedSoul.IBS_CallbackID = {


--镜子被破坏(弃用)
-- MIRROR_BROKEN = "IBS_CALLBACK_MIRROR_BROKEN",


--变身昧化角色
BENIGHTED = "IBS_CALLBACK_BENIGHED",
--[[可输入参数:角色ID]]
--[[提供参数:玩家(实体), 由角色菜单触发(是否)]]


--检查坚贞之心
CHECK_IRON_HEART = "IBS_CALLBACK_CHECK_IRON_HEART",
--[[提供参数:玩家(实体)]]
--[[说明:
返回true以启用坚贞之心
]]


--贪婪模式波次变动
GREED_WAVE_CHANGE = "IBS_CALLBACK_GREED_WAVE_CHANGE",
--[[提供参数:当前波次(整数)]]


--贪婪模式新波次
GREED_NEW_WAVE = "IBS_CALLBACK_GREED_NEW_WAVE",
--[[提供参数:当前波次(整数)]]


--贪婪模式波次完成状态
GREED_WAVE_END_STATE = "IBS_CALLBACK_GREED_WAVE_END_STATE",
--[[提供参数:状态(整数)]]
--[[说明:
状态:
	0 -- 小怪波次未完成
	1 -- 小怪波次完成
	2 -- Boss波次完成
	3 -- 额外Boss波次完成

该回调在波次结束后触发
]]


--恶魔房和天使房开启状态
DEVIL_ANGEL_OPEN_STATE = "IBS_CALLBACK_DEVIL_ANGEL_OPEN_STATE",
--[[提供参数:恶魔房开启(是否), 天使房开启(是否)]]
--[[说明:
该回调在八层及以前清理最后一个Boss房后触发;
贪婪模式额外波次结束后也会触发
]]


--拾取道具
PICK_COLLECTIBLE = "IBS_CALLBACK_PICK_COLLECTIBLE",
--[[可输入参数:道具ID]]
--[[提供参数:玩家(实体), 道具ID, 道具是否被摸过(是否), 道具(实体)]]
--[[说明:
提供的道具实体一般为空底座
]]

--拾取饰品
PICK_TRINKET = "IBS_CALLBACK_PICK_TRINKET",
--[[可输入参数:饰品ID]]
--[[提供参数:玩家(实体), 饰品ID, 是否为金饰品(是否), 饰品是否被摸过(是否)]]


--拾取口袋物品(不包含药丸)
PICK_CARD = "IBS_CALLBACK_PICK_CARD",
--[[可输入参数:口袋物品ID]]
--[[提供参数:玩家(实体), 口袋物品ID]]


--从道具池中抽取道具之前
PRE_GET_COLLECTIBLE = "IBS_CALLBACK_PRE_GET_COLLECTIBLE",
--[[提供参数:道具池ID, 是否减少在道具池的权重(是否), 种子(整数), 之前的结果(整数)]]
--[[说明:
返回道具ID以改变抽取结果,之后的结果会覆盖之前的结果
没有函数返回过结果时,"之前的结果"为0
]]

--双击按键
DOUBLE_TAP = "IBS_CALLBACK_PLAYER_DOUBLE_TAP",
--[[提供参数:玩家(实体), 按键类型(整数), 按键ID或射击方向(整数)]]
--[[说明:
按键类型:
	0 -- 行走
	1 -- 射击
	2 -- 其他(包括射击按键)

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


--上层渲染
--[[说明:贴图通过该回调进行渲染会显示在HUD上层]]
RENDER_OVERLAY = "IBS_CALLBACK_RENDER_OVERLAY",


--尝试握住主动
TRY_HOLD_ITEM = "IBS_CALLBACK_TRY_HOLD_ITEM",
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
	Timeout -- 限时 [-1] (60为1秒, -1代表不限时)

之后的结果会覆盖之前的结果

对错误道具无效

成功握住主动将触发下面的"正在握住主动"回调
]]


--正在握住主动
HOLDING_ITEM = "IBS_CALLBACK_HOLDING_ITEM",
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

任意函数返回false会结束握住状态,并不再调用之后的函数
限时结束,受伤或进入新房间,也会结束掉握住状态

在握住状态下不能攻击,不能拾取物品,点击丢弃键无效(长按仍有效)

结束握住握住状态时,触发下面的"结束握住主动"回调
]]


--结束握住主动
HOLD_ITEM_END = "IBS_CALLBACK_HOLD_ITEM_END",
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


--是否能收集掉落物
CAN_COLLECT_PICKUP = "IBS_CALLBACK_CAN_COLLECT_PICKUP",
--[[提供参数:掉落物(实体), 收集者(实体 / nil)]]
--[[可输入参数:掉落物类型(Variant)]]
--[[说明:
任意函数返回false表示不能收集,并不再调用之后的函数

"收集者"大部分情况是玩家,但有时不是(比如乞丐宝),还有可能为nil,所以要检测一下

该回调由"Pickus"函数库中的"CanCollect"函数发起,
用于添加收集掉落物的额外条件,
所以没有满足前提条件时,不会发起该回调
]]


--掉落物首次出现
PICKUP_FIRST_APPEAR = "IBS_CALLBACK_PICKUP_FIRST_APPEAR",
--[[提供参数:掉落物(实体)]]
--[[可输入参数:掉落物类型(Variant)]]
--[[说明:
为实现类似"替换下一个出现的掉落物"效果而制作的回调
]]


--捐助乞丐
BUM_DONATION = "IBS_CALLBACK_BUM_DONATION",
--[[提供参数:实体(实体), 掉落物(实体或nil)]]
--[[可输入参数:实体大类(Type)]]
--[[说明:
实体可能是可互动实体或跟班

掉落物在实体为跟班时才不为nil


可互动实体通过检测特定名称的动画播放情况实现,能否兼容模组还得看命名规范
("PayPrize"和"PayNothing")

跟班(类似乞丐朋友)等就需要特殊兼容了

]]


--破坏大便
POOP_BREAK = "IBS_CALLBACK_POOP_BREAK",
--[[提供参数:网格大便(网格实体), 实体大便(实体), 大便类别]]
--[[说明:
第二个参数为实体大便(由大肠杆菌等效果产生)
前两个参数中必定有一个为nil

为实体大便时,中类0为普通大便,1则为金大便,
回调内部会自动设置对应的大便类别

大便类别:
	0 -- 普通
	1 -- 红
	2 -- 玉米粒
	3 -- 金
	4 -- 彩虹
	5 -- 黑
	6 -- 白
	7 -- 巨型大便的一部分
	8 -- 巨型大便的一部分
	9 -- 巨型大便的一部分
	10 -- 巨型大便的一部分

]]

--破坏火堆
FIREPLACE_BREAK = "IBS_CALLBACK_FIREPLACE_BREAK",
--[[提供参数:火堆(实体), 火堆中类(Variant)]]
--[[说明:
在火堆熄灭时触发

支持的火堆中类:
	0 -- 普通
	1 -- 红
	2 -- 蓝
	3 -- 紫
	4 -- 白(虽然原版几乎无法破坏)
]]

}

