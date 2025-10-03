--恶魔房和天使房开启状态回调

local mod = Isaac_BenightedSoul
local IBS_CallbackID = mod.IBS_CallbackID

local game = Game()

local DevilAngelOpenState = mod.IBS_Class.Callback(IBS_CallbackID.DEVIL_ANGEL_OPEN_STATE)


--检测房门
function DevilAngelOpenState:CheckDAOpen()
	local devil = false
	local angel = false
	local room = game:GetRoom()
	local level = game:GetLevel()
	
	--贪婪模式只检测一个地方门就行
	if game:IsGreedMode() then
		local door = room:GetDoor(DoorSlot.LEFT1)
		if door then
			local data = level:GetRoomByIdx(door.TargetRoomIndex).Data
			if data then
				if (data.Type == RoomType.ROOM_DEVIL) then	
					devil = true
				end
				if (data.Type == RoomType.ROOM_ANGEL) then	
					angel = true
				end
			end
		end	
	else
		for i = 0, DoorSlot.NUM_DOOR_SLOTS - 1 do
			local door = room:GetDoor(i)
			if door then
				local data = level:GetRoomByIdx(door.TargetRoomIndex).Data
				if data then
					if (data.Type == RoomType.ROOM_DEVIL) then	
						devil = true
					end
					if (data.Type == RoomType.ROOM_ANGEL) then	
						angel = true
					end
				end
			end
		end	
	end

	
	return devil,angel
end

--击败Boss后检测房门
function DevilAngelOpenState:AfterBoss()
	if not game:IsGreedMode() then --非贪婪
		local room = game:GetRoom()
		local level = game:GetLevel()
		local stage = level:GetStage()
		
		--非回溯线,2到8层,非见证者房间,最后一个Boss房
		if (not level:IsAscent()) and (stage >= 2 and stage <= 8) and (room:GetBossID() ~= 88) and room:IsCurrentRoomLastBoss() then
			local devil,angel = self:CheckDAOpen()
			
			--二元性(检测并不完善)
			if PlayerManager.AnyoneHasCollectible(498) and level:CanSpawnDevilRoom() and not level:IsDevilRoomDisabled() then
				devil = true
				angel = true
			end
			
			self:Run(devil, angel)
		end
	end
end
DevilAngelOpenState:AddPriorityCallback(ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD, 2000, 'AfterBoss')

--贪婪模式完成额外波次后检测房门
function DevilAngelOpenState:AfterDealWave(state)
	if state == 3 then
		local devil,angel = self:CheckDAOpen()
		self:Run(devil, angel)
	end	
end
DevilAngelOpenState:AddPriorityCallback(IBS_CallbackID.GREED_WAVE_END_STATE, 2000, 'AfterDealWave')


return DevilAngelOpenState