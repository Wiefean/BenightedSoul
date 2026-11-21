--解锁昧化阿撒泻勒

local mod = Isaac_BenightedSoul
local IBS_PlayerKey = mod.IBS_PlayerKey
local CharacterLock = mod.IBS_Class.CharacterLock

local game = Game()
local sfx = SFXManager()

local BAzazel = CharacterLock(mod.IBS_PlayerID.BAzazel, {"bazazel_unlock"} )

--在挑战中进入天使房三次
function BAzazel:OnNewRoom()
	if self:IsUnlocked() then return end
	local BC8 = mod.IBS_Achiev and mod.IBS_Achiev.Challenge[8]
	if BC8 and BC8:Challenging() then
		if game:GetRoom():GetType() == RoomType.ROOM_ANGEL then
			local data = self:GetIBSData("temp")
			data.AngelTimesForBAzazel = (data.AngelTimesForBAzazel or 0) + 1
			if data.AngelTimesForBAzazel >= 3 then
				self:Unlock(true, true)
				sfx:Play(mod.IBS_Sound.SecretFound, 1.5)
			end
		end
	end	
end
BAzazel:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, 'OnNewRoom')

return BAzazel