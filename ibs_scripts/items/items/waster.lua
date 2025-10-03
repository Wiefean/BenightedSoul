--剩饼

local mod = Isaac_BenightedSoul

local Waster = mod.IBS_Class.Item(mod.IBS_ItemID.Waster)


--效果
function Waster:OnTakeDMG(ent, dmg)
	local player = ent:ToPlayer()

	if player and dmg > 0 then
		if player:HasCollectible(self.ID) then
			local rng = player:GetCollectibleRNG(self.ID)
			local chance = rng:RandomInt(100)

			if chance > 75 then
				player:AddSoulHearts(1)
				local effect = player:GetEffects()
				if not effect:HasCollectibleEffect(108) then
					effect:AddCollectibleEffect(108)
				end
			end
		end	
	end	
end
Waster:AddPriorityCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, 200, 'OnTakeDMG')


return Waster