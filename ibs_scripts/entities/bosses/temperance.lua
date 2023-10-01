--节制
--偷懒套用了暴食的id,多省事

local mod = Isaac_BenightedSoul
local IBS_Item = mod.IBS_Item
local Maths = mod.IBS_Lib.Maths
local Finds = mod.IBS_Lib.Finds
local Ents = mod.IBS_Lib.Ents
local Translations = mod.IBS_Lib.Translations
local DropRNG = mod:GetUniqueRNG("Boss_Temperance")

local LANG = Options.Language
if LANG ~= "zh" then LANG = "en" end

local sfx = SFXManager()



--基础属性
local Temperance = {
	Type = Isaac.GetEntityTypeByName("IBS_Temperance"),
	Variant = Isaac.GetEntityVariantByName("IBS_Temperance"),
	ProjParams = ProjectileParams(),
	ProjParams2 = ProjectileParams()
}
Temperance.ProjParams.Variant = ProjectileVariant.PROJECTILE_BONE
Temperance.ProjParams.Spread = 1.2
Temperance.ProjParams.BulletFlags = ProjectileFlags.BOUNCE
Temperance.ProjParams.Color = Color(0.3,0.5,1)

Temperance.ProjParams2.Variant = ProjectileVariant.PROJECTILE_BONE
Temperance.ProjParams2.BulletFlags = ProjectileFlags.BOUNCE
Temperance.ProjParams2.Color = Color(0.3,0.5,1)

local BossState = {
	Walk = 20,
	Attack1 = 21,
	Teleport = 22,
	Attack2 = 23,
	Attack3 = 24,
}

local function GetNpcData(npc)
	local data = Ents:GetTempData(npc)
	data.Temperance = data.Temperance or {
		Recycle = false,
		Attack1Left = math.random(0,4)
	}
	return data.Temperance
end

local function GetProjData(proj)
	local data = Ents:GetTempData(proj)
	data.TemperanceProj = data.TemperanceProj or {Stop = false, FrameToStop = 30}
	return data.TemperanceProj
end

local function SetStop(proj)
	local data = GetProjData(proj)
	data.Stop = true
	data.FrameToStop = math.random(30,120)
end

local function SetRecycle(proj)
	local data = GetProjData(proj)
	data.Recycle = true
end

--特殊眼泪
mod:AddCallback(ModCallbacks.MC_POST_PROJECTILE_INIT, function(_,proj)
	local ent = proj.SpawnerEntity
	if ent then
		if ent.Type == Temperance.Type and ent.Variant == Temperance.Variant then
			proj.FallingSpeed = 0
			proj.FallingAccel = -0.1		
			SetStop(proj)
		end	
	end
end)
mod:AddCallback(ModCallbacks.MC_POST_PROJECTILE_UPDATE, function(_,proj)
	local ent = proj.SpawnerEntity
	if ent then
		if ent.Type == Temperance.Type and ent.Variant == Temperance.Variant then
			local data = GetProjData(proj)
			local edata = GetNpcData(ent)
			proj.FallingSpeed = 0
			proj.FallingAccel = -0.1				
			
			if data.Stop and (proj.FrameCount > data.FrameToStop) and not edata.Recycle then
				proj.Velocity = Vector.Zero
			elseif edata.Recycle then
				proj.Velocity = 30*((ent.Position - proj.Position):Normalized())
				if (proj.Position - ent.Position):Length() <= 2*(ent.Size) then
					proj:Remove()
				end
			end
			
			if ent:IsDead() or not ent:Exists() then
				proj:Die()
			end
		end	
	end
end)

--替换暴食
mod:AddCallback(ModCallbacks.MC_POST_NPC_INIT, function(_,npc)
	if (npc.Type == 49) and (npc.Variant ~= Temperance.Variant) and (Game():GetRoom():GetType() ~= RoomType.ROOM_BOSS) then
		if IBS_Data.Setting["bisaac"].FINISHED then
			local chance = DropRNG:RandomInt(99) + 1
			local replac = false
			
			--暴食
			if npc.Variant == 0 and chance <= 25 then
				replac = true
			end
			
			--超级暴食
			if npc.Variant == 1 and chance <= 40 then
				replac = true
			end
			
			if replac then
				local info = Translations[LANG].BossReplaced["Temperance"]	
				Game():GetHUD():ShowItemText(info.Title, info.Sub)
				Isaac.Spawn(Temperance.Type, Temperance.Variant, 0, npc.Position, Vector.Zero, nil)
				npc:Remove()
			end
		end	
	end
end)

--替换暴食的掉落物
mod:AddCallback(ModCallbacks.MC_POST_PICKUP_INIT, function(_,pickup)
	local ent = pickup.SpawnerEntity
	if ent then
		if ent.Type == Temperance.Type and ent.Variant == Temperance.Variant then
			pickup:Remove()
		end
	end
end)
mod:AddCallback(ModCallbacks.MC_POST_NPC_DEATH, function(_,npc)
	if not Game():IsGreedMode() then
		if (npc.Variant == Temperance.Variant) and (not npc:HasEntityFlags(EntityFlag.FLAG_NO_REWARD)) and (not npc.SpawnerEntity or npc.SpawnerType ~= EntityType.ENTITY_PLAYER) then
			local chance = DropRNG:RandomInt(99) + 1
			
			--33%节制卡
			local V = 300
			local S = 15
			
			if chance <= 34 then --34%魂心+骨心
				V = 10
				S = 3
				local boneHeart = Isaac.Spawn(5, 10, 11, Game():GetRoom():FindFreePickupSpawnPosition(npc.Position), Vector.Zero, nil)
				boneHeart.Velocity = RandomVector() / 2
			elseif chance > 34 and chance <= 67 then --33%节制之骨
				V = 100
				S = IBS_Item.bone
			end
			
			local pickup = Isaac.Spawn(5, V, S, Game():GetRoom():FindFreePickupSpawnPosition(npc.Position), Vector.Zero, nil)
			pickup.Velocity = RandomVector() / 2
			
			--死亡填深坑
			local room = Game():GetRoom()
			local size = room:GetGridSize()
			
			for i = 0,size-1 do
				local grid = room:GetGridEntity(i)
				if grid and (grid.State == 0) and (grid:GetType() == GridEntityType.GRID_PIT) then
					grid:ToPit():MakeBridge(nil)
				end
			end	
		end	
	end
end, Temperance.Type)

--节制初始化
local function OnInit(_,npc)
	if npc.Variant == Temperance.Variant then
		npc:GetSprite():Play("Appear", true)
		npc.State = BossState.Walk
	end
end
mod:AddCallback(ModCallbacks.MC_POST_NPC_INIT, OnInit, Temperance.Type)

--节制瞬移
local function TemperanceTeleport(npc)
    local poof = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, npc.Position,Vector.Zero, nil)
    local spr = poof:GetSprite()
    spr:Load("gfx/001.000_player.anm2", true)
    spr:Play("TeleportUp")
    SFXManager():Play(SoundEffect.SOUND_HELL_PORTAL1)
    SFXManager():Play(SoundEffect.SOUND_HELL_PORTAL2)
    npc.Position = Game():GetRoom():FindFreePickupSpawnPosition(npc.Position + 300 * RandomVector(), 0, true)
    npc:SetColor(Color(1, 1, 1, 1, 1,1,1),10,7,true)
end

--行为
local function OnUpdate(_,npc)
    if (npc.Variant == Temperance.Variant) then
		local data = GetNpcData(npc)
		local spr = npc:GetSprite()
		local vec = Vector.Zero
		local A = Vector.Zero
		local A2 = Vector.Zero
		local target = nil
		
		--在友好状态下目标改为最近的敌人,如果没有则仍为玩家
		if npc:HasEntityFlags(EntityFlag.FLAG_FRIENDLY) then
			target = Finds:ClosestEnemy(npc.Position)
			if target == nil then
				target = Finds:ClosestPlayer(npc.Position)
			end
		else
			target = Finds:ClosestPlayer(npc.Position)
		end	

		local dist = (npc.Position - target.Position):Length()
		local dir = -1
		
		if npc.State == BossState.Walk then
			if npc.StateFrame < 90 + math.random(0,90) then
				 --行走状态与玩家保持距离
				if dist < 200 then
					vec = npc.Position - target.Position
					A = vec:Resized(math.min(1.1, (vec:Length()) / 30))
					dir = Maths:VectorToDirection(vec:Normalized())			
					
					if npc.Velocity:Length() <= 0.5 then
						spr:Play("Idle", false)
					elseif dir == Direction.LEFT then 
						spr:Play("WalkHori", false)
						spr.FlipX = true						
					elseif dir == Direction.RIGHT then		
						spr:Play("WalkHori", false)
						spr.FlipX = false
					elseif dir == Direction.UP then
						spr:Play("WalkUp", false)
					elseif dir == Direction.DOWN then
						spr:Play("WalkDown", false)
					end			
					
					npc.Velocity = npc.Velocity + A			
				else
					dir = Maths:VectorToDirection(vec:Normalized())
					spr:Play("Idle", false)
					npc.Velocity = Vector.Zero
				end
			elseif dist > 300 then --瞬移
				npc.State = BossState.Teleport
				npc.StateFrame = 0
			else --切换至攻击1
				sfx:Play(116, 0.7)
				npc.State = BossState.Attack1
				npc.StateFrame = 0
			end
		elseif npc.State == BossState.Attack1 then
			if npc.StateFrame < 80 then
				vec = target.Position - npc.Position
				spr:Play("Attack1", false)
				if spr:IsPlaying("Attack1") then
					if spr:IsEventTriggered("FireProj") then
						sfx:Play(249, 0.5)
						npc:FireProjectiles(npc.Position, (vec:Normalized()*7) + RandomVector(), 1, Temperance.ProjParams)					
					end
				end
				npc.Velocity = Vector.Zero
			else --切换
				if data.Attack1Left > 0 then
					data.Attack1Left = data.Attack1Left - 1
					npc.State = math.random(20,22)
				else
					data.Attack1Left = math.random(0,4)
					npc.State = BossState.Attack2
				end
				npc.StateFrame = 0
			end
		elseif npc.State == BossState.Teleport then
			local int = math.random(1,2)
			if int == 1 then
				npc.State = BossState.Attack1
			elseif int == 2 then
				npc.State = BossState.Attack2
			end	
			TemperanceTeleport(npc)
		elseif npc.State == BossState.Attack2 then
			if npc.StateFrame < 80 then
				spr:Play("Attack2", false)
				if spr:IsPlaying("Attack2") then
					if spr:IsEventTriggered("FireProj2") then
						sfx:Play(249)
						npc:FireProjectiles(npc.Position, Vector(16,0), 8, Temperance.ProjParams2)					
					end						
				end
				npc.Velocity = Vector.Zero
			else --切换至攻击3
				sfx:Play(305, 0.7)
				npc.State = BossState.Attack3
				npc.StateFrame = 0
			end	
		elseif npc.State == BossState.Attack3 then
			if npc.StateFrame < 75 then
				spr:Play("Attack3", false)
				if spr:IsPlaying("Attack3") then
					if spr:IsEventTriggered("Recycle") then
						data.Recycle = true
					end						
				end
				npc.Velocity = Vector.Zero
			else --切换
				data.Recycle = false
				npc.State = math.random(20,22)
				npc.StateFrame = 0
			end	
		end		
		
		--最大速度
		-- local maxSpeed = 1
        -- local speed = npc.Velocity:Length()
        -- if speed > maxSpeed then
            -- speed = maxSpeed 
            -- npc.Velocity:Resize(speed)
        -- end	
			
		
		--状态计时
		npc.StateFrame = npc.StateFrame + 1
    end
end
mod:AddCallback(ModCallbacks.MC_NPC_UPDATE, OnUpdate, Temperance.Type)

--受伤概率瞬移
mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, function(_,ent, dmg, flag, source)
	local npc = ent:ToNPC()

	if npc then
		if (npc.Type == Temperance.Type) and (npc.Variant == Temperance.Variant) then
			local data = GetNpcData(npc)
			if not data.Recycle then
				local int = math.random(1,100)
				local chance = 14
				
				if (npc.HitPoints <= ((npc.MaxHitPoints) / 2)) then
					chance = 28
				end
				
				if (dmg >= npc.HitPoints) then
					chance = 77
				end
				
				if int <= chance then
					TemperanceTeleport(npc)
					return false
				end	
			end	
		end	
	end	
end)