--古老硬币

local mod = Isaac_BenightedSoul

local game = Game()

local OldPenny = mod.IBS_Class.Trinket(mod.IBS_TrinketID.OldPenny)

--拾取硬币时减少游戏计时
function OldPenny:OnCoinCollision(pickup, other)
	local player = other:ToPlayer()
	if player and player:HasTrinket(self.ID) and self._Pickups:CanCollect(pickup, player) then
		local rng = RNG(pickup.InitSeed)
		local value = pickup:GetCoinValue()

		for i = 1,player:GetTrinketMultiplier(self.ID) do
			game.TimeCounter = math.max(30, game.TimeCounter - 5*30*value)
		end

		--少于10分钟则概率触发7书
		if game.TimeCounter < 18000 and rng:RandomInt(100) < 25 then
			player:UseActiveItem(97, false, false)
		end
	end	
end
OldPenny:AddPriorityCallback(ModCallbacks.MC_POST_PICKUP_COLLISION, CallbackPriority.LATE, 'OnCoinCollision', PickupVariant.PICKUP_COIN)

return OldPenny