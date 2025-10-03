--昧化伊甸通关标记设置

local mod = Isaac_BenightedSoul
local Marks = mod.IBS_Class.Marks
local Levels = mod.IBS_Lib.Levels
local Pools = mod.IBS_Lib.Pools
local IBS_ItemID = mod.IBS_ItemID
local IBS_TrinketID = mod.IBS_TrinketID
local IBS_PocketID = mod.IBS_PocketID

local game = Game()

--"存档修正"重进房间自动重置错误道具(包括错误技)
mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, function()
	if not mod:GetIBSData('persis')['BEden'].MegaSatan then return end
	if game:GetRoom():IsFirstVisit() then return end
	if PlayerManager.AnyoneHasCollectible(721) then return end
	for _,ent in ipairs(Isaac.FindByType(5,100)) do
		local pickup = ent:ToPickup()
		local id = pickup.SubType
		if id > 10000 or id == 721 then
			local seed = Levels:GetRoomUniqueSeed()
			local new = game:GetItemPool():GetCollectible(Pools:GetRoomPool(seed), true, seed, 25)		
			pickup:Morph(5,100,new, true, false, true)
		end
	end
end)

local BEden = Marks(mod.IBS_PlayerID.BEden, {

Heart = {
	PaperNames = {'blackjack'},
	Items = {IBS_ItemID.Blackjack},
},
Isaac = {
	PaperNames = {'interval'},
	Trinkets = {IBS_TrinketID.Interval},
},
BlueBaby = {
	PaperNames = {'molekale'},
	Items = {IBS_ItemID.Molekale},
},
Satan = {
	PaperNames = {'ssstew'},
	Items = {IBS_ItemID.Ssstew},
},
Lamb = {
	PaperNames = {'sketch'},
	Items = {IBS_ItemID.Sketch},
},
MegaSatan = {
	PaperNames = {'corrected_data'},
},
BossRush = {
	PaperNames = {'super_panic_button'},
	Items = {IBS_ItemID.SuperPanicButton},
},
Hush = {
	PaperNames = {'beden_falsehood'},
	Pockets = {IBS_PocketID.BEden},
},
Delirium = {
	PaperNames = {'defined'},
	Items = {IBS_ItemID.Defined},
},
Witness = {
	PaperNames = {'numeron_force'},
	Trinkets = {IBS_TrinketID.NumeronForce},
},
Beast = {
	PaperNames = {'hypercube'},
	Items = {IBS_ItemID.Hypercube},
},
Greed = {
	PaperNames = {'book_of_seen'},
	Items = {IBS_ItemID.BookOfSeen},
},
FINISHED = {
	PaperNames = {'d4d'},
	Items = {IBS_ItemID.D4D},
},

})


return BEden