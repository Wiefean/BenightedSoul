--墓地

local mod = Isaac_BenightedSoul
local IBS_PlayerID = mod.IBS_PlayerID

local game = Game()

local minVariant = 7254
local maxVariant = 7265

local Variants = {}
for i = minVariant,maxVariant do
	table.insert(Variants, i)
end

local Graveyard = mod.IBS_Class.Rooms{
	Type = RoomType.ROOM_SUPERSECRET,
	Variants = Variants
}

Graveyard.MinVariant = minVariant
Graveyard.MaxVariant = maxVariant

--奖励列表
Graveyard.BonusList = {
	"Item",
	"ShopItem",
	"CurseItem",
	"Trinket",
	"Chest",
	"Chest",
}

--箱子列表
Graveyard.ChestList = {
	PickupVariant.PICKUP_CHEST,
	PickupVariant.PICKUP_LOCKEDCHEST,
	PickupVariant.PICKUP_REDCHEST,
	PickupVariant.PICKUP_OLDCHEST,
}

--生成掉落物
local function SpawnPickup(V, S, pos)
	local pickup = Isaac.Spawn(5, V, S, pos, 0.01 * math.random(100, 200) * RandomVector(), nil):ToPickup()
	pickup.Wait = 60
	return pickup
end

--尝试添加骨头环绕物
function Graveyard:TryAddBoneOrbital(player, pos)
	local num = 0

	for _,ent in ipairs(Isaac.FindByType(3, 128)) do
		local familiar = ent:ToFamiliar()
		if familiar and self._Ents:IsTheSame(familiar.Player, player) then
			num = num + 1
			if num >= 6 then
				return false
			end
		end
	end
	
	if num < 6 then
		player:AddBoneOrbital(pos)
		return true
	end
	
	return false
end

--尝试生成奖励
function Graveyard:TryBonus(effect, player)
	if effect and effect.State == 0 then
		effect.State = 1
		
		local pos = effect.Position
		local seed = effect.InitSeed
		local rng = RNG(seed)		
		
		--镜世界不生成道具
		if game:GetRoom():IsMirrorWorld() then
			--昧化遗骸补偿菜刀碎片
			if PlayerManager.AnyoneIsPlayerType(IBS_PlayerID.BForgotten)
				and not self:GetIBSData("level").ROOM_GRAVEYARD_KNIFE_PIECE
			then			
				self:GetIBSData("level").ROOM_GRAVEYARD_KNIFE_PIECE = true
				local pickup = SpawnPickup(100, 626, pos)
				pickup:Morph(5, 100, 626, false, true, true)
			else
				--箱子
				local variant = self.ChestList[rng:RandomInt(1,#self.ChestList)] or PickupVariant.PICKUP_CHEST
				if variant == PickupVariant.PICKUP_CHEST then
					SpawnPickup(variant, 0, pos)
				else
					SpawnPickup(variant, 1, pos)
				end
			end
		else
			local itemPool = game:GetItemPool()
			local result = self.BonusList[rng:RandomInt(1,#self.BonusList)] or "Chest"
			
			if result == "Item" then
				--宝箱房道具
				local id = itemPool:GetCollectible(ItemPoolType.POOL_TREASURE, true, seed)
				SpawnPickup(100, id, pos)
			elseif result == "ShopItem" then
				--商店道具
				local id = itemPool:GetCollectible(ItemPoolType.POOL_SHOP, true, seed)
				local pickup = SpawnPickup(100, id, pos)
				pickup.ShopItemId = -1
				pickup.Price = 1
			elseif result == "CurseItem" then
				--诅咒房道具
				local id = itemPool:GetCollectible(ItemPoolType.POOL_CURSE, true, seed)
				local pickup = SpawnPickup(100, id, pos)
				pickup.ShopItemId = -2
				pickup.Price = -1
			elseif result == "Trinket" then
				--饰品
				local id = itemPool:GetTrinket()
				SpawnPickup(350, id, pos)
				
				--完成挑战后同时生成箱子
				if self:GetIBSData('persis')['bc15'] then
					local variant = self.ChestList[rng:RandomInt(1,#self.ChestList)] or PickupVariant.PICKUP_CHEST
					if variant == PickupVariant.PICKUP_CHEST then
						SpawnPickup(variant, 0, pos)
					else
						SpawnPickup(variant, 1, pos)
					end
				end
			else
				--箱子
				local variant = self.ChestList[rng:RandomInt(1,#self.ChestList)] or PickupVariant.PICKUP_CHEST
				if variant == PickupVariant.PICKUP_CHEST then
					SpawnPickup(variant, 0, pos)
				else
					SpawnPickup(variant, 1, pos)
				end
			end
		end
		
		
		--骨头环绕物
		if player then
			self:TryAddBoneOrbital(player, pos)
		end
		
		return true
	end
	
	return false
end

--自动挖坟
function Graveyard:OnPlayerUpdate(player)
	if not self:IsInRoom() then return end
	if not player:IsFrame(15,0) then return end
	
	local pos = player.Position
	local ent = self._Finds:ClosestEntity(pos, 1000, 116, 0, function(ent)
		local effect = ent:ToEffect()
		if effect and effect.State == 0 and effect.Position:Distance(pos) < 70 then
			return true
		end
	end)
	
	local effect = (ent and ent:ToEffect())
	if effect then
		self:TryBonus(effect, player)
	end
end
Graveyard:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, 'OnPlayerUpdate', 0)

--魂心概率变腐心
function Graveyard:OnPickupInit(pickup)
	if not self:IsInRoom() then return end
	if (pickup.SubType == 3 or pickup.SubType == 8) and RNG(pickup.InitSeed):RandomInt(100) < 34 then
		pickup:Morph(5, 10, 12, true, true)
		return true
	end
end
Graveyard:AddCallback(ModCallbacks.MC_POST_PICKUP_INIT, 'OnPickupInit', 10)

--替换房间
function Graveyard:ReplaceRooms(roomSlot, roomData, seed)
	--昧化遗骸,替换商店宝箱房和诅咒房
	if PlayerManager.AnyoneIsPlayerType(IBS_PlayerID.BForgotten) or self:GetBenightedRun() == IBS_PlayerID.BForgotten then
		--贪婪模式
		if game:IsGreedMode() then
			if (roomSlot:Column() == 7 and roomSlot:Row() == 6)
				or (roomSlot:Column() == 5 and roomSlot:Row() == 6)
			then
				local newData = self._Levels:CreateRoomData{
					ReduceWeight = false,
					Seed = seed,
					Type = RoomType.ROOM_SUPERSECRET,
					MinVariant = self.MinVariant,
					MaxVariant = self.MaxVariant,
					Shape = roomSlot:Shape(),
					Doors = roomSlot:DoorMask()
				}
				seed = math.max(1, seed - 1)
				if newData then
					return newData
				end
			end
		else --非贪婪模式
			local roomType = roomData.Type
		
			if roomType == RoomType.ROOM_SHOP or roomType == RoomType.ROOM_TREASURE or roomType == RoomType.ROOM_CURSE then
				local newData = self._Levels:CreateRoomData{
					ReduceWeight = false,
					Seed = seed,
					Type = RoomType.ROOM_SUPERSECRET,
					MinVariant = self.MinVariant,
					MaxVariant = self.MaxVariant,
					Shape = roomSlot:Shape(),
					Doors = roomSlot:DoorMask()
				}
				seed = math.max(1, seed - 1)
				if newData then
					return newData
				end
			end
		end
		return
	end

	--没有解锁时尽量避免生成墓地
	if not self:GetIBSData('persis')["BForgotten"].MegaSatan then
		if roomData.Type == RoomType.ROOM_SUPERSECRET then	
			local variant = roomData.Variant
			if variant >= self.MinVariant and variant <= self.MaxVariant then
				local newData = self._Levels:CreateRoomData{
					Seed = seed,
					Type = RoomType.ROOM_SUPERSECRET,
					Shape = roomSlot:Shape(),
					Doors = roomSlot:DoorMask()
				}

				if newData then
					return newData
				end
			end
		end
	end
end
Graveyard:AddPriorityCallback(ModCallbacks.MC_PRE_LEVEL_PLACE_ROOM, -500, 'ReplaceRooms')

--测试用,生成房间
-- function Graveyard:TryGenerate()
	-- local level = game:GetLevel()
	-- local seed = level:GetDungeonPlacementSeed()
	-- local roomData = self._Levels:CreateRoomData{
		-- Seed = seed,
		-- Type = RoomType.ROOM_SUPERSECRET,
		-- MinVariant = minVariant,
		-- MaxVariant = maxVariant,
		-- SubType = 16,
	-- }
	-- if roomData then
		-- for _,gridIndex in pairs(level:FindValidRoomPlacementLocations(roomData)) do
			-- if level:TryPlaceRoom(roomData, gridIndex, -1, seed) then
				-- break
			-- end
		-- end
	-- end
-- end
-- Graveyard:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, 'TryGenerate')

return Graveyard