--是否可收集掉落物回调(主要用于自定义掉落物)

--调用在
--\ibs_scripts\commons\lib\pickups.lua

local mod = Isaac_BenightedSoul

local CanCollectPickup = mod.IBS_Class.Callback(mod.IBS_CallbackID.CAN_COLLECT_PICKUP)


return CanCollectPickup