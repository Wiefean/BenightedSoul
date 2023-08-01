--绑定诅咒

local mod = Isaac_BenightedSoul
local IBS_Curse = mod.IBS_Curse
local Ents = mod.IBS_Lib.Ents
local IBS_RNG = mod:GetUniqueRNG("Curse_Binding")

local config = Isaac.GetItemConfig()

--尝试添加诅咒
local function PreCurse(_,curse)
	if IBS_Data.Setting["curse_binding"] and (IBS_RNG:RandomInt(99) <= 9) then
		return IBS_Curse.binding
	end
end
mod:AddPriorityCallback(ModCallbacks.MC_POST_CURSE_EVAL, CallbackPriority.IMPORTANT, PreCurse)

--阻止拾取新的道具/口袋物品
local function Occupation(_,pickup, other)
	if (Game():GetLevel():GetCurses() & IBS_Curse.binding > 0) then
		local player = other:ToPlayer()
		if player and (pickup.SubType > 0) and not player:HasCollectible(260) then
		
			if pickup.Variant == 100 then --道具
				local itemConfig = config:GetCollectible(pickup.SubType) 
				local active = itemConfig and (itemConfig.Type == ItemType.ITEM_ACTIVE)
			
				if active and (player:GetActiveItem(0) ~= 0) then
					return false
				end
			elseif (pickup.Variant == 70) or (pickup.Variant == 300) then --口袋物品
				if (player:GetPill(0) + player:GetPill(1) + player:GetPill(2) + player:GetPill(3) + player:GetCard(0) + player:GetCard(1) + player:GetCard(2) + player:GetCard(3)) ~= 0 then
					return false
				end
			elseif pickup.Variant == 350 then --饰品
				if (player:GetTrinket(0) + player:GetTrinket(1)) ~= 0 then
					return false
				end
			end
			
		end	
	end	
end
mod:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, Occupation)

