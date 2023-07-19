--仰望星空

local mod = Isaac_BenightedSoul
local IBS_Callback = mod.IBS_Callback
local IBS_Item = mod.IBS_Item
local IBS_Sound = mod.IBS_Sound
local Ents = mod.IBS_Lib.Ents
local Maths = mod.IBS_Lib.Maths
local Stats = mod.IBS_Lib.Stats

local sfx = SFXManager()


--临时眼泪数据
local function GetTearData(tear)
	local data = Ents:GetTempData(tear)
	data.SHOOTINGSTARS_TEAR = data.SHOOTINGSTARS_TEAR or {
		Other = false,
		First = false,
		Player = nil
	}

	return data.SHOOTINGSTARS_TEAR
end

--临时玩家数据
local function GetPlayerData(player)
	local data = Ents:GetTempData(player)
	data.SHOOTINGSTARS_PLAYER = data.SHOOTINGSTARS_PLAYER or {
		CD = 0,
		Ready = true,
		KnifeWait = 0,
		Area = {}
	}

	return data.SHOOTINGSTARS_PLAYER
end

--临时敌人数据
local function GetNpcData(npc)
	local data = Ents:GetTempData(npc)
	data.SHOOTINGSTARS_TARGET = data.SHOOTINGSTARS_TARGET or {HitCD = 0}

	return data.SHOOTINGSTARS_TARGET
end
mod:AddCallback(ModCallbacks.MC_NPC_UPDATE, function(_,npc)
	local data = GetNpcData(npc)
    if data.HitCD > 0 then
		data.HitCD = data.HitCD - 1
	else
		data.HitCD = 0
    end
end)


--模拟高度眼泪
local function SetFallenTear(tear)
	local data = GetTearData(tear)
	data.Other = true
end
mod:AddCallback(ModCallbacks.MC_PRE_TEAR_COLLISION, function(_,tear,target)
	local data = GetTearData(tear)
    if data.Other then
        if target:IsEnemy() and target:HasEntityFlags(EntityFlag.FLAG_FRIENDLY) == false then
            if (-tear.Height > 1.2*(target.Size)) then
                return true
            end
        end
    end
end)


--硫磺火兼容
local function TryBrimeStone(player, timer, pos)
	if player:HasCollectible(118) then
		local tear = Isaac.Spawn(EntityType.ENTITY_EFFECT, 101, 0, pos, Vector.Zero, player):ToEffect()
		SetFallenTear(tear)  --(这里懒得写直接写tear)
		tear.Timeout = timer + 60
		tear.CollisionDamage = math.max(player.Damage / 2, 2)
		tear.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ENEMIES
		tear:SetColor(Color(0.75, 0.75, 1, 1, 0, 0, 1),-1,0)	
		sfx:Play(7,0.5)
	end
end
mod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, function(_,effect)
	if (effect.FrameCount % 2 == 0) then
		local data = GetTearData(effect)
		if data.Other then
			local target = Isaac.FindInRadius(effect.Position, 10, EntityPartition.ENEMY)
			for i = 1 , #target do
				if target[i]:IsVulnerableEnemy() and (target[i]:HasEntityFlags(EntityFlag.FLAG_FRIENDLY) == false) then	
					target[i]:TakeDamage(effect.CollisionDamage, 0, EntityRef(effect), 6)
				end
			end
		end
	end
	if effect.TimeOut == 0 then
		effect:Die()
	end
end, 101)

--特殊引物引发流星雨
local function SetStarTear(tear)
	local data = GetTearData(tear)
	data.First = true
end
mod:AddPriorityCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, -300, function(_,target, dmg, flags, source)
	if target:IsEnemy() and target:HasEntityFlags(EntityFlag.FLAG_FRIENDLY) == false then
		if source.Entity then
			if source.Entity:ToTear() or source.Entity:ToLaser() then
				local tear = source.Entity --引物为眼泪或激光(这里懒得写直接写tear)
				local data = GetTearData(tear)
				local edata = GetNpcData(target)
				local player = data.Player
			
				--要求目标不在命中CD，伤害来源是引物，生成引物的玩家存在
				if (edata.HitCD <= 0) and (data.First) and (player) then
					local pdata = GetPlayerData(player)	
					local pos = target.Position
					local timer = math.floor(math.max(4*60, 60*((player.TearRange / 40) - 2)))
					if timer > 12*60 then timer = 12*60 end
					TryBrimeStone(player, timer, pos)
					table.insert(pdata.Area, {TimeOut = timer, Wait = 0, Pos = pos})
					edata.HitCD = 60
				end	
			end
		end
	end
end)

--特殊激光引发流星雨
mod:AddPriorityCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, -300, function(_,npc)
	if npc:IsEnemy() and npc:HasEntityFlags(EntityFlag.FLAG_FRIENDLY) == false then
	
	end
end)

--方向转向量
local ToVector = {
	[Direction.LEFT] = Vector(-1, 0),
	[Direction.UP] = Vector(0, -1),
	[Direction.RIGHT] = Vector(1, 0),
	[Direction.DOWN] = Vector(0, 1)
}

--设置生成引物的玩家(针对原版激光有生成者时伤害来源变为生产者的问题)
local function SetPlayer(tear, player)
	local data = GetTearData(tear)
	data.Player = player
end

--双击发射引物
local function ShootingStars(_,player, type, dir)
	if (type == 1) and not Input.IsActionPressed(ButtonAction.ACTION_MAP, player.ControllerIndex) then
		if player:HasCollectible(IBS_Item.ssg) and player:IsExtraAnimationFinished() and not player:IsCoopGhost() then
			local data = GetPlayerData(player)
			if data.CD <= 0 then
				data.CD = 240
				
				--科技/II/X/0/0.5兼容(引物变为激光)
				--激光有生成者时对敌人造成伤害,伤害来源是生成者,所以这里生成者是空值
				--设置生成引物的玩家直接用自定义函数
				if player:HasCollectible(68) or player:HasCollectible(152) or player:HasCollectible(244) or player:HasCollectible(395) or player:HasCollectible(524) then
					local laser = EntityLaser.ShootAngle(2, player.Position, ToVector[dir]:GetAngleDegrees(), 2, Vector(0,-20), nil)
					SetPlayer(laser, player)
					SetStarTear(laser)
					laser.Parent = player
					laser.TearFlags = TearFlags.TEAR_HOMING
					laser:AddTearFlags(TearFlags.TEAR_SPECTRAL)
					laser.CollisionDamage = 7
					laser:SetColor(Color(0.1, 0.1, 0.8, 0.5, 0.25, 0.25, 1),-1,0)
					laser:Update()
				else
					local tear = Isaac.Spawn(EntityType.ENTITY_TEAR, 18, 0, player.Position, ToVector[dir]*20, player):ToTear()
					SetPlayer(tear, player)
					SetStarTear(tear)
					tear.TearFlags = TearFlags.TEAR_HOMING
					tear:AddTearFlags(TearFlags.TEAR_PIERCING)
					tear:AddTearFlags(TearFlags.TEAR_SPECTRAL)
					tear.CollisionDamage = 7
					tear:SetColor(Color(1, 1, 1, 1, 0, 0, 1),-1,0)
					tear:Update()
				end	
				sfx:Play(IBS_Sound.ssg_fire,0.6)
			end
		end
	end	
end
mod:AddCallback(IBS_Callback.PLAYER_DOUBLE_TAP, ShootingStars)


--生成流星泪
local function SpawnStars(player, pos)
	--local tear = Isaac.Spawn(EntityType.ENTITY_TEAR, 18, 0, v.Pos, Vector.Zero, player):ToTear()
	local tear = player:FireTear(pos, Vector.Zero, false, true, false)
	local dmg = math.max(7, player.Damage)
	local scale = Maths:TearDamageToScale(dmg)
	local fallingSpd = player.ShotSpeed * 2
	if fallingSpd > 10 then fallingSpd = 10 end
	
	--剖腹产兼容
	if player:HasCollectible(678) then
		tear:ChangeVariant(50)
		tear:SetColor(Color(0, 0, 1, 0.5, 0.25, 0.25, 1),-1,0)
	else
		tear:ChangeVariant(18)
		tear:SetColor(Color(1, 1, 1, 1, 0, 0, 1),-1,0)
	end
	
	--突眼不兼容
	if tear:HasTearFlags(TearFlags.TEAR_SHRINK) then
		tear:ClearTearFlags(TearFlags.TEAR_SHRINK) 
	end
	
	--科技零不兼容(已经另改兼容)
	if tear:HasTearFlags(TearFlags.TEAR_LASER) then
		tear:ClearTearFlags(TearFlags.TEAR_LASER) 
	end

	--眼球不兼容
	if tear:HasTearFlags(TearFlags.TEAR_POP) then
		tear:ClearTearFlags(TearFlags.TEAR_POP) 
	end
	
	--三圣颂不兼容
	if tear:HasTearFlags(TearFlags.TEAR_LASERSHOT) then
		tear:ClearTearFlags(TearFlags.TEAR_LASERSHOT) 
	end	
	
	SetFallenTear(tear)
	tear.CollisionDamage = dmg
	tear.Scale = scale
	tear.Height = -800
	tear:AddTearFlags(TearFlags.TEAR_HOMING)
	tear:AddTearFlags(TearFlags.TEAR_SPECTRAL)
	tear.FallingAcceleration = fallingSpd
	tear:Update()
	
	sfx:Stop(153)
end

--射速转流星间隔
local function GetWaitTime(firedelay)
	local tears = 30 / (firedelay + 1)
	local wait = 30 - math.floor(2.5*tears + 0.5)
	if wait < 7 then wait = 7 end
	return wait
end

--妈刀兼容
mod:AddCallback(ModCallbacks.MC_POST_KNIFE_UPDATE, function(_,knife)
	local player = nil

	if knife.SpawnerEntity then
		player = knife.SpawnerEntity:ToPlayer()
	end
	
	if player and player:HasCollectible(114) and player:HasCollectible(IBS_Item.ssg) then
		local data = GetPlayerData(player)

		if data.KnifeWait > 0 then
			data.KnifeWait = data.KnifeWait - 1
		else
			data.KnifeWait = math.floor(GetWaitTime(player.MaxFireDelay) / 1.5)
			if knife:IsFlying() then
				SpawnStars(player, knife.Position)
			end			
		end
		knife:SetColor(Color(1, 1, 1, 1, 0, 0, 1),-1,0,false,true)
	end
end,0)


--冷却以及流星点位更新
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, function(_,player)
	if player:HasCollectible(IBS_Item.ssg) then
		local data = GetPlayerData(player)
		
		--冷却
		if data.CD > 0 then
			data.Ready = false
			data.CD = data.CD - 1
		elseif data.Ready == false then
			data.Ready = true
			sfx:Play(IBS_Sound.ssg_ready,0.6)
			player:SetColor(Color(1, 1, 1, 1, 0,0.25,1),15,2,true)
		end
		
		--流星
		for k,v in pairs(data.Area) do
			if v.TimeOut > 0 then
				if v.Wait > 0 then
					v.Wait = v.Wait - 1
				else
					v.Wait = GetWaitTime(player.MaxFireDelay)
					SpawnStars(player, v.Pos)
				end		
				v.TimeOut = v.TimeOut - 1
			else
				data.Area[k] = nil
			end 
		end
	end
end,0)

--新房间清除点位以及彩蛋
mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, function()
	for i = 0, Game():GetNumPlayers() -1 do
		local player = Isaac.GetPlayer(i)
		local data = GetPlayerData(player)
		data.Area = {}
	end

	local chance = math.random(1,100)
	if (chance > 80) and not Game():GetRoom():IsFirstVisit() then
		for _,item in pairs(Isaac.FindByType(5,100)) do
			if item.SubType == (IBS_Item.ssg) then
				local spr = item:GetSprite()
				spr:ReplaceSpritesheet(1, "gfx/ibs/items/collectibles/ssg_alt.png")
				spr:LoadGraphics()
			end
		end
	end	
end)

