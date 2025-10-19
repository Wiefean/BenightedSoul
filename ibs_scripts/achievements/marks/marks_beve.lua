--昧化夏娃通关标记设置

local mod = Isaac_BenightedSoul
local Marks = mod.IBS_Class.Marks
local IBS_ItemID = mod.IBS_ItemID
local IBS_TrinketID = mod.IBS_TrinketID
local IBS_PocketID = mod.IBS_PocketID


local BEve = Marks(mod.IBS_PlayerID.BEve, {

Heart = {
	PaperNames = {'ffruit'},
	Items = {IBS_ItemID.ForbiddenFruit},
},
Isaac = {
	PaperNames = {'the_eye_of_truth'},
	Items = {IBS_ItemID.TheEyeofTruth},
},
BlueBaby = {
	PaperNames = {'yongle'},
	Items = {IBS_ItemID.Yongle},
},
-- Satan = {
	-- PaperNames = {'vein_miner'},
	-- Items = {IBS_ItemID.VeinMiner},
-- },
-- Lamb = {
	-- PaperNames = {'vain_miner'},
	-- Items = {Items.VainMiner},
-- },
-- MegaSatan = {
	-- PaperNames = {'czd6'},
	-- Pockets = {IBS_PocketID.CuZnD6},
-- },
BossRush = {
	PaperNames = {'reused_story'},
	Items = {IBS_ItemID.ReusedStory},
},
Hush = {
	PaperNames = {'beve_falsehood'},
	Pockets = {IBS_PocketID.BEve},
},
Delirium = {
	PaperNames = {'my_fruit_fault'},
	Items = {IBS_ItemID.MyFruit, IBS_ItemID.MyFault},
},
Witness = {
	PaperNames = {'folk_prescription'},
	Items = {IBS_ItemID.FolkPrescription},
},
Beast = {
	PaperNames = {'burning_of_unburnt_god'},
	Items = {IBS_ItemID.UnburntGod},
},
Greed = {
	PaperNames = {'zoth'},
	Items = {IBS_ItemID.Zoth},
},
-- FINISHED = {
	-- PaperNames = {'boss_temperance'},
-- },

})



return BEve