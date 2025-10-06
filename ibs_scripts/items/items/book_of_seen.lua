--全知之书

local mod = Isaac_BenightedSoul

local game = Game()
local config = Isaac.GetItemConfig()

local BookOfSeen = mod.IBS_Class.Item(mod.IBS_ItemID.BookOfSeen)


--获取数据
function BookOfSeen:GetData()
	local data = self:GetIBSData('temp')
	data.BookOfSeen = data.BookOfSeen or {}
	return data.BookOfSeen
end

--获取书道具
function BookOfSeen:GetBookItem(seed)
	seed = seed or 1
	local itemPool = game:GetItemPool()
	local result = 25
	local cache = {}

	for id = 1, config:GetCollectibles().Size do
		if itemPool:HasCollectible(id) then
			local itemConfig = config:GetCollectible(id)
			if itemConfig and itemConfig:IsAvailable() and itemConfig:HasTags(ItemConfig.TAG_BOOK) and not itemConfig:HasTags(ItemConfig.TAG_QUEST) then
				table.insert(cache, id)
			end
		end
	end	

	if #cache > 0 then
		result = cache[RNG(seed):RandomInt(1, #cache)] or 25
	end

	return result
end

--宝箱房生成书
function BookOfSeen:OnNewRoom(generator)
	if not PlayerManager.AnyoneHasCollectible(self.ID) then return end
	local room = game:GetRoom()
	if room:IsFirstVisit() and (room:GetType() == RoomType.ROOM_TREASURE) then
		local id = self:GetBookItem(self._Levels:GetRoomUniqueSeed())
		local pos = room:FindFreePickupSpawnPosition((room:GetCenterPos() + Vector(0, 80)), 0, true)
		Isaac.Spawn(5, 100, id, pos, Vector.Zero, nil)
		game:GetItemPool():RemoveCollectible(id)
	end
end
BookOfSeen:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, 'OnNewRoom')


--使用
function BookOfSeen:OnUse(item, rng, player, flag, slot)
	local data = self:GetData()

	--记录书道具
	for _,ent in pairs(Isaac.FindByType(5,100)) do
		local id = ent.SubType
		if id ~= self.ID then
			local recorded = false
			
			for k,v in pairs(data) do
				if v == id then
					recorded = true
					break
				end
			end
			
			if not recorded then
				local itemConfig = config:GetCollectible(id)
				if itemConfig and itemConfig:IsAvailable() and (itemConfig.Type == ItemType.ITEM_ACTIVE) and itemConfig:HasTags(ItemConfig.TAG_BOOK) and not itemConfig:HasTags(ItemConfig.TAG_QUEST) then
					ent:SetColor(Color(1,1,1,1,1,1,1),6,3,true)
					SFXManager():Play(171)
					table.insert(data, id)
				end
			end
		end
	end
	
	--触发效果
	for _,id in ipairs(data) do
		player:UseActiveItem(id, UseFlag.USE_NOANIM | UseFlag.USE_VOID)
		
		--美德书魂火
		if player:HasCollectible(584) then		
			player:AddWisp(id, player.Position, true)
		end
	end
	
	return true
end
BookOfSeen:AddCallback(ModCallbacks.MC_USE_ITEM, 'OnUse', BookOfSeen.ID)


return BookOfSeen

