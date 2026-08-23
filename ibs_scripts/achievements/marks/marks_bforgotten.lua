--昧化遗骸通关标记设置

local mod = Isaac_BenightedSoul
local Marks = mod.IBS_Class.Marks
local IBS_ItemID = mod.IBS_ItemID
local IBS_TrinketID = mod.IBS_TrinketID
local IBS_PocketID = mod.IBS_PocketID


local BForgotten = Marks(mod.IBS_PlayerID.BForgotten, {

Heart = {
	PaperNames = {'bony_knife'},
	Items = {IBS_ItemID.BonyKnife},
},
Isaac = {
	PaperNames = {'ghd'},
	Items = {IBS_ItemID.GHD},
},
BlueBaby = {
	PaperNames = {'cranium'},
	Items = {IBS_ItemID.Cranium},
},
Satan = {
	PaperNames = {'false_ghd'},
	Items = {IBS_ItemID.FGHD},
},
Lamb = {
	PaperNames = {'dusty_bombs'},
	Items = {IBS_ItemID.DustyBomb},
},
MegaSatan = {
	PaperNames = {'graveyard'},
},
BossRush = {
	PaperNames = {'moon_streets'},
	Items = {IBS_ItemID.MoonStreets},
},
Hush = {
	PaperNames = {'bforgotten_falsehood'},
	Pockets = {IBS_PocketID.BForgotten},
},
Delirium = {
	PaperNames = {'temperance_bone'},
},
Witness = {
	PaperNames = {'neopolitan'},
	Trinkets = {IBS_TrinketID.Neopolitan},
},
Beast = {
	PaperNames = {'wildering_mirror'},
	Items = {IBS_ItemID.WilderingMirror},
},
Greed = {
	PaperNames = {'the_horned_axe'},
	Items = {IBS_ItemID.TheHornedAxe},
},
FINISHED = {
	PaperNames = {'familiy_portrayal'},
	Items = {IBS_ItemID.FamilyPortrayal},
},

})



return BForgotten