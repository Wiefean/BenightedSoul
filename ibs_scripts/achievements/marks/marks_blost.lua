--昧化游魂通关标记设置

local mod = Isaac_BenightedSoul
local Marks = mod.IBS_Class.Marks
local IBS_ItemID = mod.IBS_ItemID
local IBS_TrinketID = mod.IBS_TrinketID
local IBS_PocketID = mod.IBS_PocketID


local BLost = Marks(mod.IBS_PlayerID.BLost, {

Heart = {
	PaperNames = {'treasure_key'},
	Items = {IBS_ItemID.TreasureKey},
},
Isaac = {
	PaperNames = {'wildering_mirror'},
	Items = {IBS_ItemID.WilderingMirror},
},
BlueBaby = {
	PaperNames = {'the_horned_axe'},
	Items = {IBS_ItemID.TheHornedAxe},
},
Satan = {
	PaperNames = {'moon_streets'},
	Items = {IBS_ItemID.MoonStreets},
},
Lamb = {
	PaperNames = {'akey47'},
	Items = {IBS_ItemID.AKEY47},
},
MegaSatan = {
	PaperNames = {'brother_albern'},
	Items = {IBS_ItemID.TruthChest},
},
BossRush = {
	PaperNames = {'odd_key'},
	Trinkets = {IBS_TrinketID.OddKey},
},
Hush = {
	PaperNames = {'blost_falsehood'},
	Pockets = {IBS_PocketID.BLost},
},
Delirium = {
	PaperNames = {'chest_chest'},
	Items = {IBS_ItemID.ChestChest},
},
Witness = {
	PaperNames = {'neopolitan'},
	Trinkets = {IBS_TrinketID.Neopolitan},
},
Beast = {
	PaperNames = {'knock'},
	Items = {IBS_ItemID.Knock},
},
Greed = {
	PaperNames = {'fomalhunt'},
	Items = {IBS_ItemID.Fomalhunt},
},
FINISHED = {
	PaperNames = {'the_silver_key'},
	Items = {IBS_ItemID.SilverKey},
},

})



return BLost