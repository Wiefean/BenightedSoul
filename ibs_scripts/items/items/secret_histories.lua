--浪游秘史

local mod = Isaac_BenightedSoul
local IBS_ItemID = mod.IBS_ItemID

local game = Game()
local config = Isaac.GetItemConfig()

local SecretHistories = mod.IBS_Class.Item(IBS_ItemID.SecretHistories)

--道具列表
SecretHistories.ItemList = {
	IBS_ItemID.Moth,
	IBS_ItemID.Moth,
	IBS_ItemID.Moth,
	IBS_ItemID.Moth,
	IBS_ItemID.Moth,
	IBS_ItemID.Moth,
	IBS_ItemID.Knock,
	IBS_ItemID.Knock,
	IBS_ItemID.Edge2,
	IBS_ItemID.Edge3,
	IBS_ItemID.Grail,
	IBS_ItemID.Grail,
	IBS_ItemID.Grail,
	IBS_ItemID.Grail,
	IBS_ItemID.Forge,
	IBS_ItemID.Forge,
	IBS_ItemID.Forge,
	IBS_ItemID.Forge,
}

--卡牌列表
SecretHistories.CardList = {
	[IBS_ItemID.Moth] = Card.CARD_FOOL,
	[IBS_ItemID.Knock] = Card.CARD_HIEROPHANT,
	[IBS_ItemID.Edge2] = Card.CARD_CHARIOT,
	[IBS_ItemID.Edge3] = Card.CARD_STRENGTH,
	[IBS_ItemID.Grail] = Card.CARD_DEVIL,
	[IBS_ItemID.Forge] = Card.CARD_JUDGEMENT,
}

--获取道具和对应卡牌
function SecretHistories:GetItemAndCard(seed)
	local list = {}
	
	for _,id in ipairs(self.ItemList) do
		local itemConfig = config:GetCollectible(id)
		if itemConfig and itemConfig:IsAvailable() then
			table.insert(list, id)
		else
			table.insert(list, IBS_ItemID.Moth)
		end
	end
	
	local id = list[RNG(seed):RandomInt(1,#self.ItemList)] or IBS_ItemID.Moth
	local card = self.CardList[id] or Card.CARD_FOOL
	return id,card
end

--获得时生成星星卡
function SecretHistories:OnGain(item, charge, first, slot, varData, player)
	if first then
		local room = game:GetRoom()
		local pos = room:FindFreePickupSpawnPosition(player.Position, 0, true)
		Isaac.Spawn(5, 300, 18, pos, Vector.Zero, nil)
	end
end
SecretHistories:AddCallback(ModCallbacks.MC_POST_ADD_COLLECTIBLE, 'OnGain', SecretHistories.ID)

--更改星星卡的效果
function SecretHistories:PreUseCard(card, player, flag)
	if (flag & UseFlag.USE_MIMIC > 0) or (flag & UseFlag.USE_NOANIM > 0) or (flag & UseFlag.USE_NOHUD > 0) then return end
	if player:HasCollectible(self.ID) and card == 18 then
		local id,c = self:GetItemAndCard(player:GetCardRNG(card):Next())
		local room = game:GetRoom()
		local pos = room:FindFreePickupSpawnPosition(player.Position, 0, true)
		Isaac.Spawn(5, 300, c, pos, Vector.Zero, nil)	

		--道具魂火
		player:AddItemWisp(id, player.Position, true)
		
		player:AnimateCard(18, "UseItem")
		return true
	end
end
SecretHistories:AddCallback(ModCallbacks.MC_PRE_USE_CARD, 'PreUseCard')

--新层生成星星卡
function SecretHistories:OnNewLevel()
	if PlayerManager.AnyoneHasCollectible(self.ID) then
		local room = game:GetRoom()
		local pos = room:FindFreePickupSpawnPosition(room:GetCenterPos() + Vector(0,80), 0, true)
		Isaac.Spawn(5, 300, 18, pos, Vector.Zero, nil)	
	end
end
SecretHistories:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, 'OnNewLevel')


return SecretHistories