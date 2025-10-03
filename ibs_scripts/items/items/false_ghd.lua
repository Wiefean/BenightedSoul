--伪造地质学博士证

local mod = Isaac_BenightedSoul

local game = Game()

local FGHD = mod.IBS_Class.Item(mod.IBS_ItemID.FGHD)

--获取数据
function FGHD:GetData(player)
	local data = self._Ents:GetTempData(player)
	data.FGHD = data.FGHD or {dmg = 0}
	return data.FGHD
end

--获得时生成塔
function FGHD:OnGainItem(item, charge, first, slot, varData, player)
	if first then
		local room = game:GetRoom()
		local pos = room:FindFreePickupSpawnPosition(player.Position, 0, true)
		Isaac.Spawn(5, 300, 17, pos, Vector.Zero, nil)
	end
end
FGHD:AddCallback(ModCallbacks.MC_POST_ADD_COLLECTIBLE, 'OnGainItem', FGHD.ID)

--新房间触发
function FGHD:OnNewRoom()
	if not PlayerManager.AnyoneHasCollectible(self.ID) then return end
	local room = game:GetRoom()
	if not room:IsFirstVisit() then return end
	local rng = RNG(self._Levels:GetRoomUniqueSeed())
	
	--普通石头换为刺石头或炸弹石头
	local width = room:GetGridWidth()
	local height = room:GetGridHeight()
	for x = 1, width - 1 do
		for y = 1, height - 1 do
			local gridIndex = x + y * width
			local gridEnt = room:GetGridEntity(gridIndex)
			
			--普通石头,非暗门石头
			if gridEnt and (gridEnt:GetType() == 2) and (gridIndex ~= room:GetDungeonRockIdx()) then
				local new = 5
				if rng:RandomInt(100) < 66 then
					new = new + 20
				end
				room:DestroyGrid(gridIndex, true)
				room:SpawnGridEntity(gridIndex, new, 0, rng:Next(), 0)
			end
		end
	end	
end
FGHD:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, 'OnNewRoom')

--新层清除数据
function FGHD:OnNewLevel()
	for i = 0, game:GetNumPlayers() - 1 do
		local player = Isaac.GetPlayer(i)
		local data = self._Ents:GetTempData(player).FGHD
		if data then
			self._Ents:GetTempData(player).FGHD = nil
			player:AddCacheFlags(CacheFlag.CACHE_DAMAGE, true)
		end
	end	
end
FGHD:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, 'OnNewLevel')


--是否为障碍物
local function IsObstacle(gridType)
	if gridType >= 2 and gridType <= 6 then
		return true
	end
	if gridType == 11 or (gridType >= 22 and gridType <= 27) then
		return true
	end
	return false
end

--摧毁障碍物时触发
function FGHD:OnRockDestory(gridEnt, gridType)
	if not IsObstacle(gridType) then return end
	if not PlayerManager.AnyoneHasCollectible(self.ID) then return end
	local pos = gridEnt.Position
	local rng = Isaac.GetPlayer(0):GetCollectibleRNG(self.ID)

	--概率生成标记石头蜘蛛
	if rng:RandomInt(100) <= 3 then
		local ent = Isaac.Spawn(818, 1, rng:RandomInt(0,3), pos, RandomVector(), nil)
		ent.MaxHitPoints = ent.MaxHitPoints * 2
		ent.HitPoints = ent.MaxHitPoints
	end

	--提升伤害
	for i = 0, game:GetNumPlayers() - 1 do
		local player = Isaac.GetPlayer(i)
		if player:HasCollectible(self.ID) then
			local data = self:GetData(player)
			data.dmg = data.dmg + 0.02
			player:AddCacheFlags(CacheFlag.CACHE_DAMAGE, true)
		end
	end
end
FGHD:AddCallback(ModCallbacks.MC_POST_GRID_ROCK_DESTROY, 'OnRockDestory')

--属性
function FGHD:OnEvaluateCache(player, flag)
	local data = self._Ents:GetTempData(player).FGHD
	if data and flag == CacheFlag.CACHE_DAMAGE and data.dmg > 0 then	
		self._Stats:Damage(player, data.dmg)
	end	
end
FGHD:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, 'OnEvaluateCache')

return FGHD