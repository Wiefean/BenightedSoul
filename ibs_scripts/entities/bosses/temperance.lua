--节制
--(偷懒套用了暴食的id,多省事)

local mod = Isaac_BenightedSoul
local IBS_BossID = mod.IBS_BossID
local IBS_PlayerKey = mod.IBS_PlayerKey

local game = Game()
local sfx = SFXManager()

local Temperance = mod.IBS_Class.Entity{
	Type = IBS_BossID.Temperance.Type,
	Variant = IBS_BossID.Temperance.Variant,
	SubType = IBS_BossID.Temperance.SubType,
	Name = {zh = '节制', en = 'Temperance'}
}

--是否可出现
function Temperance:CanAppear()
	if not self:GetIBSData('persis')['boss_temperance'] then return false end

	--表表抹检测
	if game:GetRoom():GetType() == RoomType.ROOM_MINIBOSS and PlayerManager.AnyoneIsPlayerType(mod.IBS_PlayerID.BMaggy) then
		return false
	end
	if self:GetIBSData('persis')[IBS_PlayerKey.BIsaac].FINISHED and (game:GetRoom():GetType() ~= RoomType.ROOM_BOSS) then
		return true
	end
	return false
end

--子弹属性
Temperance.ProjParams = ProjectileParams()
Temperance.ProjParams.Variant = ProjectileVariant.PROJECTILE_BONE
Temperance.ProjParams.Spread = 1.2
Temperance.ProjParams.BulletFlags = ProjectileFlags.BOUNCE
Temperance.ProjParams.Color = Color(0.3,0.5,1)

Temperance.ProjParams2 = ProjectileParams()
Temperance.ProjParams2.Variant = ProjectileVariant.PROJECTILE_BONE
Temperance.ProjParams2.BulletFlags = ProjectileFlags.BOUNCE
Temperance.ProjParams2.Color = Color(0.3,0.5,1)

--状态
Temperance.State = {
	Walk = 20,
	Attack1 = 21,
	Teleport = 22,
	Attack2 = 23,
	Attack3 = 24,
}

--获取数据
function Temperance:GetData(npc)
	local data = self._Ents:GetTempData(npc)
	data.Temperance_Boss = data.Temperance_Boss or {
		Recycle = false,
		Attack1Left = math.random(0,4)
	}
	return data.Temperance_Boss
end

--获取子弹数据
function Temperance:GetProjData(proj)
	local data = self._Ents:GetTempData(proj)
	data.Temperance_Proj = data.Temperance_Proj or {Stop = false, FrameToStop = 30}
	return data.Temperance_Proj
end

--停止子弹移动
function Temperance:StopProj(proj)
	local data = self:GetProjData(proj)
	data.Stop = true
	data.FrameToStop = math.random(30,120)
end

--回收子弹
function Temperance:RecycleProj(proj)
	local data = self:GetProjData(proj)
	data.Recycle = true
end

--特殊子弹初始化
function Temperance:OnProjInit(proj)
	local ent = proj.SpawnerEntity
	if ent and ent.Type == Temperance.Type and ent.Variant == Temperance.Variant then
		proj.FallingSpeed = 0
		proj.FallingAccel = -0.1		
		self:StopProj(proj)
	end
end
Temperance:AddCallback(ModCallbacks.MC_POST_PROJECTILE_INIT, 'OnProjInit')

--特殊子弹更新
function Temperance:OnProjUpdate(proj)
	local ent = proj.SpawnerEntity
	if ent and ent.Type == Temperance.Type and ent.Variant == Temperance.Variant then
		local data = self:GetProjData(proj)
		local edata = self:GetData(ent)
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
Temperance:AddCallback(ModCallbacks.MC_POST_PROJECTILE_UPDATE, 'OnProjUpdate')

--初始化
function Temperance:OnNpcInit(npc)
	if (npc.Variant == Temperance.Variant) then
		npc:GetSprite():Play('Appear', true)
		npc.State = self.State.Walk
		npc.SplatColor = Color(0.3,0.5,1)
	elseif (npc.Variant <= 1) and self:CanAppear() then
		--尝试替换暴食
		local rng = RNG(npc.InitSeed)
		local int = rng:RandomInt(100)
		local replac = false
		
		--暴食
		if npc.Variant == 0 and int < 25 then
			replac = true
		end
		
		--超级暴食
		if npc.Variant == 1 and int < 40 then
			replac = true
		end
		
		if replac then
			Isaac.Spawn(Temperance.Type, Temperance.Variant, 0, npc.Position, Vector.Zero, nil)
			npc:Remove()
			
			--提示
			self:DelayFunction(function()
				game:GetHUD():ShowItemText(self:ChooseLanguage('暴食有些不对劲 ?', 'Gluttony ?'), self:ChooseLanguage('节制 !', 'Temperance !'))
			end, 30)
		end
	end	
end
Temperance:AddCallback(ModCallbacks.MC_POST_NPC_INIT, 'OnNpcInit', 49)

--节制瞬移
function Temperance:Teleport(npc)
	--原地留下骨头
	local proj = Isaac.Spawn(EntityType.ENTITY_PROJECTILE, ProjectileVariant.PROJECTILE_BONE, 0, npc.Position, Vector.Zero, npc)
	proj.Color = Color(0.3,0.5,1)
	self:GetProjData(proj).Stop = true

    local poof = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, npc.Position, Vector.Zero, nil)
    local spr = poof:GetSprite()
    spr:Load('gfx/001.000_player.anm2', true)
    spr:Play('TeleportUp')
    sfx:Play(SoundEffect.SOUND_HELL_PORTAL1)
    sfx:Play(SoundEffect.SOUND_HELL_PORTAL2)
    npc.Position = game:GetRoom():FindFreePickupSpawnPosition(npc.Position + 300 * RandomVector(), 0, true)
    npc:SetColor(Color(1, 1, 1, 1, 1,1,1),10,7,true)
end


--更改状态
function Temperance:ChangeState(npc, state)
	--音效提醒
	if state == self.State.Attack1 then
		sfx:Play(116, 0.7)
	elseif state == self.State.Attack2 then
		sfx:Play(305, 0.7)
	end
	
	npc.StateFrame = 0
	npc.State = state
end

--节制更新
function Temperance:OnNpcUpdate(npc)
    if (npc.Variant ~= Temperance.Variant) then return end
	local spr = npc:GetSprite()
	if spr:IsPlaying('Appear') then return end

	local data = self:GetData(npc)
	local vec = Vector.Zero
	local A = Vector.Zero
	local A2 = Vector.Zero
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

	local dist = (npc.Position - target.Position):Length()
	local dir = -1
	
	if npc.State == self.State.Walk then
		if npc.StateFrame < 90 + math.random(0,90) then
			 --行走状态与玩家保持距离
			if dist < 200 then
				vec = npc.Position - target.Position
				A = vec:Resized(math.min(1.1, (vec:Length()) / 30))
				dir = self._Maths:VectorToDirection(vec:Normalized())			
				
				if npc.Velocity:Length() <= 0.5 then
					spr:Play('Idle', false)
				elseif dir == Direction.LEFT then 
					spr:Play('WalkHori', false)
					spr.FlipX = true						
				elseif dir == Direction.RIGHT then		
					spr:Play('WalkHori', false)
					spr.FlipX = false
				elseif dir == Direction.UP then
					spr:Play('WalkUp', false)
				elseif dir == Direction.DOWN then
					spr:Play('WalkDown', false)
				end			
				
				npc.Velocity = npc.Velocity + A			
			else
				dir = self._Maths:VectorToDirection(vec:Normalized())
				spr:Play('Idle', false)
				npc.Velocity = Vector.Zero
			end
		elseif dist > 250 then --距离远则瞬移
			self:ChangeState(npc, self.State.Teleport)
		else --切换至攻击1
			self:ChangeState(npc, self.State.Attack1)
		end
	elseif npc.State == self.State.Attack1 then
		if npc.StateFrame < 80 then
			vec = target.Position - npc.Position
			spr:Play('Attack1', false)
			if spr:IsPlaying('Attack1') then
				if spr:IsEventTriggered('FireProj') then
					sfx:Play(249, 0.5)
					npc:FireProjectiles(npc.Position, (vec:Normalized()*7) + RandomVector(), 1, self.ProjParams)
					
					if friendly then
						for i = 1,10 do
							npc:FireProjectiles(npc.Position, vec:Normalized()*(i+6) + RandomVector(), 0, self.ProjParams2)						
						end
					end
				end
			end
			npc.Velocity = Vector.Zero
		else --切换
			if data.Attack1Left > 0 then
				data.Attack1Left = data.Attack1Left - 1
				self:ChangeState(npc, math.random(20,22))
			else
				data.Attack1Left = math.random(0,4)
				self:ChangeState(npc, self.State.Attack2)
			end
			npc.StateFrame = 0
		end
	elseif npc.State == self.State.Teleport then --主动瞬移后尝试立刻攻击
		local int = math.random(1,2)
		if int == 1 then
			self:ChangeState(npc, self.State.Attack1)
		elseif int == 2 then
			self:ChangeState(npc, self.State.Attack2)
		end	
		self:Teleport(npc)
	elseif npc.State == self.State.Attack2 then
		if npc.StateFrame < 80 then
			spr:Play('Attack2', false)
			if spr:IsPlaying('Attack2') then
				if spr:IsEventTriggered('FireProj2') then
					sfx:Play(249)
					npc:FireProjectiles(npc.Position, Vector(14,0), math.random(6,7), self.ProjParams2)					
				end						
			end
			npc.Velocity = Vector.Zero
		else --切换至攻击3
			self:ChangeState(npc, self.State.Attack3)
		end	
	elseif npc.State == self.State.Attack3 then
		if npc.StateFrame < 75 then
			spr:Play('Attack3', false)
			if spr:IsPlaying('Attack3') then
				if spr:IsEventTriggered('Recycle') then
					data.Recycle = true
				end						
			end
			npc.Velocity = Vector.Zero
		else --切换
			data.Recycle = false
			self:ChangeState(npc, math.random(20,22))
		end	
	end		
	
	--状态计时
	npc.StateFrame = npc.StateFrame + 1
end
Temperance:AddCallback(ModCallbacks.MC_NPC_UPDATE, 'OnNpcUpdate', 49)

--受伤概率瞬移
function Temperance:OnTakeDMG(ent, dmg, flag, source)
	local npc = ent:ToNPC()
	if not npc or (npc.Variant ~= Temperance.Variant) then return end

	local data = self:GetData(npc)
	if not data.Recycle then
		local int = math.random(1,100)
		local chance = 14
		local friendly = npc:HasEntityFlags(EntityFlag.FLAG_FRIENDLY)
		
		if (npc.HitPoints <= ((npc.MaxHitPoints) / 2)) then
			chance = 28
		end

		if friendly then chance = chance * 2 end

		if (dmg >= npc.HitPoints) then
			if friendly then
				chance = 90
			else
				chance = 77
			end
		end


		if int <= chance then
			self:Teleport(npc)
			return false
		end	
	end	
end
Temperance:AddPriorityCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, CallbackPriority.LATE, 'OnTakeDMG', 49)


--替换暴食的掉落物
function Temperance:OnPickupInit(pickup)
	local ent = pickup.SpawnerEntity
	if ent and ent.Type == 49 and ent.Variant == Temperance.Variant then
		pickup:Remove()
	end
end
Temperance:AddCallback(ModCallbacks.MC_POST_PICKUP_INIT, 'OnPickupInit')

--死亡
function Temperance:OnNpcDeath(npc)
	if (npc.SpawnerType == EntityType.ENTITY_PLAYER) or game:IsGreedMode() then return end
	if (npc.Variant ~= Temperance.Variant) then return end
	local int = npc:GetDropRNG():RandomInt(100)
	
	--33%节制卡
	local V = 300
	local S = 15

	if int < 34 then --34%半魂心+骨心
		V = 10
		S = 8
		local boneHeart = Isaac.Spawn(5, 10, 11, game:GetRoom():FindFreePickupSpawnPosition(npc.Position), Vector.Zero, nil)
		boneHeart.Velocity = RandomVector() / 2
	elseif int >= 34 and int < 67 then --33%节制之骨
		V = 100
		S = mod.IBS_ItemID.BOT
	end

	Isaac.Spawn(5, V, S, game:GetRoom():FindFreePickupSpawnPosition(npc.Position),  RandomVector() / 2, nil)
	

	--死亡填坑
	local room = game:GetRoom()
	local size = room:GetGridSize()

	for i = 0,size-1 do
		local grid = room:GetGridEntity(i)
		if grid and (grid.State == 0) and (grid:GetType() == GridEntityType.GRID_PIT) then
			grid:ToPit():MakeBridge(nil)
		end
	end	
end
Temperance:AddCallback(ModCallbacks.MC_POST_NPC_DEATH, 'OnNpcDeath', 49)


return Temperance