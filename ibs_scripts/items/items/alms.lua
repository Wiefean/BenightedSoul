--施粥处

local mod = Isaac_BenightedSoul
local IBS_ItemID = mod.IBS_ItemID

local game = Game()

local Alms = mod.IBS_Class.Item(IBS_ItemID.Alms)

--获得
function Alms:OnGain(item, charge, first, slot, varData, player)
	if first then
		local room = game:GetRoom()
		local pos = room:FindFreePickupSpawnPosition(player.Position, 0, true)
		Isaac.Spawn(5, 300, 21, pos, Vector.Zero, nil)
	end
end
Alms:AddCallback(ModCallbacks.MC_POST_ADD_COLLECTIBLE, 'OnGain', Alms.ID)


--乞丐池道具免费且二选一
function Alms:OnPickupFirstAppear(pickup)
	if not PlayerManager.AnyoneHasCollectible(self.ID) then return end
	if pickup.SubType <= 0 then return end
	local room = game:GetRoom()

	for _,pool in ipairs(self._Pools.BeggarPool) do
		if self._Pools:IsCollectibleInPool(pickup.SubType, pool) then
			local id = game:GetItemPool():GetCollectible(pool, true, pickup.InitSeed, 25)
			pickup:AddCollectibleCycle(id)
			pickup.Price = 0
			break
		end
	end
end
Alms:AddCallback(mod.IBS_CallbackID.PICKUP_FIRST_APPEAR, 'OnPickupFirstAppear', 100)



return Alms