--昧化该隐&亚伯通关标记设置

local mod = Isaac_BenightedSoul
local Marks = mod.IBS_Class.Marks
local IBS_ItemID = mod.IBS_ItemID
local IBS_TrinketID = mod.IBS_TrinketID
local IBS_PocketID = mod.IBS_PocketID

local marks = {

Heart = {
	PaperNames = {'redeath'},
	Items = {IBS_ItemID.Redeath},
},
Isaac = {
	PaperNames = {'rabbit_head'},
	Trinkets = {IBS_TrinketID.RabbitHead},
},
BlueBaby = {
	PaperNames = {'sacrifice'},
	Items = {IBS_ItemID.Sacrifice},
},
Satan = {
	PaperNames = {'left_foot'},
	Trinkets = {IBS_TrinketID.LeftFoot},
},
Lamb = {
	PaperNames = {'sacrifice2'},
	Items = {IBS_ItemID.Sacrifice2},
},
MegaSatan = {
	PaperNames = {'seed_bag'},
},
BossRush = {
	PaperNames = {'ether'},
	Items = {IBS_ItemID.Ether},
},
Hush = {
	PaperNames = {'bcain_babel_falsehood'},
	Pockets = {IBS_PocketID.BCain, IBS_PocketID.BAbel},
},
Delirium = {
	PaperNames = {'farm'},
	Items = {IBS_ItemID.PortableFarm, IBS_ItemID.Goatify},
	Trinkets = {IBS_TrinketID.WheatSeeds},
},
Witness = {
	PaperNames = {'nemesis'},
	Trinkets = {IBS_TrinketID.Nemesis},
},
Beast = {
	PaperNames = {'superb'},
	Items = {IBS_ItemID.SuperB},
},
Greed = {
	PaperNames = {'barren'},
	Trinkets = {IBS_TrinketID.Barren},
},
-- FINISHED = {
	-- PaperNames = {'boss_temperance'},
-- },

}


return {
BCain = Marks(mod.IBS_PlayerID.BCain, marks),
BAbel = Marks(mod.IBS_PlayerID.BAbel, marks),
}