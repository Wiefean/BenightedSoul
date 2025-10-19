--楼层相关函数

local mod = Isaac_BenightedSoul
local Ents = mod.IBS_Lib.Ents

local Levels = {}

local game = Game()

--获取楼层独特种子(利用楼层和楼层种类数值上的差异不同且恒定的特性)
--[[
用此函数设置种子的RNG,应该用"RandomInt"而不应该用"RandomFloat"获取随机数,
因为"RandomFloat"在种子差异较小的情况下获取的随机数差异也较小
]]
function Levels:GetLevelUniqueSeed()
	local level = game:GetLevel()
	return game:GetSeeds():GetStartSeed() - level:GetStage() - level:GetStageType()
end

--获取房间独特种子(利用楼层和楼层种类数值以及房间号数上的差异不同且恒定的特性)
--[[
用此函数设置种子的RNG,应该用"RandomInt"而不应该用"RandomFloat"获取随机数,
因为"RandomFloat"在种子差异较小的情况下获取的随机数差异也较小
]]
function Levels:GetRoomUniqueSeed()
	local level = game:GetLevel()
	return game:GetSeeds():GetStartSeed() - level:GetStage() - level:GetStageType() - level:GetCurrentRoomIndex()
end

--是否在大房间里
function Levels:IsInBigRoom()
	local shape = game:GetRoom():GetRoomShape()
	return (shape >= 8 and shape <= 12)
end

--是否为镜子房
function Levels:IsMirrorRoom(roomIdx)
	local level = game:GetLevel()
	if level:HasMirrorDimension() then
		local roomDesc = level:GetRoomByIdx(roomIdx)
		local roomData = (roomDesc and roomDesc.Data) or nil
		if roomData and roomData.Type == RoomType.ROOM_DEFAULT and roomData.Subtype == RoomSubType.DOWNPOUR_MIRROR then
			return true
		end
	end
	return false
end

--是否为矿坑逃亡入口
function Levels:IsMineShaftEntrance(roomIdx)
	local level = game:GetLevel()
	if level:HasAbandonedMineshaft() then
		local roomDesc = level:GetRoomByIdx(roomIdx)
		local roomData = (roomDesc and roomDesc.Data) or nil
		if roomData and roomData.Type == RoomType.ROOM_DEFAULT and roomData.Subtype == RoomSubType.MINES_MINESHAFT_ENTRANCE then
			return true
		end
	end
	return false
end

--是否在祸兽房间里
function Levels:IsInBeastBattle()
	local roomDesc = game:GetLevel():GetCurrentRoomDesc()
	local roomData = (roomDesc and roomDesc.Data) or nil
	
	if roomData and roomData.Type == RoomType.ROOM_DUNGEON and roomData.Subtype == RoomSubType.CRAWLSPACE_BEAST then
		return true
	end

	return false
end

--获取可用的房间门位置(主要用于生成红房间)
function Levels:GetRoomDoorSlots(roomIdx)
	local level = game:GetLevel()
	local room = game:GetRoom()
	local result = {}
	
	local desc = level:GetRoomByIdx(roomIdx)
	if desc and desc.Data then
		local doors = desc.Data.Doors
		for slot = 0,7 do 
			if doors & (1 << slot) > 0 then
				table.insert(result, slot)
			end
		end
	end
	
	return result
end

--获取当前房间门空位(主要用于生成红房间)
function Levels:GetCurrentRoomSpareDoorSlots()
	local level = game:GetLevel()
	local room = game:GetRoom()
	local result = {}
	
	local desc = level:GetCurrentRoomDesc()
	if desc and desc.Data then
		local doors = desc.Data.Doors
		for slot = 0,7 do 
			if doors & (1 << slot) > 0 and room:GetDoor(slot) == nil then
				table.insert(result, slot)
			end
		end
	end
	
	return result
end


do

local shouldQuit = false

--退出游戏自动离开测试房间(-3为测试房间的编号,可能会用于模组的额外房间)
function Levels:QuitDebugRoomWhenExit()
	shouldQuit = true
end

--退出游戏时自动传回初始房间
mod:AddCallback(ModCallbacks.MC_PRE_GAME_EXIT, function()
	local level = game:GetLevel()
	if level:GetCurrentRoomIndex() == -3 and shouldQuit then
		game:ChangeRoom(level:GetStartingRoomIndex(), 0)
	end
	shouldQuit = false
end)

--非测试房间自动重置
mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, function()
	local level = game:GetLevel()
	if level:GetCurrentRoomIndex() ~= -3 then
		shouldQuit = false
	end
end)

end

--获取楼层内符合条件的房间信息
--[[
"condition"是一个带参数"RoomDescriptor"的函数,
需返回true或false,示例:

function condition(roomDesc)
	if roomDesc.Data and roomDesc.Data.Type == RoomType.ROOM_SHOP then
		return true
	end
	return false
end
]]
function Levels:GetRooms(condition)
	local rooms = game:GetLevel():GetRooms()
	local cache = {}
	local result = {}

	for i = 0, rooms.Size - 1 do
		local desc = rooms:Get(i)
		if desc and desc.SafeGridIndex and not cache[desc.SafeGridIndex] then 
			cache[desc.SafeGridIndex] = true
			if condition == nil or condition(desc) then
				table.insert(result, game:GetLevel():GetRoomByIdx(desc.SafeGridIndex))
			end
		end
	end

	return result
end

--房间索引转列行(列行取值范围为0~12)
function Levels:IndexToColRow(roomIdx)
    local column = (roomIdx) % 13
    local row = math.floor(roomIdx/13)
    return column,row
end

--列行转房间索引(列行取值范围为0~12)
function Levels:ColRowToIndex(col, row)
    return col + 13*row
end

--是否为地图内的房间索引
function Levels:IsRoomInMap(col, row)
	return (col >= 0 and col <= 12) and (row >= 0 and row <= 12)
end

--获取当前楼层类型(主要用于获取普通房间)
function Levels:GetStbType(rng)
	local id = Isaac:GetCurrentStageConfigId()

	--虚空或家层改为随机(不包含支线)
	if id == StbType.THE_VOID or id == StbType.HOME then
		local rng = rng or RNG(self:GetRoomUniqueSeed())
		return rng:RandomInt(1,17)
	end

	return id
end

--创造房间数据
function Levels:CreateRoomData(tbl)
	local seed = tbl.Seed or game:GetLevel():GetDungeonPlacementSeed()
	local stbType = tbl.StbType
	
	--自动修正
	if not stbType and tbl.Type then
		if tbl.Type == RoomType.ROOM_DEFAULT then		
			stbType = self:GetStbType(RNG(seed))
		else
			stbType = StbType.SPECIAL_ROOMS
		end
	end

	return RoomConfigHolder.GetRandomRoom(
		seed,
		tbl.ReduceWeight or true,
		stbType,
		tbl.Type,
		tbl.Shape or RoomShape.ROOMSHAPE_1x1,
		tbl.MinVariant or 0, 
		tbl.MaxVariant or -1,
		tbl.MinDifficulty or 0,
		tbl.MaxDifficulty or 20,
		tbl.Doors or 0,
		tbl.SubType or -1,
		tbl.Mode or -1
	)
end

--重设房间
--(允许的门位置与房间形状最好要与原来一致)
function Levels:ResetRoom(roomDesc, newData, seed)
	local col,row = self:IndexToColRow(roomDesc.GridIndex)
	local entry = Isaac.LevelGeneratorEntry()
	entry:SetAllowedDoors(roomDesc.AllowedDoors)
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

	local level = game:GetLevel()
	if level:PlaceRoom(entry, newData, seed) then
		local newDesc = level:GetRoomByIdx(roomDesc.SafeGridIndex)
		if newDesc then		
			--更新门连接
			for doorSlot,gridIdx in pairs(cachedDoors) do
				newDesc.Doors[doorSlot] = gridIdx
			end
			return newDesc
		end
	end
end

--将特殊房间类型翻译为控制台指令(用于goto指令)
local RoomTypeToCMD = {
	[RoomType.ROOM_SHOP] = 'shop',
	[RoomType.ROOM_ERROR] = 'error',
	[RoomType.ROOM_TREASURE] = 'treasure',
	[RoomType.ROOM_BOSS] = 'boss',
	[RoomType.ROOM_MINIBOSS] = 'miniboss',
	[RoomType.ROOM_SECRET] = 'secret',
	[RoomType.ROOM_SUPERSECRET] = 'supersecret',
	[RoomType.ROOM_ARCADE] = 'arcade',
	[RoomType.ROOM_CURSE] = 'curse',
	[RoomType.ROOM_CHALLENGE] = 'challenge',
	[RoomType.ROOM_LIBRARY] = 'library',
	[RoomType.ROOM_SACRIFICE] = 'sacrifice',
	[RoomType.ROOM_DEVIL] = 'devil',
	[RoomType.ROOM_ANGEL] = 'angel',
	[RoomType.ROOM_BOSSRUSH] = 'bossrush',
	[RoomType.ROOM_ISAACS] = 'isaacs',
	[RoomType.ROOM_BARREN] = 'barren',
	[RoomType.ROOM_CHEST] = 'chest',
	[RoomType.ROOM_DICE] = 'dice',
	[RoomType.ROOM_BLACK_MARKET] = 'blackmarket',
	[RoomType.ROOM_PLANETARIUM] = 'planetarium',
	[RoomType.ROOM_ULTRASECRET] = 'ultrasecret',
}
function Levels:RoomTypeToCMD(roomType)
	return RoomTypeToCMD[roomType]
end

--获取StageAPI自定义楼层的原楼层
local function GetStageApiBaseStage(name)
	local level = game:GetLevel()
	local stage = level:GetStage()
	local stageType = level:GetStageType()

	for k,v in pairs(StageAPI.CustomStages) do
		if k ~= name and
			v.XLStage and v.XLStage.Name and v.XLStage.Name == name and
			v.Replaces and v.Replaces.OverrideStage == stage and v.Replaces.OverrideStageType == stageType
		then
			return v
		end
	end

	return nil
end

--用于控制台指令的楼层代号
local StageTypeToCMD = {
	[StageType.STAGETYPE_WOTL] = 'a',
	[StageType.STAGETYPE_AFTERBIRTH] = 'b',
	[StageType.STAGETYPE_REPENTANCE] = 'c',
	[StageType.STAGETYPE_REPENTANCE_B] = 'd'
}

--重载楼层(硬核)
function Levels:Reload()
	if StageAPI and StageAPI.Loaded and StageAPI.CurrentStage and StageAPI.CurrentStage.Name and not StageAPI.CurrentStage.NormalStage then
		local currentStage = GetStageApiBaseStage(StageAPI.CurrentStage.Name) or StageAPI.CurrentStage
		StageAPI.GotoCustomStage(currentStage, false, true)
	else
		local level = game:GetLevel()
		local stage = tostring(level:GetStage())
		local letter = StageTypeToCMD[level:GetStageType()]
		if letter then
			stage = stage .. letter
		end
		Isaac.ExecuteCommand('stage '..stage)
	end
end

return Levels