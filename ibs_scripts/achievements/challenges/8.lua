--褪色挑战

local mod = Isaac_BenightedSoul

local game = Game()
local config = Isaac.GetItemConfig()

local BC8 = mod.IBS_Class.Challenge(8, {
	Destination = 'Isaac'
})	
		
--游戏开始
function BC8:OnGameStart(isContinued)
    if not self:Challenging() or isContinued then return end
	game:AddDevilRoomDeal()
end
BC8:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, 'OnGameStart')		
		
--临时数据
function BC8:GetTempData(player)
	local data = self._Ents:GetTempData(player)
	data.BC8 = data.BC8 or {
		CanWTF = false,
		FirstWTF = false,
		WTFCD = 0,
	}
	return data.BC8
end

--新房间重置数据
function BC8:OnNewRoom(player)
	if not self:Challenging() then return end

	for i = 0, game:GetNumPlayers() - 1 do
		local player = Isaac.GetPlayer(i)
		local data = self:GetTempData(player)
		data.CanWTF = false
		data.FirstWTF = false
	end
end
BC8:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, 'OnNewRoom')


--神秘动静
function BC8:WTF(player)
	local target = self._Finds:ClosestEnemy(player.Position)

	if target and target:IsActiveEnemy() then
		local data = self:GetTempData(player)

		if not data.FirstWTF or (self._Players:IsShooting(player) and target.Position:Distance(player.Position) < 150 + target.Size) then
			data.FirstWTF = true
			player:AddVelocity((target.Position - player.Position):Resized(20))
			player:UseActiveItem(160, false, false)
			player:UseActiveItem(160, false, false)
			player:UseActiveItem(181, false, false)
			player:RemoveCostume(config:GetCollectible(181))
			player:SetMinDamageCooldown(120)
			
			game:GetRoom():MamaMegaExplosion(player.Position)
			
			local data = self:GetTempData(player)
			data.WTFCD = 60
		end
	end
end

--神秘圣光
function BC8:WTFLight(laser)
	local player = self._Ents:IsSpawnerPlayer(laser)
    if player and self:Challenging() then
		laser:AddTearFlags(TearFlags.TEAR_HOMING)
		laser:SetScale(10)
		laser:SetHomingType(1)
		
		local data = self:GetTempData(player)
		data.CanWTF = true
		data.FirstWTF = false
		data.WTFCD = 0
    end
end
BC8:AddCallback(ModCallbacks.MC_POST_LASER_INIT, 'WTFLight', 5)

--角色更新
function BC8:OnUpdate(player)
	if not self:Challenging() then return end
	local data = self:GetTempData(player)

	if data.WTFCD > 0 then
		data.WTFCD = data.WTFCD - 1
	elseif data.CanWTF then
		self:WTF(player)
	end
end
BC8:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, 'OnUpdate')

--飞行
function BC8:OnEvaluateCache(player, flag)
	if flag == CacheFlag.CACHE_FLYING and self:Challenging() then
		player.CanFly = true
	end
end
BC8:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, 'OnEvaluateCache')

--翅膀装饰
function BC8:ApplyFlyCostume(player)
	if self:Challenging() then
		local effect = player:GetEffects()
		if not effect:HasCollectibleEffect(179) then
			effect:AddCollectibleEffect(179, true)
		end	
		if not effect:HasCollectibleEffect(216) then
			effect:AddCollectibleEffect(216, true)
		end
		if not player:HasCollectible(643) then
			player:AddInnateCollectible(643, 1)
			player:RemoveCostume(config:GetCollectible(643))
		end	
		if not player:HasCollectible(215) then
			player:AddInnateCollectible(215, 1)
			player:RemoveCostume(config:GetCollectible(215))
		end			
	end	
end
BC8:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, 'ApplyFlyCostume')


--完成
function BC8:TryFinish()
	if self:IsUnfinished() and self:AtDestination() then
		self:Finish(false, true)
	end
end
BC8:AddCallback(ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD, 'TryFinish')


return BC8