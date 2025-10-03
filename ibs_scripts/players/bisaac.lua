--昧化以撒

local mod = Isaac_BenightedSoul
local CharacterLock = mod.IBS_Achiev.CharacterLock
local IBS_CallbackID = mod.IBS_CallbackID
local IBS_Sound = mod.IBS_Sound

local game = Game()
local sfx = SFXManager()

local BIsaac = mod.IBS_Class.Character(mod.IBS_PlayerID.BIsaac, {
	PocketActive = mod.IBS_ItemID.LightD6,
})


--变身
function BIsaac:Benighted(player, fromMenu)
	if CharacterLock.BIsaac:IsLocked() then return end

	local CAN = false 

	--检测D6
	for slot = 0,1 do
		if player:GetActiveItem(slot) == 105 then
			player:RemoveCollectible(105, true, slot)
			CAN = true
			break
		end	
	end
	if player:GetActiveItem(2) == 105 then CAN = true end
	
	if CAN or fromMenu then
		player:ChangePlayerType(self.ID)
		player:AddSoulHearts(6)
		player:AddMaxHearts(-6)
		player:SetPocketActiveItem(self.Info.PocketActive, ActiveSlot.SLOT_POCKET, false)
		
		--如果完成了对应挑战,生成一个骰子碎片
		if self:GetIBSData('persis')['bc1'] then
			Isaac.Spawn(5, 300, 49, game:GetRoom():FindFreePickupSpawnPosition(player.Position, 0, true), Vector.Zero, nil)
		end

		player:SetColor(Color(1,1,0,0.5,1,1,0), 30, 7, true, false)
		Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, player.Position, Vector.Zero, nil)
	end
end
BIsaac:AddCallback(IBS_CallbackID.BENIGHTED, 'Benighted', PlayerType.PLAYER_ISAAC)



--装扮
local costume_devilBonus = Isaac.GetCostumeIdByPath('gfx/ibs/characters/bisaac_devil.anm2')
local costume_angelBonus = Isaac.GetCostumeIdByPath('gfx/ibs/characters/bisaac_angel.anm2')
local costume_bothBonus = Isaac.GetCostumeIdByPath('gfx/ibs/characters/bisaac_both.anm2')


--获取临时数据
function BIsaac:GetTempData(player)
	local data = self._Ents:GetTempData(player)
	data.BISAAC = data.BISAAC or {
		PlayerMatched = false,
		CostumeState = "none"
	}

	return data.BISAAC
end

--获取数据
function BIsaac:GetData(onlyGet)
	local data = self:GetIBSData('temp')
	
	if not data.BISAAC and not onlyGet then
		data.BISAAC = {
			BonusMode = "none",
			DevilTriggered = false,
			KnifePieceSpawned = false
		}
	end
	
	return data.BISAAC
end

--查看记录
function BIsaac:CheckMode()
	local data = self:GetData()
	return data.BonusMode
end

--更改记录
function BIsaac:ChangeMode(value)
	local data = self:GetData()
	data.BonusMode = value
end


--更新装扮
function BIsaac:UpdateCostume(player)
    local data = self:GetTempData(player)	
    local state = 1

	if player:GetPlayerType() == self.ID then
		if not data.PlayerMatched then data.PlayerMatched = true end
		
		--恶魔/天使奖励装扮
		local mode = self:CheckMode()
		if data.CostumeState ~= mode then
			data.CostumeState = mode
			player:TryRemoveNullCostume(costume_devilBonus)
			player:TryRemoveNullCostume(costume_angelBonus)
			player:TryRemoveNullCostume(costume_bothBonus)
			
			if data.CostumeState == "both" then
				player:AddNullCostume(costume_bothBonus)
			elseif data.CostumeState == "angel" then
				player:AddNullCostume(costume_angelBonus)
			elseif data.CostumeState == "devil" then
				player:AddNullCostume(costume_devilBonus)					
			end
		end
	else
		if data.PlayerMatched then
			data.PlayerMatched = false
			player:TryRemoveNullCostume(costume_devilBonus)
			player:TryRemoveNullCostume(costume_angelBonus)
			player:TryRemoveNullCostume(costume_bothBonus)
		end
	end	
end
BIsaac:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, 'UpdateCostume')

--检查恶魔天使房开启状态
function BIsaac:CheckDAOpen(devil, angel)
	if PlayerManager.AnyoneIsPlayerType(self.ID) and self:CheckMode() == "none" then			
		if devil and angel then
			self:ChangeMode("both")
		elseif devil then
			self:ChangeMode("angel")
		elseif angel then
			self:ChangeMode("devil")
		end	
	end
end
BIsaac:AddCallback(IBS_CallbackID.DEVIL_ANGEL_OPEN_STATE, 'CheckDAOpen')

--长子权检测
function BIsaac:CheckBirthRight()
	for i = 0, game:GetNumPlayers() -1 do
		local player = Isaac.GetPlayer(i)
		if player:GetPlayerType() == self.ID and player:HasCollectible(619) then	
			return true
		end
	end
end

--恶魔房道具数量保底
function BIsaac:DevilCompensation(num)
	local total = 0

	for _,item in pairs(Isaac.FindByType(5, 100)) do
		if item.SubType ~= 0 then
			total = total + 1	
		end
	end
	
	if total < num then
		local seed = self._Levels:GetRoomUniqueSeed()
		local pool = self._Pools:GetRoomPool(seed)

		for i = 1,(num - total) do
			local id = game:GetItemPool():GetCollectible(pool, true, seed)
			local pos = game:GetRoom():FindFreePickupSpawnPosition(game:GetRoom():GetCenterPos(), 0, true)
			local item = Isaac.Spawn(5, 100, id, pos, Vector(0,0), nil):ToPickup()
			item.ShopItemId = -2
			item.Price = -1
		end
	end	
end

--进入恶魔天使房检测
function BIsaac:OnNewRoom()
	local room = game:GetRoom()
	local roomType = room:GetType()
	local devilRoom = roomType == RoomType.ROOM_DEVIL
	local angelRoom = roomType == RoomType.ROOM_ANGEL

	--不在地图内才检测奖励
	if game:GetLevel():GetCurrentRoomIndex() < 0 then
		if (devilRoom or angelRoom) and PlayerManager.AnyoneIsPlayerType(self.ID) then		
			local mode = self:CheckMode()

			if devilRoom then
				if self:GetData().DevilTriggered and room:IsFirstVisit() then
					BIsaac:DevilCompensation((game:IsGreedMode() and 2) or 3)
				end
				if mode == "angel" then
					self:ChangeMode("none")
					sfx:Play(SoundEffect.SOUND_THUMBS_DOWN)
				end
			end

			if angelRoom then
				self:GetData().DevilTriggered = false
				if mode == "devil" then
					self:ChangeMode("none")
					sfx:Play(SoundEffect.SOUND_THUMBS_DOWN)
				end
			end
		end
	elseif not self:CheckBirthRight() then
		--镜子刀把补偿
		local data = self:GetData(true)
		if data and devilRoom then
			if data.DevilTriggered and room:IsFirstVisit() and game:GetLevel():GetDimension() == Dimension.MIRROR then
				if not data.KnifePieceSpawned then
					local pos = room:FindFreePickupSpawnPosition((room:GetCenterPos()), 0, true)
					local pickup = Isaac.Spawn(5, 100, 626, pos, Vector.Zero, nil):ToPickup()
					pickup:Morph(5, 100, 626, true, false, true)
					data.KnifePieceSpawned = true
				end
			end
		end
	end
end
BIsaac:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, 'OnNewRoom')

--长子权恶魔/天使更多选择
function BIsaac:OnPickupFirstAppear(pickup)
	local itemPool = game:GetItemPool()
	local roomType = game:GetRoom():GetType()
	local devilRoom = roomType == RoomType.ROOM_DEVIL
	local angelRoom = roomType == RoomType.ROOM_ANGEL
	
	if (devilRoom or angelRoom) and self:CheckBirthRight() then
		for i = 1,2 do
			local id = itemPool:GetCollectible(self._Pools:GetRoomPool(), true, pickup.InitSeed, 25)
			pickup:AddCollectibleCycle(id)
		end
	end
end
BIsaac:AddCallback(mod.IBS_CallbackID.PICKUP_FIRST_APPEAR, 'OnPickupFirstAppear', 100)

--替换房间
function BIsaac:ReplaceRooms(roomSlot, roomData, seed)
	if PlayerManager.AnyoneIsPlayerType(self.ID) then
		local mode = self:CheckMode()
		local devilBonus = mode == 'devil'
		local angelBonus = mode == 'angel'
		local bothBonus = mode == 'both'
		local birthright = self:CheckBirthRight()

		--贪婪模式
		if game:IsGreedMode() then

			--宝箱房变恶魔房
			if roomSlot:Column() == 7 and roomSlot:Row() == 6 and (devilBonus or bothBonus) then
				local newData = self._Levels:CreateRoomData{
					Seed = seed,
					Type = RoomType.ROOM_DEVIL,
					Shape = roomSlot:Shape(),
					Doors = roomSlot:DoorMask()
				}
				
				if newData then
					return newData
				end
			end

			--诅咒房变天使商店
			if roomSlot:Column() == 5 and roomSlot:Row() == 6 and (angelBonus or bothBonus) then
				--42号蓝火堵门,所以才这么搞
				local newData = {}
				newData[1] = self._Levels:CreateRoomData{
					Seed = seed,
					Type = RoomType.ROOM_ANGEL,
					Shape = roomSlot:Shape(),
					Doors = roomSlot:DoorMask(),
					MinVariant = 40,
					MaxVariant = 41
				}
				newData[2] = self._Levels:CreateRoomData{
					Seed = seed,
					Type = RoomType.ROOM_ANGEL,
					Shape = roomSlot:Shape(),
					Doors = roomSlot:DoorMask(),
					MinVariant = 43,
					MaxVariant = 45
				}				
				
				local key = RNG(seed):RandomInt(1,2)	
				if newData[key] then
					return newData[key]
				else
					local anotherKey = (key == 1 and 2) or (key == 2 and 1)
					if newData[anotherKey] then
						return newData[anotherKey]
					end
				end		
			end
		else --非贪婪模式
			local roomType = roomData.Type
			local devilReplace = RoomType.ROOM_TREASURE
			local angelReplace = RoomType.ROOM_SHOP
		
			--长子权
			if birthright then
				devilReplace = RoomType.ROOM_SECRET
				angelReplace = RoomType.ROOM_SUPERSECRET
			end
		
			--恶魔房替换
			if roomType == devilReplace and (devilBonus or bothBonus) then
				local newData = self._Levels:CreateRoomData{
					Seed = seed,
					Type = RoomType.ROOM_DEVIL,
					Shape = roomSlot:Shape(),
					Doors = roomSlot:DoorMask()
				}
				
				if newData then
					return newData
				end
			end

			--天使商店替换
			if roomType == angelReplace and (angelBonus or bothBonus) then
				local newData = {}
				newData[1] = self._Levels:CreateRoomData{
					Seed = seed,
					Type = RoomType.ROOM_ANGEL,
					Shape = roomSlot:Shape(),
					Doors = roomSlot:DoorMask(),
					MinVariant = 40,
					MaxVariant = 41
				}
				newData[2] = self._Levels:CreateRoomData{
					Seed = seed,
					Type = RoomType.ROOM_ANGEL,
					Shape = roomSlot:Shape(),
					Doors = roomSlot:DoorMask(),
					MinVariant = 43,
					MaxVariant = 45
				}				
				
				local key = RNG(seed):RandomInt(1,2)	
				if newData[key] then
					return newData[key]
				else
					local anotherKey = (key == 1 and 2) or (key == 2 and 1)
					if newData[anotherKey] then
						return newData[anotherKey]
					end
				end		
			end			

		end
	end
end
BIsaac:AddPriorityCallback(ModCallbacks.MC_PRE_LEVEL_PLACE_ROOM, -700, 'ReplaceRooms')


--新层重置奖励模式
function BIsaac:OnNewLevel()
	if PlayerManager.AnyoneIsPlayerType(self.ID) then
		local mode = self:CheckMode()
		local devilBonus = mode == 'devil'
		local angelBonus = mode == 'angel'
		local bothBonus = mode == 'both'
		
		if devilBonus then
			game:AddDevilRoomDeal()
			self:GetData().DevilTriggered = true
		end
		if devilBonus or bothBonus then
			sfx:Play(IBS_Sound.DevilBonus, 0.9)
		end
		if angelBonus or bothBonus then
			self:GetData().DevilTriggered = false
			sfx:Play(IBS_Sound.AngelBonus)
		end
		
		self:ChangeMode('none')
	end
	local data = self:GetData(true)
	if data then
		data.KnifePieceSpawned = false
	end
end
BIsaac:AddPriorityCallback(ModCallbacks.MC_POST_NEW_LEVEL, -700, 'OnNewLevel')

--长子权飞行
function BIsaac:CheckBirthright(player, flag)
	if player:GetPlayerType() == self.ID then
		if player:HasCollectible(619) then	
			if flag == CacheFlag.CACHE_FLYING then
				player.CanFly = true
			end	
		end
	end	
end
BIsaac:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, 'CheckBirthright')

--长子权翅膀装扮
function BIsaac:CheckBirthrightCostume(player)
	if player:GetPlayerType() == self.ID and player:HasCollectible(619) then
		local effect = player:GetEffects()
		if not effect:HasCollectibleEffect(179) then
			effect:AddCollectibleEffect(179, true)
		end	
	end	
end
BIsaac:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, 'CheckBirthrightCostume')


return BIsaac