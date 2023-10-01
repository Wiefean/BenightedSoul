--中文

--[[说明书:
新增介绍按格式填入对应表即可
]]

local mod = Isaac_BenightedSoul
local IBS_Item = mod.IBS_Item
local IBS_Trinket = mod.IBS_Trinket
local IBS_Pocket = mod.IBS_Pocket
local IBS_Player = mod.IBS_Player

local LANG = "zh_cn"

--------------------------------------------------------
-----------------------角色长子权-----------------------
--------------------------------------------------------
local birthrightEID = {

[IBS_Player.bisaac] = {
	name = "昧化以撒",
	info = "飞行#恶魔/天使房中道具选择 + 1"
},

[IBS_Player.bmaggy] = {
	name = "昧化抹大拉",
	info = "坚贞之心自然恢复量翻倍"
},

[IBS_Player.bjudas] = {
	name = "昧化犹大",
	info = "{{Collectible"..(IBS_Item.tgoj).."}} 吸收敌弹时返还泪弹"
},


}
--------------------------------------------------------
--------------------------道具--------------------------
--------------------------------------------------------
local itemEID={

[IBS_Item.ld6]={
	name="光辉六面骰",
	info="无需满充能即可使用"..
		 "#以房间内道具平均品质重置道具"..
		 "#消耗的充能由平均品质决定:"..
		 "#{{Quality0}} 及以下: 0"..
		 "#{{Quality1}} : 1"..
		 "#{{Quality2}} : 2"..
		 "#{{Quality3}} : 3"..
		 "#{{Quality4}} 及以上 : 6",
	virtue="内层魂火，概率发射圣光眼泪#每消耗1充能生成1魂火",
	belial="品质可能上下浮动",
	seijaNerf="使用需要消耗{{HalfSoulHeart}}半魂心或{{HalfBlackHeart}}半黑心，且充能消耗变为6",
	player={[IBS_Player.bisaac]="以{{HalfSoulHeart}}半魂心或{{HalfBlackHeart}}半黑心代替缺少的充能1格"}
},

[IBS_Item.nop]={
	name="拒绝选择",
	info="不再单选物品",
	seijaNerf="获得遗忘诅咒",
	player={
		[PlayerType.PLAYER_THELOST]="若场上只有{{Player10}}或{{Player31}}，恶魔交易免费",
		[PlayerType.PLAYER_THELOST_B]="若场上只有{{Player10}}或{{Player31}}，恶魔交易免费",
		[PlayerType.PLAYER_JACOB] = "额外获得{{Collectible249}}",
		[PlayerType.PLAYER_ESAU] = "额外获得{{Collectible414}}"
	}
},

[IBS_Item.d4d]={
	name="四维骰",
	info="以相对方位改变离角色最近道具的ID#左加;右减;上翻倍;下减半",
	virtue="4个外层魂火，不发射眼泪",
	belial="没有对应道具时，以{{Collectible51}}五芒星代替",
	seijaNerf="按随机方位重置",
},

[IBS_Item.ssg]={
	name="仰望星空",
	info="双击发射一颗特殊眼泪，命中目标时生成落泪区"..
		 "#4秒冷却"
},

[IBS_Item.waster]={
	name="剩饼",
	info="即将受伤时，25%概率获得{{HalfSoulHeart}}半魂心，之后在本房间获得{{Collectible108}}圣饼效果"
},

[IBS_Item.envy]={
	name="女疾女户",
	info="↓ {{Speed}}移速 - 0.15#"..
		 "#↓ {{Tears}}射速修正 - 0.06"..
		 "#↑ {{Damage}}伤害 + 1"..
		 "#6%概率替换之后的道具(可叠加，最多60%)"
},

[IBS_Item.gheart]={
	name="发光的心",
	info="在清理房间后充能，可充满两次"..
		 "#移除1个{{BrokenHeart}}碎心，若没有，获得1{{SoulHeart}}魂心",
	virtue="内层魂火，概率发射圣光眼泪",
	greed="贪婪模式:波次开始时也会充能",
	belial="无{{BrokenHeart}}碎心时，效果改为获得1{{BlackHeart}}黑心",
	player={[IBS_Player.bmaggy]="同时恢复20可超上限的坚贞之心(切换房间后移除超出上限部分)"}
},

[IBS_Item.pb]={
	name="紫色泡泡水",
	info="随机获得一项以下效果:"..
		 "#↓ {{Speed}}移速 - 0.02"..
		 "#↑ {{Tears}}射速修正 + 0.06"..
		 "#↑ {{Damage}}伤害 + 0.1"..
		 "#↑ {{Range}}射程 + 0.15"..
		 "#↓ {{Shotspeed}}弹速 - 0.03"..
		 "#丢弃该道具后，在下一层重置属性变动"..
		 "#使用24次之后，不会重置",
	virtue="内层魂火，概率发射眩晕眼泪",
	belial="无特殊效果",		 
},

[IBS_Item.cmantle]={
	name="诅咒屏障",
	info="强占主动槽，除非持有{{Collectible260}}黑蜡烛或{{Collectible584}}美德之书"..
		 "#直接使用无效果"..
		 "#即将受伤时，消耗2充能，免疫伤害，并进入影遁状态",
	virtue="每用影遁杀死一个敌人生成一个单房间魂火#阻止该道具强占主动槽",
	belial="无特殊效果",
	player={[PlayerType.PLAYER_JUDAS_B]="影遁同样会给予{{Damage}}伤害提升"}

},

[IBS_Item.hypercube]={
	name="超立方",
	info="无记录时，记录距离最近的道具，并将其移出道具池"..
		 "#已有记录时，将房间内的道具重置为记录的道具"..
		 "#所有{{Collectible"..(IBS_Item.hypercube).."}}".."超立方共享记录",
	virtue="外层魂火，发射追踪眼泪",
	belial="无特殊效果"
},

[IBS_Item.defined]={
	name="已定义",
	info="无需满充能即可使用"..
		 "#传送至选定类型的房间"..
		 "#双击 "..EID.ButtonToIconMap[ButtonAction.ACTION_MAP].." 地图键以切换类型",
	virtue="无魂火#充能消耗 - 1",
	belial="充能消耗 - 1",
	seijaNerf="25%变为{{Collectible324}}未定义"
},

[IBS_Item.chocolate]={
	name="瓦伦丁巧克力",
	info="{{SoulHeart}} 魂心 + 2"..
		 "#双击发射一颗特殊眼泪，将命中的非Boss敌人变为友好状态，但其生命减半"..
		 "#两次机会，进入新房间重置"
},

[IBS_Item.diamoond]={
	name="钻石",
	info="{{Burning}} 33%火焰眼泪"..
		 "#{{Slow}} 33%减速眼泪"..
		 "#{{Luck}} 幸运不会影响概率"..
		 "#{{Freezing}} 冰冻同时被点燃和减速的非Boss敌人"..
		 "#免疫爆炸伤害"
},

[IBS_Item.cranium]={
	name="奇怪的头骨",
	info="进入新层时，角色获得{{Player10}}游魂诅咒"..
		 "#进入{{BossRoom}}Boss房后恢复，并获得1{{BlackHeart}}黑心",
	seijaBuff="诅咒持续期间，进入有敌人的房间获得10秒护盾"
},

[IBS_Item.ether]={
	name="以太之云",
	info="受伤后在本房间获得飞行，并降下圣光"..
		 "#圣光造成角色伤害的2倍穿甲伤害"..
		 "#圣光降落频率随角色在本房间的受伤次数递增",
	trans={"LEVIATHAN", "ANGEL"}
},

[IBS_Item.wisper]={
	name="魂火之灵",
	info="抵挡敌弹的环绕物跟班"..
		 "#造成角色伤害3倍的碰撞伤害"..
		 "#击杀敌人有30%概率生成普通魂火({{Luck}}幸运7:100%)",
	trans={"ANGEL"}
},

[IBS_Item.bone]={
	name="节制之骨",
	info="幽灵眼泪"..
		 "#穿透眼泪"..
		 "#角色眼泪不再具有垂直加速度"..
		 "#双击 "..EID.ButtonToIconMap[ButtonAction.ACTION_DROP].." 丢弃键可以使角色眼泪静止"..
		 "#7秒后自动回收眼泪"
},

[IBS_Item.guard]={
	name="坚韧面罩",
	info="抵挡面前的敌弹"..
		 "#受到敌弹伤害时，清除所有敌弹"..
		 "#受到的爆炸伤害降低至半心"
},

[IBS_Item.v7]={
	name="美德七面骰",
	info="在当前房间召唤一个友好的以下小Boss："..
		 "#节制"..
		 "#坚韧",
	virtue="普通魂火",
	belial="无特殊效果",		 
},

[IBS_Item.tgoj]={
	name="犹大福音",
	info="扔出一本能吸收敌弹的书，飞行期间具有碰撞伤害"..
		 "#充能未满时使用则回收书"..
		 "#吸收一定敌弹后，生成{{Collectible634}}炼狱恶鬼的裂缝",
	virtue="吸收一定敌弹后，生成魂火",
	belial="吸收敌弹将提供临时{{Damage}}伤害提升",
	player={[IBS_Player.bjudas]="吸收敌弹将提供临时{{Damage}}伤害提升"},
	trans={"BOOKWORM"}
},

[IBS_Item.nail]={
	name="备用钉子",
	info="发射一枚钉子，对命中的目标造成2.5秒的石化和虚弱效果"..
		 "#造成伤害可以加快充能",
	virtue="不发射眼泪的中层魂火#单房间魂火",
	belial="钉子附带火焰效果"
},

[IBS_Item.superb]={
	name="核能电罐",
	info="造成一定伤害后，为主动道具充能，可为额外充能条充能"..
		 "#受伤后，进入蓄力状态，不断消耗额外充能条的充能"..
		 "#蓄力伴随激光、毒气、水迹，完成后爆炸，没完成则取消",
	seijaNerf="爆炸会伤害自己"
},

[IBS_Item.dreggypie]={
	name="掉渣饼",
	info="{{Heart}} 获得1心之容器，治疗1红心"..
		 "#↑ {{Tears}}射速修正 + 5，并不断衰减"..
		 "#除了{{Player20}}以扫，{{Collectible"..(IBS_Item.dreggypie).."}} + {{Collectible621}} = {{Collectible619}}"
},

[IBS_Item.bonyknife]={
	name="骨刀",
	info="在当前房间中，{{Damage}}攻击力降低25%(不叠加)，获得{{Collectible114}}妈妈的菜刀效果",
	virtue="不发射眼泪的内层魂火#熄灭时，触发该道具的效果",
	belial="刀附带火焰"	
},

[IBS_Item.circumcision]={
	name="割礼",
	info="↓ {{Speed}}移速 - 0.7"..
		 "#↑ {{Tears}}射速翻倍"..
		 "#↑ {{Luck}}幸运 + 2"	
},

[IBS_Item.cheart]={
	name="诅咒之心",
	info="{{CurseRoom}} 诅咒房中额外生成一个血量代价的道具"
},

[IBS_Item.redeath]={
	name="死亡回放",
	info="角色每次死亡都会获得:"..
		 "#↑ {{Speed}}移速 + 0.1"..
		 "#↑ {{Tears}}射速 + 0.35"..
		 "#↑ {{Damage}}伤害 + 1",
	seijaBuff="每层获得一个{{Card89}} 拉萨路的魂石"
},

[IBS_Item.dustybomb]={
	name="尘埃炸弹",
	info="+ 3{{Bomb}}炸弹"..
		 "#角色炸弹一触即发"..
		 "#当前房间，角色炸弹第三次爆炸时，消灭房间内的所有非Boss敌人，Boss失去15%生命"
},

[IBS_Item.nm]={
	name="金针菇",
	info="↑ {{Speed}}速度 + 0.3"..
		 "#↑ {{Tears}}射速 + 0.7"..
		 "#↑ {{Range}}射程 + 1.25"..
		 "#攻击时，每秒有6%概率({{Luck}}幸运5:1%)丢弃该道具，且5秒内不能拾取",
	trans={"MUSHROOM", "POOP"},
	player={[PlayerType.PLAYER_BLUEBABY_B]="丢弃的同时生成一个便便掉落物"}
},

[IBS_Item.minihorn]={
	name="小小角恶魔",
	info="攻击6~13秒后，在角色位置生成一个伤害为60的小即爆炸弹",
	seijaBuff="改为生成红炸弹，生成所需时间固定为3秒"
},

[IBS_Item.woa]={
	name="亚波伦之翼",
	info="↑ {{Shotspeed}}弹速 + 0.16"..
		 "#除{{Shotspeed}}弹速外，所有属性获得{{Shotspeed}}弹速 - 1 的倍率，最低100%，最高150%",
	player={[PlayerType.PLAYER_APOLLYON] = "飞行",
			[PlayerType.PLAYER_APOLLYON_B] = "飞行",
	}
},

[IBS_Item.momscheque]={
	name="妈妈的支票",
	info="直接使用无效果"..
		 "#+ 3{{Coin}}硬币"..
		 "#↑ + 1{{Luck}}幸运"..	
		 "#每层获得7{{Coin}}硬币",
	trans={"MOM"}
},

[IBS_Item.ffruit]={
	name="禁断之果",
	info="!!! {{ColorYellow}}一次性{{CR}}"..
		 "#将品质{{Quality1}}或{{Quality3}}的道具移出道具池"..
		 "#本局不再遇到{{CurseUnknown}}未知诅咒和{{CurseBlind}}致盲诅咒",
	virtue="内层魂火，发射毒性眼泪",
	belial="移除角色身上品质{{Quality1}}或{{Quality3}}的道具，每移除一个提升一定{{Damage}}伤害"
},

[IBS_Item.sword]={
	name="紫电护主之刃",
	info="自动攻击"..
		 "#抵挡敌弹"..
		 "#{{Collectible536}} 不可献祭",
	seijaNerf="没有目标时，攻击角色"
},

}
--------------------------------------------------------
--------------------------饰品--------------------------
--------------------------------------------------------
local trinketEID={

[IBS_Trinket.bottleshard]={
	name="酒瓶碎片",
	info="10%概率令受伤的敌人额外受到3点伤害，并进入流血状态",
	mult={
		numberToMultiply = 10,
		maxMultiplier = 3,
	}	
},

[IBS_Trinket.dadspromise]={
	name="爸爸的约定",
	info="{{BossRoom}} 在进入新层后的45 + 15x楼层数秒内完成Boss房，生成1个{{Card49}}骰子碎片",
	mult={findReplace = {"15","20","25"}}	
},

[IBS_Trinket.divineretaliation]={
	name="神圣反击",
	info="10%概率免疫泪弹伤害#被泪弹击中时，将周围的所有泪弹变为火焰",
	mult={
		numberToMultiply = 10,
		maxMultiplier = 3,
	}	
},

[IBS_Trinket.toughheart]={
	name="硬的心",
	info="10%概率免疫伤害#受伤时，免伤概率增加15%，直到下一次免伤#对自伤无效",
	mult={
		numberToMultiply = 10,
		maxMultiplier = 3,
	}	
},

[IBS_Trinket.chaoticbelief]={
	name="混沌信仰",
	info="进入新层时，视为一次恶魔交易，天使房转换率 + 50%"..
		 "#{{Heart}} 红心受伤不再影响恶魔/天使房开启率",
	mult={
		numberToMultiply = 50,
		maxMultiplier = 2,
	}	
},

[IBS_Trinket.thronyring]={
	name="荆棘指环",
	info="受伤时，9%概率触发以下的一项"..
		 "#{{BrokenHeart}} 50%消除一个碎心，没有则触发下一项"..
		 "#{{SoulHeart}} 25%获得一个魂心"..
		 "#{{AngelRoom}} 15%天使房转换率 + 10%"..
		 "#{{EternalHeart}} 10%获得一个永恒之心",
	mult={
		numberToMultiply = 9,
		maxMultiplier = 3,
	}	
},

}
--------------------------------------------------------
--------------------------卡牌--------------------------
--------------------------------------------------------
local cardEID={

[IBS_Pocket.czd6] = {
	name="六面骰黄金典藏版",
	info="重置道具#90%不消失，每使用一次概率降低10%(影响持续一整局)"
},

[IBS_Pocket.goldenprayer] = {
	name="金色祈者",
	info="获得30不会自动恢复的坚贞之心#消耗后，完成下一个{{BossRoom}}Boss房会再次生成该卡牌",
	mimic={charge = 6, isRune = false},
	player={[IBS_Player.bmaggy]="效果改为恢复30可超上限的坚贞之心(切换房间后移除超出上限部分)"}
},

}
--------------------------------------------------------


--返回表
return {
	BirthrightEID = birthrightEID,
	ItemEID = itemEID,
	TrinketEID = trinketEID,
	CardEID = cardEID
}