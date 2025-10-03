--昧化店主通关标记设置

local mod = Isaac_BenightedSoul
local Marks = mod.IBS_Class.Marks
local Levels = mod.IBS_Lib.Levels
local Pools = mod.IBS_Lib.Pools
local IBS_ItemID = mod.IBS_ItemID
local IBS_TrinketID = mod.IBS_TrinketID
local IBS_PocketID = mod.IBS_PocketID

local game = Game()

--"慷慨一些"贪婪商店额外概率出现捐款机
mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, function()
	if not mod:GetIBSData('persis')['BKeeper'].MegaSatan then return end
	if not game:IsGreedMode() then return end
	local room = game:GetRoom()
	
	if room:GetType() == RoomType.ROOM_SHOP and room:IsFirstVisit() and #Isaac.FindByType(6,8,0) <= 0 then
		local rng = RNG(mod.IBS_Lib.Levels:GetRoomUniqueSeed())
		local int = rng:RandomInt(100)
		if int < 50 then
			Isaac.Spawn(6, 8, 0, room:FindFreePickupSpawnPosition(room:GetGridPosition(78), 0, true), Vector.Zero, nil)		
		end
	end
end)

local BKeeper = Marks(mod.IBS_PlayerID.BKeeper, {

Heart = {
	PaperNames = {'alms'},
	Items = {IBS_ItemID.Alms},
},
Isaac = {
	PaperNames = {'panacea'},
	Items = {IBS_ItemID.Panacea},
},
BlueBaby = {
	PaperNames = {'contact_c'},
	Items = {
		IBS_ItemID.ContactC,
		IBS_ItemID.MaxxC,
		IBS_ItemID.SneakyC,
		IBS_ItemID.ConfrontingC,
		IBS_ItemID.RetaliatingC,
	},
},
Satan = {
	PaperNames = {'minihorn'},
	Items = {IBS_ItemID.MiniHorn},
},
Lamb = {
	PaperNames = {'rich_mines'},
	Items = {IBS_ItemID.RichMines},
},
MegaSatan = {
	PaperNames = {'generouser'},
	Trinkets = {
		IBS_TrinketID.GlitchedPenny,
		IBS_TrinketID.StarryPenny,
		IBS_TrinketID.PaperPenny,
		IBS_TrinketID.OldPenny,
	},
},
BossRush = {
	PaperNames = {'faces'},
	Trinkets = {
		IBS_TrinketID.CultistMask,
		IBS_TrinketID.SsserpentHead,
		IBS_TrinketID.ClericFace,
		IBS_TrinketID.NlothsMask,
		IBS_TrinketID.GremlinMask,
	},
},
Hush = {
	PaperNames = {'bkeeper_falsehood'},
	Pockets = {IBS_PocketID.BKeeper},
},
Delirium = {
	PaperNames = {'another_karma'},
	Items = {IBS_ItemID.AnotherKarma},
},
Witness = {
	PaperNames = {'scp'},
	Items = {IBS_ItemID.SCP018},
},
Beast = {
	PaperNames = {'multiplication'},
	Items = {IBS_ItemID.Multiplication},
},
Greed = {
	PaperNames = {'master_pack'},
	Items = {
		IBS_ItemID.MasterPack,
		IBS_ItemID.Multiply,
		IBS_ItemID.SmileWorld,
	},
},
-- FINISHED = {
	-- PaperNames = {'boss_generosity'},
-- },

})


return BKeeper