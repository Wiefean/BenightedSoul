--犹大福音

local mod = Isaac_BenightedSoul
local IBS_API = mod.IBS_API
local IBS_Callback = mod.IBS_Callback
local IBS_Challenge = mod.IBS_Challenge
local IBS_Item = mod.IBS_Item
local IBS_Player = mod.IBS_Player
local Ents = mod.IBS_Lib.Ents
local Players = mod.IBS_Lib.Players
local Screens = mod.IBS_Lib.Screens
local Finds = mod.IBS_Lib.Finds
local Stats = mod.IBS_Lib.Stats

local BookVariant = mod.IBS_Effect.TGOJ.Variant
local ErrorTipName = "IBS_API.TGOJ"
IBS_API.TGOJ = {}

--用于昧化该隐&亚伯
IBS_API.BCBA:AddExcludedActiveItem(IBS_Item.tgoj)

--临时玩家数据
local function GetPlayerData(player)
	local data = Ents:GetTempData(player)
	data.TGOJ_PLAYER = data.TGOJ_PLAYER or {
		Points = 0,
		DMGUp = 0,
		TargetPosition = player.Position
	}
	
	return data.TGOJ_PLAYER
end

--临时书本数据
local function GetBookData(effect)
	local data = Ents:GetTempData(effect)
	data.TGOJ_EFFECT = data.TGOJ_EFFECT or {
		State = "Go",
		TimeOut = 240,
		Slot = nil,
		TargetPosition = Vector.Zero
	}
	
	return data.TGOJ_EFFECT
end

--查找书本
function IBS_API.TGOJ:FindBooks(player, slot)
	local err,mes = mod:CheckArgType(player, "userdata", "player", 1, ErrorTipName)
	if err then error(mes, 2) end
	err,mes = mod:CheckArgType(slot, "number", nil, 2, ErrorTipName, true)
	if err then error(mes, 2) end

	local result = {}
	for _,effect in pairs(Isaac.FindByType(1000, BookVariant)) do
		local data = Ents:GetTempData(effect).TGOJ_EFFECT
		if data and Ents:IsTheSame(effect.SpawnerEntity, player) then
			if (slot == nil) then
				table.insert(result, effect)
			elseif (data.Slot ~= nil) and (slot == data.Slot) then
				table.insert(result, effect)
			end
		end	
	end
	
	return result
end

--生成书本
function IBS_API.TGOJ:SpawnBook(player, spawnPos, targetPos, timeOut, flyingDMG)
	local err,mes = mod:CheckArgType(player, "userdata", "player", 1, ErrorTipName)
	if err then error(mes, 2) end
	err,mes = mod:CheckArgType(spawnPos, "userdata", "vector", 2, ErrorTipName)
	if err then error(mes, 2) end
	err,mes = mod:CheckArgType(targetPos, "userdata", "vector", 3, ErrorTipName, true)
	if err then error(mes, 2) end
	err,mes = mod:CheckArgType(timeOut, "number", nil, 4, ErrorTipName, true)
	if err then error(mes, 2) end
	err,mes = mod:CheckArgType(flyingDMG, "number", nil, 5, ErrorTipName, true)
	if err then error(mes, 2) end
	
	targetPos = targetPos or spawnPos
	timeOut = timeOut or 240
	flyingDMG = flyingDMG or 6.5

	local book = Isaac.Spawn(1000, BookVariant, 0, spawnPos, Vector.Zero, player):ToEffect()
	local data = GetBookData(book)
	data.TimeOut = timeOut
	data.TargetPosition = targetPos
	book.CollisionDamage = flyingDMG
	
	return book
end

--获取书本数据
function IBS_API.TGOJ:GetBookData(effect)
	local err,mes = mod:CheckArgType(effect, "userdata", "effect", 1, ErrorTipName)
	if err then error(mes, 2) end
	
	return GetBookData(effect)
end

--书本是否在飞行
function IBS_API.TGOJ:IsBookFlying(effect)
	local err,mes = mod:CheckArgType(effect, "userdata", "effect", 1, ErrorTipName)
	if err then error(mes, 2) end

	local data = GetBookData(effect)
	return (data.State == "Go") or (data.State == "Recycle")
end

mod:AddCallback(ModCallbacks.MC_USE_ITEM, function()
	return {Discharge = false, ShowAnim = false}
end, IBS_Item.tgoj)

--尝试回收书本
mod:AddCallback(IBS_Callback.TRY_USE_ITEM, function(_,item, player, slot, charges, maxCharges)
	if charges < maxCharges then
		for _,book in pairs(IBS_API.TGOJ:FindBooks(player, slot)) do
			local data = GetBookData(book)
			if data.State == "Idle" then
				data.State = "Recycle"
			end
		end
	end
end, IBS_Item.tgoj)

--举起判定
mod:AddCallback(IBS_Callback.TRY_HOLD_ITEM, function(_,item, player, flag, slot, holdingItem)
	local canHold = (flag & UseFlag.USE_CARBATTERY <= 0) and (flag & UseFlag.USE_VOID <= 0)
	if canHold and (holdingItem <= 0) then GetPlayerData(player).TargetPosition = player.Position end
	
	if (flag & UseFlag.USE_VOID > 0) then
		IBS_API.TGOJ:SpawnBook(player, player.Position)
	end
	
	return {
		CanHold = canHold,
		CanCancel = true,
		TimeOut = 120
	}
end, IBS_Item.tgoj)

--正在握住
local function OnHolding(_,item, player, flag, slot)
	local cid = player.ControllerIndex
	local data = GetPlayerData(player)
	if not data.TargetPosition then data.TargetPosition = player.Position end
	
	--调整目标位置
	if player:AreControlsEnabled() then
		if (player.ControllerIndex == 0) and Input.IsMouseBtnPressed(0) then --鼠标兼容
			local mousePos = Screens:GetMousePosition(true)
			data.TargetPosition = data.TargetPosition + (mousePos - data.TargetPosition):Resized(4.5)
		else
			data.TargetPosition = data.TargetPosition + (Players:GetAimingVector(player, true))*4
		end
	end
end
mod:AddCallback(IBS_Callback.HOLDING_ITEM, OnHolding, IBS_Item.tgoj)

--结束握住
local function OnHoldEnd(_,item, player, flag, slot, active, timeOut, hurt, newRoom)
	if (flag & UseFlag.USE_CARBATTERY <= 0) and not newRoom then
		if (flag & UseFlag.USE_OWNED <= 0) or Players:DischargeSlot(player, slot, 90, true, false, true, true) then
			local book = Isaac.Spawn(1000, BookVariant, 0, player.Position, Vector.Zero, player):ToEffect()
			local bData = GetBookData(book)
			local pData = GetPlayerData(player)
			
			book.CollisionDamage = 6.5
			bData.Slot = slot
			bData.TargetPosition = pData.TargetPosition
			SFXManager():Play(SoundEffect.SOUND_SHELLGAME)
			
			--车载电池
			if player:HasCollectible(356) then
				bData.TimeOut = bData.TimeOut * 2
			end
		end
	end
end
mod:AddCallback(IBS_Callback.END_HOLD_ITEM, OnHoldEnd, IBS_Item.tgoj)

--充能
local function OnCharge()
	for i = 0, Game():GetNumPlayers() -1 do
		local player = Isaac.GetPlayer(i)	
		for slot = 0,2 do
			if player:GetActiveItem(slot) == (IBS_Item.tgoj) then
				if #IBS_API.TGOJ:FindBooks(player, slot) <= 0 then
					local charges = Players:GetSlotCharges(player, slot, true, true)
					
					if charges < 90 then
						Players:ChargeSlot(player, slot, 1, true)
						
						if charges == 89 then
							SFXManager():Play(SoundEffect.SOUND_BEEP)
							Game():GetHUD():FlashChargeBar(player, slot)
						end						
					end
				end	
			end	
		end
	end	
end
mod:AddCallback(ModCallbacks.MC_POST_UPDATE, OnCharge)

--显示光标
local mark_spr = Sprite()
mark_spr:Load("gfx/ibs/effects/mark.anm2", true)
mark_spr:Play("Mark")
local function TargetRender()
	for i = 0, Game():GetNumPlayers() -1 do
		local player = Isaac.GetPlayer(i)
		local data = Ents:GetTempData(player).TGOJ_PLAYER
		local hold = (Ents:GetTempData(player).HoldItemCallback and Ents:GetTempData(player).HoldItemCallback.Item == (IBS_Item.tgoj))
		
		if data and hold then
			local pos = Screens:WorldToScreen(data.TargetPosition)
			mark_spr:Render(pos)
		end
	end	
end
mod:AddCallback(ModCallbacks.MC_POST_RENDER, TargetRender)

--书本拖尾
mod:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, function(_,effect)
	local trail = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.SPRITE_TRAIL, 0, effect.Position, Vector(0,0), effect):ToEffect()
	trail:FollowParent(effect)
	trail:GetSprite().Color = Color(0.6,0.6,0.6,1) --颜色
	trail.MinRadius = 0.06 --淡化速率
	trail.SpriteScale = Vector(2,2) --尺寸
	trail:Update()	
end, BookVariant)

--书本逻辑
mod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, function(_,effect)
	local data = Ents:GetTempData(effect).TGOJ_EFFECT
	local player = Ents:IsSpawnerPlayer(effect)
	
	if data and player then
		local spr = effect:GetSprite()
		effect.DepthOffset = 70 --使图层处于上层
		
		if data.State == "Go" then
			local vec = data.TargetPosition - effect.Position
			effect.Velocity = vec:Resized(14)
			spr:Play("Moving", false)
			spr.Rotation = spr.Rotation + 4
			
			--为了让旋转看起来更丝滑，用延迟触发的方式
			mod:DelayFunction(function() spr.Rotation = spr.Rotation + 4 end ,1)
			mod:DelayFunction(function() spr.Rotation = spr.Rotation + 4 end ,2)
			mod:DelayFunction(function() spr.Rotation = spr.Rotation + 4 end ,3)
			
			if vec:Length() <= 10 then
				spr.Rotation = 0
				effect.Velocity = Vector.Zero
				data.State = "Opening"
			end
		elseif data.State == "Opening" then
			spr:Play("Opening", false)
			
			if spr:IsEventTriggered("sound") then
				SFXManager():Play(SoundEffect.SOUND_PAPER_IN, 1, 3, false, 0.666)
			end
			
			if spr:IsFinished("Opening") then 
				data.State = "Idle" 
			end
		elseif data.State == "Idle" then
			spr:Play("Idle", false)
			spr:PlayOverlay("Sparkle", false)
			
			local pos = effect.Position + Vector(0,20)
			local range = 90
			local pdata = GetPlayerData(player)
		
			--吸收敌弹
			for _,bullet in pairs(Isaac.FindInRadius(effect.Position, range, EntityPartition.BULLET)) do
				bullet.Velocity = (pos - bullet.Position):Resized(7)
				if bullet.Position:Distance(pos) <= 12 then
					pdata.Points = pdata.Points + 1
				
					if pdata.Points >= 13 then
						pdata.Points = pdata.Points - 13
						
						--我释放恶魂
						Isaac.Spawn(1000, 189, 0, player.Position, Vector.Zero, player)
		
						--美德书兼容
						if player:HasCollectible(584) then
							player:AddWisp(33, player.Position)
							player:AddWisp(34, player.Position)
						end					
					end					
				
					--彼列书/昧化犹大兼容
					if player:HasCollectible(59) or (player:GetPlayerType() == IBS_Player.bjudas) then
						pdata.DMGUp = pdata.DMGUp + 0.2
						player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
						player:EvaluateItems()					
					end
					
					--昧化犹大长子权
					if (player:GetPlayerType() == IBS_Player.bjudas) and player:HasCollectible(619) then
						local target = Finds:ClosestEnemy(pos)
						if target ~= nil then
							local tear = player:FireTear(pos, (target.Position - pos):Resized(13), true, false, false, player, 0.5)
							tear.CollisionDamage = math.max(2, tear.CollisionDamage)
						end	
					end
					bullet:Remove()
				end
			end
			
			--虚弱敌人
			if (Isaac.GetChallenge() == IBS_Challenge.bc4) or IBS_Data.Setting["bc4"] then
				for _,target in pairs(Isaac.FindInRadius(effect.Position, range, EntityPartition.ENEMY)) do
					if Ents:IsEnemy(target) then
						Ents:AddWeakness(target, 2)
					end
				end
			end		
		elseif data.State == "Recycle" then
			local vec = player.Position - effect.Position
			effect.Velocity = vec:Resized(13)
			spr:Play("Closing", false)
			spr.Rotation = spr.Rotation + 4
			mod:DelayFunction(function() spr.Rotation = spr.Rotation + 4 end ,1)
			mod:DelayFunction(function() spr.Rotation = spr.Rotation + 4 end ,2)
			mod:DelayFunction(function() spr.Rotation = spr.Rotation + 4 end ,3)
			
			if spr:IsEventTriggered("sound") then
				SFXManager():Play(SoundEffect.SOUND_PAPER_OUT, 1, 3, false, 0.777)
			end			
		
			if vec:Length() <= math.max(30, 30*(player.SpriteScale.X), 30*(player.SpriteScale.Y)) then
				effect:Remove()
				SFXManager():Play(SoundEffect.SOUND_BOOK_PAGE_TURN_12, 1, 3, false, 0.777)
			end			
		end
		
		--属性修正以及飞行时碰撞伤害
		if (data.State ~= "Go") and (data.State ~= "Recycle") then
			spr.Rotation = 0
			effect.Velocity = Vector.Zero
		elseif (data.State == "Go") or (data.State == "Recycle") then
			for _,target in pairs(Isaac.FindInRadius(effect.Position, 20, EntityPartition.ENEMY)) do
				if Ents:IsEnemy(target) then
					target:TakeDamage(effect.CollisionDamage, 0, EntityRef(effect), 1)
				end
			end
		end
		
		if data.TimeOut > 0 then
			data.TimeOut = data.TimeOut - 1
		else
			data.State = "Recycle"
		end
	else
		effect:Remove()
	end		
end, BookVariant)

--伤害加成
mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, function(_,player, flag)
	local data = Ents:GetTempData(player).TGOJ_PLAYER
	if data and (data.DMGUp > 0) then
		if flag == CacheFlag.CACHE_DAMAGE then
			Stats:Damage(player, data.DMGUp)
		end
	end	
end)

--更新玩家数据
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, function(_,player)
	local data = Ents:GetTempData(player).TGOJ_PLAYER
	if data then
	
		--伤害衰减
		if (player.FrameCount % 31 == 0) and (data.DMGUp >= 0.1) then
			data.DMGUp = data.DMGUp - 0.1
			player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
			player:EvaluateItems()
		end		
	end	
end)

--新房间重置伤害加成
mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, function()
	for i = 0, Game():GetNumPlayers() -1 do
		local player = Isaac.GetPlayer(i)
		local data = Ents:GetTempData(player).TGOJ_PLAYER
		if data then
			data.DMGUp = 0
			player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
			player:EvaluateItems()
		end
	end
end)




