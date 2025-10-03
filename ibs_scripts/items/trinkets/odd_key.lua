--怪异钥匙

local mod = Isaac_BenightedSoul

local game = Game()
local sfx = SFXManager()

local OddKey = mod.IBS_Class.Trinket(mod.IBS_TrinketID.OddKey)

--打开车轮战门
function OddKey:OnRoomCleaned()
	if game:IsGreedMode() then return end
	if not PlayerManager.AnyoneHasTrinket(self.ID) then return end
	local room = game:GetRoom()
	if room:IsClear() then
		if room:GetBossID() == BossType.MOM then
			room:TrySpawnBossRushDoor(true)
		end
		
		--完成车轮战生成潘多拉盒子
		if room:GetType() == RoomType.ROOM_BOSSRUSH then
			for i = 0, game:GetNumPlayers() -1 do
				local player = Isaac.GetPlayer(i)
				if player:HasTrinket(self.ID) then
					local mult = player:GetTrinketMultiplier(self.ID)
					if mult > 3 then mult = 3 end
					player:TryRemoveTrinket(self.ID)
					
					for i = 1,mult do
						local pos = room:FindFreePickupSpawnPosition(room:GetCenterPos(), 0, true)
						Isaac.Spawn(5, 100, 297, pos, Vector.Zero, nil)
					end	
				end
			end
		end
		
	end
end
OddKey:AddCallback(ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD, 'OnRoomCleaned')


return OddKey