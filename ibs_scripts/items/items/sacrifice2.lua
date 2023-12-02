--亚伯的祭品

local mod = Isaac_BenightedSoul
local IBS_Callback = mod.IBS_Callback
local IBS_Item = mod.IBS_Item
local Finds = mod.IBS_Lib.Finds
local Players = mod.IBS_Lib.Players
local Pickups = mod.IBS_Lib.Pickups
local rng = mod:GetUniqueRNG("Item_Sacrifice2")

local LANG = mod.Language

local config = Isaac.GetItemConfig()

--用于昧化该隐&亚伯
mod.IBS_API.BCBA:AddExcludedActiveItem(IBS_Item.sacrifice2)

--使用
local function OnUse(_,item, rng, player, flags)
	if (flags & UseFlag.USE_CARBATTERY <= 0) then
		local data = mod:GetIBSData("Temp")
		
		--记录使用
		if not data.welcomSacrificeUsed then data.welcomSacrificeUsed = true end
		
		local text = "You Feel Blessed!"
		if LANG == "zh" then text = "你被祝福了 !" end
		Game():GetHUD():ShowFortuneText(text)
		
		return {ShowAnim = true, Remove = true}
	end
end
mod:AddCallback(ModCallbacks.MC_USE_ITEM, OnUse, IBS_Item.sacrifice2)

--自动充能判定
local function AutoCharge()
	local unwelcomSacrifice = mod:GetIBSData("Temp").unwelcomSacrificeUsed

	for i = 0, Game():GetNumPlayers() -1 do
		local player = Isaac.GetPlayer(i)
		
		--使用过该隐祭品或美德书或犹大长子权
		if unwelcomSacrifice or player:HasCollectible(584) or player:HasCollectible(59) then
			for slot = 0,2 do
				if player:GetActiveItem(slot) == (IBS_Item.sacrifice2) then
					local charges = Players:GetSlotCharges(player, slot, true, true)
					
					if charges < 1 then
						Players:ChargeSlot(player, slot, 1, true)				
					end
				end	
			end
		end	
	end	
end
mod:AddCallback(ModCallbacks.MC_POST_UPDATE, AutoCharge)

--新房间
local function NewRoom()
	local game = Game()
	local room = game:GetRoom()
	
	if room:IsFirstVisit() then
		local roomType = room:GetType()
		
		--进入恶魔/天使房充能
		if (roomType == RoomType.ROOM_DEVIL) or (roomType == RoomType.ROOM_ANGEL) then
			for i = 0, Game():GetNumPlayers() -1 do
				local player = Isaac.GetPlayer(i)
				for slot = 0,2 do
					if player:GetActiveItem(slot) == (IBS_Item.sacrifice2) then
						local charges = Players:GetSlotCharges(player, slot, true, true)
						if charges < 1 then
							Players:ChargeSlot(player, slot, 1, true, false, true, true)
						end
					end
				end
			end
		end

		--新房间额外道具选择
		--(延迟触发,以实现视觉效果和模组兼容)
		if mod:GetIBSData("Temp").welcomSacrificeUsed then
			mod:DelayFunction(function()
				local ent = Finds:ClosestCollectible(room:GetCenterPos())
				local closestItem = ent and ent:ToPickup()
				local itemConfig =  (closestItem and config:GetCollectible(closestItem.SubType))
				
				if closestItem and (not itemConfig or not itemConfig:HasTags(ItemConfig.TAG_QUEST)) then
					local pos1 = room:FindFreePickupSpawnPosition(closestItem.Position + Vector(80,0), 0, true)
					local pos2 = room:FindFreePickupSpawnPosition(closestItem.Position - Vector(80,0), 0, true)
					local id1 = game:GetItemPool():GetCollectible(ItemPoolType.POOL_ANGEL, true, rng:Next())
					local id2 = game:GetItemPool():GetCollectible(ItemPoolType.POOL_DEVIL, true, rng:Next())
					local item1 = Isaac.Spawn(5, 100, id1, pos1, Vector.Zero, nil):ToPickup()
					local item2 = Isaac.Spawn(5, 100, id2, pos2, Vector.Zero, nil):ToPickup()
					
					local price = closestItem.Price
					if price ~= 0 then
						if (price < 0) and (price ~= -1000) then 
							item1.ShopItemId = -2
							item2.ShopItemId = -2
						elseif (price > 0) then
							item1.ShopItemId = -1
							item2.ShopItemId = -1
						end
						item1.Price = price
						item2.Price = price
					end
					
					local index = closestItem.OptionsPickupIndex
					if index == 0 then
						local newIndex = Pickups:GetUniqueOptionsIndex()
						item1.OptionsPickupIndex = newIndex
						item2.OptionsPickupIndex = newIndex
						closestItem.OptionsPickupIndex = newIndex					
					else
						item1.OptionsPickupIndex = index				
						item2.OptionsPickupIndex = index				
					end
				end
			end, 1)
		end	
	end	
end
mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, NewRoom)
