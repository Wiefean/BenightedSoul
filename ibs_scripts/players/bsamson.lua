--昧化参孙
--(部分效果在架势道具文件)

local mod = Isaac_BenightedSoul
local IBS_PlayerID = mod.IBS_PlayerID
local IBS_ChallengeID = mod.IBS_ChallengeID
local IBS_CallbackID = mod.IBS_CallbackID
local IBS_TrinketID = mod.IBS_TrinketID
local IBS_Sound = mod.IBS_Sound
local CharacterLock = mod.IBS_Achiev.CharacterLock
local Damage = mod.IBS_Class.Damage()

local game = Game()
local config = Isaac.GetItemConfig()
local sfx = SFXManager()

local BSamson = mod.IBS_Class.Character(IBS_PlayerID.BSamson, {
	BossIntroName = 'bsamson',
	PocketActive = mod.IBS_ItemID.Posture,
})

--获取牌组(数据由架势道具保存)
function BSamson:GetPostureCards(player)
	return mod.IBS_Item.Posture:GetData(player).Cards
end

--获取卡牌选择
function BSamson:GetPostureDoingSel(player)
	return mod.IBS_Item.Posture:GetData(player).DoingSelection
end

--获取下一张卡牌选择
function BSamson:GetPostureNextSel(player)
	return mod.IBS_Item.Posture:GetData(player).NextSelection
end

--获取牌组贴图(数据由架势道具保存)
function BSamson:GetPostureCardsSprite(player)
	return mod.IBS_Item.Posture:GetTempData(player).List
end

--变身
function BSamson:Benighted(player, fromMenu)
	local CAN = false
	
	--检测嗜血
	if player:HasCollectible(157) then	
		for slot = 0,1 do
			if player:GetTrinket(slot) == 34 then
				player:TryRemoveTrinket(34)
				break
			end
		end
		player:RemoveCollectible(157, true)
		CAN = true
	end

	if CAN or fromMenu then
		player:ChangePlayerType(IBS_PlayerID.BSamson)
		player:SetPocketActiveItem(self.Info.PocketActive, ActiveSlot.SLOT_POCKET, false)
		game:GetItemPool():RemoveCollectible(252) --小药袋移出道具池

		--初始架势给愚者
		self:GetPostureCards(player)[1] = 1
		mod.IBS_Item.Posture:RefreshList(player)
		
		player:AnimateCollectible(mod.IBS_ItemID.Posture, "Pickup")
		
		--如果完成了对应挑战,生成倒卡
		if self:GetIBSData('persis')['bc7'] then
			local room = game:GetRoom()
			local rng = RNG(self._Levels:GetRoomUniqueSeed())
			local pos = room:FindFreePickupSpawnPosition(player.Position, 0, true)
			Isaac.Spawn(5, 300, rng:RandomInt(56,77), pos, Vector.Zero, nil)		
		end
		
		if not fromMenu then		
			sfx:Play(128)
		end
	end	
end
BSamson:AddCallback(IBS_CallbackID.BENIGHTED, 'Benighted', PlayerType.PLAYER_SAMSON)

--生成塔罗牌
local function SpawnTarot()
	local room = game:GetRoom()
	local rng = RNG(BSamson._Levels:GetRoomUniqueSeed())
	local pos = room:FindFreePickupSpawnPosition(room:GetCenterPos(), 0, true)
	local card = 1

	--如果完成了对应挑战,正卡和倒卡会交替生成
	if mod:GetIBSData('persis')['bc7'] and Isaac.GetChallenge() ~= IBS_ChallengeID[7] then
		local data = mod:GetIBSData("temp")
		if data.LastBSamsonBossBonus then
			data.LastBSamsonBossBonus = nil
			card = rng:RandomInt(56,77)
		else
			card = rng:RandomInt(1,22)
			data.LastBSamsonBossBonus = true
		end
	else
		if rng:RandomInt(100) < 50 then
			card = rng:RandomInt(1,22)
		else
			card = rng:RandomInt(56,77)
		end
	end
	
	return Isaac.Spawn(5, 300, card, pos, Vector.Zero, nil)
end

--清理boss房
function BSamson:OnRoomCleaned()
	if game:GetRoom():GetType() == RoomType.ROOM_BOSS and PlayerManager.AnyoneIsPlayerType(self.ID) then
		SpawnTarot()
	end
end
BSamson:AddCallback(ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD, 'OnRoomCleaned')

--boss波次
function BSamson:OnWaveEndState(state)
	if not PlayerManager.AnyoneIsPlayerType(self.ID) then return end
	if state == 2 and PlayerManager.AnyoneIsPlayerType(self.ID) then
		SpawnTarot()
	end
end
BSamson:AddCallback(mod.IBS_CallbackID.GREED_WAVE_END_STATE, 'OnWaveEndState')


BSamson.Calm = 0
BSamson.Wrath = 1
BSamson.CamlSheild = 90 --平静护盾持续时间
BSamson.WrathDuration = 1000 --暴怒持续时间

--是否持有牌
function BSamson:HasCard(player, id)
	return mod.IBS_Item.Posture:HasCard(player, id)
end

--获取牌数量
function BSamson:GetCardNum(player, id)
	return mod.IBS_Item.Posture:GetCardNum(player, id)
end

--获取平静护盾持续时间
function BSamson:GetCalmSheildDuration(player)
	local frames = self.CamlSheild

	--倒皇帝
	if self:HasCard(player, 60) then
		frames = frames - 30
	end

	--倒恶魔
	if self:HasCard(player, 71) then
		frames = frames + 15 * self:GetCardNum(player, 71)
	end

	return frames
end

--平静护盾
function BSamson:ApplyCalmSheild(player)
	local frames = self:GetCalmSheildDuration(player)	

	--倒皇帝
	if self:HasCard(player, 60) then
		--倒教皇
		if self:HasCard(player, 61) then
			player:SetMinDamageCooldown(player:GetDamageCooldown() + 2 * frames)
		else
			self._Players:AddShield(player, frames)
		end
	else
		--倒教皇
		if self:HasCard(player, 61) then			
			player:SetMinDamageCooldown(2 * frames)
		else
			local effects = player:GetEffects()
			local shield = effects:GetCollectibleEffect(CollectibleType.COLLECTIBLE_BOOK_OF_SHADOWS)
			if not shield then
				effects:AddCollectibleEffect(CollectibleType.COLLECTIBLE_BOOK_OF_SHADOWS)
				shield = effects:GetCollectibleEffect(CollectibleType.COLLECTIBLE_BOOK_OF_SHADOWS)
				shield.Cooldown = 0
			end
			if shield.Cooldown <= 0 then			
				shield.Cooldown = frames
			end
		end
	end
end

--获取暴怒持续时间
function BSamson:GetMaxWrathDuration(player)
	local frames = self.WrathDuration

	--倒恶魔
	if self:HasCard(player, 71) then
		frames = 500
	end

	return frames
end

--获取数据
function BSamson:GetData(player)
	local data = self._Players:GetData(player)
	
	data.BSamson = data.BSamson or {
		State = self.Calm,
		WrathDuration = self.WrathDuration,
		Standing = 0,
	}
	
	return data.BSamson
end

--进入游戏
function BSamson:OnGameStarted()
	for i = 0, game:GetNumPlayers() - 1 do
		local player = Isaac.GetPlayer(i)
		if player:GetPlayerType() == self.ID then
			mod.IBS_Item.Posture:RefreshList(player)
		end
	end
end
BSamson:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, "OnGameStarted")

--检测姿态
function BSamson:GetState(player)
	if player:GetPlayerType() == self.ID then
		return self:GetData(player).State
	else	
		return -1
	end
end

--切换姿态
function BSamson:ChangeState(player, newState)
	local data = self:GetData(player)
	local state = self.Calm
	
	--挑战特殊规则,永久暴怒
	if Isaac.GetChallenge() == IBS_ChallengeID[7] then
		newState = self.Wrath
	end
	
	--刷新暴怒持续时间
	if data.State == self.Wrath and newState == self.Wrath then
		data.WrathDuration = self:GetMaxWrathDuration(player)
		sfx:Play(592, 0.5, 10)
	end
	
	if data.State ~= newState then	
		if data.State == self.Calm then
			state = self.Wrath
			data.WrathDuration = self:GetMaxWrathDuration(player)
			sfx:Play(592, 0.5, 10)
		end
		if data.State == self.Wrath then
			state = self.Calm
			self:ApplyCalmSheild(player) --进入平静获得护盾
			sfx:Play(594, 0.5, 10)
		end
		
		data.State = state
		player:AddCacheFlags(CacheFlag.CACHE_DAMAGE, true)
	end
	
end

--切换至相反姿态
function BSamson:SwitchState(player)
	local data = self:GetData(player)
	if data.State == self.Calm then
		self:ChangeState(player, self.Wrath)
	elseif data.State == self.Wrath then
		self:ChangeState(player, self.Calm)
	end
end

--角色更新
function BSamson:OnPlayerUpdate(player)

	--对于其他角色,清除姿态相关数据
	if player:GetPlayerType() ~= self.ID then
		if self._Players:GetData(player).BSamson then
			self._Players:GetData(player).BSamson = nil
		end
		return
	end
	
	local data = self:GetData(player)
	
	--禁用其他饰品
	for slot = 0,1 do
		local id = player:GetTrinket(slot)
		if id > 0 and id ~= IBS_TrinketID.SamsonState then
			player:TryRemoveTrinket(id)
		end
	end
	
	--添加特殊饰品
	if not player:HasTrinket(IBS_TrinketID.SamsonState, true) then
		player:AddTrinket(IBS_TrinketID.SamsonState, false)
	end
	
	--暴怒
	if self:GetState(player) == self.Wrath then
		--站立计时
		if player.Velocity:Length() > 1 then
			data.Standing = 0
		else
			data.Standing = data.Standing + 1
		end
	
		--倒节制,挑战特殊规则,永久暴怒
		if self:HasCard(player, 70) or Isaac.GetChallenge() == IBS_ChallengeID[7] then
			data.WrathDuration = 280
		else		
			--计时
			if data.WrathDuration > 0 then
				local tick = (data.Standing > 70 and 5) or 1
			
				for i = 1,tick do
					data.WrathDuration = data.WrathDuration - 1
					
					--即将结束提示
					if data.WrathDuration == 70 or data.WrathDuration == 140 or data.WrathDuration == 210 then
						sfx:Play(IBS_Sound.SamsonWrathTick)
					end
				end
			else
				self:ChangeState(player, self.Calm)
			end
		end
	else
		--挑战特殊规则,永久暴怒
		if Isaac.GetChallenge() == IBS_ChallengeID[7] then
			self:ChangeState(player, self.Wrath)
		end
	end
end
BSamson:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, 'OnPlayerUpdate', 0)

--不能拿饰品和药丸
function BSamson:PrePickupCollision(pickup, other)
	local player = other:ToPlayer()
	if player and player:GetPlayerType() == self.ID then
		return false
	end	
end
BSamson:AddPriorityCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, 1000, 'PrePickupCollision', 70)
BSamson:AddPriorityCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, 1000, 'PrePickupCollision', 350)

--不能拿卡
function BSamson:PreCardCollision(pickup, other)
	local player = other:ToPlayer()
	if player and player:GetPlayerType() == self.ID then
		local id = pickup.SubType
	
		--允许买卡
		if pickup.Price ~= 0 and ((id >=1 and id <= 22) or (id >= 56 and id <= 77)) then
			
		else		
			return false
		end
	end	
end
BSamson:AddPriorityCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, 1000, 'PreCardCollision', 300)

--自动掉落拾取的口袋物品
function BSamson:OnAddPocketItem(player)
	if player:GetPlayerType() == self.ID then	
		for slot = 0,3 do
			player:DropPocketItem(slot, player.Position)
		end
	end
end
BSamson:AddPriorityCallback(ModCallbacks.MC_POST_PLAYER_ADD_CARD, 1000, 'OnAddPocketItem')
BSamson:AddPriorityCallback(ModCallbacks.MC_POST_PLAYER_ADD_PILL, 1000, 'OnAddPocketItem')

--双击切换姿态(仅限测试模式)
function BSamson:OnDoubleTap(player, type, action)
	if mod._Debug then	
		if (type == 2) and (action == ButtonAction.ACTION_DROP) and player:GetPlayerType() == self.ID then
			self:SwitchState(player)
		end
	end
end
BSamson:AddCallback(mod.IBS_CallbackID.DOUBLE_TAP, 'OnDoubleTap')

--暴怒伤害翻倍
function BSamson:OnEvalueateCache(player, flag)
	if flag == CacheFlag.CACHE_DAMAGE
		and player:GetPlayerType() == self.ID
		and self:GetState(player) == self.Wrath
		and not self:HasCard(player, 59) --倒皇后
	then
		player.Damage = player.Damage * 2
	end	
end
BSamson:AddPriorityCallback(ModCallbacks.MC_EVALUATE_CACHE, 100, 'OnEvalueateCache')

--暴怒受伤翻倍
function BSamson:PreTakeDMG(ent, dmg, flag, source, cd)
	if dmg <= 0 then return end
	local player = ent:ToPlayer()

	if player 
		and player:GetPlayerType() == self.ID 
		and self:GetState(player) == self.Wrath
		and not self:HasCard(player, 59) --倒皇后
		and Damage:IsPenalt(player, flag, source)
	then
		return {Damage = dmg * 2}
	end
end
BSamson:AddPriorityCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, -100, 'PreTakeDMG')


--获取图标渲染位置
function BSamson:GetIconRenderPosition(idx)
	local screenSizeX, screenSizeY = Isaac.GetScreenWidth(), Isaac.GetScreenHeight()
	local X,Y = 0,0
	local offset = Options.HUDOffset

	if (idx == 0) then --P1
		X = 48 + 20*offset
		Y = 40 + 12*offset
	elseif (idx == 1) then --P2
		X = screenSizeX - 116 - 24*offset
		Y = 64 + 12*offset
	elseif (idx == 2) then --P3
		X = 100 + 22*offset
		Y = screenSizeY - 32 - 6*offset
	else --P4或其他
		X = screenSizeX - 80 - 16*offset
		Y = screenSizeY - 48 - 6*offset
	end
	
	return X,Y
end

local selectionSpr = Sprite('gfx/ibs/ui/selection.anm2')
selectionSpr:Play("Idle")
selectionSpr.Color = Color(1,1,1,0.7)

local nextSelectionSpr = Sprite('gfx/ibs/ui/selection.anm2')
nextSelectionSpr:Play("Idle")
nextSelectionSpr.Color = Color(1,1,0,1)

--渲染
function BSamson:OnHUDRender()
	if not game:GetHUD():IsVisible() then return end
	local controllers = {} --用于为控制器编号
	local index = 0
	
	for i = 0, game:GetNumPlayers() -1 do
		local player = Isaac.GetPlayer(i)
		local cid = player.ControllerIndex
		
		if (player.Variant == 0) and (player:GetPlayerType() == self.ID) and not player:IsCoopGhost() then
			if (not player.Parent) and (not controllers[cid])
				--and self:GetState(player) == self.Wrath
			then
				local X,Y = self:GetIconRenderPosition(index)
				local selection = self:GetPostureDoingSel(player)
				local selection2 = self:GetPostureNextSel(player)
				
				--显示图标
				for _,tbl in ipairs(self:GetPostureCardsSprite(player)) do
					if tbl.Sprite3 then					
						tbl.Sprite3:Render(Vector(X,Y))
						X = X + 16
					end
				end

				--显示选择框
				selectionSpr:Render(Vector(X + selection * 16 - 96, Y))
				
				--架势冷却期间不显示预选
				if mod.IBS_Item.Posture:GetTempData(player).CD <= 0 then
					nextSelectionSpr:Render(Vector(X + selection2 * 16 - 96, Y))
				end
			end	
			controllers[cid] = true
			index = index + 1
		end
	end
	
	--EID显示位置稍微调下面一些
	if EID and game:GetRoom():GetFrameCount() > 0 then
		if EID.player 
			and (EID.player:GetPlayerType() == self.ID)
			--and self:GetState(EID.player) == self.Wrath
		then
			EID:addTextPosModifier("IBS_BSamson", Vector(0,16))
		else
			EID:removeTextPosModifier("IBS_BSamson")
		end
	end	
end
BSamson:AddCallback(ModCallbacks.MC_POST_HUD_RENDER, 'OnHUDRender')

--回溯线补偿,摧毁x骷髅时生成传送
function BSamson:OnDestoryXSkull(gridEnt)
	if gridEnt and PlayerManager.AnyoneIsPlayerType(self.ID) then
		local pickup = Isaac.Spawn(5, 100, 44, gridEnt.Position, Vector.Zero, nil):ToPickup()
		pickup:Morph(5, 100 , 44, false, true, true)
	end
end
BSamson:AddCallback(ModCallbacks.MC_POST_GRID_ROCK_DESTROY, 'OnDestoryXSkull', GridEntityType.GRID_ROCK_ALT2)

--切换房间触发
function BSamson:OnNewRoomChangeState()
	for i = 0, game:GetNumPlayers() - 1 do
		local player = Isaac.GetPlayer(i)
		if player:GetPlayerType() == self.ID then
			local data = mod.IBS_Item.Posture:GetData(player)
			local delay = 0
			
			for _,id in ipairs(data.Cards2) do
			
				--倒恶魔进平静
				if id == 71 then
					self:DelayFunction(function()
						self:ChangeState(player, 0)
						self:ApplyCalmSheild(player)
					end, delay)
					delay = delay + 2
				end
				
				--倒月亮进暴怒
				if id == 74 then
					self:DelayFunction(function()
						self:ChangeState(player, 1)
					end, delay)
					delay = delay + 2
				end
			end
		end
	end	
end
BSamson:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, 'OnNewRoomChangeState')


return BSamson