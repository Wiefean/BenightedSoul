--妈妈的旧钥匙

local mod = Isaac_BenightedSoul

local game = Game()

local MomsOldKey = mod.IBS_Class.Item(mod.IBS_ItemID.MomsOldKey)

--普通箱子替换
function MomsOldKey:OnPickupInit(pickup)
	if not PlayerManager.AnyoneHasCollectible(self.ID) then return end
	if not self._Pickups:IsChest(pickup.Variant) then return end
	if RNG(pickup.InitSeed):RandomInt(100) < 50 then
		pickup:Morph(5,55,1, true)
	end
end
MomsOldKey:AddCallback(ModCallbacks.MC_POST_PICKUP_INIT, 'OnPickupInit', 50)

--新层给钥匙
function MomsOldKey:OnNewLevel()
	for i = 0, game:GetNumPlayers() - 1 do
		local player = Isaac.GetPlayer(i)
		if player:HasCollectible(self.ID) then
			player:AddKeys(2)
		end
	end
end
MomsOldKey:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, 'OnNewLevel')


return MomsOldKey