--临时铁心Class

local mod = Isaac_BenightedSoul
local Players = mod.IBS_Lib.Players
local Screens = mod.IBS_Lib.Screens
local Damage = mod.IBS_Class.Damage()
local Component = mod.IBS_Class.Component

local game = Game()
local sfx = SFXManager()


local TempIronHeart = mod.Class(Component, function(self)
	Component._ctor(self)

	self.Max = 28 --临时铁心上限

	--获取数据
	function self:GetData(player)
		local data = self._Players:GetData(player)
		data.TempIronHeart = data.TempIronHeart or {
			Num = 0,
		}

		--充能条
		local bar = Sprite('gfx/ibs/ui/chargebar_ironheart.anm2')
		bar:SetFrame("Disappear", 99)

		local tData = self._Ents:GetTempData(player)
		if not tData.TempIronHeartBar then tData.TempIronHeartBar = bar end

		return data.TempIronHeart, tData.TempIronHeartBar
	end

	--角色是否具有临时铁心效果
	function self:Check(player)
		local data = self._Players:GetData(player).TempIronHeart
		if data and data.Num > 0 then
			return true
		end
		
		return false
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
			cd = cd + 30
		end
		
		if (flag & DamageFlag.DAMAGE_LASER > 0) then --激光
			dmg = dmg + 1
			cd = cd + 1
		end
		
		if (flag & DamageFlag.DAMAGE_FIRE > 0) then --火焰
			dmg = 1
			cd = cd + 60
		end
		
		if dmg <= 0 then dmg = 4 end
		if cd <= 0 then cd = 3 end
		
		return dmg,cd
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

local TIH = TempIronHeart()

--铁心保护
local function PreTakeDMG(_,player, amount, flag, source, countDown)
	if amount <= 0 then return end
	if not TIH:Check(player) then return end

	local data = TIH:GetData(player)
	local dmg,cd = TIH:CalculateDMG(flag, source)
	
	if TIH:ShouldProtect(player, flag, source) then
		if data.Num >= dmg then
			if data.Num == dmg then
				TIH:ShockWave(player)
			end

			data.Num = data.Num - dmg

			--特效
			TIH:SpawnHitEffect(player)

			--设置无敌时间
			player:SetMinDamageCooldown(cd)
			
		else
			data.Num = 0
			TIH:ShockWave(player)
			TIH:ShockWave(player)
			player:ResetDamageCooldown()
			player:SetMinDamageCooldown(6)
		end

		return false
	end
end
mod:AddCallback(ModCallbacks.MC_PRE_PLAYER_TAKE_DMG, PreTakeDMG)

--新层清零
local function OnNewLevel()
	for i = 0, game:GetNumPlayers() -1 do
		local player = Isaac.GetPlayer(i)
		Players:GetData(player).TempIronHeart = nil
	end
end
mod:AddPriorityCallback(ModCallbacks.MC_POST_NEW_LEVEL, -7000, OnNewLevel)

--渲染
local function OnRender(_,player, offset)
	if game:GetRoom():GetRenderMode() ~= RenderMode.RENDER_WATER_REFLECT then
		if not TIH:Check(player) then return end
		local data, bar = TIH:GetData(player)
		if data.Num < 0 then data.Num = 0 end --数值修正
		if data.Num > TIH.Max then data.Num = TIH.Max end --数值修正
		bar:SetFrame("Charging", math.floor((data.Num)*100 / TIH.Max))
		
		local pos = Screens:GetEntityRenderPosition(player, Vector(-12,-39) + offset)
		bar:Render(pos)
	end	
end
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_RENDER, OnRender, 0)



return TempIronHeart
