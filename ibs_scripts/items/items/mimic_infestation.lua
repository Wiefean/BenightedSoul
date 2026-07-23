--遍地宝箱怪

local mod = Isaac_BenightedSoul

local game = Game()

local MimicInfestation = mod.IBS_Class.Item(mod.IBS_ItemID.MimicInfestation)

function MimicInfestation:OnPickupUpdate(pickup)
	if pickup.SubType <= 0 then return end
	if pickup.Variant == PickupVariant.PICKUP_HAUNTEDCHEST then return end
	if not self._Pickups:IsChest(pickup.Variant) then return end
	
	--实现鬼箱特性
	if PlayerManager.AnyoneHasCollectible(self.ID) then
		local player = self._Finds:ClosestPlayer(pickup.Position)
		if player and player.Position:Distance(pickup.Position) < 100 then
			local data = self._Ents:GetDataBySeed(pickup.InitSeed)
			if not data.MIMIC_INFESTATION_CHEST then
				data.MIMIC_INFESTATION_CHEST = true
				
				local npc = Isaac.Spawn(816,0,0, pickup.Position, Vector.Zero, pickup):ToNPC()
				npc:SetColor(Color(1,1,1,0), 10, 1, true, true)
				self._Ents:GetTempData(npc).MIMIC_INFESTATION = true	
			end
		end
	end	
	
	--修正箱子位置
	local parent = pickup.Parent
	if parent and parent.Type == 816 and parent.Variant == 0 then
		if self._Ents:GetTempData(parent).MIMIC_INFESTATION then
			pickup.Position = parent.Position
			pickup.TargetPosition = parent.Position
		end
	end
end
MimicInfestation:AddCallback(ModCallbacks.MC_POST_PICKUP_UPDATE, 'OnPickupUpdate')

--新房间生成金箱子
function MimicInfestation:OnNewRoom()
	local room = game:GetRoom()
	if not room:IsFirstVisit() then return end
	local chance = 0
	
	for i = 0, game:GetNumPlayers() - 1 do
		local player = Isaac.GetPlayer(i)
		if player:HasCollectible(self.ID) then
			chance = chance + 6 * player:GetCollectibleNum(self.ID)
			
			--正邪增强(东方mod)
			if mod.IBS_Compat.THI:SeijaBuff(player) then
				chance = chance + 10
				local seijaBLevel = mod.IBS_Compat.THI:GetSeijaBLevel(player)
				if seijaBLevel > 1 then
					chance = chance + 10 * (seijaBLevel - 1)
				end
			end
		end
	end		

	if chance > 0 then
		if RNG(self._Levels:GetRoomUniqueSeed()):RandomInt(100) < chance then
			local pos = room:FindFreePickupSpawnPosition(room:GetCenterPos(), 0, true)
			local chest = Isaac.Spawn(5, 60, 1, pos, Vector.Zero, nil):ToPickup()
			chest.Wait = 90
		end
	end

end
MimicInfestation:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, 'OnNewRoom')


--正邪增强(东方mod)
--捣蛋小鬼存在时无敌
function MimicInfestation:OnPlayerUpdate(player)
	if not player:HasCollectible(self.ID) then return end
	if not mod.IBS_Compat.THI:SeijaBuff(player) then return end
	if #Isaac.FindByType(816,0,0) <= 0 then return end
	if player:GetDamageCooldown() < 15 then	
		player:SetMinDamageCooldown(30)
	end
end
MimicInfestation:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, 'OnPlayerUpdate', 0)


return MimicInfestation