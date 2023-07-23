--金色祈者

local mod = Isaac_BenightedSoul
local IBS_Callback = mod.IBS_Callback
local IBS_Player = mod.IBS_Player
local IBS_Pocket = mod.IBS_Pocket
local Players = mod.IBS_Lib.Players
local Ents = mod.IBS_Lib.Ents

--使用记录
local function Used()
	local data = mod:GetIBSData("Temp")
	data.GoldenPrayerUsed = true
end

--清理使用记录
local function UnUsed()
	local data = mod:GetIBSData("Temp")
	data.GoldenPrayerUsed = false
end

--获取通用款铁心数据
local function GetGeneralIronHeartData(player)
	local data = Players:GetData(player)
	data.GeneralIronHeart = data.GeneralIronHeart or {Num = 0}

	return data.GeneralIronHeart
end	

--临时数据
local function GetPlayerTempData(player)
	local data = Ents:GetTempData(player)
	
	if not data.GENERALIRONHEART then
		local bar = Sprite()
		bar:Load("gfx/ibs/ui/chargebar_ironheart.anm2", true)
		bar:SetFrame("Disappear", 20)
				
		data.GENERALIRONHEART = {BarSprite = bar}
	end
	
	return data.GENERALIRONHEART
end

--使用效果
local function OnUse(_,card,player,flag)
	if player:GetPlayerType() == (IBS_Player.bmaggy) then
		local data = Players:GetData(player)
		if data.IronHeart then
			data.IronHeart.Extra = data.IronHeart.Extra + 30
		end	
	else
		local IronHeart = GetGeneralIronHeartData(player)
		IronHeart.Num = 30
	end
	
	if (flag & UseFlag.USE_MIMIC <= 0) then	
		Used()
	end
	
	SFXManager():Play(SoundEffect.SOUND_SUPERHOLY)
end
mod:AddCallback(ModCallbacks.MC_USE_CARD, OnUse, IBS_Pocket.goldenprayer)

--击败Boss后尝试返还
local function Return()
	if (Game():GetRoom():GetType() == RoomType.ROOM_BOSS) then
		if mod:GetIBSData("Temp").GoldenPrayerUsed then
			local pos = Game():GetRoom():FindFreePickupSpawnPosition((Game():GetLevel():GetCurrentRoom():GetCenterPos()), 0, true)
			Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TAROTCARD, IBS_Pocket.goldenprayer, pos, Vector.Zero, nil)		
			UnUsed()
		end
	end	
end
mod:AddCallback(ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD, Return)


--贪婪Boss波次后尝试返还
local function GreedReturn(_,state)
	if state == 2 then
		if mod:GetIBSData("Temp").GoldenPrayerUsed then
			local pos = Game():GetRoom():FindFreePickupSpawnPosition((Game():GetLevel():GetCurrentRoom():GetCenterPos()), 0, true)
			Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TAROTCARD, IBS_Pocket.goldenprayer, pos, Vector.Zero, nil)		
			UnUsed()
		end
	end	
end
mod:AddCallback(IBS_Callback.GREED_WAVE_END_STATE, GreedReturn)

--是否应该保护
local function ShouldProtect(flag, source)
	if (flag & DamageFlag.DAMAGE_NO_PENALTIES > 0) then
		if (flag & DamageFlag.DAMAGE_RED_HEARTS > 0) or ((flag & DamageFlag.DAMAGE_CURSED_DOOR <= 0) and (flag & DamageFlag.DAMAGE_CHEST <= 0)) then 
			return false
		end
	end

	if (flag & DamageFlag.DAMAGE_IV_BAG > 0) then
		return false
	end

	if (flag & DamageFlag.DAMAGE_FAKE > 0) then
		return false
	end
	
	if source and source.Type == EntityType.ENTITY_SLOT then
		return false
	end

	return true
end

--计算伤害和CD
local function CalculateDMG(amount, flag, source)
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
		dmg = dmg + 5
		cd = cd + 30
	end
	
	if (flag & DamageFlag.DAMAGE_LASER > 0) then --激光
		dmg = dmg + 1
		cd = cd + 1
	end
	
	if (flag & DamageFlag.DAMAGE_FIRE > 0) then --火焰
		dmg = dmg + 1
		cd = cd + 60
	end
	
	if dmg <= 0 then dmg = 4 end
	if cd <= 0 then cd = 3 end
	
	return dmg,cd
end

--通用款铁心保护
local function IronHeart_TakeDMG(_,ent, amount, flag, source)
	local player = ent:ToPlayer()
	
	if player and player:GetPlayerType() ~= (IBS_Player.bmaggy) then
		local IronHeart = Players:GetData(player).GeneralIronHeart
		if IronHeart and ShouldProtect(flag, source) and (IronHeart.Num > 0) then
			local dmg,cd = CalculateDMG(amount, flag, source)
			
			if IronHeart.Num > dmg then
				IronHeart.Num = IronHeart.Num - dmg
				
				local effect = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.IMPACT, 0, player.Position+Vector(0,-20), Vector(0,0), nil):ToEffect()
				effect.Timeout = 60
				effect.SpriteScale = player.SpriteScale
				effect:GetSprite().Color = Color(1,1,1,1,0.5,0.5,0.5)
				effect:FollowParent(player)	
				effect.ParentOffset = Vector(0,-20)	
				SFXManager():Play(SoundEffect.SOUND_SCYTHE_BREAK, 1, 2, false, 0.8)
				player:SetMinDamageCooldown(cd)
				return false
			else
				IronHeart.Num = 0
				
				--我释放震荡波
				local timeOut = 3*(math.floor(player.Damage))
				local range = (player.TearRange)/5
				if timeOut < 12 then timeOut = 12 end
				if timeOut > 60 then timeOut = 60 end
				if range < 40 then range = 40 end
				if range > 150 then range = 150 end
				
				local wave = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.SHOCKWAVE, 0, player.Position, Vector.Zero, player):ToEffect()
				wave.Parent = player
				wave:SetTimeout(timeOut)
				wave:SetRadii(0,range)
				
				local poof = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF02, 1, player.Position, Vector.Zero, player)				
				poof.SpriteScale = Vector(1,1)*(range/90)
				poof.Color = Color(0.5,0.5,0.5)

				Game():ShakeScreen(timeOut+5)
				SFXManager():Play(SoundEffect.SOUND_BLACK_POOF)				
				
				Game():SpawnParticles(player.Position, EffectVariant.ROCK_PARTICLE, 7, 5, Color(1.1,1.1,1.1,1), 100000, 1)
				SFXManager():Play(SoundEffect.SOUND_ROCK_CRUMBLE)
				
				player:SetMinDamageCooldown(120)
				return false				
			end
		end
	end
end
mod:AddPriorityCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, -700, IronHeart_TakeDMG)

--通用款铁心显示
local function OnRender(_,player, offset)
	if (Game():GetRoom():GetRenderMode() ~= RenderMode.RENDER_WATER_REFLECT) then
		local IronHeart = Players:GetData(player).GeneralIronHeart
		if IronHeart then
			local data = GetPlayerTempData(player)
			local bar = data.BarSprite
		
			if IronHeart.Num > 0 then
				bar:SetFrame("Charging", math.floor((IronHeart.Num)*100 / 30))
			else
				bar:Play("Disappear")
			end
			
			bar:Update()
			
			local pos = Isaac.WorldToScreen(Vector(-24,-54) + player.Position + player.PositionOffset) + offset - Game():GetRoom():GetRenderScrollOffset() - Game().ScreenShakeOffset			
			bar:Render(pos)
		end
	end	
end
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_RENDER, OnRender, 0)
