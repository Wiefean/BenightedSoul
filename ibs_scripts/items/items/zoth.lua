--索斯星

local mod = Isaac_BenightedSoul

local game = Game()

local Zoth = mod.IBS_Class.Item(mod.IBS_ItemID.Zoth)

--房间列表
Zoth.RoomList = {2, 3, 4, 24, 29}
for roomType = 6,15 do
	table.insert(Zoth.RoomList, roomType)
end
for roomType = 18,21 do
	table.insert(Zoth.RoomList, roomType)
end

--用于对照的白名单
local WhiteList = {}
for _,roomType in ipairs(Zoth.RoomList) do
	if roomType ~= 29 then
		WhiteList[roomType] = true
	end
end

--新房间触发
function Zoth:OnNewRoom()
	if game:IsGreedMode() then return end
	if self:GetIBSData("level").ZothTriggered then return end
	if game:GetRoom():GetType() ~= RoomType.ROOM_BOSS then return end
	if not PlayerManager.AnyoneHasCollectible(self.ID) then return end
	local level = game:GetLevel()
	local seed = self._Levels:GetLevelUniqueSeed()
	
	local rooms = self._Levels:GetRooms(function(roomDesc)
		if roomDesc.VisitedCount <= 0 and roomDesc.Data and WhiteList[roomDesc.Data.Type] then
			return true
		end
		return false	
	end)
	
	--重置房间类型
	for _,roomDesc in ipairs(rooms) do
		local roomData = roomDesc.Data
		local newType = self.RoomList[RNG(seed - roomDesc.SafeGridIndex):RandomInt(1,#self.RoomList)] or 2
		local newData = self._Levels:CreateRoomData{
			Type = newType,
			Shape = roomData.Shape,
			Doors = roomData.Doors,
		}				
		if newData then
			roomDesc.Data = newData
		end
	end
	
	level:UpdateVisibility()	
	self:GetIBSData("level").ZothTriggered = true
end
Zoth:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, 'OnNewRoom')


return Zoth