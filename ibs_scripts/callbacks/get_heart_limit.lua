--获取掉落物价格回调

local mod = Isaac_BenightedSoul
local IBS_CallbackID = mod.IBS_CallbackID

local GetHeartLimit = mod.IBS_Class.Callback(mod.IBS_CallbackID.GET_HEART_LIMIT)

function GetHeartLimit:GetHeartLimitCallback(player, limit, isKeeper)
	local newLimit = limit
	local playerType = player:GetPlayerType()

	for _,callback in ipairs(self:Get()) do
		if (not callback.Param) or (callback.Param == playerType) then	
			local result = callback.Function(callback.Mod, player, newLimit, isKeeper)
			if type(result) == "number" then 
				newLimit = result
			end
		end
	end
	
	if newLimit < 2 then newLimit = 2 end
	
	if newLimit ~= limit then
		return newLimit
	end
end
GetHeartLimit:AddPriorityCallback(ModCallbacks.MC_PLAYER_GET_HEART_LIMIT, CallbackPriority.EARLY, 'GetHeartLimitCallback')


return GetHeartLimit