--被弃行李箱

local mod = Isaac_BenightedSoul

local game = Game()

local AbandonedLuggage = mod.IBS_Class.Item(mod.IBS_ItemID.AbandonedLuggage)

--获得时
function AbandonedLuggage:OnGainItem(item, charge, first, slot, varData, player)
	if first then
		local room = game:GetRoom()
		for i = 1,5 do		
			local id = game:GetItemPool():GetTrinket()
			local pos = room:FindFreePickupSpawnPosition(player.Position, 0, true)
			Isaac.Spawn(5, 350, id, pos, Vector.Zero, nil):ToPickup().Wait = 45
		end
	end
end
AbandonedLuggage:AddCallback(ModCallbacks.MC_POST_ADD_COLLECTIBLE, 'OnGainItem', AbandonedLuggage.ID)

return AbandonedLuggage