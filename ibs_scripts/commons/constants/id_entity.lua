--常量,其他实体ID

local mod = Isaac_BenightedSoul

--Boss
mod.IBS_BossID = {

--勤劳
Diligence = {
	Type = 46,
	Variant = Isaac.GetEntityVariantByName('IBS_Diligence'),
	SubType = {Farmer = 0, Worker = 1},
},

--坚韧
Fortitude = {
	Type = 48,
	Variant = Isaac.GetEntityVariantByName('IBS_Fortitude'),
	SubType = 0,
},

--节制
Temperance = {
	Type = 49,
	Variant = Isaac.GetEntityVariantByName('IBS_Temperance'),
	SubType = 0,
},

--慷慨
Generosity = {
	Type = 50,
	Variant = Isaac.GetEntityVariantByName('IBS_Generosity'),
	SubType = {Generosity = 0, Bum = 1},
},

--谦逊
Humility = {
	Type = 52,
	Variant = Isaac.GetEntityVariantByName('IBS_Humility'),
	SubType = 0,
},


}


--眼泪
mod.IBS_TearID = {

--劳锤眼泪
DiligenceHammerTear = {
	Type = 2,
	Variant = Isaac.GetEntityVariantByName('IBS_DiligenceHammerTear'),
	SubType = Isaac.GetEntitySubTypeByName('IBS_DiligenceHammerTear'),
},


}


--跟班
mod.IBS_FamiliarID = {

--魂火之灵
Wisper = {
	Type = 3,
	Variant = Isaac.GetEntityVariantByName('IBS_Wisper'),
	SubType = Isaac.GetEntitySubTypeByName('IBS_Wisper'),
},

--护主之刃
Sword = {
	Type = 3,
	Variant = Isaac.GetEntityVariantByName('IBS_Sword'),
	SubType = Isaac.GetEntitySubTypeByName('IBS_Sword'),
},

--伪忆球
BXXXOrb = {
	Type = 3,
	Variant = Isaac.GetEntityVariantByName('IBS_BXXXOrbIsaac'),
	SubType = {
		BIsaac = 0,
		BMaggy = 1,
		BCain = 2,
		BAbel = 3,
		BJudas = 4,
		BEve = 5,
		BSamson = 6,
		BAzazel = 7,
		BLazarus = 8,
		BEden = 9,
		BLost = 10,
		BLilith = 11,
		BKeeper = 12,
		BApollyon = 13,
		BForgotten = 14,
		BBeth = 15,
		BJBE = 16,
	},
},

--018
SCP018 = {
	Type = 3,
	Variant = Isaac.GetEntityVariantByName('IBS_018'),
	SubType = Isaac.GetEntitySubTypeByName('IBS_018'),
},

--箱子僚机
BLostFloat = {
	Type = 3,
	Variant = Isaac.GetEntityVariantByName('IBS_BLostFloatCommon'),
	SubType = {
		Common = 0,
		Stone = 1,
		Spike = 2,
		Eternal = 3,
		Old = 4,
		Wooden = 5,
		Haunted = 6,
		Golden = 7,
		Red = 8,
	},
},


--箱子武器
BLostWeapon = {
	Type = 3,
	Variant = Isaac.GetEntityVariantByName('IBS_BLostWeaponCommon'),
	SubType = {
		Common = 0,
		Stone = 1,
		Spike = 2,
		Eternal = 3,
		Old = 4,
		Wooden = 5,
		Haunted = 6,
		Golden = 7,
		Red = 8,
	},
},

--AKEY47
AKEY47 = {
	Type = 3,
	Variant = Isaac.GetEntityVariantByName('IBS_AKEY47'),
	SubType = Isaac.GetEntitySubTypeByName('IBS_AKEY47'),
},

}


--掉落物
mod.IBS_PickupID = {

--种子袋
SeedBag = {
	Type = 5,
	Variant = Isaac.GetEntityVariantByName('IBS_SeedBag'),
	SubType = Isaac.GetEntitySubTypeByName('IBS_SeedBag'),
},

--记忆碎片
Memory = {
	Type = 5,
	Variant = Isaac.GetEntityVariantByName('IBS_Memory'),
	SubType = {
		Small = Isaac.GetEntitySubTypeByName('IBS_Memory'),
		Big = Isaac.GetEntitySubTypeByName('IBS_MemoryBig'),
	},
},

--遗物泡影
Relic = {
	Type = 5,
	Variant = Isaac.GetEntityVariantByName('IBS_Relic'),
	SubType = Isaac.GetEntitySubTypeByName('IBS_Relic'),
},

--勤麦
DeligenceWheat = {
	Type = 5,
	Variant = Isaac.GetEntityVariantByName('IBS_DeligenceWheat'),
	SubType = Isaac.GetEntitySubTypeByName('IBS_DeligenceWheat'),
},


}


--可互动实体
mod.IBS_SlotID = {

--募捐箱
CollectionBox = {
	Type = 6,
	Variant = Isaac.GetEntityVariantByName('IBS_CollectionBox'),
	SubType = Isaac.GetEntitySubTypeByName('IBS_CollectionBox'),
},

--真理小子
Albern = {
	Type = 6,
	Variant = Isaac.GetEntityVariantByName('IBS_Albern'),
	SubType = Isaac.GetEntitySubTypeByName('IBS_Albern'),
},

--换脸商
Facer = {
	Type = 6,
	Variant = Isaac.GetEntityVariantByName('IBS_Facer'),
	SubType = Isaac.GetEntitySubTypeByName('IBS_Facer'),
},

--使者
Envoy = {
	Type = 6,
	Variant = Isaac.GetEntityVariantByName('IBS_Envoy'),
	SubType = Isaac.GetEntitySubTypeByName('IBS_Envoy'),
},

}


--敌弹
mod.IBS_ProjID = {

--劳锤
DiligenceHammer = {
	Type = 9,
	Variant = Isaac.GetEntityVariantByName('IBS_DiligenceHammer'),
	SubType = Isaac.GetEntitySubTypeByName('IBS_DiligenceHammer'),
},

}


--效果
mod.IBS_EffectID = {

--用于昧化角色变身的光柱,现仅用于多人模式
Benighting = {
	Type = 1000,
	Variant = Isaac.GetEntityVariantByName('IBS_Benighting'),
	SubType = Isaac.GetEntitySubTypeByName('IBS_Benighting'),
},

--犹大福音
TGOJ = {
	Type = 1000,
	Variant = Isaac.GetEntityVariantByName('IBS_TheGospelOfJudas'),
	SubType = Isaac.GetEntitySubTypeByName('IBS_TheGospelOfJudas'),
},

--犹大福音冲刺特效
TGOJDash = {
	Type = 1000,
	Variant = Isaac.GetEntityVariantByName('IBS_TGOJDash'),
	SubType = Isaac.GetEntitySubTypeByName('IBS_TGOJDash'),
},

--大光柱,用于不受欢迎的祭品
BigLight = {
	Type = 1000,
	Variant = Isaac.GetEntityVariantByName('IBS_BigLight'),
	SubType = Isaac.GetEntitySubTypeByName('IBS_BigLight'),
},

--扫荡(骨棒近战攻击特效)
Swing = {
	Type = 1000,
	Variant = Isaac.GetEntityVariantByName('IBS_Swing'),
	SubType = Isaac.GetEntitySubTypeByName('IBS_Swing'),
},

--勤勤扫荡(小boss)
DeligenceSwing = {
	Type = 1000,
	Variant = Isaac.GetEntityVariantByName('IBS_DeligenceSwing'),
	SubType = Isaac.GetEntitySubTypeByName('IBS_DeligenceSwing'),
},

--遗弃物品
AbandonedItem = {
	Type = 1000,
	Variant = Isaac.GetEntityVariantByName('IBS_AbandonedItem'),
	SubType = Isaac.GetEntitySubTypeByName('IBS_AbandonedItem'),
},

--劳灯
DiligenceLamp = {
	Type = 1000,
	Variant = Isaac.GetEntityVariantByName('IBS_DiligenceLamp'),
	SubType = Isaac.GetEntitySubTypeByName('IBS_DiligenceLamp'),
},

--箱子斗篷(昧化游魂使用)
ChestMantle = {
	Type = 1000,
	Variant = Isaac.GetEntityVariantByName('IBS_ChestMantle'),
	SubType = Isaac.GetEntitySubTypeByName('IBS_ChestMantle'),
},

--震荡波特供版(昧化抹大拉使用)
ShockWave = {
	Type = 1000,
	Variant = Isaac.GetEntityVariantByName('IBS_ShockWave'),
	SubType = {
		OnlyHurtEnemy = 0,
		HurtEnemyAndPlayer = 1,
		OnlyHurtPlayer = 2,
	},
},

--空实体
Empty = {
	Type = 1000,
	Variant = Isaac.GetEntityVariantByName('IBS_Empty'),
	SubType = Isaac.GetEntitySubTypeByName('IBS_Empty'),
},

}