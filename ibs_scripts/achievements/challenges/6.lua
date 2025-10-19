--池沼魔谷挑战

local mod = Isaac_BenightedSoul
local IBS_ItemID = mod.IBS_ItemID
local IBS_CallbackID = mod.IBS_CallbackID
local Memories = mod.IBS_Class.Memories()

local game = Game()
local sfx = SFXManager()

local BC6 = mod.IBS_Class.Challenge(6, {
	PaperNames = {'beve_up'},
	Destination = 'Witness'
})

--细节禁goodtrip
mod:AddPriorityCallback(ModCallbacks.MC_POST_MODS_LOADED, CallbackPriority.EARLY, function()
	if gt then
		local oldfn = gt.check_teleble
		function gt:check_teleble(...)
			if BC6:Challenging() and not mod._Debug then
				return false
			end
			return oldfn(self, ...)
		end
	end
end)

--角色初始化
function BC6:OnPlayerInit(player)
	if not self:Challenging() then return end
	player:AddCollectible(IBS_ItemID.Circumcision) --细节割礼加幸运
	player:AddCollectible(IBS_ItemID.RedHook) --红钩,精髓所在
	player:AddSmeltedTrinket(88) --禁主动
	
	--清空装扮,防止看不出角色是谁
	self:DelayFunction2(function()
		if self:Challenging() and not self:IsGameContinued() then
			player:ClearCostumes()
			player:AddNullCostume(84) --头发加回去
		end
	end, 1)		
end
BC6:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, 'OnPlayerInit')

--割血团修改
function BC6:OnPlayerUpdate(player)
	if not self:Challenging() then return end
	if player:GetPlayerType() ~= PlayerType.PLAYER_EVE_B then return end
	if not self._Players:IsShooting(player) then return end
	if not player:IsFrame(1,0) then return end
	
	--boss房或血团小于4个
	if game:GetRoom():GetType() == RoomType.ROOM_BOSS or #Isaac.FindByType(3,238) < 4 then
		player:SetEveSumptoriumCharge(player:GetEveSumptoriumCharge() + 2)
	else	
		player:SetEveSumptoriumCharge(0)
	end
end
BC6:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, 'OnPlayerUpdate')


--获取准备生成的房间类型
function BC6:GetRoomTypeToSpawn(idx)
	local col,row = self._Levels:IndexToColRow(idx)
	
	--最终是boss房
	if idx == 168 then
		return RoomType.ROOM_BOSS
	elseif idx == 155 then --倒数第二个是boss挑战
		return RoomType.ROOM_CHALLENGE
	else		
		--在每一段的末尾放一个宝箱房(想比某汁泽非常仁慈了)
		if col % 2 == 0 then
			if row == 12 then
				return RoomType.ROOM_TREASURE
			end
		else
			if row == 0 then
				return RoomType.ROOM_TREASURE
			end	
		end
	end
	
	return RoomType.ROOM_DEFAULT
end

--获取允许开门的位置
function BC6:GetRoomDoorsToSpawn(idx)
	local col,row = self._Levels:IndexToColRow(idx)
	local doors = {
		[DoorSlot.UP0] = true,
		[DoorSlot.DOWN0] = true,
	}

	--在每一段的开头开左门,末尾开右门
	if col % 2 == 0 then
		if row == 0 then
			doors[DoorSlot.LEFT0] = true
		end
		if row == 12 then
			doors[DoorSlot.RIGHT0] = true
		end
	else
		if row == 0 then
			doors[DoorSlot.RIGHT0] = true
		end	
		if row == 12 then
			doors[DoorSlot.LEFT0] = true
		end		
	end
	
	return doors
end

--相邻房间行列位置修正对照表
local neighborOffsets = {
	[DoorSlot.LEFT0] = {-1,0},
	[DoorSlot.UP0] = {0,-1},
	[DoorSlot.RIGHT0] = {1,0},
	[DoorSlot.DOWN0] = {0,1},
}

--表示所有门位置
local allDoors = (1<<0) | (1<<1) |(1<<2) |(1<<3)

--生成楼层
function BC6:GenerateLevel()
	local level = game:GetLevel()

	local rng = RNG(self._Levels:GetLevelUniqueSeed())
	for idx = 0,168 do
		local seed = rng:Next()
		local col,row = self._Levels:IndexToColRow(idx)
		local entry = Isaac.LevelGeneratorEntry()
		entry:SetAllowedDoors(allDoors)
		entry:SetColIdx(col)
		entry:SetLineIdx(row)
		
		local roomType = self:GetRoomTypeToSpawn(idx)
		local isBoss = (roomType == RoomType.ROOM_BOSS)
		local roomData = self._Levels:CreateRoomData{
			Seed = seed,
			Type = roomType,
			MinVariant = (isBoss and 2010) or nil,
			MaxVariant = (isBoss and 2018) or nil,
			SubType = (roomType == RoomType.ROOM_CHALLENGE and 1) or -1,
			Shape = 1,
			Doors = allDoors,
		}
		
		if roomData and level:PlaceRoom(entry, roomData, seed) then
			local roomDesc = level:GetRoomByIdx(idx)
			if roomDesc then
				--更新门连接
				for doorSlot,_ in pairs(self:GetRoomDoorsToSpawn(idx)) do
					local offsets = neighborOffsets[doorSlot]
					if offsets and self._Levels:IsRoomInMap(col + offsets[1], row + offsets[2]) then		
						roomDesc.Doors[doorSlot] = idx + offsets[1] + 13*offsets[2]
					end
				end
			end
		end		
	end
end

--游戏开始
function BC6:OnNewLevel()
    if not self:Challenging() then return end
	local level = game:GetLevel()
	
	--传送到尸宫并设置地图
	if level:GetStage() ~= 8 and level:GetStageType() ~= 4 then
		Isaac.ExecuteCommand('stage 8c')
	elseif level:GetStage() == 8 and level:GetStageType() == 4 then
		self:GenerateLevel()
		game:StartRoomTransition(0, -1, RoomTransitionAnim.MAZE)
		Isaac.GetPlayer(0):AddGoldenKey() --金钥匙
	end
end
BC6:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, 'OnNewLevel')

function BC6:OnNpcInit(ent)
	if not self:Challenging() then return end
	local bossRoom = (game:GetRoom():GetType() == RoomType.ROOM_BOSS)

	--苍蝇公爵
	if ent.Type == 67 and ent.Variant == 0 and bossRoom then
		--固定绿色变种
		if ent.SubType ~= 1 then
			Isaac.Spawn(67,0,1, ent.Position, Vector.Zero, nil)
			ent:Remove()
		end
		ent.MaxHitPoints = ent.MaxHitPoints * 66
		ent.HitPoints = ent.MaxHitPoints
	else
		--替换红苍蝇
		if ent.Type == 18 and ent.Variant == 0 and ent.SubType == 0 and bossRoom then
			local int = RNG(ent.InitSeed):RandomInt(100)
			if int < 2 then
				--绿炸弹苍蝇
				Isaac.Spawn(25,5,0, ent.Position, Vector.Zero, nil)
			elseif (int >= 2 and int < 10) then
				--母体苍蝇
				Isaac.Spawn(61,4,0, ent.Position, Vector.Zero, nil)
			else
				--吸电苍蝇
				Isaac.Spawn(61,5,0, ent.Position, Vector.Zero, nil)
			end	
			ent:Remove()
		end
		ent.MaxHitPoints = ent.MaxHitPoints * 6
		ent.HitPoints = ent.HitPoints * 6
	end
end
BC6:AddCallback(ModCallbacks.MC_POST_NPC_INIT, 'OnNpcInit')


--新房间触发
function BC6:OnNewRoom()
	if not self:Challenging() then return end
	local room = game:GetRoom()
	local level = game:GetLevel()
	
	--原初始房间生成假床
	if level:GetCurrentRoomIndex() == level:GetStartingRoomIndex() then
		if room:IsFirstVisit() then		
			local pos = room:GetGridPosition(70)
			local pickup = Isaac.Spawn(5,380,1, pos, Vector.Zero, nil):ToPickup()
			pickup:Morph(5,380,1, true, true, true)
			pickup.Touched = true
		end
		for _,ent in pairs(Isaac.FindByType(5,380,1)) do		
			ent:GetSprite():ReplaceSpritesheet(0, 'gfx/items/pick ups/isaacbed_barren.png', true)
		end
	end
	
	
	--boss挑战门前检测
	if level:GetCurrentRoomIndex() == 142 then
		--保释卡偷懒
		Isaac.GetPlayer(0):UseCard(47, UseFlag.USE_NOANIM | UseFlag.USE_NOANNOUNCER | UseFlag.USE_MIMIC)
		sfx:Stop(156)
		sfx:Stop(204)
	end
	
	--boss门检测
	local door = room:GetDoor(DoorSlot.DOWN0)
	if door and door.TargetRoomIndex == 168 then
		local locked = true
		local roomDesc = game:GetLevel():GetRoomByIdx(155)
		
		--boss挑战打完或第六次进入时开启
		if roomDesc then
			if (roomDesc.Flags & RoomDescriptor.FLAG_CHALLENGE_DONE > 0) then
				locked = false
			end
			if roomDesc.VisitedCount >= 6 then
				locked = false
			end
			if roomDesc.VisitedCount == 6 then
				for _,ent in pairs(Isaac.FindByType(5)) do
					ent:Remove()
				end
				--生成气消床
				local pickup = Isaac.Spawn(5,380,0, room:GetCenterPos(), Vector.Zero, nil):ToPickup()
				pickup:Morph(5,380,0, true, true, true)
			end			
		end
		
		if locked then
			room:RemoveDoor(DoorSlot.DOWN0)
		end
	end
end
BC6:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, 'OnNewRoom')

--细节假床
function BC6:OnPickupCollision(pickup, other)
	if not self:Challenging() then return end
	if pickup.SubType ~= 1 then return end
	if pickup.Wait > 0 then return end
	local level = game:GetLevel(); if level:GetCurrentRoomIndex() ~= level:GetStartingRoomIndex() then return end
	local player = other:ToPlayer(); if not player then return end
	ItemOverlay.Show(33)
	self:DelayFunction2(function()
		game:StartRoomTransition(0, -1, RoomTransitionAnim.MAZE)
	end, 120)
	pickup.Wait = 30
end
BC6:AddCallback(ModCallbacks.MC_POST_PICKUP_COLLISION, 'OnPickupCollision', 380)

--气消奖励
function BC6:BONUS()
	local room = game:GetRoom()
	local pos = room:GetGridPosition(70)
	local pickup = Isaac.Spawn(5,380,0, pos, Vector.Zero, nil):ToPickup()
	pickup:Morph(5,380,0, true, true, true)
	room:MamaMegaExplosion(pos)
end

--完成
function BC6:TryFinish()
	if not self:Challenging() then return end
	local room = game:GetRoom()
	if room:GetType() == RoomType.ROOM_BOSS then
		if self:IsUnfinished() then		
			self:Finish(true, true)
		end
		self:BONUS()
		Isaac.Spawn(5,370,0, room:GetCenterPos(), Vector.Zero, nil)
	end
end
BC6:AddCallback(ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD, 'TryFinish')




--美心改动,要先楞一会儿再回血
do

function BC6:PreUseItem(item, rng, player, flag, slot)
	if not self:Challenging() then return end
	local owned = (flag & UseFlag.USE_OWNED > 0) and (flag & UseFlag.USE_CARBATTERY <= 0)

	if owned then
		if self._Players:IsHoldingItem(player) then
			--硬核兼容,抵消原来的消耗充能
			self._Players:ChargeSlot(player, slot, player:GetActiveMaxCharge(slot))
		else		
			self._Players:TryHoldItem(item, player, flag, slot)
		end
	end
	
	return true
end
BC6:AddCallback(ModCallbacks.MC_PRE_USE_ITEM, 'PreUseItem', 45)

--握住判定
function BC6:OnTryHold(item, player, flag, slot, holdingItem)
	local canHold = (holdingItem <= 0) and (flag & UseFlag.USE_CARBATTERY <= 0) and (flag & UseFlag.USE_VOID <= 0)
	return {
		CanHold = canHold,
		Timeout = 60
	}
end
BC6:AddCallback(IBS_CallbackID.TRY_HOLD_ITEM, 'OnTryHold', 45)

--结束握住
function BC6:OnHoldEnd(item, player, flag, slot, byActive, byTimeout, byHurt, byNewRoom)
	if not self:Challenging() then return end
	if not byTimeout then return end

	--车载电池
	if player:HasCollectible(356) then
		player:AddHearts(4)
	else
		player:AddHearts(2)
	end
	sfx:Play(SoundEffect.SOUND_VAMP_GULP)
end
BC6:AddCallback(IBS_CallbackID.HOLD_ITEM_END, 'OnHoldEnd', 45)

end

return BC6