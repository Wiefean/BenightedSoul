--诅咒之心

local mod = Isaac_BenightedSoul
local IBS_Item = mod.IBS_Item
local Pools = mod.IBS_Lib.Pools

mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, function()
	local game = Game()
	local room = game:GetRoom()
	
	if room:IsFirstVisit() and (room:GetType() == RoomType.ROOM_CURSE) then
		local num = 0
		local rng = nil
		
		for i = 0, game:GetNumPlayers() -1 do
			local player = Isaac.GetPlayer(i)
			num = num + player:GetCollectibleNum(IBS_Item.cheart)
			
			if not rng then
				rng = player:GetCollectibleRNG(IBS_Item.cheart)
			end
		end
		
		if num > 0 then
			for i = 1,num do
				local item = game:GetItemPool():GetCollectible(ItemPoolType.POOL_CURSE, true, rng:Next())
				local pos = game:GetRoom():FindFreePickupSpawnPosition((room:GetCenterPos()), 0, true)
				local item = Isaac.Spawn(5, 100, item, pos, Vector(0,0), nil):ToPickup()
				item.ShopItemId = -2
				item.Price = -1	
			end
		end
	end
end)
