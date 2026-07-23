--恶魔三选一超隐

local mod = Isaac_BenightedSoul
local IBS_ItemID = mod.IBS_ItemID
local IBS_PlayerKey = mod.IBS_PlayerKey

local game = Game()

local Choose = mod.IBS_Class.Room{
	Type = RoomType.ROOM_SUPERSECRET,
	Variant = 7253
}

--道具列表
Choose.ItemList = {
	IBS_ItemID.LordsParasol,
	IBS_ItemID.BloodyRose,
	IBS_ItemID.PreservedFog,
	IBS_ItemID.Fiddle,
	IBS_ItemID.WhisperingEarring,
	IBS_ItemID.SereTalon,
	IBS_ItemID.MusicBox,
	IBS_ItemID.JeweledMask,
	IBS_ItemID.ChoicesParadox,
	IBS_ItemID.DistinguishedCape,
}

--副作用道具名单
Choose.WithDebuffList = {
	[IBS_ItemID.LordsParasol] = true,
	[IBS_ItemID.BloodyRose] = true,
	[IBS_ItemID.PreservedFog] = true,
	[IBS_ItemID.Fiddle] = true,
	[IBS_ItemID.WhisperingEarring] = true,
	[IBS_ItemID.SereTalon] = true,
}

--抽取道具
function Choose:GetItems()
	local seed = self._Levels:GetRoomUniqueSeed()
	local rng = RNG(seed)
	local cache = {}
	local cache2 = {}
	local result = {}
	
	for _,id in ipairs(self.ItemList) do
		if self.WithDebuffList[id] then		
			table.insert(cache, id)
		end
	end
	for _,id in ipairs(self.ItemList) do	
		table.insert(cache2, id)
	end	
	
	--先抽取两个副作用道具
	for i = 1,2 do
		local id = cache[rng:RandomInt(1,#cache)] or cache[1]
		if id then
			table.insert(result, id)
			
			for k,v in ipairs(cache) do
				if v == id then
					table.remove(cache, k)
				end
			end
			for k,v in ipairs(cache2) do
				if v == id then
					table.remove(cache2, k)
				end
			end
		end
	end
	
	--再随机抽取剩下的
	local id = cache2[rng:RandomInt(1,#cache2)] or cache2[1]
	if id then
		table.insert(result, id)
	end
	
	return result
end

--按格子位置生成实体
local function SpawnOnGrid(T,V,S, grid)
	local room = game:GetRoom()
	local pos = room:GetGridPosition(grid)
	return Isaac.Spawn(T,V,S, pos, Vector.Zero, nil)
end

--生成梯子
local function SpawnLadder()
	if #Isaac.FindByType(1000, 156, 0) <= 0 then
		SpawnOnGrid(1000, 156, 0, 26)
	end
end

--房间初始化
Choose.EnterFunc = function(self, first, room, roomData)
	if first then
		local idx = self._Pickups:GetUniqueOptionsIndex()
		local seed = self._Levels:GetRoomUniqueSeed()
		local grid = 80
		
		for _,id in ipairs(self:GetItems()) do		
			local item = SpawnOnGrid(5,100,id, grid):ToPickup()
			item.ShopItemId = -2
			item.Price = -1
			item.OptionsPickupIndex = idx
			grid = grid + 2
		end
		
		--跳过心掉落物的动画
		for _,ent in ipairs(Isaac.FindByType(5,10)) do
			ent:GetSprite():SetFrame(99)
		end
	end
	
	--删除门
	for slot = 0,7 do
		room:RemoveDoor(slot)
	end	
	
	--如有记录,生成梯子
	if self:GetIBSData("level").TheSuperSecetRoomNamedChooseTriggered then
		SpawnLadder()
	end
end

--拾取道具时记录
function Choose:OnPickItem(player, item, touched)
	if self:IsInRoom() then
		SpawnLadder()
		self:GetIBSData("level").TheSuperSecetRoomNamedChooseTriggered = true
	end
end
Choose:AddPriorityCallback(mod.IBS_CallbackID.PICK_COLLECTIBLE, CallbackPriority.LATE, 'OnPickItem')

--房间内没有道具时也记录
function Choose:OnUpdate()
	local data = self:GetIBSData("level")
	if self:IsInRoom() 
		and not data.TheSuperSecetRoomNamedChooseTriggered
		and (#Isaac.FindByType(5,100) <= 0 or #Isaac.FindByType(5,100,0) > 0)
	then
		SpawnLadder()
		data.TheSuperSecetRoomNamedChooseTriggered = true		
	end
end
Choose:AddCallback(ModCallbacks.MC_POST_UPDATE, 'OnUpdate')

--小退直接开
function Choose:PreGameExit()
	local data = self:GetIBSData("level")
	if self:IsInRoom() then
		SpawnLadder()
		data.TheSuperSecetRoomNamedChooseTriggered = true		
	end
end
Choose:AddCallback(ModCallbacks.MC_PRE_GAME_EXIT, 'PreGameExit')

--未解锁时替换房间
function Choose:ReplaceRooms(roomSlot, roomData, seed)
	if self:GetIBSData('persis')[IBS_PlayerKey.BSamson].MegaSatan then return end

	if roomData.Type == RoomType.ROOM_SUPERSECRET
		and roomData.Variant == self.Variant
	then
		local newData = self._Levels:CreateRoomData{
			Seed = seed,
			Type = RoomType.ROOM_SUPERSECRET,
			MinVariant = 0,
			MaxVariant = 0,
			Shape = roomSlot:Shape(),
			Doors = roomSlot:DoorMask()
		}
		if newData then
			return newData
		end
	end
end
Choose:AddPriorityCallback(ModCallbacks.MC_PRE_LEVEL_PLACE_ROOM, -1000, 'ReplaceRooms')

--测试用,生成房间
-- function Choose:TryGenerate()
	-- local level = game:GetLevel()
	-- local seed = level:GetDungeonPlacementSeed()
	-- local roomData = self._Levels:CreateRoomData{
		-- Seed = seed,
		-- Type = RoomType.ROOM_SUPERSECRET,
		-- MinVariant = self.Variant,
		-- MaxVariant = self.Variant,
		-- SubType = 14,
	-- }
	-- if roomData then
		-- for _,gridIndex in pairs(level:FindValidRoomPlacementLocations(roomData)) do
			-- if level:TryPlaceRoom(roomData, gridIndex, -1, seed) then
				-- break
			-- end
		-- end
	-- end
-- end
-- Choose:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, 'TryGenerate')

return Choose