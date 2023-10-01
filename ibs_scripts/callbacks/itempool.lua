--池相关回调

local mod = Isaac_BenightedSoul
local IBS_Callback = mod.IBS_Callback

mod:AddCallback(ModCallbacks.MC_PRE_GET_COLLECTIBLE, function(Mod, pool, decrease, seed)
    local resultBefore = false
	local item = nil
	
    for _, callback in pairs(Isaac.GetCallbacks(IBS_Callback.PRE_GET_COLLECTIBLE)) do
        local result = callback.Function(Mod, pool, decrease, seed, resultBefore)
        if (result) then
            resultBefore = true
			item = result
        end
    end
	
	if item then return item end	
end)

