--蛇的头

local mod = Isaac_BenightedSoul
local IBS_Sound = mod.IBS_Sound

local game = Game()
local sfx = SFXManager()

local SsserpentHead = mod.IBS_Class.Trinket(mod.IBS_TrinketID.SsserpentHead)

--隐藏房给钱
function SsserpentHead:OnNewRoom()
	local room = game:GetRoom()
	local roomType = room:GetType()
	
	if room:IsFirstVisit() and (
		roomType == RoomType.ROOM_SECRET
		or roomType == RoomType.ROOM_SUPERSECRET
		or roomType == RoomType.ROOM_ULTRASECRET
	)
	then
		local pos = room:GetCenterPos()
		for i = 0, game:GetNumPlayers() -1 do
			local player = Isaac.GetPlayer(i)
			if player:HasTrinket(self.ID) then
				local mult = player:GetTrinketMultiplier(self.ID)
				for i = 1,5*mult do
					Isaac.Spawn(5,20,0, pos, 2*RandomVector(), nil)
				end
				sfx:Play(SoundEffect.SOUND_CASH_REGISTER)
			end
		end
	end	
end
SsserpentHead:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, 'OnNewRoom')


return SsserpentHead