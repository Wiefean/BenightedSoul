--昧化抹大拉通关标记设置

local mod = Isaac_BenightedSoul
local Marks = mod.IBS_Class.Marks
local IBS_ItemID = mod.IBS_ItemID
local IBS_TrinketID = mod.IBS_TrinketID
local IBS_PocketID = mod.IBS_PocketID


local BMaggy = Marks(mod.IBS_PlayerID.BMaggy, {

Heart = {
	PaperNames = {'leaden_heart'},
	Items = {IBS_ItemID.LeadenHeart},
},
Isaac = {
	PaperNames = {'cathedral_window'},
	Items = {IBS_ItemID.CathedralWindow},
},
BlueBaby = {
	PaperNames = {'china'},
	Items = {IBS_ItemID.China},
},
Satan = {
	PaperNames = {'divine_retaliation'},
	Trinkets = {IBS_TrinketID.DivineRetaliation},
},
Lamb = {
	PaperNames = {'tough_heart'},
	Trinkets = {IBS_TrinketID.ToughHeart},
},
MegaSatan = {
	PaperNames = {'golden_prayer'},
	Pockets = {IBS_PocketID.GoldenPrayer},
},
BossRush = {
	PaperNames = {'silver_bracelet'},
	Items = {IBS_ItemID.SilverBracelet},
},
Hush = {
	PaperNames = {'bmaggy_falsehood'},
	Pockets = {IBS_PocketID.BMaggy},
},
Delirium = {
	PaperNames = {'glowing_heart'},
	Items = {IBS_ItemID.GlowingHeart},
},
Witness = {
	PaperNames = {'lunar_twigs'},
	Trinkets = {IBS_TrinketID.LunarTwigs},
},
Beast = {
	PaperNames = {'diamoond'},
	Items = {IBS_ItemID.Diamoond},
},
Greed = {
	PaperNames = {'chocolate'},
	Items = {IBS_ItemID.Chocolate},
},
FINISHED = {
	PaperNames = {'boss_fortitude'},
},

})


return BMaggy