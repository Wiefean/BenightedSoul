--出口产品

local mod = Isaac_BenightedSoul

local game = Game()
local config = Isaac.GetItemConfig() 

local Export = mod.IBS_Class.Trinket(mod.IBS_TrinketID.Export)

--效果
function Export:OnNewRoom()
	local mult = PlayerManager.GetTotalTrinketMultiplier(self.ID)
	if mult <= 0 then return end
	local room = game:GetRoom()
	if not room:IsFirstVisit() then return end
	local roomType = room:GetType()
	local devil = (roomType == RoomType.ROOM_DEVIL)
	local angel = (roomType == RoomType.ROOM_ANGEL)
	if not (devil or angel) then return end

	if RNG(self._Levels:GetRoomUniqueSeed()):RandomInt(100) < 50*mult then
		local pool = (devil and ItemPoolType.POOL_ANGEL) or ItemPoolType.POOL_DEVIL
		local id = game:GetItemPool():GetCollectible(pool, true, self._Levels:GetRoomUniqueSeed())
		local pos = room:FindFreePickupSpawnPosition((room:GetCenterPos()), 0, true)
		local item = Isaac.Spawn(5, 100, id, pos, Vector(0,0), nil):ToPickup()

		if devil then
			item.AutoUpdatePrice = false
		else
			item.ShopItemId = -2
		end

		local itemConfig = config:GetCollectible(id)
		local price = (itemConfig and itemConfig.ShopPrice) or 15
		item.Price = (devil and price) or -1
	end
end
Export:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, 'OnNewRoom')


return Export