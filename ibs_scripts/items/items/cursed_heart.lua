--诅咒之心

local mod = Isaac_BenightedSoul

local game = Game()

local CursedHeart = mod.IBS_Class.Item(mod.IBS_ItemID.CursedHeart)

--诅咒房额外道具
function CursedHeart:OnNewRoom()
	local room = game:GetRoom()
	
	if room:IsFirstVisit() and (room:GetType() == RoomType.ROOM_CURSE) then
		local num = 0
		
		for i = 0, game:GetNumPlayers() -1 do
			local player = Isaac.GetPlayer(i)
			num = num + player:GetCollectibleNum(self.ID)
		end
		
		if num > 0 then
			local seed = self._Levels:GetRoomUniqueSeed()
			for i = 1,num do
				local id = game:GetItemPool():GetCollectible(ItemPoolType.POOL_CURSE, true, seed)
				local pos = room:FindFreePickupSpawnPosition((room:GetCenterPos()), 0, true)
				local item = Isaac.Spawn(5, 100, id, pos, Vector(0,0), nil):ToPickup()
				item.ShopItemId = -2
				item.Price = -1	
			end
		end
	end
end
CursedHeart:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, 'OnNewRoom')

--获得时,如果在诅咒房,立刻触发一次效果
function CursedHeart:OnGainItem(item, charge, first, slot, varData, player)
	local room = game:GetRoom()
	if first and (room:GetType() == RoomType.ROOM_CURSE) then
		local id = game:GetItemPool():GetCollectible(ItemPoolType.POOL_CURSE, true, self._Levels:GetRoomUniqueSeed())
		local pos = room:FindFreePickupSpawnPosition((room:GetCenterPos()), 0, true)
		local item = Isaac.Spawn(5, 100, id, pos, Vector(0,0), nil):ToPickup()
		item.ShopItemId = -2
		item.Price = -1	
	end
end
CursedHeart:AddCallback(ModCallbacks.MC_POST_ADD_COLLECTIBLE, 'OnGainItem', CursedHeart.ID)



return CursedHeart