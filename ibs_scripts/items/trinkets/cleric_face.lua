--牧师的脸

local mod = Isaac_BenightedSoul
local IBS_Sound = mod.IBS_Sound

local game = Game()
local sfx = SFXManager()

local ClericFace = mod.IBS_Class.Trinket(mod.IBS_TrinketID.ClericFace)

--数据
function ClericFace:GetData(player)
	local data = self._Players:GetData(player)
	data.ClericFace = data.ClericFace or {Count = 0}
	return data.ClericFace
end

--清房给血
function ClericFace:OnRoomCleaned()
	local room = game:GetRoom()

	for i = 0, game:GetNumPlayers() -1 do
		local player = Isaac.GetPlayer(i)
		if player:HasTrinket(self.ID) then
			local mult = player:GetTrinketMultiplier(self.ID)
			local data = self:GetData(player)
			
			data.Count = data.Count + mult
			
			if data.Count >= 14 then
				data.Count = data.Count - 14
				if player:GetMaxHearts() < 10 then
					player:AddEternalHearts(1)
					sfx:Play(SoundEffect.SOUND_SUPERHOLY)
				else
					player:AddSoulHearts(1)
					sfx:Play(SoundEffect.SOUND_HOLY)
				end
				
				local pos = room:FindFreePickupSpawnPosition(player.Position, 0, true)
				Isaac.Spawn(5, 300, 51, pos, Vector.Zero, nil)					
			end
		end
	end
end
ClericFace:AddCallback(ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD, 'OnRoomCleaned')

return ClericFace