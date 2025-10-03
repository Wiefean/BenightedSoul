--检查坚贞之心回调

local mod = Isaac_BenightedSoul
local IBS_CallbackID = mod.IBS_CallbackID
local IronHeart = mod.IBS_Class.IronHeart()

local CheckIronHeart = mod.IBS_Class.Callback(mod.IBS_CallbackID.CHECK_IRON_HEART)

--检查铁心
function CheckIronHeart:CheckIronHeartCallback(player)
	for _,callback in ipairs(self:Get()) do
		local result = callback.Function(callback.Mod, player)
		if type(result) == "boolean" and result == true then 
			if not IronHeart:Check(player) then
				IronHeart:Apply(player, 7)
			end
			return
		end
	end
	IronHeart:Cancel(player)
end
CheckIronHeart:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, 'CheckIronHeartCallback')

return CheckIronHeart