--谦逊
--(偷懒套用了傲慢的id,多省事)

local mod = Isaac_BenightedSoul
local IBS_BossID = mod.IBS_BossID
local IBS_ItemID = mod.IBS_ItemID
local IBS_PocketID = mod.IBS_PocketID
local IBS_TrinketID = mod.IBS_TrinketID
local IBS_PlayerKey = mod.IBS_PlayerKey

local game = Game()
local sfx = SFXManager()

local Humility = mod.IBS_Class.Entity{
	Type = IBS_BossID.Humility.Type,
	Variant = IBS_BossID.Humility.Variant,
	SubType = IBS_BossID.Humility.SubType,
	Name = {zh = '谦逊', en = 'Humility'}
}

--是否可出现
function Humility:CanAppear()
	if not self:GetIBSData('persis')['boss_humility'] then return false end

	--表表抹检测
	if game:GetRoom():GetType() == RoomType.ROOM_MINIBOSS and PlayerManager.AnyoneIsPlayerType(mod.IBS_PlayerID.BMaggy) then
		return false
	end
	if self:GetIBSData('persis')[IBS_PlayerKey.BJudas].FINISHED and (game:GetRoom():GetType() ~= RoomType.ROOM_BOSS) then
		return true
	end
	return false
end

--状态
Humility.State = {
	Walk = 20,
	Attack = 21
}

--临时数据
function Humility:GetData(npc)
	local data = self._Ents:GetTempData(npc)
	data.Humility_Boss = data.Humility_Boss or {Wait = 0, Alpha = 1, AlphaDown = true}
	return data.Humility_Boss
end

--临时眼泪数据
function Humility:GetTearData(tear)
	local data = self._Ents:GetTempData(tear)
	data.Humility_Tear = data.Humility_Tear or {Friendly = false, Target = nil}
	return data.Humility_Tear
end


--初始化
function Humility:OnNpcInit(npc)
	if npc.Variant == Humility.Variant then
		npc:GetSprite():Play("Appear", true)
		npc.State = self.State.Walk
		npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_WALLS --飞行
		self:GetData(npc).Wait = math.random(30, 90)
		self:DelayFunction(function()
			local portal = Isaac.Spawn(306, 0, 0, npc.Position, Vector.Zero, npc) --传送门
			if npc:HasEntityFlags(EntityFlag.FLAG_FRIENDLY)	then
				portal:AddCharmed(EntityRef(npc.SpawnerEntity or Isaac.GetPlayer(0)), -1)
			end	
		end, 1)
	elseif (npc.Variant <= 1) and self:CanAppear() then
		--尝试替换傲慢
		local rng = RNG(npc.InitSeed)
		local int = rng:RandomInt(100)
		local replac = false
		
		--傲慢
		if npc.Variant == 0 and int < 25 then
			replac = true
		end
		
		--超级傲慢
		if npc.Variant == 1 and int < 40 then
			replac = true
		end

		if replac then
			Isaac.Spawn(Humility.Type, Humility.Variant, 0, npc.Position, Vector.Zero, nil)
			npc:Remove()

			--提示
			self:DelayFunction(function()
				game:GetHUD():ShowItemText(self:ChooseLanguage('傲慢有些不对劲 ?', 'Pride ?'), self:ChooseLanguage('谦逊 !', 'Humility !'))
			end, 30)
		end
	end
end
Humility:AddCallback(ModCallbacks.MC_POST_NPC_INIT, 'OnNpcInit', 52)

--行为
function Humility:OnNpcUpdate(npc)
    if (npc.Variant ~= self.Variant) then return end
	local spr = npc:GetSprite()
	if spr:IsPlaying('Appear') then return end

	local data = self:GetData(npc)
	local friendly = npc:HasEntityFlags(EntityFlag.FLAG_FRIENDLY)

	--切换状态
	if data.Wait > 0 then
		data.Wait = data.Wait - 1
	else
		if npc.State == self.State.Walk then
			npc.State = self.State.Attack
		end
	end

	--行走状态
	if npc.State == self.State.Walk then
		--身体动画
		spr:Play("Walk", false)

		--移动
		if npc:IsFrame(20,0) then
			--友好状态下尝试与玩家保持距离,没有玩家生成者则远离敌怪
			if friendly then 
				local ent = npc.SpawnerEntity
				if ent then
					if ent.Position:Distance(npc.Position) < math.random(70,140) then
						npc.Velocity = npc.Velocity + (npc.Position - ent.Position):Normalized() * 16
					else
						npc.Velocity = npc.Velocity + (npc.Position - ent.Position):Normalized() * -16
					end
				else
					npc.Pathfinder:MoveRandomly()
					npc.Velocity = npc.Velocity:Normalized() * -20
				end
			else
				npc.Pathfinder:MoveRandomly()
				npc.Velocity = npc.Velocity:Normalized() * 20
			end
		end

		--头部动画
		local dir = -1
		dir = self._Maths:VectorToDirection(npc.Velocity:Normalized())

		if dir == Direction.LEFT then 
			spr:SetOverlayFrame("HeadLeft", 1)
		elseif dir == Direction.RIGHT then		
			spr:SetOverlayFrame("HeadRight", 1)
		elseif dir == Direction.UP then
			spr:SetOverlayFrame("HeadUp", 1)
		elseif dir == Direction.DOWN then
			spr:SetOverlayFrame("HeadDown", 1)
		end	
	end

	--攻击状态
	if npc.State == self.State.Attack then
		local int = 20

		--没有传送门时概率提升
		if #Isaac.FindByType(306) <= 0 then 
			int = 4
		end

		if math.random(1,int) == 1 then --尝试召唤传送门
			if friendly then
				if self._Finds:ClosestEnemy(npc.Position) ~= nil then
					Isaac.Spawn(306, 0, 0, npc.Position, Vector.Zero, npc):AddCharmed(EntityRef(npc.SpawnerEntity or Isaac.GetPlayer(0)), -1)
				end
			else
				Isaac.Spawn(306, 0, 0, npc.Position, Vector.Zero, npc)
			end
		else
			local color = Color(1,1,1, math.max(0.2, data.Alpha))
			color:SetColorize(1,1,1,1)

			--发射特殊眼泪
			for i = 1,12 do
				local tear = Isaac.Spawn(2, 0, 0, npc.Position, Vector.FromAngle(i*30)*10, npc):ToTear()
				tear.TearFlags = TearFlags.TEAR_SPECTRAL
				tear.Color = color
				self:GetTearData(tear).Friendly = friendly
			end
			for _,ent in ipairs(Isaac.FindInRadius(npc.Position, 280, EntityPartition.ENEMY)) do
				if not self._Ents:IsTheSame(npc, ent) then
					local entFriendly = ent:HasEntityFlags(EntityFlag.FLAG_FRIENDLY)
					if (friendly and entFriendly) or (not friendly and not entFriendly) then
						local tear = Isaac.Spawn(2, 0, 0, npc.Position, (ent.Position - npc.Position):Normalized()*20, npc):ToTear()
						tear.TearFlags = TearFlags.TEAR_SPECTRAL
						tear.Color = color
						self:GetTearData(tear).Friendly = friendly
						self:GetTearData(tear).Target = ent
					end
				end
			end
		end

		--切换至行走
		data.Wait = math.random(30,60)
		npc.State = self.State.Walk
	end

	--调整透明度
	if friendly then
		data.Alpha = 1
	else
		if data.AlphaDown then
			if data.Alpha > -1 then 
				data.Alpha = data.Alpha - 0.01
			else
				data.AlphaDown = false
			end
		else
			if data.Alpha < 1 then
				data.Alpha = data.Alpha + 0.02
			else
				data.AlphaDown = true
			end
		end
	end

	npc:SetColor(Color(1, 1, 1, data.Alpha), -1, 7, true)
end
Humility:AddCallback(ModCallbacks.MC_NPC_UPDATE, 'OnNpcUpdate', Humility.Type)

--特殊眼泪给怪回血
function Humility:PreTearCollision(tear, other)
	local data = self._Ents:GetTempData(tear).Humility_Tear
	if not data then return end
	if not self._Ents:IsEnemy(other, true, true) then return end
	local friendly = other:HasEntityFlags(EntityFlag.FLAG_FRIENDLY)

	--不会给谦逊自身治疗
	if self._Ents:IsTheSame(other, tear.SpawnerEntity) then	
		return true
	end

	--友好状态兼容,给友好怪回血
	if data.Friendly then
		if friendly then
			tear:Die()
			other.HitPoints = math.min(other.MaxHitPoints, other.HitPoints + 0.15 * other.MaxHitPoints)
		end
	else --给敌怪回血
		if not friendly then
			tear:Die()
			other.HitPoints = math.min(other.MaxHitPoints, other.HitPoints + 0.25 * other.MaxHitPoints)
		end
	end

	return true
end
Humility:AddCallback(ModCallbacks.MC_PRE_TEAR_COLLISION, 'PreTearCollision')


--眼泪更新
function Humility:OnTearUpdate(tear)
	local data = self._Ents:GetTempData(tear).Humility_Tear
	if not data then return end
	local friendly = data.Friendly

	--追踪附近的目标
	local target = self._Finds:ClosestEntityInTable(tear.Position, Isaac.FindInRadius(tear.Position, 100, EntityPartition.ENEMY), function(ent)
		local entFriendly = ent:HasEntityFlags(EntityFlag.FLAG_FRIENDLY)
		return (not self._Ents:IsTheSame(ent, tear.SpawnerEntity)) and ((friendly and entFriendly) or (not friendly and not entFriendly))
	end)
	if target and (not data.Target or (data.Target:IsDead() or not data.Target:Exists()) or data.Target.Position:Distance(tear.Position) > 100) then
		data.Target = target
	end
	if data.Target then
		tear.Velocity = tear.Velocity + (data.Target.Position - tear.Position):Normalized()
	end
end
Humility:AddCallback(ModCallbacks.MC_POST_TEAR_UPDATE, 'OnTearUpdate')


--替换傲慢的掉落物
function Humility:OnPickupInit(pickup)
	local ent = pickup.SpawnerEntity
	if ent and ent.Type == 52 and ent.Variant == Humility.Variant then
		pickup:Remove()
	end
end
Humility:AddCallback(ModCallbacks.MC_POST_PICKUP_INIT, 'OnPickupInit')

--死亡
function Humility:OnNpcDeath(npc)
	if (npc.SpawnerType == EntityType.ENTITY_PLAYER) or game:IsGreedMode() then return end
	if (npc.Variant ~= Humility.Variant) then return end
	local int = npc:GetDropRNG():RandomInt(100)
	
	--25%红钥匙碎片
	local V = 300
	local S = 78

	--50%符文
	if int < 50 then 
		S = game:GetItemPool():GetCard(npc.InitSeed, false, true, true)
	elseif int >= 50 and int < 75 then --25%谦逊之径
		V = 100
		S = IBS_ItemID.ROH
	end

	Isaac.Spawn(5, V, S, game:GetRoom():FindFreePickupSpawnPosition(npc.Position), RandomVector() / 2, nil)
end
Humility:AddCallback(ModCallbacks.MC_POST_NPC_DEATH, 'OnNpcDeath', 52)



return Humility