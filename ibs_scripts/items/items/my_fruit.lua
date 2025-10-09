--我果

local mod = Isaac_BenightedSoul
local IBS_ItemID = mod.IBS_ItemID
local IBS_PlayerID = mod.IBS_PlayerID

local game = Game()
local sfx = SFXManager()

local MyFruit = mod.IBS_Class.Item(IBS_ItemID.MyFruit)

MyFruit.GiantBookID = Isaac.GetGiantBookIdByName('IBS_MyFruit')

--祝福列表
MyFruit.BlessList = {
	[1] = {zh = '预知祝福...', en = 'Bless of the Foreknown...'},
	[2] = {zh = '光明祝福...', en = 'Bless of the Light...'},
	[3] = {zh = '羽翼祝福...', en = 'Bless of the Wing...', noGreed = true, evaluateCache = true},
	[4] = {zh = '丰收祝福...', en = 'Bless of the Harvest...'},
}

--获取最大充能
function MyFruit:GetMaxCharge(player, slot)
	if player:GetActiveItem(slot) == self.ID then
		--昧化夏娃长子权
		if player:GetPlayerType() == IBS_PlayerID.BEve and player:HasCollectible(619) then
			return 0
		end
		return 8
	end
	return 0
end

--清理房间充能
function MyFruit:Charge()
	local roomDesc = game:GetLevel():GetCurrentRoomDesc()
	
	--检查是否为红房间
	if roomDesc and roomDesc.Flags & RoomDescriptor.FLAG_RED_ROOM > 0 then
		return
	end
	
	for i = 0, game:GetNumPlayers() - 1 do
		local player = Isaac.GetPlayer(i)
		for slot = 0,2 do
			if player:GetActiveItem(slot) == self.ID then
				local charges = self._Players:GetSlotCharges(player, slot, true, true)
				local chargeTimes = (self._Levels:IsInBigRoom() and 2) or 1
				local maxCharges = self:GetMaxCharge(player, slot)
	
				for i = 1,chargeTimes do
					if charges < maxCharges then
						self._Players:ChargeSlot(player, slot, 1, true, true, true)

						--音效
						charges = charges + 1
						if charges == 12 or charges == 24 then
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
MyFruit:AddCallback(ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD, 'Charge')
MyFruit:AddCallback(mod.IBS_CallbackID.GREED_NEW_WAVE, 'Charge') --贪婪模式波次充能

--获取数据
function MyFruit:GetData()
	local data = self:GetIBSData('level')
	data.MyFruitBless = data.MyFruitBless or {}
	return data.MyFruitBless
end

--获取可用祝福总数
function MyFruit:GetAvailableBlessNum()
	local num = #self.BlessList

	--考虑贪婪模式不出现的祝福
	if game:IsGreedMode() then
		for _,v in ipairs(self.BlessList) do
			if v.noGreed then
				num = num - 1
			end
		end
	end

	return num
end

--获取祝福
function MyFruit:GetBless(seed)
	local data = self:GetData()

	--尝试获取不重复值
	local greed = game:IsGreedMode()
	local result = {}
	for bless,v in ipairs(self.BlessList) do
		if (not greed) or not v.noGreed then
			if not data[bless] then
				table.insert(result, bless)
			end
		end
	end
	
	if #result > 0 then
		return result[RNG(seed):RandomInt(1, #result)] or result[1]
	end

	return 0
end

--启用祝福
function MyFruit:EnableBless(bless)
	local data = self:GetData()
	if self.BlessList[bless] then	
		data[bless] = true
		--刷新角色属性
		if self.BlessList[bless].evaluateCache then
			for i = 0, game:GetNumPlayers() - 1 do
				local player = Isaac.GetPlayer(i)
				player:AddCacheFlags(CacheFlag.CACHE_ALL, true)
			end
		end
	end
end

--启用随机祝福
function MyFruit:EnableRandomBless(seed, showText, textDelay)
	local data = self:GetData()
	local bless = self:GetBless(seed)
	if self.BlessList[bless] then
		if showText and not data[bless] then
			if textDelay ~= nil and textDelay > 0 then
				self:DelayFunction(function()
					game:GetHUD():ShowFortuneText(self:ChooseLanguageInTable(self.BlessList[bless]))	
				end, textDelay)
			else			
				game:GetHUD():ShowFortuneText(self:ChooseLanguageInTable(self.BlessList[bless]))	
			end
		end
		data[bless] = true
		
		--刷新角色属性
		if self.BlessList[bless].evaluateCache then
			for i = 0, game:GetNumPlayers() - 1 do
				local player = Isaac.GetPlayer(i)
				player:AddCacheFlags(CacheFlag.CACHE_ALL, true)
			end
		end		
	end
end

--是否有祝福
function MyFruit:HasBless(bless)
	local data = self:GetIBSData('level').MyFruitBless
	if data and data[bless] then
		return true
	end
	return false
end

--是否有所有祝福
function MyFruit:HasAllBlesses()
	local data = self:GetIBSData('level').MyFruitBless
	if data then
		local greed = game:IsGreedMode()
		for bless,v in ipairs(self.BlessList) do
			if (not greed) or not v.noGreed then
				if not data[bless] then
					return false
				end
			end
		end
		return true
	end
	return false	
end

--触发效果
function MyFruit:TriggerEffect(player, playSound, showGiant)
	local level = game:GetLevel()
	local seed = player:GetCollectibleRNG(self.ID):Next()
	self:GetIBSData('level').MyFruitTriggered = true
	
	--移除诅咒并获得一个祝福
	level:RemoveCurses(level:GetCurses())
	self:EnableRandomBless(self._Levels:GetLevelUniqueSeed(), true, (showGiant and 1) or nil)
	
	--排除家层,检测主世界和镜世界
	if level:GetStage() ~= 13 and (level:GetDimension() == 0 or level:GetDimension() == 1) then
		--排除一些房间
		local rooms = self._Levels:GetRooms(function(roomDesc)
			roomDesc.DisplayFlags = 101
			if roomDesc.Data 
				and (not self._Levels:IsMirrorRoom(roomDesc.SafeGridIndex))
				and (not self._Levels:IsMineShaftEntrance(roomDesc.SafeGridIndex))
				and (roomDesc.Data.Type ~= RoomType.ROOM_BOSS and roomDesc.Data.Type ~= RoomType.ROOM_GREED_EXIT)
				and (roomDesc.SafeGridIndex ~= level:GetStartingRoomIndex() or game:IsGreedMode())
			then
				return true
			end
			return false	
		end)

		for _,roomDesc in ipairs(rooms) do
			local roomData = roomDesc.Data
			if roomData then
				local col,row = self._Levels:IndexToColRow(roomDesc.SafeGridIndex)
				local entry = Isaac.LevelGeneratorEntry()
				entry:SetAllowedDoors(roomData.Doors)
				entry:SetColIdx(col)
				entry:SetLineIdx(row)
				
				--缓存原来的门连接
				local cachedDoors = {}
				for doorSlot = 0,7 do
					local gridIdx = roomDesc.Doors[doorSlot]
					if gridIdx >= 0 then
						cachedDoors[doorSlot] = gridIdx
					end
				end
				
				if level:PlaceRoom(entry, roomData, seed) then
					local roomDesc2 = level:GetRoomByIdx(roomDesc.SafeGridIndex)
					
					--设为红房间并揭示位置
					roomDesc2.Flags = roomDesc2.Flags | RoomDescriptor.FLAG_RED_ROOM
					roomDesc2.DisplayFlags = 101
					
					--更新门连接
					for doorSlot,gridIdx in pairs(cachedDoors) do
						roomDesc2.Doors[doorSlot] = gridIdx
					end
				end
			end
		end	
	end

	level:UpdateVisibility()
	
	--播放动画
	if showGiant then	
		ItemOverlay.Show(self.GiantBookID)
	end
	if playSound then
		sfx:Play(266, 0.7, 2, false, 0.7)
	end
end

--使用效果
function MyFruit:OnUse(item, rng, player, flags, slot)

	--检测是否真正持有
	if (slot >= 0 and slot <= 2) and (flags & UseFlag.USE_OWNED > 0) and (flags & UseFlag.USE_VOID <= 0) and (flags & UseFlag.USE_CARBATTERY <= 0) then
		local varData = player:GetActiveItemDesc(slot).VarData
		self:TriggerEffect(player, true, true)
		player:SetActiveVarData(varData+1, slot) --记录使用次数
		
		--昧化夏娃
		if slot == 2 and player:GetPlayerType() == IBS_PlayerID.BEve then
			self:DelayFunction(function()					
				player:SetPocketActiveItem(IBS_ItemID.MyFault, slot, false)
				player:SetActiveVarData(varData+1, slot)
			end, 0)
		else	
			--使用达4次时时移除
			if varData+1 >= 4 then
				return {ShowAnim = true, Remove = true}
			end
		end		
	else
		self:TriggerEffect(player, true)
		return {ShowAnim = true, Remove = true}
	end
	
	return true
end
MyFruit:AddCallback(ModCallbacks.MC_USE_ITEM, 'OnUse', MyFruit.ID)

--设置最大充能
function MyFruit:OnGetMaxCharge(item, player, varData, maxCharge)
	--昧化夏娃长子权
	if player:GetPlayerType() == IBS_PlayerID.BEve and player:HasCollectible(619) then
		return 0
	end
end
MyFruit:AddCallback(ModCallbacks.MC_PLAYER_GET_ACTIVE_MAX_CHARGE, 'OnGetMaxCharge', MyFruit.ID)

--暂停游戏计时
function MyFruit:OnUpdate()
	if self:GetIBSData('level').MyFruitTriggered then
		game.TimeCounter = math.max(30, game.TimeCounter - 1)	
	end
end
MyFruit:AddCallback(ModCallbacks.MC_POST_UPDATE, 'OnUpdate')


--魂火在角色持有道具时不会受伤
function MyFruit:PreWispTakeDMG(ent)
	if ent.Variant ~= FamiliarVariant.WISP then return end
	if ent.SubType ~= self.ID then return end
	local familiar = ent:ToFamiliar(); if not familiar then return end
	local player = familiar.Player or Isaac.GetPlayer(0); if not player then return end
	if player and player:HasCollectible(self.ID) then
		return false
	end
end
MyFruit:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, 'PreWispTakeDMG', EntityType.ENTITY_FAMILIAR)

--祝福效果
do


--生成
local function Spawn(T, V, S)
	local room = game:GetRoom()
	local pos = room:FindFreePickupSpawnPosition((room:GetCenterPos()), 0, true)
	Isaac.Spawn(T, V, S, pos, Vector.Zero, nil)
end

--清理房间触发
function MyFruit:OnRoomCleaned()
	if game:IsGreedMode() then return end
	local rng = self:GetRNG('Pocket_Falsehood_BEve')

	--预知祝福
	if self:HasBless(1) and rng:RandomInt(100) < 50 then
		Spawn(5, 300, rng:RandomInt(1, 22))
	end

	--丰收祝福
	if self:HasBless(4) then
		Isaac.GetPlayer(0):UseActiveItem(476, false, false)
	end	
end
MyFruit:AddCallback(ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD, 'OnRoomCleaned')

--贪婪模式新波次触发
function MyFruit:OnGreedNewWave()
	local rng = self:GetRNG('Pocket_Falsehood_BEve')

	--预知祝福
	if self:HasBless(1) and rng:RandomInt(100) < 25 then
		Spawn(5, 300, rng:RandomInt(1, 22))
	end
	
	--丰收祝福
	if self:HasBless(4) then
		Isaac.GetPlayer(0):UseActiveItem(476, false, false)
	end	
end
MyFruit:AddCallback(mod.IBS_CallbackID.GREED_NEW_WAVE, 'OnGreedNewWave')


--光明祝福
function MyFruit:OnPEffectUpdate(player)
	if self:HasBless(2) then
		local effects = player:GetEffects()
		if not effects:HasNullEffect(60) then
			effects:AddNullEffect(60)
		end
	end
end
MyFruit:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, 'OnPEffectUpdate')

--新层触发
function MyFruit:OnNewLevel()
	
	--硬核清除光明祝福
	for i = 0, game:GetNumPlayers() -1 do
		local player = Isaac.GetPlayer(i)
		player:GetEffects():RemoveNullEffect(60)
	end	
end
MyFruit:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, 'OnNewLevel')

--新房间触发
function MyFruit:OnNewRoom()
	--羽翼祝福
	if self:HasBless(3) then
		local room = game:GetRoom()
		for slot = 0,7 do
			local door = room:GetDoor(slot)
			if door then
				door:Open()
			end
		end
	end
end
MyFruit:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, 'OnNewRoom')

--属性
function MyFruit:OnEvaluateCache(player, flag)
	if self:HasBless(3) then
		if flag & CacheFlag.CACHE_SPEED > 0 then
			self._Stats:Speed(player, 0.3)
		end
	end
end
MyFruit:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, 'OnEvaluateCache')

end


return MyFruit