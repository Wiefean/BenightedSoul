--银之钥

local mod = Isaac_BenightedSoul
local IBS_CallbackID = mod.IBS_CallbackID

local game = Game()
local sfx = SFXManager()

local SilverKey = mod.IBS_Class.Item(mod.IBS_ItemID.SilverKey)

--可记录的房间类型(右边的值为动画帧数)
local RoomTypeList = {
	[RoomType.ROOM_MINIBOSS] = 0,
	[RoomType.ROOM_TREASURE] = 1,
	[RoomType.ROOM_PLANETARIUM] = 2,
	[RoomType.ROOM_LIBRARY] = 3,
	[RoomType.ROOM_SHOP] = 4,
	[RoomType.ROOM_CURSE] = 5,
	[RoomType.ROOM_SACRIFICE] = 6,
	[RoomType.ROOM_ARCADE] = 7,
	[RoomType.ROOM_CHEST] = 8,
	[RoomType.ROOM_DICE] = 9,
	[RoomType.ROOM_ISAACS] = 10,
	[RoomType.ROOM_BARREN] = 11,
	[RoomType.ROOM_SECRET] = 12,
	[RoomType.ROOM_SUPERSECRET] = 13,
	[RoomType.ROOM_ULTRASECRET] = 14,
	-- [RoomType.ROOM_DEVIL] = 15, --犹大长子权才能记录
	-- [RoomType.ROOM_ANGEL] = 16, --美德书才能记录
}

--获取可记录的房间类型
function SilverKey:GetCanRecoredList()
	local list = {}
	for roomType,anim in pairs(RoomTypeList) do
		list[roomType] = anim
	end
	
	--犹大长子权可记录恶魔房
	if PlayerManager.AnyoneHasCollectible(59) then
		list[RoomType.ROOM_DEVIL] = 15
	end
	
	--美德书可记录天使房
	if PlayerManager.AnyoneHasCollectible(584) then
		list[RoomType.ROOM_ANGEL] = 16
	end
	
	return list
end

--获取数据
function SilverKey:GetData()
	local data = self:GetIBSData('temp')
	data.SilverKey = data.SilverKey or {
		Type = 0,
		Variant = 0,
		SubType = 0,
		Shape = 0,
		Doors = 0,
		Difficulty = 0,
		Mode = 0,

		Time = game.TimeCounter,
		Ban = 0,
	}
	return data.SilverKey
end

--是否可以重设房间
function SilverKey:CanResetRoom(roomDesc)
	local level = game:GetLevel()
	
	--检测楼层和维度
	if (level:GetStage() == 13) or (level:GetDimension() ~= 0 and level:GetDimension() ~= 1) then
		return false
	end
	
	local data = self:GetData(); if data.Type <= 0 then return false end
	
	--排除一些房间
	if not roomDesc.Data then return false end
	if roomDesc.GridIndex < 0 then return false end
	if roomDesc.SafeGridIndex == level:GetStartingRoomIndex() then return false end
	if roomDesc.Data.Type == RoomType.ROOM_BOSS then return false end
	if roomDesc.Data.Type == RoomType.ROOM_GREED_EXIT then return false end
	if self._Levels:IsMirrorRoom(roomDesc.SafeGridIndex) then return false end
	if self._Levels:IsMineShaftEntrance(roomDesc.SafeGridIndex) then return false end

	--检查准备重设的房间门位置和形状是否吻合
	if (roomDesc.Data.Shape == data.Shape) and (roomDesc.Data.Doors >= data.Doors) then
		return true
	end

	return false
end

--清理房间充能
function SilverKey:Charge()
	for i = 0, game:GetNumPlayers() - 1 do
		local player = Isaac.GetPlayer(i)
		for slot = 0,2 do
			if player:GetActiveItem(slot) == self.ID then
				local charges = self._Players:GetSlotCharges(player, slot, true, true)
				local chargeTimes = (self._Levels:IsInBigRoom() and 2) or 1
	
				for i = 1,chargeTimes do
					if charges < 8 then
						self._Players:ChargeSlot(player, slot, 1, true, true, true)

						--音效
						charges = charges + 1
						if charges == 4 or charges == 8 then
							sfx:Play(SoundEffect.SOUND_BATTERYCHARGE)					
						else
							sfx:Play(SoundEffect.SOUND_BEEP)
						end
					end
				end
			end
		end
	end	
end
SilverKey:AddCallback(ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD, 'Charge')
SilverKey:AddCallback(IBS_CallbackID.GREED_NEW_WAVE, 'Charge') --贪婪模式波次充能

--使用
function SilverKey:OnUse(item, rng, player, flag, slot)
	local level = game:GetLevel()
	
	--贪婪模式,不在主世界或镜世界
	if game:IsGreedMode() or (level:GetDimension() ~= 0 and level:GetDimension() ~= 1) then
		return {ShowAnim = false, Discharge = false}
	end

	if (flag & UseFlag.USE_OWNED > 0) and (flag & UseFlag.USE_CARBATTERY <= 0) and (flag & UseFlag.USE_VOID <= 0) then
		local room = game:GetRoom()
		local data = self:GetData()
		local list = self:GetCanRecoredList()
		
		--记录当前房间类型和当前时间
		if data.Type <= 0 then
			local roomType = room:GetType()
			local roomDesc = game:GetLevel():GetCurrentRoomDesc()
			local roomData = (roomDesc and roomDesc.Data) or nil
			if list[roomType] and roomData then
				data.Type = roomType
				data.Variant = roomData.Variant
				data.SubType = roomData.Subtype
				data.Shape = roomData.Shape
				data.Doors = roomData.Doors
				data.Difficulty = roomData.Difficulty
				data.Mode = roomData.Mode
				
				data.Time = game.TimeCounter
				data.Ban = roomType
				return true
			else
				sfx:Play(187, 1, 30) --失败提示音
			end
		else
			local door = self._Finds:ClosestDoor(player.Position)

			--将普通房间变为记录的房间类型,并回溯时间
			if door and door.TargetRoomIndex and door.Position:Distance(player.Position) <= 70 then
				local roomDesc = level:GetRoomByIdx(door.TargetRoomIndex)
				if roomDesc ~= nil and roomDesc.Data ~= nil and self:CanResetRoom(roomDesc) then
					local roomData = roomDesc.Data
					local seed = rng:Next()
					local newData = self._Levels:CreateRoomData{
						Seed = seed,
						ReduceWeight = false,
						Type = data.Type,
						MinVariant = data.Variant,
						MaxVariant = data.Variant,
						SubType = data.SubType,
						MinDifficulty = data.Difficulty,
						MaxDifficulty = data.Difficulty,
						Mode = data.Mode,
						Shape = roomData.Shape,
						Doors = roomData.Doors
					}
					
					if newData and self._Levels:ResetRoom(roomDesc, newData, seed) then
						data.Type = 0
						game.TimeCounter = data.Time

						--开门
						door:SetLocked(false)
						door:Open()

						--缓存位置
						for i = 0, game:GetNumPlayers() -1 do
							local player = Isaac.GetPlayer(i)
							self._Players:CachePosition(player)
						end

						--原地传送以刷新状态
						local dir = self._Maths:VectorToDirection((door.Position - player.Position):Normalized())
						game:StartRoomTransition(level:GetCurrentRoomIndex(), dir, RoomTransitionAnim.MAZE, player)

						--举起道具动画
						self:DelayFunction(function()
							player:AnimateCollectible(self.ID)
						end, 1)

						return {ShowAnim = false, Discharge = true}
					else
						sfx:Play(187, 1, 30) --失败提示音
					end
				else
					sfx:Play(187, 1, 30) --失败提示音
				end
			end
		end
	end	
	return {ShowAnim = false, Discharge = false}
end
SilverKey:AddCallback(ModCallbacks.MC_USE_ITEM, 'OnUse', SilverKey.ID)


--新层将曾经记录过的特殊房间变为普通房间
function SilverKey:OnNewLevel()
	if game:IsGreedMode() then return end
	local data = self:GetIBSData('temp').SilverKey
	if not data then return end

	local level = game:GetLevel()
	if not self:IsStartingRun() then --非新开一局
		local rooms = self._Levels:GetRooms(function(desc)
			if desc and desc.Data and desc.Data.Type == data.Ban then
				return true
			end
			return false
		end)

		local rng = RNG(level:GetDungeonPlacementSeed())

		for _,roomDesc in ipairs(rooms) do
			local roomData = roomDesc.Data
			if roomData then
				local newData = self._Levels:CreateRoomData{
					Type = 1,
					StbType = self._Levels:GetStbType(rng),
					Shape = roomData.Shape,
					Doors = roomData.Doors,
				}				
				if newData then
					roomDesc.Data = newData
					level:UpdateVisibility()
				end
			end
		end
	end
end
SilverKey:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, 'OnNewLevel')


--进入三种隐藏房时自动开门(防卡关)
function SilverKey:OnNewRoom()
	if not PlayerManager.AnyoneHasCollectible(self.ID) then return end
	local room = game:GetRoom()
	local roomType = room:GetType()
	if roomType == 7 or roomType == 8 or roomType == 29 then
		for slot = 0,7 do
			local door = room:GetDoor(slot)
			if door then
				door:SetLocked(false)
				door:Open()
			end
		end
	end
end
SilverKey:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, 'OnNewRoom')


local spr = Sprite('gfx/ibs/ui/items/the_silver_key.anm2')
spr:Play('Idle')

--渲染
function SilverKey:OnActiveRender(player, slot, offset, alpha, scale)
	if player:GetActiveItem(slot) ~= self.ID then return end
	local data = mod:GetIBSData("temp").SilverKey
	if data then
		local list = self:GetCanRecoredList()
		if list[data.Type] ~= nil then
			spr:SetFrame(list[data.Type])
			spr.Scale = Vector(scale, scale)
			
			local color = Color(1,1,1,alpha)
			color:SetColorize(1,1,1,1)
			spr.Color = color
			
			spr:Render(offset + Vector(16*scale,10*scale))
		else
			data.Type = 0
		end
	end
end
SilverKey:AddCallback(ModCallbacks.MC_POST_PLAYERHUD_RENDER_ACTIVE_ITEM, 'OnActiveRender')


return SilverKey