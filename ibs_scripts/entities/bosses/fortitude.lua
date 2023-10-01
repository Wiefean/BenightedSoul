--坚韧
--偷懒套用了愤怒的id,多省事

local mod = Isaac_BenightedSoul
local IBS_Item = mod.IBS_Item
local IBS_Pocket = mod.IBS_Pocket
local IBS_Trinket = mod.IBS_Trinket
local Maths = mod.IBS_Lib.Maths
local Finds = mod.IBS_Lib.Finds
local Ents = mod.IBS_Lib.Ents
local Translations = mod.IBS_Lib.Translations
local IBS_RNG = mod:GetUniqueRNG("Boss_Fortitude")

local LANG = Options.Language
if LANG ~= "zh" then LANG = "en" end

local sfx = SFXManager()



--基础属性
local Fortitude = {
	Type = Isaac.GetEntityTypeByName("IBS_Fortitude"),
	Variant = Isaac.GetEntityVariantByName("IBS_Fortitude")
}

local BossState = {
	Normal = 20,
	HalfHp = 21
}

--临时数据
local function GetNpcData(npc)
	local data = Ents:GetTempData(npc)
	data.Fortitude = data.Fortitude or {
		DashCD = 60,
		DashLeft = 0
	}
	return data.Fortitude
end

--是否半血
local function IsHalfHp(npc)
	return npc.HitPoints <= ((npc.MaxHitPoints) / 2) or (npc.State == BossState.HalfHp)
end

--替换愤怒
mod:AddCallback(ModCallbacks.MC_POST_NPC_INIT, function(_,npc)
	if (npc.Type == 48) and (npc.Variant ~= Fortitude.Variant) and (Game():GetRoom():GetType() ~= RoomType.ROOM_BOSS) then
		if IBS_Data.Setting["bmaggy"].FINISHED then
			local chance = IBS_RNG:RandomInt(99) + 1
			local replac = false
			
			--愤怒
			if npc.Variant == 0 and chance <= 25 then
				replac = true
			end
			
			--超级愤怒
			if npc.Variant == 1 and chance <= 40 then
				replac = true
			end
			
			if replac then
				local info = Translations[LANG].BossReplaced["Fortitude"]	
				Game():GetHUD():ShowItemText(info.Title, info.Sub)
				Isaac.Spawn(Fortitude.Type, Fortitude.Variant, 0, npc.Position, Vector.Zero, nil)
				npc:Remove()
			end
		end	
	end
end)

--替换愤怒的掉落物
mod:AddCallback(ModCallbacks.MC_POST_PICKUP_INIT, function(_,pickup)
	local ent = pickup.SpawnerEntity
	if ent then
		if ent.Type == Fortitude.Type and ent.Variant == Fortitude.Variant then
			pickup:Remove()
		end
	end
end)
mod:AddCallback(ModCallbacks.MC_POST_NPC_DEATH, function(_,npc)
	if not Game():IsGreedMode() then
		if (npc.Variant == Fortitude.Variant) and (not npc:HasEntityFlags(EntityFlag.FLAG_NO_REWARD)) and (not npc.SpawnerEntity or npc.SpawnerType ~= EntityType.ENTITY_PLAYER) then
			local chance = IBS_RNG:RandomInt(99) + 1
			
			--1%金色祈者
			local V = 300
			local S = IBS_Pocket.goldenprayer
			
			if chance <= 33 then --33%神圣反击
				V = 350
				S = IBS_Trinket.divineretaliation
			elseif chance > 33 and chance <= 66 then --33%硬心
				V = 350
				S = IBS_Trinket.toughheart
			elseif chance > 66 and chance <= 98 then --33%坚韧面具
				V = 100
				S = IBS_Item.guard
			end
			
			local pickup = Isaac.Spawn(5, V, S, Game():GetRoom():FindFreePickupSpawnPosition(npc.Position), Vector.Zero, nil)
			pickup.Velocity = RandomVector() / 2
		end
	end	
end, Fortitude.Type)

--坚韧初始化
local function OnInit(_,npc)
	if npc.Variant == Fortitude.Variant then
		npc:GetSprite():Play("Appear", true)
		npc.State = BossState.Normal
	end
end
mod:AddCallback(ModCallbacks.MC_POST_NPC_INIT, OnInit, Fortitude.Type)

--行为
local function OnUpdate(_,npc)
    if (npc.Variant == Fortitude.Variant) then
		local data = GetNpcData(npc)
		local spr = npc:GetSprite()
		local vec = Vector.Zero
		local A = Vector.Zero
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
		
		local dir = -1
		local dashSpd = 70
		
		vec = target.Position - npc.Position
		A =  vec:Resized(math.min(1, (vec:Length()) / 40))
		dir = Maths:VectorToDirection(vec:Normalized())			
		
		if dir == Direction.LEFT then 
			spr:Play("WalkHori", false)
			spr.FlipX = true
		elseif dir == Direction.RIGHT then		
			spr:Play("WalkHori", false)
			spr.FlipX = false
		elseif dir == Direction.UP then
			spr:Play("WalkVert", false)
		elseif dir == Direction.DOWN then
			spr:Play("WalkVert", false)
		end			

		
		if IsHalfHp(npc) then
			spr:PlayOverlay("Head2", false)
			npc.Velocity = npc.Velocity - 1.5*A
			dashSpd = 140
			
			if npc.State == BossState.Normal then
				npc.State = BossState.HalfHp
				Isaac.Explode(npc.Position, npc, 0)
			end
		else
			spr:PlayOverlay("Head1", false)
			npc.Velocity = npc.Velocity + A
		end
		
		if data.DashCD == 15 then
			npc:SetColor(Color(1, 1, 1, 1, 1,1,1),10,7,true)
			sfx:Play(171)
		end
		
		if data.DashCD > 0 then
			data.DashCD = data.DashCD - 1
		else
			data.DashCD = 90
			data.DashLeft = 7
			npc:AddVelocity(dashSpd * ((target.Position - npc.Position):Normalized()))
		end
		
		if data.DashLeft > 0 then
			data.DashLeft = data.DashLeft - 1
			local shockwave = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.SHOCKWAVE, 0, npc.Position, Vector.Zero, npc):ToEffect()
			shockwave:SetRadii(0, 10)
			shockwave:SetTimeout(1)
			shockwave.Parent = npc
		end
					
    end
end
mod:AddCallback(ModCallbacks.MC_NPC_UPDATE, OnUpdate, Fortitude.Type)

--半血前抵挡眼泪
mod:AddCallback(ModCallbacks.MC_PRE_TEAR_COLLISION, function(_,tear, other)
	if other then
		if (other.Type == Fortitude.Type) and (other.Variant == Fortitude.Variant) and not IsHalfHp(other) then	
			local vec = other.Position - tear.Position
			local dir = Maths:VectorToDirection(vec:Normalized())			
					
			if dir ~= Direction.DOWN then 
				tear:Die()
				return false
			end
		end	
	end
end)
mod:AddCallback(ModCallbacks.MC_PRE_PROJECTILE_COLLISION, function(_,proj, other)
	if other then
		if (other.Type == Fortitude.Type) and (other.Variant == Fortitude.Variant) and not IsHalfHp(other) then	
			local vec = other.Position - other.Position
			local dir = Maths:VectorToDirection(vec:Normalized())			
					
			if dir ~= Direction.DOWN then 
				proj:Die()
				return false
			end
		end	
	end
end)

--冲撞时穿过被碰撞的生物
mod:AddCallback(ModCallbacks.MC_PRE_NPC_COLLISION, function(_,npc, other)
	if npc.Variant == Fortitude.Variant then
		local data = GetNpcData(npc)
		if data.DashLeft > 0 then
			return true
		end
	end
end, Fortitude.Type)

--半血前爆炸抗性,冲撞时无敌
mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, function(_,ent, dmg, flag, source)
	local npc = ent:ToNPC()

	if npc then
		if (npc.Type == Fortitude.Type) and (npc.Variant == Fortitude.Variant) then
			local data = GetNpcData(npc)
			if data.DashLeft > 0 then
				return false
			end
			
			if not IsHalfHp(npc) then
				 if (dmg > 5) and (flag & DamageFlag.DAMAGE_EXPLOSION > 0) and (flag & DamageFlag.DAMAGE_CLONES <= 0) then
					npc:TakeDamage(5, flag | DamageFlag.DAMAGE_CLONES, source, 0)
					return false
				 end
			end		
		end	
	end	
end)

