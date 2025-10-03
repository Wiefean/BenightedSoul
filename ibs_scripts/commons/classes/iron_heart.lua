--铁心Class

local mod = Isaac_BenightedSoul
local IBS_PlayerID = mod.IBS_PlayerID
local IBS_ItemID = mod.IBS_ItemID
local Pools = mod.IBS_Lib.Pools
local Damage = mod.IBS_Class.Damage()
local Component = mod.IBS_Class.Component

local game = Game()
local sfx = SFXManager()


--初始数值
local Init = {
	Max = 25, --铁心上限
	MaxMax = 70, --铁心上限上限
	MaxMin = 7, --铁心上限下限
}


mod:AddPriorityCallback(ModCallbacks.MC_POST_GAME_STARTED, CallbackPriority.EARLY, function(_,isContinued)
	--易碎品挑战
	if Isaac.GetChallenge() == mod.IBS_ChallengeID[2] then
		Init.Max = 7
	else--完成挑战后,初始铁心上限+3
		if mod:GetIBSData('persis')['bc2'] then
			Init.Max = 28
		else
			Init.Max = 25
		end
	end
end)

local IronHeart = mod.Class(Component, function(self)
	Component._ctor(self)

	--获取数据
	function self:GetData(player)
		local data = self._Players:GetData(player)
		data.IronHeart = data.IronHeart or {
			Num = 0,
			Extra = 0,
			Max = Init.Max,
			Loss = 0,
			Breakdown = 0,
			Recover = 0,
			Enabled = (player:GetPlayerType() == IBS_PlayerID.BMaggy and true) or false
		}

		return data.IronHeart
	end

	--角色是否具有铁心效果
	function self:Check(player)
		local data = self._Players:GetData(player).IronHeart
		if data and data.Enabled then
			return true
		end
		
		return false
	end

	--应用铁心效果到角色身上
	function self:Apply(player, Num)
		local data = self:GetData(player)
		data.Num = Num or 0
		data.Enabled = true
	end

	--取消铁心效果
	function self:Cancel(player)
		local data = self._Players:GetData(player).IronHeart
		if data and data.Enabled then
			data.Enabled = false
		end
	end
	

	--是否应该保护
	function self:ShouldProtect(player, flag, source)
		return Damage:CanHurtPlayer(player, flag, source) and not Damage:IsPlayerSelfDamage(player, flag, source)
	end

	--计算伤害和CD
	function self:CalculateDMG(flag, source)
		local dmg = 0
		local cd = 0

		if source then
			local type = source.Type
			if type == EntityType.ENTITY_PROJECTILE then --子弹
				dmg = 6
				cd = 20
			elseif source.Entity and source.Entity:IsEnemy() then --敌人
				dmg = 2
				cd = 5
			elseif type == EntityType.ENTITY_EFFECT then --水迹
				local V = source.Variant
				if V == (EffectVariant.CREEP_RED) or (V == EffectVariant.CREEP_GREEN) or (V == EffectVariant.CREEP_YELLOW) or (V == EffectVariant.CREEP_WHITE) or (V == EffectVariant.CREEP_BLACK) then
					dmg = 2
					cd = 60
				end
			end
		end
		
		if (flag & DamageFlag.DAMAGE_EXPLOSION > 0) then --爆炸
			dmg = dmg + 33
			cd = cd + 100
		end
		
		--尖刺/诅咒门/刺箱
		if (flag & DamageFlag.DAMAGE_SPIKES > 0) or (flag & DamageFlag.DAMAGE_CURSED_DOOR > 0) or (flag & DamageFlag.DAMAGE_CHEST > 0) then 
			dmg = dmg + 2
			cd = cd + 60
		end
		
		if (flag & DamageFlag.DAMAGE_LASER > 0) then --激光
			dmg = dmg + 1
			cd = cd + 1
		end
		
		if (flag & DamageFlag.DAMAGE_FIRE > 0) then --火焰
			dmg = 1
			cd = cd + 60
		end
		
		if dmg <= 0 then dmg = 1 end
		if cd <= 0 then cd = 3 end
		
		return dmg,cd
	end


	--计算铁心上限
	function self:CalculateMaxMax(player)
		--易碎品挑战
		if Isaac.GetChallenge() == mod.IBS_ChallengeID[2] then
			return 7
		end

		local data = self:GetData(player)
		local sinData = self:GetIBSData("temp").BMAGGY_SIN
	
		local result = Init.Max
		local level = game:GetLevel()
		
		--铅制心脏
		if player:HasCollectible(IBS_ItemID.LeadenHeart) then
			result = result + 7
		end

		--七宗罪击杀数
		if sinData then
			for _,v in pairs(sinData) do
				if type(v) == "number" then				
					result = result + v
				end
			end
		end

		--破损
		if data.Breakdown > 0 then		
			result = result - math.ceil(data.Breakdown)
		end

		if result < Init.MaxMin then result = Init.MaxMin end
		if result > Init.MaxMax then result = Init.MaxMax end
		
		return result
	end

	--我释放震荡波
	function self:ShockWave(player)
		local timeOut = 3*(math.floor(player.Damage))
		local range = (player.TearRange)/5
		if timeOut < 12 then timeOut = 12 end
		if timeOut > 60 then timeOut = 60 end
		if range < 40 then range = 40 end
		if range > 150 then range = 150 end

		--对周围敌人造成伤害,清除周围子弹
		for _,ent in ipairs(Isaac.GetRoomEntities()) do
			if player.Position:Distance(ent.Position) <= range then
				if self._Ents:IsEnemy(ent) then
					ent:TakeDamage(player.Damage * 7, 0, EntityRef(player), 0)
				elseif ent:ToProjectile() and not ent:ToProjectile():HasProjectileFlags(ProjectileFlags.CANT_HIT_PLAYER) then
					ent:Die()
				end
			end
		end
	
		local wave = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.SHOCKWAVE, 0, player.Position, Vector.Zero, player):ToEffect()
		wave.Parent = player
		wave:SetTimeout(timeOut)
		wave:SetRadii(0,range)
		
		local poof = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF02, 1, player.Position, Vector.Zero, player)				
		poof.SpriteScale = Vector(1,1)*(range/90)
		poof.Color = Color(0.5,0.5,0.5)

		game:ShakeScreen(timeOut+5)
		sfx:Play(SoundEffect.SOUND_BLACK_POOF)	
	end

	--受击特效
	function self:SpawnHitEffect(player)
		local effect = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.IMPACT, 0, player.Position+Vector(0,-20), Vector(0,0), nil):ToEffect()
		effect.Timeout = 60
		effect.SpriteScale = player.SpriteScale
		effect:GetSprite().Color = Color(1,1,1,1,0.5,0.5,0.5)
		effect:FollowParent(player)	
		effect.ParentOffset = Vector(0,-20)	
		sfx:Play(SoundEffect.SOUND_SCYTHE_BREAK, 1, 2, false, 0.8)
		return effect
	end
	
end)

local IH = IronHeart()

--铁心保护
local function PreTakeDMG(_,player, amount, flag, source, countDown)
	if amount <= 0 then return end
	if not IH:Check(player) then return end 

	local data = IH:GetData(player)
	local armorBroken = false
	
	if IH:ShouldProtect(player, flag, source) and (data.Num + data.Extra > 0) then
		local dmg,cd = IH:CalculateDMG(flag, source)

		if (data.Num >= dmg) or (data.Num + data.Extra >= dmg) then
			if (data.Num >= dmg) then
				data.Loss = data.Loss + dmg
				data.Num = data.Num - dmg
			elseif (data.Num + data.Extra >= dmg) then
				data.Loss = data.Loss + dmg
				dmg = dmg - data.Num
				data.Num = 0
				data.Extra = data.Extra - dmg
			end

			--每消耗7铁心触发受伤效果和震荡波
			if data.Loss >= 7 then
				data.Loss = 0
				if data.Num + data.Extra <= data.Max then				
					data.Breakdown = data.Breakdown + 2
				end
				player:TakeDamage(1, DamageFlag.DAMAGE_FAKE, source, 0)
				IH:ShockWave(player)
				sfx:Stop(55) -- 移除受伤音效

				--设置无敌时间
				player:SetMinDamageCooldown(30)
			end

			--特效
			IH:SpawnHitEffect(player)

			--设置无敌时间
			player:SetMinDamageCooldown(cd)
				
			--伤害不溢出也会释放震荡波
			if data.Num + data.Extra <= dmg then
				IH:ShockWave(player)
			end

			return false
		else --破防
			armorBroken = true
			data.Loss = data.Loss + data.Num
			data.Extra = 0
			data.Num = 0
			data.Breakdown = data.Breakdown + 6
			data.Recover = data.Recover + data.Max --迅速恢复到上限
			IH:ShockWave(player)
		end

		--破防额外伤
		if armorBroken then
			game:SpawnParticles(player.Position, EffectVariant.ROCK_PARTICLE, 7, 5, Color(1.1,1.1,1.1,1), 100000, 1)
			sfx:Play(SoundEffect.SOUND_ROCK_CRUMBLE)
			player:TakeDamage(amount + 2, flag | DamageFlag.DAMAGE_NO_MODIFIERS | DamageFlag.DAMAGE_INVINCIBLE | DamageFlag.DAMAGE_CLONES, source, 0)
			player:SetMinDamageCooldown(180)
		end
	end
end
mod:AddCallback(ModCallbacks.MC_PRE_PLAYER_TAKE_DMG, PreTakeDMG)


--铁心恢复
local function IronHeartRecovery(percent)
	for i = 0, game:GetNumPlayers() -1 do
		local player = Isaac.GetPlayer(i)
		if IH:Check(player) then
			local data = IH:GetData(player)
			local recovery = math.ceil(percent*(data.Max))
			data.Num = math.min(data.Max, data.Num + recovery)
		end
	end
end
mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, function()
	--易碎品挑战
	if game:GetRoom():IsFirstVisit() and Isaac.GetChallenge() == mod.IBS_ChallengeID[2] then
		IronHeartRecovery(0.2)
	end
	
	--清除额外铁心
	for i = 0, game:GetNumPlayers() -1 do
		local player = Isaac.GetPlayer(i)
		if IH:Check(player) then
			local data = IH:GetData(player)
			data.Num = math.min(data.Max, data.Num + data.Extra)
			data.Extra = 0
		end
	end
end)

--清理房间恢复破损
local function RecoverMaxIronHeart(num)
	for i = 0, game:GetNumPlayers() -1 do
		local player = Isaac.GetPlayer(i)
		if IH:Check(player) then
			local data = IH:GetData(player)
			data.Breakdown = math.max(0, data.Breakdown - num)
		end
	end	
end
mod:AddCallback(ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD, function()
	RecoverMaxIronHeart(1)
end)
mod:AddCallback(mod.IBS_CallbackID.GREED_NEW_WAVE, function()
	RecoverMaxIronHeart(0.5)
end)

mod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, function(_,player)
	if IH:Check(player) then
		local data = IH:GetData(player)
		data.Max = IH:CalculateMaxMax(player)
		data.Num = math.floor(data.Num)
		data.Max = math.floor(data.Max)
		data.Extra = math.floor(data.Extra)

		--恢复
		if data.Recover > 1 then
			data.Recover = data.Recover - 1
			data.Num = math.min(data.Max, data.Num + 1)
			
			--昧化抹大拉长子权
			if player:GetPlayerType() == (IBS_PlayerID.BMaggy) and player:HasCollectible(619) then
				data.Num = data.Num + 1
			end
		end
	end
end, 0)


--图标
local spr = Sprite('gfx/ibs/ui/ironheart.anm2')
spr:Play(spr:GetDefaultAnimation())

--字体
fnt = Font('font/pftempestasevencondensed.fnt')


--获取铁心显示位置
local function GetIronHeartRenderPosition(idx)
	local X,Y = Isaac.GetScreenWidth(), Isaac.GetScreenHeight()
	local offset = Options.HUDOffset
	
	if (idx == 0) then --P1
		X = 48 + 20*offset
		Y = 40 + 12*offset
	elseif (idx == 1) then --P2
		X = X - 116 - 24*offset
		Y = 54 + 12*offset
	elseif (idx == 2) then --P3
		X = 100 + 22*offset
		Y = Y - 33 - 6*offset
	else --P4或其他
		X = X - 80 - 16*offset
		Y = Y - 58 - 6*offset
	end
	
	return X,Y
end

--显示铁心
local function OnHUDRender()
	if not game:GetHUD():IsVisible() then return end

	local controllers = {} --用于为控制器编号
	local index = 0
	
	for i = 0, game:GetNumPlayers() -1 do
		local player = Isaac.GetPlayer(i)
		local cid = player.ControllerIndex

		if (not controllers[cid]) and IH:Check(player) and (player.Variant == 0) and not player:IsCoopGhost() and not player.Parent then
			local X,Y = GetIronHeartRenderPosition(index)
			local data = IH:GetData(player)
			local inum = tostring(data.Num + data.Extra)
			local imax = tostring(data.Max)
			if data.Num < 10 then inum = " "..inum end

			--未知诅咒兼容
			if (game:GetLevel():GetCurses() & LevelCurse.CURSE_OF_THE_UNKNOWN > 0) then
				inum = " ?"
				imax = "?"
			end
			
			--字体颜色提示
			local inumColor = KColor(1,1,1,1,0,0,0)
			if (data.Num + data.Extra) == data.Max then inumColor = KColor(0.5,1,1,1,0,0,0) end
			if (data.Num + data.Extra) > data.Max then inumColor = KColor(1,1,0,1,0,0,0) end
			local imaxColor = KColor(1,1,1,1,0,0,0)
			if data.Max < Init.Max then imaxColor = KColor(1,0,0,1,0,0,0) end
			if data.Max > Init.Max then imaxColor = KColor(0.5,1,1,1,0,0,0) end
			
			spr:Render(Vector(X,Y))
			fnt:DrawString(inum, X+7, Y-7, inumColor)
			fnt:DrawString("/", X+7+fnt:GetStringWidth(inum), Y-7, KColor(1,1,1,1,0,0,0))
			fnt:DrawString(imax, X+7+fnt:GetStringWidth("/"..inum), Y-7, imaxColor)	
		end

		controllers[cid] = true
		index = index + 1
	end
	
	--EID显示位置稍微调下面一些
	if EID and game:GetRoom():GetFrameCount() > 0 then
		if EID.player and IH:Check(EID.player) then
			EID:addTextPosModifier("IBS_IRONHEART", Vector(0,22))
		else
			EID:removeTextPosModifier("IBS_IRONHEART")
		end
	end		
end
mod:AddPriorityCallback(ModCallbacks.MC_POST_HUD_RENDER, CallbackPriority.EARLY, OnHUDRender)





return IronHeart





