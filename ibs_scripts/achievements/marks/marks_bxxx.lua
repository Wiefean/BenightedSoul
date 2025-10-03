--昧化???通关标记设置

local mod = Isaac_BenightedSoul
local Marks = mod.IBS_Class.Marks
local IBS_ItemID = mod.IBS_ItemID
local IBS_TrinketID = mod.IBS_TrinketID
local IBS_PocketID = mod.IBS_PocketID

local BXXX = Marks(mod.IBS_PlayerID.BXXX, {

Heart = {
	PaperNames = {'circumcision'},
	Items = {IBS_ItemID.Circumcision},
},
Isaac = {
	PaperNames = {'needle_mushroom'},
	Items = {IBS_ItemID.NeedleMushroom},
},
BlueBaby = {
	PaperNames = {'elegiast_winter'},
	Items = {IBS_ItemID.ElegiastWinter},
	Pockets = {IBS_PocketID.NeniaDea},
},
Satan = {
	PaperNames = {'grail'},
	Items = {IBS_ItemID.Grail},
},
Lamb = {
	PaperNames = {'moth'},
	Items = {IBS_ItemID.Moth},
},
MegaSatan = {
	PaperNames = {'v7'},
	Items = {IBS_ItemID.V7},
},
BossRush = {
	PaperNames = {'profane_weapon'},
	Items = {IBS_ItemID.ProfaneWeapon},
},
Hush = {
	PaperNames = {'bxxx_falsehood'},
	Items = {IBS_ItemID.FalsehoodOfXXX},
},
Delirium = {
	PaperNames = {'falowerse'},
	Items = {IBS_ItemID.Falowerse},
},
Witness = {
	PaperNames = {'corrupted_deck'},
	Trinkets = {IBS_TrinketID.CorruptedDeck},
},
Beast = {
	PaperNames = {'forge'},
	Items = {IBS_ItemID.Forge},
},
Greed = {
	PaperNames = {'edge'},
	Items = {IBS_ItemID.Edge, IBS_ItemID.Edge2, IBS_ItemID.Edge3},
},
FINISHED = {
	PaperNames = {'secret_histories'},
	Items = {IBS_ItemID.SecretHistories},
},

})



return BXXX