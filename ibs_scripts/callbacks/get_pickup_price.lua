--获取掉落物价格回调

local mod = Isaac_BenightedSoul
local IBS_CallbackID = mod.IBS_CallbackID

local GetPickupPrice = mod.IBS_Class.Callback(mod.IBS_CallbackID.GET_PICKUP_PRICE)

function GetPickupPrice:GetPickupPriceCallback(variant, subType, shopItemID, price)
	local newPrice = price

	for _,callback in ipairs(self:Get()) do
		if (not callback.Param) or (callback.Param == variant) then	
			local result = callback.Function(callback.Mod, variant, subType, shopItemID, newPrice)
			if type(result) == "number" then 
				newPrice = result
			end
		end
	end
	
	if newPrice ~= price then
		return newPrice
	end
end
GetPickupPrice:AddPriorityCallback(ModCallbacks.MC_GET_SHOP_ITEM_PRICE, CallbackPriority.EARLY, 'GetPickupPriceCallback')


return GetPickupPrice