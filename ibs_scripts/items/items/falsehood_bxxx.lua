--???的伪忆

local mod = Isaac_BenightedSoul

local game = Game()

local FalsehoodOfXXX = mod.IBS_Class.Item(mod.IBS_ItemID.FalsehoodOfXXX)

--获得
function FalsehoodOfXXX:OnGain(item, charge, first, slot, varData, player)
	if first then
		local falsehood = self._Pools:GetRandomFalsehood(player:GetCollectibleRNG(self.ID))
		local room = game:GetRoom()
		local pos = room:FindFreePickupSpawnPosition(player.Position, 0, true)		
		local pickup = Isaac.Spawn(5, 300, falsehood, pos, Vector.Zero, player):ToPickup()
	end
end
FalsehoodOfXXX:AddCallback(ModCallbacks.MC_POST_ADD_COLLECTIBLE, 'OnGain', FalsehoodOfXXX.ID)


return FalsehoodOfXXX