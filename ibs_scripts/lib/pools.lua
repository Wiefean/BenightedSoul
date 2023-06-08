--池相关函数

local mod = Isaac_BenightedSoul

local config = Isaac.GetItemConfig()

local Pools = {}


--获取当前房间道具池
--[[
输入:种子

输出:道具池ID
]]
function Pools:GetRoomPool(seed)
	if not seed then seed = Game():GetSeeds():GetStartSeed() end

    local itemPool = Game():GetItemPool()
    local level = Game():GetLevel()
    local room = Game():GetRoom()
    local roomType = room:GetType()
    local newPool = itemPool:GetPoolForRoom(roomType, seed)

    if (roomType == RoomType.ROOM_CHALLENGE and Game():GetLevel():HasBossChallenge()) then
        newPool = ItemPoolType.POOL_BOSS
    end

    if (newPool < 0) then
        newPool = ItemPoolType.POOL_TREASURE
    end

    if (roomType == RoomType.ROOM_BOSS) then
        if (room:GetBossID() == 23 or level:GetStateFlag(LevelStateFlag.STATE_SATANIC_BIBLE_USED)) then
            newPool = ItemPoolType.POOL_DEVIL
        end
    end
    return newPool
end


--以特定品质从道具池抽取道具
--[[
输入:品质, 道具池, 是否移出道具池(是否), RNG

输出:道具ID
(没有抽取到道具时会以早餐代替)
]]
function Pools:GetCollectibleWithQuality(quality, pool, shouldRemove, rng)
	if quality < 0 then quality = 0 end
	if quality > 4 then quality = 4 end
	if not pool then pool = ItemPoolType.POOL_TREASURE end
	if not rng then rng = RNG() rng:SetSeed(Game():GetSeeds():GetStartSeed(), 35) end

	local itemPool = Game():GetItemPool()
    local item = 1
    local Q = 114514
	local times = 0
	local MAX = Isaac.GetItemConfig():GetCollectibles().Size or 2023
	
	while (Q ~= quality) do  
		item = itemPool:GetCollectible(pool, false, rng:Next(), 25)
		Q = (config:GetCollectible(item) and config:GetCollectible(item).Quality) or 114514
		times = times + 1
		
		--超过尝试次数直接换成早餐(偷懒的屑码师)
		if times > MAX then 
			item = 25
			break
		end
	end
	
	--移出道具池
	if shouldRemove then
		itemPool:RemoveCollectible(item)
    end
	
    return item
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

--获取单选掉落物参数
function Pools:GetUniqueOptionsIndex()
    local idx = 1
    local pickups = Isaac.FindByType(5)
    local unique = false
    while (not unique) do
        unique = true
        for i = 1, #pickups do
            local pickup = pickups[i]:ToPickup()
            if pickup.OptionsPickupIndex == idx then
                idx = idx + 1
                unique = false
                break
            end
        end
    end
    return idx
end



return Pools