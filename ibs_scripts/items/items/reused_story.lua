--插叙

local mod = Isaac_BenightedSoul

local game = Game()

local ReusedStory = mod.IBS_Class.Item(mod.IBS_ItemID.ReusedStory)

--房间类型白名单
ReusedStory.WhiteList = {
	[RoomType.ROOM_SHOP] = true,
	[RoomType.ROOM_ERROR] = true,
	[RoomType.ROOM_TREASURE] = true,
	[RoomType.ROOM_SECRET] = true,
	[RoomType.ROOM_SUPERSECRET] = true,
	[RoomType.ROOM_ARCADE] = true,
	[RoomType.ROOM_CURSE] = true,
	[RoomType.ROOM_LIBRARY] = true,
	[RoomType.ROOM_SACRIFICE] = true,
	[RoomType.ROOM_DEVIL] = true,
	[RoomType.ROOM_ANGEL] = true,
	[RoomType.ROOM_ISAACS] = true,
	[RoomType.ROOM_BARREN] = true,
	[RoomType.ROOM_CHEST] = true,
	[RoomType.ROOM_DICE] = true,
	[RoomType.ROOM_PLANETARIUM] = true,
	[RoomType.ROOM_ULTRASECRET] = true,
}

--获取数据
function ReusedStory:GetData()
	local data = self:GetIBSData('temp')
	data.ReusedStory = data.ReusedStory or {
		Type = -1,
		Variant = -1,
		Subtype = -1,
		Shape = -1,
		Doors = -1,
		Mode = -1,
	}
	return data.ReusedStory
end

--记录房间信息
function ReusedStory:Record()
	local level = game:GetLevel()
	local roomDesc = level:GetRoomByIdx(level:GetCurrentRoomIndex())
	local roomData = (roomDesc and roomDesc.Data)
	if roomData then
		local data = self:GetData()
		data.Type = roomData.Type
		data.Variant = roomData.Variant
		data.Subtype = roomData.Subtype
		data.Shape = roomData.Shape
		data.Doors = roomData.Doors
		data.Mode = roomData.Mode
	end
end

--获取记录的房间信息
function ReusedStory:GetRecord()
	local data = self:GetData()
	if data.Type > 1 then
		return self._Levels:CreateRoomData{
			ReduceWeight = false,
			Type = data.Type,
			Shape = data.Shape,
			MinVariant = data.Variant, 
			MaxVariant = data.Variant,
			Doors = data.Doors,
			SubType = data.SubType,
			Mode = data.Mode,
		}
	end
end

--记录房间
function ReusedStory:OnNewRoom()
	if not PlayerManager.AnyoneHasCollectible(self.ID) then return end
	if self.WhiteList[game:GetRoom():GetType()] then
		local roomDesc = game:GetLevel():GetCurrentRoomDesc()
		if roomDesc and roomDesc.Flags & RoomDescriptor.FLAG_RED_ROOM <= 0 then		
			self:Record()
		end
	end
end
ReusedStory:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, 'OnNewRoom')

--新层生成房间
function ReusedStory:OnNewLevel()
	if not PlayerManager.AnyoneHasCollectible(self.ID) then return end
	local roomData = self:GetRecord()
	if roomData then
		local level = game:GetLevel()
		local seed = level:GetDungeonPlacementSeed()
		for _,gridIndex in ipairs(level:FindValidRoomPlacementLocations(roomData, -1, true, true)) do
			local roomDesc = level:TryPlaceRoom(roomData, gridIndex, -1, seed)
			if roomDesc then
				roomDesc.Flags = roomDesc.Flags | RoomDescriptor.FLAG_RED_ROOM
				roomDesc.DisplayFlags = 101
				level:UpdateVisibility()
				break
			end
		end
	end
end
ReusedStory:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, 'OnNewLevel')

return ReusedStory