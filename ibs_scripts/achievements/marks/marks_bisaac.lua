--昧化以撒通关标记设置

local mod = Isaac_BenightedSoul
local Marks = mod.IBS_Class.Marks
local IBS_ItemID = mod.IBS_ItemID
local IBS_TrinketID = mod.IBS_TrinketID
local IBS_PocketID = mod.IBS_PocketID


local BIsaac = Marks(mod.IBS_PlayerID.BIsaac, {

Heart = {
	PaperNames = {'hoarding'},
	Items = {IBS_ItemID.Hoarding},
},
Isaac = {
	PaperNames = {'dads_promise'},
	Trinkets = {IBS_TrinketID.DadsPromise},
},
BlueBaby = {
	PaperNames = {'guppys_potty'},
	Items = {IBS_ItemID.GuppysPotty},
},
Satan = {
	PaperNames = {'bottle_shard'},
	Trinkets = {IBS_TrinketID.BottleShard},
},
Lamb = {
	PaperNames = {'gamblers_eye'},
	Trinkets = {IBS_TrinketID.GamblersEye},
},
MegaSatan = {
	PaperNames = {'czd6'},
	Pockets = {IBS_PocketID.CuZnD6},
},
BossRush = {
	PaperNames = {'dice_projector'},
	Items = {IBS_ItemID.DiceProjector},
},
Hush = {
	PaperNames = {'bisaac_falsehood'},
	Pockets = {IBS_PocketID.BIsaac},
},
Delirium = {
	PaperNames = {'light_d6'},
	Items = {IBS_ItemID.LightD6},
},
Witness = {
	PaperNames = {'bacon_saver'},
	Trinkets = {IBS_TrinketID.BaconSaver},
},
Beast = {
	PaperNames = {'no_options'},
	Items = {IBS_ItemID.NoOptions},
},
Greed = {
	PaperNames = {'ssg'},
	Items = {IBS_ItemID.SSG},
},
FINISHED = {
	PaperNames = {'boss_temperance'},
},

})



return BIsaac