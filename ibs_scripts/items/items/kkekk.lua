--是匕是匕

local mod = Isaac_BenightedSoul

local game = Game()

local KKEKK = mod.IBS_Class.Item(mod.IBS_ItemID.KKEKK)

--失去钥匙时触发
function KKEKK:OnKeyNumChange(delta, left)
	if delta < 0 and left <= 0 and PlayerManager.AnyoneHasCollectible(self.ID) then
		local data = self:GetIBSData('level')
		if not data.KKEKK_Triggered then
			data.KKEKK_Triggered = true
			game:StartRoomTransition(GridRooms.ROOM_ERROR_IDX, Direction.NO_DIRECTION, RoomTransitionAnim.TELEPORT)
		end
	end
end
KKEKK:AddCallback(mod.IBS_CallbackID.NUM_CHANGE_KEY,'OnKeyNumChange')


return KKEKK