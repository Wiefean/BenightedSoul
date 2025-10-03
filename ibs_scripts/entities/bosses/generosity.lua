--慷慨
--(偷懒套用了贪婪的id,多省事)

local mod = Isaac_BenightedSoul
local IBS_BossID  = mod.IBS_BossID
local IBS_ItemID = mod.IBS_ItemID
local IBS_PocketID = mod.IBS_PocketID
local IBS_TrinketID = mod.IBS_TrinketID
local IBS_PlayerKey = mod.IBS_PlayerKey

local game = Game()
local sfx = SFXManager()

local Generosity = mod.IBS_Class.Entity{
	Type = IBS_BossID.Generosity.Type,
	Variant = IBS_BossID.Generosity.Variant,
	SubType = IBS_BossID.Generosity.SubType,
	Name = {zh = '慷慨', en = 'Generosity'}
}

--是否可出现
function Generosity:CanAppear()
	if not self:GetIBSData('persis')['boss_generosity'] then return false end

	--表表抹检测
	if game:GetRoom():GetType() == RoomType.ROOM_MINIBOSS and PlayerManager.AnyoneIsPlayerType(mod.IBS_PlayerID.BMaggy) then
		return false
	end
	if self:GetIBSData('persis')[IBS_PlayerKey.BKeeper].FINISHED and (game:GetRoom():GetType() ~= RoomType.ROOM_BOSS) then
		return true
	end
	return false
end

--状态
Generosity.State = {
	Walk = 20,
	Bonus = 21,
}

--临时数据
function Generosity:GetData(npc)
	local data = self._Ents:GetTempData(npc)
	data.Generosity = data.Generosity or {
		Wait = 35,
		Grid = game:GetRoom():GetGridIndex(npc.Position),
		BonusTimes = 0,
	}
	return data.Generosity
end

--生成随机基础掉落
function Generosity:SpawnPickup(npc)
	local int = npc:GetDropRNG():RandomInt(1,4)
	local variant = 10 --心
	
	if int == 1 then
		variant = 20 --硬币
	elseif int == 2 then
		variant = 30 --钥匙
	elseif int == 3 then
		variant = 40 --炸弹
	end
	
	local pickup = Isaac.Spawn(5, variant, 0, npc.Position, math.random(5,10) * RandomVector(), nil):ToPickup()
	pickup.Timeout = 60
	
	return pickup
end

--初始化
function Generosity:OnNpcInit(npc)
	if npc.Variant == self.Variant then
		if npc.SubType == self.SubType.Generosity then
			npc:GetSprite():Play("Appear", true)
		elseif npc.SubType == self.SubType.Bum then
			npc:GetSprite():Play("Idle", true)
		end
		npc.State = self.State.Walk
		npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_WALLS --飞行
		self:GetData(npc).Wait = math.random(35, 70)
	elseif (npc.Variant <= 1) and self:CanAppear() then
		--尝试替换贪婪
		local room = game:GetRoom()
		local rng = RNG(npc.InitSeed)
		local int = rng:RandomInt(100)
		local replac = false
		
		--贪婪
		if npc.Variant == 0 and int < 10 then
			replac = true
		end
		
		--超级贪婪
		if npc.Variant == 1 and int < 20 then
			replac = true
		end

		if replac then
			local pos = room:FindFreePickupSpawnPosition(npc.Position, 0, true)
		
			Isaac.Spawn(self.Type, self.Variant, self.SubType.Generosity, npc.Position, Vector.Zero, nil)
			Isaac.Spawn(self.Type, self.Variant, self.SubType.Bum, pos, Vector.Zero, nil)
			npc:Remove()

			--提示
			self:DelayFunction(function()
				game:GetHUD():ShowItemText(self:ChooseLanguage('贪婪有些不对劲 ?', 'Greed ?'), self:ChooseLanguage('慷慨 !', 'Generosity !'))
			end, 30)
		end
	end
end
Generosity:AddCallback(ModCallbacks.MC_POST_NPC_INIT, 'OnNpcInit', 50)

--慷慨行为
function Generosity:OnNpcUpdate1(npc)
    if (npc.Variant ~= self.Variant) then return end
    if (npc.SubType ~= self.SubType.Generosity) then return end
	local room = game:GetRoom()
	local spr = npc:GetSprite()
	npc.SpriteOffset = Vector(0,-5)
	if spr:IsPlaying('Appear') then return end
	local data = self:GetData(npc)
	local friendly = npc:HasEntityFlags(EntityFlag.FLAG_FRIENDLY)

	--自动掉血
	npc.HitPoints = npc.HitPoints - 0.5

	--血量耗尽或奖励次数满后离开
	if npc.HitPoints <= 0 or data.BonusTimes >= 20 then
		if not friendly and not game:IsGreedMode() then
			--掉落慷慨之魂
			local pos = game:GetRoom():FindFreePickupSpawnPosition(npc.Position)
			Isaac.Spawn(5, 100, IBS_ItemID.SOG, pos, Vector.Zero, nil)
		end

		self._Ents:CopyAnimation(npc, npc.Position, 30, "Leave")
		npc:Remove()

		return
	end

	if npc.State == self.State.Walk then
		--向选定位置移动
		if data.Grid ~= room:GetGridIndex(npc.Position) then
			local vec = room:GetGridPosition(data.Grid) - npc.Position
			local A = vec:Resized(math.max(1, vec:Length() / 50))
			npc.Velocity = npc.Velocity + A
		end
		
		--切换至奖励
		if data.Wait > 0 then
			data.Wait = data.Wait - 1
			spr:SetFrame("Idle", 1)
		else
			data.Wait = math.random(35, 70)
			npc.State = self.State.Bonus
			spr:Play('Bonus', true)
			
			--友好状态下改为召唤乞丐
			if friendly then
				local bum = Isaac.Spawn(self.Type, self.Variant, self.SubType.Bum, npc.Position, RandomVector(), npc)
				bum:AddCharmed(EntityRef(npc.SpawnerEntity or Isaac.GetPlayer(0)), -1)
				Isaac.Spawn(1000, 15, 0, npc.Position, Vector.Zero, nil)
			else
				for i = 1,math.random(2,7) do			
					self:SpawnPickup(npc)
				end
			end
		end
	end
	
	--切换至行走
	if spr:IsFinished('Bonus') then
		npc.State = self.State.Walk
		
		--重新选定位置
		local width = room:GetGridWidth()
		local height = room:GetGridHeight()
		local x = math.random(1, width-1)
		local y = math.random(1, height-1)
		data.Grid = x + y * width
		
		if not friendly then
			data.BonusTimes = data.BonusTimes + 1
		end
	end
	
	--召唤乞丐
	if not friendly and npc:IsFrame(300,0) then
		Isaac.Spawn(self.Type, self.Variant, self.SubType.Bum, npc.Position, RandomVector(), npc)
		Isaac.Spawn(1000, 15, 0, npc.Position, Vector.Zero, nil)
	end
end

--乞丐行为
function Generosity:OnNpcUpdate2(npc)
    if (npc.Variant ~= self.Variant) then return end
    if (npc.SubType ~= self.SubType.Bum) then return end
	local spr = npc:GetSprite()
	local data = self:GetData(npc)
	local friendly = npc:HasEntityFlags(EntityFlag.FLAG_FRIENDLY)

	if not friendly then
		--避免同一个掉落物被多个乞丐盯上
		local target = self._Finds:ClosestEntity(npc.Position, 5, -1, -1, function(ent)
			local variant = ent.Variant
			if variant == 10 or variant == 20 or variant == 30 or variant == 40 then
				local bum = self._Ents:GetTempData(ent).GenerosityBumTarget
				if bum and bum:Exists() and not bum:IsDead() then
					if not self._Ents:IsTheSame(npc, bum) then
						return false
					end
				end
				return true
			end
			return false
		end)
		
		if target then
			--清除其他的记录
			for _,ent in ipairs(Isaac.FindByType(5)) do
				local variant = ent.Variant
				if variant == 10 or variant == 20 or variant == 30 or variant == 40 then
					if self._Ents:IsTheSame(npc, self._Ents:GetTempData(ent).GenerosityBumTarget) then
						self._Ents:GetTempData(ent).GenerosityBumTarget = nil
					end
				end
			end
			self._Ents:GetTempData(target).GenerosityBumTarget = npc

			local vec = target.Position - npc.Position
			local A = vec:Resized(1)
			npc.Velocity = npc.Velocity + A	
			
			--距离足够近时移除掉落物
			if vec:Length() <= 10 then
				Isaac.Spawn(1000, 15, 0, target.Position, Vector.Zero, nil)
				target:Remove()
			end
		else --跟随玩家
			target = self._Finds:ClosestPlayer(npc.Position)
			if target then		
				local vec = target.Position - npc.Position
				local A = vec:Resized(math.max(1, vec:Length() / 100))
				npc.Velocity = npc.Velocity + A				
			end
		end
	else --友好状态下发动自杀式袭击
		local target = self._Finds:ClosestEnemy(npc.Position)
		if target == nil then
			target = self._Finds:ClosestPlayer(npc.Position)
		end
		if target then
			local vec = target.Position - npc.Position
			local A = vec:Resized(1)
			npc.Velocity = npc.Velocity + A	
		end
	end
end
Generosity:AddCallback(ModCallbacks.MC_NPC_UPDATE, 'OnNpcUpdate1', Generosity.Type)
Generosity:AddCallback(ModCallbacks.MC_NPC_UPDATE, 'OnNpcUpdate2', Generosity.Type)

--受伤判定
function Generosity:OnTakeDMG(ent, dmg, flag, source)
	local npc = ent:ToNPC()
	if not npc or (npc.Variant ~= self.Variant) or (npc.SubType ~= self.SubType.Generosity) then return end
	if dmg > 5 then dmg = 5 end
	return {Damage = dmg}
end
Generosity:AddPriorityCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, -777, 'OnTakeDMG', 50)

--替换懒惰的掉落物
function Generosity:OnPickupInit(pickup)
	local ent = pickup.SpawnerEntity
	if ent and ent.Type == 50 and ent.Variant == self.Variant then
		pickup:Remove()
	end
end
Generosity:AddCallback(ModCallbacks.MC_POST_PICKUP_INIT, 'OnPickupInit')

--死亡
function Generosity:OnNpcDeath(npc)
	if (npc.SpawnerType == EntityType.ENTITY_PLAYER) or game:IsGreedMode() then return end
	if (npc.Variant ~= Generosity.Variant) then return end
	
	--掉落慷慨之魂
	if npc.SubType == self.SubType.Generosity then
		local pos = game:GetRoom():FindFreePickupSpawnPosition(npc.Position)
		Isaac.Spawn(5, 100, IBS_ItemID.SOG, pos, Vector.Zero, nil)
	end
end
Generosity:AddCallback(ModCallbacks.MC_POST_NPC_DEATH, 'OnNpcDeath', 50)



return Generosity