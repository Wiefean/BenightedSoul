--选择悖论

local mod = Isaac_BenightedSoul
local IBS_ItemID = mod.IBS_ItemID

local game = Game()
local config = Isaac.GetItemConfig()

local ChoicesParadox = mod.IBS_Class.Item(IBS_ItemID.ChoicesParadox)

--新层
function ChoicesParadox:OnNewLevel()
	if not PlayerManager.AnyoneHasCollectible(self.ID) then return end
	local room = game:GetRoom()
	local itemPool = game:GetItemPool()
	local index = self._Pickups:GetUniqueOptionsIndex()

	for i = 1,5 do	
		local pos = room:FindFreePickupSpawnPosition(room:GetCenterPos() + Vector(-240 + i*80,-80), 0, true)
		local seed = math.max(1, self._Levels:GetLevelUniqueSeed() - i)
		local id = itemPool:GetCard(seed, false, true, true)
		local pickup = Isaac.Spawn(5, 300, id, pos, Vector.Zero, nil):ToPickup()
		pickup.OptionsPickupIndex = index
	end
end
ChoicesParadox:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, 'OnNewLevel')

return ChoicesParadox
