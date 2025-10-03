--迷途之镜

local mod = Isaac_BenightedSoul
local IBS_ItemID = mod.IBS_ItemID
local Damage = mod.IBS_Class.Damage()

local game = Game()
local sfx = SFXManager()

local WilderingMirror = mod.IBS_Class.Item(IBS_ItemID.WilderingMirror)

--受伤判定
function WilderingMirror:OnTakeDMG(ent, dmg, flag, source)
	if dmg <= 0 then return end
	local player = ent:ToPlayer()
	if player and Damage:IsPenalt(player, flag, source) and player:HasCollectible(self.ID, true) then
		if player:GetCollectibleRNG(self.ID):RandomInt(100) < 50 then
			player:RemoveCollectible(self.ID, true)
			game:GetLevel():AddCurse(LevelCurse.CURSE_OF_THE_LOST, false)
			
			--生成破损版本
			local room = game:GetRoom()
			local pos = room:FindFreePickupSpawnPosition(player.Position, 0, true)
			local pickup = Isaac.Spawn(5, 100, IBS_ItemID.WilderingMirror2, pos, Vector.Zero, nil):ToPickup()
			pickup.Touched = true
			sfx:Play(53)
		end
	end
end
WilderingMirror:AddCallback(ModCallbacks.MC_POST_ENTITY_TAKE_DMG, 'OnTakeDMG')


--新层在特殊房间周围生成红房间
function WilderingMirror:GenerateRooms()
	if game:IsGreedMode() then return end
	if not PlayerManager.AnyoneHasCollectible(self.ID) then return end
	local level = game:GetLevel()

	for _,roomDesc in pairs(self._Levels:GetRooms()) do
		local roomData = roomDesc.Data
	
		--非普通房间,Boss房和红隐
		if roomData and roomData.Type ~= 1 and roomData.Type ~= 5 and roomData.Type ~= 29 then
			local roomIdx = roomDesc.SafeGridIndex
			for _,slot in ipairs(self._Levels:GetRoomDoorSlots(roomIdx)) do
				level:MakeRedRoomDoor(roomIdx, slot)
			end
		end
	end
	
	--揭示红房间位置
	for _,roomDesc in pairs(self._Levels:GetRooms()) do
		if roomDesc.Flags & RoomDescriptor.FLAG_RED_ROOM > 0 and roomDesc.Data then
			roomDesc.DisplayFlags = 101
		end
	end
	
	level:UpdateVisibility()
end
WilderingMirror:AddPriorityCallback(ModCallbacks.MC_POST_NEW_LEVEL, 1000, 'GenerateRooms')


return WilderingMirror