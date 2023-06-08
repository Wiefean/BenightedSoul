--节制
--偷懒套用了暴食的id,多省事

local mod = Isaac_BenightedSoul
local Maths = mod.IBS_Lib.Maths
local Finds = mod.IBS_Lib.Finds
local Ents = mod.IBS_Lib.Ents
local Translations = mod.IBS_Lib.Translations
local DropRNG = mod:GetUniqueRNG("Boss_Temperance_DorpItem")

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
Temperance.ProjParams.Variant = ProjectileVariant.PROJECTILE_TEAR
Temperance.ProjParams.Spread = 1.2
--Temperance.ProjParams.FallingSpeedModifier = 0
--Temperance.ProjParams.FallingAccelModifier = -0.1
Temperance.ProjParams.BulletFlags = ProjectileFlags.BOUNCE

Temperance.ProjParams2.Variant = ProjectileVariant.PROJECTILE_TEAR
--Temperance.ProjParams2.FallingSpeedModifier = 0
--Temperance.ProjParams2.FallingAccelModifier = -0.1
Temperance.ProjParams2.BulletFlags = ProjectileFlags.BOUNCE

local BossState = {
	Walk = 20,
	Attack1 = 21,
	Attack2 = 22,
	Attack3 = 23
}

local function GetNpcData(npc)
	local data = Ents:GetTempData(npc)
	data.Temperance = data.Temperance or {Recycle = false}
	return data.Temperance
end

local function GetProjData(proj)
	local data = Ents:GetTempData(proj)
	data.TemperanceProj = data.TemperanceProj or {Stop = false}
	return data.TemperanceProj
end

local function SetStop(proj)
	local data = GetProjData(proj)
	data.Stop = true
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
			
			if data.Stop and proj.FrameCount > 30 and not edata.Recycle then
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
	if npc.Type == 49 and npc.Variant ~= Temperance.Variant and (Game():GetRoom():GetType() ~= RoomType.ROOM_BOSS) then
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
	if npc.Variant == Temperance.Variant then
		local chance = DropRNG:RandomInt(99) + 1
		local V = 10
		local S = 8
		
		if chance <= 25 then
			S = 3
		elseif chance >25 and chance <= 40 then
			V = 100
			S = 222
		elseif chance >40 and chance <= 65 then
			V = 300
			S = 15
		end
		
		local pickup = Isaac.Spawn(5, V, S, Game():GetRoom():FindFreePickupSpawnPosition(npc.Position), Vector.Zero, nil)
		pickup.Velocity = Vector(math.random(-1,1)/2, math.random(-1,1)/2)
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

--行为
local function OnUpdate(_,npc)
    if (npc.Variant == Temperance.Variant) then
		local data = GetNpcData(npc)
		local spr = npc:GetSprite()
		local vec = Vector.Zero
		local A = Vector.Zero
		local player = Finds:ClosestPlayer(npc.Position)
		local dist = (npc.Position - player.Position):Length()
		local dir = -1
		
		if npc.State == BossState.Walk then
			if npc.StateFrame < 100 + math.random(0,80) then
				 --行走状态与玩家保持距离
				if dist < 150 then
					vec = npc.Position - player.Position
					A =  vec:Resized(math.min(1, (vec:Length()) / 30))
					dir = Maths:VectorToDirection(vec:Normalized())			
					
					if dir == Direction.LEFT then 
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
			else --切换至攻击1
				sfx:Play(116, 0.7)
				npc.State = BossState.Attack1
				npc.StateFrame = 0
			end
		elseif npc.State == BossState.Attack1 then
			if npc.StateFrame < 80 then
				vec = player.Position - npc.Position
				spr:Play("Attack1", false)
				if spr:IsPlaying("Attack1") then
					if spr:IsEventTriggered("FireProj") then
						sfx:Play(153)
						npc:FireProjectiles(npc.Position, vec:Normalized()*15, 1, Temperance.ProjParams)					
					end
				end
				npc.Velocity = Vector.Zero
			else --切换
				npc.State = math.random(20,22)
				npc.StateFrame = 0
			end	
		elseif npc.State == BossState.Attack2 then
			if npc.StateFrame < 80 then
				spr:Play("Attack2", false)
				if spr:IsPlaying("Attack2") then
					if spr:IsEventTriggered("FireProj") then
						sfx:Play(153)
						npc:FireProjectiles(npc.Position, Vector(10,0), 8, Temperance.ProjParams)					
					end
					if spr:IsEventTriggered("FireProj2") then
						sfx:Play(153)
						npc:FireProjectiles(npc.Position, Vector(15,0), 8, Temperance.ProjParams2)					
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