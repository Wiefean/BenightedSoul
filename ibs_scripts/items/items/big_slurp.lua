--超大杯

local mod = Isaac_BenightedSoul
local IBS_ItemID = mod.IBS_ItemID

local game = Game()

local BigSlurp = mod.IBS_Class.Item(IBS_ItemID.BigSlurp)


--获得时触发
function BigSlurp:OnGain(item, charge, first, slot, varData, player)
	if first then
		local room = game:GetRoom()
		for i = 1,2 do		
			local pos = room:FindFreePickupSpawnPosition(player.Position + Vector((-1)^i *40,0), 0, true)
			Isaac.Spawn(5, 100, 197, pos, Vector.Zero, nil)
		end
	end
end
BigSlurp:AddCallback(ModCallbacks.MC_POST_ADD_COLLECTIBLE, 'OnGain', BigSlurp.ID)



return BigSlurp