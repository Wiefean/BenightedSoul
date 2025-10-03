--坚韧
--(偷懒套用了愤怒的id,多省事)

local mod = Isaac_BenightedSoul
local IBS_BossID = mod.IBS_BossID
local IBS_ItemID = mod.IBS_ItemID
local IBS_PocketID = mod.IBS_PocketID
local IBS_TrinketID = mod.IBS_TrinketID
local IBS_PlayerKey = mod.IBS_PlayerKey

local game = Game()
local sfx = SFXManager()

local Fortitude = mod.IBS_Class.Entity{
	Type = IBS_BossID.Fortitude.Type,
	Variant = IBS_BossID.Fortitude.Variant,
	SubType = IBS_BossID.Fortitude.SubType,
	Name = {zh = '坚韧', en = 'Fortitude'}
}

--是否可出现
function Fortitude:CanAppear()
	if not self:GetIBSData('persis')['boss_fortitude'] then return false end

	--表表抹检测
	if game:GetRoom():GetType() == RoomType.ROOM_MINIBOSS and PlayerManager.AnyoneIsPlayerType(mod.IBS_PlayerID.BMaggy) then
		return false
	end
	if self:GetIBSData('persis')[IBS_PlayerKey.BMaggy].FINISHED and (game:GetRoom():GetType() ~= RoomType.ROOM_BOSS) then
		return true
	end
	return false
end

--状态
Fortitude.State = {
	Normal = 20,
	HalfHp = 21
}

--临时数据
function Fortitude:GetData(npc)
	local data = self._Ents:GetTempData(npc)
	data.Fortitude_Boss = data.Fortitude_Boss or {
		DashCD = 60,
		DashLeft = 0
	}
	return data.Fortitude_Boss
end

--是否二阶段
function Fortitude:IsPhase2(npc)
	return npc.HitPoints <= ((npc.MaxHitPoints) / 2) or (npc.FrameCount >= 840) or (npc.State == self.State.HalfHp)
end

--初始化
function Fortitude:OnNpcInit(npc)
	if npc.Variant == Fortitude.Variant then
		npc:GetSprite():Play("Appear", true)
		npc.State = self.State.Normal
	elseif (npc.Variant <= 1) and self:CanAppear() then
		--尝试替换愤怒
		local rng = RNG(npc.InitSeed)
		local int = rng:RandomInt(100)
		local replac = false
		
		--愤怒
		if npc.Variant == 0 and int < 25 then
			replac = true
		end
		
		--超级愤怒
		if npc.Variant == 1 and int < 40 then
			replac = true
		end

		if replac then
			Isaac.Spawn(Fortitude.Type, Fortitude.Variant, 0, npc.Position, Vector.Zero, nil)
			npc:Remove()
			
			--提示
			self:DelayFunction(function()
				game:GetHUD():ShowItemText(self:ChooseLanguage('愤怒有些不对劲 ?', 'Wrath ?'), self:ChooseLanguage('坚韧 !', 'Fortitude !'))
			end, 30)			
		end
	end
end
Fortitude:AddCallback(ModCallbacks.MC_POST_NPC_INIT, 'OnNpcInit', 48)

--行为
function Fortitude:OnNpcUpdate(npc)
    if (npc.Variant ~= Fortitude.Variant) then return end
	local spr = npc:GetSprite()
	if spr:IsPlaying('Appear') then return end

	local data = self:GetData(npc)
	local vec = Vector.Zero
	local A = Vector.Zero
	local target = nil
	local friendly = npc:HasEntityFlags(EntityFlag.FLAG_FRIENDLY)
	
	--在友好状态下目标改为最近的敌人,如果没有则仍为玩家
	if friendly then
		target = self._Finds:ClosestEnemy(npc.Position)
		if target == nil then
			target = self._Finds:ClosestPlayer(npc.Position)
		end
	else
		target = self._Finds:ClosestPlayer(npc.Position)
	end
	
	local dir = -1
	local dashSpd = 35
	
	vec = target.Position - npc.Position
	A =  vec:Resized(math.min(1, (vec:Length()) / 40))
	dir = self._Maths:VectorToDirection(vec:Normalized())			
	
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

	--半血进入二阶段
	if self:IsPhase2(npc) then
		spr:PlayOverlay("Head2", false)
		npc.Velocity = npc.Velocity - A
		dashSpd = 120
		
		if npc.State == self.State.Normal then
			npc.State = self.State.HalfHp
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
		
		if friendly then
			data.DashCD = 30
		end
	end
	
	if data.DashLeft > 0 then
		data.DashLeft = data.DashLeft - 1
		local shockwave = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.SHOCKWAVE, 0, npc.Position, Vector.Zero, npc):ToEffect()
		shockwave:SetRadii(0, 8)
		shockwave:SetTimeout(1)
		shockwave.Parent = npc
	end
end
Fortitude:AddCallback(ModCallbacks.MC_NPC_UPDATE, 'OnNpcUpdate', Fortitude.Type)

--半血前抵挡眼泪
function Fortitude:PreTearCollision(tear, other)
	if (other.Type == Fortitude.Type) and (other.Variant == Fortitude.Variant) and not self:IsPhase2(other) then			
		local vec = other.Position - tear.Position
		local dir = self._Maths:VectorToDirection(vec:Normalized())			
				
		if dir ~= Direction.DOWN then 
			tear:Die()
			return false
		end
	end
end
Fortitude:AddCallback(ModCallbacks.MC_PRE_TEAR_COLLISION, 'PreTearCollision')

function Fortitude:PreProjCollision(proj, other)
	if (other.Type == Fortitude.Type) and (other.Variant == Fortitude.Variant) and not self:IsPhase2(other) then	
		local vec = other.Position - other.Position
		local dir = self._Maths:VectorToDirection(vec:Normalized())			
				
		if dir ~= Direction.DOWN then 
			proj:Die()
			return false
		end
	end	
end
Fortitude:AddCallback(ModCallbacks.MC_PRE_PROJECTILE_COLLISION, 'PreProjCollision')

--冲撞时穿过除子弹外实体
function Fortitude:PreNpcCollision(npc, other)
	if npc.Variant == Fortitude.Variant then
		local data = self:GetData(npc)
		local type = other.Type
		if data.DashLeft > 0 and not (type == EntityType.ENTITY_TEAR or type == EntityType.ENTITY_PROJECTILE) then
			return true
		end
	end
end
Fortitude:AddCallback(ModCallbacks.MC_PRE_NPC_COLLISION, 'PreNpcCollision', 48)

--半血前爆炸抗性,冲撞时无敌
function Fortitude:OnTakeDMG(ent, dmg, flag, source)
	local npc = ent:ToNPC()

	if npc and (npc.Type == Fortitude.Type) and (npc.Variant == Fortitude.Variant) then
		local data = self:GetData(npc)
		if data.DashLeft > 0 then
			return false
		end
		
		if not self:IsPhase2(npc) then
			 if (dmg > 5) and (flag & DamageFlag.DAMAGE_EXPLOSION > 0) and (flag & DamageFlag.DAMAGE_CLONES <= 0) then
				npc:TakeDamage(5, flag | DamageFlag.DAMAGE_CLONES, source, 0)
				return false
			 end
		end		
	end	
end
Fortitude:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, 'OnTakeDMG')


--替换愤怒的掉落物
function Fortitude:OnPickupInit(pickup)
	local ent = pickup.SpawnerEntity
	if ent and ent.Type == 48 and ent.Variant == Fortitude.Variant then
		pickup:Remove()
	end
end
Fortitude:AddCallback(ModCallbacks.MC_POST_PICKUP_INIT, 'OnPickupInit')

--死亡
function Fortitude:OnNpcDeath(npc)
	if (npc.SpawnerType == EntityType.ENTITY_PLAYER) or game:IsGreedMode() then return end
	if (npc.Variant ~= Fortitude.Variant) then return end
	local int = npc:GetDropRNG():RandomInt(100)
		
	--2%金色祈者
	local V = 300
	local S = IBS_PocketID.GoldenPrayer
	
	if int < 33 then --33%神圣反击
		V = 350
		S = IBS_TrinketID.DivineRetaliation
	elseif int >= 33 and int < 66 then --33%硬心
		V = 350
		S = IBS_TrinketID.ToughHeart
	elseif int >= 66 and int < 98 then --32%坚韧面具
		V = 100
		S = IBS_ItemID.GOF
	end
	
	Isaac.Spawn(5, V, S, game:GetRoom():FindFreePickupSpawnPosition(npc.Position), RandomVector() / 2, nil)
end
Fortitude:AddCallback(ModCallbacks.MC_POST_NPC_DEATH, 'OnNpcDeath', 48)



return Fortitude