--命运纠缠

local mod = Isaac_BenightedSoul
local IBS_ItemID = mod.IBS_ItemID

local game = Game()
local sfx = SFXManager()

local Entanglement = mod.IBS_Class.Item(IBS_ItemID.Entanglement)

--检查恶魔天使房开启状态
function Entanglement:CheckDAOpen(devil, angel)
	if game:IsGreedMode() then return end
	if not PlayerManager.AnyoneHasCollectible(self.ID) then return end

	if not devil and not angel then
		local room = game:GetRoom()
		local level = game:GetLevel()
		local seed = level:GetDungeonPlacementSeed()
		
		for i = 1,2 do		
			local roomData = self._Levels:CreateRoomData{
				Seed = seed,
				Type = RoomType.ROOM_ERROR,
			}
			if roomData then
				for _,gridIndex in pairs(level:FindValidRoomPlacementLocations(roomData, -1, true, true)) do
					local skip = false
				
					--相邻房间不能是红隐
					for _,neighborDesc in pairs(level:GetNeighboringRooms(gridIndex, 1)) do
						local neighborType = (neighborDesc.Data and neighborDesc.Data.Type) or -1
						if neighborType == RoomType.ROOM_ULTRASECRET then
							skip = true
							break
						end
					end				
				
					if not skip then					
						local desc = level:TryPlaceRoom(roomData, gridIndex, -1, seed, true, true)
						if desc then
							desc.Flags = desc.Flags | RoomDescriptor.FLAG_RED_ROOM
							desc.DisplayFlags = 101
							level:UpdateVisibility()
							sfx:Play(81)
							break
						end
					end
				end
			end	
			seed = seed - 1
		end
	end
end
Entanglement:AddCallback(mod.IBS_CallbackID.DEVIL_ANGEL_OPEN_STATE, 'CheckDAOpen')

return Entanglement