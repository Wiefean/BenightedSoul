--月下异巷

local mod = Isaac_BenightedSoul
local IBS_ItemID = mod.IBS_ItemID

local game = Game()
local sfx = SFXManager()

local MoonStreets = mod.IBS_Class.Item(IBS_ItemID.MoonStreets)

function MoonStreets:OnNewRoom()
	if not PlayerManager.AnyoneHasCollectible(self.ID) then return end
	local room = game:GetRoom()
	local roomType = room:GetType()
	
	--进入三种隐藏房时自动开门(防卡关)
	if roomType == 7 or roomType == 8 or roomType == 29 then
		for slot = 0,7 do
			local door = room:GetDoor(slot)
			if door then
				door:SetLocked(false)
				door:Open()
			end
		end
	end

	if roomType ~= 1 then
		return
	end	
	
	local level = game:GetLevel()

	--贪婪模式,不在主世界或镜世界
	if game:IsGreedMode() or (level:GetDimension() ~= 0 and level:GetDimension() ~= 1) then
		return
	end
	
	--非初始房间
	if level:GetStartingRoomIndex() == level:GetCurrentRoomDesc().SafeGridIndex then return end

	--获取未进入过的特殊房间
	local rooms = self._Levels:GetRooms(function(desc)
		if desc and desc.VisitedCount <= 0 and desc.Data and desc.Data.Type ~= 1 and desc.Data.Type ~= 29 then
			--第六层忽略boss房
			if desc.Data.Type == 5 and level:GetStage() == 6 then
				return false
			end
			return true
		end
		return false
	end)

	if #rooms > 0 then
		local player = Isaac.GetPlayer(0)
		local rng = RNG(self._Levels:GetRoomUniqueSeed())
		local roomDesc = rooms[rng:RandomInt(1,#rooms)] or rooms[1]
		if roomDesc and roomDesc.Data then
			game:StartRoomTransition(roomDesc.GridIndex, -1, RoomTransitionAnim.FADE, player)
		end
	end

end
MoonStreets:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, 'OnNewRoom')

--角色免疫诅咒房门伤害
function MoonStreets:PrePlayerTakeDMG(player, dmg, flag)
	if player:HasCollectible(self.ID) and (flag & DamageFlag.DAMAGE_CURSED_DOOR > 0) then
		return false
	end
end
MoonStreets:AddPriorityCallback(ModCallbacks.MC_PRE_PLAYER_TAKE_DMG, -800, 'PrePlayerTakeDMG')


return MoonStreets