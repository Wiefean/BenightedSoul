--胜者之弹

local mod = Isaac_BenightedSoul

local game = Game()

local MasterRound = mod.IBS_Class.Item(mod.IBS_ItemID.MasterRound)

--获得时满血
function MasterRound:OnGain(item, charge, first, slot, varData, player)
	if first then
		player:SetFullHearts()
	end
end
MasterRound:AddCallback(ModCallbacks.MC_POST_ADD_COLLECTIBLE, 'OnGain', MasterRound.ID)

--受伤记录
function MasterRound:OnTakeDMG(ent, dmg, flag, source)
	local player = ent:ToPlayer()	
	if player and (flag & DamageFlag.DAMAGE_NO_PENALTIES <= 0) then		
		self._Ents:GetTempData(player).NoMasterRound = true
	end
end
MasterRound:AddCallback(ModCallbacks.MC_POST_ENTITY_TAKE_DMG, 'OnTakeDMG')

--新房间清除记录
function MasterRound:OnNewRoom()
	for i = 0, game:GetNumPlayers() - 1 do
		local player = Isaac.GetPlayer(i)
		self._Ents:GetTempData(player).NoMasterRound = nil
	end	
end
MasterRound:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, 'OnNewRoom')

--清理boss房
function MasterRound:OnRoomCleaned()
	local room = game:GetRoom()
	local roomType = room:GetType()
	if roomType == RoomType.ROOM_BOSS or roomType == RoomType.ROOM_BOSSRUSH then
		for i = 0, game:GetNumPlayers() -1 do
			local player = Isaac.GetPlayer(i)
			if player:HasCollectible(self.ID) and not self._Ents:GetTempData(player).NoMasterRound then
				local pos = room:FindFreePickupSpawnPosition(room:GetCenterPos(), 0, true)
				Isaac.Spawn(5, 100, self.ID, pos, Vector.Zero, nil)
			end
		end
	end
end
MasterRound:AddCallback(ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD, 'OnRoomCleaned')

--boss波次
function MasterRound:OnWaveEndState(state)
	if state == 2 then
		local room = game:GetRoom()
		for i = 0, game:GetNumPlayers() -1 do
			local player = Isaac.GetPlayer(i)
			if player:HasCollectible(self.ID) then
				local pos = room:FindFreePickupSpawnPosition(room:GetCenterPos(), 0, true)
				Isaac.Spawn(5, 100, self.ID, pos, Vector.Zero, nil)
			end
		end
	end
end
MasterRound:AddCallback(mod.IBS_CallbackID.GREED_WAVE_END_STATE, 'OnWaveEndState')

--开门
function MasterRound:OnDoorUpdate(door)
	if game:IsGreedMode() then return end
	if not PlayerManager.AnyoneHasCollectible(self.ID) then return end
	if door:IsRoomType(RoomType.ROOM_SECRET_EXIT) and door:IsLocked() then
		door:SetLocked(false)
	end
end
MasterRound:AddCallback(ModCallbacks.MC_POST_GRID_ENTITY_DOOR_UPDATE, 'OnDoorUpdate')

return MasterRound