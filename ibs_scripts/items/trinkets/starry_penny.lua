--星空硬币

local mod = Isaac_BenightedSoul

local game = Game()

local StarryPenny = mod.IBS_Class.Trinket(mod.IBS_TrinketID.StarryPenny)

--拾取硬币时
function StarryPenny:OnCoinCollision(pickup, other)
	local player = other:ToPlayer()
	if player and player:HasTrinket(self.ID) and self._Pickups:CanCollect(pickup, player) then
		local rng = RNG(pickup.InitSeed)
		local value = pickup:GetCoinValue()
		local int = rng:RandomInt(100)
		
		--符文碎片
		if rng:RandomInt(100) < 10 + 5*value + 10*player:GetTrinketMultiplier(self.ID) then
			Isaac.Spawn(5, 300, 55, pickup.Position, Vector.Zero, nil)
		end
		
		--增加星象房开启率
		local data = self:GetIBSData('temp')
		data.StarryPennyPlanetariumChance = data.StarryPennyPlanetariumChance or 0
		data.StarryPennyPlanetariumChance = data.StarryPennyPlanetariumChance + 0.001
	end	
end
StarryPenny:AddPriorityCallback(ModCallbacks.MC_POST_PICKUP_COLLISION, CallbackPriority.LATE, 'OnCoinCollision', PickupVariant.PICKUP_COIN)

--更改星象房开启率
function StarryPenny:OnPlanetariumChance(chance)
	if game:GetLevel():GetStage() == 1 then return end
	if game:IsGreedMode() then return end
	local data = self:GetIBSData('temp')
	if data.StarryPennyPlanetariumChance then
		return chance + data.StarryPennyPlanetariumChance
	end
end
StarryPenny:AddCallback(ModCallbacks.MC_PRE_PLANETARIUM_APPLY_ITEMS, 'OnPlanetariumChance')

return StarryPenny