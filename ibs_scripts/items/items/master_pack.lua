--大师组合包

local mod = Isaac_BenightedSoul

local game = Game()
local config = Isaac.GetItemConfig()

local MasterPack = mod.IBS_Class.Item(mod.IBS_ItemID.MasterPack)

--获得时生成卡牌
function MasterPack:OnGain(item, charge, first, slot, varData, player)
	if first then
		local room = game:GetRoom()
		local itemPool = game:GetItemPool()
		local rng = player:GetCollectibleRNG(self.ID)
		for i = 1,4 do
			local card = 31
			local cardType = ItemConfig.CARDTYPE_TAROT
			
			--排除塔罗牌,规则卡,自杀之王
			while (card == 44 or card == 46) or (cardType == ItemConfig.CARDTYPE_TAROT or cardType == ItemConfig.CARDTYPE_TAROT_REVERSE) do
				card = itemPool:GetCardEx(rng:Next(), 1, 0, 1, false)
				local itemConfig = config:GetCard(card)
				if itemConfig then
					cardType = itemConfig.CardType
				end
			end
			
			local pos = room:FindFreePickupSpawnPosition(player.Position, 0, true)
			Isaac.Spawn(5, 300, card, pos, Vector.Zero, nil)
		end
	end
end
MasterPack:AddCallback(ModCallbacks.MC_POST_ADD_COLLECTIBLE, 'OnGain', MasterPack.ID)

--替换商店的一个卡牌商品
function MasterPack:OnNewRoom()
	if not PlayerManager.AnyoneHasCollectible(self.ID) then return end
	local room = game:GetRoom()
	if room:IsFirstVisit() and room:GetType() == RoomType.ROOM_SHOP then
		for _,ent in ipairs(Isaac.FindByType(5,300)) do
			local itemConfig = config:GetCard(ent.SubType)
			if itemConfig and ent:ToPickup() and ent:ToPickup().Price ~= 0 then
				local cardType = itemConfig.CardType
				
				--非符文和物件
				if cardType ~= ItemConfig.CARDTYPE_RUNE and cardType ~= ItemConfig.CARDTYPE_SPECIAL_OBJECT then
					local pickup = Isaac.Spawn(5, 100, self.ID, ent.Position, Vector.Zero, nil):ToPickup()
					pickup.ShopItemId = -1
					pickup.Price = 20
					ent:Remove()
					break
				end
			end
		end	
	end
end
MasterPack:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, 'OnNewRoom')

return MasterPack