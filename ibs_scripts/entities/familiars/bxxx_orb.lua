--伪忆球

local mod = Isaac_BenightedSoul
local IBS_FamiliarID = mod.IBS_FamiliarID
local TempIronHeart = mod.IBS_Class.TempIronHeart()
local Memories = mod.IBS_Class.Memories()

local game = Game()
local sfx = SFXManager()
local config = Isaac.GetItemConfig()

local BXXXOrb = mod.IBS_Class.Familiar{
	Variant = IBS_FamiliarID.BXXXOrb.Variant,
	SubType = IBS_FamiliarID.BXXXOrb.SubType,
	Name = {zh = '伪忆球', en = 'Falsehood Orb'}
}

--获取数据
function BXXXOrb:GetData(familiar)
	local data = self._Ents:GetTempData(familiar)
	data.BXXXOrb = data.BXXXOrb or {
		--CD = 0,
		CachedEffect = -1,
	}
	
	return data.BXXXOrb
end

--获取对应伪忆贴图路径
function BXXXOrb:GetPNGPath(subType)
	local path = 'gfx/ibs/familiar/bxxx_orb/'
	local player = 'bisaac'
	
	for k,v in pairs(self.SubType) do
		if subType == v then
			player = string.lower(k)
			break
		end
	end

	return path..player..'.png'
end

--初始化
function BXXXOrb:OnFamiliarInit(familiar)
	local spr = familiar:GetSprite()
	local path = self:GetPNGPath(familiar.SubType)

	--修改贴图(非常好偷懒方式)
	spr:ReplaceSpritesheet(0, path)
	spr:ReplaceSpritesheet(1, path)
	spr:ReplaceSpritesheet(3, path, true)
	spr.Scale = Vector(0.5, 0.5)
	spr:Play('Idle')
	
	familiar.DepthOffset = 50 --使图层处于上层
    familiar:AddToOrbit(725)
	familiar.OrbitDistance = Vector(60,60)
	familiar.OrbitSpeed = 0.02
	familiar:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
	familiar:SetColor(Color(1,1,1,0), 120, 1, true, true)
end
BXXXOrb:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, 'OnFamiliarInit', BXXXOrb.Variant)


--获取双子球当前复制的伪忆球
function BXXXOrb:GetBJBEOrbMimics(player)
	if player:GetPlayerType() ~= mod.IBS_PlayerID.BXXX then return {} end
	local data = self._Players:GetData(player).BXXX
	if data and data.BJBEMimics then
		return data.BJBEMimics
	end
	return {}
end

--双子球是否复制了该伪忆球的能力
function BXXXOrb:HasBJBEOrbCopied(subType, player)
	for _,v in ipairs(self:GetBJBEOrbMimics(player)) do
		if v == subType then
			return true
		end
	end
	return false
end

--检查伪忆球效果(方便双子球兼容)
function BXXXOrb:CheckEffect(familiarSubType, subType, player)
	if familiarSubType == subType then
		return true
	end
	if familiarSubType == self.SubType.BJBE and self:HasBJBEOrbCopied(subType, player) then
		return true
	end
	return false
end

--查找伪忆球
function BXXXOrb:FindOrbs(player, subType, includeBJBE)
	if player:GetPlayerType() ~= mod.IBS_PlayerID.BXXX then return {} end
	local result = {}

	for _,ent in ipairs(Isaac.FindByType(3, BXXXOrb.Variant)) do
		local familiar = ent:ToFamiliar()
		if familiar and self._Ents:IsTheSame(familiar.Player, player) then
			--可选择是否包括双子球
			if familiar.SubType == subType or (includeBJBE and self:CheckEffect(familiar.SubType, subType, player)) then
				table.insert(result, familiar)
			end
		end
	end
	
	return result
end

--查找符合以撒球要求的道具
function BXXXOrb:FindBIsaacOrbItems(familiar, radius)
	if not familiar.Player then return {} end
	local result = {}

	for _,ent in ipairs(Isaac.FindInRadius(familiar.Position, radius or 30, EntityPartition.PICKUP)) do
		if ent:ToPickup() and ent.Variant == 100 and ent.SubType ~= 0 and config:GetCollectible(ent.SubType) then
			local itemConfig = config:GetCollectible(ent.SubType)
			
			--道具品质小于等于以撒球数量时重置
			if itemConfig and itemConfig.Quality and itemConfig.Quality <= #self:FindOrbs(familiar.Player, self.SubType.BIsaac, true) then 
				table.insert(result, ent:ToPickup())
			end
		end
	end

	return result
end

--查找符合夏娃球要求的敌弹
function BXXXOrb:FindBEveOrbProj(familiar, pos, radius)
	return self._Finds:ClosestEntity(pos, 9, -1, -1, function(ent)
		local proj = ent:ToProjectile()
		if proj and not proj:HasProjectileFlags(ProjectileFlags.CANT_HIT_PLAYER) and proj.Position:Distance(pos) ^ 2 <= radius ^ 2 then
			local data = self._Ents:GetTempData(proj)

			--防止多个夏娃球锁定同一个敌弹
			if data.BEveOrbProjPtr == nil or data.BEveOrbProjPtr == GetPtrHash(familiar) then		
				return true
			end
		end
		return false
	end)
end

--查找符合参孙球要求的目标(敌人或敌弹)
function BXXXOrb:FindBSamsonOrbTarget(familiar, pos, radius)
	local target = self._Finds:ClosestEnemy(pos) 

	if target == nil or (target.Position:Distance(pos) - target.Size) ^ 2 > radius ^ 2 then
		target = self._Finds:ClosestEntity(pos, 9, -1, -1, function(ent)
			local proj = ent:ToProjectile()
			if proj and not proj:HasProjectileFlags(ProjectileFlags.CANT_HIT_PLAYER) and proj.Position:Distance(pos) ^ 2 <= radius ^ 2 then
				return true
			end
			return false
		end)
	end

	return target
end

--查找符合莉莉丝球要求的道具ID
function BXXXOrb:FindBLilithOrbItemID(seed)
	local itemPool = game:GetItemPool()
	local lowest = 114514 --非常好数字(悲)
	local lastLowest = 114514
	local result = {}

	local pool = self._Pools:GetRoomPool(self._Levels:GetRoomUniqueSeed())
	for _,v in ipairs(itemPool:GetCollectiblesFromPool(pool)) do
		local id = v.itemID
		if itemPool:HasCollectible(id) then
			local itemConfig = config:GetCollectible(id)
			if itemConfig and itemConfig:IsAvailable() and not itemConfig:HasTags(ItemConfig.TAG_QUEST) then
				if itemConfig.Quality < lowest then
					lowest = itemConfig.Quality
					
					--如果比之前的品质更低,重置表
					if lowest < lastLowest then
						for key,value in pairs(result) do
							result[key] = nil
						end
					end
					lastLowest = lowest
					
					table.insert(result, id)
				end
			end	
		end
	end

	--抽取一个
	if #result > 0 then
		return result[RNG(seed):RandomInt(1, #result)] or result[1]
	end
	
	--默认返回早餐
	return 25
end

--设置亚波伦球缓存的符文ID
function BXXXOrb:SetBApollyonCachedRuneID(familiar, id)
	self._Ents:GetTempData(familiar).BApollyonOrbRune = id
end

--获取亚波伦球缓存的符文ID
function BXXXOrb:GetBApollyonCachedRuneID(familiar)
	return self._Ents:GetTempData(familiar).BApollyonOrbRune
end

--查找符合伯大尼球要求的道具
function BXXXOrb:FindBBethOrbItems(familiar, radius)
	if not familiar.Player then return {} end
	local Relic = mod.IBS_Pickup and mod.IBS_Pickup.Relic
	if not Relic then return {} end
	local result = {}

	for _,ent in ipairs(Isaac.FindInRadius(familiar.Position, radius or 30, EntityPartition.PICKUP)) do
		if ent:ToPickup() and ent.Variant == Relic.Variant and ent:ToPickup():GetVarData() > 0 then
			table.insert(result, ent:ToPickup())
		end
	end

	return result
end

--触发
function BXXXOrb:Trigger(familiar, subType)
	local data = self:GetData(familiar)
	data.CachedEffect = subType
	
	local spr = familiar:GetSprite()
	spr:Play('Trigger', true)
end

--触发效果
function BXXXOrb:TriggerEffect(familiar, subType)
	subType = subType or familiar.SubType
	local player = familiar.Player
	local level = game:GetLevel()

	--以撒球
	if self:CheckEffect(subType, self.SubType.BIsaac, player) and Memories:GetNum() >= 4 then	
		for _,pickup in ipairs(self:FindBIsaacOrbItems(familiar)) do
			local itemConfig = config:GetCollectible(pickup.SubType)

			if itemConfig then
				local pool = self._Pools:GetRoomPool(self._Levels:GetRoomUniqueSeed())
				local new = 25
				new = self._Pools:GetCollectibleWithQuality(self._Levels:GetRoomUniqueSeed(), itemConfig.Quality, pool, true)
				pickup:Morph(5,100,new,true)
				pickup.Touched = false
				Memories:Add(-3)
				player:AddCacheFlags(CacheFlag.CACHE_FIREDELAY, true)
				Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, pickup.Position, Vector.Zero, nil)
			end

			if Memories:GetNum() < 4 then
				break
			end
		end
	elseif self:CheckEffect(subType, self.SubType.BMaggy, player) then --抹大拉球
		local TIH = TempIronHeart:GetData(player)
		TIH.Num = TIH.Num + 1
	elseif self:CheckEffect(subType, self.SubType.BCain, player) then --该隐球
		local id = mod.IBS_TrinketID.WheatSeeds
		local smelted = false

		--吞下小麦种子
		for slot = 0,1 do
			if player:GetTrinket(slot) == id then
				player:TryRemoveTrinket(id)
				player:AddSmeltedTrinket(id, false)
				smelted = true
				sfx:Play(157)
			end

			--金饰品
			golden = id + 32768
			if player:GetTrinket(slot) == golden then
				player:TryRemoveTrinket(golden)
				player:AddSmeltedTrinket(golden, false)
				smelted = true
				sfx:Play(157)
			end		
		end

		if not smelted then
			Isaac.Spawn(5,350, id, familiar.Position, RandomVector(), familiar)
		end
	elseif self:CheckEffect(subType, self.SubType.BAbel, player) then --亚伯球
		local pos = game:GetRoom():FindFreePickupSpawnPosition(familiar.Position, 0, true)	
		local goat = Isaac.Spawn(891,0,0, pos, Vector.Zero, familiar):ToNPC()
		goat:MakeChampion(goat.InitSeed, ChampionColor.TINY)
		goat:AddCharmed(EntityRef(player), -1)
	elseif self:CheckEffect(subType, self.SubType.BJudas, player) then --犹大球
		for _,target in ipairs(Isaac.FindInRadius(player.Position, 130, EntityPartition.ENEMY)) do
			if self._Ents:IsEnemy(target) then
				target:AddWeakness(EntityRef(familiar), 45)
			end
		end
	elseif self:CheckEffect(subType, self.SubType.BEve, player) then --夏娃球
		local proj = self:FindBEveOrbProj(familiar, player.Position, 240)
		if proj then
			proj:Die()
		end
	elseif self:CheckEffect(subType, self.SubType.BEden, player) then --伊甸球
		local did = false

		for i = 1,169 do
			local roomData = level:GetRoomByIdx(i).Data					
			if roomData and roomData.Type ~= 0 and roomData.Type ~= 1 then
				local roomDesc = level:GetRoomByIdx(i)
				local flag = (1<<2)
				if roomDesc and roomDesc.DisplayFlags & flag <= 0 then
					roomDesc.DisplayFlags = roomDesc.DisplayFlags | flag
					did = true
					break
				end
			end
		end

		if not did then
			Memories:Add(3)
			player:AddCacheFlags(CacheFlag.CACHE_FIREDELAY, true)
		end

		level:UpdateVisibility()
		level:RemoveCurses(LevelCurse.CURSE_OF_THE_LOST)
	elseif self:CheckEffect(subType, self.SubType.BAzazel, player) then --阿撒泻勒球
		for _,target in ipairs(Isaac.FindInRadius(familiar.Position, 30, EntityPartition.ENEMY)) do
			if self._Ents:IsEnemy(target) then
				target:AddBleeding(EntityRef(familiar), 90)
			end
		end
	elseif self:CheckEffect(subType, self.SubType.BLazarus, player) then --拉撒路球
		Memories:Add(5)
		player:AddCacheFlags(CacheFlag.CACHE_FIREDELAY, true)
	elseif self:CheckEffect(subType, self.SubType.BLost, player) then --游魂球
		local room = game:GetRoom()
		local pos = room:FindFreePickupSpawnPosition(familiar.Position, 0, true)
		Isaac.Spawn(5, 50, 1, pos, Vector.Zero, nil, 0, false) --普通箱子
		Isaac.Spawn(1000, 15, 0, pos, Vector.Zero, nil, 0, false) --烟雾特效
	elseif self:CheckEffect(subType, self.SubType.BLilith, player) then --莉莉丝球
		local id = self:FindBLilithOrbItemID(self._Levels:GetRoomUniqueSeed())
		game:GetItemPool():RemoveCollectible(id)

		--特效
		if mod.IBS_Effect and mod.IBS_Effect.AbandonedItem then
			local itemConfig = config:GetCollectible(id)
			if itemConfig.GfxFileName then
				mod.IBS_Effect.AbandonedItem:Spawn(player.Position, itemConfig.GfxFileName, RandomVector() * 0.1 * math.random(9, 15))
			end
		end
		SFXManager():Play(267)
	elseif self:CheckEffect(subType, self.SubType.BKeeper, player) and mod.IBS_Pocket and mod.IBS_Pocket.BKeeper then --店主球
		local target = self._Finds:ClosestEnemy(familiar.Position)

		if target ~= nil and self._Ents:IsEnemy(target) then
			local dmg = 1 + 0.1 * mod.IBS_Pocket.BKeeper:GetData().Points
			local tear = familiar:FireProjectile((target.Position - familiar.Position):Normalized())
			tear:ChangeVariant(20)
			tear.CollisionDamage = dmg
			tear.Velocity = tear.Velocity * 0.1 * math.random(10, 15)
			tear.Scale = self._Tears:DamageToScale(dmg)
			tear:AddTearFlags(TearFlags.TEAR_SPECTRAL)
			tear:AddTearFlags(TearFlags.TEAR_PIERCING)
			tear:AddTearFlags(TearFlags.TEAR_HOMING)
			tear:AddTearFlags(TearFlags.TEAR_SHIELDED)
			tear:AddTearFlags(TearFlags.TEAR_FETUS)

			local color = Color(115/255, 99/255, 122/255, 0.25, 0, 0, 1)
			color:SetColorize(1,1,1,2)
			tear.Color = color
			tear:Update()
		end
	elseif self:CheckEffect(subType, self.SubType.BApollyon, player) then --亚波伦球
		if Memories:GetNum() >= 5 then
			local id = self:GetBApollyonCachedRuneID(familiar)
			if id then
				player:UseCard(id, UseFlag.USE_NOANIM | UseFlag.USE_NOANNOUNCER | UseFlag.USE_MIMIC)
				Memories:Add(-5)
				player:AddCacheFlags(CacheFlag.CACHE_FIREDELAY, true)
				self:SetBApollyonCachedRuneID(familiar, nil)
			end
		else
			self:SetBApollyonCachedRuneID(familiar, nil)
		end
	elseif self:CheckEffect(subType, self.SubType.BForgotten, player) then --遗骸球
		player:AddBoneOrbital(familiar.Position)
	elseif self:CheckEffect(subType, self.SubType.BBeth, player) and Memories:GetNum() >= 1 then --伯大尼球
		local Relic = mod.IBS_Pickup and mod.IBS_Pickup.Relic
		if Relic then
			for _,ent in ipairs(self:FindBBethOrbItems(familiar)) do
				local pickup = ent:ToPickup()
				local itemID = pickup:GetVarData()
				if itemID > 0 then
					Relic:UpdateRecord(itemID)
					Memories:Add(-1)
					player:AddCacheFlags(CacheFlag.CACHE_FIREDELAY, true)
				end

				if Memories:GetNum() < 1 then
					break
				end
			end
		end
	end
end

--更新
function BXXXOrb:OnFamiliarUpdate(familiar)
	local player = familiar.Player
	if not player then return end
	local spr = familiar:GetSprite()
	local data = self:GetData(familiar)
	local subType = familiar.SubType
	
	spr.Scale = Vector(0.5, 0.5)	
	familiar.OrbitDistance = Vector(60,60)
	familiar.OrbitSpeed = 0.02
    familiar.Velocity = (familiar:GetOrbitPosition(player.Position + Vector(0,-4) + player.Velocity) - familiar.Position)	

	--触发效果
	if spr:IsEventTriggered('Trigger') then
		self:TriggerEffect(familiar, data.CachedEffect)
		sfx:Play(SoundEffect.SOUND_FIREDEATH_HISS, 0.4, 0, false, 3)
	end
	
	--以撒球触发
	if self:CheckEffect(subType, self.SubType.BIsaac, player) and Memories:GetNum() >= 4 then
		data.Wait_1 = data.Wait_1 or 0
		if #self:FindBIsaacOrbItems(familiar) > 0 then
			if data.Wait_1 < 60 then
				data.Wait_1 = data.Wait_1 + 1
			else
				data.Wait_1 = 0
				self:Trigger(familiar, self.SubType.BIsaac)
			end
		else
			data.Wait_1 = 0
		end
	end
	
	--亚伯球触发
	if self:CheckEffect(subType, self.SubType.BAbel, player) and familiar:IsFrame(210,0) then
		local num = 0
		for _,ent in ipairs(Isaac.FindByType(891,0,0)) do
			if ent.SpawnerType == 3 and ent.SpawnerVariant == self.Variant then
				num = num + 1
			end
		end

		if num < 2 * #self:FindOrbs(player, self.SubType.BAbel, true) then
			self:Trigger(familiar, self.SubType.BAbel)		
		end
	end
	
	--犹大球触发
	if self:CheckEffect(subType, self.SubType.BJudas, player) and familiar:IsFrame(60,0) then
		for _,target in ipairs(Isaac.FindInRadius(player.Position, 130, EntityPartition.ENEMY)) do
			if self._Ents:IsEnemy(target) then	
				self:Trigger(familiar, self.SubType.BJudas)
				break
			end
		end
	end
	
	--夏娃球触发
	if self:CheckEffect(subType, self.SubType.BEve, player) and familiar:IsFrame(12,0) then
		local proj = self:FindBEveOrbProj(familiar, player.Position, 240)
		if proj then
			self._Ents:GetTempData(proj).BEveOrbProjPtr = GetPtrHash(familiar)	
			self:Trigger(familiar, self.SubType.BEve)
		end
	end

	--参孙球攻击
	if self:CheckEffect(subType, self.SubType.BSamson, player) then 
		data.Wait_3 = data.Wait_3 or 0
		if data.Wait_3 <= 0 then
			local cd = 20

			--受伤次数越多,攻速越快
			local falsehoodData = self._Players:GetData(player).FalsehoodBSamson
			if falsehoodData then
				cd = math.max(3, math.ceil(cd - 0.5 * falsehoodData.TotalHurtTimes))
			end

			data.Wait_3 = cd
		
			local Swing = mod.IBS_Effect and mod.IBS_Effect.Swing
			if Swing then
				local target = self:FindBSamsonOrbTarget(familiar, familiar.Position, 60)
				if target ~= nil then
					--为敌弹
					if target:ToProjectile() then
						target:Die()
					elseif self._Ents:IsEnemy(target) then --为敌人
						target:TakeDamage(14, 0, EntityRef(familiar), 0)
					end
					Swing:Spawn(familiar.Position, 90 + (familiar.Position - target.Position):GetAngleDegrees(), familiar)
					sfx:Play(252)
					self:Trigger(familiar, self.SubType.BSamson) --提供供特效XD
				end
			end
		else
			data.Wait_3 = data.Wait_3 -1
		end
	end
	
	--阿撒泻勒球碰撞伤害&触发
	if self:CheckEffect(subType, self.SubType.BAzazel, player) then
		data.Wait_4 = data.Wait_4 or 0
		if data.Wait_4 <= 0 then
			local dmg = 7
			
			--使用次数越多,伤害越高
			local falsehoodData = self:GetIBSData('temp').FalsehoodBAzazel
			if falsehoodData then
				dmg = dmg + falsehoodData.Sacrifice
			end	

			for _,target in ipairs(Isaac.FindInRadius(familiar.Position, 12, EntityPartition.ENEMY)) do
				if self._Ents:IsEnemy(target) then	
					target:TakeDamage(dmg, 0, EntityRef(familiar), 0)
				end
			end
			
			data.Wait_4 = 5
		else
			data.Wait_4 = data.Wait_4 - 1
		end
		if familiar:IsFrame(90,0) then
			for _,target in ipairs(Isaac.FindInRadius(familiar.Position, 24, EntityPartition.ENEMY)) do
				if self._Ents:IsEnemy(target) then	
					self:Trigger(familiar, self.SubType.BAzazel)
					break
				end
			end
		end
	end
	
	--店主球触发
	if self:CheckEffect(subType, self.SubType.BKeeper, player) then
		data.Wait_2 = data.Wait_2 or 0
		if data.Wait_2 <= 0 then
			data.Wait_2 = 30
			for _,target in ipairs(Isaac.FindInRadius(familiar.Position, 240, EntityPartition.ENEMY)) do
				if self._Ents:IsEnemy(target) then	
					self:Trigger(familiar, self.SubType.BKeeper)
					break
				end
			end
		else
			data.Wait_2 = data.Wait_2 - 1
		end
	end
	
	--遗骸球触发
	if self:CheckEffect(subType, self.SubType.BForgotten, player) then
		data.Wait_6 = data.Wait_6 or 0
		if data.Wait_6 < 150 then
			data.Wait_6 = data.Wait_6 + 1
		else
			data.Wait_6 = 0
			
			local num = 0
			for _,ent in ipairs(Isaac.FindByType(3,128)) do
				if ent:ToFamiliar() and self._Ents:IsTheSame(ent:ToFamiliar().Player, player) then
					num = num + 1
				end
			end

			if num < 6 * #self:FindOrbs(player, self.SubType.BForgotten, true) then
				self:Trigger(familiar, self.SubType.BForgotten)
			end
		end	
	end

	--伯大尼球触发
	if self:CheckEffect(subType, self.SubType.BBeth, player) and Memories:GetNum() >= 1 then 
		data.Wait_7 = data.Wait_7 or 0
		local Relic = mod.IBS_Pickup and mod.IBS_Pickup.Relic
		if Relic then
			if #self:FindBBethOrbItems(familiar) > 0 then
				if data.Wait_7 < 60 then
					data.Wait_7 = data.Wait_7 + 1
				else
					data.Wait_7 = 0
					self:Trigger(familiar, self.SubType.BBeth)
				end
			else
				data.Wait_7 = 0
			end
		end
	end
	
	if spr:IsFinished('Trigger') then
		spr:Play('Idle')
	end
end
BXXXOrb:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, 'OnFamiliarUpdate', BXXXOrb.Variant)

--亚波伦球更新
function BXXXOrb:OnUpdate()
	for i = 0, game:GetNumPlayers() - 1 do
		local player = Isaac.GetPlayer(i)
		for _,ent in ipairs(self:FindOrbs(player, self.SubType.BApollyon, true)) do
			local familiar = ent:ToFamiliar()
			if familiar then
				local data = self:GetData(familiar)
				data.Wait_5 = data.Wait_5 or 0
				local id = self:GetBApollyonCachedRuneID(familiar)
				if id then
					if data.Wait_5 < 90 then
						data.Wait_5 = data.Wait_5 + 1
					else
						data.Wait_5 = 0
						self:Trigger(familiar, self.SubType.BApollyon)

						-- 延长其他亚波伦球的等待时间
						for _,ent2 in ipairs(self:FindOrbs(player, self.SubType.BApollyon, true)) do
							if not self._Ents:IsTheSame(ent2, familiar) then
								local otherData = self:GetData(ent2)
								otherData.Wait_5 = otherData.Wait_5 - 60
							end
						end
					end
				else
					data.Wait_5 = 0
				end
			else
				self:SetBApollyonCachedRuneID(familiar, nil)
			end
		end
	end
end
BXXXOrb:AddCallback(ModCallbacks.MC_POST_UPDATE, 'OnUpdate')

--退出游戏时候清除亚伯球生成的山羊
function BXXXOrb:ClearGoats()
	for _,ent in ipairs(Isaac.FindByType(891,0,0)) do
		if ent.SpawnerType == 3 and ent.SpawnerVariant == self.Variant then
			ent:ClearEntityFlags(EntityFlag.FLAG_FRIENDLY)
			ent:Remove()
		end
	end
end
BXXXOrb:AddCallback(ModCallbacks.MC_PRE_GAME_EXIT, 'ClearGoats')

--清除亚伯球生成的山羊的掉落物
function BXXXOrb:ClearGoatDrop(pickup)
	local ent = pickup.SpawnerEntity
	if ent and ent.Type == 891 and ent.Variant == 0 and ent.SubType == 0 then
		if ent.SpawnerType == 3 and ent.SpawnerVariant == self.Variant then
			pickup:Remove()
		end
	end
end
BXXXOrb:AddCallback(ModCallbacks.MC_POST_PICKUP_INIT, 'ClearGoatDrop')

--清理房间触发
function BXXXOrb:OnRoomCleaned()
	for _,ent in ipairs(Isaac.FindByType(3, self.Variant)) do
		local player = (ent:ToFamiliar() and ent:ToFamiliar().Player) or Isaac.GetPlayer(0)
		local subType = ent.SubType
	
		--抹大拉球
		if self:CheckEffect(subType, self.SubType.BMaggy, player) then
			self:Trigger(ent, self.SubType.BMaggy)
		elseif self:CheckEffect(subType, self.SubType.BEden, player) then
			--伊甸球
			self:Trigger(ent, self.SubType.BEden)
		elseif self:CheckEffect(subType, self.SubType.BCain, player) and self:GetRNG('Familiar_Orb_BCain'):RandomInt(1,3) == 3 then
			--该隐球
			self:Trigger(ent, self.SubType.BCain)
		elseif self:CheckEffect(subType, self.SubType.BLost, player) and self:GetRNG('Familiar_Orb_BLost'):RandomInt(100) < 20 then
			--游魂球
			self:Trigger(ent, self.SubType.BLost)
		end
	end
end
BXXXOrb:AddCallback(ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD, 'OnRoomCleaned')
BXXXOrb:AddCallback(mod.IBS_CallbackID.GREED_NEW_WAVE, 'OnRoomCleaned')

--新房间触发
function BXXXOrb:OnNewRoom()
	local room = game:GetRoom()

	if room:IsFirstVisit() then
		--拉撒路球
		if room:GetType() ~= RoomType.ROOM_DEFAULT then
			for _,ent in ipairs(Isaac.FindByType(3, self.Variant)) do
				local player = (ent:ToFamiliar() and ent:ToFamiliar().Player) or Isaac.GetPlayer(0)
				if self:CheckEffect(ent.SubType, self.SubType.BLazarus, player) then
					self:Trigger(ent, self.SubType.BLazarus)
				end
			end
		end

		--莉莉丝球
		for _,ent in ipairs(Isaac.FindByType(3, self.Variant)) do
			local player = (ent:ToFamiliar() and ent:ToFamiliar().Player) or Isaac.GetPlayer(0)
			if self:CheckEffect(ent.SubType, self.SubType.BLilith, player) then
				self:Trigger(ent, self.SubType.BLilith)
			end
		end
	end
end
BXXXOrb:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, 'OnNewRoom')

--贪婪模式新波次触发
function BXXXOrb:OnGreedNewWave()
	--莉莉丝球
	for _,ent in ipairs(Isaac.FindByType(3, self.Variant)) do
		local player = (ent:ToFamiliar() and ent:ToFamiliar().Player) or Isaac.GetPlayer(0)
		if self:CheckEffect(ent.SubType, self.SubType.BLilith, player) then
			self:Trigger(ent, self.SubType.BLilith)
		end
	end
end
BXXXOrb:AddCallback(mod.IBS_CallbackID.GREED_NEW_WAVE, 'OnGreedNewWave')

--受伤触发
function BXXXOrb:OnTakeDMG(ent, dmg, flag, source)
	local player = ent:ToPlayer()
	if player then
		for _,ent in pairs(self:FindOrbs(player, self.SubType.BMaggy, true)) do
			self:Trigger(ent, self.SubType.BMaggy)
		end
	end
end
BXXXOrb:AddCallback(ModCallbacks.MC_POST_ENTITY_TAKE_DMG, 'OnTakeDMG')

--使用卡牌触发
function BXXXOrb:OnUseCard(card, player, flag)
	--非收获符文
	if card == 33 then return end

	--亚波伦球
	if card ~= mod.IBS_PocketID.BApollyon and flag & UseFlag.USE_MIMIC <= 0 and Memories:GetNum() >= 5 then
		--检测是否为符文
		local cardConfig = config:GetCard(card)
		if cardConfig and cardConfig.CardType == ItemConfig.CARDTYPE_RUNE then
			for _,ent in pairs(self:FindOrbs(player, self.SubType.BApollyon, true)) do
				self:SetBApollyonCachedRuneID(ent, card)
				--self:Trigger(ent, self.SubType.BApollyon)
			end
		end
	end
end
BXXXOrb:AddCallback(ModCallbacks.MC_USE_CARD, 'OnUseCard')

return BXXXOrb