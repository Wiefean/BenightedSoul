--应战的G

local mod = Isaac_BenightedSoul
local IBS_CallbackID = mod.IBS_CallbackID
local AbandonedItem = mod.IBS_Effect.AbandonedItem

local game = Game()
local config = Isaac.GetItemConfig()

local RetaliatingC = mod.IBS_Class.Item(mod.IBS_ItemID.RetaliatingC)

--苍蝇标签和可召唤标签,非任务,非主动
local function Condition(itemConfig)
	if itemConfig:HasTags(ItemConfig.TAG_SUMMONABLE)
		and itemConfig:IsAvailable()
		and itemConfig:HasTags(ItemConfig.TAG_FLY)
		and not itemConfig:HasTags(ItemConfig.TAG_QUEST)
		and itemConfig.Type ~= ItemType.ITEM_ACTIVE
	then
		return true
	end
	return false
end

--获取满足要求的道具魂火ID
function RetaliatingC:GetWispID(seed)
	local itemPool = game:GetItemPool()
	local result = {}

	for _,id in ipairs(self._Pools:GetCollectibles(Condition)) do
		table.insert(result, id)
	end	
	
	--抽取一个
	if #result > 0 then
		return result[RNG(seed):RandomInt(1, #result)] or result[1]
	end
	
	--默认苍蝇环
	return 10
end

--获取满足要求的准备移除的道具ID
function RetaliatingC:GetItemIDToRemove(seed, quality)
	local itemPool = game:GetItemPool()
	local result = {}

	for _,v in ipairs(itemPool:GetCollectiblesFromPool(self._Pools:GetRoomPool(seed))) do
		local id = v.itemID
		if itemPool:HasCollectible(id) then
			local itemConfig = config:GetCollectible(id)
			if itemConfig and itemConfig.Quality == quality then
				table.insert(result, id)
			end	
		end
	end	
	
	--抽取一个
	if #result > 0 then
		return result[RNG(seed):RandomInt(1, #result)] or result[1]
	end
	
	--默认早餐
	return 25
end

--获得
function RetaliatingC:OnGain(item, charge, first, slot, varData, player)
	if first then
		local rng = player:GetCollectibleRNG(self.ID)
		player:AddItemWisp(self:GetWispID(rng:Next()), player.Position)
	end
end
RetaliatingC:AddCallback(ModCallbacks.MC_POST_ADD_COLLECTIBLE, 'OnGain', RetaliatingC.ID)

--道具首次出现时触发
function RetaliatingC:OnPickupFirstAppear(pickup)
	if not PlayerManager.AnyoneHasCollectible(self.ID) then return end
	if pickup.SubType <= 0 then return end
	local itemConfig = config:GetCollectible(pickup.SubType)
	
	--品质低于2的道具
	if itemConfig and itemConfig.Quality < 2 then
		for i = 0, game:GetNumPlayers() - 1 do
			local player = Isaac.GetPlayer(i)

			--将品质相同的道具移出道具池
			local rng = player:GetCollectibleRNG(self.ID)
			local id = self:GetItemIDToRemove(rng:Next(), itemConfig.Quality)
			game:GetItemPool():RemoveCollectible(id)
			
			--添加魂火
			player:AddItemWisp(self:GetWispID(rng:Next()), player.Position)	
			
			--特效
			do
				local itemConfig = config:GetCollectible(id)
				if itemConfig.GfxFileName then
					AbandonedItem:Spawn(pickup.Position, itemConfig.GfxFileName, RandomVector() * 0.1 * math.random(7, 12))
				end	
			end
		end
	end
end
RetaliatingC:AddCallback(IBS_CallbackID.PICKUP_FIRST_APPEAR, 'OnPickupFirstAppear', 100)


return RetaliatingC