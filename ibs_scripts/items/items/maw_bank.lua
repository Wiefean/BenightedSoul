--巨口储蓄罐

local mod = Isaac_BenightedSoul
local AbandonedItem = mod.IBS_Effect.AbandonedItem

local game = Game()
local sfx = SFXManager()
local config = Isaac.GetItemConfig()

local MawBank = mod.IBS_Class.Trinket(mod.IBS_ItemID.MawBank)

--清房给钱
function MawBank:OnRoomCleaned()
	if PlayerManager.AnyoneHasCollectible(self.ID) then
		local room = game:GetRoom()
		local pos = room:FindFreePickupSpawnPosition(room:GetCenterPos(), 0, true)
		for i = 1,2 do
			Isaac.Spawn(5,20,0, pos, 0.5*RandomVector(), nil)
		end
		sfx:Play(SoundEffect.SOUND_CASH_REGISTER)	
	end
end
MawBank:AddCallback(ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD, 'OnRoomCleaned')
MawBank:AddCallback(mod.IBS_CallbackID.GREED_NEW_WAVE, 'OnRoomCleaned')

--购物检测
function MawBank:OnPurchasePickup(pickup, player, price)
	if price > 0 and player:HasCollectible(self.ID, true) then
		player:RemoveCollectible(self.ID, true)
		
		--特效
		local itemConfig = config:GetCollectible(self.ID)
		if itemConfig.GfxFileName then
			AbandonedItem:Spawn(player.Position, itemConfig.GfxFileName, RandomVector() * 0.1 * math.random(10, 15))
		end
		sfx:Play(267)
	end
end
MawBank:AddCallback(ModCallbacks.MC_POST_PICKUP_SHOP_PURCHASE, 'OnPurchasePickup')


return MawBank