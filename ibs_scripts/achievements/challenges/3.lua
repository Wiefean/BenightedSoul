--牧地挑战
--(部分效果在对应道具文件里)

local mod = Isaac_BenightedSoul
local IBS_ItemID = mod.IBS_ItemID

local game = Game()
local sfx = SFXManager()

local BC3 = mod.IBS_Class.Challenge(3, {
	PaperNames = {'bcain_babel_up'},
	Destination = 'Foot'
})

--游戏开始
function BC3:OnGameStart(isContinued)
    if not self:Challenging() or isContinued then return end
	Isaac.GetPlayer(0):AddCoins(30)
	Isaac.ExecuteCommand('stage 1')
	Isaac.ExecuteCommand('goto s.arcade.'..'7777')
end
BC3:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, 'OnGameStart')

--角色初始化
function BC3:OnPlayerInit(player)
    if not self:Challenging() then return end
	player:AddCollectible(IBS_ItemID.Goatify, 12)
end
BC3:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, 'OnPlayerInit')


--是否在该挑战房间内
function BC3:IsInRoom()
	if not self:Challenging() then return false end
	local room = game:GetRoom()
	local desc = game:GetLevel():GetCurrentRoomDesc()
	if not desc.Data then return end
	local roomData = desc.Data
	if room:GetType() == 9 and roomData.Variant == 7777 then
		return true
	end
	return false
end	

function BC3:OnNewRoom()
    if not self:IsInRoom() then return end
	local room = game:GetRoom()
	
	--移除门
	for slot = 0,7 do
		room:RemoveDoor(slot)
	end

	if room:IsFirstVisit() then
		local centerPos = room:GetCenterPos()
		
		do --生成小怪异菇
			local pos = centerPos + Vector(-500,-250)
			
			local pickup = Isaac.Spawn(5, 100, 120, pos, Vector.Zero, nil):ToPickup()
			pickup.AutoUpdatePrice = false
			pickup.ShopItemId = -1
			pickup.Price = 30

			--烟雾特效
			Isaac.Spawn(1000, 15, 0, pos, Vector.Zero, nil)
		end
		
		do --生成假币
			local pos = centerPos + Vector(500,-250)
			
			local pickup = Isaac.Spawn(5, 350, 52, pos, Vector.Zero, nil):ToPickup()
			pickup.AutoUpdatePrice = false
			pickup.ShopItemId = -1
			pickup.Price = 99

			--烟雾特效
			Isaac.Spawn(1000, 15, 0, pos, Vector.Zero, nil)
		end	

		do --生成万磁王
			local pos = centerPos + Vector(-500,250)
			
			local pickup = Isaac.Spawn(5, 100, 53, pos, Vector.Zero, nil):ToPickup()
			pickup.AutoUpdatePrice = false
			pickup.ShopItemId = -1
			pickup.Price = 66

			--烟雾特效
			Isaac.Spawn(1000, 15, 0, pos, Vector.Zero, nil)
		end	
		
		do --生成火箭炸弹
			local pos = centerPos + Vector(500,250)
			
			local pickup = Isaac.Spawn(5, 100, 583, pos, Vector.Zero, nil):ToPickup()
			pickup.AutoUpdatePrice = false
			pickup.ShopItemId = -1
			pickup.Price = 30

			--烟雾特效
			Isaac.Spawn(1000, 15, 0, pos, Vector.Zero, nil)
		end			
	end
end
BC3:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, 'OnNewRoom')

--更新
function BC3:OnUpdate()
    if not self:IsInRoom() then return end
	local room = game:GetRoom()
	local centerPos = room:GetCenterPos()
	local coins = Isaac.GetPlayer(0):GetNumCoins()

	--生成炸弹
	if #Isaac.FindByType(5, 40) <= 0 and #Isaac.FindByType(5, 370, 0) <= 0 then
		local pos = centerPos + Vector(-40,0)
		
		local pickup = Isaac.Spawn(5, 40, (coins > 100 and 2) or 1, pos, Vector.Zero, nil):ToPickup()
		pickup.AutoUpdatePrice = false
		pickup.ShopItemId = -1
		pickup.Price = (coins > 100 and 5) or 3

		--烟雾特效
		Isaac.Spawn(1000, 15, 0, pos, Vector.Zero, nil)		
	end	
	
	--生成电池
	if #Isaac.FindByType(5, 90, 1) <= 0 and #Isaac.FindByType(5, 370, 0) <= 0 then
		local pos = centerPos + Vector(40,0)
		
		local pickup = Isaac.Spawn(5, 90, 1, pos, Vector.Zero, nil):ToPickup()
		pickup.AutoUpdatePrice = false
		pickup.ShopItemId = -1
		pickup.Price = 30

		--烟雾特效
		Isaac.Spawn(1000, 15, 0, pos, Vector.Zero, nil)		
	end

	--生成小麦
	if #Isaac.FindByType(5, 100, IBS_ItemID.Wheat) <= (coins // 200) and #Isaac.FindByType(5, 370, 0) <= 0 then
		local width = room:GetGridWidth()
		local height = room:GetGridHeight()
		local x = math.random(1, width-1)
		local y = math.random(1, height-1)
		local gridIndex = x + y * width
		local pos = room:FindFreePickupSpawnPosition(room:GetGridPosition(gridIndex), 0, true)

		local pickup = Isaac.Spawn(5, 100, IBS_ItemID.Wheat, pos, Vector.Zero, nil):ToPickup()
		pickup.AutoUpdatePrice = false
		pickup.ShopItemId = -1
		pickup.Price = 7
		
		--烟雾特效
		Isaac.Spawn(1000, 15, 0, pos, Vector.Zero, nil)
	end
	
	--生成篝火
	if game:GetFrameCount() % 210 == 0 and #Isaac.FindByType(5, 370, 0) <= 0 then
		local width = room:GetGridWidth()
		local height = room:GetGridHeight()
		local x = math.random(1, width-1)
		local y = math.random(1, height-1)
		local gridIndex = x + y * width
		local pos = room:FindFreePickupSpawnPosition(room:GetGridPosition(gridIndex), 0, true)
	
		local pos = room:FindFreePickupSpawnPosition(pos, 0, true)
		Isaac.Spawn(33, math.random(0, 3), 0, pos, Vector.Zero, nil)	
		Isaac.Spawn(1000, 15, 0, pos, Vector.Zero, nil)
	end
	
	--生成面包
	if #Isaac.FindByType(5, 100, IBS_ItemID.Bread) <= 0 and coins >= 150 and #Isaac.FindByType(5, 370, 0) <= 0 then
		local width = room:GetGridWidth()
		local height = room:GetGridHeight()
		local x = math.random(1, width-1)
		local y = math.random(1, height-1)
		local gridIndex = x + y * width
		local pos = room:FindFreePickupSpawnPosition(room:GetGridPosition(gridIndex), 0, true)

		local pickup = Isaac.Spawn(5, 100, IBS_ItemID.Bread, pos, Vector.Zero, nil):ToPickup()
		pickup.AutoUpdatePrice = false
		pickup.ShopItemId = -1
		pickup.Price = 15
		
		--烟雾特效
		Isaac.Spawn(1000, 15, 0, pos, Vector.Zero, nil)
	end

	--生成恶魔山羊
	if game:GetFrameCount() % 180 == 0 and coins >= 300 and #Isaac.FindByType(5, 370, 0) <= 0 then
		local width = room:GetGridWidth()
		local height = room:GetGridHeight()
		local x = math.random(1, width-1)
		local y = math.random(1, height-1)
		local gridIndex = x + y * width
		local pos = room:FindFreePickupSpawnPosition(room:GetGridPosition(gridIndex), 0, true)
	
		local pos = room:FindFreePickupSpawnPosition(pos, 0, true)
		local goat = Isaac.Spawn(891, 1, 0, pos, Vector.Zero, nil)
		goat.MaxHitPoints = goat.MaxHitPoints * math.random(10, 15)
		goat.HitPoints = goat.MaxHitPoints
		--Isaac.Spawn(1000, 15, 0, pos, Vector.Zero, nil)
	end	
	
	--生成坎普斯
	if game:GetFrameCount() % 450 == 0 and coins >= 666 and #Isaac.FindByType(5, 370, 0) <= 0 then
		local width = room:GetGridWidth()
		local height = room:GetGridHeight()
		local x = math.random(1, width-1)
		local y = math.random(1, height-1)
		local gridIndex = x + y * width
		local pos = room:FindFreePickupSpawnPosition(room:GetGridPosition(gridIndex), 0, true)
	
		local pos = room:FindFreePickupSpawnPosition(pos, 0, true)
		local goat = Isaac.Spawn(81, 1, 0, pos, Vector.Zero, nil)
		goat.MaxHitPoints = goat.MaxHitPoints * math.random(6, 10)
		goat.HitPoints = goat.MaxHitPoints
		--Isaac.Spawn(1000, 15, 0, pos, Vector.Zero, nil)
	end		
	
	--生成奖杯
	if coins >= 999 and #Isaac.FindByType(5, 370, 0) <= 0 then
		Isaac.GetPlayer(0):AddCoins(-coins)
		Isaac.Spawn(5, 370, 0, centerPos, Vector.Zero, nil)
		room:MamaMegaExplosion(centerPos)
		
		--移除其他东东
		for _,ent in pairs(Isaac.FindByType(5, 90)) do
			ent:Remove()
		end
		for _,ent in pairs(Isaac.FindByType(5, 40)) do
			ent:Remove()
		end
		for _,ent in pairs(Isaac.FindByType(5, 100)) do
			ent:Remove()
		end
		for _,ent in pairs(Isaac.FindByType(5, 20)) do
			ent:Remove()
		end	
		for _,ent in pairs(Isaac.FindByType(81)) do
			ent:Die()
		end		
		for _,ent in pairs(Isaac.FindByType(891)) do
			ent:Die()
		end
		
		--完成挑战
		if self:IsUnfinished() then
			self:Finish(true, true)
		end
	end
end
BC3:AddCallback(ModCallbacks.MC_POST_UPDATE, 'OnUpdate')

--山羊逻辑
function BC3:OnGoatUpdate(npc)
	if not self:IsInRoom() then return end
	if npc.Variant == 0 then
		local cd = RNG(npc.InitSeed):RandomInt(30,60)
	
		--生成硬币
		if npc:IsFrame(cd,0) then
			Isaac.Spawn(5, 20, 0, npc.Position, RandomVector(), nil)
		end
	
		--受伤
		local cd2 = RNG(npc.InitSeed):RandomInt(30,60)
		if npc:IsFrame(cd2,0) then
			npc:TakeDamage(2 + 0.05 * npc.MaxHitPoints, 0, EntityRef(nil), 0)
		end
	end
end
BC3:AddCallback(ModCallbacks.MC_NPC_UPDATE, 'OnGoatUpdate', 891)

--篝火熄灭时移除底座
function BC3:OnFirePlaceUpdate(npc)
	if not self:IsInRoom() then return end
	if npc.Variant >= 0 and npc.Variant <= 3 and npc.State == 3 then
		npc:Remove()
	end
end
BC3:AddCallback(ModCallbacks.MC_NPC_UPDATE, 'OnFirePlaceUpdate', 33)

--清除掉落物
function BC3:ClearDrop(pickup)
	if not self:IsInRoom() then return end
	local ent = pickup.SpawnerEntity
	if ent then
		if ent.Type == 891 or ent.Type == 81 then
			pickup:Remove()
		end
	end
end
BC3:AddCallback(ModCallbacks.MC_POST_PICKUP_INIT, 'ClearDrop')

return BC3