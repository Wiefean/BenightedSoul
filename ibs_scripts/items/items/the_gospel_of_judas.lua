--犹大福音

local mod = Isaac_BenightedSoul
local IBS_CallbackID = mod.IBS_CallbackID
local IBS_PlayerID = mod.IBS_PlayerID

local game = Game()
local sfx = SFXManager()

local TGOJ_Book = mod.IBS_Effect.TGOJ
local TGOJ = mod.IBS_Class.Item(mod.IBS_ItemID.TGOJ)

TGOJ.BookVariant = TGOJ_Book.Variant
TGOJ.DashVariant = mod.IBS_Effect.TGOJDash.Variant

--获取书本数据
function TGOJ:GetBookData(effect)
	return TGOJ_Book:GetBookData(effect)
end

--玩家数据
function TGOJ:GetPlayerData(player)
	local data = self._Ents:GetTempData(player)
	data.TGOJ_PLAYER = data.TGOJ_PLAYER or {
		Points = 0,
		TargetPosition = player.Position,
		DashFrame = 0,
		DashPosition = nil,
		DashEffect = nil
	}
	
	return data.TGOJ_PLAYER
end

--查找书本
function TGOJ:FindBooks(player, slot)
	local result = {}
	for _,effect in pairs(Isaac.FindByType(1000, self.BookVariant)) do
		if self._Ents:IsTheSame(effect.SpawnerEntity, player) then
			local data = self:GetBookData(effect)
			if (slot == nil) then
				table.insert(result, effect)
			elseif (data.Slot ~= nil) and (slot == data.Slot) then
				table.insert(result, effect)
			end
		end	
	end
	
	return result
end

--无飞行不能停在障碍物上
function TGOJ:CanStop(pos, canFly)
	local room = game:GetRoom()
	local grid = room:GetGridEntityFromPos(pos)
	if grid then
		local isPit = (grid.CollisionClass == GridCollisionClass.COLLISION_PIT)
		if not canFly then
			if isPit or (grid.CollisionClass == GridCollisionClass.COLLISION_SOLID) then
				return false
			end
		else --不能飞到超撒坑里
			if isPit and (room:GetBossID() == BossType.MEGA_SATAN) then
				return false
			end
		end
	end
	return true
end

--查找可冲向的书本
function TGOJ:FindBookToDash(player, slot)
	return self._Finds:ClosestEntityInTable(player.Position, self:FindBooks(player, slot), function(book)
		local room = game:GetRoom()
		local data = self:GetBookData(book)

		--检测书本位置
		if (book.Position:Distance(player.Position) < 100) or not room:IsPositionInRoom(book.Position, 1) then
			return false
		end

		--无飞行不能冲刺到障碍物上
		if not self:CanStop(book.Position, player.CanFly) then
			return false
		end

		--检测书本状态
		if (data.DashLeft <= 0) then
			return false
		end

		return true
	end)
end

--角色是否可冲刺
function TGOJ:CanDash(player, slot)
	if player:GetPlayerType() ~= IBS_PlayerID.BJudas then return false end
	local book = self:FindBookToDash(player, slot)
	if book == nil or (book:IsDead() or not book:Exists()) then return false end

	return true
end

--角色正在冲刺
function TGOJ:IsPlayerDashing(player)
	local data = self._Ents:GetTempData(player).TGOJ_PLAYER
	if data and (data.DashPosition ~= nil) then
		return true
	end
	return false
end

--获取兼容状态
function TGOJ:GetCompats(player)
	local tear = true
	local tear_to_fetus = player:HasCollectible(678)
	local tear_to_laser = false
	local brimstone = false
	local tech = false
	local explosion = false
	local sword = false

	if not tear_to_fetus then
		--科技/X
		if player:HasCollectible(68) or player:HasCollectible(395) then	
			tear_to_laser = true
		end
	end

	--硫磺火
	if player:HasCollectible(118) then
		brimstone = true
		
		--没有剖腹产则取消眼泪
		if not tear_to_fetus then
			tear = false
		end
	end

	--胎儿博士
	if player:HasCollectible(52) or player:HasCollectible(168) then
		explosion = true
	end

	return {
		Tear = tear,
		TearToFetus = tear_to_fetus,
		TearToLaser = tear_to_laser,
		TechX = techX,
		Brimstone = brimstone,
		Tech = tech,
		Explosion = explosion,
	}
end

--尝试使用
function TGOJ:OnTryUse()
	return 0
end
TGOJ:AddCallback(ModCallbacks.MC_PLAYER_GET_ACTIVE_MIN_USABLE_CHARGE, 'OnTryUse', TGOJ.ID)

--提醒是否可冲刺
local fnt = Font()
fnt:Load("font/pftempestasevencondensed.fnt")
function TGOJ:OnActiveRender(player, slot, offset, alpha, scale)
	if player:GetActiveItem(slot) ~= self.ID then return end
	if not self:CanDash(player, slot) then return end
	local book = TGOJ:FindBookToDash(player, slot)
	if (not book) or (book:IsDead() or not book:Exists()) then return end
	local left = self:GetBookData(book).DashLeft
	if left <= 0 then return end
	local pos = Vector(14*scale, -1*scale) + offset
	local color = KColor(1,1,1,alpha)

	--抖动
	if not game:IsPaused() then
		pos.X = pos.X + math.random(-2,2)
		pos.Y = pos.Y + math.random(-2,2)
	end
	
	if left >= 4 then
		fnt:DrawStringScaled('^', pos.X, pos.Y, 1.5*scale, 1.5*scale, color)
	end

	if left >= 1 then
		fnt:DrawStringScaled('^', pos.X, pos.Y + 6*scale, 1.5*scale, 1.5*scale, color)
	end
	
	if left >= 2 then
		fnt:DrawStringScaled('^', pos.X, pos.Y + 12*scale, 1.5*scale, 1.5*scale, color)
	end
	
	if left >= 3 then
		fnt:DrawStringScaled('^', pos.X, pos.Y + 18*scale, 1.5*scale, 1.5*scale, color)
	end
end
TGOJ:AddCallback(ModCallbacks.MC_POST_PLAYERHUD_RENDER_ACTIVE_ITEM, 'OnActiveRender')


--使用
function TGOJ:OnUse(item, rng, player, flag, slot)
	if (flag & UseFlag.USE_CARBATTERY > 0) then return end
	local owned = (flag & UseFlag.USE_OWNED > 0) --是否拥有

	--由其他效果触发则原地生成书本
	if not owned then
		TGOJ_Book:Spawn(player)
	else
		local charges = self._Players:GetSlotCharges(player, slot, true, true)
		local maxCharges = 135

		if charges < maxCharges then
			local book = TGOJ:FindBookToDash(player, slot)

			--表表犹大兼容
			if player:GetPlayerType() == IBS_PlayerID.BJudas and book and self:CanDash(player, slot) then
				local data = self:GetPlayerData(player)
				data.DashPosition = book.Position
				
				local bdata = self:GetBookData(book)
				bdata.State = 'Go'
				bdata.TargetPosition = player.Position
				bdata.DashLeft = bdata.DashLeft - 1
			else
				--尝试回收书本
				for _,book in ipairs(self:FindBooks(player, slot)) do
					local data = self:GetBookData(book)
					if data.State == 'Idle' then
						data.State = 'Recycle'
					end
				end
			end
		else
			self._Players:TryHoldItem(item, player, flag, slot)
		end	
	end
	
	return {ShowAnim = false, Discharge = false}
end
TGOJ:AddCallback(ModCallbacks.MC_USE_ITEM, 'OnUse', TGOJ.ID)


--握住判定
function TGOJ:OnTryHold(item, player, flag, slot, holdingItem)
	local canHold = (flag & UseFlag.USE_CARBATTERY <= 0) and (flag & UseFlag.USE_VOID <= 0)
	if canHold and (holdingItem <= 0) then self:GetPlayerData(player).TargetPosition = player.Position end
	
	return {
		CanHold = canHold,
		CanCancel = true,
		Timeout = 120
	}
end
TGOJ:AddCallback(IBS_CallbackID.TRY_HOLD_ITEM, 'OnTryHold', TGOJ.ID)


--正在握住
function TGOJ:OnHolding(item, player, flag, slot)
	local data = self:GetPlayerData(player)
	if not data.TargetPosition then data.TargetPosition = player.Position end
	
	--调整目标位置
	if player:AreControlsEnabled() then
		if (player.ControllerIndex == 0) and Input.IsMouseBtnPressed(0) then --鼠标兼容
			local mousePos = self._Screens:GetMousePosition(true)
			if mousePos:Distance(data.TargetPosition) > 4 then
				data.TargetPosition = self._Maths:MoveInRoom(data.TargetPosition, (mousePos - data.TargetPosition):Resized(8), 5)
			end
		else
			data.TargetPosition = self._Maths:MoveInRoom(data.TargetPosition, (self._Players:GetAimingVector(player, true))*9, 5)
		end
	end
end
TGOJ:AddCallback(IBS_CallbackID.HOLDING_ITEM, 'OnHolding', TGOJ.ID)

--结束握住
function TGOJ:OnHoldEnd(item, player, flag, slot, byActive, byTimeout, byHurt, byNewRoom)
	if byNewRoom then return end

	if (flag & UseFlag.USE_OWNED <= 0) or self._Players:DischargeSlot(player, slot, 135, true, false, true, true) then
		local data = self:GetPlayerData(player)
		local timeout = 270

		--昧化犹大长子权
		if player:GetPlayerType() == IBS_PlayerID.BJudas and player:HasCollectible(619) then
			timeout = 390
		end

		--车载电池
		if player:HasCollectible(356) then
			timeout = timeout * 2
		end

		TGOJ_Book:Spawn(player, player.Position, data.TargetPosition, timeout, slot)
		sfx:Play(SoundEffect.SOUND_SHELLGAME)
		
		--尝试恢复上限骰(东方mod)
		if slot ~= 2 then
			mod.IBS_Compat.THI:TryRestoreDice(player, TGOJ.ID, slot)
		end
	end
end
TGOJ:AddCallback(IBS_CallbackID.HOLD_ITEM_END, 'OnHoldEnd', TGOJ.ID)

--充能
function TGOJ:Charge()
	for i = 0, game:GetNumPlayers() -1 do
		local player = Isaac.GetPlayer(i)	
		for slot = 0,2 do
			if player:GetActiveItem(slot) == (self.ID) and #self:FindBooks(player, slot) <= 0 then
			local charges = self._Players:GetSlotCharges(player, slot, true, true)
			local maxCharges = 135
			
				if charges < maxCharges then
					self._Players:ChargeSlot(player, slot, 1, true)
					
					if charges + 1 == maxCharges then
						sfx:Play(SoundEffect.SOUND_BEEP)
						game:GetHUD():FlashChargeBar(player, slot)
					end						
				end
			end	
		end
	end	
end
TGOJ:AddCallback(ModCallbacks.MC_POST_UPDATE, 'Charge')

--显示光标
local mark_spr = Sprite()
mark_spr:Load("gfx/ibs/effects/mark.anm2", true)
mark_spr:Play("Mark")
function TGOJ:OnRender()
	for i = 0, game:GetNumPlayers() -1 do
		local player = Isaac.GetPlayer(i)
		local data = self._Ents:GetTempData(player).TGOJ_PLAYER
		
		if data and self._Players:IsHoldingItem(player, self.ID) then
			local pos = self._Screens:WorldToScreen(data.TargetPosition, nil, true)
			mark_spr:Render(pos)
		end
	end	
end
TGOJ:AddCallback(ModCallbacks.MC_POST_RENDER, 'OnRender')

--更新玩家数据
function TGOJ:OnPlayerUpdate(player)
	local data = self._Ents:GetTempData(player).TGOJ_PLAYER
	if data then

		--冲刺
		if data.DashPosition then
			local compats = self:GetCompats(player)
			local scale = math.max(player.SpriteScale.X, player.SpriteScale.Y)

			player:SetMinDamageCooldown(24)
			player:AddControlsCooldown(1)
			player.Position = player.Position + (data.DashPosition - player.Position):Resized(13)

			--自动攻击
			if compats.Tear then
				if compats.TearToLaser and not compats.TearToFetus then
					if player:IsFrame(math.max(1, math.ceil(player.MaxFireDelay / 2)),0) then
						for _,ent in pairs(Isaac.FindInRadius(player.Position, player.TearRange, EntityPartition.ENEMY)) do
							local laser = EntityLaser.ShootAngle(2, player.Position, (ent.Position - player.Position):GetAngleDegrees(), 2, Vector(0,-20), player)
							laser:SetMaxDistance(player.TearRange / 3)
							laser.CollisionDamage = math.max(2, player.Damage / 2)
							laser.LaserLength = self._Maths:TearDamageToScale(laser.CollisionDamage)
							laser:AddTearFlags(player.TearFlags)
							laser.Color = player.LaserColor
							laser:Update()
						end
					end
				elseif player:IsFrame(math.max(1, math.ceil(player.MaxFireDelay)),0) then
					for _,ent in pairs(Isaac.FindInRadius(player.Position, player.TearRange, EntityPartition.ENEMY)) do
						local tear = player:FireTear(player.Position, (ent.Position - player.Position):Resized(player.ShotSpeed * 10), true, true, false)
						if compats.TearToFetus then
							self._Tears:ToFetus(tear, player)
						end
					end
				end
			end
			if compats.Brimstone then
				if player:IsFrame(math.max(1, math.ceil(player.MaxFireDelay / 5)),0) then
					local timeout = 30 * math.floor(math.min(13, player.TearRange / 160))
					local ball = player:FireBrimstoneBall(player.Position, Vector.Zero)
					ball.CollisionDamage = ball.CollisionDamage / 2
					ball.Timeout = timeout
					for _,ent in pairs(Isaac.FindInRadius(player.Position, 120, EntityPartition.ENEMY)) do
						local ball = player:FireBrimstoneBall(player.Position, (ent.Position - player.Position):Resized(10))
						ball.CollisionDamage = ball.CollisionDamage / 2
						ball.Timeout = timeout
					end				
					sfx:Play(7,0.5)
				end
			end

			--碰撞伤害
			if player:IsFrame(2,0) then
				for _,ent in pairs(Isaac.FindInRadius(player.Position, scale*40, EntityPartition.ENEMY)) do
					ent:TakeDamage(math.max(3.5, player.Damage), 0, EntityRef(player), 0)

					--虚弱敌人
					if self:GetIBSData('persis')['bc4'] then
						ent:AddWeakness(EntityRef(player), 20)
					end
				end
			end

			--设置特效
			local effect = data.DashEffect
			if (not effect) or (effect:IsDead() or not effect:Exists()) then
				data.DashEffect = Isaac.Spawn(1000, self.DashVariant, 0, player.Position, Vector.Zero, player):ToEffect()
				data.DashEffect:FollowParent(player)
				data.DashEffect.SpriteScale = Vector(scale, scale)

				local spr = data.DashEffect:GetSprite()
				spr.Rotation = (data.DashPosition - player.Position):Normalized():GetAngleDegrees() + 90
				local color = (compats.Brimstone and Color(1,1,1,1)) or Color(173/255, 170/255, 170/255)
				if compats.Brimstone then
					color:SetColorize(1,0,0,1)
				else
					color:SetColorize(1,1,1,1)
				end
				spr.Color = color

				--光效
				local lightColor = (compats.Brimstone and Color(1,0,0,1)) or Color(173/255, 170/255, 170/255, 2)
				self._Ents:ApplyLight(data.DashEffect, scale * 2, lightColor, function(light)
					light.Scale = scale * 2
				end)

				--拖尾
				local trailColor = (compats.Brimstone and Color(1,0,0,1,1)) or Color(0.6,0.6,0.6,1)
				self._Ents:ApplyTrail(data.DashEffect, trailColor, 2*Vector(scale,scale))

				--烟雾
				local poof = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF02, 1, player.Position, Vector.Zero, player)				
				poof.SpriteScale = Vector(0.7*scale,0.7*scale)
				poof.Color = color

				sfx:Play(SoundEffect.SOUND_BLACK_POOF, 0.5)
				game:ShakeScreen(3)
				
				--爆炸(非特效哦)
				if compats.Explosion then
					local bomb = player:FireBomb(player.Position, Vector.Zero, player)
					bomb.ExplosionDamage = math.max(30, player.Damage * 10)
					bomb:SetExplosionCountdown(0)
				end
			else
				effect.SpriteScale = player.SpriteScale
				effect:GetSprite().Rotation = (data.DashPosition - player.Position):Normalized():GetAngleDegrees() + 90
			end
			
			--到达地点
			if (data.DashPosition:Distance(player.Position) <= player.Size) or (data.DashFrame > 3 and self:CanStop(player.Position, player.CanFly) and self._Players:IsShooting(player, true)) or (data.DashFrame > 420) then
				data.DashPosition = nil
				if data.DashEffect then
					data.DashEffect.Parent = nil
				end

				--爆炸
				if compats.Explosion then
					local bomb = player:FireBomb(player.Position, Vector.Zero, player)
					bomb.ExplosionDamage = math.max(30, player.Damage * 10)
					bomb:SetExplosionCountdown(0)
				end

				--烟雾
				local color = Color(173/255, 170/255, 170/255)
				color:SetColorize(1,1,1,1)
				local poof = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF02, 1, player.Position, Vector.Zero, player)				
				poof.SpriteScale = Vector(0.7*scale,0.7*scale)
				poof.Color = color

				sfx:Play(SoundEffect.SOUND_BLACK_POOF, 0.5)
				game:ShakeScreen(3)
			end
			
			--计时,最多冲刺7秒
			if data.DashFrame then
				data.DashFrame = data.DashFrame + 1
			end
		end

		--重置数据
		if data.DashPosition == nil then
			data.DashFrame = 0
		end
	end	
end
TGOJ:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, 'OnPlayerUpdate')

--冲刺期间无视与实体的碰撞
function TGOJ:PrePlayerCollision(player)
	if self:IsPlayerDashing(player) then
		return true
	end
end
TGOJ:AddCallback(ModCallbacks.MC_PRE_PLAYER_COLLISION, 'PrePlayerCollision')

--冲刺期间无视与障碍物的碰撞
function TGOJ:PrePlayerGridCollision(player)
	if self:IsPlayerDashing(player) then
		return true
	end
end
TGOJ:AddCallback(ModCallbacks.MC_PRE_PLAYER_GRID_COLLISION, 'PrePlayerGridCollision')

--冲刺期间无视伤害
function TGOJ:PrePlayerTakeDMG(player)
	if self:IsPlayerDashing(player) then
		return false
	end
end
TGOJ:AddCallback(ModCallbacks.MC_PRE_PLAYER_TAKE_DMG, 'PrePlayerTakeDMG')


--新房间重置数据
function TGOJ:OnNewRoom()
	for i = 0, game:GetNumPlayers() -1 do
		local player = Isaac.GetPlayer(i)
		local data = self._Ents:GetTempData(player).TGOJ_PLAYER
		if data then
			data.DashPosition = nil
			player:AddCacheFlags(CacheFlag.CACHE_DAMAGE, true)
		end
		
		--充能
		for slot = 0,2 do
			if player:GetActiveItem(slot) == (self.ID) then
				local maxCharges = 135
				player:SetActiveCharge(maxCharges, slot)
			end
		end		
	end
end
TGOJ:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, 'OnNewRoom')




return TGOJ

