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

--是否在祸兽房间里
function Levels:IsInBeastBattle()
	local desc = game:GetLevel():GetCurrentRoomDesc()
	local roomData = desc and desc.Data
	
	if roomData and roomData.Type == RoomType.ROOM_DUNGEON and roomData.Subtype == 4 then
		return true
	end

	return false
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
function Levels:IsRoomInMap(roomIdx)
	return (roomIdx >= 0 and roomIdx <= 168)
end

--创造房间数据
function Levels:CreateRoomData(tbl)
	return RoomConfigHolder.GetRandomRoom(
		tbl.Seed or game:GetLevel():GetDungeonPlacementSeed(),
		tbl.ReduceWeight or true,
		tbl.StbType or StbType.SPECIAL_ROOMS,
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

--对于不同形状的房间,可能的相邻房间编号修正对照表
local RoomShapeToNeighborOffsets = {
	[RoomShape.ROOMSHAPE_1x1] = {-1,-13,1,13},
	[RoomShape.ROOMSHAPE_IH] = {-1,1},
	[RoomShape.ROOMSHAPE_IV] = {-13,13},
	[RoomShape.ROOMSHAPE_1x2] = {-1,-13,1,12,14,26},
	[RoomShape.ROOMSHAPE_IIV] = {-13,26},
	[RoomShape.ROOMSHAPE_2x1] = {-1,-13,-12,2,13,14},
	[RoomShape.ROOMSHAPE_IIH] = {-1,2},
	[RoomShape.ROOMSHAPE_2x2] = {-1,-13,-12,2,12,15,26,27},
	[RoomShape.ROOMSHAPE_LTL] = {0,-12,2,12,15,26,27},
	[RoomShape.ROOMSHAPE_LTR] = {-1,-13,1,12,15,26,27},
	[RoomShape.ROOMSHAPE_LBL] = {-1,-13,-12,2,13,15,27},
	[RoomShape.ROOMSHAPE_LBR] = {-1,-13,-12,2,12,14,26},
}

--获取可能的相邻房间编号修正
function Levels:GetRoomNeighborOffsets(roomShape, roomIdx)
	local result = {}

	if RoomShapeToNeighborOffsets[roomShape] then
		for _,offset in ipairs(RoomShapeToNeighborOffsets[roomShape]) do
			if self:IsRoomInMap(roomIdx + offset) then
				table.insert(result, offset)
			end
		end
	end

	return result
end

--获取可能的相邻房间编号
function Levels:GetRoomNeighborIndexes(roomShape, roomIdx)
	local result = {}

	if RoomShapeToNeighborOffsets[roomShape] then
		for _,offset in ipairs(RoomShapeToNeighborOffsets[roomShape]) do
			if self:IsRoomInMap(roomIdx + offset) then
				table.insert(result, roomIdx + offset)
			end
		end
	end

	return result
end


--尝试扩展楼层
--[[
会改变楼层布局,且存在一些不明的bug
"count"表示尝试添加的房间数量,并不一定能全部添加上(成功率跟楼层尽头数量有关)

只能在忏悔龙的"MC_POST_LEVEL_LAYOUT_GENERATED"回调使用
参数"LevelGenerator"也只有那个回调提供

mod:AddCallback(ModCallbacks.MC_POST_LEVEL_LAYOUT_GENERATED, function(_, LevelGenerator)
	Levels:TryExpandLevel(LevelGenerator)
end)

对死寂层及以上使用很可能崩溃,干脆直接排除了
]]
function Levels:TryExpandLevel(LevelGenerator, seed, count)
	if game:IsGreedMode() then return end --贪婪模式
	local level = game:GetLevel(); if level:IsAscent() then return end --回溯线
	local stage = level:GetStage(); if stage >= 9 then return end --死寂层及以上
	seed = seed or self:GetLevelUniqueSeed(); if seed <= 0 then seed = 1 end
	count = count or 1

	local deadEnds = LevelGenerator:GetDeadEnds()
	mod:ShuffleTable(deadEnds, seed) --根据种子为楼层尽头房间打乱排序

	for _,roomSlot in ipairs(deadEnds) do
		local roomIdx = self:ColRowToIndex(roomSlot:Column(), roomSlot:Row())
		
		--排除初始房间
		if roomIdx ~= level:GetStartingRoomIndex() then			
			for _,idx in ipairs(self:GetRoomNeighborIndexes(roomSlot:Shape(), roomIdx)) do		
				local col,row = self:IndexToColRow(idx)
				local success,mes = pcall(LevelGenerator.PlaceRoom, LevelGenerator, col, row, RoomShape.ROOMSHAPE_1x1, roomSlot)
				if success then
					count = count - 1
					break
				end
			end
			if count <= 0 then
				break
			end
		end
		
	end
end


return Levels