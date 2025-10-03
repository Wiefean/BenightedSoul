--错误硬币

local mod = Isaac_BenightedSoul

local game = Game()

local GlitchedPenny = mod.IBS_Class.Trinket(mod.IBS_TrinketID.GlitchedPenny)

--拾取硬币时有概率变化
function GlitchedPenny:PreCoinCollision(pickup, other)
	if pickup.SubType ~= 1 then return end
	local player = other:ToPlayer()
	if player and player:HasTrinket(self.ID) and self._Pickups:CanCollect(pickup, player) then
		local rng = RNG(pickup.InitSeed)
		local chance = rng:RandomInt(math.min(100, 10 + 5 * player:GetTrinketMultiplier(self.ID)), 100)
		if rng:RandomInt(100) < chance then
			pickup:Morph(5, 20, 0, true, false)
			return true
		end
	end	
end
GlitchedPenny:AddPriorityCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, CallbackPriority.LATE, 'PreCoinCollision', PickupVariant.PICKUP_COIN)


return GlitchedPenny