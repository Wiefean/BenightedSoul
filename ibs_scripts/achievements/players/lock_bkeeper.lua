--解锁昧化店主
--[[
控制台增加捐款数指令
lua Isaac.GetPersistentGameData():IncreaseEventCounter(20, 数量)

控制台增加贪婪捐款数指令
lua Isaac.GetPersistentGameData():IncreaseEventCounter(115, 数量)
]]

local mod = Isaac_BenightedSoul
local IBS_ItemID = mod.IBS_ItemID
local CharacterLock = mod.IBS_Class.CharacterLock

local game = Game()
local sfx = SFXManager()
local music = MusicManager()

local BKeeper = CharacterLock(mod.IBS_PlayerID.BKeeper, {'bkeeper_unlock'} )

--获取当前捐款数
local function GetCurrentCounter()
	local donation = Isaac.GetPersistentGameData():GetEventCounter(EventCounter.DONATION_MACHINE_COUNTER)
	local greedDonation = Isaac.GetPersistentGameData():GetEventCounter(EventCounter.GREED_DONATION_MACHINE_COUNTER)
	
	while donation >= 1000 do
		donation = donation - 1000
	end
	
	while greedDonation >= 1000 do
		greedDonation = greedDonation - 1000
	end

	return donation,greedDonation
end

--未解锁时贪婪商店额外概率出现捐款机
function BKeeper:OnNewRoom()
	if self:IsUnlocked() then return end
	if not game:IsGreedMode() then return end
	local room = game:GetRoom()
	
	if room:GetType() == RoomType.ROOM_SHOP and room:IsFirstVisit() and #Isaac.FindByType(6,8,0) <= 0 then
		local rng = RNG(self._Levels:GetRoomUniqueSeed())
		local int = rng:RandomInt(100)
		if int < 50 then
			Isaac.Spawn(6, 8, 0, room:FindFreePickupSpawnPosition(room:GetGridPosition(78), 0, true), Vector.Zero, nil)		
		end
	end
end
BKeeper:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, 'OnNewRoom')

--贪婪模式捐满捐款机解锁
function BKeeper:OnUpdate(item, rng, player, flag, slot)
	if self:IsUnlocked() then return end
	if game:AchievementUnlocksDisallowed() then return end
	local donation,greedDonation = GetCurrentCounter()
	if donation >= 999 and greedDonation <= 0 then
		sfx:Play(mod.IBS_Sound.SecretFound, 1.3)
		self:Unlock(true, true)
	end
end
BKeeper:AddCallback(ModCallbacks.MC_POST_UPDATE, 'OnUpdate')


return BKeeper