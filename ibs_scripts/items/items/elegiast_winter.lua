--悼歌之冬

local mod = Isaac_BenightedSoul

local game = Game()
local config = Isaac.GetItemConfig()
local ElegiastRoom = mod.IBS_Room.Elegiast

local ElegiastWinter = mod.IBS_Class.Item(mod.IBS_ItemID.ElegiastWinter)

--拾取
function ElegiastWinter:OnGain(item, charge, first, slot, varData, player)
	if first then
		local room = game:GetRoom()
		local pos = room:FindFreePickupSpawnPosition(player.Position, 0, true)
		Isaac.Spawn(5, 300, 10, pos, Vector.Zero, nil)
	end
end
ElegiastWinter:AddCallback(ModCallbacks.MC_POST_ADD_COLLECTIBLE, 'OnGain', ElegiastWinter.ID)

--清理房间概率生成隐者
function ElegiastWinter:OnRoomCleaned()
	for i = 0, game:GetNumPlayers() - 1 do
		local player = Isaac.GetPlayer(i)
		if player:HasCollectible(self.ID) then
			local int = player:GetCollectibleRNG(self.ID):RandomInt(100)
			if int < 10 then
				local room = game:GetRoom()
				local pos = room:FindFreePickupSpawnPosition(room:GetCenterPos(), 0, true)
				Isaac.Spawn(5, 300, 10, pos, Vector.Zero, nil)
			end
		end
	end	
end
ElegiastWinter:AddCallback(ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD, 'OnRoomCleaned')
ElegiastWinter:AddCallback(mod.IBS_CallbackID.GREED_NEW_WAVE, 'OnRoomCleaned')

--隐者传送
function ElegiastWinter:OnUseCard(id, player, flag)
	if not player:HasCollectible(self.ID) then return end
	local data = self:GetIBSData('level')
	if data.ElegiastWinterUsed then return end

	--排除祸兽房间
	if not self._Levels:IsInBeastBattle() then
		Isaac.ExecuteCommand('goto s.shop.'..ElegiastRoom.Variant)
		game:StartRoomTransition(-3, Direction.NO_DIRECTION, RoomTransitionAnim.TELEPORT, player)
		self._Levels:QuitDebugRoomWhenExit()
		data.ElegiastWinterUsed = true
	end
end
ElegiastWinter:AddCallback(ModCallbacks.MC_USE_CARD, 'OnUseCard', 10)


return ElegiastWinter