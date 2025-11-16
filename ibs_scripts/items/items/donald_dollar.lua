--金圆券

local mod = Isaac_BenightedSoul

local game = Game()

local DonaldDollar = mod.IBS_Class.Item(mod.IBS_ItemID.DonaldDollar)

--黑名单
DonaldDollar.CoinBlackList = {
	[3] = true, --镍币
	[5] = true, --幸运币
	[7] = true, --金币
}

--通胀这一块
function DonaldDollar:OnCoinInit(pickup, other)
	if not PlayerManager.AnyoneHasCollectible(self.ID) then return end
	if self.CoinBlackList[pickup.SubType] then return end
	pickup:Morph(5,20,3, true, true, true)
end
DonaldDollar:AddCallback(ModCallbacks.MC_POST_PICKUP_INIT, 'OnCoinInit', PickupVariant.PICKUP_COIN)


--通胀这两块
function DonaldDollar:OnPriceUpdate(variant, subType, shopItemID, price)
	if price > 0 and PlayerManager.AnyoneHasCollectible(self.ID) then	
		return price * 7
	end
end
DonaldDollar:AddCallback(mod.IBS_CallbackID.GET_PICKUP_PRICE, 'OnPriceUpdate', 100)


return DonaldDollar