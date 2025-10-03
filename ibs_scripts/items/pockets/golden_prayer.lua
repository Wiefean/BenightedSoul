--金色祈者

local mod = Isaac_BenightedSoul
local IronHeart = mod.IBS_Class.IronHeart()
local TempIronHeart = mod.IBS_Class.TempIronHeart()

local game = Game()
local sfx = SFXManager()

local GoldenPrayer = mod.IBS_Class.Pocket(mod.IBS_PocketID.GoldenPrayer)

--使用记录
function GoldenPrayer:Record()
	self:GetIBSData('temp').GoldenPrayerUsed = true
end

--是否有记录
function GoldenPrayer:IsRecorded()
	return (self:GetIBSData('temp').GoldenPrayerUsed ~= nil)
end

--清理使用记录
function GoldenPrayer:Unrecord()
	self:GetIBSData('temp').GoldenPrayerUsed = nil
end


--使用效果
function GoldenPrayer:OnUse(card, player, flag)
	--表表抹
	if player:GetPlayerType() == (mod.IBS_PlayerID.BMaggy) then
		local data = IronHeart:GetData(player)
		data.Extra = data.Extra + 28
		data.Breakdown = 0
	else
		local data = TempIronHeart:GetData(player)
		data.Num = data.Num + 28
	end

	if (flag & UseFlag.USE_MIMIC <= 0) then	
		self:Record()
	end
	
	sfx:Play(SoundEffect.SOUND_SUPERHOLY)
end
GoldenPrayer:AddCallback(ModCallbacks.MC_USE_CARD, 'OnUse', GoldenPrayer.ID)

--击败Boss后尝试返还
function GoldenPrayer:OnRoomCleaned()
	local room = game:GetRoom()
	if room:GetType() == RoomType.ROOM_BOSS and self:IsRecorded() then
		local pos = room:FindFreePickupSpawnPosition(room:GetCenterPos(), 0, true)
		Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TAROTCARD, self.ID, pos, Vector.Zero, nil)		
		self:Unrecord()
		sfx:Play(268)
	end	
end
GoldenPrayer:AddCallback(ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD, 'OnRoomCleaned')


--贪婪Boss波次后尝试返还
function GoldenPrayer:OnGreedWaveEnd(state)
	if state == 2 and self:IsRecorded() then
		local room = game:GetRoom()
		local pos = room:FindFreePickupSpawnPosition(room:GetCenterPos(), 0, true)
		Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TAROTCARD, self.ID, pos, Vector.Zero, nil)		
		self:Unrecord()
		sfx:Play(268)
	end	
end
GoldenPrayer:AddCallback(mod.IBS_CallbackID.GREED_WAVE_END_STATE, 'OnGreedWaveEnd')



return GoldenPrayer
