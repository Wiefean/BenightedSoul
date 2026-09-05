--钥匙先生

local mod = Isaac_BenightedSoul
local IBS_PlayerKey = mod.IBS_PlayerKey

local game = Game()

local MrKey = mod.IBS_Class.Item(mod.IBS_ItemID.MrKey)

--大箱子只用一把钥匙开(多钥匙开的大箱子本质是不同掉落物)
function MrKey:OnMegaChestInit(pickup)
	if pickup.SubType > 1 and PlayerManager.AnyoneHasCollectible(self.ID) then
		pickup:Morph(5, 57, 1, true, true)
		return true
	end
end
MrKey:AddCallback(ModCallbacks.MC_POST_PICKUP_INIT, 'OnMegaChestInit', 57)

--拾取时检测房间内的大箱子
function MrKey:OnGainItem(item, charge, first, slot, varData, player)
	for _,ent in ipairs(Isaac.FindByType(5, 57)) do
		local pickup = ent:ToPickup()
		if pickup and pickup.SubType > 1 then
			pickup:Morph(5, 57, 1, true, true)
		end
	end
end
MrKey:AddCallback(ModCallbacks.MC_POST_ADD_COLLECTIBLE, 'OnGainItem', MrKey.ID)

--钥匙乞丐返还
function MrKey:OnBumDonation(ent, pickup)
	if not PlayerManager.AnyoneHasCollectible(self.ID) then return end
	local variant = ent.Variant
	local p = Isaac.GetPlayer(0)
	
	if p:GetCollectibleRNG(self.ID):RandomInt(100) < 50 then
		--可互动实体
		if ent:ToSlot() then
			--钥匙乞丐
			if variant == 7 then
				p:AddKeys(1)
			end
		elseif ent:ToFamiliar() and pickup and pickup.Variant == 30 then --跟班拾取钥匙
			--钥匙乞丐或超级乞丐
			if variant == 90 or variant == 102 then
				p:AddKeys(1)
			end
		end
	end
end
MrKey:AddCallback(mod.IBS_CallbackID.BUM_DONATION, 'OnBumDonation')

return MrKey