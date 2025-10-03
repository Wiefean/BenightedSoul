--勤劳
--(偷懒套用了懒惰的id,多省事)

local mod = Isaac_BenightedSoul
local IBS_BossID  = mod.IBS_BossID
local IBS_ItemID = mod.IBS_ItemID
local IBS_PocketID = mod.IBS_PocketID
local IBS_TrinketID = mod.IBS_TrinketID
local IBS_PlayerKey = mod.IBS_PlayerKey

local game = Game()
local sfx = SFXManager()

local Diligence = mod.IBS_Class.Entity{
	Type = IBS_BossID.Diligence.Type,
	Variant = IBS_BossID.Diligence.Variant,
	SubType = IBS_BossID.Diligence.SubType,
	Name = {zh = '勤劳', en = 'Diligence'}
}

--是否可出现
function Diligence:CanAppear()
	if not self:GetIBSData('persis')['boss_deligence_diligence'] then return false end
	
	--表表抹检测
	if game:GetRoom():GetType() == RoomType.ROOM_MINIBOSS and PlayerManager.AnyoneIsPlayerType(mod.IBS_PlayerID.BMaggy) then
		return false
	end
	if self:GetIBSData('persis')[IBS_PlayerKey.BCBA].FINISHED and (game:GetRoom():GetType() ~= RoomType.ROOM_BOSS) then
		return true
	end
	return false
end

--状态
Diligence.State = {
	Walk = 20,
	Attack = 21,
}

--临时数据
function Diligence:GetData(npc)
	local data = self._Ents:GetTempData(npc)
	data.Diligence_Boss = data.Diligence_Boss or {Wait = 60, WheatCollected = 4, InvincibleFrames = 0}
	return data.Diligence_Boss
end

--增加小麦计数
function Diligence:AddWheatCollected(npc, num)
	local data = self:GetData(npc)
	
	if data.WheatCollected < 4 then
		data.WheatCollected = math.min(4, data.WheatCollected + num)

		--提示
		if data.WheatCollected >= 4 then
			npc:SetColor(Color(1, 1, 1, 1, 1, 1),10,7,true)
		end
	end
end

--初始化
function Diligence:OnNpcInit(npc)
	if npc.Variant == self.Variant then
		npc:GetSprite():Play("GhostAppear", true)
		npc.State = self.State.Walk
		npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_WALLS --飞行
		self:GetData(npc).Wait = math.random(60, 90)
	elseif (npc.Variant <= 1) and self:CanAppear() then
		--尝试替换懒惰
		local room = game:GetRoom()
		local rng = RNG(npc.InitSeed)
		local int = rng:RandomInt(100)
		local replac = false
		
		--懒惰
		if npc.Variant == 0 and int < 25 then
			replac = true
		end
		
		--超级懒惰
		if npc.Variant == 1 and int < 40 then
			replac = true
		end

		if replac then
			local pos1 = room:FindFreePickupSpawnPosition(npc.Position + Vector(-100,0), 0, true)
			local pos2 = room:FindFreePickupSpawnPosition(npc.Position + Vector(100,0), 0, true)
		
			Isaac.Spawn(self.Type, self.Variant, self.SubType.Farmer, pos1, Vector.Zero, nil)
			Isaac.Spawn(self.Type, self.Variant, self.SubType.Worker, pos2, Vector.Zero, nil)
			npc:Remove()

			--提示
			self:DelayFunction(function()
				game:GetHUD():ShowItemText(self:ChooseLanguage('懒惰有些不对劲 ?', 'Sloth ?'), self:ChooseLanguage('勤勤 & 劳劳 !', 'Deligence & Diligence !'))
			end, 30)
		end
	end
end
Diligence:AddCallback(ModCallbacks.MC_POST_NPC_INIT, 'OnNpcInit', 46)

--农民行为
function Diligence:OnNpcUpdate1(npc)
    if (npc.Variant ~= self.Variant) then return end
    if (npc.SubType ~= self.SubType.Farmer) then return end
	local spr = npc:GetSprite()
	if spr:IsPlaying('GhostAppear') then return end
	local data = self:GetData(npc)
	local friendly = npc:HasEntityFlags(EntityFlag.FLAG_FRIENDLY)

	--存在一定时间后离开,除非友好
	if not friendly and npc.FrameCount >= 1200 then
		if not game:IsGreedMode() then
			local SeedBag = (mod.IBS_Pickup and mod.IBS_Pickup.SeedBag)

			--种子袋
			if SeedBag then
				Isaac.Spawn(5, SeedBag.Variant, SeedBag.SubType, npc.Position, RandomVector() / 2, nil)
			end
		
			--50%额外掉落偶像
			if npc:GetDropRNG():RandomInt(100) <= 50 then
				local pos = game:GetRoom():FindFreePickupSpawnPosition(npc.Position)
				Isaac.Spawn(5, 100, IBS_ItemID.MODE, pos, Vector.Zero, nil)
			end
		end

		self._Ents:CopyAnimation(npc, npc.Position, 30, "LostDeath")
		npc:Remove()

		return
	end

	--身体动画
	spr:PlayOverlay("Dripping", false)

	if data.InvincibleFrames > 0 then
		data.InvincibleFrames = data.InvincibleFrames - 1
		
		--无敌闪烁
		if npc:IsFrame(2,0) then
			npc.Visible = false
		else
			npc.Visible = true
		end
	else
		npc.Visible = true
	end

	--向小麦移动
	local DeligenceWheat = (mod.IBS_Pickup and mod.IBS_Pickup.DeligenceWheat)
	if DeligenceWheat then
		--避免同一个小麦被多个勤劳盯上
		local target = self._Finds:ClosestEntity(npc.Position, 5, DeligenceWheat.Variant, 0, function(ent)
			local diligence = self._Ents:GetTempData(ent).DiligenceWheatTarget
			if diligence and diligence:Exists() and not diligence:IsDead() then
				if not self._Ents:IsTheSame(npc, diligence) then
					return false
				end
			end
			return true
		end)
		
		if target then
			--清除其他小麦的记录
			for _,wheat in ipairs(Isaac.FindByType(5, DeligenceWheat.Variant)) do
				if self._Ents:IsTheSame(npc, self._Ents:GetTempData(wheat).DiligenceWheatTarget) then
					self._Ents:GetTempData(wheat).DiligenceWheatTarget = nil
				end
			end
			self._Ents:GetTempData(target).DiligenceWheatTarget = npc

			local vec = target.Position - npc.Position
			local A = vec:Resized(math.max(1, vec:Length() / 150))
			if friendly then A = A/2 end
			
			npc.Velocity = npc.Velocity + A	
		end
	end

	--头部动画
	local dir = -1
	dir = self._Maths:VectorToDirection(npc.Velocity:Normalized())

	if dir == Direction.LEFT then 
		spr:SetFrame("HeadLeft", 1)
	elseif dir == Direction.RIGHT then		
		spr:SetFrame("HeadRight", 1)
	elseif dir == Direction.UP then
		spr:SetFrame("HeadUp", 1)
	elseif dir == Direction.DOWN then
		spr:SetFrame("HeadDown", 1)
	end	
end

--工人行为
function Diligence:OnNpcUpdate2(npc)
    if (npc.Variant ~= self.Variant) then return end
    if (npc.SubType ~= self.SubType.Worker) then return end
	local spr = npc:GetSprite()
	if spr:IsPlaying('GhostAppear') then return end
	local data = self:GetData(npc)
	local friendly = npc:HasEntityFlags(EntityFlag.FLAG_FRIENDLY)

	--存在一定时间后离开,除非友好
	if not friendly and npc.FrameCount >= 1200 then
		if not game:IsGreedMode() then

			--随机饰品
			do
				local itemPool = game:GetItemPool()
				Isaac.Spawn(5, 350, itemPool:GetTrinket(), npc.Position, RandomVector() / 2, nil)
			end
			
			--50%额外掉落灯
			if npc:GetDropRNG():RandomInt(100) <= 50 then
				local pos = game:GetRoom():FindFreePickupSpawnPosition(npc.Position)
				Isaac.Spawn(5, 100, IBS_ItemID.LODI, pos, Vector.Zero, nil)
			end
		end
		
		self._Ents:CopyAnimation(npc, npc.Position, 30, "LostDeath")
		npc:Remove()
		
		return
	end

	--身体动画
	spr:PlayOverlay("Dripping", false)

	if data.InvincibleFrames > 0 then
		data.InvincibleFrames = data.InvincibleFrames - 1
		
		--无敌闪烁
		if npc:IsFrame(2,0) then
			npc.Visible = false
		else
			npc.Visible = true
		end
	else
		npc.Visible = true
	end

	local target = nil
	local vec = Vector.Zero

	--在友好状态下目标改为最近的敌人,如果没有则仍为玩家
	if friendly then
		target = self._Finds:ClosestEnemy(npc.Position)
		if target == nil then
			target = self._Finds:ClosestPlayer(npc.Position)
		end
	else
		target = self._Finds:ClosestPlayer(npc.Position)
	end	

	if target then
		vec = target.Position - npc.Position
		local A =  vec:Resized(math.max(2, vec:Length() / 150))
		
		--保持一定距离
		local distance = (target.Position:Distance(npc.Position)) ^ 2
		if distance > (150 + target.Size ) ^ 2 then
			npc.Velocity = npc.Velocity + A	
		elseif distance < (140 + target.Size) ^ 2 then
			npc.Velocity = npc.Velocity - A	
		end
		
		--切换至攻击
		if npc.State == self.State.Walk then
			if data.Wait > 0 then
				data.Wait = data.Wait - 1

				--攻击预警
				if data.Wait == 15 then				
					npc:SetColor(Color(1, 1, 1, 1, 1,1,1),10,7,true)
					sfx:Play(171)
				end
			else
				data.Wait = 3
				npc.State = self.State.Attack
			end
		end
	end

	local dir = -1
	dir = self._Maths:VectorToDirection(vec:Normalized())

	--头部动画
	if npc.State == self.State.Walk then	
		if dir == Direction.LEFT then 
			spr:SetFrame("HeadLeft", 1)
		elseif dir == Direction.RIGHT then		
			spr:SetFrame("HeadRight", 1)
		elseif dir == Direction.UP then
			spr:SetFrame("HeadUp", 1)
		elseif dir == Direction.DOWN then
			spr:SetFrame("HeadDown", 1)
		end	
	elseif npc.State == self.State.Attack then --攻击
		if dir == Direction.LEFT then 
			spr:SetFrame("HeadLeft", 3)
		elseif dir == Direction.RIGHT then		
			spr:SetFrame("HeadRight", 3)
		elseif dir == Direction.UP then
			spr:SetFrame("HeadUp", 3)
		elseif dir == Direction.DOWN then
			spr:SetFrame("HeadDown", 3)
		end	

		--发射锤子并切换至行走
		if data.Wait > 0 then
			data.Wait = data.Wait - 1
		else
			if friendly then
				local DiligenceHammerTear = (mod.IBS_Tear and mod.IBS_Tear.DiligenceHammerTear)
				if DiligenceHammerTear then
					local tear = Isaac.Spawn(2, DiligenceHammerTear.Variant, 0, npc.Position, vec:Resized(15), npc):ToTear()
					tear.Height = -30
					tear.FallingSpeed = -10
					tear.FallingAcceleration = 0.1*math.random(15,25)
					tear.CollisionDamage = 35
				end			
				data.Wait = math.random(30,60)
			else			
				local DiligenceHammer = (mod.IBS_Proj and mod.IBS_Proj.DiligenceHammer)
				if DiligenceHammer then
					local proj = Isaac.Spawn(9, DiligenceHammer.Variant, 0, npc.Position, vec:Resized(15), npc):ToProjectile()
					proj.Height = -30
					proj.FallingSpeed = -10
					proj.FallingAccel = 0.1*math.random(15,25)
				end
				data.Wait = math.random(90,120)
			end
		
			npc.State = self.State.Walk
		end
	end
end
Diligence:AddCallback(ModCallbacks.MC_NPC_UPDATE, 'OnNpcUpdate1', Diligence.Type)
Diligence:AddCallback(ModCallbacks.MC_NPC_UPDATE, 'OnNpcUpdate2', Diligence.Type)

--受伤判定
function Diligence:OnTakeDMG(ent, dmg, flag, source)
	local npc = ent:ToNPC()
	if not npc or (npc.Variant ~= self.Variant) then return end
	local data = self:GetData(npc)

	--友好状态相同的勤劳之间免疫伤害
	local friendly = npc:HasEntityFlags(EntityFlag.FLAG_FRIENDLY)
	local ent = self._Ents:GetSourceEnemy(source.Entity)
	if ent ~= nil and friendly == ent:HasEntityFlags(EntityFlag.FLAG_FRIENDLY) then
		return false
	end

	--无敌状态
	if data.InvincibleFrames > 0 then
		return false
	end

	--小麦收集足够时免伤
	if dmg >= npc.HitPoints and data.WheatCollected >= 4 then
		data.WheatCollected = data.WheatCollected - 4
		data.InvincibleFrames = data.InvincibleFrames + 70

		--特效
		local effect = Isaac.Spawn(1000, 16, 11, npc.Position, Vector.Zero, npc):ToEffect()
		effect:FollowParent(npc)
		effect.SpriteScale = npc.SpriteScale
		effect:GetSprite().Color = Color(1,1,0,1)
		effect:Update()
		
		sfx:Play(SoundEffect.SOUND_HOLY_MANTLE)
				
		return false
	end	
end
Diligence:AddPriorityCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, -777, 'OnTakeDMG', 46)


--替换懒惰的掉落物
function Diligence:OnPickupInit(pickup)
	local ent = pickup.SpawnerEntity
	if ent and ent.Type == 46 and ent.Variant == self.Variant then
		pickup:Remove()
	end
end
Diligence:AddCallback(ModCallbacks.MC_POST_PICKUP_INIT, 'OnPickupInit')

--死亡
function Diligence:OnNpcDeath(npc)
	if (npc.SpawnerType == EntityType.ENTITY_PLAYER) or game:IsGreedMode() then return end
	if (npc.Variant ~= Diligence.Variant) then return end
	local int = npc:GetDropRNG():RandomInt(100)
	local pos = game:GetRoom():FindFreePickupSpawnPosition(npc.Position)
	
	if npc.SubType == Diligence.SubType.Farmer then
		local SeedBag = (mod.IBS_Pickup and mod.IBS_Pickup.SeedBag)
	
		--20%额外掉落农场
		if int <= 20 then
			Isaac.Spawn(5, 100, IBS_ItemID.PortableFarm, pos, Vector.Zero, nil)
		end
		
		--25%额外掉落偶像
		if int > 20 and int <= 40 then
			Isaac.Spawn(5, 100, IBS_ItemID.MODE, pos, Vector.Zero, nil)
		end

		--种子袋
		if SeedBag then
			Isaac.Spawn(5, SeedBag.Variant, SeedBag.SubType, pos, RandomVector() / 2, nil)
			Isaac.Spawn(5, SeedBag.Variant, SeedBag.SubType, pos, RandomVector() / 2, nil)
		end
	elseif npc.SubType == Diligence.SubType.Worker then
		local itemPool = game:GetItemPool()
	
		--20%额外掉落熔炉
		if int <= 20 then
			Isaac.Spawn(5, 100, 479, pos, Vector.Zero, nil)
		end
		
		--25%额外掉落灯
		if int > 20 and int <= 40 then
			Isaac.Spawn(5, 100, IBS_ItemID.LODI, pos, Vector.Zero, nil)
		end		
		
		--两个随机饰品
		for i = 1,2 do			
			Isaac.Spawn(5, 350, itemPool:GetTrinket(), pos, RandomVector() / 2, nil)
		end
	end
end
Diligence:AddCallback(ModCallbacks.MC_POST_NPC_DEATH, 'OnNpcDeath', 46)



return Diligence