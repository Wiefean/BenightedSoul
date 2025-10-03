--光之结界

local mod = Isaac_BenightedSoul

local game = Game()
local config = Isaac.GetItemConfig()

local LightBarrier = mod.IBS_Class.Item(mod.IBS_ItemID.LightBarrier)

--获得时生成正卡和倒卡
function LightBarrier:OnGain(item, charge, first, slot, varData, player)
	if first then
		local room = game:GetRoom()
		local rng = player:GetCollectibleRNG(self.ID)
		do
			local pos = room:FindFreePickupSpawnPosition(player.Position, 0, true)
			Isaac.Spawn(5, 300, rng:RandomInt(1,22), pos, Vector.Zero, nil)	
		end
		do
			local pos = room:FindFreePickupSpawnPosition(player.Position, 0, true)
			Isaac.Spawn(5, 300, rng:RandomInt(56,77), pos, Vector.Zero, nil)
		end		
	end
end
LightBarrier:AddCallback(ModCallbacks.MC_POST_ADD_COLLECTIBLE, 'OnGain', LightBarrier.ID)


--根据塔罗牌获取逆位塔罗牌ID,或反之
function LightBarrier:GetReversedTarot(id)
	if id >= 1 and id <= 22 then
		return id + 55
	end
	if id >= 56 and id <= 77 then
		return id - 55
	end
end

--获取塔罗牌点数
function LightBarrier:GetTarotNumber(id, alsoReversed)
	if id >= 1 and id <= 22 then
		return id - 1
	end
	if alsoReversed and id >= 56 and id <= 77 then
		return id - 56
	end
end

--清理房间后翻转角色身上的塔罗牌
function LightBarrier:OnRoomCleared()
	for i = 0, game:GetNumPlayers() - 1 do
		local player = Isaac.GetPlayer(i)
		local data = self._Players:GetData(player)
		if player:HasCollectible(self.ID) and not data.LightBarrierStop then
			for slot = 0,4 do
				local id = player:GetCard(slot)
				local number = self:GetTarotNumber(id, true)
				if number then
					local reversed = self:GetReversedTarot(id)
					player:SetCard(slot, reversed)
				end				
			end
		end
	end
end
LightBarrier:AddCallback(ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD, 'OnRoomCleared')

--新层
function LightBarrier:OnNewLevel()
	for i = 0, game:GetNumPlayers() - 1 do
		local player = Isaac.GetPlayer(i)
		local data = self._Players:GetData(player)
		data.LightBarrierStop = nil
		
		if player:HasCollectible(self.ID) then
			local rng = player:GetCollectibleRNG(self.ID)
			
			--播放动画
			self:DelayFunction(function()				
				player:AnimateCollectible(self.ID, "UseItem")
			end, 1)			
			
			--生成正或倒卡
			if rng:RandomInt(100) < 50 then
				self:DelayFunction(function()
					local room = game:GetRoom()
					local pos = room:FindFreePickupSpawnPosition(player.Position, 0, true)
					Isaac.Spawn(5, 300, player:GetCollectibleRNG(self.ID):RandomInt(1,22), pos, Vector.Zero, nil)	
				end, 10)
			else
				--生成倒卡后停用
				data.LightBarrierStop = true
				self:DelayFunction(function()
					local room = game:GetRoom()
					local pos = room:FindFreePickupSpawnPosition(player.Position, 0, true)
					Isaac.Spawn(5, 300, player:GetCollectibleRNG(self.ID):RandomInt(56,77), pos, Vector.Zero, nil)			
					player:AnimateSad()
				end, 10)			
			end
		end
	end
end
LightBarrier:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, 'OnNewLevel')


return LightBarrier