--洞开之启

local mod = Isaac_BenightedSoul

local game = Game()
local sfx = SFXManager()

local Knock = mod.IBS_Class.Item(mod.IBS_ItemID.Knock)

--特殊房间池
Knock.RoomTypeList = {
	2,
	4,
	7,
	8,
	9,
	10,
	12,
	13,
	14,
	15,
	18,
	19,
	20,
	21,
	24,
}

--获得时生成教皇卡
function Knock:OnGain(item, charge, first, slot, varData, player)
	if first then
		local room = game:GetRoom()
		local pos = room:FindFreePickupSpawnPosition(player.Position, 0, true)
		Isaac.Spawn(5, 300, 6, pos, Vector.Zero, nil)
	end
end
Knock:AddCallback(ModCallbacks.MC_POST_ADD_COLLECTIBLE, 'OnGain', Knock.ID)

--使用教皇卡
function Knock:OnUseCard(card, player)
	if player:HasCollectible(self.ID) then
		local room = game:GetRoom()
		local level = game:GetLevel()
		local idx = level:GetCurrentRoomIndex()
		local brokenNum = 0
		local seed = self._Levels:GetRoomUniqueSeed()
		
		for _,slot in ipairs(self._Levels:GetCurrentRoomSpareDoorSlots()) do
			if level:MakeRedRoomDoor(idx, slot) then
				local door = room:GetDoor(slot)
				if door then
					local desc = level:GetRoomByIdx(door.TargetRoomIndex)
					
					if desc ~= nil and desc.GridIndex > 0 and desc.Data then
						local roomData = desc.Data
						local inList = false
						
						for _,roomType in ipairs(self.RoomTypeList) do
							if roomType == roomData.Type then
								inList = true
								break
							end
						end
					
						--为非名单内房间则尝试替换为特殊房间
						if not inList then
							local list = {}
							for _,roomType in ipairs(self.RoomTypeList) do
								table.insert(list, roomType)
							end
						
							self:ShuffleTable(list, seed) --打乱
						
							--每种都尝试一遍提升成功概率
							for _,roomType in ipairs(list) do
								local newData = self._Levels:CreateRoomData{
									Type = roomType,
									Shape = roomData.Shape,
									Doors = roomData.Doors
								}				
								if newData then
									desc.Data = newData
									brokenNum = brokenNum + 1
									seed = seed - 1
									level:UpdateVisibility()
									break
								end
							end
						else
							brokenNum = brokenNum + 1
						end

					end
				end
			end
		end

		--每开启一个特殊房间门,获得1碎心
		if brokenNum > 0 then
			player:AddBrokenHearts(brokenNum)
		end		
	end
end
Knock:AddCallback(ModCallbacks.MC_USE_CARD, 'OnUseCard', 6)

--进入红隐时清除4碎心
function Knock:OnNewRoom()
	local room = game:GetRoom()
	if room:GetType() ~= 29 or not room:IsFirstVisit() then return end
	for i = 0, game:GetNumPlayers() - 1 do
		local player = Isaac.GetPlayer(i)
		if player:HasCollectible(self.ID) then
			player:AddBrokenHearts(-5)
		end
	end
end
Knock:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, 'OnNewRoom')

--受伤概率生成教皇卡
function Knock:OnTakeDMG(ent, dmg, flag, source)
	local player = ent:ToPlayer()
	if player and player:HasCollectible(self.ID) then
		local data = self._Players:GetData(player)
		data.KnockCounter = data.KnockCounter or 0
		data.KnockCounter = data.KnockCounter + 1
		
		if data.KnockCounter >= 5 then
			data.KnockCounter = data.KnockCounter - 5
			if player:GetCollectibleRNG(self.ID):RandomInt(100) < 50 then
				local room = game:GetRoom()
				local pos = room:FindFreePickupSpawnPosition(player.Position, 0, true)
				Isaac.Spawn(5, 300, 6, pos, Vector.Zero, nil)		
			end
		end
	end
end
Knock:AddCallback(ModCallbacks.MC_POST_ENTITY_TAKE_DMG, 'OnTakeDMG')

return Knock