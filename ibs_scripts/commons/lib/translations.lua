--翻译

local mod = Isaac_BenightedSoul
local IBS_CallbackID = mod.IBS_CallbackID
local IBS_PlayerID = mod.IBS_PlayerID
local IBS_ItemID = mod.IBS_ItemID
local IBS_TrinketID = mod.IBS_TrinketID
local IBS_PocketID = mod.IBS_PocketID

local LANG = mod.Language
local config = Isaac.GetItemConfig()

local Translations = {}

--中文
Translations['zh'] = {

--角色
Player = {
	[IBS_PlayerID.BIsaac] = '以撒',
	[IBS_PlayerID.BMaggy] = '抹大拉',
	[IBS_PlayerID.BCain] = '该隐',
	[IBS_PlayerID.BAbel] = '亚伯',
	[IBS_PlayerID.BJudas] = '犹大',
	[IBS_PlayerID.BXXX] = '???',
	[IBS_PlayerID.BEden] = '伊甸',
	[IBS_PlayerID.BLost] = '游魂',
	[IBS_PlayerID.BKeeper] = '店主',
},

--道具(包含长子权)
Item = {
	[CollectibleType.COLLECTIBLE_BIRTHRIGHT]={
		['Name']='长子名分',
		[IBS_PlayerID.BIsaac]='飞升',
		[IBS_PlayerID.BMaggy]='更快变硬',
		[IBS_PlayerID.BJudas]='返还',
		[IBS_PlayerID.BCain]='你在哪 ?',
		[IBS_PlayerID.BAbel]='在你那',
		[IBS_PlayerID.BXXX]='沉浸',
		[IBS_PlayerID.BEden]='氵卖神',
		[IBS_PlayerID.BLost]='永恒心锁',
		[IBS_PlayerID.BKeeper]='取决于你',
	},
	[IBS_ItemID.LightD6]={
		Name='光辉六面骰',
		Desc='权衡你的命运'
	},

	[IBS_ItemID.NoOptions]={
		Name='拒绝选择',
		Desc='小孩子的选择'
	},

	[IBS_ItemID.D4D]={
		Name='四维骰',
		Desc='掌握你的命运',
	},

	[IBS_ItemID.SSG]={
		Name='仰望星空',
		Desc='双击观星'
	},

	[IBS_ItemID.Waster]={
		Name='剩饼',
		Desc='残余的守护'
	},

	[IBS_ItemID.Envy]={
		Name='女疾女户',
		Desc='你在期待什么 ?'
	},

	[IBS_ItemID.GlowingHeart]={
		Name='发光的心',
		Desc='充能型体力回复'
	},

	[IBS_ItemID.PurpleBubbles]={
		Name='紫色泡泡水',
		Desc='再喝 !'
	},

	[IBS_ItemID.CursedMantle]={
		Name='诅咒屏障',
		Desc='绑定诅咒 + 防御反击'
	},

	[IBS_ItemID.Hypercube]={
		Name='超立方',
		Desc='复制你的命运'
	},

	[IBS_ItemID.Defined]={
		Name='已定义',
		Desc='旅途愉快'
	},
	
	[IBS_ItemID.Chocolate]={
		Name='瓦伦丁巧克力',
		Desc='双击友好 , 每房间两次机会'
	},
	
	[IBS_ItemID.Diamoond]={
		Name='钻石',
		Desc='迪亚蒙德'
	},	

	[IBS_ItemID.Cranium]={
		Name='奇怪的头骨',
		Desc='似曾相识'
	},

	[IBS_ItemID.Ether]={
		Name='以太之云',
		Desc='复仇飞行'
	},

	[IBS_ItemID.Wisper]={
		Name='魂火之灵',
		Desc='魂火们'
	},

	[IBS_ItemID.BOT]={
		Name='节制之骨',
		Desc='愿你节制常驻'
	},

	[IBS_ItemID.GOF]={
		Name='坚韧面罩',
		Desc='愿你勇往直前'
	},

	[IBS_ItemID.V7]={
		Name='美德七面骰',
		Desc='随机的美德'
	},

	[IBS_ItemID.TGOJ]={
		Name='犹大福音',
		Desc='救赎之道 , 自在其中'
	},

	[IBS_ItemID.ReservedNail]={
		Name='备用钉子',
		Desc='钉好他们'
	},
	
	[IBS_ItemID.SuperB]={
		Name='核能电罐',
		Desc='充能有风险 , 但是管他呢'
	},
	
	[IBS_ItemID.DreggyPie]={
		Name='掉渣饼',
		Desc='体力上升 + 暂时性射速上升 , 搭配红豆汤风味更佳'
	},
	
	[IBS_ItemID.BonyKnife]={
		Name='骨刀',
		Desc='刀他们的骨'
	},
	
	[IBS_ItemID.Circumcision]={
		Name='割礼',
		Desc='移速下降 + 射速和幸运上升'
	},
	
	[IBS_ItemID.CursedHeart]={
		Name='诅咒之心',
		Desc='诅咒提升'
	},
	
	[IBS_ItemID.Redeath]={
		Name='死亡回放',
		Desc='重置已逝...暂时'
	},
	
	[IBS_ItemID.DustyBomb]={
		Name='尘埃炸弹',
		Desc='第三次爆炸...'
	},
	
	[IBS_ItemID.NeedleMushroom]={
		Name='金针菇',
		Desc='明天见'
	},
	
	[IBS_ItemID.MiniHorn]={
		Name='小小角恶魔',
		Desc='限量款'
	},
	
	[IBS_ItemID.WOA]={
		Name='亚波伦之翼',
		Desc='弹速上升 = 全属性上升'
	},
	
	[IBS_ItemID.MomsCheque]={
		Name='妈妈的支票',
		Desc='分期付款'
	},
	
	[IBS_ItemID.ForbiddenFruit]={
		Name='禁断之果',
		Desc='原罪'
	},
	
	[IBS_ItemID.Sword]={
		Name='紫电护主之刃',
		Desc='激进的守护者'
	},

	[IBS_ItemID.Regret]={
		Name='死不瞑目',
		Desc='杀死你的也会让你更强大'
	},
	
	[IBS_ItemID.Sacrifice]={
		Name='不受欢迎的祭品',
		Desc='事实证明 , 上帝不是吃素的'
	},
	
	[IBS_ItemID.Sacrifice2]={
		Name='受欢迎的祭品',
		Desc='致命盛宴'
	},
	
	[IBS_ItemID.Multiplication]={
		Name='只剩亿点',
		Desc='饼和鱼的奇迹'
	},

	[IBS_ItemID.NoTemperance]={
		Name='不懂节制 ?',
		Desc='该戒赌了 !'
	},

	[IBS_ItemID.GuppysPotty]={
		Name='嗝屁猫砂盆',
		Desc='我也用过'
	},

	[IBS_ItemID.LOL]={
		Name='蝗虫领主',
		Desc='英虫联盟'
	},

	[IBS_ItemID.Falowerse]={
		Name='薇艺',
		Desc='"以撒和他的父母住在..."'
	},

	[IBS_ItemID.FalsehoodOfXXX]={
		Name='??? 的伪忆',
		Desc='--尚未完工'
	},
	
	[IBS_ItemID.GoldExperience]={
		Name='黄金体验',
		Desc='要钱不要命 !'
	},
	
	[IBS_ItemID.ChubbyCookbook]={
		Name='蛆虫食谱',
		Desc='召唤蛆虫'
	},

	[IBS_ItemID.ProfaneWeapon]={
		Name='俗世的武器',
		Desc='伤害提升...仅对凡人'
	},

	[IBS_ItemID.RulesBook]={
		Name='规则书',
		Desc='??????'
	},

	[IBS_ItemID.CathedralWindow]={
		Name='教堂玻璃窗',
		Desc='正道的光'
	},

	[IBS_ItemID.LeadenHeart]={
		Name='铅制心脏',
		Desc='心里塞了铅块般难受'
	},

	[IBS_ItemID.China]={
		Name='瓷',
		Desc='中国制造'
	},

	[IBS_ItemID.SilverBracelet]={
		Name='银色手镯',
		Desc='参赌即送'
	},

	[IBS_ItemID.ROH]={
		Name='谦逊之径',
		Desc='愿你虚心而行'
	},

	[IBS_ItemID.Tenebrosity]={
		Name='晦涩之心',
		Desc='治疗 = 伤害'
	},

	[IBS_ItemID.HellKitchen]={
		Name='地狱厨房',
		Desc='撒但下厨'
	},

	[IBS_ItemID.StolenDecade]={
		Name='偷来的十年',
		Desc='或许是某人的馈赠'
	},

	[IBS_ItemID.DiceProjector]={
		Name='骰影仪',
		Desc='映射你的命运...暂时'
	},

	[IBS_ItemID.Hoarding]={
		Name='收集癖',
		Desc='玩桌游玩的'
	},

	[IBS_ItemID.SuperPanicButton]={
		Name='超紧急按钮',
		Desc='限救急 , 否则后果自负'
	},

	[IBS_ItemID.SuperPanicButton_Active]={
		Name='超紧急按钮',
		Desc='限救急 , 否则后果自负'
	},

	[IBS_ItemID.Blackjack]={
		Name='21点',
		Desc='但是塔罗牌'
	},

	[IBS_ItemID.Sketch]={
		Name='写生',
		Desc='关键词创作'
	},

	[IBS_ItemID.Molekale]={
		Name='分子植物',
		Desc='是我 , 又不是我'
	},

	[IBS_ItemID.Ssstew]={
		Name='炖蛇羹',
		Desc='远古风味'
	},

	[IBS_ItemID.BookOfSeen]={
		Name='全知之书',
		Desc='书的书'
	},

	[IBS_ItemID.PortableFarm]={
		Name='移动农场',
		Desc='指的是你'
	},

	[IBS_ItemID.GrowingWheatI]={
		Name='麦苗 I',
		Desc='生长中'
	},
	[IBS_ItemID.GrowingWheatII]={
		Name='麦苗 II',
		Desc='生长中'
	},
	[IBS_ItemID.GrowingWheatIII]={
		Name='麦苗 III',
		Desc='生长中'
	},
	[IBS_ItemID.GrowingWheatIV]={
		Name='麦苗 IV',
		Desc='生长中'
	},
	[IBS_ItemID.GrowingWheatV]={
		Name='麦苗 V',
		Desc='生长中'
	},
	[IBS_ItemID.GrowingWheatVI]={
		Name='麦苗 VI',
		Desc='生长中'
	},
	[IBS_ItemID.Wheat]={
		Name='小麦',
		Desc='收集3个以制作面包 !'
	},
	[IBS_ItemID.Bread]={
		Name='面包',
		Desc='经典食品'
	},

	[IBS_ItemID.Goatify]={
		Name='变羊术',
		Desc='必羊的'
	},

	[IBS_ItemID.ElegiastWinter]={
		Name='悼歌之冬',
		Desc='异隐者诗篇'
	},
	
	[IBS_ItemID.GHD]={
		Name='地质学博士证',
		Desc='更好的障碍物'
	},

	[IBS_ItemID.Grail]={
		Name='筵宴之杯',
		Desc='有溺无还的恶魔'
	},
	
	[IBS_ItemID.Moth]={
		Name='蜕变之蛾',
		Desc='愚者的蜕变'
	},
	
	[IBS_ItemID.Edge]={
		Name='流亡之刃',
		Desc='上校与狮子匠'
	},
	
	[IBS_ItemID.Edge2]={
		Name='伤疤之秘',
		Desc='无畏的战车'
	},
	
	[IBS_ItemID.Edge3]={
		Name='破碎之秘',
		Desc='无穷的力量'
	},

	[IBS_ItemID.Forge]={
		Name='白日之铸',
		Desc='铸炉审判'
	},
	
	[IBS_ItemID.SecretHistories]={
		Name='浪游秘史',
		Desc='千面旅人'
	},
	
	[IBS_ItemID.AnotherKarma]={
		Name='异业',
		Desc='利或弊'
	},

	[IBS_ItemID.Alms]={
		Name='施粥处',
		Desc='是给乞丐的'
	},
	
	[IBS_ItemID.NotchedSword]={
		Name='残损之剑',
		Desc='伤害上升...以及开门 !'
	},
	
	[IBS_ItemID.Troposphere]={
		Name='对流层',
		Desc='交换'
	},
	
	[IBS_ItemID.MODE]={
		Name='勤奋偶像',
		Desc='愿你勤勤恳恳'
	},
	
	[IBS_ItemID.LODI]={
		Name='劳动明灯',
		Desc='愿你吃苦耐劳'
	},
	
	[IBS_ItemID.ContactC]={
		Name='接触的G',
		Desc='WOC !'
	},

	[IBS_ItemID.MaxxC]={
		Name='增殖的G',
		Desc='跟上来试试 !'
	},
	
	[IBS_ItemID.Multiply]={
		Name='增殖',
		Desc='颗粒波狂潮'
	},

	[IBS_ItemID.SneakyC]={
		Name='潜伏的G',
		Desc='C4蚱蛋 !'
	},
	
	[IBS_ItemID.ConfrontingC]={
		Name='对峙的G',
		Desc='滚啊 !'
	},

	[IBS_ItemID.RetaliatingC]={
		Name='应战的G',
		Desc='接招 !'
	},
	
	[IBS_ItemID.MasterRound]={
		Name='胜者之弹',
		Desc='体力上升 + 无伤奖品'
	},

	[IBS_ItemID.MasterPack]={
		Name='大师组合包',
		Desc='氪金豪华版'
	},
	
	[IBS_ItemID.RichMines]={
		Name='富饶矿脉',
		Desc='下矿时间到'
	},
	
	[IBS_ItemID.Panacea]={
		Name='万能药',
		Desc='包治百病 !'
	},
	
	[IBS_ItemID.SmileWorld]={
		Name='微笑世界',
		Desc='伤害提升斯麦路斯麦路'
	},

	[IBS_ItemID.FGHD]={
		Name='伪造地质学博士证',
		Desc='更差的障碍物 + 破坏欲上升'
	},
	
	[IBS_ItemID.SOG]={
		Name='慷慨之魂',
		Desc='愿你慷慨解囊'
	},
	
	[IBS_ItemID.Clash]={
		Name='交锋',
		Desc='伤害上升，如果你很有攻击性的话'
	},
	
	[IBS_ItemID.TheBestWeapon]={
		Name='全村最好的剑',
		Desc='伤害上升 ?'
	},
	
	[IBS_ItemID.ThreeWishes]={
		Name='三个愿望',
		Desc='充能型掉落物生成'
	},
	
	[IBS_ItemID.ChestChest]={
		Name='箱中箱宝库',
		Desc='循环或终焉'
	},
	
	[IBS_ItemID.CheeseCutter]={
		Name='奶酪切片器',
		Desc='头目 = 加餐'
	},
	
	[IBS_ItemID.Turbo]={
		Name='内核加速',
		Desc='充能回满 , 但代价是什么呢 ?'
	},
	
	[IBS_ItemID.TreasureKey]={
		Name='宝库钥匙',
		Desc='前往宝库'
	},
	
	[IBS_ItemID.AKEY47]={
		Name='AKEY-47',
		Desc='钥匙发射器'
	},
	
	[IBS_ItemID.SilverKey]={
		Name='银之钥',
		Desc='穿越银钥之门'
	},
	
	[IBS_ItemID.TruthChest]={
		Name='真理宝箱',
		Desc='真理小子去哪了 ?'
	},
	
	[IBS_ItemID.Knock]={
		Name='洞开之启',
		Desc='教皇通行证'
	},
	
	[IBS_ItemID.WilderingMirror]={
		Name='迷途之镜',
		Desc='多重景观...不是指碎片 !'
	},
	
	[IBS_ItemID.WilderingMirror2]={
		Name='破损的迷途之镜',
		Desc='买点胶水 ?'
	},
	
	[IBS_ItemID.MoonStreets]={
		Name='月下异巷',
		Desc='诡异连接'
	},
	
	[IBS_ItemID.Fomalhaut]={
		Name='北落师门',
		Desc='发光发热'
	},
	
	[IBS_ItemID.LuckEnchantment]={
		Name='幸运附魔',
		Desc='幸运 = 伤害'
	},
	
	[IBS_ItemID.TheHornedAxe]={
		Name='双角斧',
		Desc='死亡与复生'
	},
	
	[IBS_ItemID.LightBarrier]={
		Name='光之结界',
		Desc='塔罗反转'
	},
	
	[IBS_ItemID.ChillMind]={
		Name='冷静头脑',
		Desc='试着望眼未来'
	},
	
	[IBS_ItemID.LownTea]={
		Name='免茶',
		Desc='体力上升'
	},
	
	[IBS_ItemID.TheEyeofTruth]={
		Name='真实之眼',
		Desc='让我看看 !'
	},
	
	[IBS_ItemID.Turbine]={
		Name='涡轮',
		Desc='机器驱动'
	},
	
	[IBS_ItemID.RedHook]={
		Name='红钩',
		Desc='暗黑暴击 !'
	},
	
	[IBS_ItemID.OvO]={
		Name='OvO',
		Desc='20连 !'
	},

	[IBS_ItemID.DanishGambit]={
		Name='丹麦弃兵',
		Desc='弃子战未来'
	},
	
	[IBS_ItemID.HyperBlock]={
		Name='超能格挡',
		Desc='抵挡伤害 + 提供超能力'
	},
	
	[IBS_ItemID.FusionHammer]={
		Name='融合之锤',
		Desc='无法放下的力量'
	},
	
	[IBS_ItemID.SangenSummoning]={
		Name='杯满的灿幻庄',
		Desc='伤害抗性 + 未知潜力'
	},

	[IBS_ItemID.PeacePipe]={
		Name='宁静烟斗',
		Desc='放空心智'
	},
	
	[IBS_ItemID.Yongle]={
		Name='永乐大典',
		Desc='文献大成'
	},

	[IBS_ItemID.HexaVessel]={
		Name='六魂容器',
		Desc='复燃'
	},

	[IBS_ItemID.Flex]={
		Name='活动肌肉',
		Desc='伤害上升'
	},
	
	[IBS_ItemID.SignatureMove]={
		Name='招牌技',
		Desc='攻击性越少 , 攻击性越多'
	},
	
	[IBS_ItemID.DoubleDosage]={
		Name='双倍剂量',
		Desc='做个大剩人'
	},
	
	[IBS_ItemID.HolyInjection]={
		Name='注射型圣水',
		Desc='祝福其实是一种物质'
	},
	
	[IBS_ItemID.KilleR]={
		Name='R剑',
		Desc='伤害 Rp'
	},
	
	[IBS_ItemID.VeinMiner]={
		Name='连锁挖掘',
		Desc='挖挖挖 !'
	},
	
	[IBS_ItemID.VainMiner]={
		Name='帘锁挖掘',
		Desc='挖挖挖 ?'
	},
	
	[IBS_ItemID.PUC]={
		Name='杯水',
		Desc='愚昧提升'
	},
	
	[IBS_ItemID.SaleBomb]={
		Name='促销炸弹',
		Desc='惊爆价 !'
	},
	
	[IBS_ItemID.Diecry]={
		Name='日寄',
		Desc='一股洋葱味'
	},
	
	[IBS_ItemID.ReusedStory]={
		Name='套作',
		Desc='以撒贮在...'
	},
	
	[IBS_ItemID.Zoth]={
		Name='索斯星',
		Desc='房间变换'
	},
	
	[IBS_ItemID.PageantFather]={
		Name='盛装教父',
		Desc='终极豪华至尊版 +++'
	},
	
	[IBS_ItemID.DeciduousMeat]={
		Name='剥落古老肉',
		Desc='体力上升 ?'
	},
	
	[IBS_ItemID.CurseSyringe]={
		Name='诅咒针剂',
		Desc='诅咒 = 伤害'
	},
	
	[IBS_ItemID.AstroVera]={
		Name='星际芦荟',
		Desc='最大体力上升'
	},

	[IBS_ItemID.CurseoftheFool]={
		Name='愚者之诅咒',
		Desc='无终无始之旅'
	},

	[IBS_ItemID.UnburntGod]={
		Name='焚烧不焚之神',
		Desc='铁匠的仪式'
	},
},

--饰品
Trinket = {
	[IBS_TrinketID.BottleShard]={
		Name='酒瓶碎片',
		Desc='他离开前干的'
	},

	[IBS_TrinketID.DadsPromise]={
		Name='爸爸的约定',
		Desc='旧约的结束是新约的开始'
	},

	[IBS_TrinketID.GamblersEye]={
		Name='赌徒之眼',
		Desc='眼疾手快'
	},

	[IBS_TrinketID.BaconSaver]={
		Name='骨猪一掷',
		Desc='最后一次'
	},

	[IBS_TrinketID.DivineRetaliation]={
		Name='神圣反击',
		Desc='弹火'
	},

	[IBS_TrinketID.ToughHeart]={
		Name='硬的心',
		Desc='抵挡伤害...总会有效'
	},
	
	[IBS_TrinketID.ChaoticBelief]={
		Name='混沌信仰',
		Desc='信仰提升 ?'
	},
	
	[IBS_TrinketID.ThronyRing]={
		Name='荆棘指环',
		Desc='最后之作'
	},

	[IBS_TrinketID.Export]={
		Name='出口产品',
		Desc='二元贸易'
	},

	[IBS_TrinketID.Nemesis]={
		Name='天谴报应',
		Desc='7倍奉还'
	},
	
	[IBS_TrinketID.Barren]={
		Name='贫瘠',
		Desc='白费功夫'
	},

	[IBS_TrinketID.LeftFoot]={
		Name='左断脚',
		Desc='行歧路者得恶报'
	},
	
	[IBS_TrinketID.RabbitHead]={
		Name='兔头',
		Desc='树桩上的意外收获'
	},

	[IBS_TrinketID.LunarTwigs]={
		Name='月桂枝',
		Desc='生来倔'
	},

	[IBS_TrinketID.PresentationalMind]={
		Name='表观思维',
		Desc='背叛 ?'
	},

	[IBS_TrinketID.Interval]={
		Name='区间',
		Desc='差距 = 力量'
	},

	[IBS_TrinketID.NumeronForce]={
		Name='源数之力',
		Desc='更改卡牌效果'
	},

	[IBS_TrinketID.WheatSeeds]={
		Name='小麦种子',
		Desc='种你胃里'
	},

	[IBS_TrinketID.CorruptedDeck]={
		Name='腐蚀套牌',
		Desc='腐蚀你的塔罗牌 !'
	},
	
	[IBS_TrinketID.GlitchedPenny]={
		Name='错误硬币',
		Desc='财富即锟斤拷'
	},
	
	[IBS_TrinketID.StarryPenny]={
		Name='星空硬币',
		Desc='财富即未来'
	},
	
	[IBS_TrinketID.PaperPenny]={
		Name='纸质硬币',
		Desc='财富即知识'
	},
	
	[IBS_TrinketID.CultistMask]={
		Name='邪教徒头套',
		Desc='你觉得自己有开腔的欲望'
	},
	
	[IBS_TrinketID.SsserpentHead]={
		Name='蛇的头',
		Desc='? = $'
	},

	[IBS_TrinketID.ClericFace]={
		Name='牧师的脸',
		Desc='人人都爱牧师'
	},

	[IBS_TrinketID.NlothsMask]={
		Name='恩洛斯的脸',
		Desc='你觉得好饿'
	},

	[IBS_TrinketID.GremlinMask]={
		Name='地精容貌',
		Desc='好想逃'
	},
	
	[IBS_TrinketID.OldPenny]={
		Name='古老硬币',
		Desc='财富即光阴'
	},

	[IBS_TrinketID.CrackCallback]={
		Name='踩背腿',
		Desc='踩踩背 ？'
	},
	
	[IBS_TrinketID.Foe]={
		Name='杜弗尔的头',
		Desc='挡下攻击 (不是指你)'
	},
	
	[IBS_TrinketID.OddKey]={
		Name='怪异钥匙',
		Desc='???'
	},
	
	[IBS_TrinketID.Neopolitan]={
		Name='三色杯',
		Desc='三种口味 !'
	},

	[IBS_TrinketID.WildMilk]={
		Name='猛牛牛奶',
		Desc='来自公奶牛 !'
	},

	[IBS_TrinketID.BlackCharm]={
		Name='黑魔咒',
		Desc='诅咒打击'
	},
	
	[IBS_TrinketID.WarHospital]={
		Name='战地医院',
		Desc='还能抢救一下'
	},
	
	[IBS_TrinketID.SporeCloud]={
		Name='孢子云',
		Desc='散播真菌'
	},
	
	[IBS_TrinketID.ForScreenshot]={
		Name='截图用具',
		Desc='囤欺者'
	},


},

--口袋物品(不包含药丸)
Pocket = {
	[IBS_PocketID.CuZnD6]={
		Name='六面骰黄金典藏版',
		Desc='Cu + Zn'
	},

	[IBS_PocketID.GoldenPrayer]={
		Name='金色祈者',
		Desc='祈祷 , 为人与和平'
	},
	
	[IBS_PocketID.StolenYear]={
		Name='偷来的一年',
		Desc='或许是某人的馈赠'
	},
	
	[IBS_PocketID.NeniaDea]={
		Name='挽歌儿小姐',
		Desc='灵魂与回忆的交谈'
	},


	--伪忆
	[IBS_PocketID.BIsaac]={
		Name='以撒的伪忆',
		Desc='骰符 「二元平衡」'
	},
	[IBS_PocketID.BMaggy]={
		Name='抹大拉的伪忆',
		Desc='圣符 「石破天惊」'
	},
	[IBS_PocketID.BCain]={
		Name='该隐的伪忆',
		Desc='生长 「播汗种水」'
	},
	[IBS_PocketID.BAbel]={
		Name='亚伯的伪忆',
		Desc='牧地 「盛宴前夕」'
	},
	[IBS_PocketID.BJudas]={
		Name='犹大的伪忆',
		Desc='死符 「灯熄枪响」'
	},
	[IBS_PocketID.BEve]={
		Name='夏娃的伪忆',
		Desc='净化 「自允之果」'
	},
	[IBS_PocketID.BSamson]={
		Name='参孙的伪忆',
		Desc='默符 「回光返照」'
	},
	[IBS_PocketID.BAzazel]={
		Name='阿撒泻勒的伪忆',
		Desc='祭祀 「旷野替罪」'
	},
	[IBS_PocketID.BLazarus]={
		Name='拉撒路的伪忆',
		Desc='通符 「两世车票」'
	},
	[IBS_PocketID.BEden]={
		Name='伊甸的伪忆',
		Desc='穿梭 「漏洞弥补」'
	},
	[IBS_PocketID.BLost]={
		Name='游魂的伪忆',
		Desc='夭符 「永恒心锁」'
	},
	[IBS_PocketID.BLilith]={
		Name='莉莉丝的伪忆',
		Desc='落子 「后翼弃兵」'
	},
	[IBS_PocketID.BKeeper]={
		Name='店主的伪忆',
		Desc='业符 「乞丐回礼」'
	},
	[IBS_PocketID.BApollyon]={
		Name='亚波伦的伪忆',
		Desc='反刍 「灵魂回响」'
	},
	[IBS_PocketID.BForgotten]={
		Name='遗骸的伪忆',
		Desc='召回 「卷骨重来」'
	},
	[IBS_PocketID.BBeth]={
		Name='伯大尼的伪忆',
		Desc='求知 「遗物泡影」'
	},
	[IBS_PocketID.BJBE]={
		Name='雅各和以扫的伪忆',
		Desc='名分 「融合解除」'
	},
	
	
},


}


--英文
Translations['en'] = {


}


----翻译器开始----

--测试时关闭,防止影响ID获取
if LANG == 'zh' and not mod._Debug then
	--道具
	for id,v in pairs(Translations[LANG].Item) do
		if id ~= CollectibleType.COLLECTIBLE_BIRTHRIGHT then
			local itemConfig = config:GetCollectible(id)
			if itemConfig then
				itemConfig.Name = v.Name
				itemConfig.Description = v.Desc
			end
		end
	end
	
	--饰品
	for id,v in pairs(Translations[LANG].Trinket) do
		local itemConfig = config:GetTrinket(id)
		if itemConfig then
			itemConfig.Name = v.Name
			itemConfig.Description = v.Desc
		end
	end
	
	--口袋物品(不包含药丸)
	for id,v in pairs(Translations[LANG].Pocket) do
		local itemConfig = config:GetCard(id)
		if itemConfig then
			itemConfig.Name = v.Name
			itemConfig.Description = v.Desc
		end
	end	
end

--长子权翻译
local function Translation_Birthright(_,player, item)
    if Translations[LANG] and Translations[LANG].Item then
		local info = Translations[LANG].Item[item]	
		if info then
			local playerType = player:GetPlayerType()
			local desc = info[playerType]
			if desc then
				Game():GetHUD():ShowItemText(info.Name, desc)
			end
		end
	end
end
mod:AddCallback(IBS_CallbackID.PICK_COLLECTIBLE, Translation_Birthright, CollectibleType.COLLECTIBLE_BIRTHRIGHT)
----翻译器结束----



return Translations