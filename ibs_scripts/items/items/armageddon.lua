--哈米吉多顿

local mod = Isaac_BenightedSoul

local game = Game()

local Armageddon = mod.IBS_Class.Item(mod.IBS_ItemID.Armageddon)

--尝试生成br
function Armageddon:TryGenerateBR()
	if not PlayerManager.AnyoneHasCollectible(self.ID) then return end
	
	--正邪削弱(东方mod)
	--直接跳过生成
	for i = 0, game:GetNumPlayers() - 1 do
		local player = Isaac.GetPlayer(i)
		if mod.IBS_Compat.THI:SeijaNerf(player) then
			return
		end
	end
	
	local level = game:GetLevel()
	local seed = self._Levels:GetLevelUniqueSeed()
	local roomData = self._Levels:CreateRoomData{
		Seed = seed,
		Type = RoomType.ROOM_BOSSRUSH,
		Shape = RoomShape.ROOMSHAPE_2x2,
	}
	if roomData then
		for _,gridIndex in pairs(level:FindValidRoomPlacementLocations(roomData)) do
			local roomDesc = level:TryPlaceRoom(roomData, gridIndex, -1, seed)
			if roomDesc then
				--揭示位置
				roomDesc.DisplayFlags = 101
				level:UpdateVisibility()
				break
			end
		end
	end
end
Armageddon:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, 'TryGenerateBR')

--取消br内道具单选
function Armageddon:OnPickupUpdate(pickup)
	if not PlayerManager.AnyoneHasCollectible(self.ID) then return end
	if game:GetRoom():GetType() == RoomType.ROOM_BOSSRUSH then
		pickup.OptionsPickupIndex = 0
	end
end
Armageddon:AddCallback(ModCallbacks.MC_POST_PICKUP_UPDATE, 'OnPickupUpdate', 100)

--br内道具选择增加
function Armageddon:OnPickupFirstAppear(pickup)
	if not PlayerManager.AnyoneHasCollectible(self.ID) then return end
	if game:GetRoom():GetType() ~= RoomType.ROOM_BOSSRUSH then return end
	local itemPool = game:GetItemPool()
	local id = itemPool:GetCollectible(self._Pools:GetRoomPool(), true, pickup.InitSeed, 25)
	pickup:AddCollectibleCycle(id)
end
Armageddon:AddCallback(mod.IBS_CallbackID.PICKUP_FIRST_APPEAR, 'OnPickupFirstAppear', 100)


--敌人扣血
function Armageddon:OnNpcUpdate(npc)
	if not PlayerManager.AnyoneHasCollectible(self.ID) then return end
	if game:GetRoom():GetType() ~= RoomType.ROOM_BOSSRUSH then return end
	if not self._Ents:IsEnemy(npc, true) then return end
	
	if npc:IsFrame(30,0) and npc.HitPoints > 0 then
		npc.HitPoints = math.floor(math.max(0, npc.HitPoints - 0.12*npc.MaxHitPoints))
	end
end
Armageddon:AddCallback(ModCallbacks.MC_NPC_UPDATE, 'OnNpcUpdate')


return Armageddon