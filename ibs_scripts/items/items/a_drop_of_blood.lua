--一滴血

local mod = Isaac_BenightedSoul

local game = Game()

local ADropOfBlood = mod.IBS_Class.Item(mod.IBS_ItemID.ADropOfBlood)
local config = Isaac.GetItemConfig()

--获得时
function ADropOfBlood:OnGainItem(item, charge, first, Slot, varData, player)
	game:GetLevel():AddAngelRoomChance(1)
end
ADropOfBlood:AddCallback(ModCallbacks.MC_POST_ADD_COLLECTIBLE, 'OnGainItem', ADropOfBlood.ID)


--道具首次出现时触发
function ADropOfBlood:OnPickupFirstAppear(pickup)
	if pickup.SubType <= 0 then return end --非错误道具和空底座
	if not PlayerManager.AnyoneHasCollectible(self.ID) then return end
	local itemConfig = config:GetCollectible(pickup.SubType)
		
	--非任务道具
	if itemConfig and itemConfig:HasTags(ItemConfig.TAG_QUEST) then
		return
	end

	local roomType = game:GetRoom():GetType()
	if roomType == RoomType.ROOM_ANGEL then 
		pickup.Wait = pickup.Wait + 2

		self:DelayFunction(function()
			pickup.Price = 1
			pickup.ShopItemId = -1
			pickup.OptionsPickupIndex = 0
		end, 0)
	elseif roomType == RoomType.ROOM_SHOP then
		pickup.Wait = pickup.Wait + 2
		pickup.AutoUpdatePrice = false
		
		if pickup.Price - 30 < 0 then
			pickup.Price = -1000
		else
			pickup.Price = pickup.Price - 30
		end

		self:DelayFunction(function()
			pickup.OptionsPickupIndex = 1
		end, 0)		
	end
end
ADropOfBlood:AddCallback(mod.IBS_CallbackID.PICKUP_FIRST_APPEAR, 'OnPickupFirstAppear', 100)

--新层触发
function ADropOfBlood:OnNewLevel()
	if PlayerManager.AnyoneHasCollectible(self.ID) then
		self:DelayFunction(function()	
			game:GetLevel():AddAngelRoomChance(1)
		end, 0)
	end
end
ADropOfBlood:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, 'OnNewLevel')

return ADropOfBlood