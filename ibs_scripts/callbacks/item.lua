--物品相关回调

local mod = Isaac_BenightedSoul
local IBS_Callback = mod.IBS_Callback
local Ents = mod.IBS_Lib.Ents

local config = Isaac.GetItemConfig()


--拾取道具回调
local function RunCallback_PickCollectible(player, item, touched)
	touched = touched or false
	Isaac.RunCallbackWithParam(IBS_Callback.PICK_COLLECTIBLE, item, player, item, touched)
end

--获得道具回调
local function RunCallback_GainCollectible(player, item, count, touched, holding)
	count = count or 1
	touched = touched or false
	holding = holding or false
	Isaac.RunCallbackWithParam(IBS_Callback.GAIN_COLLECTIBLE, item, player, item, count, touched, holding)
end

--失去道具回调
local function RunCallback_LoseCollectible(player, item, count)
	count = count or 1
	Isaac.RunCallbackWithParam(IBS_Callback.LOSE_COLLECTIBLE, item, player, item, count)
end

--拾取饰品回调
local function RunCallback_PickTrinket(player, trinket, golden, touched)
	touched = touched or false
	Isaac.RunCallbackWithParam(IBS_Callback.PICK_TRINKET, trinket, player, trinket, golden, touched)
end

--拾取口袋物品回调(不包括药丸)
local function RunCallback_PickCard(player, card)
	Isaac.RunCallbackWithParam(IBS_Callback.PICK_CARD, card, player, card)
end


--获取底座道具的上一个ID
local function GetPickupLastID(pickup) 
	local data = Ents:GetTempData(pickup)
	data.LastID = data.LastID or -1
	
	return data.LastID
end
mod:AddCallback(ModCallbacks.MC_POST_PICKUP_UPDATE, function(_,pickup)
	local data = Ents:GetTempData(pickup)
	data.LastID = pickup.SubType
end, PickupVariant.PICKUP_COLLECTIBLE)

--更新被移除的饰品表
local RemovedTrinkets = {}
mod:AddCallback(ModCallbacks.MC_POST_ENTITY_REMOVE, function(_,ent)
    if (ent.Variant == PickupVariant.PICKUP_TRINKET) then
        table.insert(RemovedTrinkets, {ID = ent.SubType, TimeOut = 1})
    end
end, EntityType.ENTITY_PICKUP)

--更新可能被拾取的口袋物品表
--(价格判定有些缺陷)
local PickedCards = {}
mod:AddPriorityCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, CallbackPriority.LATE, function(_,pickup,collider)
	local player = collider:ToPlayer()
	if player then
		if not (player.Parent ~= nil and player:GetPlayerType() == PlayerType.PLAYER_KEEPER) then --非稻草人
			if (player.Variant == 0 and not player:IsCoopGhost()) then --非宝宝玩家或鬼魂玩家
				if (player:CanPickupItem() and player:IsExtraAnimationFinished() and player.ItemHoldCooldown <= 0) then --玩家处于可拾取物品状态
					if (pickup.Wait <= 0 and (pickup.Price <= 0 or player:GetNumCoins() >= pickup.Price)) then--物品可被拾取
						table.insert(PickedCards, {Entity = pickup, ID = pickup.SubType, TimeOut = 1})
					end
				end
			end	
		end	
	end	
end, PickupVariant.PICKUP_TAROTCARD)

--更新饰品和口袋物品表
mod:AddCallback(ModCallbacks.MC_POST_UPDATE, function()
    for k, trinket in pairs(RemovedTrinkets) do
        if (trinket.TimeOut > 0) then
            trinket.TimeOut = trinket.TimeOut - 1
        else
            RemovedTrinkets[k] = nil
        end 
    end
    for k, card in pairs(PickedCards) do
        if (card.TimeOut > 0) then
            card.TimeOut = card.TimeOut - 1
        else
            PickedCards[k] = nil
        end 
    end	
end)

--获取玩家数据缓存
local function GetPlayerItemsData(player)
	local data = Ents:GetTempData(player)
	data.Items = data.Items or {
		List = {},
		Count = 0,
		QueueingItem = nil
	}
	
	return data.Items
end


--继续游戏时抢先缓存数据
mod:AddPriorityCallback(ModCallbacks.MC_POST_GAME_STARTED, CallbackPriority.IMPORTANT, function(_,isContinue)
    if isContinue then
		for i = 0, Game():GetNumPlayers() -1 do
			local player = Isaac.GetPlayer(i)
            local data = GetPlayerItemsData(player)	
            data.Count = player:GetCollectibleCount()
            for item = 1, config:GetCollectibles().Size do
                local itemConfig = config:GetCollectible(item)
                if (itemConfig) then
                    local key = tostring(item)
                    local num = data.List[key] or 0
                    local curNum = player:GetCollectibleNum(item, true)

                    if (num ~= curNum) then
                        data.List[key] = num
                    end
                end
            end
        end
    end
end)


--更新数据以及拾取道具/饰品/口袋物品回调(每秒检测60次)
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, function(_,player)
    if (Game():GetFrameCount() > 1) then --稍微等待
        if (not player:IsItemQueueEmpty()) then --正在举起物品
            local data = GetPlayerItemsData(player)
            if (not data.QueueingItem) then --正在举起的物品无记录
                local queued = player.QueuedItem
                local id = queued.Item.ID
                local type = queued.Item.Type
                local touched = queued.Touched
				
				--更新正在举起的物品记录
                data.QueueingItem = {Item = id, Type = type, Touched = touched}

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
                    for _, pickup in pairs(Isaac.FindByType(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE)) do
                        local matches = (GetPickupLastID(pickup) == id) --ID匹配
                        local swapped = pickup.FrameCount <= 0 --被交换(主动道具和里以撒兼容)
                        local taken = (pickup.SubType <= 0 and matches) or not pickup:Exists() --被拾取
                        if (swapped or taken) then
                            RunCallback_PickCollectible(player, id, touched)
                            break
                        end
                    end
                end
            end
        end
		
		
		--更新口袋物品
		for k, card in pairs(PickedCards) do
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
local function Update(player)
	local data = GetPlayerItemsData(player)

	--更新总数
	data.Count = player:GetCollectibleCount()

	--更新单个道具数量
	for item = 1, config:GetCollectibles().Size do
		local itemConfig = config:GetCollectible(item)
		if (itemConfig) then
			local key = tostring(item) --将数字转为字符串作为索引
			local num = data.List[key] or 0
			local curNum = player:GetCollectibleNum(item, true)

			local diff = curNum - num
			if (diff ~= 0) then
				if (diff > 0) then 	--增加
					local gained = diff
					
					--检查正在拿起的物品
					local queuedItem = data.QueueingItem	
					if (queuedItem) then
						if (item == queuedItem.Item and queuedItem.Type ~= ItemType.ITEM_TRINKET) then
							RunCallback_GainCollectible(player, item, 1, queuedItem.Touched, true)
							gained = gained - 1
							data.QueueingItem = nil --清空记录
						end
					end

					if (gained > 0) then
						RunCallback_GainCollectible(player, item, gained, false, false)
					end
				else --减少
					RunCallback_LoseCollectible(player, item, -diff)
				end
				data.List[key] = curNum
			end
		end
	end
end

--是否需要更新
local function NeedUpdate(player)
	local data = GetPlayerItemsData(player)

	--正在拾取的物品有记录且玩家没有正在拾取物品时返回true
	if (data.QueueingItem and player:IsItemQueueEmpty()) then 
		return true
	end

	--道具总数与数据不相等时返回true
	if (data.Count ~= player:GetCollectibleCount()) then
		return true
	end
	
	--单个道具的数量与数据不相等时返回true
	local totalCount = 0
	for key, num in pairs(data.List) do
		local id = tonumber(key)
		local curNum = player:GetCollectibleNum(id, true)
		totalCount = totalCount + num
		if (num ~= curNum) then
			return true
		end
	end	
	
	return false
end

--更新数据以及获得/失去道具回调
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_RENDER, function(_,player)
    if (Game():GetFrameCount() > 0) then --稍微等待
        local data = GetPlayerItemsData(player)

		--在需要时更新
        if NeedUpdate(player) then
            Update(player)
        end
        
        --清空正在举起的物品记录
        if (data.QueueingItem and player:IsItemQueueEmpty()) then 
            data.QueueingItem = nil
        end			
    end
end)
