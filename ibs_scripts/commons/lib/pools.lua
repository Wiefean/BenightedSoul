--池相关函数

local mod = Isaac_BenightedSoul
local IBS_TrinketID = mod.IBS_TrinketID
local IBS_PocketID = mod.IBS_PocketID

local game = Game()
local config = Isaac.GetItemConfig()

local Pools = {}

--获取对应的贪婪模式池，没有则返回原池
function Pools:ToGreed(pool, noCheckGreedMode)
	if (not noCheckGreedMode) and not game:IsGreedMode() then return pool end

	if pool == ItemPoolType.POOL_TREASURE then
		return ItemPoolType.POOL_GREED_TREASURE
	elseif pool == ItemPoolType.POOL_SHOP then
		return ItemPoolType.POOL_GREED_SHOP
	elseif pool == ItemPoolType.POOL_DEVIL then
		return ItemPoolType.POOL_GREED_DEVIL
	elseif pool == ItemPoolType.POOL_ANGEL then
		return ItemPoolType.POOL_GREED_ANGEL
	elseif pool == ItemPoolType.POOL_SECRET then
		return ItemPoolType.POOL_GREED_SECRET
	elseif pool == ItemPoolType.POOL_SECRET then
		return ItemPoolType.POOL_GREED_SECRET
	elseif pool == ItemPoolType.POOL_CURSE then
		return ItemPoolType.POOL_GREED_CURSE
	end
	
	return pool
end

--获取当前房间道具池
--[[
输入:种子

输出:道具池ID
]]
function Pools:GetRoomPool(seed)
	if not seed then seed = game:GetSeeds():GetStartSeed() end
    local itemPool = game:GetItemPool()

	--混沌
	if PlayerManager.AnyoneHasCollectible(402) then
		return itemPool:GetRandomPool(RNG(seed))
	end

    local level = game:GetLevel()
    local room = game:GetRoom()
    local roomType = room:GetType()
    local pool = itemPool:GetPoolForRoom(roomType, seed)

    if (pool < 0) then
        pool = ItemPoolType.POOL_TREASURE
    end

	--boos挑战房
    if (roomType == RoomType.ROOM_CHALLENGE and game:GetLevel():HasBossChallenge()) then
        pool = ItemPoolType.POOL_BOSS
    end

	--boss房考虑堕落恶魔和撒旦圣经
    if (roomType == RoomType.ROOM_BOSS) then
        if (room:GetBossID() == 23) or level:GetStateFlag(LevelStateFlag.STATE_SATANIC_BIBLE_USED) then
            pool = ItemPoolType.POOL_DEVIL
        end
    end

    return self:ToGreed(pool)
end


--以特定条件获取道具ID(返回表)
--(不建议频繁触发该函数)
--[[条件示例:
local function condition(itemConfig)
	if itemConfig.Quality == 4 then  --需要是四级道具
		return true
	end
	return false
end
]]
function Pools:GetCollectibles(condition)
    local results = {}

    for id = 1, config:GetCollectibles().Size do
        if (condition ~= nil) then	--没有输入条件时不处理
			local itemConfig = config:GetCollectible(id)
			if (itemConfig and condition(itemConfig)) then
				table.insert(results, id)
			end
		else
			table.insert(results, id)
		end	
    end
	
    return results
end

--道具是否在特定道具池中
function Pools:IsCollectibleInPool(id, pool)
	local itemPool = game:GetItemPool()

	for _,v in pairs(itemPool:GetCollectiblesFromPool(pool)) do
		if id == v.itemID then
			return true
		end
	end
	
	return false
end

--获取全池剩余道具
function Pools:GetLeftCollectibles(condition)
	local itemPool = game:GetItemPool()
	local result = {}

	for _,id in ipairs(self:GetCollectibles(condition)) do
		local itemConfig = config:GetCollectible(id)
		if itemConfig and itemConfig:IsAvailable() and itemPool:HasCollectible(id) then	
			table.insert(result, id)
		end
	end
	
	return result
end

--获取经过回调调整后的道具id,用于模组兼容
function Pools:GetCollectibleThroughCallbacks(id, pool, decrease, seed)
	for _,callback in ipairs(Isaac.GetCallbacks(ModCallbacks.MC_PRE_GET_COLLECTIBLE)) do
		local result = callback.Function(callback.Mod, pool, decrease, seed)
		if type(result) == 'number' then
			id = result
		end
	end
	for _,callback in ipairs(Isaac.GetCallbacks(ModCallbacks.MC_POST_GET_COLLECTIBLE)) do
		local result = callback.Function(callback.Mod, id, pool, decrease, seed)
		if type(result) == 'number' then
			id = result
		end
	end

	return id
end

--以特定品质从道具池抽取道具
--[[
输入:种子, 品质, 道具池, 是否从道具池中移除, 默认道具, 是否忽略回调的修改, 包括品质更高的道具, 包括品质更低的道具

输出:道具ID
(没有抽取到道具时会以早餐代替)
]]
function Pools:GetCollectibleWithQuality(seed, quality, pool, shouldRemove, defaultItem, ignoreModifier, alsoAbove, alsoBelow)
	if not pool then pool = ItemPoolType.POOL_TREASURE end
	if not defaultItem then defaultItem = 25 end --早餐
	local itemPool = game:GetItemPool()

	--混沌
	if not ignoreModifier and PlayerManager.AnyoneHasCollectible(402) then
		pool = itemPool:GetRandomPool(RNG(seed))
	end
	
	pool = self:ToGreed(pool)

	local result = {}
	
	for _,v in ipairs(itemPool:GetCollectiblesFromPool(pool)) do
		local id = v.itemID
		if itemPool:HasCollectible(id) then
			local itemConfig = config:GetCollectible(id)
			if itemConfig and itemConfig:IsAvailable() then
				local Q = itemConfig.Quality
				if Q == quality or (alsoAbove and  Q > quality) or (alsoBelow and Q < quality) then
					table.insert(result, id)
				end
			end	
		end
	end
	
	--抽取一个
	if #result > 0 then
		local id = result[RNG(seed):RandomInt(1, #result)] or result[1]
		
		--调用原版回调
		if not ignoreModifier then
			id = self:GetCollectibleThroughCallbacks(id, pool, shouldRemove, seed)
		end
		
		--移出道具池
		if shouldRemove then
			itemPool:RemoveCollectible(id)
		end

		return id
	end
	
	--默认道具
	if not ignoreModifier then
		defaultItem = self:GetCollectibleThroughCallbacks(defaultItem, pool, shouldRemove, seed)
	end

    return defaultItem
end
--旧版
-- function Pools:GetCollectibleWithQuality(quality, pool, shouldRemove, rng, defaultItem, alsoAbove, alsoBelow)
	-- if not pool then pool = ItemPoolType.POOL_TREASURE end
	-- if not rng then rng = RNG() rng:SetSeed(game:GetSeeds():GetStartSeed(), 35) end
	-- if not defaultItem then defaultItem = 25 end --早餐

	-- local itemPool = game:GetItemPool()
    -- local item = 1
    -- local Q = 114514
	-- local times = 0
	-- local MAX = 2*(Isaac.GetItemConfig():GetCollectibles().Size) or 2023
	
	-- while (Q ~= quality) do  
		-- item = itemPool:GetCollectible(pool, false, rng:Next(), 25)
		-- Q = (config:GetCollectible(item) and config:GetCollectible(item).Quality) or 114514
		-- times = times + 1
		
		-- --可选择包括品质更高或低的道具
		-- if alsoAbove and (Q > quality) then break end
		-- if alsoBelow and (Q < quality) then break end
		
		-- --超过尝试次数直接退出循环(偷懒的屑码师)
		-- if times > MAX then 
			-- item = defaultItem
			-- break
		-- end
	-- end
	
	-- --移出道具池
	-- if shouldRemove then
		-- itemPool:RemoveCollectible(item)
    -- end
	
    -- return item
-- end


--以特定条件从道具池抽取道具
--[[
输入:种子, 条件, 道具池, 是否从道具池中移除, 默认道具, 是否忽略回调的修改, 包括品质更高的道具, 包括品质更低的道具

输出:道具ID
]]
--[[条件示例:
local function condition(itemConfig)
	if itemConfig.Quality == 4 then  --需要是四级道具
		return true
	end
	return false
end
]]
function Pools:GetCollectibleWithCondition(seed, condition, pool, shouldRemove, defaultItem, ignoreModifier)
	if not pool then pool = ItemPoolType.POOL_TREASURE end
	if not defaultItem then defaultItem = 25 end --早餐
	local itemPool = game:GetItemPool()

	--混沌
	if not ignoreModifier and PlayerManager.AnyoneHasCollectible(402) then
		pool = itemPool:GetRandomPool(RNG(seed))
	end
	
	pool = self:ToGreed(pool)

	local result = {}
	
	for _,v in ipairs(itemPool:GetCollectiblesFromPool(pool)) do
		local id = v.itemID
		if itemPool:HasCollectible(id) then
			local itemConfig = config:GetCollectible(id)
			if itemConfig and itemConfig:IsAvailable() and condition(itemConfig) then
				table.insert(result, id)
			end	
		end
	end
	
	--抽取一个
	if #result > 0 then
		local id = result[RNG(seed):RandomInt(1, #result)] or result[1]
		
		--调用原版回调
		if not ignoreModifier then
			id = self:GetCollectibleThroughCallbacks(id, pool, shouldRemove, seed)
		end
		
		--移出道具池
		if shouldRemove then
			itemPool:RemoveCollectible(id)
		end

		return id
	end
	
	--默认道具
	if not ignoreModifier then
		defaultItem = self:GetCollectibleThroughCallbacks(defaultItem, pool, shouldRemove, seed)
	end

    return defaultItem
end


--疾病道具列表
Pools.DiseaseItemList = {
	CollectibleType.COLLECTIBLE_COMMON_COLD, --普通感冒
	CollectibleType.COLLECTIBLE_ANEMIC, --贫血
	CollectibleType.COLLECTIBLE_PROPTOSIS, --眼球突出
	CollectibleType.COLLECTIBLE_DIPLOPIA, --复视
	CollectibleType.COLLECTIBLE_TOXIC_SHOCK, --毒性休克
	CollectibleType.COLLECTIBLE_EPIPHORA, --溢泪症
	CollectibleType.COLLECTIBLE_PUPULA_DUPLEX, --双瞳
	CollectibleType.COLLECTIBLE_KIDNEY_STONE, --肾结石
	CollectibleType.COLLECTIBLE_DEAD_TOOTH, --死牙
	CollectibleType.COLLECTIBLE_VARICOSE_VEINS, --静脉曲张
	CollectibleType.COLLECTIBLE_COMPOUND_FRACTURE, --复杂性骨折
	CollectibleType.COLLECTIBLE_POLYDACTYLY, --多指畸形
	CollectibleType.COLLECTIBLE_SINUS_INFECTION, --鼻窦炎
	CollectibleType.COLLECTIBLE_GLAUCOMA, --青光眼
	CollectibleType.COLLECTIBLE_CONTAGION, --传染病
	CollectibleType.COLLECTIBLE_DEPRESSION, --抑郁症
	CollectibleType.COLLECTIBLE_LARGE_ZIT, --大青春痘
	CollectibleType.COLLECTIBLE_DELIRIOUS, --精神错乱
	CollectibleType.COLLECTIBLE_LEPROSY, --麻风病
	CollectibleType.COLLECTIBLE_HAEMOLACRIA, --泪血症
	CollectibleType.COLLECTIBLE_BRITTLE_BONES, --脆骨症
	CollectibleType.COLLECTIBLE_MUCORMYCOSIS, --毛霉菌病
	CollectibleType.COLLECTIBLE_TINYTOMA, --小畸胎瘤
	CollectibleType.COLLECTIBLE_VASCULITIS, --血管炎
	CollectibleType.COLLECTIBLE_EYE_SORE, --眼瘤
	CollectibleType.COLLECTIBLE_MONTEZUMAS_REVENGE, --水土不服症
	CollectibleType.COLLECTIBLE_BONE_SPURS, --骨刺
	CollectibleType.COLLECTIBLE_HYPERCOAGULATION, --高凝血
	CollectibleType.COLLECTIBLE_IBS, --大肠激躁症
	CollectibleType.COLLECTIBLE_HEMOPTYSIS, --咯血症
	CollectibleType.COLLECTIBLE_STYE, --麦粒肿
}

--是否为疾病道具
function Pools:IsDiseaseItem(id)
	for _,v in ipairs(self.DiseaseItemList) do
		if v == id then
			return true
		end
	end
	return false
end

--乞丐道具池
Pools.BeggarPool = {
	ItemPoolType.POOL_BEGGAR,
	ItemPoolType.POOL_DEMON_BEGGAR,
	ItemPoolType.POOL_KEY_MASTER,
	ItemPoolType.POOL_BOMB_BUM,
	ItemPoolType.POOL_BATTERY_BUM,
	ItemPoolType.POOL_ROTTEN_BEGGAR,
}

--是否为乞丐道具池
function Pools:IsBeggarPool(id)
	for _,v in ipairs(self.BeggarPool) do
		if v == id then
			return true
		end
	end
	return false
end

--乞丐列表
Pools.BeggarList = {4, 5, 7, 9, 13, 18}

--获取随机乞丐
function Pools:GetRandomBeggar(rng, configTbl)
	if not rng then rng = RNG() rng:SetSeed(game:GetSeeds():GetStartSeed(), 35) end
	
	--调整权重
	if configTbl then
		local cache = {}
		local did = {}

		for id,times in pairs(configTbl) do
			if times > 0 then			
				for i = 1,times do
					table.insert(cache, id)
				end
			end
			did[id] = true
		end
		
		--没有特别设置倍数则自动补上
		for _,id in ipairs(self.BeggarList) do
			if not did[id] then
				table.insert(cache, id)
			end
		end

		return cache[rng:RandomInt(#cache) + 1] or 4
	end
	
	return self.BeggarList[rng:RandomInt(#self.BeggarList) + 1] or 4
end

--是否为乞丐
function Pools:IsBeggar(id)
	for _,v in ipairs(self.BeggarList) do
		if v == id then
			return true
		end
	end
	return false
end

--乞丐对应的乞丐道具池
Pools.BeggarToBeggarPool = {
	[4] = ItemPoolType.POOL_BEGGAR,
	[5] = ItemPoolType.POOL_DEMON_BEGGAR,
	[7] = ItemPoolType.POOL_KEY_MASTER,
	[9] = ItemPoolType.POOL_BOMB_BUM,
	[13] = ItemPoolType.POOL_BATTERY_BUM,
	[18] = ItemPoolType.POOL_ROTTEN_BEGGAR,
}

--硬币饰品列表
Pools.PennyTrinketList = {
	TrinketType.TRINKET_SWALLOWED_PENNY, --口水币
	TrinketType.TRINKET_BUTT_PENNY, --屁币
	TrinketType.TRINKET_ROTTEN_PENNY, --腐币
	TrinketType.TRINKET_BLOODY_PENNY, --血币
	TrinketType.TRINKET_BURNT_PENNY, --焦币
	TrinketType.TRINKET_FLAT_PENNY, --扁币
	TrinketType.TRINKET_COUNTERFEIT_PENNY, --假币
	TrinketType.TRINKET_BLESSED_PENNY, --圣币
	TrinketType.TRINKET_CHARGED_PENNY, --电币
	TrinketType.TRINKET_CURSED_PENNY, --诅咒币
	
	--愚昧
	IBS_TrinketID.GlitchedPenny, --错误硬币
	IBS_TrinketID.StarryPenny, --星空硬币
	IBS_TrinketID.PaperPenny, --纸质硬币
	IBS_TrinketID.OldPenny, --古老硬币
}

--获取随机硬币饰品
function Pools:GetRandomPennyTrinket(rng, configTbl)
	if not rng then rng = RNG() rng:SetSeed(game:GetSeeds():GetStartSeed(), 35) end
	
	--调整权重
	if configTbl then
		local cache = {}
		local did = {}

		for id,times in pairs(configTbl) do
			if times > 0 then	
				for i = 1,times do
					table.insert(cache, id)
				end
			end
			did[id] = true
		end
		
		--没有特别设置倍数则自动补上
		for _,id in ipairs(self.PennyTrinketList) do
			if not did[id] then
				table.insert(cache, id)
			end
		end

		return cache[rng:RandomInt(#cache) + 1] or 1
	end	
	
	return self.PennyTrinketList[rng:RandomInt(#self.PennyTrinketList) + 1] or 1
end

--是否为硬币饰品
function Pools:IsPennyTrinket(id, ignoreGolden)
	for _,v in ipairs(self.PennyTrinketList) do
		if v == id or (not ignoreGolden and v == id -32768) then
			return true
		end
	end
	return false
end

--获取随机伪忆
local FalsehoodList = {}
for FH = IBS_PocketID.BIsaac, IBS_PocketID.BJBE do
	table.insert(FalsehoodList, FH)
end
function Pools:GetRandomFalsehood(rng)
	if not rng then rng = RNG() rng:SetSeed(game:GetSeeds():GetStartSeed(), 35) end
	return FalsehoodList[rng:RandomInt(#FalsehoodList) + 1] or IBS_PocketID.BIsaac
end


return Pools