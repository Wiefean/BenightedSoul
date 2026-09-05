--折扣钥匙

local mod = Isaac_BenightedSoul

local game = Game()

local DiscountKey = mod.IBS_Class.Item(mod.IBS_ItemID.DiscountKey)

--替换店长
function DiscountKey:TryReplaceKeeper()
	for _,ent in ipairs(Isaac.FindByType(17)) do
		Isaac.Spawn(6, 7, 0, ent.Position, Vector.Zero, nil)
		Isaac.Spawn(1000, 15, 0, ent.Position, Vector.Zero, nil)
		ent:Remove()
		return true
	end
	return false
end

--替换商店的店长
function DiscountKey:OnNewRoom(delta)
	local room = game:GetRoom()
	if room:GetType() == RoomType.ROOM_SHOP and room:IsFirstVisit() and PlayerManager.AnyoneHasCollectible(self.ID) then
		self:TryReplaceKeeper()
	end
end
DiscountKey:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, 'OnNewRoom')

--获得时,如果在商店,立刻触发一次效果
function DiscountKey:OnGainItem(item, charge, first, slot, varData, player)
	local room = game:GetRoom()
	if first and (room:GetType() == RoomType.ROOM_SHOP) then
		self:TryReplaceKeeper()
	end
end
DiscountKey:AddCallback(ModCallbacks.MC_POST_ADD_COLLECTIBLE, 'OnGainItem', DiscountKey.ID)

--减少物品价格
function DiscountKey:DoDiscount(pickup)
	if pickup and pickup.Price > 0 then
		pickup.AutoUpdatePrice = false
		
		pickup.Price = math.floor(math.max(0, pickup.Price - math.max(1, 0.2 * pickup.Price)))
		if pickup.Price <= 0 then pickup.Price = -1000 end --零元购
	end
end

--失去钥匙时触发
function DiscountKey:OnKeyNumChange(delta)
	if delta < 0 and PlayerManager.AnyoneHasCollectible(self.ID) then
		for _,ent in ipairs(Isaac.FindByType(5)) do
			local pickup = ent:ToPickup()
			if pickup and pickup.Price > 0 then
				self:DoDiscount(pickup)
			end
		end
	end
end
DiscountKey:AddCallback(mod.IBS_CallbackID.NUM_CHANGE_KEY,'OnKeyNumChange')


return DiscountKey
