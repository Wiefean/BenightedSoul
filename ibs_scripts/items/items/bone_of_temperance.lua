--节制之骨

local mod = Isaac_BenightedSoul

local game = Game()

local BOT = mod.IBS_Class.Item(mod.IBS_ItemID.BOT)

--眼泪特效黑名单
BOT.TearFlagBlacklist = {
	--环绕(小星球,木星,无暇圣心)
	TearFlags.TEAR_ORBIT,
	TearFlags.TEAR_ORBIT_ADVANCED,

	--剖腹产
	TearFlags.TEAR_FETUS_SWORD,
	TearFlags.TEAR_FETUS_BONE,
	TearFlags.TEAR_FETUS_KNIFE,
	TearFlags.TEAR_FETUS_TECHX,
	TearFlags.TEAR_FETUS_TECH,
	TearFlags.TEAR_FETUS_BRIMSTONE,
	TearFlags.TEAR_FETUS_BOMBER,
	TearFlags.TEAR_FETUS,
	
	--锁链(遗骸等)
	TearFlags.TEAR_CHAIN,
	
	--悬浮科技
	TearFlags.TEAR_LUDOVICO
}

--检查条件
function BOT:CheckTearCondition(tear)
	for _,flag in pairs(self.TearFlagBlacklist) do
		if tear:HasTearFlags(flag) then return false end
	end

	local SSG = mod.IBS_Item and mod.IBS_Item.SSG
	if SSG and SSG:IsFallingTear(tear) then return false end --判断是否为仰望星空的下落眼泪

	return true
end

--临时玩家数据
function BOT:GetPlayerData(player)
	local data = self._Ents:GetTempData(player)
	data.BoneOfTemperance_Player = data.BoneOfTemperance_Player or {TearsUp = 0}
	return data.BoneOfTemperance_Player
end

--临时眼泪数据(科X激光也可使用)
function BOT:GetTearData(tear)
	local data = self._Ents:GetTempData(tear)
	data.BoneOfTemperance_Tear = data.BoneOfTemperance_Tear or {
		Stop = false,
		Recycle = false,
		Timeout = 210
	}
	return data.BoneOfTemperance_Tear
end

--临时妈刀数据(常规激光也可使用)
function BOT:GetKnifeData(knife)
	local data = self._Ents:GetTempData(knife)
	data.BoneOfTemperance_Knife = data.BoneOfTemperance_Knife or {Wait = 0}

	return data.BoneOfTemperance_Knife
end

--眼泪发射
function BOT:OnFireTear(tear)
	local player = self._Ents:IsSpawnerPlayer(tear, true)
	
    if player and player:HasCollectible(self.ID) and self:CheckTearCondition(tear) then
		local data = self:GetTearData(tear)

		--突眼
		if tear:HasTearFlags(TearFlags.TEAR_SHRINK) then
			tear:ClearTearFlags(TearFlags.TEAR_SHRINK) 
		end
    end
end
BOT:AddCallback(ModCallbacks.MC_POST_FIRE_TEAR, 'OnFireTear')

function BOT:OnTearUpdate(tear)
	local data = self._Ents:GetTempData(tear).BoneOfTemperance_Tear
	local player = self._Ents:IsSpawnerPlayer(tear, true)

	--判断是否为仰望星空的下落眼泪
	local SSG = mod.IBS_Item and mod.IBS_Item.SSG
	if SSG and SSG:IsFallingTear(tear) then return end

	if data and player then
		tear.FallingSpeed = 0
		tear.FallingAcceleration = -0.1
		
		if data.Stop and not data.Recycle then
			tear.Velocity = Vector.Zero
		elseif data.Recycle then
			tear.Velocity = 30*((player.Position - tear.Position):Normalized())
			if self._Ents:AreColliding(tear, player) then
				local pData = self:GetPlayerData(player)
				pData.TearsUp = math.min(2, pData.TearsUp + 0.1)
				player:AddCacheFlags(CacheFlag.CACHE_FIREDELAY, true)
				tear:Remove()
			end
		end
		
		if data.Timeout > 0 then
			data.Timeout = data.Timeout - 1
		elseif not data.Recycle then
			data.Recycle = true
		end
	end
end
BOT:AddCallback(ModCallbacks.MC_POST_TEAR_UPDATE, 'OnTearUpdate')

--科技X兼容
function BOT:OnTechXLaserUpdate(laser)
	if laser.SubType == 2 then
		local data = self._Ents:GetTempData(laser).BoneOfTemperance_Tear
		local player = self._Ents:IsSpawnerPlayer(laser, true)
			
		if data and player then
			if data.Stop and not data.Recycle then
				laser.Velocity = Vector.Zero
			elseif data.Recycle then
				laser.Velocity = 30*((player.Position - laser.Position):Normalized())
				if self._Ents:AreColliding(laser, player) then
					local pData = self:GetPlayerData(player)
					pData.TearsUp = math.min(2, pData.TearsUp + 0.5)
					player:AddCacheFlags(CacheFlag.CACHE_FIREDELAY, true)				
					laser:Remove()
				end
			end
			
			if data.Timeout > 0 then
				data.Timeout = data.Timeout - 1
			elseif not data.Recycle then
				data.Recycle = true
			end
		end	
	end
end
BOT:AddCallback(ModCallbacks.MC_POST_LASER_UPDATE, 'OnTechXLaserUpdate')

--生成停滞的眼泪
function BOT:SpawnStoppedTear(player, position)
	local tear = Isaac.Spawn(EntityType.ENTITY_TEAR, 0, 0, position, Vector.Zero, player):ToTear()
	local data = self:GetTearData(tear)
	data.Stop = true
	
	tear:AddTearFlags(TearFlags.TEAR_SPECTRAL)
	tear:AddTearFlags(TearFlags.TEAR_PIERCING)
	tear.CollisionDamage = math.max(3.5, player.Damage)
	tear.FallingSpeed = 0
	tear.FallingAcceleration = -0.1	
	
	return tear
end


--妈刀等兼容
function BOT:OnKnifeUpdate(knife)
	local player = self._Ents:IsSpawnerPlayer(knife, true)
	
	if player and player:HasCollectible(self.ID) then
		local data = self:GetKnifeData(knife)

		if data.Wait > 0 then
			data.Wait = data.Wait - 1
		else
			data.Wait = 10
			if knife:IsFlying() then
				local tear = self:SpawnStoppedTear(player, knife.Position)
				tear.Scale = 1
				
				if (knife.Variant == 0) then --经典妈刀对应金属子弹
					tear:ChangeVariant(3)
				elseif (knife.Variant == 2) then --骨刀棒对应镰刀子弹(骨棒对应骨头子弹，不知为何自动设置了)
					tear:ChangeVariant(8)
				elseif (knife.Variant == 3) or (knife.Variant == 5) then --驴骨棒和血吸管对应血泪
					tear:ChangeVariant(1)
				elseif (knife.Variant == 10) then --妈刀配英灵剑对应剑气
					tear:ChangeVariant(47)
				elseif (knife.Variant == 11) then --妈刀配英灵剑配科技对应激光剑气
					tear:ChangeVariant(49)	
				end	
				
				tear:Update()
			end			
		end
	end
end
BOT:AddCallback(ModCallbacks.MC_POST_KNIFE_UPDATE, 'OnKnifeUpdate')


--暂停玩家的所有眼泪或科X激光
function BOT:StopAll(player)
	if not player:HasCollectible(self.ID) then return end

	for _,tear in ipairs(Isaac.FindByType(EntityType.ENTITY_TEAR)) do
		tear = tear:ToTear()
		local tearPlayer = self._Ents:IsSpawnerPlayer(tear, true)
		
		if self._Ents:IsTheSame(tearPlayer, player) and self:CheckTearCondition(tear) then
			local data = self:GetTearData(tear)
			data.Stop = true
		end	
	end	
	for _,laser in ipairs(Isaac.FindByType(EntityType.ENTITY_LASER)) do
		local laserPlayer = self._Ents:IsSpawnerPlayer(laser, true)
		
		if self._Ents:IsTheSame(laserPlayer, player) then
			local data = self:GetTearData(laser)
			data.Stop = true
		end	
	end	
end

--玩家更新
function BOT:OnPlayerUpdate(player)
	if player:HasCollectible(self.ID) then
		local data = self:GetPlayerData(player)

		--加成衰减
		if player:IsFrame(3, 0) and data.TearsUp > 0 then
			data.TearsUp = math.max(0, data.TearsUp - 0.03)
			player:AddCacheFlags(CacheFlag.CACHE_FIREDELAY, true)
		end

		--单击暂停眼泪
		if player:AreControlsEnabled() and not game:IsPaused() then
			if Input.IsActionTriggered(ButtonAction.ACTION_DROP, player.ControllerIndex) then
				self:StopAll(player)
			end
		end
	end
end
BOT:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, 'OnPlayerUpdate')

--新房间重置属性加成
function BOT:OnNewRoom()
	for i = 0, game:GetNumPlayers() -1 do
		local player = Isaac.GetPlayer(i)
		if self._Ents:GetTempData(player).BoneOfTemperance_Player then
			self._Ents:GetTempData(player).BoneOfTemperance_Player = nil
			player:AddCacheFlags(CacheFlag.CACHE_FIREDELAY, true)
		end
	end
end
BOT:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, 'OnNewRoom')

--回收玩家的所有眼泪或科X激光
function BOT:RecycleAll(player)
	if not player:HasCollectible(self.ID) then return end

	for _,tear in ipairs(Isaac.FindByType(EntityType.ENTITY_TEAR)) do
		tear = tear:ToTear()
		local tearPlayer = self._Ents:IsSpawnerPlayer(tear, true)
		
		if self._Ents:IsTheSame(tearPlayer, player) and self:CheckTearCondition(tear) then
			local data = self:GetTearData(tear)
			data.Recycle = true
		end	
	end	
	for _,laser in ipairs(Isaac.FindByType(EntityType.ENTITY_LASER)) do
		local laserPlayer = self._Ents:IsSpawnerPlayer(laser, true)
		
		if self._Ents:IsTheSame(laserPlayer, player) then
			local data = self:GetTearData(laser)
			data.Recycle = true
		end	
	end	
end

--双击回收眼泪
function BOT:OnDoubleTap(player, type, action)
	if (type == 2) and (action == ButtonAction.ACTION_DROP) then
		self:RecycleAll(player)
	end
end
BOT:AddCallback(mod.IBS_CallbackID.DOUBLE_TAP, 'OnDoubleTap')

--属性变更
function BOT:OnEvalueateCache(player, flag)
	if player:HasCollectible(self.ID) then
		if flag == CacheFlag.CACHE_FIREDELAY then
			local data = self:GetPlayerData(player)
			if data.TearsUp > 0 then
				self._Stats:TearsModifier(player, data.TearsUp)
			end
		end
		
		--弹性眼泪
		if flag == CacheFlag.CACHE_TEARFLAG then
			player.TearFlags = player.TearFlags | TearFlags.TEAR_BOUNCE
		end
	end
end
BOT:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, 'OnEvalueateCache')



return BOT

