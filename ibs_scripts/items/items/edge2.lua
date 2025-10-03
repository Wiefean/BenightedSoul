--伤疤之秘

local mod = Isaac_BenightedSoul
local Stats = mod.IBS_Lib.Stats

local game = Game()
local config = Isaac.GetItemConfig()

local Edge2 = mod.IBS_Class.Item(mod.IBS_ItemID.Edge2)

--获取数据
function Edge2:GetData(player, onlyGet)
	local data = self._Ents:GetTempData(player)
	
	if onlyGet then
		return data.Edge2
	end
	
	data.Edge2 = data.Edge2 or {Frames = 0}
	
	return data.Edge2
end

--获得时生成战车卡
function Edge2:OnGain(item, charge, first, slot, varData, player)
	if first then
		local room = game:GetRoom()
		local pos = room:FindFreePickupSpawnPosition(player.Position, 0, true)
		Isaac.Spawn(5, 300, 8, pos, Vector.Zero, nil)
	end
end
Edge2:AddCallback(ModCallbacks.MC_POST_ADD_COLLECTIBLE, 'OnGain', Edge2.ID)

--使用战车卡
function Edge2:OnUseCard(card, player)
	if player:HasCollectible(self.ID) then
		local data = self:GetData(player)
		data.Frames = data.Frames + 360
		
		--塔罗牌桌布
		if player:HasCollectible(451) then
			data.Frames = data.Frames + 360
		end
	end
end
Edge2:AddCallback(ModCallbacks.MC_USE_CARD, 'OnUseCard', 8)

--受伤时
function Edge2:OnTakeDMG(ent, dmg)
	if dmg <= 0 then return end
	local player = ent:ToPlayer()
	if player and player:HasCollectible(self.ID) then
		local data = self:GetData(player)
		data.Frames = data.Frames + 360
	end
end
Edge2:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, 'OnTakeDMG')

--角色更新
function Edge2:OnPlayeUpdate(player)
	if not player:HasCollectible(self.ID) then return end

	local data = self:GetData(player)
	if data.Frames > 0 then data.Frames = data.Frames - 1 end
	
	local dir = player:GetMovementDirection()
	if dir == Direction.NO_DIRECTION then return end
	if not self._Players:IsShooting(player) then return end
	if not player:IsFrame(math.max(math.ceil(player.MaxFireDelay / 1.5), 1), 0) then return end
	
	--发射眼泪
	for i = 1,2 do
		local dmg = math.max(1.5, player.Damage / 3)
		local offset = (-1)^i * Vector(0, 8)
		
		if dir == Direction.UP or dir == Direction.DOWN then
			offset = (-1)^i * Vector(8, 0)
		end
		local tear = player:FireTear(player.Position + offset, self._Maths:DirectionToVector(dir)*20, true, false, false, player)
		tear:ChangeVariant(12)
		tear:AddTearFlags(TearFlags.TEAR_PIERCING)
		tear:AddTearFlags(TearFlags.TEAR_SPECTRAL)
		tear.CollisionDamage = dmg
		tear:SetColor(Color(1, 1, 1, 0.5),-1,0)
		if data.Frames > 0 then
			tear:AddTearFlags(TearFlags.TEAR_HOMING)
			tear.CollisionDamage = tear.CollisionDamage * 2
			tear:SetColor(Color(1, 0, 1, 0.5),-1,0)
		end
		tear.Scale = self._Maths:TearDamageToScale(dmg)
		tear:Update()
	end

	SFXManager():Stop(153)

	--正邪削弱(东方mod)
	if mod.IBS_Compat.THI:SeijaNerf(player) then
		player.Velocity = player.Velocity + self._Maths:DirectionToVector(dir) * 15
	end
end
Edge2:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, 'OnPlayeUpdate', 0)

--新层生成战车卡并获得碎心
function Edge2:OnNewLevel()
	if PlayerManager.AnyoneHasCollectible(self.ID) then
		local room = game:GetRoom()
		local pos = room:FindFreePickupSpawnPosition(room:GetCenterPos() + Vector(0,80), 0, true)
		Isaac.Spawn(5, 300, 8, pos, Vector.Zero, nil)	
	end
	
	for i = 0, game:GetNumPlayers() - 1 do
		local player = Isaac.GetPlayer(i)
		if player:HasCollectible(self.ID) then
			if player:GetBrokenHearts() < 4 then
				player:AddBrokenHearts(1)
			end
		end
	end
end
Edge2:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, 'OnNewLevel')

--角色爆炸免疫
function Edge2:PrePlayerTakeDMG(player, dmg, flag)
	if player:HasCollectible(self.ID) and (flag & DamageFlag.DAMAGE_EXPLOSION > 0) then
		return false
	end
end
Edge2:AddPriorityCallback(ModCallbacks.MC_PRE_PLAYER_TAKE_DMG, -800, 'PrePlayerTakeDMG')

--属性
function Edge2:OnEvaluateCache(player, flag)
	if player:HasCollectible(self.ID) then	
		if flag == CacheFlag.CACHE_FIREDELAY then
			Stats:TearsModifier(player, 0.5)
		end
	end	
end
Edge2:AddPriorityCallback(ModCallbacks.MC_EVALUATE_CACHE, 200, 'OnEvaluateCache')


--碰撞免疫
function Edge2:PreNPCCollision(npc, other)
	if not self._Ents:IsEnemy(npc, true) then return end
	if npc.Type == 33 and npc.Variant == 4 then return end --忽略白火
    local player = other:ToPlayer()
    if player and player:HasCollectible(self.ID) then
		return false
    end
end
Edge2:AddPriorityCallback(ModCallbacks.MC_PRE_NPC_COLLISION, CallbackPriority.LATE, 'PreNPCCollision')


return Edge2