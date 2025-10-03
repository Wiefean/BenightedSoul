--爸约

local mod = Isaac_BenightedSoul

local game = Game()
local sfx = SFXManager()

local DadsPromise = mod.IBS_Class.Trinket(mod.IBS_TrinketID.DadsPromise)


--拾取尝试添加计时器
function DadsPromise:ApplyTimer()
	local data = self:GetIBSData('temp')
	if data.DadsPromiseTimer == nil then
		data.DadsPromiseTimer = 0
	end
end
DadsPromise:AddCallback(ModCallbacks.MC_POST_TRIGGER_TRINKET_ADDED, 'ApplyTimer', DadsPromise.ID)
DadsPromise:AddCallback(ModCallbacks.MC_POST_TRIGGER_TRINKET_ADDED, 'ApplyTimer', DadsPromise.ID + 32768)

--计时器
function DadsPromise:TimerTick()
	local data = self:GetIBSData('temp')
	if data.DadsPromiseTimer ~= nil then
		data.DadsPromiseTimer = data.DadsPromiseTimer + 1
	end
end
DadsPromise:AddCallback(ModCallbacks.MC_POST_UPDATE, 'TimerTick')

--重置计时
function DadsPromise:ResetTimer()
	local data = self:GetIBSData('temp')
	if PlayerManager.AnyoneHasTrinket(self.ID) then
		data.DadsPromiseTimer = 0
	else	
		data.DadsPromiseTimer = nil
	end
end
DadsPromise:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, 'ResetTimer')

--获取计时
function DadsPromise:GetTimer()
	local data = self:GetIBSData('temp')
	return data.DadsPromiseTimer or 0
end

--尝试生成骰子碎片
function DadsPromise:TryReward(player)
	local room = game:GetRoom()
	local stage = game:GetLevel():GetStage()
	local mult = player:GetTrinketMultiplier(self.ID) - 1
	local timer = self:GetTimer()
	if timer <= 30*60 + stage*(15 + 5*mult) then
		local pos = room:FindFreePickupSpawnPosition(room:GetCenterPos(), 0, true)
		Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TAROTCARD, 49, pos, Vector.Zero, player)
		return true
	end
	return false
end

--清理boss房
function DadsPromise:OnRoomCleaned()
	local room = game:GetRoom()
	if room:GetType() == RoomType.ROOM_BOSS then
		for i = 0, game:GetNumPlayers() -1 do
			local player = Isaac.GetPlayer(i)
			if player:HasTrinket(self.ID) then
				self:TryReward(player)
			end
		end
	end
end
DadsPromise:AddCallback(ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD, 'OnRoomCleaned')

--boss波次
function DadsPromise:OnWaveEndState(state)
	if state == 2 then
		for i = 0, game:GetNumPlayers() -1 do
			local player = Isaac.GetPlayer(i)
			if player:HasTrinket(self.ID) then
				self:TryReward(player)
			end
		end
	end
end
DadsPromise:AddCallback(mod.IBS_CallbackID.GREED_WAVE_END_STATE, 'OnWaveEndState')


return DadsPromise
