--掉落物实体相关函数

local mod = Isaac_BenightedSoul
local IBS_CallbackID = mod.IBS_CallbackID
local Ents = mod.IBS_Lib.Ents
local Finds = mod.IBS_Lib.Finds
local Players = mod.IBS_Lib.Players

local config = Isaac.GetItemConfig()

local Pickups = {}

--通过单选掉落物参数获取掉落物组
function Pickups:GetPickupsByOptionsIndex(idx)
	local result = {}

	for _,ent in pairs(Isaac.FindByType(5)) do
		local pickup = ent:ToPickup()
		if pickup.OptionsPickupIndex == idx then
			table.insert(result, pickup)
		end
	end
	
	return result
end

--获取新的单选掉落物参数
function Pickups:GetUniqueOptionsIndex()
	local idx = 1
	local pickups = Isaac.FindByType(5)
	local unique = false
	
	while (not unique) do
		unique = true
		for _,ent in pairs(pickups) do
			if ent:ToPickup().OptionsPickupIndex == idx then
				idx = idx + 1
				unique = false
				break
			end
		end
	end

	return idx
end


--箱子
Pickups.ChestVariant = {
	[PickupVariant.PICKUP_CHEST] = true,
	[PickupVariant.PICKUP_BOMBCHEST] = true,
	[PickupVariant.PICKUP_SPIKEDCHEST] = true,
	[PickupVariant.PICKUP_ETERNALCHEST] = true,
	[PickupVariant.PICKUP_MIMICCHEST] = true,
	[PickupVariant.PICKUP_OLDCHEST] = true,
	[PickupVariant.PICKUP_WOODENCHEST] = true,
	[PickupVariant.PICKUP_MEGACHEST] = true,
	[PickupVariant.PICKUP_HAUNTEDCHEST] = true,
	[PickupVariant.PICKUP_LOCKEDCHEST] = true,
	[PickupVariant.PICKUP_REDCHEST] = true,
	[PickupVariant.PICKUP_MOMSCHEST] = true,
}

--是否为箱子(只能判断原版箱子)
function Pickups:IsChest(variant)
	if Pickups.ChestVariant[variant] then
		return true
	end
	return false
end

--箱子是否为关闭状态
function Pickups:IsChestClosed(pickup)
	if self:IsChest(pickup.Variant) then
		return (pickup.SubType > 0)
	end
	return false
end

--注册箱子(用于模组自定义箱子)
function Pickups:RegisterChest(variant)
	ChestVariant[variant] = true
end

--是否能收集掉落物
--[[输入: 掉落物(实体), 收集者(实体), 忽略掉落物等待时间(是否), 忽略价格(是否)]]
--[[说明:
"收集者"可以为nil
"忽略价格"只在收集者是玩家时有效

这个函数主要在掉落物碰撞回调(ModCallbacks.MC_PRE_PICKUP_COLLISION)中使用
]]
function Pickups:CanCollect(pickup, collector, ignoreWait, ignorePrice)
	local variant = pickup.Variant
	local subType = pickup.SubType
	local player = (collector and collector:ToPlayer()) or nil
	local familiar = (collector and collector:ToFamiliar()) or nil

	--掉落物不处于等待时间
	if (not ignoreWait) and (pickup.Wait > 0) then
		return false
	end

	--收集者存在
	if collector then
		if (not collector:Exists()) or collector:IsDead() then
			return false
		end
	end

	--箱子处于打开状态
	if Pickups:IsChest(variant) and (subType == ChestSubType.CHEST_OPENED) then
		return false
	end

	--黏币
	if (variant == PickupVariant.PICKUP_COIN) and (subType == CoinSubType.COIN_STICKYNICKEL) then
		return false
	end

	--非宝宝玩家,非多人模式死亡玩家
	if player and (player.Variant == 0) and not player:IsCoopGhost() then

		--买不起
		if (not ignorePrice) and (pickup.Price > 0 and player:GetNumCoins() < pickup.Price) then
			return false
		end

		--玩家没有处于可拾取物品状态
		if (not player:CanPickupItem()) or (not player:IsExtraAnimationFinished()) or (player.ItemHoldCooldown > 0) then
			return false
		end

		--分类讨论
		if (variant == PickupVariant.PICKUP_HEART) then --心
			if (subType == HeartSubType.HEART_FULL or subType == HeartSubType.HEART_HALF or subType == HeartSubType.HEART_DOUBLEPACK or subType == HeartSubType.HEART_SCARED) and not player:CanPickRedHearts() then
				return false		
			elseif (subType == HeartSubType.HEART_SOUL or subType == HeartSubType.HEART_HALF_SOUL) then
				return player:CanPickSoulHearts()
			elseif (subType == HeartSubType.HEART_BLACK) and not player:CanPickBlackHearts() then
				return false
			elseif (subType == HeartSubType.HEART_GOLDEN) and not player:CanPickGoldenHearts() then
				return false
			elseif (subType == HeartSubType.HEART_BLENDED) and not (player:CanPickSoulHearts() or player:CanPickRedHearts()) then
				return false
			elseif (subType == HeartSubType.HEART_BONE) and not player:CanPickBoneHearts() then
				return false
			elseif (subType == HeartSubType.HEART_ROTTEN) and not player:CanPickRottenHearts() then
				return false
			end		
		elseif (variant == PickupVariant.PICKUP_LIL_BATTERY) then --电池
			local needsCharge = player:NeedsCharge(0) or player:NeedsCharge(1) or player:NeedsCharge(2) or player:NeedsCharge(3)
			
			--超级电池(因其可以充满主动至额外充能条,需要额外判断)
			if (not needsCharge) and (subType == BatterySubType.BATTERY_MEGA) then
				for slot = 0,2 do
					local itemConfig = config:GetCollectible(player:GetActiveItem(slot))
					if itemConfig and (itemConfig.ChargeType ~= ItemConfig.CHARGE_SPECIAL) then
						needsCharge = needsCharge or (player:GetBatteryCharge(slot) < itemConfig.MaxCharges)
					end
					if needsCharge then
						break
					end
				end
			end
			
			if not needsCharge then
				return false
			end
		elseif (variant == PickupVariant.PICKUP_COLLECTIBLE) then	
			if Players:IsStrawMan(player) then --稻草人不能拾取主动
				local itemConfig = config:GetCollectible(pickup.SubType)
				if itemConfig and (itemConfig.Type == ItemType.ITEM_ACTIVE) then
					return false
				end			
			end
		elseif Pickups:IsChest(variant) then --原版箱子
			--鬼箱,家层妈箱
			if (variant == PickupVariant.PICKUP_HAUNTEDCHEST) or (variant == PickupVariant.PICKUP_MOMSCHEST) then
				return false
			end
		elseif Players:IsStrawMan(player) and (variant == PickupVariant.PICKUP_PILL or variant == PickupVariant.PICKUP_BROKEN_SHOVEL or variant == PickupVariant.PICKUP_TAROTCARD or variant == PickupVariant.PICKUP_TRINKET) then
			return false -- 稻草人不能拾取口袋物品和妈铲柄
		end
	elseif familiar then --跟班(主要是乞丐等)
		--乞丐朋友
		if familiar.Variant == FamiliarVariant.BUM_FRIEND then
			if (variant ~= PickupVariant.PICKUP_COIN) then
				return false
			end
		end
		
		--黑暗乞丐
		if familiar.Variant == FamiliarVariant.DARK_BUM then
			if (variant ~= PickupVariant.PICKUP_HEART) then
				return false
			else
				--非红心
				if (subType ~= HeartSubType.HEART_FULL and subType ~= HeartSubType.HEART_HALF and subType ~= HeartSubType.HEART_DOUBLEPACK and subType ~= HeartSubType.HEART_SCARED) then
					return false
				end
			end	
		end
		
		--钥匙乞丐
		if familiar.Variant == FamiliarVariant.KEY_BUM then
			if (variant ~= PickupVariant.PICKUP_KEY) then
				return false
			end			
		end
		
		--超级乞丐
		if familiar.Variant == FamiliarVariant.SUPER_BUM then
			if (variant ~= PickupVariant.PICKUP_COIN) and (variant ~= PickupVariant.PICKUP_HEART) and (variant ~= PickupVariant.PICKUP_KEY) then
				return false
			elseif (variant == PickupVariant.PICKUP_HEART) then
				if (subType ~= HeartSubType.HEART_FULL and subType ~= HeartSubType.HEART_HALF and subType ~= HeartSubType.HEART_DOUBLEPACK and subType ~= HeartSubType.HEART_SCARED) then
					return false				
				end
			end
		end
		
	end

	--通过回调的方式获取额外条件
	for _,callback in ipairs(Isaac.GetCallbacks(IBS_CallbackID.CAN_COLLECT_PICKUP)) do
		if (not callback.Param) or (callback.Param == variant) then	
			local result = callback.Function(callback.Mod, pickup, collector)
			if type(result) == "boolean" and (result == false) then
				return false
			end
		end	
	end

	return true
end

--临时掉落物数据
local function GetPickupData(pickup)
	local data = Ents:GetTempData(pickup)
	data.IBS_LIB_PICKUPS = data.IBS_LIB_PICKUPS or {OriginalPosition = pickup.Position}
	
	return data.IBS_LIB_PICKUPS
end

--尝试收集(硬核)
--[[输入: 掉落物(实体), 收集者(实体)]]
--[[说明:
"收集者"可以为nil
"掉落物"为箱子时,尝试打开;若收集者为玩家,还会调取玩家信息以调整生成物品
"掉落物"不为箱子且"收集者"不为nil时,临时将掉落物移动至收集者位置以创造收集机会
]]
function Pickups:TryCollect(pickup, collector)
	if Pickups:CanCollect(pickup, collector) then
	    if Pickups:IsChest(pickup.Variant) then
			local player = (collector and collector:ToPlayer()) or nil
			pickup:TryOpenChest(player)
		else
			local originalPos = pickup.Position
			pickup.Position = collector.Position
			GetPickupData(pickup).OriginalPosition = originalPos
			
			--如果没有被拾取,还原位置(还是会有一瞬间的瑕疵)
			mod:DelayFunction2(function()
				if pickup:Exists() then
					pickup.Position = originalPos
				end
			end, 0, nil, true)
		end	
	end
end

--获取被临时移动前的位置
--(主要用于播放掉落物动画)
function Pickups:GetOffsetedPosition(pickup)
	return GetPickupData(pickup).OriginalPosition
end

--播放掉落物收集动画(实为生成空实体效果)
function Pickups:PlayCollectAnim(pickup, duration, anim, pos)
	duration = duration or 30
	anim = anim or "Collect"
	pos = pos or Pickups:GetOffsetedPosition(pickup)
	return Ents:CopyAnimation(pickup, pos, duration, anim)
end

--获取正在以挥动方式收集掉落物的玩家(骨棒,英灵剑等)
--(主要用于自定义掉落物)
function Pickups:GetSwingPickupPlayer(pickup)
	if pickup:GetSprite():IsPlaying("Collect") then return nil end --正在被拾取

	for _,knife in pairs(Isaac.FindByType(EntityType.ENTITY_KNIFE, -1, 4)) do
		local player = Ents:IsSpawnerPlayer(knife)

		--玩家存在,非合成袋挥动,存在帧数大于0
		if player and (knife.Variant ~= 4) and (knife.FrameCount > 0) then
			knife = knife:ToKnife()
			local pos = knife.Position
			local scale = 30

			--骨棒妈刀或英灵剑(范围更大)
			if (knife.Variant == 2) or (knife.Variant == 10) then 
				scale = 44
			end		
			scale = scale * knife.SpriteScale.X

			--旋转修正
			local offset = Vector(scale,0)
			offset = offset:Rotated(knife.Rotation)
			pos = pos + offset

			if (pos - pickup.Position):Length() < pickup.Size + scale then
				return player
			end
		end
	end

	return nil
end

--设置尖刺价格(硬核,会改变生成者ID信息)
function Pickups:SetSpikePrice(pickup)
	pickup.ShopItemId = -1
	pickup.Price = -5
	pickup.AutoUpdatePrice = false	
	pickup.SpawnerType = 114 + 514 + 1919810
	pickup.SpawnerVariant = 114 + 514 + 1919810
end
mod:AddCallback(ModCallbacks.MC_POST_PICKUP_MORPH, function(_,pickup, lastT, lastV, lastS, keepPrice, keepSeed, ignoreModifiers)
	if keepPrice and (pickup.Price < 0 and pickup.Price ~= -1000) and pickup.SpawnerType == 114 + 514 + 1919810 and pickup.SpawnerVariant == 114 + 514 + 1919810 then
		pickup.ShopItemId = -1
		pickup.Price = -5
		pickup.AutoUpdatePrice = false
		
		--硬核施加尖刺效果
		for _,ent in ipairs(Isaac.FindByType(1000, 174, 0)) do
			if pickup.Position:Distance(ent.Position) <= 1 then
				ent:Remove()
			end
		end
		local effect = Isaac.Spawn(1000, 174, 0, pickup.Position, Vector.Zero, pickup):ToEffect()
		effect.Parent = pickup
	end
end)

--重置为错误道具(原理是添加错误技,重置道具后再移除)
function Pickups:MorphToErrorItem(pickup, keepPrice, keepSeed, ignoreModifiers)
	local player = Isaac.GetPlayer(0)
	player:AddCollectible(721, 0, false)
	pickup:Morph(5, 100, 0, keepPrice, keepSeed, ignoreModifiers)
	player:RemoveCollectible(721, true)
end

--道具伪装(原为女疾女户使用)
function Pickups:CollectibleDisguise(pickup, disguiseID)
	if pickup.Variant == 100 and pickup.SubType > 0 then	
		pickup:GetSprite():ReplaceSpritesheet(1, config:GetCollectible(disguiseID).GfxFileName, true)
		Ents:GetTempData(pickup).EnvyDisguise = disguiseID
	end
end

--移除道具伪装(原为女疾女户使用)
function Pickups:RemoveCollectibleDisguise(pickup)
	if pickup.Variant == 100 and pickup.SubType > 0 then	
		pickup:GetSprite():ReplaceSpritesheet(1, config:GetCollectible(pickup.SubType).GfxFileName, true)
		Ents:GetTempData(pickup).EnvyDisguise = nil
	end
end

--玩家靠近时换回贴图(设置较晚优先级防止与女疾女户冲突)
mod:AddPriorityCallback(ModCallbacks.MC_POST_PICKUP_UPDATE, 200, function(_,pickup)
	local disguise = Ents:GetTempData(pickup).EnvyDisguise
	if disguise ~= nil then
		local pos = pickup.Position
		local player = Finds:ClosestPlayer(pos)
		if player and pos:Distance(player.Position) < 35 then
			Pickups:RemoveCollectibleDisguise(pickup)
		end
	end
end, 100)

return Pickups