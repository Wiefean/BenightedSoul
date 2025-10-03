--左断脚

local mod = Isaac_BenightedSoul

local game = Game()

local LeftFoot = mod.IBS_Class.Trinket(mod.IBS_TrinketID.LeftFoot)

--新层降低移速并生成红箱
function LeftFoot:OnNewLevel()
	for i = 0, game:GetNumPlayers() -1 do
		local player = Isaac.GetPlayer(i)
		
		if player:HasTrinket(self.ID) then
			local mult = player:GetTrinketMultiplier(self.ID)
			local room = game:GetRoom()

			if player.MoveSpeed >= 0.6 then
				for i = 1,2*mult do
					local pos = room:FindFreePickupSpawnPosition(player.Position, 0 ,true)
					Isaac.Spawn(5, 360, 1, pos, Vector.Zero, player) --红箱
					Isaac.Spawn(1000, 15, 0, pos, Vector.Zero, nil) --烟雾
				end
				self._Stats:PersisSpeed(player, -0.06, true)
			end
		end	
	end	
end
LeftFoot:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, 'OnNewLevel')


return LeftFoot