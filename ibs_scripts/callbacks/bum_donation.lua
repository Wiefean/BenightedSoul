--捐助乞丐

local mod = Isaac_BenightedSoul

local BumDonation = mod.IBS_Class.Callback(mod.IBS_CallbackID.BUM_DONATION)

--通过检测特定名称的动画播放情况实现(能否兼容模组还得看命名规范)
function BumDonation:OnSlotUpdate(slot)
	local spr = slot:GetSprite()
	if (spr:IsPlaying('PayPrize') or spr:IsPlaying('PayNothing')) and spr:GetFrame() == 1 then	
		self:RunWithParam(slot.Type, slot)
	end
end
BumDonation:AddCallback(ModCallbacks.MC_POST_SLOT_UPDATE, 'OnSlotUpdate')

--检测乞丐跟班拾取掉落物(硬核)
do

--临时数据
function BumDonation:GetFamiliarData(familiar)
	local data = self._Ents:GetTempData(familiar)
	data.BumDonationCallback = BumDonationCallback or {}
	return data.BumDonationCallback
end

--乞丐跟班列表
BumDonation.BumFamiliar = {
	[24] = true,
	[64] = true,
	[88] = true,
	[90] = true,
	[102] = true,
}

--记录乞丐跟班接触的掉落物
function BumDonation:OnPickupCollision(pickup, other)
	if pickup.Price ~= 0 then return end
	local familiar = other:ToFamiliar()
	if familiar and self.BumFamiliar[familiar.Variant] and self._Pickups:CanCollect(pickup, familiar) then	
		table.insert(self:GetFamiliarData(familiar), pickup)
	end
end
BumDonation:AddCallback(ModCallbacks.MC_POST_PICKUP_COLLISION, 'OnPickupCollision')

--检测记录的掉落物是否消失
function BumDonation:OnFamiliarUpdate(familiar)
	if not self.BumFamiliar[familiar.Variant] then return end
	local data = self._Ents:GetTempData(familiar).BumDonationCallback
	if data then
		for k,pickup in ipairs(data) do
			if pickup:IsDead() or not pickup:IsExist() then
				self:RunWithParam(familiar.Type, familiar, pickup)
			end
			table.remove(data, k)
		end
	end
end
BumDonation:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, 'OnFamiliarUpdate')


end

return BumDonation