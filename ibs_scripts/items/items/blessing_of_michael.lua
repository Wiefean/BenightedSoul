--米迦勒的祝福

local mod = Isaac_BenightedSoul
local Pools = mod.IBS_Lib.Pools
local Damage = mod.IBS_Class.Damage()

local game = Game()

local BlessingOfMichael = mod.IBS_Class.Item(mod.IBS_ItemID.BlessingOfMichael)

--品质4以下的天使房道具
local function Condition(itemConfig)
	local quality = itemConfig.Quality
	if quality < 4 and Pools:IsCollectibleInPool(itemConfig.ID, ItemPoolType.POOL_ANGEL) then
		return true
	end
	return false
end

--品质4的天使房道具
local function Condition2(itemConfig)
	local quality = itemConfig.Quality
	if quality == 4 and Pools:IsCollectibleInPool(itemConfig.ID, ItemPoolType.POOL_ANGEL) then
		return true
	end
	return false
end

--品质2以下
local function Condition3(itemConfig)
	local quality = itemConfig.Quality
	if quality < 2 then
		return true
	end
	return false
end

--获得时
function BlessingOfMichael:OnGainItem(item, charge, first, slot, varData, player)
	if first then
		local itemPool = game:GetItemPool()
	
		for _,id in pairs(Pools:GetCollectibles(Condition)) do
			itemPool:RemoveCollectible(id)
		end	
		itemPool:RemoveCollectible(self.ID)
	
		local seed = player:GetCollectibleRNG(self.ID):Next()
		local id = Pools:GetCollectibleWithCondition(seed, Condition2, ItemPoolType.POOL_ANGEL, true, 25, true)				
		
		--正邪削弱
		--改为直接获得
		if mod.IBS_Compat.THI:SeijaNerf(player) then
			player:AddCollectible(id)
		else
			local room = game:GetRoom()
			local pos = room:FindFreePickupSpawnPosition((room:GetCenterPos()), 0, true)
			local item = Isaac.Spawn(5, 100, id, pos, Vector.Zero, nil):ToPickup()
		end
		
	end
end
BlessingOfMichael:AddCallback(ModCallbacks.MC_POST_ADD_COLLECTIBLE, 'OnGainItem', BlessingOfMichael.ID)

--不能拾取恶魔房内的血量交易道具
function BlessingOfMichael:PrePickupCollision(pickup, other)
	if game:GetRoom():GetType() == RoomType.ROOM_DEVIL then	
		local player = other:ToPlayer()
		if player and player:HasCollectible(self.ID) and pickup.SubType > 0 and pickup.Price ~= -1000 and pickup.Price < 0 then
			return false
		end	
	end
end
BlessingOfMichael:AddPriorityCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, 300, 'PrePickupCollision', PickupVariant.PICKUP_COLLECTIBLE)


--圣饼加强
function BlessingOfMichael:Wafer(ent, dmg)
	local player = ent:ToPlayer()

	if player and dmg > 0 then
		if player:HasCollectible(self.ID) and player:HasCollectible(108) then
			local rng = player:GetCollectibleRNG(108)
			local chance = rng:RandomInt(100)

			if chance > 50 then
				local num = player:GetCollectibleNum(108)
				player:AddSoulHearts(num)
				local effect = player:GetEffects()
				if not effect:HasCollectibleEffect(108) then
					effect:AddCollectibleEffect(108)
				end
			end
		end	
	end	
end
BlessingOfMichael:AddPriorityCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, 200, 'Wafer')

--圣心增强
function BlessingOfMichael:SacredHeart(player, flag)
	if player:HasCollectible(self.ID) then
		if player:HasCollectible(182) and flag == CacheFlag.CACHE_DAMAGE then
			local mult = 1.4 * player:GetCollectibleNum(182)
			player.Damage = player.Damage * mult
		end
	end	
end
BlessingOfMichael:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, 'SacredHeart')

--神圣屏障增强
function BlessingOfMichael:HolyMantle()
	for i = 0, game:GetNumPlayers() -1 do
		local player = Isaac.GetPlayer(i)
		
		if player:HasCollectible(self.ID) and player:HasCollectible(313) then
			local num = player:GetCollectibleNum(313)
			player:GetEffects():AddCollectibleEffect(313, true, num + 1)
		end
	end	
end
BlessingOfMichael:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, 'HolyMantle')

--神性增强
function BlessingOfMichael:Godhead(ent, dmg, flag, source, cd)
	if dmg <= 0 then return end
	
	if self._Ents:IsEnemy(ent, true) then
		local extra = 0
		for i = 0, game:GetNumPlayers() - 1 do
			local player = Isaac.GetPlayer(i)			
			if player:HasCollectible(self.ID) and player:HasCollectible(331) then
				local num = player:GetCollectibleNum(331)
				extra = extra + num * 0.3 * player.Damage
			end
		end
		
		return {Damage = dmg + extra}
	end
end
BlessingOfMichael:AddPriorityCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, -7000, 'Godhead')

--光明之冠增强
function BlessingOfMichael:CrownOfLight(ent, dmg, flag, source, cd)
	local player = ent:ToPlayer()
	if player and player:HasCollectible(self.ID) and player:HasCollectible(415, true) then
		player:AddCollectible(415, 0, false)
		player:RemoveCollectible(415, true)
	end
end
BlessingOfMichael:AddCallback(ModCallbacks.MC_POST_ENTITY_TAKE_DMG, 'CrownOfLight')

--光明之冠增强
function BlessingOfMichael:CrownOfLight2(ent, dmg, flag, source, cd)
	for i = 0, game:GetNumPlayers() -1 do
		local player = Isaac.GetPlayer(i)
		if player:HasCollectible(self.ID) and player:HasCollectible(415, true) then
			player:AddCollectible(415, 0, false)
			player:RemoveCollectible(415, true)
		end
	end	
end
BlessingOfMichael:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, 'CrownOfLight2')

--终末天启加强
function BlessingOfMichael:OnPlayerUpdate(player)
	if player:HasCollectible(self.ID) and player:HasCollectible(643) and player:IsFrame(75,0) then
		local target = self._Finds:ClosestEnemy(player.Position)
		if target then
			local angle = (target.Position - player.Position):GetAngleDegrees()
			local laser = EntityLaser.ShootAngle(5, player.Position, angle, 30, Vector(0,-30), player)
			laser:SetScale(0.5)
			laser.CollisionDamage = math.max(2, player.Damage * 0.5)
			laser:AddTearFlags(player.TearFlags | TearFlags.TEAR_HOMING)
			laser:Update()
		end
	end
end
BlessingOfMichael:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, 'OnPlayerUpdate')

--十字圣球加强
function BlessingOfMichael:OnGainItem2(item, charge, first, slot, varData, player)
	if first then
		local itemPool = game:GetItemPool()
		for _,id in pairs(Pools:GetCollectibles(Condition3)) do
			itemPool:RemoveCollectible(id)
		end	
	end
end
BlessingOfMichael:AddCallback(ModCallbacks.MC_POST_ADD_COLLECTIBLE, 'OnGainItem2', 691)

--虚空增强
function BlessingOfMichael:OnGetMaxCharge(item, player, varData, maxCharge)
	if player:HasCollectible(self.ID) then
		return maxCharge - 2
	end
end
BlessingOfMichael:AddCallback(ModCallbacks.MC_PLAYER_GET_ACTIVE_MAX_CHARGE, 'OnGetMaxCharge', 477)


return BlessingOfMichael