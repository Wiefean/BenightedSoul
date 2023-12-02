--绑定诅咒

local mod = Isaac_BenightedSoul
local IBS_Curse = mod.IBS_Curse
local IBS_RNG = mod:GetUniqueRNG("Curse_Binding")

local config = Isaac.GetItemConfig()

--阻止拾取新的主动道具
local function Occupation(_,pickup, other)
	if (Game():GetLevel():GetCurses() & IBS_Curse.binding > 0) then
		local player = other:ToPlayer()
		if player and (pickup.SubType > 0) and not player:HasCollectible(260) then
			local itemConfig = config:GetCollectible(pickup.SubType) 
			local active = itemConfig and (itemConfig.Type == ItemType.ITEM_ACTIVE)
		
			if active and (player:GetActiveItem(0) ~= 0) then
				return false
			end
		end	
	end	
end
mod:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, Occupation, 100)

