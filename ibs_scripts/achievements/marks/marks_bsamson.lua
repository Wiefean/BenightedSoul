--昧化参孙通关标记设置

local mod = Isaac_BenightedSoul
local Marks = mod.IBS_Class.Marks
local IBS_ItemID = mod.IBS_ItemID
local IBS_TrinketID = mod.IBS_TrinketID
local IBS_PocketID = mod.IBS_PocketID

local game = Game()

local BSamson = Marks(mod.IBS_PlayerID.BSamson, {

Heart = {
	PaperNames = {'dmg_transmitter'},
	Items = {IBS_ItemID.DMGTransmitter},
},
Isaac = {
	PaperNames = {'peace_pipe'},
	Items = {IBS_ItemID.PeacePipe},
},
BlueBaby = {
	PaperNames = {'spirit_poop'},
	Items = {IBS_ItemID.SpiritPoop},
},
Satan = {
	PaperNames = {'luck_enchantment'},
	Items = {IBS_ItemID.LuckEnchantment},
},
Lamb = {
	PaperNames = {'signature_move'},
	Items = {IBS_ItemID.SignatureMove},
},
-- MegaSatan = {
	-- PaperNames = {'corrected_data'},
-- },
BossRush = {
	PaperNames = {'armageddon'},
	Items = {IBS_ItemID.Armageddon},
},
Hush = {
	PaperNames = {'bsamson_falsehood'},
	Pockets = {IBS_PocketID.BSamson},
},
Delirium = {
	PaperNames = {'posture'},
	Items = {IBS_ItemID.Posture},
},
Witness = {
	PaperNames = {'bulky_worm'},
	Trinkets = {IBS_TrinketID.BulkyWorm},
},
Beast = {
	PaperNames = {'loong'},
	Items = {IBS_ItemID.Loong},
},
Greed = {
	PaperNames = {'maw_bank'},
	Items = {IBS_ItemID.MawBank},
},
-- FINISHED = {
	-- PaperNames = {'d4d'},
	-- Items = {IBS_ItemID.D4D},
-- },

})


return BSamson