--昧化抹大拉

local mod = Isaac_BenightedSoul
local IBS_Callback = mod.IBS_Callback
local IBS_Item = mod.IBS_Item
local IBS_Player = mod.IBS_Player
local IBS_Sound = mod.IBS_Sound
local Pools = mod.IBS_Lib.Pools
local Stats = mod.IBS_Lib.Stats
local Players = mod.IBS_Lib.Players
local Ents = mod.IBS_Lib.Ents


--角色贴图和路径
costume = Isaac.GetCostumeIdByPath("gfx/ibs/characters/bmaggy_hair.anm2")
spritePath = "gfx/ibs/characters/player_bmaggy.anm2"
spriteFlightPath = "gfx/ibs/characters/player_bmaggy.anm2"

--基础数值
local Init = {
	IronHeart_Max = 25, --铁心上限
	IronHeart_MaxMax = 70, --铁心上限上限
	IronHeart_MaxMin = 14, --铁心上限下限
	IronHeart_RecoveryInterval = 72, --铁心恢复间隔,60=1秒
	IronHeart_Interruption = 240, --铁心被打断恢复持续时间,60=1秒
	ShockWave_MaxCharges = 180, --震荡波充能时间,60=1秒
	ShockWave_Cost = 7 --震荡波消耗
}

--角色属性
mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, function(_,player, flag)
	if player:GetPlayerType() == (IBS_Player.bmaggy) then
		if flag == CacheFlag.CACHE_SPEED then
			Stats:Speed(player, -0.3)
		end
		if flag == CacheFlag.CACHE_DAMAGE then
			player.Damage = player.Damage * 0.75
		end
		if flag == CacheFlag.CACHE_RANGE then
			player.TearRange = player.TearRange * 0.5
		end		
	end	
end)

--初始化角色
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, function(_,player)
    if player:GetPlayerType() == (IBS_Player.bmaggy) then
        local game = Game()
        if not (game:GetRoom():GetFrameCount() < 0 and game:GetFrameCount() > 0) then
            player:SetPocketActiveItem((IBS_Item.gheart), ActiveSlot.SLOT_POCKET, false)
        end
    end
end)

--临时数据
local function GetPlayerTempData(player)
	local data = Ents:GetTempData(player)
	
	if not data.BMAGGY then
		local spr = Sprite()
		spr:Load("gfx/ibs/ui/ironheart.anm2", true)
		spr:Play(spr:GetDefaultAnimation())
	
		local fnt = Font()
		fnt:Load("font/pftempestasevencondensed.fnt")
		
		local bar = Sprite()
		bar:Load("gfx/ibs/ui/chargebar_shockwave.anm2", true)
		bar:SetFrame("Disappear", 20)
				
		data.BMAGGY = {
			PlayerMatched = false,
			CostumeState = 0,
			SpriteState = 0,
			IronHeart_Interruption = 0,
			IronHeart_Recovering = 0,
			IronHeart_Sprite = spr,
			IronHeart_Font = fnt,
			Charges = 0,
			ChargeBarSprite = bar
		}
	end
	
	return data.BMAGGY
end

--获取铁心数据
local function GetIronHeartData(player)
	local data = Players:GetData(player)
	data.IronHeart = data.IronHeart or {
		Num = 0,
		Max = Init.IronHeart_Max
	}

	return data.IronHeart
end	

--更新角色贴图
local function UpdatePlayerSprite(player)
    local data = GetPlayerTempData(player)
    local sprState = 1
    local costumeState = 1
    local path = spritePath
    if player.CanFly then path = spriteFlightPath sprState = 2 end
	
	if player:GetPlayerType() == (IBS_Player.bmaggy) then
		data.PlayerMatched = true
		if data.SpriteState ~= sprState then
			data.SpriteState = sprState
			local spr = player:GetSprite()
			local animation = spr:GetAnimation()
			local frame = spr:GetFrame()
			local overlayAnimation = spr:GetOverlayAnimation()
			local overlayFrame = spr:GetOverlayFrame()
			spr:Load(path, true)
			spr:SetFrame(animation, frame)
			spr:SetOverlayFrame(overlayAnimation, overlayFrame)
		end	
		if data.CostumeState ~= costumeState then
			data.CostumeState = costumeState
			player:TryRemoveNullCostume(costume)
			
			if data.CostumeState == 1 then
				player:AddNullCostume(costume)
			end
		end
	else
		if data.PlayerMatched then
			data.PlayerMatched = false
			player:TryRemoveNullCostume(costume)
		end
	end
end

--变身
local function Henshin(_,ent, dmg, flag, source)
	local player = ent:ToPlayer()
	
	if player and (player:GetPlayerType() == PlayerType.PLAYER_MAGDALENE) and player:HasCollectible(45) and (Isaac.GetChallenge() <= 0) then
		if IBS_Data.Setting["bmaggy"]["Unlocked"] then
			local ready = false
		
			--愚蠢的写法，但确实有用(魂心已包含黑心)
			local health = (player:GetBoneHearts())+(player:GetEternalHearts())+(player:GetSoulHearts())+(player:GetHearts())
			if health <= dmg then
				if Game():GetFrameCount() <= (30*30) then
					ready = true
				end
				if (not ready) and Game():GetLevel():GetStage() == 2 then
					if (flag & DamageFlag.DAMAGE_EXPLOSION > 0) then
						ready = true
					end
				end
				if ready then
					local data = GetIronHeartData(player)
					player:ChangePlayerType(IBS_Player.bmaggy)
					data.Num = 25
					player:RemoveCollectible(45, true)
					player:AddSoulHearts(8)
					player:AddMaxHearts(-99)
					player:AddBrokenHearts(4)
					player:SetPocketActiveItem((IBS_Item.gheart), ActiveSlot.SLOT_POCKET, false)
					player:AddNullCostume(costume)
					
					--我释放震荡波
					local wave = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.SHOCKWAVE, 0, player.Position, Vector.Zero, player):ToEffect()
					wave.Parent = player
					wave:SetTimeout(15)
					wave:SetRadii(0,120)
					
					local poof = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF02, 1, player.Position, Vector.Zero, player)				
					poof.SpriteScale = Vector(1.5,1.5)
					poof.Color = Color(0.5,0.5,0.5)

					Game():ShakeScreen(50)
					SFXManager():Play(SoundEffect.SOUND_BLACK_POOF, 4)
					
					player:SetMinDamageCooldown(127)
					return false
				end
			end
		end	
	end
end
mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, Henshin)

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
			dmg = 7
			cd = 20
		elseif source.Entity and source.Entity:IsEnemy() then --敌人
			dmg = 2
			cd = 3
		elseif type == EntityType.ENTITY_EFFECT then --水迹
	        local V = source.Variant
            if V == (EffectVariant.CREEP_RED) or (V == EffectVariant.CREEP_GREEN) or (V == EffectVariant.CREEP_YELLOW) or (V == EffectVariant.CREEP_WHITE) or (V == EffectVariant.CREEP_BLACK) then
				dmg = 2
				cd = 15
			end
		end
	end
	
	if (flag & DamageFlag.DAMAGE_EXPLOSION > 0) then --爆炸
		dmg = dmg + 33
		cd = cd + 75
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
		dmg = dmg + 2
		cd = cd + 30
	end
	
	if dmg <= 0 then dmg = 4 end
	if cd <= 0 then cd = 3 end
	
	return dmg,cd
end

--铁心保护
local function IronHeart_TakeDMG(_,ent, amount, flag, source)
	local player = ent:ToPlayer()
	
	if player and player:GetPlayerType() == (IBS_Player.bmaggy) then
		local IronHeart = GetIronHeartData(player)
		local data = GetPlayerTempData(player)
		local dmg,cd = CalculateDMG(amount, flag, source)
		
		if ShouldProtect(flag, source) and IronHeart.Num > 0 then
			if IronHeart.Num > dmg then
				IronHeart.Num = IronHeart.Num - dmg
				player:SetMinDamageCooldown(cd)
				
				--5毛钱特效
				local effect = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.IMPACT, 0, player.Position+Vector(0,-20), Vector(0,0), nil):ToEffect()
				effect.Timeout = 60
				effect.SpriteScale = player.SpriteScale
				effect:GetSprite().Color = Color(1,1,1,1,0.5,0.5,0.5)
				effect:FollowParent(player)	
				effect.ParentOffset = Vector(0,-20)
				
				SFXManager():Play(SoundEffect.SOUND_SCYTHE_BREAK, 1, 2, false, 0.8)
				data.IronHeart_Interruption = Init.IronHeart_Interruption
				
				return false
			else
				player:TakeDamage(1, DamageFlag.DAMAGE_NO_PENALTIES | DamageFlag.DAMAGE_IV_BAG | DamageFlag.DAMAGE_NO_MODIFIERS | DamageFlag.DAMAGE_INVINCIBLE | DamageFlag.DAMAGE_CLONES, source, 10)
				IronHeart.Num = 0
				
				--1块钱特效
				Game():SpawnParticles(player.Position, EffectVariant.ROCK_PARTICLE, 7, 5, Color(1.1,1.1,1.1,1), 100000, 1)
				
				SFXManager():Play(SoundEffect.SOUND_ROCK_CRUMBLE)
			end
			data.IronHeart_Interruption = Init.IronHeart_Interruption
		end
	end
end
mod:AddPriorityCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, -700, IronHeart_TakeDMG)

--楼层状态影响铁心上限
local LevelStateInfluence = {
	STATE_BUM_KILLED = -3,
	STATE_EVIL_BUM_KILLED = 7,
	STATE_BUM_LEFT = 7,
	STATE_EVIL_BUM_LEFT = -6,
	STATE_SHOPKEEPER_KILLED_LVL = 5
}

local function DevilTag(itemConfig)
	if itemConfig:HasTags(ItemConfig.TAG_DEVIL) then
		return true
	end
	return false
end

local function AngelTag(itemConfig)
	if itemConfig:HasTags(ItemConfig.TAG_ANGEL) then
		return true
	end
	return false
end

local DevilItems = Pools:GetCollectibles(DevilTag)
local AngelItems = Pools:GetCollectibles(AngelTag)
mod:AddPriorityCallback(ModCallbacks.MC_POST_GAME_STARTED, CallbackPriority.EARLY, function(_,isContinue)
	if not isContinue then
		DevilItems = Pools:GetCollectibles(DevilTag)
		AngelItems = Pools:GetCollectibles(AngelTag)
	end
end)

--获取恶魔/天使套件数量
local function GetDAItemsNum(player)
	local dnum = 0
	local anum = 0

	for _,ditem in pairs(DevilItems) do
		if player:HasCollectible(ditem) then
			dnum = dnum + 1
		end
	end
	for _,aitem in pairs(AngelItems) do
		if player:HasCollectible(aitem) then
			anum = anum + 1
		end
	end
	
	return dnum,anum
end

--计算铁心上限
local function CalculateMaxIronHeart(player)
	local result = Init.IronHeart_Max
	local level = Game():GetLevel()
	local devilDeal = Game():GetDevilRoomDeals()
	local devilNum,angelNum = GetDAItemsNum(player)
	
	--楼层状态
	for flag,influence in pairs(LevelStateInfluence) do
		if level:GetStateFlag(LevelStateFlag[flag]) then
			result = result + influence
		end
	end
	
	--钥匙碎片
	if player:HasCollectible(238) then
		result = result + 2
	end
	if player:HasCollectible(239) then
		result = result + 2
	end
	
	result = result - 6*devilDeal - 3*devilNum + 4*angelNum
	if result < Init.IronHeart_MaxMin then result = Init.IronHeart_MaxMin end
	if result > Init.IronHeart_MaxMax then result = Init.IronHeart_MaxMax end
	
	return result
end

--铁心更新
local function IronHeart_Update(_,player)
	if player:GetPlayerType() == (IBS_Player.bmaggy) then
		UpdatePlayerSprite(player) --更新角色贴图
		
		local IronHeart = GetIronHeartData(player)
		local data = GetPlayerTempData(player)
		
		IronHeart.Max = CalculateMaxIronHeart(player) --更新铁心上限
		
		local recoveryInterval = Init.IronHeart_RecoveryInterval
		if player:HasCollectible(619) then --长子权
			recoveryInterval = recoveryInterval / 2
		end
		
		if data.IronHeart_Interruption > 0 then
			data.IronHeart_Interruption = data.IronHeart_Interruption - 1
		else
			if data.IronHeart_Recovering > 0 then
				data.IronHeart_Recovering = data.IronHeart_Recovering - 1
			else
				if IronHeart.Num < IronHeart.Max then
					IronHeart.Num = IronHeart.Num + 1
					data.IronHeart_Recovering = math.floor(recoveryInterval)
				end
			end
		end
		
		if IronHeart.Num > IronHeart.Max then IronHeart.Num = IronHeart.Max end
		
		IronHeart.Num = math.floor(IronHeart.Num)
		IronHeart.Max = math.floor(IronHeart.Max)
	end
end
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, IronHeart_Update)

--是否在蓄力
local function IsCharging(player)
    if player:AreControlsEnabled() and player:GetPlayerType() == (IBS_Player.bmaggy) then
        local cid = player.ControllerIndex
        if player:GetFireDirection() ~= Direction.NO_DIRECTION and not Input.IsActionPressed(ButtonAction.ACTION_DROP, cid) then
			if not Input.IsActionPressed(ButtonAction.ACTION_MAP, cid) then
				return true
			end
		end	
    end
	
    return false
end

--获取屏幕尺寸
local function GetScreenSize()
	local room = Game():GetRoom()
	local pos = Isaac.WorldToScreen(Vector(0,0)) - room:GetRenderScrollOffset() - Game().ScreenShakeOffset
	
	local rx = pos.X + 60 * 26 / 40
	local ry = pos.Y + 140 * (26 / 40)
	
	return rx*2 + 13*26, ry*2 + 7*26
end

--获取铁心显示位置
local function GetIronHeartRenderPosition(idx)
	local X,Y = GetScreenSize()
	local offset = Options.HUDOffset
	
	if idx == 0 then --P1
		X = X/6.8 + 20*offset
		Y = Y/6.5 + 12*offset
	elseif idx == 1 then --P2
		X = X/1.3 - 20*offset
		Y = Y/4.6 + 8*offset
	elseif idx == 2 then --P3
		X = X/4.5 + 22*offset
		Y = Y/1.1 - 6*offset
	else --P4或其他
		X = X/1.3 - 16*offset
		Y = Y/1.2 - 6*offset
	end
	
	return X,Y
end

--显示铁心
local function IronHeart_Render()
	if Game():GetHUD():IsVisible() then
		local controllers = {} --用于为控制器编号
		local index = 0
		
		for i = 0, Game():GetNumPlayers() -1 do
			local player = Isaac.GetPlayer(i)
			if (player.Variant == 0) then
				local cid = player.ControllerIndex
				if not controllers[cid] then
					if player:GetPlayerType() == (IBS_Player.bmaggy) then
						local IronHeart = GetIronHeartData(player)
						local data = GetPlayerTempData(player)
						IronHeart.Num = math.floor(IronHeart.Num)
						IronHeart.Max = math.floor(IronHeart.Max)
						
						local X,Y = GetIronHeartRenderPosition(index)
						local spr = data.IronHeart_Sprite
						local fnt = data.IronHeart_Font
						local inum = tostring(IronHeart.Num)
						local imax = tostring(IronHeart.Max)
						if IronHeart.Num < 10 then inum = " "..inum end
						
						--未知诅咒兼容
						if (Game():GetLevel():GetCurses() & LevelCurse.CURSE_OF_THE_UNKNOWN > 0) then
							inum = " ?"
							imax = "?"
						end
						
						local inumColor = KColor(1,1,1 - (data.IronHeart_Interruption / 240),1,0,0,0)
						local imaxColor = KColor(1,1,1,1,0,0,0)
						if IronHeart.Max < Init.IronHeart_Max then imaxColor = KColor(1,0,0,1,0,0,0) end
						if IronHeart.Max > Init.IronHeart_Max then imaxColor = KColor(0.5,1,1,1,0,0,0) end
						
						spr:Render(Vector(X,Y))
						fnt:DrawString(inum, X+7, Y-7, inumColor)
						fnt:DrawString("/", X+7+fnt:GetStringWidth(inum), Y-7, KColor(1,1,1,1,0,0,0))
						fnt:DrawString(imax, X+7+fnt:GetStringWidth("/"..inum), Y-7, imaxColor)				
						
						
						--EID显示位置稍微调下面一些
						if EID then
							if EID.player then
								EID:addTextPosModifier("IBS_BMAGGY", Vector(0,20))
							else
								EID:removeTextPosModifier("IBS_BMAGGY")
							end
						end
					end	
					controllers[cid] = true
					index = index + 1		
				end
			end
		end
	end
end
mod:AddPriorityCallback(ModCallbacks.MC_POST_RENDER, CallbackPriority.EARLY, IronHeart_Render)

--震荡波
local function ShockWave(_,player, offset)
	if player:GetPlayerType() == (IBS_Player.bmaggy) and (Game():GetRoom():GetRenderMode() ~= RenderMode.RENDER_WATER_REFLECT) then
		local IronHeart = GetIronHeartData(player)
		local data = GetPlayerTempData(player)
		local isCharging = IsCharging(player)
		local maxCharges = Init.ShockWave_MaxCharges
		local cost = Init.ShockWave_Cost
		local game = Game()
		local room = game:GetRoom()
		
		if isCharging then
			if data.Charges < maxCharges then
				data.Charges = data.Charges + 1
			end
		else
			if (data.Charges >= maxCharges) and (IronHeart.Num > cost) and not Input.IsActionPressed(ButtonAction.ACTION_DROP, player.ControllerIndex) then
				IronHeart.Num = IronHeart.Num - cost
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

				game:ShakeScreen(timeOut+5)
				SFXManager():Play(SoundEffect.SOUND_BLACK_POOF)
			end
			data.Charges = 0
		end	
		
		if Options.ChargeBars then
			local charges = data.Charges
			local bar = data.ChargeBarSprite
			local anim = bar:GetAnimation()
		
			if isCharging and charges > 7 then
				if charges >= maxCharges then
					if (anim ~= "StartCharged") and (anim ~= "Charged") then
						bar:Play("StartCharged")
					end
					if bar:IsFinished("StartCharged") then
						bar:Play("Charged")
					end
				else
					bar:SetFrame("Charging", math.floor(charges*100 / maxCharges))
				end
			else
				bar:Play("Disappear")
			end
			
			if (player.FrameCount % 2 == 0) then
				bar:Update()
			end
			
			local pos = Isaac.WorldToScreen(Vector(-24,-54) + player.Position + player.PositionOffset) + offset - room:GetRenderScrollOffset() - Game().ScreenShakeOffset			
			bar:Render(pos)
		end
	end	
end
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_RENDER, ShockWave, 0)

