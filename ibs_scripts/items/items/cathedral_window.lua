--教堂玻璃窗

local mod = Isaac_BenightedSoul

local game = Game()
local conig = Isaac.GetItemConfig()

local CathedralWindow = mod.IBS_Class.Item(mod.IBS_ItemID.CathedralWindow)

--赌博游戏
CathedralWindow.GamblingSlot = {
	[1] = true, --老虎机
	[3] = true, --预言机
	[6] = true, --罐子游戏
	[15] = true, --地狱游戏
	[16] = true, --娃娃机
}

--寻找位置
local function FindPos(gridOrPosition, forcePos)
	local room = game:GetRoom()
	local pos = 1

	if type(gridOrPosition) == "number" then
		if not forcePos then
			pos = room:FindFreePickupSpawnPosition(room:GetGridPosition(gridOrPosition), 0, true)
		else
			pos = room:GetGridPosition(gridOrPosition)
		end
	else
		if not forcePos then
			pos = room:FindFreePickupSpawnPosition(gridOrPosition, 0, true)
		else
			pos = gridOrPosition
		end
	end
	
	return pos
end

--生成
local function Spawn(type, variant, subType, gridOrPosition, forcePos, velocity)
	local pos = FindPos(gridOrPosition, forcePos)
	return Isaac.Spawn(type, variant, subType, pos, velocity or Vector.Zero, nil)
end

--生成障碍物
local function GridSpawn(type, variant, gridOrPosition, forcePos)
	local pos = FindPos(gridOrPosition, forcePos)
	return Isaac.GridSpawn(type, variant, pos, true)
end

--效果
function CathedralWindow:OnNewRoom()
	if not PlayerManager.AnyoneHasCollectible(self.ID) then return end
	local room = game:GetRoom()
	if not room:IsFirstVisit() then return end
	local roomType = room:GetType()
	
	--商店卡牌替换为神圣卡
	if roomType == RoomType.ROOM_SHOP then
		for _,ent in ipairs(Isaac.FindByType(5,300)) do
			local id = ent.SubType
			if id ~= 51 and conig:GetCard(id) and conig:GetCard(id):IsCard() and RNG(ent.InitSeed):RandomInt(100) < 50 then
				ent:ToPickup():Morph(5, 300, 51, true, true, true)
			end
		end
	end

	--宝箱房出现乞丐
	if roomType == RoomType.ROOM_TREASURE then
		Spawn(6, 4, 0, 118)
	end

	--隐藏房店长变为天使雕像
	if roomType == RoomType.ROOM_SECRET then
		for _,ent in ipairs(Isaac.FindByType(17)) do
			local pos = ent.Position
			ent:Remove()
			GridSpawn(21, 1, pos, true)
		end	
	end
	
	--赌博房互动实体变忏悔机
	if roomType == RoomType.ROOM_ARCADE then
		for _,ent in ipairs(Isaac.FindByType(6)) do
			if self.GamblingSlot[ent.Variant] and RNG(ent.InitSeed):RandomInt(100) < 50 then
				local pos = ent.Position
				ent:Remove()
				Spawn(6, 17, 0, pos, true)
			end
		end	
	end

	--诅咒房红箱变白箱
	if roomType == RoomType.ROOM_CURSE then
		for _,ent in ipairs(Isaac.FindByType(5,360,1)) do
			if RNG(ent.InitSeed):RandomInt(100) < 50 then
				ent:ToPickup():Morph(5, 53, 0, true, true, true)
			end
		end		
	end

	--恶魔房道具免费但单选
	if roomType == RoomType.ROOM_DEVIL then
		local newIndex = self._Pickups:GetUniqueOptionsIndex()
		for _,ent in ipairs(Isaac.FindByType(5,100)) do
			if ent.SubType ~= 0 then
				local pickup = ent:ToPickup()
				pickup.Price = 0
				pickup.OptionsPickupIndex = newIndex
			end
		end
	end

end
CathedralWindow:AddPriorityCallback(ModCallbacks.MC_POST_NEW_ROOM, CallbackPriority.LATE, 'OnNewRoom')

--属性改动
function CathedralWindow:OnEvaluateCache(player, flag)	
	if flag == CacheFlag.CACHE_FIREDELAY and player:HasCollectible(self.ID) then
		self._Stats:TearsModifier(player, 0.7)
	end
end
CathedralWindow:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, 'OnEvaluateCache')

--持有玻璃窗时,允许隐藏房的天使掉落钥匙碎片
function CathedralWindow:OnNpcInit(npc)
	if not (npc.Type == 271 or npc.Type == 272) then return end
	if not PlayerManager.AnyoneHasCollectible(self.ID) then return end
	self._Ents:SetKeyPieceAngel(npc)
end
CathedralWindow:AddCallback(ModCallbacks.MC_POST_NPC_INIT, 'OnNpcInit')

return CathedralWindow