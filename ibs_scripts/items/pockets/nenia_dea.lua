--挽歌儿小姐

local mod = Isaac_BenightedSoul
local IBS_ItemID = mod.IBS_ItemID
local IBS_PocketID = mod.IBS_PocketID

local game = Game()
local sfx = SFXManager()

local NeniaDea = mod.IBS_Class.Pocket(IBS_PocketID.NeniaDea)

--对照表(除开???)
local TransTable = {
	[81] = IBS_PocketID.BIsaac,
	[IBS_PocketID.BIsaac] = 81,

	[82] = IBS_PocketID.BMaggy,
	[IBS_PocketID.BMaggy] = 82,
	
	[83] = IBS_PocketID.BCain,
	[IBS_PocketID.BCain] = 83,
	
	[84] = IBS_PocketID.BJudas,
	[IBS_PocketID.BJudas] = 84,
	
	[86] = IBS_PocketID.BEve,
	[IBS_PocketID.BEve] = 86,
	
	[87] = IBS_PocketID.BSamson,
	[IBS_PocketID.BSamson] = 87,
	
	[88] = IBS_PocketID.BAzazel,
	[IBS_PocketID.BSamson] = 88,

	[89] = IBS_PocketID.BLazarus,
	[IBS_PocketID.BLazarus] = 89,
	
	[90] = IBS_PocketID.BEden,
	[IBS_PocketID.BEden] = 90,
	
	[91] = IBS_PocketID.BLost,
	[IBS_PocketID.BLost] = 91,
	
	[92] = IBS_PocketID.BLilith,
	[IBS_PocketID.BLilith] = 92,
	
	[93] = IBS_PocketID.BKeeper,
	[IBS_PocketID.BKeeper] = 93,
	
	[94] = IBS_PocketID.BApollyon,
	[IBS_PocketID.BApollyon] = 94,
	
	[95] = IBS_PocketID.BForgotten,
	[IBS_PocketID.BForgotten] = 95,
	
	[96] = IBS_PocketID.BBeth,
	[IBS_PocketID.BBeth] = 96,
	
	[97] = IBS_PocketID.BJBE,	
	[IBS_PocketID.BJBE] = 97,
}

--生成列表
NeniaDea.SpawnList = {
	{Variant = 100, ID = IBS_ItemID.FalsehoodOfXXX}
}
for id,_ in pairs(TransTable) do
	table.insert(NeniaDea.SpawnList, {Variant = 300, ID = id})
end

--使用
function NeniaDea:OnUse(card,player,flag)
	local did = false
	
	for _,ent in ipairs(Isaac.FindByType(5)) do
		local pickup = ent:ToPickup()
		if pickup then
			if pickup.Variant == 100 and pickup.SubType == IBS_ItemID.FalsehoodOfXXX then
				--???的伪忆
				pickup:Morph(5, 300, 85, true)
				Isaac.Spawn(1000, 15, 0, pickup.Position, Vector.Zero, nil)	
				did = true
			elseif pickup.Variant == 300 then
				if pickup.SubType == 85 then --???的魂石
					pickup:Morph(5, 100, IBS_ItemID.FalsehoodOfXXX, true)
					Isaac.Spawn(1000, 15, 0, pickup.Position, Vector.Zero, nil)					
					did = true
				else
					local id = TransTable[pickup.SubType]
					if id then				
						pickup:Morph(5, 300, id, true)
						Isaac.Spawn(1000, 15, 0, pickup.Position, Vector.Zero, nil)	
						did = true
					end
				end
			end
		end
	end

	--没有转换则生成一个
	if not did then
		local room = game:GetRoom()
		local pos = room:FindFreePickupSpawnPosition(player.Position, 0, true)	
		local rng = player:GetCardRNG(self.ID)
		local tbl = self.SpawnList[rng:RandomInt(1,#self.SpawnList)] or {Variant = 300, ID = 81}
		Isaac.Spawn(5, tbl.Variant, tbl.ID, pos, Vector.Zero, player)
		Isaac.Spawn(1000, 15, 0, pos, Vector.Zero, nil)	
	end
end
NeniaDea:AddCallback(ModCallbacks.MC_USE_CARD, 'OnUse', NeniaDea.ID)


return NeniaDea