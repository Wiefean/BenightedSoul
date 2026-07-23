--锂电池

local mod = Isaac_BenightedSoul

local game = Game()

local LithiumBattery = mod.IBS_Class.Trinket(mod.IBS_TrinketID.LithiumBattery)

--购物检测
function LithiumBattery:OnPurchasePickup(pickup, player, price)
	if price > 0 and player:HasTrinket(self.ID, true) then
		local mult = PlayerManager.GetTotalTrinketMultiplier(self.ID)
		if mult > 2 then mult = 2 end
		if price >= 7 - 2 * mult then
			local room = game:GetRoom()
			local pos = room:FindFreePickupSpawnPosition(room:GetCenterPos(), 0, true)		
			Isaac.Spawn(5, 90, 1, pos, Vector.Zero, player)
		end
	end
end
LithiumBattery:AddCallback(ModCallbacks.MC_POST_PICKUP_SHOP_PURCHASE, 'OnPurchasePickup')


return LithiumBattery