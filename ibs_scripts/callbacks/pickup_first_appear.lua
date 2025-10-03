--掉落物首次出现

local mod = Isaac_BenightedSoul

local PickupFirstAppear = mod.IBS_Class.Callback(mod.IBS_CallbackID.PICKUP_FIRST_APPEAR)

--利用掉落物初始化回调和Ents函数库实现
function PickupFirstAppear:OnPickupUpdate(pickup)
	if pickup.FrameCount > 1 then return end
	if pickup.Touched then return end --已经被摸过的当然不算首次出现
	local data = self._Ents:GetDataBySeed(pickup.InitSeed)
	if data.PickupFirstAppearCallbackChecked then return end
	
	--回调函数
	self:RunWithParam(pickup.Variant, pickup)

	--记录
	data.PickupFirstAppearCallbackChecked = true
end
PickupFirstAppear:AddCallback(ModCallbacks.MC_POST_PICKUP_UPDATE, 'OnPickupUpdate')

return PickupFirstAppear