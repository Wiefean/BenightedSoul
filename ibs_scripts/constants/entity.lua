--常量,其他实体

local mod = Isaac_BenightedSoul

--Boss("Key"用于查找对应信息)
mod.IBS_Boss = {

--节制
Temperance = {
	Type = Isaac.GetEntityTypeByName("IBS_Temperance"),
	Variant = Isaac.GetEntityVariantByName("IBS_Temperance"),
	SubType = 0,
	Key = "Temperance"
},

--坚韧
Fortitude = {
	Type = Isaac.GetEntityTypeByName("IBS_Fortitude"),
	Variant = Isaac.GetEntityVariantByName("IBS_Fortitude"),
	SubType = 0,
	Key = "Fortitude"
},


}

--跟班
mod.IBS_Familiar = {

--魂火之灵
Wisper = {
	Type = 3,
	Variant = Isaac.GetEntityVariantByName("IBS_Wisper"),
	SubType = 0
},

--紫电护主之刃
Sword = {
	Type = 3,
	Variant = Isaac.GetEntityVariantByName("IBS_Sword"),
	SubType = 0
},



}

--效果
mod.IBS_Effect = {

--光柱,用于昧化角色变身
Benighting = {
	Type = 1000,
	Variant = Isaac.GetEntityVariantByName("IBS_Benighting"),
	SubType = 0
},

--犹大福音
TGOJ = {
	Type = 1000,
	Variant = Isaac.GetEntityVariantByName("IBS_TheGospelOfJudas"),
	SubType = 0
},

--大光柱,用于不受欢迎的祭品
BigLight = {
	Type = 1000,
	Variant = Isaac.GetEntityVariantByName("IBS_BigLight"),
	SubType = 0
},

}