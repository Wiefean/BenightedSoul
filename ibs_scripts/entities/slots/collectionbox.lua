--募捐箱

local mod = Isaac_BenightedSoul
local IBS_SlotID = mod.IBS_SlotID

local game = Game()
local sfx = SFXManager()

local CollectionBox = mod.IBS_Class.Slot{
	Variant = IBS_SlotID.CollectionBox.Variant,
	SubType = IBS_SlotID.CollectionBox.SubType,
	Name = {zh = '募捐箱', en = 'Collecttion Box'},
}

--乞丐列表
CollectionBox.BeggerList = {
	4, --普通乞丐
	4, --普通乞丐
	4, --普通乞丐
	7, --钥匙乞丐
	9, --炸弹乞丐
	13, --电池乞丐
}

--移除被破坏时的默认掉落物
function CollectionBox:PreDrop()
	return false
end
CollectionBox:AddCallback(ModCallbacks.MC_PRE_SLOT_CREATE_EXPLOSION_DROPS, 'PreDrop', CollectionBox.Variant)


--一局的数据
function CollectionBox:GetData()
	local data = mod:GetIBSData('temp')
	
	if not data.CollectionBox then
		data.CollectionBox = {
			Coins = 0,
			Luck = 0,
			BeggerSpawned = false,
			CardSpawned = false,
			StairSpawned = false,
		}
	end
	
	return data.CollectionBox
end

--临时数据
function CollectionBox:GetTempData(slot)
	local data = self._Ents:GetTempData(slot)
	
	data.CollectionBox = data.CollectionBox or {
		Level = 0,
		Timeout = 0,
		LastPosition = slot.Position
	}
	
	return data.CollectionBox
end

CollectionBox.CoinToBoxLevel = {
	[0] = 1,
	[3] = 2,
	[10] = 3,
	[24] = 4,
	[52] = 5
}

CollectionBox.BoxLevelToCoin = {
	[1] = 0,
	[2] = 3,
	[3] = 10,
	[4] = 24,
	[5] = 52
}

--获取箱等级
function CollectionBox:GetLevel()
	local data = self:GetData()

	for level = 5,1,-1 do
		if data.Coins >= self.BoxLevelToCoin[level] then
			return level
		end
	end
	
	return 1
end

--更换贴图
local function ChangeSprite(slot, boxLevel)
	local spr = slot:GetSprite()
	local anim = spr:GetAnimation()

	spr:ReplaceSpritesheet(0, "gfx/ibs/items/slots/collectionbox"..boxLevel..".png")
	spr:LoadGraphics()
	spr:Play("Idle")
end

--募捐箱初始化
function CollectionBox:OnSlotInit(slot)
	local tdata = self:GetTempData(slot)
	local boxLevel = self:GetLevel()
	local spr = slot:GetSprite()

	--检查贴图
	if tdata.Level ~= boxLevel then
		tdata.Level = boxLevel
		ChangeSprite(slot, boxLevel)
	end
	
	--调整贴图位置
	slot.SpriteOffset = Vector(0,-2)
end
CollectionBox:AddCallback(ModCallbacks.MC_POST_SLOT_INIT, 'OnSlotInit', CollectionBox.Variant)

--募捐箱更新
function CollectionBox:OnSlotUpdate(slot)
	local tdata = self:GetTempData(slot)
	local boxLevel = self:GetLevel()
	local spr = slot:GetSprite()

	--记录位置
	if slot.FrameCount <= 0 then
		tdata.LastPosition = slot.Position
	end

	if tdata.Level ~= boxLevel then
		tdata.Level = boxLevel
		ChangeSprite(slot, boxLevel)
	end

	if spr:IsFinished("Initiate") then
		spr:Play("Idle")
	end

	if spr:IsFinished("Shield") then
		spr:Play("Idle")
	end

	if spr:IsOverlayPlaying("CoinInsert") and spr:IsEventTriggered("CoinInsert") then
		sfx:Play(SoundEffect.SOUND_COIN_SLOT, 1, 5)
	end


	--被破坏时生成新的
	if slot.GridCollisionClass == 5 then
		local new = Isaac.Spawn(6, self.Variant, 0, tdata.LastPosition, Vector.Zero, nil)
		self:GetTempData(new).Level = boxLevel
		ChangeSprite(new, boxLevel)
		new:GetSprite():Play("Shield", true)
		slot:Remove()
	end	

	if tdata.Timeout > 0 then	
		tdata.Timeout = tdata.Timeout - 1
	else
		spr.PlaybackSpeed = math.min(3.5, 1 + 0.01 * slot:GetTouch()) --调整动画速度
	end
	slot.SizeMulti = Vector(1, 0.5) --椭圆型碰撞体积
end
CollectionBox:AddCallback(ModCallbacks.MC_POST_SLOT_UPDATE, 'OnSlotUpdate', CollectionBox.Variant)

--触碰
function CollectionBox:OnSlotCollision(slot, other)
	local player = other:ToPlayer()
	if not player then return end
	local spr = slot:GetSprite()
	local tdata = self:GetTempData(slot)

	if spr:IsPlaying("Idle") and (player:GetNumCoins() > 0) and tdata.Timeout <= 0 then
		local data = self:GetData()
		local boxLevel = self:GetLevel()
		local room = game:GetRoom()

		player:AddCoins(-1)
		data.Coins = data.Coins + 1
		spr:Play("Initiate", true)
		spr:PlayOverlay("CoinInsert", true)
		
		local chance = math.min(7 + 7 * boxLevel + data.Coins, 250)
		if self:GetRNG('Slot_CollectionBox'):RandomInt(1000) < chance then
			if player:GetBrokenHearts() > 0 then
				player:AddBrokenHearts(-1)
				Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF02, 1, player.Position, Vector.Zero, nil)
				sfx:Play(SoundEffect.SOUND_BLACK_POOF)
			else
				data.Luck = math.min(10, data.Luck + 0.5)
				for i = 0, game:GetNumPlayers() - 1 do
					Isaac.GetPlayer(i):AddCacheFlags(CacheFlag.CACHE_LUCK, true)
				end
			end

			--消灭店长和贪婪
			if boxLevel >= 2 then
				for _,ent in ipairs(Isaac.FindByType(17)) do
					ent:BloodExplode()
					ent:Die()
				end		
				for _,ent in ipairs(Isaac.FindByType(50)) do
					if ent.SubType <= 1 then
						ent:Die()
					end
				end
			end

			--生成乞丐
			if boxLevel >= 3 and not data.BeggerSpawned then
				local variant = self.BeggerList[RNG(self._Levels:GetRoomUniqueSeed()):RandomInt(1, #self.BeggerList)] or 4
				local pos = room:FindFreePickupSpawnPosition(room:GetCenterPos(), 0, true)
				Isaac.Spawn(6, variant, 0, pos, Vector.Zero, nil)
				Isaac.Spawn(1000, EffectVariant.POOF01, 0, pos, Vector.Zero, nil)
				data.BeggerSpawned = true
			end
			
			--生成偷来的一年
			if boxLevel >= 4 and not data.CardSpawned then
				Isaac.Spawn(5, 300, mod.IBS_PocketID.StolenYear, room:FindFreePickupSpawnPosition(slot.Position, 0, true), Vector.Zero, nil)
				data.CardSpawned = true
			end
			
			--生成天梯
			if boxLevel >= 5 and not data.StairSpawned then
				local pos = room:FindFreePickupSpawnPosition(room:GetGridPosition(26))
				Isaac.Spawn(1000, 156, 1, pos, Vector.Zero, nil)
				Isaac.Spawn(1000, EffectVariant.POOF01, 0, pos, Vector.Zero, nil)
				data.StairSpawned = true
			end

			sfx:Play(268)
		end

		--升级时
		if self.CoinToBoxLevel[data.Coins] then
			tdata.Timeout = tdata.Timeout + 15

			--烟雾特效
			for _,ent in pairs(Isaac.FindByType(6, self.Variant, 0)) do
				Isaac.Spawn(1000, EffectVariant.POOF01, 0, ent.Position, Vector.Zero, nil)
			end
		end
	end
end
CollectionBox:AddCallback(ModCallbacks.MC_PRE_SLOT_COLLISION, 'OnSlotCollision', CollectionBox.Variant)


--新房间
function CollectionBox:OnNewRoom()
	local data = self:GetIBSData('temp').CollectionBox
	local room = game:GetRoom()
	local level= game:GetLevel()

	--在商店尝试生成募捐箱
	if self:GetIBSData('persis')['slot_collectionBox'] then
		if self:GetIBSData('persis')["BJudas"].MegaSatan and (room:GetType() == RoomType.ROOM_SHOP) and room:IsFirstVisit() and level:GetCurrentRoomIndex() > 0 then
			local chance = (data and 14 + 7*self:GetLevel()) or 14
			if RNG(self._Levels:GetRoomUniqueSeed()):RandomInt(100) < chance then
				local grid = 117
				if game:IsGreedMode() then grid = 221 end
				Isaac.Spawn(6, self.Variant, 0, room:FindFreePickupSpawnPosition(room:GetGridPosition(grid), 0, true), Vector.Zero, nil)
			end
		end
	end

	--尝试生成天梯
	if data and data.StairSpawned and level:GetCurrentRoomIndex() > 0 and #Isaac.FindByType(6, self.Variant, 0) > 0 then
		local pos = room:FindFreePickupSpawnPosition(room:GetGridPosition(26))
		Isaac.Spawn(1000, 156, 1, pos, Vector.Zero, nil)
	end
end
CollectionBox:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, 'OnNewRoom')

--新层
function CollectionBox:OnNewLevel()
	local data = self:GetIBSData('temp').CollectionBox
	if data then
		data.BeggerSpawned = false
		data.CardSpawned = false
		data.StairSpawned = false
	end
end
CollectionBox:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, 'OnNewLevel')

--属性
function CollectionBox:OnEvaluateCache(player, flag)
	local data = self:GetIBSData('temp').CollectionBox
	if data and flag == CacheFlag.CACHE_LUCK then
		self._Stats:Luck(player, data.Luck)
	end
end
CollectionBox:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, 'OnEvaluateCache')

--忽略除玩家外的碰撞
function CollectionBox:PreSlotCollision(slot, other)
	if not other:ToPlayer() then
		return true
	end
end
CollectionBox:AddCallback(ModCallbacks.MC_PRE_SLOT_COLLISION, 'PreSlotCollision', CollectionBox.Variant)

return CollectionBox