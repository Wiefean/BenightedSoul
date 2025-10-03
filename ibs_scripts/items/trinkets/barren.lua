--贫瘠

local mod = Isaac_BenightedSoul

local Barren = mod.IBS_Class.Trinket(mod.IBS_TrinketID.Barren)

--受伤翻倍
function Barren:PreTakeDMG(ent, dmg, flag, source, cd)
	if dmg <= 0 then return end
	local player = ent:ToPlayer()

	if player then
		if player:HasTrinket(self.ID) then
			return {Damage = dmg + 1}
		end	
	elseif self._Ents:IsEnemy(ent) then
		if PlayerManager.AnyoneHasTrinket(self.ID) then
			return {Damage = dmg * 1.5}
		end
	end
end
Barren:AddPriorityCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, -10, 'PreTakeDMG')

--心,硬币,炸弹,钥匙消失
function Barren:OnPickupInit(pickup)
	if PlayerManager.AnyoneHasTrinket(self.ID) then
		local variant = pickup.Variant
		
		if (variant == 10) or (variant == 20) or (variant == 30)or (variant == 40) then
			local mult = PlayerManager.GetTotalTrinketMultiplier(self.ID)
			if (pickup.Timeout == -1) or (pickup.Timeout > 90) then
				pickup.Timeout = 90 * mult
			end
		end
	end	
end
Barren:AddCallback(ModCallbacks.MC_POST_PICKUP_INIT, 'OnPickupInit')


return Barren