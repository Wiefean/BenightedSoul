--中文

--[[说明书:
新增介绍按格式填入对应表即可
]]

local mod = Isaac_BenightedSoul
local IBS_PlayerID = mod.IBS_PlayerID
local IBS_ItemID = mod.IBS_ItemID
local IBS_TrinketID = mod.IBS_TrinketID
local IBS_PocketID = mod.IBS_PocketID
local IBS_SlotID = mod.IBS_SlotID

local LANG = 'zh_cn'

--------------------------------------------------------
--------------------------角色--------------------------
--------------------------------------------------------
local playerEID = {

[IBS_PlayerID.BIsaac] = {
	name='昧化以撒',
	info='跳过{{AngelRoom}}天使房会使下一层的{{TreasureRoom}}宝箱房变为{{DevilRoom}}恶魔房'..
		 '#跳过{{DevilRoom}}恶魔房会使下一层的{{Shop}}商店变为{{AngelRoom}}天使商店',
	br = '飞行#恶魔/天使房中道具选择 + 2'..
		 '#恶魔房/天使商店不再替换{{TreasureRoom}}宝箱房/{{Shop}}商店，而是{{SecretRoom}}隐藏房/{{SuperSecretRoom}}超级隐藏房 ({{GreedMode}}贪婪模式下不生效)'
},

[IBS_PlayerID.BMaggy] = {
	name='昧化抹大拉',
	info='心上限为7'..
		 '#具有可承伤的{{IBSIronHeart}}坚贞之心'..
		 '#蓄力释放震荡波，命中敌人可恢复{{IBSIronHeart}}坚贞之心'..
		 '#击杀7宗罪以获得一些增强效果'..
		 '#{{MiniBoss}}小头目房将替换{{SacrificeRoom}}献祭房',
	br='{{IBSIronHeart}} 震荡波命中时，坚贞之心恢复量翻倍'
},

[IBS_PlayerID.BCain] = {
	name='昧化该隐',
	info='主副角色相接触以切换，过久未切换会使副角色持续受伤'..
		 '#按住'..EID.ButtonToIconMap[ButtonAction.ACTION_MAP]..'地图键使主角色立定'..
		 '#按住'..EID.ButtonToIconMap[ButtonAction.ACTION_DROP]..'丢弃键使副角色立定'..
		 '#副角色无视大部分伤害且能穿过障碍物，但移动和射击操作反转'..
		 '#死亡时任意主副角色存活，则变为鬼魂玩家',
	br='副角色操作不再反转'
},

[IBS_PlayerID.BAbel] = {
	name='昧化亚伯',
	info='主副角色相接触以切换，过久未切换会使副角色持续受伤'..
		 '#按住'..EID.ButtonToIconMap[ButtonAction.ACTION_MAP]..'地图键使主角色立定'..
		 '#按住'..EID.ButtonToIconMap[ButtonAction.ACTION_DROP]..'丢弃键使副角色立定'..
		 '#副角色无视大部分伤害且能穿过障碍物，但移动和射击操作反转'..
		 '#死亡时任意主副角色存活，则变为鬼魂玩家',
	br='副角色操作不再反转'
},

[IBS_PlayerID.BJudas] = {
	name='昧化犹大',
	br='{{Collectible'..(IBS_ItemID.TGOJ)..'}} 持续时间延长至13秒，吸收敌弹时返还泪弹'
},

[IBS_PlayerID.BXXX] = {
	name='昧化???',
	info='↑ 每个{{IBSMemory}}记忆碎片提供额外1%{{Tears}}射速'..
		 '#按下'..EID.ButtonToIconMap[ButtonAction.ACTION_DROP]..'丢弃键以切换'..EID.ButtonToIconMap[ButtonAction.ACTION_BOMB]..'炸弹键的效果：'..
		 '#储存/使用伪忆'..
		 '#消耗21{{IBSMemory}}记忆碎片生成伪忆三选一'..
		 '#将周围的一些掉落物分解为{{IBSMemory}}记忆碎片'..
		 '#使用{{Bomb}}炸弹',
	br='伪忆球上限提升至6'
},

[IBS_PlayerID.BEve] = {
	name='昧化夏娃',
	info='具有能阻挡敌弹和伤害敌人的跟班'..
		 '#使用次要主动{{Collectible'..(IBS_ItemID.MyFruit)..'}}我果后，将其替换为{{Collectible'..(IBS_ItemID.MyFault)..'}}我过，并失去那个跟班'..
		 '#在新层换回{{Collectible'..(IBS_ItemID.MyFruit)..'}}我果，并刷新跟班'..
		 '#!!! {{Collectible'..(IBS_ItemID.MyFruit)..'}}我果耗尽后不再换回',
	br='{{Collectible'..(IBS_ItemID.MyFruit)..'}} 我果的最大充能固定为0#{{Collectible'..(IBS_ItemID.MyFault)..'}} 我过在即将受到惩罚性伤害时自动触发'
},

[IBS_PlayerID.BSamson] = {
	name='昧化参孙',
	info='不能拾取饰品和口袋物品，但可以购买塔罗牌'..
		 '#清理{{BossRoom}}头目房后，生成塔罗牌'..
		 '#{{IBSSamsonCalm}} 平静：进入时获得3秒护盾，不可叠加'..
		 '#{{IBSSamsonWrath}} 暴怒：14秒后恢复平静；伤害和受到的惩罚性伤害翻倍；可使用{{Collectible'..(IBS_ItemID.Posture)..'}}架势的攻击'..
		 '#站立不动时加速{{IBSSamsonWrath}}暴怒流逝'..
		 '#!!! {{IBSSamsonWrath}}暴怒时受到惩罚性伤害有50%概率失去选中的牌，除了{{Card1}}愚者 ({{Luck}}幸运10: 10%)',
	br='由{{IBSSamsonCalm}}平静进入{{IBSSamsonWrath}}暴怒时，恢复{{Collectible'..(IBS_ItemID.Posture)..'}}架势1点充能'
},

[IBS_PlayerID.BEden] = {
	name='昧化伊甸',
	info='属性不受大部分效果影响',
	br='转换为点数后:'..
		 '#本层道具点数价值 x 300%'..
		 '#清空{{BrokenHeart}}碎心'..
		 '#+ 3 {{BoneHeart}}骨心'..
		 '#{{Heart}} 体力回满'..
		 '#下层7秒后死亡'
},

[IBS_PlayerID.BLost] = {
	name='昧化游魂',
	info='飞行'..
		 '#跟班道具将被移出道具池'..
		 '#幽灵眼泪'..
		 '#10%概率发射伤害+1的钥匙眼泪({{Luck}}幸运10：50%)'..
		 '#可全向攻击'..
		 '#非游魂长子名分道具和部分道具会被分解为{{Key}}钥匙；若品质为{{Quality2}}2或以上会额外生成箱子'..
		 '#按住'..EID.ButtonToIconMap[ButtonAction.ACTION_DROP]..'丢弃键才能开启箱子',
	br='{{Key}} 钥匙 + 70#生成3个{{EternalChest}}永恒箱子#修复速度加快'
},

[IBS_PlayerID.BKeeper] = {
	name='昧化店主',
	info='飞行'..
		 '#双发眼泪'..
		 '#自动吞下硬币饰品'..
		 '#硬币饰品将影响乞丐道具池'..
		 '#道具价格 x 300%，可通过捐助乞丐降低'..
		 '#心免费，且拾取后将被储存，受致命伤时消耗14点抵消；与机器或乞丐交互受伤时消耗2点抵消'..
		 '#捐助乞丐一定次数后获得硬币心之容器，最多7个',
	br='通过捐助乞丐最多可达到12硬币心之容器#硬币饰品有33.3%概率变为金色'
},


}
--------------------------------------------------------
--------------------------道具--------------------------
--------------------------------------------------------
local itemEID={

[IBS_ItemID.LightD6]={
	name='光辉六面骰',
	info='无需满充能即可使用'..
		 '#以房间内道具平均品质重置道具'..
		 '#消耗的充能由平均品质决定:'..
		 '#{{Quality0}} 0及以下: 0'..
		 '#{{Quality1}} 1: 1'..
		 '#{{Quality2}} 2: 2'..
		 '#{{Quality3}} 3: 3'..
		 '#{{Quality4}} 4及以上 : 6',
	virtue='内环魂火，概率发射圣光眼泪#每消耗1充能生成1魂火',
	belial='品质可能上下浮动',
	void='无效',
	seijaNerf='使用需要消耗{{HalfSoulHeart}}半魂心或{{HalfBlackHeart}}半黑心，且充能消耗固定为6',
},

[IBS_ItemID.NoOptions]={
	name='拒绝选择',
	info='不再单选掉落物',
	player={
		[PlayerType.PLAYER_THELOST]='恶魔交易免费',
		[PlayerType.PLAYER_THELOST_B]='恶魔交易免费',
		[IBS_PlayerID.BLost]='恶魔交易免费',
		[PlayerType.PLAYER_JACOB] = '额外获得{{Collectible249}}',
		[PlayerType.PLAYER_ESAU] = '额外获得{{Collectible414}}'
	}
},

[IBS_ItemID.D4D]={
	name='四维骰',
	info='以相对方位改变离角色最近道具的ID#左加;右减;上翻倍;下减半',
	virtue='4个外环魂火，不发射眼泪',
	belial='没有对应道具时，以{{Collectible51}}五芒星代替',
	void='无效',
	seijaNerf='按随机方位重置',
},

[IBS_ItemID.SSG]={
	name='仰望星空',
	info='双击发射一颗特殊眼泪，命中目标时生成落泪区'..
		 '#4秒冷却'
},

[IBS_ItemID.Waster]={
	name='剩饼',
	info='即将受伤时，25%概率获得{{HalfSoulHeart}}半魂心，之后在本房间获得{{Collectible108}}圣饼效果'
},

[IBS_ItemID.Envy]={
	name='女疾女户',
	info='↑ {{Damage}}伤害 x 1.3'..
		 '#↑ {{Luck}}幸运 x 1.6'..
		 '#嫉妒等级初始为1, 最高4, 最低0'..
		 '#直接拾取的道具的品质高于{{Quality2}}2时，等级增加；低于则减少'..
		 '#等级达到一定值：'..
		 '#{{Blank}} 2：↓{{Luck}}失去幸运加成'..
		 '#{{Blank}} 3：↓{{Damage}}失去伤害加成'..
		 '#{{Blank}} 4：品质高于{{Quality2}}2的道具都被替换为该道具'
},

[IBS_ItemID.GlowingHeart]={
	name='发光的心',
	info='#移除1个{{BrokenHeart}}碎心，没有碎心则获得1{{SoulHeart}}魂心',
	virtue='内环魂火，概率发射圣光眼泪',
	belial='无{{BrokenHeart}}碎心时，效果改为获得1{{BlackHeart}}黑心',
	player={[IBS_PlayerID.BMaggy]='+ 21{{IBSIronHeart}}坚贞之心，并恢复7已损失的上限'}
},

[IBS_ItemID.PurpleBubbles]={
	name='紫色泡泡水',
	info='随机获得一项以下效果:'..
		 '#↓ {{Speed}}移速 - 0.02'..
		 '#↑ {{Tears}}射速修正 + 0.06'..
		 '#↑ {{Damage}}伤害 + 0.1'..
		 '#↑ {{Range}}射程 + 0.15'..
		 '#↓ {{Shotspeed}}弹速 - 0.03'..
		 '#丢弃该道具后，在下一层重置属性变动'..
		 '#使用24次之后，不会重置',
	virtue='内环魂火，概率发射眩晕眼泪',
	belial='无特殊效果',
	void='不会重置属性'
},

[IBS_ItemID.CursedMantle]={
	name='诅咒屏障',
	info='强占主动槽，除非持有{{Collectible260}}黑蜡烛或{{Collectible584}}美德之书'..
		 '#直接使用无效果'..
		 '#即将受伤时，消耗2充能，触发{{Collectible705}}暗影刺刀效果',
	virtue='阻止该道具强占主动槽',
	belial='无特殊效果',
	void='吸收后，获得{{Collectible313}}神圣屏障效果',
},

[IBS_ItemID.Hypercube]={
	name='超立方',
	info='无记录时，记录距离最近的道具，并将其移出道具池'..
		 '#已有记录时，将房间内的道具重置为记录的道具'..
		 '#所有{{Collectible'..(IBS_ItemID.Hypercube)..'}}'..'超立方共享记录',
	virtue='外环魂火，发射追踪眼泪',
	belial='无特殊效果',
	void='无效'
},

[IBS_ItemID.Defined]={
	name='已定义',
	info='在清理房间后充能'..
		 '#无需满充能即可使用'..
		 '#选择传送至一个特定类型的房间(充能消耗与类型有关)，若与本层已经进入过的房间类型相同则不消耗充能',
	virtue='无魂火#充能消耗 - 1',
	belial='充能消耗 - 1',
	void='无效',
	seijaNerf='20%变为{{Collectible324}}未定义',
	player={[IBS_PlayerID.BEden]='在初始房间使用进入操作面板'}
},

[IBS_ItemID.Chocolate]={
	name='瓦伦丁巧克力',
	info='{{SoulHeart}} 魂心 + 2'..
		 '#双击发射一颗特殊眼泪，将命中的非Boss敌人变为友好状态，并获得2.14倍血量'..
		 '#两次机会，进入新房间重置'..
		 '#存在2个友好敌人时不能使用'
},

[IBS_ItemID.Diamoond]={
	name='钻石',
	info='防爆'..
		 '#33%概率眼泪变为{{Burning}}火焰或{{Slow}}减速眼泪，伤害 + 1，并可破坏障碍物'..
		 '#{{Luck}} 幸运不会影响概率'..
		 '#{{Freezing}} 冰冻同时被点燃和减速的非Boss敌人'
},

[IBS_ItemID.Cranium]={
	name='奇怪的头骨',
	info='进入新层时，角色获得{{Player10}}游魂诅咒'..
		 '#进入{{BossRoom}}Boss房后恢复，并获得1{{BlackHeart}}黑心',
	seijaBuff={
		desc = '诅咒持续期间，进入有敌人的房间获得10秒护盾',
		data = {
			append = function(x) 
				return (x > 1 and "#清理{{BossRoom}}Boss房后生成"..(x-1).."个血量代价的恶魔房道具") or ''
			end
		},
	},
},

[IBS_ItemID.Ether]={
	name='以太之云',
	info='拾取时，+ 1 {{BlackHeart}}黑心和{{SoulHeart}}魂心'..
		 '#受伤后在本房间获得飞行，并降下圣光'..
		 '#圣光造成角色伤害的2倍穿甲伤害'..
		 '#圣光降落频率随角色在本房间的受伤次数递增',
	trans={'LEVIATHAN', 'ANGEL'}
},

[IBS_ItemID.Wisper]={
	name='魂火之灵',
	info='抵挡敌弹的环绕物跟班'..
		 '#造成角色伤害3倍的碰撞伤害'..
		 '#击杀敌人有30%概率生成普通魂火({{Luck}}幸运7:100%)',
	trans={'ANGEL'}
},

[IBS_ItemID.BOT]={
	name='节制之骨',
	info='弹性眼泪'..
		 '#角色眼泪不再具有垂直加速度'..
		 '#按下 '..EID.ButtonToIconMap[ButtonAction.ACTION_DROP]..' 丢弃键可使眼泪静止，'..
		 '双击则回收'..
		 '#↑ 回收眼泪提供临时{{Tears}}射速提升，最高2'..
		 '#7秒后自动回收眼泪'
},

[IBS_ItemID.GOF]={
	name='坚韧面罩',
	info='抵挡面前的敌弹'..
		 '#受到敌弹伤害时，清除所有敌弹'..
		 '#受到的爆炸伤害降低至半心'
},

[IBS_ItemID.V7]={
	name='美德七面骰',
	info='在当前房间召唤一个友好的以下小Boss，具有双倍血量:'..
		'#勤勤 & 劳劳'..
		 '#贞洁'..
		 '#坚韧'..
		 '#节制'..
		 '#慷慨'..
		 '#谦逊',
	virtue='普通魂火',
	belial='无特殊效果',		 
},

[IBS_ItemID.TGOJ]={
	name='犹大福音',
	info='扔出一本能吸收敌弹的书，飞行期间具有碰撞伤害'..
		 '#充能未满时使用则回收书'..
		 '#吸收一定敌弹后，生成{{Collectible634}}炼狱恶鬼的裂缝',
	virtue='吸收一定敌弹后，生成魂火',
	belial='吸收敌弹将提供临时{{Damage}}伤害提升',
	player={[IBS_PlayerID.BJudas]='与书本较远时，与书本交换位置，期间具有碰撞伤害，且自动发射眼泪'},
	trans={'BOOKWORM'}
},

[IBS_ItemID.ReservedNail]={
	name='备用钉子',
	info='发射一枚钉子，对命中的目标造成3秒的石化和虚弱效果'..
		 '#造成伤害可以加快充能',
	virtue='不发射眼泪的中环魂火，熄灭后对附近的敌人施加1.5秒的石化和虚弱效果#单房间魂火',
	belial='钉子附带火焰效果'
},

[IBS_ItemID.SuperB]={
	name='核能电罐',
	info='每造成200伤害，为主动道具充能，可为额外充能条充能'..
		 '#受到非自伤后，进入蓄力状态，不断消耗充能'..
		 '#蓄力完成后爆炸，没完成则取消',
	seijaNerf='爆炸会伤害自己'
},

[IBS_ItemID.DreggyPie]={
	name='掉渣饼',
	info='{{Heart}} 获得1心之容器，满血'..
		 '#↑ {{Tears}}射速修正 + 5，并不断衰减'..
		 '#除了{{Player20}}以扫，{{Collectible'..(IBS_ItemID.DreggyPie)..'}}掉渣饼 + {{Collectible621}}红豆汤 = {{Collectible619}}长子名分'
},

[IBS_ItemID.BonyKnife]={
	name='骨刀',
	info='在当前房间中，{{Damage}}攻击力降低25%(不叠加)，获得{{Collectible114}}妈妈的菜刀效果',
	virtue='不发射眼泪的内环魂火#熄灭时，触发该道具的效果',
	belial='刀附带火焰'	
},

[IBS_ItemID.Circumcision]={
	name='割礼',
	info='↓ {{Speed}}移速 - 0.4'..
		 '#↑ {{Tears}}射速修正 + 2'..
		 '#↑ {{Luck}}幸运 + 2'	
},

[IBS_ItemID.CursedHeart]={
	name='诅咒之心',
	info='{{CurseRoom}} 诅咒房中额外生成一个血量代价的道具'
},

[IBS_ItemID.Redeath]={
	name='死亡回放',
	info='将空底座道具重置为一个以下掉落物:'..
		 '#金箱子，旧箱子，黑福袋，金饰品，道具'..
		 '#重置出的掉落物在20秒后消失，且有尖刺环绕',
	virtue='无魂火#掉落物不消失',
	belial='掉落物无尖刺环绕'
},

[IBS_ItemID.DustyBomb]={
	name='尘埃炸弹',
	info='+ 3{{Bomb}}炸弹'..
		 '#免疫来自角色炸弹的爆炸'..
		 '#角色炸弹一触即发'..
		 '#切换房间刷新，角色炸弹前三次爆炸时，所有敌人失去12%当前血量；第三次爆炸还会消灭非头目敌人'
},

[IBS_ItemID.NeedleMushroom]={
	name='金针菇',
	info='↑ {{Speed}}速度 + 0.3'..
		 '#↑ {{Tears}}射速 + 0.7'..
		 '#↑ {{Range}}射程 + 1.25'..
		 '#攻击时，每秒有6%概率({{Luck}}幸运5:1%)丢弃该道具，且5秒内不能拾取',
	trans={'MUSHROOM', 'POOP'},
	player={[PlayerType.PLAYER_BLUEBABY_B]='丢弃的同时生成一个便便掉落物'}
},

[IBS_ItemID.MiniHorn]={
	name='小小角恶魔',
	info='攻击6~13秒后，在角色位置生成一个伤害为60的小即爆炸弹',
	seijaBuff={
		desc = '改为生成红炸弹，生成所需时间固定为3秒',
		data = {
			append = function(x) 
				return (x > 1 and "#额外生成"..(3*(x-1)).."个即爆炸弹；角色免疫爆炸伤害") or ''
			end
		},
	}
},

[IBS_ItemID.WOA]={
	name='亚波伦之翼',
	info='{{Pill}} 拾起时，生成弹速上升胶囊'..
		 '#↑ {{Shotspeed}}弹速 + 0.16'..
		 '#除{{Shotspeed}}弹速外，所有属性获得{{Shotspeed}}弹速 - 0.3 的倍率，最低90%，最高150%',
	player={
		[PlayerType.PLAYER_APOLLYON] = '飞行',
		[PlayerType.PLAYER_APOLLYON_B] = '飞行'
	}
},

[IBS_ItemID.MomsCheque]={
	name='妈妈的支票',
	info='直接使用无效果'..
		 '#↑ + 2{{Luck}}幸运'..	
		 '#每层获得10{{Coin}}硬币',
	void='吸收后仍有效',
	trans={'MOM'}
},

[IBS_ItemID.ForbiddenFruit]={
	name='禁断之果',
	info='!!! {{ColorYellow}}一次性{{CR}}'..
		 '#{{Quality1}}1级道具和{{Quality3}}3级道具将被移出道具池'..
		 '#本局不再遇到{{CurseUnknown}}未知诅咒和{{CurseBlind}}致盲诅咒',
	virtue='2个内环魂火，发射毒性眼泪',
	belial='移除角色身上品质{{Quality1}}或{{Quality3}}的道具，每移除一个提升一定{{Damage}}伤害'
},

[IBS_ItemID.Sword]={
	name='紫电护主之刃',
	info='自动攻击'..
		 '#抵挡敌弹'..
		 '#{{Collectible536}} 不可献祭',
	bff='攻速翻倍',
	seijaNerf='没有目标时，攻击角色'
},

[IBS_ItemID.Regret]={
	name='死不瞑目',
	info='角色每次死亡都会获得:'..
		 '#↑ {{Speed}}移速 + 0.1'..
		 '#↑ {{Tears}}射速 + 0.35'..
		 '#↑ {{Damage}}伤害 + 1',
	seijaBuff={
		desc = '若未持有，每层获得一个{{Collectible11}} 1 UP',
		data =  {
			append = function(x) 
				return (x > 1 and "#每层获得"..(x-1).."个{{Card89}}拉撒路的魂石") or ''
			end		
		}
	}
},

[IBS_ItemID.Sacrifice]={
	name='不受欢迎的祭品',
	info='1.7秒后，在使用位置降下一道大光柱，并产生爆炸'..
		 '#光柱造成每帧70%{{Damage}}角色伤害，并摧毁周围的障碍物，持续3.5秒'..
		 '#!!! 光柱也会伤害角色'..
		 '#若使用过{{Collectible'..(IBS_ItemID.Sacrifice2)..'}}受欢迎的祭品，则光柱不再伤害角色，且追踪敌人',
	virtue='无魂火#光柱不再伤害角色，且追踪敌人',
	belial='光柱更大，还会追踪角色'
},

[IBS_ItemID.Sacrifice2]={
	name='受欢迎的祭品',
	info='进入恶魔/天使房以充能'..
		 '#若使用过{{Collectible'..(IBS_ItemID.Sacrifice)..'}}不受欢迎的祭品，立刻充能'..
		 '#!!! {{ColorYellow}}一次性{{CR}}'..
		 '#使用后:'..
		 '#为新房间内品质最高的道具，生成品质相同的，一个血量代价的恶魔房道具，和一个硬币代价的天使房道具作为额外选择',
	virtue='无魂火#立刻充能',
	belial='立刻充能'
},

[IBS_ItemID.Multiplication]={
	name='只剩亿点',
	info='{{Coin}}硬币，{{Bomb}}炸弹和{{Key}}钥匙的下限变为1',
	seijaNerf='上限也变为1，包括{{EmptyHeart}}心之容器',
	player={
		[PlayerType.PLAYER_BLUEBABY_B] = '对便便掉落物也生效',
		[PlayerType.PLAYER_BETHANY] = '对魂心充能也生效',
		[PlayerType.PLAYER_BETHANY_B] = '对鲜血充能也生效',
	}
},

[IBS_ItemID.NoTemperance]={
	name='不懂节制?',
	info='遇见但不参与赌博游戏：'..
		 '#↑ {{Speed}}移速 + 0.02'..
		 '#↑ {{Damage}}伤害 + 0.2'..
		 '#↓ {{Shotspeed}}弹速 - 0.02'..
		 '#↑ {{Luck}}幸运 + 0.25'..
		 '#遇见但不进入{{ArcadeRoom}}赌博房：获得4倍以上属性'
},

[IBS_ItemID.GuppysPotty]={
	name='嗝屁猫砂盆',
	info='吞下2个{{Trinket86}}小幼虫'..
		 '#清理房间后，生成大便',
	trans={'GUPPY', 'LORD_OF_THE_FLIES', 'POOP'}
},

[IBS_ItemID.LOL]={
	name='蝗虫领主',
	info='清理房间后，生成1只天启蝗虫'..
		 '#每造成50伤害，有50%概率生成1只天启蝗虫'..
		 '#角色不会受到{{Trinket113}}战争蝗虫的伤害',
},

[IBS_ItemID.Falowerse]={
	name='薇艺',
	info='按住 '..EID.ButtonToIconMap[ButtonAction.ACTION_DROP]..' 丢弃键触碰掉落物时, 将其分解为{{IBSMemory}}记忆碎片'..
		 '#消耗21{{IBSMemory}}记忆碎片生成3个伪忆，但只能拿1个'..
		 '#角色死亡时，变为 {{Player'..(IBS_PlayerID.BXXX)..'}} 昧化???，失去该道具，并重新开始本层',
	virtue='无魂火',
	belial='无效',
	player={[IBS_PlayerID.BXXX] = '伪忆球上限提升至6，并失去该道具'}
},

[IBS_ItemID.FalsehoodOfXXX]={
	name='???的伪忆',
	info='生成一个伪忆',
	trans={'GUPPY','LORD_OF_THE_FLIES','MUSHROOM','ANGEL','BOB','SPUN','MOM','CONJOINED','LEVIATHAN','POOP','BOOKWORM','SPIDERBABY'}
},

[IBS_ItemID.GoldExperience]={
	name='黄金体验',
	info='获得1{{BrokenHeart}}碎心'..
		 '#提供等同于{{BrokenHeart}}碎心数量的硬币心之容器'..
		 ' (类似{{Player14}}店主的，但只能通过拾取{{Coin}}硬币恢复)'..
		 '#!!! {{ColorYellow}}不能阻止死亡{{CR}}',
	player={
		[PlayerType.PLAYER_KEEPER] = '效果改为吞下{{Trinket156}}妈妈的吻',
		[PlayerType.PLAYER_KEEPER_B] = '效果改为吞下{{Trinket156}}妈妈的吻'
	}
},

[IBS_ItemID.ChubbyCookbook]={
	name='蛆虫食谱',
	info='召唤友好的蛆虫，每次使用多召唤一只'..
		 '#第6次使用时重置计数',
	virtue='不发射眼泪的等量外环魂火',
	belial='生成等量的我的影子'
},

[IBS_ItemID.ProfaneWeapon]={
	name='俗世的武器',
	info='对非Boss敌人造成1.5倍穿甲伤害'
},

[IBS_ItemID.RulesBook]={
	name='规则书',
	info='随机触发一项以下效果:'..
		 '#生成1个{{Coin}}硬币'..
		 '#生成1个{{Bomb}}炸弹'..
		 '#生成纸质饰品'..
		 '#生成血量代价的商店道具'..
		 '#生成{{Card47}}保释卡'..
		 '#{{AngelRoom}}天使房转换率 + 15%'..
		 '#触发{{Collectible76}}X光透视效果'..
		 '#游戏计时减少10分钟',
	virtue='内环魂火',
	belial='无特殊效果'
},

[IBS_ItemID.CathedralWindow]={
	name='教堂玻璃窗',
	info='+ 2{{SoulHeart}}魂心'..
		 '#↑ + 0.7{{Tears}}射速'..
		 '#{{Shop}} 商店：卡牌50%变为{{Card51}}神圣卡'..
		 '#{{TreasureRoom}} 宝箱房：出现一个普通乞丐'..
		 '#{{SecretRoom}} 隐藏房：店主变为天使雕像'..
		 '#{{ArcadeRoom}} 赌博房：赌博游戏50%变为忏悔室'..
		 '#{{CurseRoom}} 诅咒房：红箱子50%变为永恒箱子'..
		 '#{{DevilRoom}} 恶魔房：道具免费，但只能拿1个'
},

[IBS_ItemID.LeadenHeart]={
	name='铅制心脏',
	info='+ 1{{BrokenHeart}}碎心'..
		 '#↓ - 0.15 {{Speed}}移速'..
		 '#获得28临时{{IBSIronHeart}}坚贞之心'..
		 '#进入新层时，获得28临时{{IBSIronHeart}}坚贞之心',
	player={[IBS_PlayerID.BMaggy]='+7{{IBSIronHeart}}坚贞之心上限'}
},

[IBS_ItemID.China]={
	name='瓷',
	info='获得心时，+ 1 临时{{IBSIronHeart}}坚贞之心',
	player={[IBS_PlayerID.BMaggy]='效果改为获得额外{{IBSIronHeart}}坚贞之心'}
},

[IBS_ItemID.SilverBracelet]={
	name='银色手镯',
	info='令周围的敌人混乱、恐惧或石化'..
		 '#赌博游戏爆炸'..
		 '#{{ArcadeRoom}}赌博房内所有可互动实体爆炸',
	virtue='不发射眼泪的中环单房间魂火#熄灭时，触发该道具的效果',
	belial='点燃敌人'
},

[IBS_ItemID.ROH]={
	name='谦逊之径',
	info='获得道具时，随机属性+ 2.5% x (4 - 品质)'
},

[IBS_ItemID.Tenebrosity]={
	name='晦涩之心',
	info='获得心时，22%概率触发{{Collectible35}}死灵之书效果 ({{Luck}}幸运13：100%)',
	seijaBuff={
		desc = '↑触发时获得%s{{Damage}}伤害提升',
		data = {
			args = function(x) return 0.5*x end		
		}
	}
},

[IBS_ItemID.HellKitchen]={
	name='地狱厨房',
	info='+ 2{{BlackHeart}}黑心'..
		 '#{{DevilRoom}} 恶魔房中额外出现一个有尖刺环绕的道具 (独立道具池)'
},

[IBS_ItemID.StolenDecade]={
	name='偷来的十年',
	info='可使用10次'..
		 '#按优先级触发效果：'..
		 '#存在标价物品：使其免费'..
		 '#存在单选物品：使其不再单选'..
		 '#在初始房间：触发朝夕符文，诸神符文和{{Collectible76}}X光透视效果'..
		 '#以上均未满足：移除1{{BrokenHeart}}碎心，并触发{{Card51}}神圣卡效果',
	virtue='不发射眼泪的外环魂火',
	belial='获得1{{BlackHeart}}黑心',
	void='无效'
},

[IBS_ItemID.DiceProjector]={
	name='骰影仪',
	info='进入新房间时，生成与房间内道具等量等价的道具作为选择，但只能存在3秒',
},

[IBS_ItemID.Hoarding]={
	name='收集癖',
	info='↑ {{Luck}}幸运 + 1'..
		 '#一些套装部件具有额外效果',
},

[IBS_ItemID.SuperPanicButton]={
	name='超紧急按钮',
	info='初始房间会生成主动形式的该道具，其效果:'..
		 '#无论是否持有，离开房间后消失'..
		 '#!!! {{ColorYellow}}一次性{{CR}}'..
		 '#移除被动形式的该道具'..
		 '#无敌75秒'..
		 '#+ 1 {{EmptyBoneHeart}}骨心'..
		 '#治疗3{{Heart}}红心'..
		 '#本层的心不能被角色拾取',
	greed='波次开始时消失',
	virtue='6个不发射眼泪的高血量内环魂火',
	belial='↑{{Damage}}伤害 + 2',
	void='无效'
},

[IBS_ItemID.SuperPanicButton_Active]={
	name='超紧急按钮 (主动形式)',
	info='无论是否持有，离开房间后消失'..
		 '#!!! {{ColorYellow}}一次性{{CR}}'..
		 '#移除被动形式的该道具'..
		 '#无敌75秒'..
		 '#+ 1 {{EmptyBoneHeart}}骨心'..
		 '#治疗3{{Heart}}红心'..
		 '#本层的心不能被角色拾取',
	greed='波次开始时消失',	 
	virtue='6个不发射眼泪的高血量内环魂火',
	belial='↑{{Damage}}伤害 + 2',
	void='无效'
},

[IBS_ItemID.Blackjack]={
	name='21点',
	info='清理房间后有10%概率生成正塔罗牌'..
		 '#消耗塔罗牌时，增加对应数字的计数；为逆位塔罗牌则减去'..
		 '#!!! {{ColorYellow}}大于10的数字算作10{{CR}}'..
		 '#计数小于0或大于21时，获得ID为计数绝对值的卡牌，并重置计数'..
		 '#计数正好为21时，生成{{Collectible624}}扩展包，并重置计数',
},

[IBS_ItemID.Sketch]={
	name='写生',
	info='使用消耗4充能'..
		 '#按优先级记录距离最近的道具的一个标签：'..
		 '死亡，注射器，妈妈，科技，电池，嗝屁猫，苍蝇，'..
		 '鲍勃，蘑菇，宝宝，天使，恶魔，便便，书，蜘蛛，'..
		 '食物，攻击性，星星'..
		 '#没有对应标签或标签重复时记为"空"'..
		 '#记录两个标签后，再使用两次可以生成具有相同标签的被动道具'..
		 '#!!! 影响道具池',
	virtue='无魂火#至少{{Quality2}}2级道具',
	belial='没有对应道具时，以{{Collectible51}}五芒星代替',
	void='无效',
	seijaNerf='75%画不出道具',
},

[IBS_ItemID.Molekale]={
	name='分子植物',
	info='根据上一个非该道具的道具的品质决定效果：'..
		 '#{{Quality0}} 0及以下：获得新道具时生成{{Bomb}}炸弹和{{Key}}钥匙'..
		 '#{{Quality1}} 1：每6个敌人死亡生成{{Coin}}硬币；每拾取3个硬币治疗{{HalfHeart}}半红心'..
		 '#{{Quality2}} 2：受伤时或进入新{{BossRoom}}Boss房时，生成血团宝宝'..
		 '#{{Quality3}} 3：切换房间时无敌5秒'..
		 '#{{Quality4}} 4及以上：对附近的敌人施加{{BrimstoneCurse}}硫磺诅咒；攻击时发射反重力追踪硫磺火',
},

[IBS_ItemID.Ssstew]={
	name='炖蛇羹',
	info='获得时，将{{EmptyHeart}}心之容器变为{{BoneHeart}}骨心，{{SoulHeart}}魂心变为{{BlackHeart}}黑心'..
		 '#第 (6 - {{BlackHeart}}黑心数) 颗眼泪伤害 + 2，附带减速，毒性和穿透效果'..
		 '#接触{{SoulHeart}}魂心会将其变为{{BlackHeart}}黑心',
	trans={'LEVIATHAN'}
},

[IBS_ItemID.BookOfSeen]={
	name='全知之书',
	info='{{TreasureRoom}} 宝箱房中额外生成一个书道具'..
		 '#使用后，记录房间内所有主动书道具效果，并触发已记录的效果'..
		 '#所有{{Collectible'..(IBS_ItemID.BookOfSeen)..'}}'..'全知之书共享记录',
	virtue='生成对应魂火',
	belial='无特殊效果',
	trans={'BOOKWORM'}
},

[IBS_ItemID.PortableFarm]={
	name='移动农场',
	info='吞下{{Trinket'..(IBS_TrinketID.WheatSeeds)..'}}'..'小麦种子',
	virtue='不发射眼泪的中环魂火#熄灭时，生成{{Trinket'..(IBS_TrinketID.WheatSeeds)..'}}'..'小麦种子',
	belial='无特殊效果',
},

[IBS_ItemID.GrowingWheatI]={
	name='麦苗I',
	info='清理房间后，变为{{Collectible'..(IBS_ItemID.GrowingWheatII)..'}}麦苗II'
},
[IBS_ItemID.GrowingWheatII]={
	name='麦苗II',
	info='清理房间后，变为{{Collectible'..(IBS_ItemID.GrowingWheatIII)..'}}麦苗III'
},
[IBS_ItemID.GrowingWheatIII]={
	name='麦苗III',
	info='清理房间后，变为{{Collectible'..(IBS_ItemID.GrowingWheatIV)..'}}麦苗IV'
},
[IBS_ItemID.GrowingWheatIV]={
	name='麦苗IV',
	info='清理房间后，变为{{Collectible'..(IBS_ItemID.GrowingWheatV)..'}}麦苗V'
},
[IBS_ItemID.GrowingWheatV]={
	name='麦苗V',
	info='清理房间后，变为{{Collectible'..(IBS_ItemID.GrowingWheatVI)..'}}麦苗VI'
},
[IBS_ItemID.GrowingWheatVI]={
	name='麦苗VI',
	info='清理房间后，变为{{Collectible'..(IBS_ItemID.Wheat)..'}}小麦'
},
[IBS_ItemID.Wheat]={
	name='小麦',
	info='↑ {{Speed}}移速 + 0.2'..
		 '#3个该道具会变为{{Collectible'..(IBS_ItemID.Bread)..'}}面包，其效果:'..
		 '#治疗3{{Heart}}红心'..
		 '#+ 1{{SoulHeart}}魂心'..
		 '#↑ {{Damage}}伤害 + 0.3'..
		 '#↑ {{Luck}}幸运 + 0.5'..
		 '#↓ {{Shotspeed}}弹速 - 0.03'
},
[IBS_ItemID.Bread]={
	name='面包',
	info='治疗3{{Heart}}红心'..
		 '#+ 1{{SoulHeart}}魂心'..
		 '#↑ {{Damage}}伤害 + 0.3'..
		 '#↑ {{Luck}}幸运 + 0.5'..
		 '#↓ {{Shotspeed}}弹速 - 0.03'
},

[IBS_ItemID.Goatify]={
	name='变羊术',
	info='所有山羊变得友好，免疫火焰，地刺和爆炸伤害，且在已清理房间内不会受伤'..
		 '#受伤时，将非Boss攻击者变为山羊'..
		 '#使用后，生成1个双倍血量山羊，并从任意角色身上消耗一个{{Collectible'..(IBS_ItemID.Wheat)..'}}小麦为所有山羊回满血量',
	virtue='不发射眼泪的中环魂火#熄灭时，生成山羊',
	belial='无特殊效果',
},

[IBS_ItemID.ElegiastWinter]={
	name='悼歌之冬',
	info='获得时，生成{{Card10}}隐者'..
		 '#清理房间后, 10%概率生成{{Card10}}隐者'..
		 '#每层首次使用{{Card10}}隐者时，传送至一个特殊商店，其中的商品只能选择一个购买'
},

[IBS_ItemID.GHD]={
	name='地质学博士证',
	info='{{Bomb}} 炸弹 + 2'..
		 '#生成{{Card72}}塔?'..
		 '#部分障碍物被摧毁时会额外生成一些掉落物'..
		 '#高亮显示标记石头和暗门石头'
},

[IBS_ItemID.Grail]={
	name='筵宴之杯',
	info='+ 1 {{EmptyHeart}} 空心之容器'..
		 '#生成{{Card16}}恶魔'..
		 '#使用{{Card16}}恶魔后，+ 0.15{{Damage}}伤害，当前房间内敌人死亡时掉落消逝的随机心'..
		 '#清理房间后有5%概率生成{{Card16}}恶魔，每有一种心提升5%',
	greed='贪婪模式：生成概率减半'
},

[IBS_ItemID.Moth]={
	name='蜕变之蛾',
	info='#获得时，生成{{Card1}}愚者'..
		 '#使用其他塔罗牌时，生成{{Card1}}愚者'..
		 '#每层的{{Card1}}愚者会根据使用次数改变效果：'..
		 '#{{Blank}} 2：传送至{{SecretRoom}}隐藏房'..
		 '#{{Blank}} 3：传送至{{SuperSecretRoom}}超级隐藏房'..
		 '#{{Blank}} 4：传送至{{UltraSecretRoom}}究极隐藏房'..
		 '#{{Blank}} 5及以上：重置本房间内的道具',
},

[IBS_ItemID.Edge]={
	name='流亡之刃',
	info='#生成{{Collectible'..(IBS_ItemID.Edge2)..'}}伤疤之秘和{{Collectible'..(IBS_ItemID.Edge3)..'}}破碎之秘'..
		 '#!!! 只能拿一个',
},

[IBS_ItemID.Edge2]={
	name='伤疤之秘',
	info='↑ + 0.5 {{Tears}}射速修正'..
		 '#获得或进入新层时，生成{{Card8}}战车，并获得1{{BrokenHeart}}碎心直到4个'..
		 '#免疫爆炸和碰撞'..
		 '#攻击时，向移动方向发射两道幽灵穿透眼泪，每个眼泪造成33%{{Damage}}角色伤害；'..
		 '受伤或使用{{Card8}}战车后的一段时间内，上述眼泪伤害翻倍并获得追踪效果',
	seijaNerf='移动时突进'
},

[IBS_ItemID.Edge3]={
	name='破碎之秘',
	info='#↑ + 8 {{Damage}}伤害修正'..
		 '#获得或进入新层时，生成{{Card12}}力量'..
		 '#使用{{Card12}}力量后获得1{{SoulHeart}}魂心和8%{{Damage}}伤害倍率，并消除1个{{BrokenHeart}}碎心',
	seijaNerf='{{Damage}}伤害加成降低至0.8；使用{{Card12}}力量后失去2.5%{{Tears}}射速直至0',
},

[IBS_ItemID.Forge]={
	name='白日之铸',
	info='#获得时，生成{{Card21}}审判'..
		 '#使用{{Card21}}审判后将角色身上的饰品变为金饰品并熔炼'..
		 '#机器被摧毁时有60%概率生成{{Card21}}审判，否则生成1个{{Bomb}}炸弹'..
		 '#乞丐被摧毁时有60%概率生成1个机器，否则生成1个{{Bomb}}炸弹',
},

[IBS_ItemID.SecretHistories]={
	name='浪游秘史',
	info='#获得或进入新层时，生成{{Card18}}星星'..
		 '#消耗{{Card18}}星星时不再传送，而是随机获得以下一个道具魂火，并生成相应卡牌：'..
		 '#{{Card1}} '..'{{Collectible'..(IBS_ItemID.Moth)..'}}蜕变之蛾'..
		 '#{{Card6}} '..'{{Collectible'..(IBS_ItemID.Knock)..'}}洞开之启'..
		 '#{{Card8}} '..'{{Collectible'..(IBS_ItemID.Edge2)..'}}伤疤之秘'..
		 '#{{Card12}} '..'{{Collectible'..(IBS_ItemID.Edge3)..'}}破碎之秘'..
		 '#{{Card16}} '..'{{Collectible'..(IBS_ItemID.Grail)..'}}筵宴之杯'..
		 '#{{Card21}} '..'{{Collectible'..(IBS_ItemID.Forge)..'}}白日之铸',
	greed='贪婪模式：跳过非贪婪标签的',
	player={
		[PlayerType.PLAYER_KEEPER]='跳过非店主标签的',
		[PlayerType.PLAYER_KEEPER_B]='跳过非店主标签的',
	}
},

[IBS_ItemID.AnotherKarma]={
	name='异业',
	info='将距离最近的免费或硬币价格的道具(包括正在拾取的道具)变为1个乞丐和3~5个{{Coin}}硬币，50%概率生成一个硬币饰品'..
		 '#!!! 房间内存在7及以上的可互动实体时不再生成乞丐',
	virtue='3个中环魂火，熄灭时概率生成硬币',
	belial='生成的乞丐必定是恶魔乞丐',
	void='无效',
	player={
		[IBS_PlayerID.BKeeper]='没有道具时，选择消耗一个硬币饰品代替；若消耗的是金饰品，触发两次效果'
	}
},

[IBS_ItemID.Alms]={
	name='施粥处',
	info='获得时，+ 3{{Coin}}硬币，并生成{{Card21}}审判'..
		 '#来自乞丐道具池的道具免费，且具有一个额外道具作为轮换',
},

[IBS_ItemID.NotchedSword]={
	name='残损之剑',
	info='↑ {{Damage}}伤害修正 + 1'..
		 '#无视敌人护甲'..
		 '#清理房间后，有33.3%概率打开所有门，包括一些特殊门'..
		 '#即使失去该道具，依然生效',
	seijaNerf='拾取时获得3{{BrokenHeart}}碎心；敌人有50%概率免伤'
},

[IBS_ItemID.Troposphere]={
	name='对流层',
	info='进入新房间时，33%概率获得一个原版额外主动 (类似{{Trinket154}}骰子袋)'..
		 '#!!! 受伤时，有33%概率交换第一主动和额外主动，并失去该道具'..
		 '#仅对部分原版道具生效',
},

[IBS_ItemID.MODE]={
	name='勤奋偶像',
	info='↑ + 1{{Luck}}幸运'..
		 '#在未清理的房间不断生成红小麦'..
		 '#↑ 拾取4个红小麦后，生成一个心魂火，并在本房间获得0.15{{Speed}}移速和0.25{{Tears}}射速',
},

[IBS_ItemID.LODI]={
	name='劳动明灯',
	info='填平沟壑'..
		 '#在未清理的房间生成一盏灯：'..
		 '#被角色接触时点亮7秒'..
		 '#点亮时，每隔3.5秒生成一个自动追击敌人的魂火'..
		 '#点亮时，穿过的眼泪有50%概率获得追踪和{{Collectible533}}三圣颂效果，且伤害+1',
},

[IBS_ItemID.ContactC]={
	name='接触的G',
	info='直接拾取道具时，记录当前房间道具池'..
		 '#下一个底座道具将被重置为记录道具池中的道具'..
		 '#对错误道具和任务道具无效',
},

[IBS_ItemID.MaxxC]={
	name='增殖的G',
	info='可使用2次'..
		 '#房间内每新生成一个敌人，获得一个品质不低于{{Quality2}}2的随机道具魂火',
	virtue='无魂火#提升道具魂火的血量',
	belial='道具魂火将来自恶魔道具池',
	void='无效',
},

[IBS_ItemID.Multiply]={
	name='增殖',
	info='清理{{BossRoom}}头目房后充能'..
		 '#消耗1充能'..
		 '#消灭所有非头目敌人，并生成等量的友好黑暗球'..
		 '#持有时，被黑暗球伤害过的敌人死亡后会生成友好黑暗球，直到13个',
	virtue='4个中环魂火，熄灭后生成1个友好黑暗球',
	belial='使用后至少生成6个黑暗球',
	void='吸收后只可触发持有时的效果',
},

[IBS_ItemID.SCP018]={
	name='018',
	info='持有时，获得一个球跟班：'..
		 '#{{Blank}} 抵挡敌弹'..
		 '#{{Blank}} 每次碰撞墙体后速度翻倍'..
		 '#{{Blank}} 伤害与速度和体型有关'..
		 '#{{Blank}} 命中敌人时加快该道具充能'..
		 '#{{Blank}} 切换房间时重置速度和体型'..
		 '#使用后，在当前房间增加球的体型和速度',
	virtue='球命中敌人时生成持续4秒的外环魂火',
	belial='球命中敌人时生成持续5秒的火焰',
	void='吸收后球跟班仍存在',
},

[IBS_ItemID.SneakyC]={
	name='潜伏的G',
	info='生成{{Trinket113}}战争蝗虫饰品'..
		 '#自动吞下{{Trinket113}}战争蝗虫饰品'..
		 '#双击 '..EID.ButtonToIconMap[ButtonAction.ACTION_DROP]..' 丢弃键扔下吞下的{{Trinket113}}战争蝗虫饰品'..
		 '#未清理的房间内，{{Trinket113}}战争蝗虫饰品每隔4秒生成1只战争蝗虫'..
		 '#房间内每新生成一个敌人，有25%概率生成1只战争蝗虫',
},

[IBS_ItemID.ConfrontingC]={
	name='对峙的G',
	info='房间内每新生成一个敌人，生成2只天启蝗虫'..
		 '#蓝苍蝇和蝗虫可以抵挡敌弹',
},

[IBS_ItemID.RetaliatingC]={
	name='应战的G',
	info='获得1个苍蝇道具魂火'..
		 '#生成品质{{Quality2}}2以下的道具时，将1个相同品质的道具移出道具池，并获得1个苍蝇道具魂火'..
		 '#对错误道具无效',
},

[IBS_ItemID.MasterRound]={
	name='胜者之弹',
	info='{{Heart}} + 1 心之容器，满血'..
		 '#秘密出口保持开启'..
		 '#不受惩罚性伤害完成{{BossRoom}}Boss房后，再生成一个{{Collectible'..(IBS_ItemID.MasterRound)..'}}胜者之弹'..
		 '#切换房间时重置受伤记录',
},

[IBS_ItemID.MasterPack]={
	name='大师组合包',
	info='生成4张卡牌，其中不包含塔罗牌，逆位塔罗牌，{{Card44}}规则卡和{{Card46}}自杀之王'..
		 '#{{Shop}} 商店中的一个卡牌商品将被替换为该道具',
},

[IBS_ItemID.RichMines]={
	name='富饶矿脉',
	info='生成所有矿石魂火'..
		 '#摧毁岩石时，有25%概率生成一个矿石魂火'..
		 '#部分岩石被摧毁时将额外产生特定魂火'..
		 '#9个相同的矿石魂火将变为特定道具魂火'..
		 '({{Collectible132}}{{Collectible201}}{{Collectible202}}{{Collectible68}}'..
		 '{{Collectible'..(IBS_ItemID.Diamoond)..'}})',
},

[IBS_ItemID.Panacea]={
	name='万能药',
	info='!!! {{ColorYellow}}一次性{{CR}}'..
		 '#{{Heart}} 满血'..
		 '#移除所有{{BrokenHeart}}碎心'..
		 '#角色属性不会低于基础{{Player0}}以撒'..
		 '#将所有疾病道具移出道具池'..
		 '#移除角色身上的疾病道具，每移除一个生成一个{{TreasureRoom}}宝箱房道具',
	virtue='无魂火#改为生成{{AngelRoom}}天使房道具',
	belial='改为生成{{DevilRoom}}恶魔房道具',
},

[IBS_ItemID.SmileWorld]={
	name='微笑世界',
	info='敌人额外受到 (0.1 x 角色持有道具数) 点伤害',
},

[IBS_ItemID.FGHD]={
	name='伪造地质学博士证',
	info='{{Bomb}} 炸弹 + 2'..
		 '#生成{{Card17}}塔'..
		 '#进入新房间时，摧毁所有普通石头，并在原位置生成刺石头或炸弹石头'..
		 '#↑ 摧毁障碍物后，本层获得0.02{{Damage}}伤害，且有3%概率生成一只标记石头蜘蛛'
},

[IBS_ItemID.SOG]={
	name='慷慨之魂',
	info='+ 2 {{SoulHeart}}魂心'..
		 '#部分特殊房间中额外生成一个乞丐'..
		 '#乞丐有42%概率返还资源'..
		 '#每捐助乞丐14次，触发{{Card51}}神圣卡效果，并消除一个{{BrokenHeart}}碎心'..
		 '#若无{{BrokenHeart}}碎心，获得0.5{{Luck}}幸运'
},

[IBS_ItemID.Clash]={
	name='交锋',
	info='↑ 每有一个攻击性道具，获得0.3{{Damage}}伤害'..
		 '#↓ 每有一个非攻击性道具，失去该道具给予的1{{Damage}}伤害'..
		 '#仅计算真正持有的道具'
},

[IBS_ItemID.TheBestWeapon]={
	name='全村最好的剑',
	info='+ 5 {{Damage}}伤害修正'..
		 '#敌人受到的伤害减少4',
	seijaBuff={
		desc = '敌人受到的伤害增加%s',
		data = {
			args = function(x) return 4*x end		
		}
	},
},

[IBS_ItemID.ThreeWishes]={
	name='三个愿望',
	info='根据情况生成三个掉落物',
	virtue="三个中环魂火，发射追踪眼泪",
	belial="不处于{{DevilRoom}}恶魔房时，将血量代价的道具纳入考虑范围"
},

[IBS_ItemID.ChestChest]={
	name='箱中箱宝库',
	info='吸收房间内的所有非空箱子'..
		 '#进入新层或下一局游戏时，生成两倍的同类型箱子',
	virtue="每吸收一个箱子，生成一个普通魂火",
	belial="生成的普通箱子有概率变为红箱子",
	void="无效",
	player={[IBS_PlayerID.BLost]='效果更改，需按住以操作：将箱子改造为武器/护甲/僚机，或修复它们'},
},

[IBS_ItemID.CheeseCutter]={
	name='奶酪切片器',
	info='Boss受到的伤害有10%概率增加18 ({{Luck}}幸运40：50%)'..
		 '#清理{{BossRoom}}Boss房后，生成一个半价硬币价格的道具 (独立道具池)',
},

[IBS_ItemID.Turbo]={
	name='内核加速',
	info='获得时，为主动道具充能至额外充能条'..
		 '#下一个底座道具将被替换为新的{{Collectible'..(IBS_ItemID.Turbo)..'}}内核加速，然后移除角色身上的所有{{Collectible'..(IBS_ItemID.Turbo)..'}}内核加速',
		 '#对错误道具和任务道具无效',
	seijaBuff={
		desc = '不替换，而是生成{{Collectible'..(IBS_ItemID.Turbo)..'}}内核加速',
		data = {
			append = function(x) 
				return (x > 1 and "#同时生成"..(x-1).."个电池"..(x>2 and 's' or '')) or ''
			end	
		}
	},		 
},

[IBS_ItemID.TreasureKey]={
	name='宝库钥匙',
	info='传送至一个临时{{ChestRoom}}宝库'..
		 '#获得{{GoldenKey}}金钥匙',
	virtue="不发射眼泪的内环魂火#熄灭时，生成箱子",
	belial="改为传送至{{CurseRoom}}诅咒房",
	void="不会触发传送效果",
	greed="贪婪模式：改为传送至错误房",
},

[IBS_ItemID.AKEY47]={
	name='AKEY-47',
	info='获得一把枪：'..
		 '#发射钥匙眼泪，具有50%角色伤害'..
		 '#射速为角色的两倍'..
		 '#继承角色眼泪特效',
	seijaNerf='没有{{Key}}钥匙时不能攻击；每次攻击有5%失去1{{Key}}钥匙',
},

[IBS_ItemID.SilverKey]={
	name='银之钥',
	info='在清理房间后充能，可充满两次'..
		 '#使用时，记录当前房间(仅部分可记录)和游戏计时'..
		 '#再次使用时，尝试将距离最近的房间重置为记录的房间，并回溯游戏计时'..
		 '#!!! 进入新层时，与上一次记录过的房间类型相同的房间将变为普通房间'..
		 '#所有{{Collectible'..(IBS_ItemID.SilverKey)..'}}'..'银之钥共享记录',
	virtue='无魂火#可记录{{AngelRoom}}天使房',
	belial='可记录{{DevilRoom}}恶魔房',
	void='无效',
	greed='贪婪模式：无效'
},

[IBS_ItemID.TruthChest]={
	name='真理宝箱',
	info='↑ {{Range}}射程 + 1.5'..
		 '#↑ {{Luck}}幸运 + 3'..
		 '#真理小子必定出现在{{SuperSecretRoom}}超级隐藏房中'..
		 '#必定可以唤醒真理小子',
},

[IBS_ItemID.Knock]={
	name='洞开之启',
	info='获得时，生成{{Card6}}教皇'..
		 '#每受伤5次，有30%概率生成{{Card6}}教皇'..
		 '#使用{{Card6}}教皇后，尝试开启红特殊房间；每开启一个特殊房间，获得1{{BrokenHeart}}碎心'..
		 '#进入{{UltraSecretRoom}}究极隐藏房时，清除5{{BrokenHeart}}碎心',
},

[IBS_ItemID.WilderingMirror]={
	name='迷途之镜',
	info='进入新层时，除{{BossRoom}}头目房和{{UltraSecretRoom}}究极隐藏房外，在特殊房间周围生成红房间，并揭示所有红房间'..
		 '#受到惩罚性伤害时，有50%概率移除该道具，获得{{CurseLost}}迷途诅咒，并生成{{Collectible'..(IBS_ItemID.WilderingMirror2)..'}}破损的迷途之镜',
},

[IBS_ItemID.WilderingMirror2]={
	name='破损的迷途之镜',
	info='!!! {{ColorYellow}}一次性{{CR}}'..
		 '#消耗10{{Coin}}硬币，移除{{CurseLost}}迷途诅咒，并获得{{Collectible'..(IBS_ItemID.WilderingMirror)..'}}迷途之镜',
	virtue='无魂火',
	belial='无效',
},

[IBS_ItemID.MoonStreets]={
	name='月下异巷',
	info='进入普通房间时 (非初始房间)，传送至一个未进入过的特殊房间'..
		 '#不会传送到{{UltraSecretRoom}}究极隐藏房'..
		 '#免疫{{CurseRoom}}诅咒房门的伤害',
},

[IBS_ItemID.Fomalhaut]={
	name='北落师门',
	info='角色免疫火焰和爆炸'..
		 '#敌人首次受伤时，生成持续18秒的蓝火',
},

[IBS_ItemID.LuckEnchantment]={
	name='幸运附魔',
	info='↑ {{Luck}}幸运 + 3'..
		 '#敌人额外受到 20% x {{Luck}}幸运 点伤害 (取绝对值)'
},

[IBS_ItemID.TheHornedAxe]={
	name='双角斧',
	info='↑ {{Damage}}伤害 + 1.3'..
		 '#每隔13秒，若房间内存在敌人，则触发{{Card14}}死亡和{{Card69}}死亡?的效果'
},

[IBS_ItemID.LightBarrier]={
	name='光之结界',
	info='获得时，生成正逆塔罗牌各一张'..
		 '#清理房间后，反转角色身上的塔罗牌'..
		 '#进入新层时，生成一张塔罗牌；若生成的是逆位塔罗牌，该道具本层失效'
},

[IBS_ItemID.ChillMind]={
	name='冷静头脑',
	info='↓ {{Shotspeed}}弹速 x 89%'..
		 '#{{Shop}} 商店中额外生成硬币代价的两个道具和{{Collectible76}}X光透视'..
		 '#!!! {{Shop}}商店中存在{{Collectible76}}X光透视时不能购买其他道具'
},

[IBS_ItemID.LownTea]={
	name='免茶',
	info='+ 1 {{Heart}}心之容器'..
		 '#治疗1{{Heart}}红心',
	eater='↑ + 0.5 {{Damage}}伤害'..
		  '#↓ - 0.03 {{Speed}}移速'..
		  '#蓝苍蝇数量少于该道具数量的四倍时，每秒生成一只'
},

[IBS_ItemID.TheEyeofTruth]={
	name='真实之眼',
	info='+ 1 {{SoulHeart}}魂心'..
		 '#↑ + 2 {{Range}}射程'..
		 '#显示掉落物和敌人的ID'
},

[IBS_ItemID.Turbine]={
	name='涡轮',
	info='根据机器触发效果：'..
		 '#{{Slotmachine}} 赌博机：生成两个掉落物'..
		 '#{{BloodDonationMachine}} 献血机：生成两个随机心'..
		 '#{{FortuneTeller}} 预言机：生成{{SoulHeart}}魂心或饰品'..
		 '#{{RestockMachine}} 补货机：重置道具或补货'..
		 '#{{CraneGame}} 抓娃娃机：摧毁，然后生成展示的道具'..
		 '#以上均未触发：获得{{Card11}}命运之轮',
	virtue='内环魂火，发射{{Collectible494}}雅各布天梯眼泪',
	belial='无特殊效果',
},

[IBS_ItemID.RedHook]={
	name='红钩',
	info='↑ + 0.3 {{Damage}}伤害'..
		 '#每层都会获得{{CurseDarkness}}黑暗诅咒，但不会获得其他诅咒'..
		 '#有{{CurseDarkness}}黑暗诅咒时，'..
		 '#{{Blank}} 敌人受到的伤害 (16 + 8 x 楼层数)% 概率变为双倍'..
		 '#!!! 角色受到的惩罚性伤害有一半概率变为双倍',
},

[IBS_ItemID.OvO]={
	name='OvO',
	info='↑ + 0.3 {{Speed}}移速'..
		 '#攻击并石化接近的敌人，造成66.6%角色伤害，最多20次'..
		 '#切换房间后重置次数',
	greed='贪婪模式：切换波次后重置次数'
},

[IBS_ItemID.DanishGambit]={
	name='丹麦弃兵',
	info='无需满充能即可使用'..
		 '#充能未满时使用，将吸收饰品和品质{{Quality1}}1及以下的道具以充能 (包括正在拾取的)'..
		 '#可为额外充能条充能'..
		 '#充能已满时使用，将重置品质{{Quality3}}3及以下的道具为品质+1的随机道具，但不会超过3',
	virtue='无魂火#道具池为{{AngelRoom}}天使房',
	belial='道具池为{{DevilRoom}}恶魔房',
	void='无效',
},

[IBS_ItemID.HyperBlock]={
	name='超能格挡',
	info='获得3秒护盾，和一个魂石或伪忆'..
		 '#即将受伤时充能1~3格，若满充能且伤害具有惩罚性则自动触发该道具效果'..
		 '#三次可用；清理{{BossRoom}}Boss房后恢复一次'..
		 '#!!! {{ColorYellow}}次数耗尽后移除{{CR}}',
	virtue='无魂火#即将受伤时，额外充能1格',
	belial='无特殊效果',
	void='不限次数',
},

[IBS_ItemID.FusionHammer]={
	name='融合之锤',
	info='↑ + 0.75 {{Damage}}伤害'..
		 '#拾取时，熔炼当前饰品并将其变为金色版本'..
		 '#所有饰品掉落物变为金色版本'..
		 '#!!! 不能再替换或丢弃饰品',
},

[IBS_ItemID.SangenSummoning]={
	name='杯满的灿幻庄',
	info='↑ + 0.5 {{Damage}}伤害'..
		 '#在已清理的房间免疫惩罚性伤害'..
		 '#该道具从角色身上移除后，角色{{Damage}}伤害翻倍'
},

[IBS_ItemID.PeacePipe]={
	name='宁静烟斗',
	info='清理房间后增加3计数 (大房间为6)'..
		 '#消耗1计数，选择将一个道具移出道具池，并减少游戏计时5秒'..
		 '#!!! 同时也会从角色身上移除选择的道具，但会返还 (品质^2 + 1)计数',
	virtue='无魂火#↑ + 0.005 {{Tears}}射速',
	belial='↑ + 0.01 {{Damage}}伤害',
	void='无效'
},

[IBS_ItemID.Yongle]={
	name='永乐大典',
	info='触发一些书主动道具的效果，那些道具的充能总和至少达20'..
		 '#每局序列固定',
	virtue='生成对应魂火',
	belial='无特殊效果',
},

[IBS_ItemID.HexaVessel]={
	name='六魂容器',
	info='攻击时，每1.2秒生成一个特殊魂火,最多6个'..
		 '#停止攻击时，熄灭魂火并释放火焰'
},

[IBS_ItemID.Flex]={
	name='活动肌肉',
	info='↑ + 2.5 {{Damage}}伤害修正'..
		 '#清理房间后，移除2点伤害加成'..
		 '#再次清理房间后，恢复2点伤害加成'
},

[IBS_ItemID.SignatureMove]={
	name='招牌技',
	info='↑ + 30 / (攻击性 - 非攻击性道具数量) {{Damage}}伤害'..
		 '#仅计算真正持有的道具'..
		 '#攻击性道具将有一个非攻击性道具作为轮换',
	seijaNerf='攻击性道具将直接被替换而不是轮换'
},

[IBS_ItemID.DoubleDosage]={
	name='双倍剂量',
	info='#复制其他被动注射器道具，对之后的道具也生效'..
		 '#!!! 拾取注射器道具后，若拥有超过11个注射器道具，则立刻死亡',
},

[IBS_ItemID.HolyInjection]={
	name='注射型圣水',
	info='#↑ + 2 {{Luck}}幸运'..
		 '#清理房间后，有3%概率移除1{{BrokenHeart}}碎心，并获得{{HalfSoulHeart}}半魂心'..
		 '#每持有一个注射器或天使道具，概率增加1%',
},

[IBS_ItemID.KilleR]={
	name='R剑',
	info='↑ + 0.16 {{Damage}}伤害'..
		 '#按住重开键时，逐渐获得最高230%{{Damage}}伤害倍率，否则衰减'..
		 '#倍率达到130%时，眼泪追踪',
},

[IBS_ItemID.VeinMiner]={
	name='连锁挖掘',
	info='#{{Bomb}} 炸弹 + 5'..
		 '#岩石，大便或火堆被摧毁时，摧毁房间内所有同类',
},

[IBS_ItemID.VainMiner]={
	name='帘锁挖掘',
	info='#每层首个因拾取道具留下的空底座，将被重置为id相邻的非任务道具'..
		 '#10.9%概率重置失败; 没有对应id时也视为失败'..
		 '#重置失败的空底座将变为错误道具',
},

[IBS_ItemID.PUC]={
	name='杯水',
	info='#35%概率为底座道具添加来自{{IBSMOD}}愚昧的道具作为轮换'..
		 '#任意角色持有{{Collectible'..(IBS_ItemID.Goatify)..'}} 变羊术时，概率翻倍'..
		 '#对任务道具无效',
},

[IBS_ItemID.SaleBomb]={
	name='促销炸弹',
	info='{{Bomb}} 角色炸弹爆炸后，其周围每个硬币价格的掉落物减少1~2价格，并生成对应数量的{{Coin}}硬币'
},

[IBS_ItemID.Diecry]={
	name='日寄',
	info='在当前房间获得{{Collectible1}}悲伤洋葱效果',
	virtue='内环魂火，射速较快',
	belial='额外获得一次效果',
},

[IBS_ItemID.ReusedStory]={
	name='套作',
	info='记录最后一次进入的非红房间的特殊房间'..
		 '#在新层生成与记录相同的红房间，并揭示其位置'..
		 '#可记录：'..
		 '{{Shop}}'..
		 '{{TreasureRoom}}'..
		 '{{Planetarium}}'..
		 '{{SecretRoom}}'..
		 '{{SuperSecretRoom}}'..
		 '{{UltraSecretRoom}}'..
		 '{{Library}}'..
		 '{{AngelRoom}}'..
		 '{{DevilRoom}}'..
		 '{{CursedRoom}}'..
		 '{{ArcadeRoom}}'..
		 '{{DiceRoom}}'..
		 '{{ChestRoom}}'..
		 '{{IsaacsRoom}}'..
		 '{{BarrenRoom}}'..
		 '{{SacrificeRoom}}'..
		 '{{ErrorRoom}}',
},

[IBS_ItemID.Zoth]={
	name='索斯星',
	info='每层首次进入{{BossRoom}}头目房时，重置未探索过的特殊房间的房间类型'..
		 '#{{BossRoom}}头目房和{{UltraSecretRoom}}究极隐藏房不会被重置'
},

[IBS_ItemID.PageantFather]={
	name='盛装教父',
	info='吞下六个金色硬币饰品 (不包含{{Trinket24}}屁股硬币和{{Trinket172}}诅咒硬币)'..
		 '#生成1个{{Crafting26}}金硬币',
},

[IBS_ItemID.DeciduousMeat]={
	name='剥落古老肉',
	info='+ 1 {{Heart}}心之容器'..
		 '#+ 12 {{RottenHeart}}腐心'..
		 '#受伤时有25%概率生成一个{{RottenHeart}}腐心',
	player={[PlayerType.PLAYER_BETHANY_B]='+ 12{{Heart}}红心充能'}
},

[IBS_ItemID.CurseSyringe]={
	name='诅咒针剂',
	info='↑ + 0.3 {{Damage}}伤害'..
		 '#↑ 本局每遇到过一种诅咒，+ 0.3{{Damage}}伤害'
},

[IBS_ItemID.AstroVera]={
	name='星际芦荟',
	info='心上限 + 10，仅对红心角色和魂心角色生效 (不包括{{Player17}}遗骸之魂)'..
		 '#+ 10 {{SoulHeart}}魂心'
},

[IBS_ItemID.SecretAgent]={
	name='秘密特工',
	info='选择移除一个角色身上的道具'..
		 '#再次使用将生成被移除的道具',
	virtue='选择空位将记录{{Collectible33}}圣经',
	belial='选择空位将记录{{Collectible51}}五芒星',
	void='无效',
},

[IBS_ItemID.CurseoftheFool]={
	name='愚者之诅咒',
	info='累计受伤11次后，触发{{Card'..Card.CARD_REVERSE_FOOL..'}}愚者？和{{Card'..Card.CARD_FOOL..'}}愚者',
	seijaBuff={
		desc = '触发时生成1个{{Card'..Card.CARD_DICE_SHARD..'}}骰子碎片',
		data = {
			append = function(x) 
				return (x > 1 and "#触发时额外生成"..(x-1).."{{Card"..Card.CARD_DICE_SHARD.."}}个骰子碎片") or ''
			end
		},
	},
},

[IBS_ItemID.UnburntGod]={
	name='焚烧不焚之神',
	info='使用后，吞下随机金饰品，并生成1个不发射眼泪的魂火'..
		 '#该魂火熄灭时，移除最后吞下的金饰品',
	virtue='魂火血量翻倍',
	belial='无特殊效果',
},

[IBS_ItemID.MyFruit]={
	name='我果',
	info='通清理非红房间充能'..
		 '#使用后：'..
		 '#+ 2{{SoulHeart}}魂心'..
		 '#本层暂停游戏计时'..
		 '#移除所有诅咒，并获得1个祝福'..
		 '#揭示并重设所有房间为红房间，部分房间除外'..
		 '#!!! 使用四次后移除该道具'..
		 '#{{Blank}} (按下'..EID.ButtonToIconMap[ButtonAction.ACTION_MAP]..'地图键查看祝福效果)',
	virtue='不发射眼泪的中环魂火#此魂火在持有该道具时不会受伤',
	belial='无特殊效果',
	void='!!! {{ColorYellow}}一次性{{CR}}',
	greed='贪婪模式：重载楼层，然后传送至初始房间',
},

[IBS_ItemID.MyFault]={
	name='我过',
	info='无敌0.5秒'..
		 '#产生一次血波，使周围的敌人失去 {{Damage}}角色伤害x2 的生命，并获得8秒流血'..
		 '#命中流血的敌人时会在其位置再产生一次血波，并刷新流血持续时间',
	virtue='不发射眼泪的外环单房间魂火',
	belial='无敌时间延长至1秒',
},

[IBS_ItemID.Memento]={
	name='某纪念品',
	info='{{Damage}} 伤害不会低于7',
},

[IBS_ItemID.RubbishBook]={
	name='惊天秘密',
	info='如此这般这般如此',
	virtue='无魂火',
	belial='无效果',
	seijaBuff={
		desc = '+ %s{{Coin}}硬币',
		data = {
			args = function(x) return x end		
		}
	},
},

[IBS_ItemID.MawBank]={
	name='巨口储蓄罐',
	info='清理房间后，生成2个{{Coin}}硬币'..
		 '#!!! 花费{{Coin}}硬币购买掉落物时，移除该道具',
},

[IBS_ItemID.FolkPrescription]={
	name='偏方',
	info='地面装饰物有13%概率变为可采集状态：站在其附近一段时间可将其变为{{Pill}}药丸'..
		 '#!!! 那个药丸的对应效果将变回未识别状态'..
		 '#{{Pill}} 使用非负面药丸时，治疗1{{Heart}}红心',
},

[IBS_ItemID.WhiteQBall]={
	name='灰白色母球',
	info='拾取时，生成1个{{Rune}}符文'..
		 '#↓ - 0.16 {{Shotspeed}}弹速'..
		 '#{{AngelDevilChance}} + 15% {{DevilRoom}}恶魔房开启率，+ 100% {{AngelRoom}}天使房转化率，直到下一次{{AngelRoom}}天使房开启',
},

[IBS_ItemID.DonaldDollar]={
	name='金圆券',
	info='大部分硬币变为 {{Crafting10}}铸币'..
		 '#!!! 道具价格 x 7',
},

[IBS_ItemID.TempFolder]={
	name='临时文件夹',
	info='拾取时，+ 1 {{EmptyBoneHeart}}骨心，并熔炼当前饰品的复制'..
		 '#↑ {{Coin}}硬币，{{Key}}钥匙和{{Bomb}}炸弹的上限 + 49'..
		 '#进入新层时，丢下多余99的部分，最多49'..
		 '#若准备丢下的足够多，改为生成以下对应道具，每种最多一个：'..
		 '#{{Blank}} {{Collectible74}}(25{{Coin}})，{{Collectible623}}(5{{Key}})，{{Collectible19}}(10{{Bomb}})'
},

[IBS_ItemID.Loong]={
	name='龙',
	info='飞行'..
		 '#攻击时，在角色位置留下火焰',
},

[IBS_ItemID.OOC]={
	name='贞洁之誓',
	info='拾取时，+ 2 {{SoulHeart}}魂心'..
		 '#↑ + 3 {{Luck}}幸运'..
		 '#秒杀乌列和加白列'..
		 '#每层的前7次惩罚性伤害变为非惩罚性，并降低至半心'..
		 '#!!! 受到惩罚性伤害时失去该道具',
},

[IBS_ItemID.MM]={
	name='悠悠',
	info='↑ + 0.3 {{Damage}}伤害'..
		 '#↑ + 0.1 {{Speed}}移速'..
		 '#若在{{AngelRoom}}天使房内被直接拾取，额外获得两个该道具',
},

[IBS_ItemID.MimicInfestation]={
	name='遍地宝箱怪',
	info='所有箱子具有{{HauntedChest}}闹鬼箱子的特性'..
		 '#进入新房间时有6%概率生成一个{{GoldenChest}}金箱子',
	seijaBuff={
		desc = '+ 10%概率；房间内存在捣蛋小鬼时，角色无敌',
		data = {
			append = function(x) 
				return (x > 1 and "#+ "..(10*(x-1)).."%概率") or ''
			end
		},		
	}
},

[IBS_ItemID.CardboardMush]={
	name='纸板蘑菇',
	info='拾取时，生成3个卡牌'..
		 '#消耗卡牌时，触发{{Card12}}力量的效果',
},

[IBS_ItemID.Transmogrify]={
	name='变形术',
	info='将离角色最近的道具重置为{{Quality1}}品质1的道具'..
		 '#1%概率重置为{{Collectible'..(IBS_ItemID.CheeseCutter)..'}}奶酪切片器',
	virtue='不发射眼泪的中环魂火；接触非头目敌人时有10%概率将其变为苍蝇',
	belial='无特殊效果',
	void='无效',
},

[IBS_ItemID.SpiritPoop]={
	name='精灵便便',
	info='{{CurseRoom}}诅咒房将被替换为{{SuperSecretRoom}}超级隐藏房'..
		 '#{{SuperSecretRoom}} 超级隐藏房的门自动开启',
},

[IBS_ItemID.CalocybeGambosa]={
	name='圣乔治蘑菇',
	info='拾取时，获得3{{SoulHeart}}魂心'..
		 '#{{SacrificeRoom}} 献祭房内额外生成两个地刺',
},

[IBS_ItemID.AFaces]={
	name='一张张脸',
	info='拾取时，吞下其中一个饰品：',
},

[IBS_ItemID.BigSlurp]={
	name='超大杯',
	info='拾取时，生成两个{{Collectible197}}耶稣果汁',
},

[IBS_ItemID.BobsRottenHand]={
	name='鲍勃的烂手',
	info='攻击时，发射一个爆炸眼泪，造成 100%{{Damage}}角色伤害'..
		 '#直到停止攻击前，不会再发射',
},

[IBS_ItemID.Armageddon]={
	name='哈米吉多顿',
	info='每层尽可能生成并揭示头目车轮战房间'..
		 '#头目车轮战房间内：'..
		 '#{{Blank}} 道具可以全部拾取'..
		 '#{{Blank}} 道具选择 + 1'..
		 '#{{Blank}} 敌人每秒失去12%血量',
	seijaNerf="不生成头目车轮战房间"
},

[IBS_ItemID.MomsOldKey]={
	name='妈妈的旧钥匙',
	info='进入新层时，+ 2 {{Key}}钥匙'..
		 '#{{Chest}}普通箱子有50%概率变为{{DirtyChest}}旧箱子',
},

[IBS_ItemID.BeggarMedal]={
	name='乞丐章',
	info='!!! {{ColorYellow}}一次性{{CR}}'..
		 '#获得{{Collectible144}}乞丐朋友，{{Collectible278}}黑暗乞丐和{{Collectible388}}钥匙乞丐'..
		 '#在新层移除以上道具',
	virtue='获得{{Collectible'..(IBS_ItemID.SOG)..'}}慷慨之魂的道具魂火',
	belial='不移除{{Collectible278}}黑暗乞丐',
},

[IBS_ItemID.SlowStart]={
	name='慢启动',
	info='↓ {{Speed}}移速 - 0.5'..
		 '#↑ 5分钟后，{{Speed}}移速 + 0.5，{{Damage}}伤害 x 150%'..
		 '#在新层重置计时，每经过一层计时缩短20秒',
},

[IBS_ItemID.BrokenRKey]={
	name='损坏的R键',
	info='!!! {{ColorYellow}}一次性{{CR}}'..
		 '#丢下等同于楼层数的被动道具，具有随机道具作为轮换'..
		 '#重置游戏计时和道具池'..
		 '#对错误道具和任务道具无效',
	virtue='无魂火#28%概率为天使房道具',
	belial='额外获得{{Collectible51}}五芒星',
},

[IBS_ItemID.ADTime]={
	name='广告时间',
	info='角色死亡时播放赞助者名单，之后原地满血复活'..
		 '#!!! 播放完成前退出会导致复活失败',
},

[IBS_ItemID.DMGTransmitter]={
	name='伤害传输器',
	info='使用后，失去1{{Damage}}伤害，敌人在本局额外受到2点伤害'..
		 '#!!! {{Damage}}伤害高于3.5时才能使用',
	virtue='内环魂火，发射{{Collectible494}}雅各布天梯眼泪',
	belial='敌人在本局额外受到1.3点伤害',
},

[IBS_ItemID.Posture]={
	name='架势！',
	info="拾取时，生成{{Card1}}愚者"..
		 '#通过清理房间，造成伤害或受伤充能，可充满两次'..
		 '#在已清理的房间，可收集最多5张塔罗牌'..
		 '#使用后，14秒内获得附加的近战攻击',
	virtue='无效果',
	belial='无效果',		 
	player={[IBS_PlayerID.BSamson] = "切换至下一张牌，在不同姿态下使用具有额外效果；具有可收集逆位塔罗牌的额外栏位"}
},

[IBS_ItemID.BlessingOfMichael]={
	name='米迦勒的赐福',
	info='拾取时，将品质低于{{Quality4}}4的{{AngelRoom}}天使房道具移出道具池，并生成一个{{Quality4}}品质4{{AngelRoom}}天使房道具'..
		 '#增强原版{{Quality4}}品质4的{{AngelRoom}}天使房道具'..
		 '#!!! 无法拾取{{DevilRoom}}恶魔房内的血量交易道具',
	seijaNerf='改为直接获得那个道具',
},

[IBS_ItemID.LordsParasol]={
	name="领主阳伞",
	info='{{Shop}} 首次进入一个商店时，持续获得其中的道具'..
		 '#!!! {{ColorRed}}若获得的道具为主动，会替换持有的主动道具{{CR}}',
},

[IBS_ItemID.BloodyRose]={
	name='血染玫瑰',
	info='为新房间内的道具生成尖刺环绕的道具作为选择'..
		 '#!!! {{ColorRed}}存在{{Quality2}}品质2的道具时，不能拾取其他品质的道具{{CR}}',
},

[IBS_ItemID.PreservedFog]={
	name='腌制活雾',
	info='直接拾取道具时，从道具池中移除3个品质最低且低于{{Quality3}}3的道具 (拾取该道具也会生效)'..
		 '#!!! {{ColorRed}}每层首个道具将被替换为{{Card41}}黑符文{{CR}}',
},

[IBS_ItemID.Fiddle]={
	name='小提琴',
	info='进入新层时，生成两个随机被动道具'..
		 '#!!! {{ColorRed}}除了{{BossRoom}}头目房，进入房间0.1秒后出现的非任务道具将被移除{{CR}}',
},

[IBS_ItemID.WhisperingEarring]={
	name='低语耳环',
	info='↑ {{Damage}} 伤害 x 1.5'..
		 '#!!! {{ColorRed}}在未清理房间内的前13秒，随机反转射击操作{{CR}}',
},

[IBS_ItemID.SereTalon]={
	name='原初之爪',
	info="拾取时，生成3个{{Card49}}骰子碎片"..
		 '#{{Card49}} 骰子碎片的效果更改：将道具重置为{{Quality2}}品质2及以上的道具'..
		 '#!!! {{ColorRed}}使用{{Card49}}骰子碎片时，获得随机{{Quality0}}品质0被动道具{{CR}}',
},

[IBS_ItemID.MusicBox]={
	name='音乐盒',
	info='直接拾取攻击性被动道具时，生成对应的道具魂火'..
		 "#对错误道具和任务道具无效",
},

[IBS_ItemID.JeweledMask]={
	name='宝石面具',
	info='进入新层时，生成一个角色已有被动道具的复制 (包括非真正持有的)'..
		 '#对错误道具和任务道具无效',
},

[IBS_ItemID.ChoicesParadox]={
	name='选择悖论',
	info='进入新层时，生成5个符文，但只能拿一个',
},

[IBS_ItemID.DistinguishedCape]={
	name='卓越斗篷',
	info='获得3个模仿角色眼泪攻击的灵魂跟班，但只有30%{{Damage}}伤害'..
		 '#即将受伤时，消耗一个灵魂跟班代替'..
		 '#进入新层时，补齐3个灵魂跟班',
},

[IBS_ItemID.AzazelTheWild]={
	name='阿撒泻勒的旷野',
	info='{{Collectible118}} 攻击时，每隔3秒，发射短程硫磺火'
},

[IBS_ItemID.Kindness]={
	name='宽容',
	info='攻击时有概率获得1秒护盾，但有0.5秒不能操作',
	seijaBuff={
		desc = '允许操作',
		data = {
			append = function(x) 
				return ''
			end
		},
	},
},

[IBS_ItemID.Beg]={
	name='乞讨',
	info='5%概率令一个非头目敌人消失，并留下一个{{Coin}}硬币',
	virtue='成功时生成一个普通魂火',
	belial='成功时生成一个{{Bomb}}炸弹',
},

[IBS_ItemID.BrokenTV]={
	name='损坏的电视',
	info='使用后，丢下该道具'..
		 '#进入商店时，有20%概率花费所有{{Coin}}硬币，将该道具变为{{Collectible633}}教条'..
		 '#{{Blank}} (至少需要1{{Coin}}硬币生效)',
	virtue='概率翻倍',
	belial='使用后，失去该道具，并获得1{{Damage}}伤害',
	void='无效'
},

[IBS_ItemID.FamilyPortrayal]={
	name='全家祸',
	info='获得原版所有被动任务道具，除了{{Collectible668}}爸爸的便条',
},

}
--------------------------------------------------------
--------------------------饰品--------------------------
--------------------------------------------------------
local trinketEID={

[IBS_TrinketID.BottleShard]={
	name='酒瓶碎片',
	info='10%概率令受伤的敌人额外受到3点穿甲伤害，并进入6秒流血状态',
	mult={
		numberToMultiply = 10,
		maxMultiplier = 3,
	}	
},

[IBS_TrinketID.DadsPromise]={
	name='爸爸的约定',
	info='{{BossRoom}} 在进入新层后的 (60 + 15 x 楼层数) 秒内完成Boss房，生成1个{{Card49}}骰子碎片',
	mult={findReplace = {'15','20','25'}}
},

[IBS_TrinketID.GamblersEye]={
	name='赌徒之眼',
	info='接触品质低于{{Quality1}}1的非任务道具会将其重置，但有20%概率消失',
	mult={findReplace = {'{{Quality1}}1', '{{Quality2}}2', '{{Quality2}}2'}}
},

[IBS_TrinketID.BaconSaver]={
	name='骨猪一掷',
	info='受到惩罚性伤害时，移除该饰品，并触发{{Card56}}愚者?和{{Card49}}骰子碎片效果',
},


[IBS_TrinketID.DivineRetaliation]={
	name='神圣反击',
	info='30%概率免疫泪弹伤害#被泪弹击中时，将周围的所有泪弹变为火焰',
	mult={
		numberToMultiply = 30,
		maxMultiplier = 3,
	}	
},

[IBS_TrinketID.ToughHeart]={
	name='硬的心',
	info='15%概率免疫伤害#受伤会使概率增加25%，直到下一次免伤#对自伤无效',
	mult={
		numberToMultiply = 25,
		maxMultiplier = 3,
	}
},

[IBS_TrinketID.ChaoticBelief]={
	name='混沌信仰',
	info='首次获得，+ 100%{{AngelRoom}}天使房转换率，+ 1 {{EternalHeart}}永恒之心和{{BlackHeart}}黑心，并视为一次恶魔交易'..
		 '#{{AngelRoom}} 天使房转换率 + 50%'..
		 '#{{Room}} 普通房间内{{Heart}}红心受伤不再影响恶魔/天使房开启率',
	mult={
		numberToMultiply = 50,
		maxMultiplier = 2,
	}	
},

[IBS_TrinketID.ThronyRing]={
	name='荆棘指环',
	info='受伤时，13%概率触发以下的一项'..
		 '#{{BrokenHeart}} 50%消除一个碎心，没有则触发下一项'..
		 '#{{SoulHeart}} 25%获得一个魂心'..
		 '#{{AngelRoom}} 15%天使房转换率 + 10%，并清除诅咒'..
		 '#{{EternalHeart}} 10%获得一个永恒之心',
	mult={
		numberToMultiply = 13,
		maxMultiplier = 3,
	}	
},

[IBS_TrinketID.PresentationalMind]={
	name='表观思维',
	info='每持有3个{{Coin}}硬币，+ 1.3% {{DevilRoom}}恶魔房开启率',
	mult={
		numberToMultiply = 1.3,
		maxMultiplier = 3,
	}	
},

[IBS_TrinketID.Export]={
	name='出口产品',
	info='50%概率恶魔房中额外生成金钱代价的天使房道具，天使房中额外生成血量代价的恶魔房道具(不算作恶魔交易)',
	mult={
		numberToMultiply = 50,
		maxMultiplier = 2,
	}
},

[IBS_TrinketID.Nemesis]={
	name='天谴报应',
	info='{{Damage}} 受伤时，对攻击者造成7倍角色伤害',
	mult={
		numberToMultiply = 7,
		maxMultiplier = 3,
	}	
},

[IBS_TrinketID.Barren]={
	name='贫瘠',
	info='敌人受到的伤害增加50%'..
		 '#角色受到的伤害增加半心'..
		 '#心，硬币，钥匙，炸弹掉落物在会3秒内消失',
	mult={
		numberToMultiply = 3,
		maxMultiplier = 3,
	}	
},

[IBS_TrinketID.LeftFoot]={
	name='左断脚',
	info='进入新层时，生成2个红箱子，失去0.06{{Speed}}移速'..
		 '#{{Speed}} 移速低于0.6时无效',
	mult={
		numberToMultiply = 2,
		maxMultiplier = 3,
	}	
},

[IBS_TrinketID.RabbitHead]={
	name='兔头',
	info='↑ 普通房间内，{{Luck}}幸运 + 3.5',
	mult={
		numberToMultiply = 3.5,
		maxMultiplier = 3,
	}	
},

[IBS_TrinketID.LunarTwigs]={
	name='月桂枝',
	info='进入新房间时，获得1临时{{IBSIronHeart}}坚贞之心',
	player={[IBS_PlayerID.BMaggy]='效果改为获得额外{{IBSIronHeart}}坚贞之心'},
	mult={
		numberToMultiply = 1,
		maxMultiplier = 3,
	}
},

[IBS_TrinketID.Interval]={
	name='区间',
	info='额外造成角色第一主动道具与最后获得的道具ID差额0.5%的伤害',
	mult={
		numberToMultiply = 0.5,
		maxMultiplier = 3,
	}
},

[IBS_TrinketID.NumeronForce]={
	name='源数之力',
	info='即将消耗卡牌时，取消其效果，'..
		 '并根据角色{{Heart}}红心，{{SoulHeart}}魂心和{{BlackHeart}}黑心数量决定效果：'..
		 '#>6：原卡牌效果'..
		 '#[4,6)：{{Card14}}死亡+{{Card69}}死亡?'..
		 '#[3,4)：{{Card4}}皇后+{{Card16}}恶魔'..
		 '#[2,3)：{{Card12}}力量+{{Card52}}变巨术'..
		 '#[0,2)：{{Card51}}神圣卡+{{Card67}}力量?' ,
	mult={append = '卡牌效果翻倍'}
},

[IBS_TrinketID.WheatSeeds]={
	name='小麦种子',
	info='吞下并清理房间后，变为麦苗I#受伤或进入新层时自动吞下该饰品',
},

[IBS_TrinketID.CorruptedDeck]={
	name='腐蚀套牌',
	info='获得时，生成两个正塔罗牌'..
		 '#清理房间后6%概率生成一个正塔罗牌'..
		 '#消耗任意塔罗牌时，房间内点数更低的正塔罗牌将变为逆塔罗牌',
	mult={
		numberToMultiply = 6,
		maxMultiplier = 3,
	}		 
},

[IBS_TrinketID.GlitchedPenny]={
	name='错误硬币',
	info='拾取普通硬币时，有15~100%概率将其重置为随机硬币',
	mult={findReplace = {'15','20','25'}}
},

[IBS_TrinketID.StarryPenny]={
	name='星空硬币',
	info='拾取硬币时，{{Planetarium}}星象房开启率 + 0.1%，并有(20 + 5 x 面值)%概率生成{{Card55}}符文碎片',
	mult={findReplace = {'20','30','40'}}
},

[IBS_TrinketID.PaperPenny]={
	name='纸质硬币',
	info='拾取硬币时，有(15 + 3 x 面值)%概率生成一个书主动道具的魂火',
	mult={
		append = {'判定两次', '判定三次'}
	}
},

[IBS_TrinketID.CultistMask]={
	name='邪教徒头套',
	info='你觉得自己有开腔的欲望',
	mult={
		append = {'你觉得自己更有开腔的欲望', '你觉得自己更有开腔的欲望#{{ColorGold}}你觉得自己非常有开腔的欲望{{CR}}'}
	}
},

[IBS_TrinketID.SsserpentHead]={
	name='蛇的头',
	info='进入新的{{SecretRoom}}隐藏房，{{SuperSecretRoom}}超级隐藏房或{{UltraSecretRoom}}究极隐藏房时，'..
		 '生成5个硬币',
	mult={
		numberToMultiply = 5,
		maxMultiplier = 3,
	}	
},

[IBS_TrinketID.ClericFace]={
	name='牧师的脸',
	info='清理14个房间后，若{{Heart}}心之容器数量少于5，获得1{{EternalHeart}}永恒之心，否则获得1{{HalfSoulHeart}}半魂心'..
		 '#同时生成{{Card51}}神圣卡',
	mult={
		numberToMultiply = 114514,
		maxMultiplier = 3,	
		append = {'双倍效率', '三倍效率'}
	},
},

[IBS_TrinketID.NlothsMask]={
	name='恩洛斯的脸',
	info='下一个底座道具将被替换为1个{{Collectible515}}神秘礼物，然后移除该饰品'..
		 '#对错误道具和任务道具无效',
	mult={
		numberToMultiply = 1,
		maxMultiplier = 3,
	},
},

[IBS_TrinketID.GremlinMask]={
	name='地精容貌',
	info='进入有敌人的房间时，角色获得1秒恐惧，敌人获得5秒恐惧和4秒虚弱',
	mult={
		numberToMultiply = 4,
		maxMultiplier = 3,
	},
},

[IBS_TrinketID.OldPenny]={
	name='古老硬币',
	info='拾取硬币时，游戏计时减少 (5 x 面值) 秒，若游戏计时少于10分钟，有25%概率生成一个随机掉落物',
	mult={
		numberToMultiply = 5,
		maxMultiplier = 3,
	}
},

[IBS_TrinketID.CrackCallback]={
	name='踩背腿',
	info='角色免疫践踏和落石的伤害'..
		 '#受伤时，有30%概率触发{{Card3}}女祭司的效果',
	mult={
		numberToMultiply = 30,
		maxMultiplier = 3,
	}
},

[IBS_TrinketID.Foe]={
	name='杜弗尔的头',
	info='该饰品在地上时可阻挡敌弹',
	mult={
		numberToMultiply = 114514,
		maxMultiplier = 3,
		append = {'体型变大', '体型更变大'}
	}
},

[IBS_TrinketID.OddKey]={
	name='怪异钥匙',
	info='头目车轮战保持开启'..
		 '#完成头目车轮战后，生成1个{{Collectible297}}潘多拉的盒子，并失去该饰品',
	mult={
		numberToMultiply = 1,
		maxMultiplier = 3,
	}
},

[IBS_TrinketID.Neopolitan]={
	name='三色杯',
	info='本层中，每进入3个新的特殊房间：'..
		 '#↑ {{Speed}} 移速 + 0.1'..
		 '#↑ {{Tears}} 射速修正 + 0.35'..
		 '#↑ {{Damage}} 伤害 + 0.5',
	mult={
		numberToMultiply = 114514,
		maxMultiplier = 3,
		append = {'双倍效率', '三倍效率'}
	}
},

[IBS_TrinketID.WildMilk]={
	name='猛牛牛奶',
	info='每房间首次受到的惩罚性伤害减少1，并变为非惩罚性伤害，但不提供无敌时间',
	mult={
		numberToMultiply = 1,
		maxMultiplier = 3,
	}
},

[IBS_TrinketID.BlackCharm]={
	name='黑魔咒',
	info='↑ 若本层进入过{{CurseRoom}}诅咒房，+ 0.6 {{Damage}}伤害'..
		 '#↑ 具有诅咒时，+ 2.4 {{Damage}}伤害',
	mult={
		numberToMultiply = 0.6,
		maxMultiplier = 3,
	}
},

[IBS_TrinketID.WarHospital]={
	name='战地医院',
	info='该饰品在地上时，持续为接近的血量低于75%的友好怪物或跟班恢复5%血量'..
		 '#该饰品在未清理的房间不会被拾取',
	mult={
		numberToMultiply = 5,
		maxMultiplier = 3,
	}
},

[IBS_TrinketID.SporeCloud]={
	name='孢子云',
	info='受伤时，发射八向{{Collectible553}}孢子眼泪，造成100%角色伤害',
	mult={
		numberToMultiply = 100,
		maxMultiplier = 3,
	}
},

[IBS_TrinketID.ForScreenshot]={
	name='截图用具',
	info='拾取后，将房间内的道具外观变为{{Quality4}}4级道具'..
		 '#失去该饰品或接近道具时复原外观'..
		 '#获得{{Player23}}堕化该隐的装扮'..
		 '#显示{{Collectible710}}合成宝袋UI (无用)',
	mult={
		numberToMultiply = 114514,
		maxMultiplier = 3,
		append = {'角色死后将复活为{{Player23}}堕化该隐，但对堕化该隐无效'}
	}
},

[IBS_TrinketID.TheLunatic]={
	name='可悲的疯人',
	info='新出现的道具有10%概率添加一个{{Collectible358}}蠢巫帽作为轮换'..
		 '#对任务道具无效',
	mult={
		numberToMultiply = 10,
		maxMultiplier = 3,
	}
},

[IBS_TrinketID.MMS]={
	name='愤怒的悠悠',
	info='↑ 击杀乌列 / 加百列后，本层{{Damage}}伤害 + 4 (多次击杀无效)',
	mult={
		numberToMultiply = 4,
		maxMultiplier = 3,
	}
},

[IBS_TrinketID.TechSL]={
	name='科技SL',
	info='角色死亡时，令游戏崩溃 (认真的)',
	mult={
		numberToMultiply = 114514,
		maxMultiplier = 3,
		append = {'游戏崩溃改为触发{{Collectible422}}发光沙漏效果'}
	}
},

[IBS_TrinketID.UnstableReagent]={
	name='不稳定试剂',
	info='进入新层时，随机触发3种药丸效果',
	mult={
		numberToMultiply = 3,
		maxMultiplier = 3,
	}
},

[IBS_TrinketID.EnvyToWin]={
	name='嫉妒致胜',
	info='进入未清理的{{BossRoom}}头目房或{{MiniBoss}}小头目房时，生成超级嫉妒'..
		 '#击杀嫉妒有50%概率生成硬币',
	mult={
		numberToMultiply = 50,
		maxMultiplier = 2,
	}
},

[IBS_TrinketID.BulkyWorm]={
	name='肥大虫',
	info='眼泪增大100%',
	mult={
		numberToMultiply = 100,
		maxMultiplier = 3,
	}
},

[IBS_TrinketID.ModelingClay]={
	name='塑型黏土II',
	info='放在{{Quality2}}品质2及以下的被动道具附近以拷贝其效果'..
		 '#对错误道具和任务道具无效'..
		 '#所有{{Trinket'..(IBS_TrinketID.ModelingClay)..'}}塑型黏土II共享效果',
	mult={
		numberToMultiply = 114514,
		maxMultiplier = 3,
		findReplace = {'{{Quality2}}品质2', '{{Quality3}}品质3', '{{Quality4}}品质4'},
	}
},

[IBS_TrinketID.SamsonState]={
	name='姿态指示器',
	info='用于指示当前姿态',
},

[IBS_TrinketID.LithiumBattery]={
	name='锂电池',
	info='花费5或更多{{Coin}}硬币购买掉落物时，生成微型电池',
	mult={
		numberToMultiply = 114514,
		maxMultiplier = 3,
		findReplace = {'5', '3', '1'},
	}	
},


}
--------------------------------------------------------
--------------------------卡牌--------------------------
--------------------------------------------------------
local cardEID={

[IBS_PocketID.CuZnD6] = {
	name='六面骰黄金典藏版',
	info='重置道具#99%不消失，每使用一次概率降低10%'
},

[IBS_PocketID.GoldenPrayer] = {
	name='金色祈者',
	info='获得28临时{{IBSIronHeart}}坚贞之心#消耗后，完成下一个{{BossRoom}}Boss房会再次生成该卡牌',
	mimic={charge = 6, isRune = false},
	player={[IBS_PlayerID.BMaggy]='恢复所有已损失的{{IBSIronHeart}}坚贞之心上限'}
},

[IBS_PocketID.StolenYear] = {
	name='偷来的一年',
	info='按优先级触发效果：'..
		 '#存在标价物品：使其免费'..
		 '#存在单选物品：使其不再单选'..
		 '#在初始房间：触发朝夕符文，诸神符文和{{Collectible76}}X光透视效果'..
		 '#以上均未满足：移除1{{BrokenHeart}}碎心，并触发{{Card51}}神圣卡效果',
	mimic={charge = 6, isRune = false},
},

[IBS_PocketID.NeniaDea] = {
	name='挽歌儿小姐',
	info='将伪忆与魂石互换，否则生成一个伪忆或魂石',
	mimic={charge = 6, isRune = false},
},

[IBS_PocketID.BIsaac] = {
	name='以撒的伪忆',
	info='以房间内道具平均品质重置道具为恶魔/天使房道具',
	mimic={charge = 4, isRune = true},
	player={[IBS_PlayerID.BXXX] = '伪忆球：若接触的道具的品质小于等于该球数量，则消耗3{{IBSMemory}}记忆碎片将其重置为相同品质的道具'},
	runeSword='恶魔/天使房中道具选择 + 2；不可叠加',
},

[IBS_PocketID.BMaggy] = {
	name='抹大拉的伪忆',
	info='↑ 7秒内角色无敌，+ 0.7{{Speed}}移速，不断生成圣光和震荡波',
	mimic={charge = 6, isRune = true},
	player={[IBS_PlayerID.BXXX] = '伪忆球：清理房间或受伤后，获得1临时{{IBSIronHeart}}坚贞之心'},
	runeSword='进入新房间时，获得1临时{{IBSIronHeart}}坚贞之心',	
},

[IBS_PocketID.BCain] = {
	name='该隐的伪忆',
	info='吞下4个{{Trinket'..(IBS_TrinketID.WheatSeeds)..'}}小麦种子',
	mimic={charge = 4, isRune = true},
	player={[IBS_PlayerID.BXXX] = '伪忆球：清理房间后，33%概率吞下{{Trinket'..(IBS_TrinketID.WheatSeeds)..'}}小麦种子，否则生成1个'},
	runeSword='种子袋有40%概率替换福袋或黑福袋，最高80%',	
},

[IBS_PocketID.BAbel] = {
	name='亚伯的伪忆',
	info='生成3只双倍血量的友好山羊',
	mimic={charge = 6, isRune = true},
	player={[IBS_PlayerID.BXXX] = '伪忆球：每隔7秒，生成小型友好山羊，上限为该球数量'},
	runeSword='受伤时，将非Boss攻击者变为友好的山羊',	
},

[IBS_PocketID.BJudas] = {
	name='犹大的伪忆',
	info='环境变暗3秒，期间下次攻击将发射一颗穿透幽灵燃烧眼泪，具有1300%{{Damage}}角色伤害'..
		 '#成功命中第一个敌人后，再获得一个{{Card'..(IBS_PocketID.BJudas)..'}}犹大的伪忆',
	mimic={charge = 1, isRune = true},
	player={[IBS_PlayerID.BXXX] = '伪忆球：每隔2秒，虚弱角色周围的敌人1.5秒'},				
	runeSword='每隔3秒，虚弱角色周围的敌人1.5秒',
},

[IBS_PocketID.BEve] = {
	name='夏娃的伪忆',
	info='清除诅咒，并获得一个祝福'..
		 '#若已有所有祝福，移除三个{{BrokenHeart}}碎心',
	mimic={charge = 6, isRune = true},
	player={[IBS_PlayerID.BXXX] = '伪忆球：每隔0.4秒，清除一个角色附近的敌弹'},
	runeSword='清理{{BossRoom}}头目房后，清除诅咒',
},

[IBS_PocketID.BSamson] = {
	name='参孙的伪忆',
	info='使用后，开始记录受伤次数'..
		 '#到达下一个{{BossRoom}}Boss房时停止记录，并获得：'..
		 '#↑ {{Tears}}射速和{{Damage}}伤害 x (100% + 15% x 计数)倍率，最高300%，并不断衰减'..
		 '#↑ {{Shotspeed}}弹速 + 1，直到以上属性衰减完毕'..
		 '#在{{BossRoom}}Boss房使用时，恢复属性已衰减部分',
	mimic={charge = 6, isRune = true},
	player={[IBS_PlayerID.BXXX] = '伪忆球：攻击最近的一个敌人或敌弹，造成14点伤害；累积计数越多攻速越快'},
	runeSword='进入未清理的{{BossRoom}}头目房时，触发该符文的效果',	
},

[IBS_PocketID.BAzazel] = {
	name='阿撒泻勒的伪忆',
	info='受到1心伤害，再获得一个该伪忆，并增加一次计数'..
		 '#每当计数增加时，触发一次奖励，类似{{SacrificeRoom}}献祭房'..
		 '#进入新层后，自动移除角色身上的该伪忆，除非计数达到11以上，并重置计数',
	mimic={charge = 6, isRune = true},
	player={[IBS_PlayerID.BXXX] = '伪忆球：具有7 + 当前计数的碰撞伤害；每隔3秒，令附近的敌人流血3秒'},
	runeSword='受到地刺伤害时增加1计数；不可叠加',
},

[IBS_PocketID.BLazarus] = {
	name='拉撒路的伪忆',
	info='传送至一个优质临时房间：'..
		 '#{{Shop}} <-> {{TreasureRoom}}'..
		 '#{{SecretRoom}} <-> {{SuperSecretRoom}}'..
		 '#{{ArcadeRoom}} <-> {{CurseRoom}}'..
		 '#{{UltraSecretRoom}} <-> {{Planetarium}}'..
		 '#成功传送后获得1{{BrokenHeart}}碎心，否则获得2{{SoulHeart}}魂心'..
		 '#!!! 由{{Collectible263}}透明符文等触发时或已处于临时房间时不传送',
	mimic={charge = 12, isRune = true},
	player={[IBS_PlayerID.BXXX] = '伪忆球：进入新的特殊房间时，获得5{{IBSMemory}}记忆碎片'},
	runeSword='进入新的特殊房间时，获得1{{HalfSoulHeart}}半魂心',
},

[IBS_PocketID.BEden] = {
	name='伊甸的伪忆',
	info='传送至错误房；若已经在错误房，则生成一个随机道具'..
		 '#之后的每个错误房中都会出现紫色传送门',
	mimic={charge = 6, isRune = true},
	player={[IBS_PlayerID.BXXX] = '伪忆球：清理房间后，揭示一个特殊房间的位置，否则获得3{{IBSMemory}}记忆碎片'},
	runeSword='每层生成一个{{Card'..(IBS_PocketID.BEden)..'}}伊甸的伪忆',
},

[IBS_PocketID.BLost] = {
	name='游魂的伪忆',
	info='将箱子和空箱子变为永恒箱子，否则生成一个永恒箱子'..
		 '#!!! 对永恒箱子无效',
	mimic={charge = 6, isRune = true},
	player={[IBS_PlayerID.BXXX] = '伪忆球：清理房间后，20%概率生成一个普通箱子'},
	runeSword='25%概率发射钥匙眼泪',
},

[IBS_PocketID.BLilith] = {
	name='莉莉丝的伪忆',
	info='移除角色身上品质最低的被动道具'..
		 '#从道具池中移除15个品质最低的道具，并生成1个品质相同的道具'..
		 '#对任务道具无效',
	mimic={charge = 3, isRune = true},
	player={[IBS_PlayerID.BXXX] = '伪忆球：进入新房间时，从道具池中移除1个品质最低的道具'},
	runeSword='镶嵌时，从道具池中移除30个{{Quality2}}品质2以下的道具',
},

[IBS_PocketID.BKeeper] = {
	name='店主的伪忆',
	info='每捐助乞丐3次，生成1个以下掉落物，最多20个：'..
		 '#55%{{Coin}}双硬币'..
		 '#10%{{Bomb}}炸弹'..
		 '#10%{{Key}}钥匙'..
		 '#10%{{SoulHeart}}魂心'..
		 '#10%{{Heart}}{{Heart}}双红心'..
		 '#10%{{Card53}}先祖召唤'..
		 '#5%{{Crafting11}}幸运币',
	mimic={charge = 6, isRune = true},
	player={[IBS_PlayerID.BXXX] = '伪忆球：每秒向最近的敌人发射眼泪，造成 (1 + 0.1 x 捐助乞丐次数) 的伤害'},
	runeSword='获得{{Collectible'..(IBS_ItemID.SOG)..'}}慷慨之魂的效果',
},

[IBS_PocketID.BApollyon] = {
	name='亚波伦的伪忆',
	info='生成最近三次消耗的其他符文，不足三个时会以{{Card41}}黑符文代替#!!! 对收获符文无效',
	mimic={charge = 12, isRune = true},
	player={[IBS_PlayerID.BXXX] = '伪忆球：消耗其他符文时，耗费5{{IBSMemory}}记忆碎片额外触发一次其效果'},
	runeSword='镶嵌时，触发该符文的效果',
},

[IBS_PocketID.BForgotten] = {
	name='遗骸的伪忆',
	info='生成三个已从道具池中移除的品质为{{Quality2}}2及以上的道具的魂火，与12个骨头环绕物',
	mimic={charge = 6, isRune = true},
	player={[IBS_PlayerID.BXXX] = '伪忆球：每隔5秒，生成骨头环绕物，其上限为该球数量的六倍'},
	runeSword='击杀敌人时，有18%概率生成友好的骷髅仔',
},

[IBS_PocketID.BBeth] = {
	name='伯大尼的伪忆',
	info='持有时，新房间内会出现一个虚影主动道具 (独立道具池)，将其拾取时记录其效果'..
		 '#触发最近记录的4个效果'..
		 '#在新层清空记录，若记录满4个效果，则再获得一个{{Card'..(IBS_PocketID.BBeth)..'}}伯大尼的伪忆',
	greed='贪婪模式：使用时立刻清空记录并尝试返还',
	mimic={charge = 4, isRune = true},
	player={[IBS_PlayerID.BXXX] = '伪忆球：消耗1{{IBSMemory}}记忆碎片记录虚影道具的效果'},
	runeSword='使用符文佩剑时，随机触发2个可能出现的虚影道具的效果',
},

[IBS_PocketID.BJBE] = {
	name='雅各和以扫的伪忆',
	info='将距离最近的道具变为两个品质减少一的道具',
	mimic={charge = 12, isRune = true},
	player={[IBS_PlayerID.BXXX] = '伪忆球：复制最近使用的两个其他伪忆对应伪忆球的能力'},
	runeSword='镶嵌时，复制角色身上品质最低的非任务道具两次',
},

}
--------------------------------------------------------
-----------------------可互动实体-----------------------
--------------------------------------------------------
local slotEID = {

[IBS_SlotID.CollectionBox.Variant] = {
	name='募捐箱',
	info=''
},

[IBS_SlotID.Albern.Variant] = {
	name='真理小子',
	info='被摧毁时，生成被拾取过的{{Collectible504}}棕色粪块'..
		 '#接触时有概率唤醒'..
		 '#被唤醒时，30%概率生成一个来自{{KeyBeggar}}钥匙大师池的道具，否则生成一个罕见箱子'
},

[IBS_SlotID.Facer.Variant] = {
	name='换脸商',
	info='接触1秒后，角色受到1心伤害(优先红心)，并生成5个硬币'..
		 '#36%概率离开；生成次数达到4时也会离开'..
		 '#离开时生成{{Collectible'..(IBS_ItemID.AFaces)..'}}一张张脸，其效果：'..
		 '#拾取时，吞下其中一个饰品：',
},

[IBS_SlotID.Envoy.Variant] = {
	name='使者',
	info='{{Coin}} 收取30个硬币后，返还硬币并触发{{Collectible585}}白玉香膏盒的效果'..
		 '#被摧毁时生成会掉落钥匙碎片的乌列/加百列'..
		 '#!!! {{Player3}}{{Collectible619}}持有长子名分的犹大：给予的硬币不计入总数',
},


}
--------------------------------------------------------

--收集癖
local hoardingEID = {

	--套装列表(不包括成人和践踏套装)
	FormList = {
		[ItemConfig.TAG_GUPPY] = '{{Guppy}} 敌人受伤时有10%概率生成蓝苍蝇',

		[ItemConfig.TAG_FLY] = '{{LordoftheFlies}} 敌人死亡时有50%概率生成蓝苍蝇',
		
		[ItemConfig.TAG_MUSHROOM] ='{{FunGuy}} 获得时有50%概率获得1{{Heart}}心之容器',
		
		[ItemConfig.TAG_ANGEL] = '{{Seraphim}} 获得时，+ 1{{SoulHeart}}魂心',
		
		[ItemConfig.TAG_BOB] = '{{Bob}} 集齐套装时免疫爆炸',
		
		[ItemConfig.TAG_SYRINGE] = '{{Spun}} + 0.25 {{Damage}}伤害',
		
		[ItemConfig.TAG_MOM] = '{{Mom}} 敌人额外受到0.25伤害',
		
		[ItemConfig.TAG_BABY] = '{{Conjoined}} + 0.15 {{Tears}}射速',
		
		[ItemConfig.TAG_DEVIL] = '{{Leviathan}} 获得时，+ 1 {{HalfBlackHeart}}半黑心',
		
		[ItemConfig.TAG_POOP] = '{{OhCrap}} 集齐套装时，摧毁大便额外恢复1{{Heart}}红心',
		
		[ItemConfig.TAG_BOOK] = '{{Bookworm}} 使用书时获得(0.5 x 最大充能 x 套件数量)秒的护盾',
		
		[ItemConfig.TAG_SPIDER] = '{{SpiderBaby}} 在新房间或新贪婪波次生成2只蓝蜘蛛',

	},

	--践踏套装(不包括变大药丸)
	StompyFrom = {
		info = '{{Stompy}} + 20碰撞伤害',
		[12] = true, --大蘑菇
		[302] = true, --狮子座
	},

}

--昧化参孙技能信息
BSamsonEID = {

	--占位符
	[0] = {
		Common = '(未完成)',
		Calm = '(未完成)',
		Wrath = '(未完成)',
	},

	--愚者
	[1] = {
		Common = '无效果',
		BSamson = '切换房间时，选中最后一张牌',
		Calm = '{{Battery}}{{1}} 进入{{IBSSamsonWrath}}暴怒',
		Wrath = '{{Battery}}{{1}} 进入{{IBSSamsonCalm}}平静',
	},
	
	--魔术师
	[2] = {
		Common = '↓{{Damage}}伤害 x 50% (不叠加)：对近战命中的敌人施加一层标记；每层标记会使敌人额外受到1伤害',
		Calm = '{{Battery}}{{2}} 对所有敌人施加十层标记；在本房间获得追踪效果',
		Wrath = '{{Battery}}{{2}} 所有敌人失去标记层数十倍的血量',
	},

	--女祭司
	[3] = {
		Common = '近战攻击可以摧毁障碍物和门',
		Calm = '{{Battery}}{{1}} 进入{{IBSSamsonWrath}}暴怒',
		Wrath = '{{Battery}}{{2}} 发射8向震荡波',
	},
	
	--皇后
	[4] = {
		Common = '近战造成流血，攻速提升25%，但范围减少10%',
		Calm = '{{Battery}}{{2}} 进入{{IBSSamsonWrath}}暴怒，获得{{Card4}}皇后的效果 (不叠加)，若已有则改为1充能',
		Wrath = '{{Battery}}{{0}} 进入{{IBSSamsonWrath}}暴怒',
	},
	
	--皇帝
	[5] = {
		Common = '近战攻速降低25%，命中敌人时提供1秒护盾，护盾持续期间不可再叠加',
		Calm = '{{Battery}}{{3}} 获得5秒护盾',
		Wrath = '{{Battery}}{{1}} 进入{{IBSSamsonCalm}}平静',
	},
	
	--教皇
	[6] = {
		Common = '首次被近战命中的敌人石化1秒',
		Calm = '{{Battery}}{{3}} 对所有敌人施加5秒石化',
		Wrath = '{{Battery}}{{1}} 进入{{IBSSamsonCalm}}平静',
	},
	
	--恋人
	[7] = {
		Common = '近战数量 + 1；被多个近战同时命中的敌人有6%概率掉落消逝的{{HalfHeart}}半红心 ({{Luck}}幸运6：12%)',
		Calm = '{{Battery}}{{1}} 进入{{IBSSamsonWrath}}暴怒',
		Wrath = '{{Battery}}{{3}} 进入{{IBSSamsonWrath}}暴怒，生成消逝的随机心',
	},
	
	--战车
	[8] = {
		Common = '近战伤害，大小和距离会逐渐增加，直到停止攻击或达边界',
		Calm = '{{Battery}}{{1}} 进入{{IBSSamsonWrath}}暴怒',
		Wrath = '{{Battery}}{{1}} 进入{{IBSSamsonWrath}}暴怒',
	},
	
	--正义
	[9] = {
		Common = '近战伤害降低50%(不叠加)，对命中的敌人发射眼泪',
		Calm = '{{Battery}}{{2}} 进入{{IBSSamsonWrath}}暴怒，下一张牌的充能消耗降低为0',
		Wrath = '{{Battery}}{{1}} 进入{{IBSSamsonCalm}}平静，恢复1充能',
	},
	
	--隐者
	[10] = {
		Common = '(不叠加) 近战数量 + 2，攻速降低50%',
		Calm = '{{Battery}}{{3}} 发射30个随机方向的弹射硬币眼泪',
		Wrath = '{{Battery}}{{0}} 进入{{IBSSamsonCalm}}平静',
	},
	
	--命运之轮
	[11] = {
		Common = '近战范围增加10%；飞行',
		Calm = '{{Battery}}{{0}} 进入{{IBSSamsonWrath}}暴怒，传送至随机敌人附近发动近战攻击',
		Wrath = '{{Battery}}{{3}} 同上，概率重复多次',
	},
	
	--力量
	[12] = {
		Common = '角色体型增加10% (不叠加)',
		Calm = '{{Battery}}{{1}} 进入{{IBSSamsonWrath}}暴怒',
		Wrath = '{{Battery}}{{3}} 进入{{IBSSamsonWrath}}暴怒，获得{{Card12}}力量效果，最多叠加2次',
	},
	
	--倒吊人
	[13] = {
		Common = '飞行',
		Calm = '{{Battery}}{{0}} 切换至最后一张牌',
		Wrath = '{{Battery}}{{0}} 进入{{IBSSamsonWrath}}暴怒，切换至最后一张牌',
	},
	
	--死亡
	[14] = {
		Common = '近战攻击时，对{{Range}}射程内的所有敌人造成13%{{Damage}}伤害',
		Calm = '{{Battery}}{{2}} 触发{{Card14}}死亡的效果',
		Wrath = '{{Battery}}{{2}} 同上',
	},
	
	--节制
	[15] = {
		Common = '停止近战3秒后，下一次近战的伤害提升100%，范围增加25%',
		Calm = '{{Battery}}{{0}} 恢复1充能，4秒冷却',
		Wrath = '{{Battery}}{{0}} 进入{{IBSSamsonCalm}}平静，恢复1充能，3秒冷却',
	},

	--恶魔
	[16] = {
		Common = '(不叠加) 近战施加硫磺标记，攻速降低33%；有硫磺标记的敌人额外受到66%伤害',
		Calm = '{{Battery}}{{1}} 进入{{IBSSamsonWrath}}暴怒',
		Wrath = '{{Battery}}{{2}} 进入{{IBSSamsonWrath}}暴怒，获得{{Card16}}恶魔的效果',
	},
	
	--塔
	[17] = {
		Common = '免疫爆炸；近战命中时有16%概率爆炸，造成200%{{Damage}}伤害 ({{Luck}}幸运17：50%)',
		Calm = '{{Battery}}{{2}} 进入{{IBSSamsonWrath}}暴怒，原地爆炸',
		Wrath = '{{Battery}}{{2}} 同上',
	},
	
	--星星
	[18] = {
		Common = '↑{{Luck}}幸运 + 1；近战额外造成200%{{Luck}}幸运的伤害，附带具有等量伤害的眼泪 (幸运低于1时失效)',
		Calm = '{{Battery}}{{3}} 进入{{IBSSamsonWrath}}暴怒，在本层 + 1{{Luck}}幸运',
		Wrath = '{{Battery}}{{0}} 进入{{IBSSamsonCalm}}平静',
	},
	
	--月亮
	[19] = {
		Common = '近战施加减速，冻结击杀的敌人，18%概率直接冻结非头目敌人 ({{Luck}}幸运41：100%)',
		Calm = '{{Battery}}{{0}} 下一次近战攻击会冻结非头目敌人',
		Wrath = '{{Battery}}{{1}} 进入{{IBSSamsonCalm}}平静',
	},
	
	--太阳
	[20] = {
		Common = '近战命中的敌人会被点燃；近战有25%概率释放火焰 ({{Luck}}幸运15：100%)',
		Calm = '{{Battery}}{{2}} 进入{{IBSSamsonWrath}}暴怒，释放一圈火焰',
		Wrath = '{{Battery}}{{2}} 同上',
	},
	
	--审判
	[21] = {
		Common = '(不叠加) 近战伤害降低50%，命中的敌人会失去等量生命，若血量低于20%则直接死亡',
		Calm = '{{Battery}}{{0}} 进入{{IBSSamsonWrath}}暴怒，2秒冷却',
		Wrath = '{{Battery}}{{0}} 进入{{IBSSamsonCalm}}平静，2秒冷却',
	},
	
	--世界
	[22] = {
		Common = '无效果',
		Calm = '{{Battery}}{{6}} 消耗该牌，生成5张其他的正塔罗牌',
		Wrath = '{{Battery}}{{6}} 同上',
	},

	--倒愚者
	[56] = {
		Common = '↑ 每个空的逆位塔罗牌槽位提供1{{Damage}}伤害和{{Tears}}射速',
	},
	
	--倒魔术师
	[57] = {
		Common = '↑ {{Damage}}伤害 x 200%；!!! 受到惩罚性伤害时，在本层获得一层标记；每层标记会使自身额外受到半心伤害',
	},
	
	--倒女祭司
	[58] = {
		Common = '每近战攻击5次，释放震荡波',
	},
	
	--倒皇后
	[59] = {
		Common = '{{IBSSamsonWrath}}暴怒不再翻倍{{Damage}}伤害和受伤',
	},
	
	--倒皇帝
	[60] = {
		Common = '{{IBSSamsonCalm}}平静护盾可以叠加，但持续时间缩短1秒',
	},
	
	--倒教皇
	[61] = {
		Common = '{{IBSSamsonCalm}}平静提供的护盾改为无敌时间',
	},
	
	--倒恋人
	[62] = {
		Common = '(不叠加) 近战数量 - 2；每有一种心，近战伤害提升20%，范围增加5%',
	},
	
	--倒战车
	[63] = {
		Common = '站立不动时，近战攻速提升60%',
	},
	
	--倒正义
	[64] = {
		Common = '(不叠加){{Collectible'..(IBS_ItemID.Posture)..'}}架势伤害充能量翻倍，但清理房间不再为其充能',
	},
	
	--倒隐者
	[65] = {
		Common = '↑ 每有1个{{Coin}}硬币，+ 0.04 {{Damage}}伤害',
	},
	
	--倒命运之轮
	[66] = {
		Common = '{{IBSSamsonWrath}}暴怒期间，即将受到惩罚性伤害时，消耗随机牌代替；↓这张牌被消耗时 - 1{{Luck}}幸运；↑其他牌被消耗时 + 0.25{{Luck}}幸运，并生成其反转版本',
	},

	--倒力量
	[67] = {
		Common = '↓ {{Damage}}伤害 x 75% (不叠加)；近战施加虚弱',
	},

	--倒倒吊人
	[68] = {
		Common = '切换房间后，下一次近战攻击会点金敌人',
	},
	
	--倒死亡
	[69] = {
		Common = '{{IBSSamsonWrath}}暴怒期间，受到惩罚性伤害不再消耗牌',
	},
	
	--倒节制
	[70] = {
		Common = '{{IBSSamsonWrath}}暴怒持续时间无限',
	},
	
	--倒恶魔
	[71] = {
		Common = '{{IBSSamsonCalm}}平静护盾持续时间延长0.5秒；{{IBSSamsonWrath}}暴怒持续时间减半 (不叠加)；切换房间时，进入{{IBSSamsonCalm}}平静并获得护盾',
	},

	--倒塔
	[72] = {
		Common = '爆炸会治疗角色',
	},	
	
	--倒星星
	[73] = {
		Common = '↓ - 7 {{Luck}}幸运；↑ 每消耗过一张牌，+ 1 {{Luck}}幸运；敌人额外受到 20% x {{Luck}}幸运 点伤害 (取绝对值)',
	},
	
	--倒月亮
	[74] = {
		Common = '切换房间时，进入{{IBSSamsonWrath}}暴怒',
	},
	
	--倒太阳
	[75] = {
		Common = '↑ 切换姿态后，+ 190% 不断衰减的{{Tears}}射速倍率',
	},
	
	--倒审判
	[76] = {
		Common = '进入{{IBSSamsonCalm}}平静时，生成追踪角色的光柱 (不会伤害角色)，光柱存在时无效',
	},
	
	--倒世界
	[77] = {
		Common = '↑ 自动消耗其他槽位的逆位塔罗牌，每张 + 0.5{{Damage}}伤害和21%{{DevilRoom}}恶魔房开启率；秘密出口保持开启',
	},
	
}

--米迦勒的赐福
local BlessingOfMichaelEID = {

	[108] = '即将受伤时，50%概率获得{{HalfSoulHeart}}半魂心',
	
	[182] = '↑ {{Damage}}伤害 x 140%',
	
	[313] = '额外获得一次机会',
	
	[331] = '敌人额外受到30%{{Damage}}角色伤害的伤害',
	
	[415] = '切换房间或受伤时，重新获得该道具 (不会算作第一次获得)',
	
	[477] = '最大充能 - 2',
	
	[643] = '每隔2.5秒，自动发射伤害减半但带有追踪的光柱',
	
	[691] = '拾取时，将品质低于{{Quality2}}2的道具移出道具池',

}

--------------------------------------------------------


--返回表
return {
	PlayerEID = playerEID,
	ItemEID = itemEID,
	TrinketEID = trinketEID,
	CardEID = cardEID,
	SlotEID = slotEID,
	
	HoardingEID = hoardingEID,
	BSamsonEID = BSamsonEID,
	BlessingOfMichaelEID = BlessingOfMichaelEID,
}