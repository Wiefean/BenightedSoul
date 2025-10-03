--物品相关回调

local mod = Isaac_BenightedSoul
local IBS_CallbackID = mod.IBS_CallbackID
local Ents = mod.IBS_Lib.Ents
local Pickups = mod.IBS_Lib.Pickups

local game = Game()

local Item = mod.IBS_Class.Callbacks{
	PICK_COLLECTIBLE = IBS_CallbackID.PICK_COLLECTIBLE,
	PICK_TRINKET = IBS_CallbackID.PICK_TRINKET,
	PICK_CARD = IBS_CallbackID.PICK_CARD,
	PRE_GET_COLLECTIBLE = IBS_CallbackID.PRE_GET_COLLECTIBLE
}

--拾取道具回调
local function RunCallback_PickCollectible(player, item, touched, pickup)
	touched = touched or false
	Isaac.RunCallbackWithParam(IBS_CallbackID.PICK_COLLECTIBLE, item, player, item, touched, pickup)
end

--拾取饰品回调
local function RunCallback_PickTrinket(player, trinket, golden, touched)
	touched = touched or false
	Isaac.RunCallbackWithParam(IBS_CallbackID.PICK_TRINKET, trinket, player, trinket, golden, touched)
end

--拾取口袋物品回调(不包括药丸)
local function RunCallback_PickCard(player, card)
	Isaac.RunCallbackWithParam(IBS_CallbackID.PICK_CARD, card, player, card)
end


--获取底座道具的上一个ID
local function GetItemLastID(pickup) 
	local data = Ents:GetTempData(pickup)
	data.ItemCallback_LastItemID = data.ItemCallback_LastItemID or -1
	
	return data.ItemCallback_LastItemID
end
mod:AddCallback(ModCallbacks.MC_POST_PICKUP_UPDATE, function(_,pickup)
	local data = Ents:GetTempData(pickup)
	data.ItemCallback_LastItemID = pickup.SubType
end, PickupVariant.PICKUP_COLLECTIBLE)

--更新被移除的饰品表
local RemovedTrinkets = {}
mod:AddCallback(ModCallbacks.MC_POST_ENTITY_REMOVE, function(_,ent)
    if (ent.Variant == PickupVariant.PICKUP_TRINKET) then
        table.insert(RemovedTrinkets, {ID = ent.SubType, Timeout = 1})
    end
end, EntityType.ENTITY_PICKUP)

--更新被拾取的口袋物品表
local PickedCards = {}
mod:AddPriorityCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, CallbackPriority.LATE, function(_,pickup,collider)
	local player = collider:ToPlayer()
	if player and Pickups:CanCollect(pickup, player) then
		table.insert(PickedCards, {Entity = pickup, ID = pickup.SubType, Timeout = 1})
	end	
end, PickupVariant.PICKUP_TAROTCARD)

--更新饰品和口袋物品表
mod:AddCallback(ModCallbacks.MC_POST_UPDATE, function()
    for k, trinket in pairs(RemovedTrinkets) do
        if (trinket.Timeout > 0) then
            trinket.Timeout = trinket.Timeout - 1
        else
            RemovedTrinkets[k] = nil
        end 
    end
    for k, card in pairs(PickedCards) do
        if (card.Timeout > 0) then
            card.Timeout = card.Timeout - 1
        else
            PickedCards[k] = nil
        end 
    end	
end)

--获取玩家数据缓存
local function GetPlayerData(player)
	local data = Ents:GetTempData(player)
	data.ItemCallback = data.ItemCallback or {
		QueueingItem = nil
	}
	
	return data.ItemCallback
end

--拾取物品回调
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, function(_,player)
    if (game:GetFrameCount() > 1) then --防止游戏加载时触发
        if not player:IsItemQueueEmpty() then --正在举起物品
            local data = GetPlayerData(player)
            if (not data.QueueingItem) then --正在举起的物品无记录
                local queued = player.QueuedItem
                local id = queued.Item.ID
                local type = queued.Item.Type
                local touched = queued.Touched
				
				--更新正在举起的物品记录
                data.QueueingItem = {ID = id, Type = type, Touched = touched}

				--检测举起的物品类型并回调
                if (type == ItemType.ITEM_TRINKET) then
                    for k, trinket in pairs(RemovedTrinkets) do --检测被移除的饰品去向是否是被玩家拾取
                        if (trinket.ID == id or trinket.ID - 32768 == id) then --金饰品兼容
                            RunCallback_PickTrinket(player, id, trinket.ID > 32768, touched)
                            table.remove(RemovedTrinkets, k)
                            break
                        end
                    end
                else
                    for _, ent in pairs(Isaac.FindByType(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE)) do
						local pickup = ent:ToPickup()
						if pickup then
							local matches = (GetItemLastID(pickup) == id) --ID匹配
							local swapped = pickup.FrameCount <= 0 --被交换(主动道具交换和道具轮换)
							local taken = (pickup.SubType == 0 and matches) or not pickup:Exists() --被拾取
							if (swapped or taken) then
								RunCallback_PickCollectible(player, id, touched, pickup)
								break
							end
						end
                    end
                end
            end
        end

		--更新口袋物品
		for k, card in ipairs(PickedCards) do
			if (not card.Entity:Exists()) or (card.Entity:IsDead()) then --确认实体消失
				local id = player:GetCard(0)
				if (id == card.ID) then  --检测第一卡槽,ID匹配时回调
					RunCallback_PickCard(player, id)
					table.remove(PickedCards, k)
					break
				end
			end
		end
		
	end
end)


--更新数据以及获得/失去道具回调
mod:AddCallback(ModCallbacks.MC_POST_RENDER, function()
	if game:GetFrameCount() <= 0 then return end --防止游戏加载时触发
	for i = 0, game:GetNumPlayers() -1 do
		local player = Isaac.GetPlayer(i)
		local data = GetPlayerData(player)
	
		--清空正在举起的物品记录
		if data.QueueingItem and player:IsItemQueueEmpty() then 
			data.QueueingItem = nil
		end
	end	
end)

--道具池获取道具之前回调
mod:AddCallback(ModCallbacks.MC_PRE_GET_COLLECTIBLE, function(_, pool, decrease, seed)
    local resultBefore = 0
	local item = nil
	
    for _,callback in ipairs(Isaac.GetCallbacks(IBS_CallbackID.PRE_GET_COLLECTIBLE)) do
        local result = callback.Function(callback.Mod, pool, decrease, seed, resultBefore)
        if (result) then
            resultBefore = result
			item = result
        end
    end

	if item then return item end	
end)


return Item