--不懂节制

local mod = Isaac_BenightedSoul
local Stats = mod.IBS_Lib.Stats

local game = Game()

local NoTemperance = mod.IBS_Class.Item(mod.IBS_ItemID.NoTemperance)

--赌博游戏
NoTemperance.GamblingSlot = {
	[1] = true, --老虎机
	[3] = true, --预言机
	[6] = true, --罐子游戏
	[15] = true, --地狱游戏
	[16] = true, --娃娃机
}


function NoTemperance:GetData()
	local data = self:GetIBSData('temp')

	if not data.NoTemperance then
		data.NoTemperance = {
			SlotRecord = {},
			RoomRecord = {},
			PersisStatsNum = 0
		}
	end
	
	return data.NoTemperance
end

--记录赌博游戏
function NoTemperance:OnSlotUpdate(slot)
	if not self._Players:AnyHasCollectible(self.ID) then return end
	local variant = slot.Variant
	local condition = self.GamblingSlot[variant]
	if condition == nil then return end
	if (type(condition) == "function") and not condition(slot) then return end

	local data = self:GetData()
	local spr = slot:GetSprite()
	local seed = tostring(slot.InitSeed)
	local needRefresh = false
	
	if data.SlotRecord[seed] == nil then
		data.SlotRecord[seed] = true
		needRefresh = true
	end

	if spr:IsPlaying("Initiate") or spr:IsPlaying("PayShuffle") then
		data.SlotRecord[seed] = false
		needRefresh = true
	end
	
	if needRefresh then
		for i = 0, Game():GetNumPlayers() -1 do
			local player = Isaac.GetPlayer(i)
			player:AddCacheFlags(CacheFlag.CACHE_ALL, true)
		end	
	end
end
NoTemperance:AddCallback(ModCallbacks.MC_POST_SLOT_UPDATE, 'OnSlotUpdate')

--记录赌博房
function NoTemperance:OnNewRoom()
	self:DelayFunction(function()
		local room = game:GetRoom()
		local level = game:GetLevel()
		local needRefresh = false
		
		if self._Players:AnyHasCollectible(self.ID) then 
			local data = self:GetData()
		
			for i = 0, DoorSlot.NUM_DOOR_SLOTS - 1 do
				local door = room:GetDoor(i)
				if door ~= nil then
					local idx = door.TargetRoomIndex
					local roomData = level:GetRoomByIdx(idx).Data
					if roomData and roomData.Type == RoomType.ROOM_ARCADE then
						idx = tostring(idx)
						if data.RoomRecord[idx] == nil then
							data.RoomRecord[idx] = true
							needRefresh = true
						end
					end
				end
			end	
		end

		do
			local data = mod:GetIBSData('temp').NoTemperance
			if data and room:GetType() == RoomType.ROOM_ARCADE then
				local idx = tostring(level:GetCurrentRoomIndex())
				if data.RoomRecord[idx] then needRefresh = true end
				data.RoomRecord[idx] = false
			end
		end	
		
		if needRefresh then
			for i = 0, game:GetNumPlayers() -1 do
				local player = Isaac.GetPlayer(i)
				player:AddCacheFlags(CacheFlag.CACHE_ALL, true)
			end	
		end
	end, 1)
end
NoTemperance:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, 'OnNewRoom')

--进入新层整理数据
function NoTemperance:OnNewLevel()
	local data = mod:GetIBSData('temp').NoTemperance
	if data then
		for k,available in pairs(data.SlotRecord) do
			if available then
				data.PersisStatsNum = data.PersisStatsNum + 1
			end
			data.SlotRecord[k] = nil
		end
		for k,available in pairs(data.RoomRecord) do
			if available then
				data.PersisStatsNum = data.PersisStatsNum + 4
			end
			data.RoomRecord[k] = nil
		end
		
		if data.PersisStatsNum < 0 then data.PersisStatsNum = 0 end
		
		--刷新角色属性
		for i = 0, Game():GetNumPlayers() -1 do
			local player = Isaac.GetPlayer(i)
			player:AddCacheFlags(CacheFlag.CACHE_ALL, true)
		end
	end
end
NoTemperance:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, 'OnNewLevel')

--属性
function NoTemperance:OnEvaluateCache(player, flag)
	local data = mod:GetIBSData('temp').NoTemperance
	
	if data then
		local num = data.PersisStatsNum

		for _,available in pairs(data.SlotRecord) do
			if available then
				num = num + 1
			end
		end
		
		for _,available in pairs(data.RoomRecord) do
			if available then
				num = num + 4
			end
		end
		
		if flag == CacheFlag.CACHE_SPEED then
			Stats:Speed(player, 0.02*num)
		end
		if flag == CacheFlag.CACHE_DAMAGE then
			Stats:Damage(player, 0.15*num)
		end
		if flag == CacheFlag.CACHE_LUCK then
			Stats:Luck(player, 0.25*num)
		end		
		if flag == CacheFlag.CACHE_SHOTSPEED then
			Stats:ShotSpeed(player, -0.02*num)
		end
	end
end
NoTemperance:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, 'OnEvaluateCache')


return NoTemperance