--奇怪的头骨

local mod = Isaac_BenightedSoul

local game = Game()

local Cranium = mod.IBS_Class.Item(mod.IBS_ItemID.Cranium)


--下层记录
function Cranium:OnNewLevel()
	for i = 0, game:GetNumPlayers() -1 do
		local player = Isaac.GetPlayer(i)
		local data = self._Players:GetData(player)
		
		if player:HasCollectible(self.ID) then
			local effect = player:GetEffects()
			data.WeirdCranium = true
			if not effect:HasNullEffect(NullItemID.ID_LOST_CURSE) then
				effect:AddNullEffect(NullItemID.ID_LOST_CURSE)
			end
		else
			data.WeirdCranium = nil
		end	
	end
end
Cranium:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, 'OnNewLevel')

--检测状态
function Cranium:OnNewRoom()
	local room = game:GetRoom()
	
	for i = 0, game:GetNumPlayers() -1 do
		local player = Isaac.GetPlayer(i)
		local effect = player:GetEffects()
		local data = self._Players:GetData(player)
	
		--没有道具直接清除记录
		if not player:HasCollectible(self.ID) then
			data.WeirdCranium = nil
		end		
		
		if (room:GetType() == RoomType.ROOM_BOSS) then --Boss房
			if data.WeirdCranium then
				player:AddBlackHearts(2)			
				SFXManager():Play(SoundEffect.SOUND_UNHOLY)
				data.WeirdCranium = nil
				if not room:IsMirrorWorld() then --不在镜子里
					if effect:HasNullEffect(NullItemID.ID_LOST_CURSE) then
						effect:RemoveNullEffect(NullItemID.ID_LOST_CURSE)
					end
				end					
			end
		else	
			if data.WeirdCranium then
				if not effect:HasNullEffect(NullItemID.ID_LOST_CURSE) then
					effect:AddNullEffect(NullItemID.ID_LOST_CURSE)
				end
				
				--正邪增强(东方mod)
				--10秒护盾(影书)
				if mod.IBS_Compat.THI:SeijaBuff(player) and (self._Finds:ClosestEnemy(player.Position) ~= nil) then
					player:UseActiveItem(58, false, false)
				end
			end
		end
	end
end
Cranium:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, 'OnNewRoom')


--里正邪兼容
function Cranium:TrySpawnItemsForSeijaB()
	local room = game:GetRoom()
	for i = 0, game:GetNumPlayers() -1 do
		local player = Isaac.GetPlayer(i)
		local num = mod.IBS_Compat.THI:GetSeijaBLevel(player) - 1
		if player:HasCollectible(self.ID) and num > 0 then
			for i = 1,num do
				local seed = self._Levels:GetRoomUniqueSeed()
				local id = game:GetItemPool():GetCollectible(ItemPoolType.POOL_DEVIL, true, seed)
				local pos = room:FindFreePickupSpawnPosition((room:GetCenterPos()), 0, true)
				local item = Isaac.Spawn(5, 100, id, pos, Vector(0,0), nil):ToPickup()
				item.ShopItemId = -2
				item.Price = -1
			end
		end
	end
end

--清理房间
function Cranium:OnRoomCleaned()
	if game:GetRoom():GetType() == RoomType.ROOM_BOSS then
		self:TrySpawnItemsForSeijaB()
	end
end
Cranium:AddCallback(ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD, 'OnRoomCleaned')


return Cranium