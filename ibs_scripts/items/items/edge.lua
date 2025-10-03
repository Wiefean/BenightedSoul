--流亡之刃

local mod = Isaac_BenightedSoul
local IBS_ItemID = mod.IBS_ItemID

local game = Game()

local Edge = mod.IBS_Class.Item(IBS_ItemID.Edge)


--获得时触发
function Edge:OnGain(item, charge, first, slot, varData, player)
	if first then
		local room = game:GetRoom()
		local pos1 = room:FindFreePickupSpawnPosition(player.Position + Vector(-80,0), 0, true)
		local pos2 = room:FindFreePickupSpawnPosition(player.Position + Vector(80,0), 0, true)
		local idx = self._Pickups:GetUniqueOptionsIndex()
		
		local item1 = Isaac.Spawn(5, 100, IBS_ItemID.Edge2, pos1, Vector.Zero, nil):ToPickup()
		item1.OptionsPickupIndex = idx
		
		local item2 = Isaac.Spawn(5, 100, IBS_ItemID.Edge3, pos2, Vector.Zero, nil):ToPickup()
		item2.OptionsPickupIndex = idx
	end
end
Edge:AddCallback(ModCallbacks.MC_POST_ADD_COLLECTIBLE, 'OnGain', Edge.ID)



return Edge