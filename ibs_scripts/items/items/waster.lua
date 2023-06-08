--剩饼

local mod = Isaac_BenightedSoul
local IBS_Item = mod.IBS_Item


--效果
mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, function(_,ent)
	local player = ent:ToPlayer()

	if player then
		if player:HasCollectible(IBS_Item.waster) then
			local effect = player:GetEffects()	
			local rng = player:GetCollectibleRNG(IBS_Item.waster)
			local chance = rng:RandomInt(99) + 1

			if chance >= 75 then
				player:AddSoulHearts(1)
				if not effect:HasCollectibleEffect(108) then
					effect:AddCollectibleEffect(108)
				end	
			end
		end	
	end	
end)