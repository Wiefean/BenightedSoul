--昧化阿撒泻勒通关标记设置

local mod = Isaac_BenightedSoul
local Marks = mod.IBS_Class.Marks
local IBS_ItemID = mod.IBS_ItemID
local IBS_TrinketID = mod.IBS_TrinketID
local IBS_PocketID = mod.IBS_PocketID

local game = Game()

local BAzazel = Marks(mod.IBS_PlayerID.BAzazel, {

Heart = {
	PaperNames = {'entanglement'},
	Items = {IBS_ItemID.Entanglement},
},
Isaac = {
	PaperNames = {'atonement_ceremony'},
	Items = {IBS_ItemID.AtonementCeremony},
},
BlueBaby = {
	PaperNames = {'mm'},
	Items = {IBS_ItemID.MM},
},
Satan = {
	PaperNames = {'azazel_the_wild'},
	Items = {IBS_ItemID.AzazelTheWild},
},
Lamb = {
	PaperNames = {'mms'},
	Trinkets = {IBS_TrinketID.MMS},
},
-- MegaSatan = {
	-- PaperNames = {''},
-- },
BossRush = {
	PaperNames = {'calocybe_gambosa'},
	Items = {IBS_ItemID.CalocybeGambosa},
},
Hush = {
	PaperNames = {'bazazel_falsehood'},
	Pockets = {IBS_PocketID.BAzazel},
},
Delirium = {
	PaperNames = {'witch_hunting_season'},
	Items = {IBS_ItemID.WitchHuntingSeason},
},
Witness = {
	PaperNames = {'rites_of_the_roots'},
	Items = {IBS_ItemID.RitesOfTheRoots},
},
Beast = {
	PaperNames = {'a_drop_of_blood'},
	Items = {IBS_ItemID.ADropOfBlood},
},
Greed = {
	PaperNames = {'on_the_pyre'},
	Items = {IBS_ItemID.OnThePyre},
},
FINISHED = {
	PaperNames = {'blessing_of_michael'},
	Items = {IBS_ItemID.BlessingOfMichael},
},

})


return BAzazel