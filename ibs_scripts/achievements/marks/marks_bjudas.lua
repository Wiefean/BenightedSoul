--昧化犹大通关标记设置

local mod = Isaac_BenightedSoul
local Marks = mod.IBS_Class.Marks
local IBS_ItemID = mod.IBS_ItemID
local IBS_TrinketID = mod.IBS_TrinketID
local IBS_PocketID = mod.IBS_PocketID


local BJudas = Marks(mod.IBS_PlayerID.BJudas, {

Heart = {
	PaperNames = {'tenebrosity'},
	Items = {IBS_ItemID.Tenebrosity},
},
Isaac = {
	PaperNames = {'presentational_mind'},
	Trinkets = {IBS_TrinketID.PresentationalMind},
},
BlueBaby = {
	PaperNames = {'export'},
	Trinkets = {IBS_TrinketID.Export},
},
Satan = {
	PaperNames = {'chaotic_belief'},
	Trinkets = {IBS_TrinketID.ChaoticBelief},
},
Lamb = {
	PaperNames = {'rules_book'},
	Items = {IBS_ItemID.RulesBook},
},
MegaSatan = {
	PaperNames = {'collectionbox'},
	Pockets = {IBS_PocketID.StolenYear},
},
BossRush = {
	PaperNames = {'stolen_decade'},
	Items = {IBS_ItemID.StolenDecade},
},
Hush = {
	PaperNames = {'bjudas_falsehood'},
	Pockets = {IBS_PocketID.BJudas},
},
Delirium = {
	PaperNames = {'tgoj'},
	Items = {IBS_ItemID.TGOJ},
},
Witness = {
	PaperNames = {'throny_ring'},
	Trinkets = {IBS_TrinketID.ThronyRing},
},
Beast = {
	PaperNames = {'sword'},
	Items = {IBS_ItemID.Sword},
},
Greed = {
	PaperNames = {'nail'},
	Items = {IBS_ItemID.ReservedNail},
},
-- FINISHED = {
	-- PaperNames = {''},
-- },

})


return BJudas