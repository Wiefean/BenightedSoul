--精灵便便

local mod = Isaac_BenightedSoul

local game = Game()
local sfx = SFXManager()

local SpiritPoop = mod.IBS_Class.Item(mod.IBS_ItemID.SpiritPoop)

--替换诅咒房
function SpiritPoop:ReplaceRooms(roomSlot, roomData, seed)
	if not PlayerManager.AnyoneHasCollectible(self.ID) then return end
	if roomData.Type == RoomType.ROOM_CURSE then
		local newData = self._Levels:CreateRoomData{
			Seed = seed,
			Type = RoomType.ROOM_SUPERSECRET,
			Shape = roomSlot:Shape(),
			Doors = roomSlot:DoorMask(),
		}
		if newData then
			return newData
		end
	end
end
SpiritPoop:AddPriorityCallback(ModCallbacks.MC_PRE_LEVEL_PLACE_ROOM, -700, 'ReplaceRooms')

--开门
function SpiritPoop:OnNewRoom()
	if not PlayerManager.AnyoneHasCollectible(self.ID) then return end
	local room = game:GetRoom()
	if not room:IsFirstVisit() then return end
	for slot = 0,7 do
		local door = room:GetDoor(slot)
		if door ~= nil then
			local roomIdx = door.TargetRoomIndex
			if roomIdx then
				local roomDesc = game:GetLevel():GetRoomByIdx(roomIdx)
				if roomDesc and roomDesc.Data and roomDesc.Data.Type == 8 then
					door:SetLocked(false)
				end
			end
		end
	end
end
SpiritPoop:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, 'OnNewRoom')

return SpiritPoop