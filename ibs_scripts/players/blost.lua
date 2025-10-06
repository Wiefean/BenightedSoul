--昧化游魂

local mod = Isaac_BenightedSoul
local IBS_ChallengeID = mod.IBS_ChallengeID
local IBS_CallbackID = mod.IBS_CallbackID
local IBS_ItemID = mod.IBS_ItemID
local Stats = mod.IBS_Lib.Stats
local Pools = mod.IBS_Lib.Pools
local CharacterLock = mod.IBS_Achiev.CharacterLock
local BLostFloat = mod.IBS_Familiar.BLostFloat
local BLostWeapon = mod.IBS_Familiar.BLostWeapon
local ChestMantle = mod.IBS_Effect.ChestMantle

local game = Game()
local sfx = SFXManager()
local config = Isaac.GetItemConfig()

local BLost = mod.IBS_Class.Character(mod.IBS_PlayerID.BLost, {
	BossIntroName = 'blost',
	SpritePath = 'gfx/ibs/characters/player_blost.anm2',
	SpritePathFlight = 'gfx/ibs/characters/player_blost.anm2',	
	PocketActive = IBS_ItemID.ChestChest,
})

--跟班道具
local function FamiliarItem(itemConfig)
	return (itemConfig.Type == ItemType.ITEM_FAMILIAR)
end

--变身
function BLost:Benighted(player, fromMenu)
	if CharacterLock.BLost:IsLocked() then return end

	local CAN = false 

	--检测永恒D6
	for slot = 0,1 do
		if player:GetActiveItem(slot) == 609 then
			player:RemoveCollectible(609, true, slot)
			CAN = true
			break
		end	
	end
	if player:GetActiveItem(2) == 609 then CAN = true end
	
	if CAN or fromMenu then
		player:ChangePlayerType(self.ID)
		player:SetPocketActiveItem(self.Info.PocketActive, ActiveSlot.SLOT_POCKET, false)
		player:AnimateCollectible(IBS_ItemID.ChestChest)
		
		--移除斗篷效果,让视觉好一些
		player:GetEffects():RemoveCollectibleEffect(313)
		
		--跟班道具移出道具池
		local itemPool = game:GetItemPool()
		for _,id in ipairs(Pools:GetCollectibles(FamiliarItem)) do
			itemPool:RemoveCollectible(id)
		end
		
		--生成箱子
		local room = game:GetRoom()
		local pos = room:FindFreePickupSpawnPosition(room:GetCenterPos() + Vector(0,-80), 0, true)
		
		--完成对应挑战后额外生成一个
		if self:GetIBSData('persis')['bc11'] then
			Isaac.Spawn(5,50,0, pos + Vector(20,0), RandomVector(), nil)
			Isaac.Spawn(5,50,1, pos - Vector(20,0), RandomVector(), nil)
		else
			Isaac.Spawn(5,50,1, pos, RandomVector(), nil)
		end

		if not fromMenu then
			sfx:Play(128)
		end
	end
end
BLost:AddCallback(IBS_CallbackID.BENIGHTED, 'Benighted', PlayerType.PLAYER_THELOST)


--稀有箱池(没错写这么长就是故意的)
BLost.RareChestList = {
	PickupVariant.PICKUP_ETERNALCHEST,
	PickupVariant.PICKUP_ETERNALCHEST,
	PickupVariant.PICKUP_ETERNALCHEST,
	PickupVariant.PICKUP_ETERNALCHEST,
	PickupVariant.PICKUP_ETERNALCHEST,
	PickupVariant.PICKUP_ETERNALCHEST,
	PickupVariant.PICKUP_ETERNALCHEST,
	PickupVariant.PICKUP_ETERNALCHEST,
	PickupVariant.PICKUP_ETERNALCHEST,
	PickupVariant.PICKUP_ETERNALCHEST,
	PickupVariant.PICKUP_ETERNALCHEST,
	PickupVariant.PICKUP_ETERNALCHEST,
	PickupVariant.PICKUP_ETERNALCHEST,
	PickupVariant.PICKUP_ETERNALCHEST,	
	PickupVariant.PICKUP_OLDCHEST,
	PickupVariant.PICKUP_OLDCHEST,
	PickupVariant.PICKUP_OLDCHEST,
	PickupVariant.PICKUP_OLDCHEST,
	PickupVariant.PICKUP_OLDCHEST,
	PickupVariant.PICKUP_REDCHEST,
	PickupVariant.PICKUP_REDCHEST,
	PickupVariant.PICKUP_REDCHEST,
	PickupVariant.PICKUP_REDCHEST,
	PickupVariant.PICKUP_REDCHEST,	
	PickupVariant.PICKUP_REDCHEST,
	PickupVariant.PICKUP_REDCHEST,
	PickupVariant.PICKUP_REDCHEST,
	PickupVariant.PICKUP_REDCHEST,
	PickupVariant.PICKUP_REDCHEST,		
	PickupVariant.PICKUP_WOODENCHEST,
	PickupVariant.PICKUP_WOODENCHEST,
	PickupVariant.PICKUP_WOODENCHEST,
	PickupVariant.PICKUP_WOODENCHEST,
	PickupVariant.PICKUP_WOODENCHEST,
	PickupVariant.PICKUP_WOODENCHEST,
	PickupVariant.PICKUP_WOODENCHEST,
	PickupVariant.PICKUP_WOODENCHEST,
	PickupVariant.PICKUP_WOODENCHEST,
	PickupVariant.PICKUP_WOODENCHEST,
	PickupVariant.PICKUP_WOODENCHEST,
	PickupVariant.PICKUP_WOODENCHEST,
	PickupVariant.PICKUP_WOODENCHEST,
	PickupVariant.PICKUP_WOODENCHEST,
	PickupVariant.PICKUP_MEGACHEST,
}


--拆解道具
BLost.DecomposeItem = {
	[53] = true, --万磁王
	[175] = true, --爸钥
	[247] = true, --大宝
	[357] = true, --朋友盒
	[536] = true, --祭坛
	[623] = true, --尖头钥匙
	[642] = true, --驴皮
	[703] = true, --小以扫
}

--获得道具
function BLost:OnGainItem(item, charge, first, slot, varData, player)
	if player:GetPlayerType() ~= self.ID then return end
	
	--自动摧毁品质低于3的非攻击性非任务道具以及名单内道具
	if item > 0 then
		local itemConfig = config:GetCollectible(item)
		if itemConfig and (self.DecomposeItem[item] or itemConfig:HasTags(ItemConfig.TAG_NO_LOST_BR)) then
			local room = game:GetRoom()
			local pos = room:FindFreePickupSpawnPosition(player.Position + Vector(0,-40), 0, true)
			
			for i = 1,(1 + 2 ^ itemConfig.Quality) do			
				local pickup = Isaac.Spawn(5,30,0, pos, RandomVector(), nil):ToPickup()
				pickup.Wait = 45
			end
			
			if itemConfig.Quality >= 2 then
				
				--3级及以上会出稀有箱
				if itemConfig.Quality >= 3 then
					local rareNum = itemConfig.Quality - 2
					local leftNum = itemConfig.Quality - 1 - rareNum

					if leftNum > 0 then
						for i = 1,leftNum do
							local pickup = Isaac.Spawn(5,50,0, pos + i*Vector(20,-20), RandomVector(), nil):ToPickup()
							pickup.Wait = 45
						end
					end
					if rareNum > 0 then
						for i = 1,rareNum do
							local pool = self.RareChestList
							local rng = player:GetCollectibleRNG(725)
							local variant = pool[rng:RandomInt(1,#pool)] or PickupVariant.PICKUP_ETERNALCHEST
							local pickup = Isaac.Spawn(5,variant,0, pos + i*Vector(20,-20), RandomVector(), nil):ToPickup()
							pickup.Wait = 45
						end
					end
				else
					for i = 1,itemConfig.Quality - 1 do
						local pickup = Isaac.Spawn(5,50,0, pos + i*Vector(20,-20), RandomVector(), nil):ToPickup()
						pickup.Wait = 45
					end
				end			
			end
			
			player:RemoveCollectible(item, true)
			sfx:Play(267)
		end
	end	
	
	--获得长子权时
	if first and item == 619 then
		local room = game:GetRoom()
		
		player:AddKeys(70)
		
		--生成3个永恒箱
		for i = 1,3 do
			local pos = room:FindFreePickupSpawnPosition(room:GetCenterPos(), 0, true)
			Isaac.Spawn(5, 53, 1, pos, Vector(0,0), nil)
		end
	end
end
BLost:AddCallback(ModCallbacks.MC_POST_ADD_COLLECTIBLE, 'OnGainItem')


--[[槽位ID图示:
 1  2  3 (武器 护甲 武器)
 4  5  6 (僚机 僚机 僚机)
]]

--获取数据
function BLost:GetData(player)
	local data = self._Players:GetData(player)
	if not data.BLost then data.BLost = {
		Mecha = {
			[1] = {Chest="None", Left=1, Max=1},
			[2] = {Chest="None", Left=1, Max=1},
			[3] = {Chest="None", Left=1, Max=1},
			[4] = {Chest="None", Left=1, Max=1},
			[5] = {Chest="None", Left=1, Max=1},
			[6] = {Chest="None", Left=1, Max=1},		
		},
		TempDMG = 0,
		MegaAbsorption = {},
	}
	end
	return data.BLost
end

--获取临时数据
function BLost:GetTempData(player)
	local data = self._Ents:GetTempData(player)
	if not data.BLost then
		data.BLost = {
			HUDSprite = {},
			OldArmorCounter = 0,
		}
		for i = 1,6 do
			local spr = Sprite("gfx/ibs/ui/players/blost_hud.anm2")
			spr:Play("None")
			data.BLost.HUDSprite[i] = spr
		end
	end
	return data.BLost
end

--获取装甲数据
function BLost:GetMechaData(player)
	local data = self:GetData(player)
	return data.Mecha
end

--获取大箱吸收的箱子数据
function BLost:GetMegaAbsorption(player)
	local data = self:GetData(player)
	return data.MegaAbsorption
end

--获取大箱等级(吸收的箱子种类数)
function BLost:GetMegaLevel(player)
	local mecha = self:GetMechaData(player)
	
	if mecha[2].Chest == 'Mega' then
		local level = 0
		for k,v in pairs(self:GetMegaAbsorption(player)) do
			if k == tostring(PickupVariant.PICKUP_MEGACHEST) then
				level = level + 3
			elseif k == tostring(PickupVariant.PICKUP_MOMSCHEST) then
				level = level + 3
			else			
				level = level + 1
			end
		end
		return level
	end
	
	return 0
end

--获取HUD贴图数据
function BLost:GetHUDSpriteData(player)
	local data = self:GetTempData(player)
	return data.HUDSprite
end

--刷新贴图
function BLost:RefreshHUD(player)
	local mecha = self:GetMechaData(player)
	local data = self:GetHUDSpriteData(player)
	for k,spr in ipairs(data) do
		spr:Play(mecha[k].Chest or "None", true)
	end
end

--箱子名称
BLost.ChestName = {
	[PickupVariant.PICKUP_CHEST] = "Common",
	[PickupVariant.PICKUP_BOMBCHEST] = "Stone",
	[PickupVariant.PICKUP_SPIKEDCHEST] = "Spike",
	[PickupVariant.PICKUP_ETERNALCHEST] = "Eternal",
	[PickupVariant.PICKUP_MIMICCHEST] = "Spike",
	[PickupVariant.PICKUP_OLDCHEST] = "Old",
	[PickupVariant.PICKUP_WOODENCHEST] = "Wooden",
	[PickupVariant.PICKUP_MEGACHEST] = "Mega",
	[PickupVariant.PICKUP_HAUNTEDCHEST] = "Haunted",
	[PickupVariant.PICKUP_LOCKEDCHEST] = "Golden",
	[PickupVariant.PICKUP_REDCHEST] = "Red",
	[PickupVariant.PICKUP_MOMSCHEST] = "Mom",
}	

--获取箱子名称
function BLost:GetChestName(pickupVariant)
	return self.ChestName[pickupVariant]
end

--获取箱子耐久(第二个参数为初始耐久)
function BLost:GetChestDurability(slot, chestName)
	--武器
	if slot == 1 or slot == 3 then
		if chestName == "Common" then
			return 100,75
		elseif chestName == "Stone" then
			return 210,210
		elseif chestName == "Spike" then
			return 111,88
		elseif chestName == "Eternal" then
			return 70,35
		elseif chestName == "Old" then
			return 109,109
		elseif chestName == "Wooden" then
			return 90,90
		elseif chestName == "Haunted" then
			return 45,45		
		elseif chestName == "Golden" then
			return 140,90
		elseif chestName == "Red" then
			return 120,66
		end
	end
	
	--护甲
	if slot == 2 then
		if chestName == "Common" then
			return 2,2
		elseif chestName == "Stone" then
			return 6,6
		elseif chestName == "Spike" then
			return 2,2
		elseif chestName == "Eternal" then
			return 4,2
		elseif chestName == "Old" then
			return 4,2
		elseif chestName == "Wooden" then
			return 2,2
		elseif chestName == "Mega" then
			return 5,3
		elseif chestName == "Haunted" then
			return 1,1
		elseif chestName == "Golden" then
			return 3,2
		elseif chestName == "Red" then
			return 6,2
		elseif chestName == "Mom" then
			return 9,9
		end
	end
	
	--僚机
	if slot >= 4 and slot <= 6 then
		if chestName == "Common" then
			return 75,60
		elseif chestName == "Stone" then
			return 180,180
		elseif chestName == "Spike" then
			return 90,90
		elseif chestName == "Eternal" then
			return 70,35
		elseif chestName == "Old" then
			return 88,88
		elseif chestName == "Wooden" then
			return 75,75
		elseif chestName == "Haunted" then
			return 60,60
		elseif chestName == "Golden" then
			return 100,75
		elseif chestName == "Red" then
			return 90,66
		end	
	end

	return 1
end

--获取修复花费
function BLost:GetRepairCost(slot, chestName, left, max)
	local mult = 1
	
	if chestName == "Common" then
		mult = 0.7
	elseif chestName == "Spike" then
		mult = 1.5
	elseif chestName == "Mega" then
		mult = 4
	elseif chestName == "Haunted" then
		mult = 0.5
	elseif chestName == "Eternal" then
		mult = 1.7
	elseif chestName == "Old" then
		mult = 2
	elseif chestName == "Golden" then
		mult = 1.25
	else
		return 0
	end

	--武器
	if slot == 1 or slot == 3 then
		mult = mult * 2
	end
	
	--护甲
	if slot == 2 then
		mult = mult * 3
	end
	
	--僚机
	if slot >= 4 and slot <= 6 then
		mult = mult * 1.5
	end	
	
	return math.ceil(mult*(1-left/max))
end

--是否能修复
function BLost:CanRepair(player, slot)
	if player:GetPlayerType() ~= self.ID then return false end
	local mecha = self:GetMechaData(player)
	local selected = mecha[slot]
	local chestName = selected.Chest

	--不能常规修复的箱子(红箱子修复方式特殊)
	if chestName == "None" or chestName == "Stone" or chestName == "Wooden" or chestName == "Red" or chestName == "Mom" then
		return false
	end
	
	--检查耐久
	if selected.Left >= selected.Max then
		return false
	end
	
	--检查价格(挑战改为用炸弹修复)
	if Isaac.GetChallenge() == IBS_ChallengeID[11] then
		if player:GetNumBombs() < self:GetRepairCost(slot, chestName, selected.Left, selected.Max) then
			return false
		end	
	else	
		if player:GetNumKeys() < self:GetRepairCost(slot, chestName, selected.Left, selected.Max) then
			return false
		end
	end

	return true
end

--获取护甲受伤无敌帧
function BLost:GetArmorInvincibleFrames(chestName, megaLevel)
	if chestName == "Common" then
		return 90
	elseif chestName == "Stone" then
		return 90
	elseif chestName == "Spike" then
		return 240
	elseif chestName == "Eternal" then
		return 70
	elseif chestName == "Wooden" then
		return 60
	elseif chestName == "Mega" then
		return 30 + 6*(megaLevel or 0)
	elseif chestName == "Old" then
		return 102
	elseif chestName == "Golden" then
		return 60
	elseif chestName == "Red" then
		return 66
	elseif chestName == "Mom" then
		return 42
	end
	return 30
end

--红箱子心价值
BLost.HeartValueForRed = {
	[HeartSubType.HEART_FULL] = 4,
	[HeartSubType.HEART_HALF] = 2,
	[HeartSubType.HEART_SOUL] = 6,
	[HeartSubType.HEART_ETERNAL] = 14,
	[HeartSubType.HEART_DOUBLEPACK] = 8,
	[HeartSubType.HEART_BLACK] = 12,
	[HeartSubType.HEART_GOLDEN] = 14,
	[HeartSubType.HEART_HALF_SOUL] = 3,
	[HeartSubType.HEART_SCARED] = 4,
	[HeartSubType.HEART_BLENDED] = 14,
	[HeartSubType.HEART_BONE] = 12,
	[HeartSubType.HEART_ROTTEN] = 5,
}

--尝试吸收心(用于红箱子修复)
function BLost:TryAbsorbHeart(player, slot, heart)
	if player:GetPlayerType() ~= self.ID then return false end
	local pickup = (heart ~= nil) and heart:ToPickup()
	if not pickup then return false end
	local value = self.HeartValueForRed[pickup.SubType]
	local mecha = self:GetMechaData(player)
	
	if mecha[slot].Chest == 'Red' and value ~= nil then
		local can = false
		
		--花钱买
		if pickup.Price > 0 then
			if player:GetNumCoins() >= pickup.Price then
				player:AddCoins(-pickup.Price)
				can = true
			end
		else
			can = true
		end
		
		if can then
			local mult = 2
			
			if slot == 2 then --护甲
				mult = 0.1
			end
		
			mecha[slot].Left = math.min(mecha[slot].Max, mecha[slot].Left + value*mult)
			Isaac.Spawn(1000, 15, 0, pickup.Position, Vector.Zero, nil)
			pickup:Remove()
			return true
		end
	end
	
	return false
end

--受伤判定
function BLost:OnTakeDMG(ent, dmg)
	if dmg <= 0 then return end
	local player = ent:ToPlayer()

	if player and player:GetPlayerType() == self.ID then
		local armor = self:GetMechaData(player)[2]
		if armor.Chest ~= nil and armor.Chest ~= "None" and armor.Left > 0 then
			armor.Left = armor.Left - 1
			player:SetMinDamageCooldown(self:GetArmorInvincibleFrames(armor.Chest, self:GetMegaLevel(player)))
			
			--特效
			local effect = ChestMantle:Spawn(player)
			
			--永恒箱子概率不消耗耐久
			if armor.Chest == 'Eternal' then
				local rng = player:GetCollectibleRNG(IBS_ItemID.ChestChest)
				if rng:RandomInt(100) < 25 then
					armor.Left = armor.Left + 1
				end
			end

			--红箱护甲加伤
			if armor.Chest == 'Red' then
				local data = self:GetData(player)
				data.TempDMG = math.min(6, data.TempDMG + 0.3)
				effect.Color = Color(1,0,0,1)
				sfx:Play(277, 1, 2, false, 0.666)
			else
				sfx:Play(277)
			end
			
			--护甲耗尽时移除
			if armor.Left <= 0 and armor.Chest ~= 'Eternal' then
				--鬼箱变为普通箱
				if armor.Chest == 'Haunted' then
					armor.Chest = "Common"
					armor.Max = 2
					armor.Left = 1
				else
					armor.Chest = "None"
				end
				self:RefreshHUD(player)
			end
			player:AddCacheFlags(CacheFlag.CACHE_ALL, true)
			return false
		end
	end	
end
BLost:AddPriorityCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, 1000, 'OnTakeDMG')

--鬼箱甲额外道具选择
function BLost:OnPickupFirstAppear(pickup)
	if pickup.SubType <= 0 then return end
	local itemConfig = config:GetCollectible(pickup.SubType)
	if itemConfig and (self.DecomposeItem[pickup.SubType] or itemConfig:HasTags(ItemConfig.TAG_NO_LOST_BR)) then
		for i = 0, game:GetNumPlayers() - 1 do
			local player = Isaac.GetPlayer(i)
			if player:GetPlayerType() == self.ID then
				local mecha = self:GetMechaData(player)
				if mecha[2].Chest == 'Haunted' then
					local seed = pickup.InitSeed
					local pool = self._Pools:GetRoomPool(seed)
					local id = game:GetItemPool():GetCollectible(pool, true, seed)
					pickup:AddCollectibleCycle(id)
				end
			end
		end
	end
end
BLost:AddCallback(mod.IBS_CallbackID.PICKUP_FIRST_APPEAR, 'OnPickupFirstAppear', 100)

--切换房间
function BLost:OnNewRoom()
	for i = 0, game:GetNumPlayers() - 1 do
		local player = Isaac.GetPlayer(i)
		if player:GetPlayerType() == self.ID then
			local mecha = self:GetMechaData(player)
			--木箱护甲回满耐久
			for k,v in ipairs(mecha) do
				if k == 2 and v.Chest == 'Wooden' then
					v.Left = v.Max
				end
			end
			self:RefreshHUD(player)
		end
	end
end
BLost:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, 'OnNewRoom')

--清理房间
function BLost:OnRoomCleaned()
	for i = 0, game:GetNumPlayers() - 1 do
		local player = Isaac.GetPlayer(i)
		if player:GetPlayerType() == self.ID then
			local mecha = self:GetMechaData(player)
			--木箱恢复耐久
			for k,v in ipairs(mecha) do
				if v.Chest == 'Wooden' then
					v.Left = math.min(v.Max, v.Left + 3)
				end
			end
		end
	end
end
BLost:AddCallback(ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD, 'OnRoomCleaned')

--新层
function BLost:OnNewLevel()
	for i = 0, game:GetNumPlayers() - 1 do
		local player = Isaac.GetPlayer(i)
		if player:GetPlayerType() == self.ID then
			local data = self:GetData(player)
			local mecha = self:GetMechaData(player)
			data.TempDMG = 0 --清除红箱护甲给予的伤害
			
			--木箱武器和僚机回满耐久
			for k,v in ipairs(mecha) do
				if k ~= 2 and v.Chest == 'Wooden' then
					v.Left = v.Max
				end
			end
			
			player:AddCacheFlags(CacheFlag.CACHE_DAMAGE, true)
			self:RefreshHUD(player)
		end
	end
end
BLost:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, 'OnNewLevel')

--碰撞判定
function BLost:PrePickupCollision(pickup, other)
	local player = other:ToPlayer()
	if not player then return end
	if player:GetPlayerType() ~= self.ID then return end
	
	--按住丢弃键时才能开箱子
	if self._Pickups:IsChest(pickup.Variant) and not Input.IsActionPressed(ButtonAction.ACTION_DROP, player.ControllerIndex) then
		return false
	end	
	
	--防抢红箱子心
	if pickup.Variant == 10 and self.HeartValueForRed[pickup.SubType] then
		local mecha = self:GetMechaData(player)
		for _,k in ipairs(mecha) do
			if k.Chest == 'Red' then
				return false
			end
		end
	end
end
BLost:AddPriorityCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, CallbackPriority.LATE, 'PrePickupCollision')

--属性(部分已在zml中)
function BLost:OnEvaluateCache(player, flag)
	if player:GetPlayerType() ~= self.ID then return end
	local data = self:GetData(player)
	local mecha = self:GetMechaData(player)
	local megaLevel = self:GetMegaLevel(player)
	local armor = mecha[2]

	if flag == CacheFlag.CACHE_SPEED then
		if armor.Chest == "Common" then
			Stats:Speed(player, 0.15)
		end	
		if armor.Chest == "Stone" then
			Stats:Speed(player, -0.15)
		end
		if armor.Chest == 'Mega' then
			Stats:Speed(player, -0.2 - 0.1*megaLevel)
		end
	end

	if flag == CacheFlag.CACHE_DAMAGE then
		local mult = 0.7
		if armor.Chest == 'Haunted' then
			mult = 1.2
		end
		player.Damage = player.Damage * mult + (data.TempDMG or 0)
	end

	if flag == CacheFlag.CACHE_LUCK then
		if armor.Chest == 'Golden' then
			Stats:Luck(player, 1)
		end
	end

	--飞行
	if flag == CacheFlag.CACHE_FLYING then
		player.CanFly = true
	end
end
BLost:AddPriorityCallback(ModCallbacks.MC_EVALUATE_CACHE, CallbackPriority.LATE, 'OnEvaluateCache')

--生成箱子跟班
function BLost:OnEvaluateCache2(player, flag)
	if flag & CacheFlag.CACHE_FAMILIARS > 0 then
		
		--僚机
		for chestName,subType in pairs(BLostFloat.SubType) do
			local num = 0
			
			if player:GetPlayerType() == self.ID then
				for slot = 4,6 do
					local float = self:GetMechaData(player)[slot]
					if float.Chest == chestName and float.Left > 0 then
						num = num + (BLostFloat.ChestInfo[subType].Count or 1)
					end
				end
			end
			
			player:CheckFamiliar(BLostFloat.Variant, num, RNG(1), nil, subType)
		end
		
		--武器
		for chestName,subType in pairs(BLostWeapon.SubType) do
			local num = 0
			
			if player:GetPlayerType() == self.ID then
				for slot = 1,3,2 do
					local weapon = self:GetMechaData(player)[slot]
					if weapon.Chest == chestName and weapon.Left > 0 then
						num = num + (BLostWeapon.ChestInfo[subType].Count or 1)
					end
				end
			end
			
			player:CheckFamiliar(BLostWeapon.Variant, num, RNG(1), nil, subType)
		end		
	end	
end
BLost:AddPriorityCallback(ModCallbacks.MC_EVALUATE_CACHE, -700, 'OnEvaluateCache2')


function BLost:OnPEffectUpdate(player)
	if player:GetPlayerType() == self.ID then
		local effect = player:GetEffects()

		--幽灵泪
		if not effect:HasCollectibleEffect(115) then
			effect:AddCollectibleEffect(115, false)
		end
		
		--模拟摇杆(方便全向攻击)
		if not player:HasCollectible(465) then
			player:AddInnateCollectible(465)
			player:RemoveCostume(config:GetCollectible(465))
		end		
	end	
end
BLost:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, 'OnPEffectUpdate')

--更新
function BLost:OnPlayerUpdate(player)
	local playerType = player:GetPlayerType()
	
	if playerType ~= self.ID then 
		local data = self._Players:GetData(player).BLost
		--游魂检测
		if data ~= nil and playerType == 10 then
			player:ChangePlayerType(self.ID)
			player:SetPocketActiveItem(self.Info.PocketActive, ActiveSlot.SLOT_POCKET, false)
		end
		return
	end
	
	local mecha = self:GetMechaData(player)
	local armor = mecha[2]
	
	--刺甲伤害
	if armor.Chest == 'Spike' then
		for _,target in ipairs(Isaac.GetRoomEntities()) do
			if self._Ents:IsEnemy(target) and player.Position:Distance(target.Position) <= 30 + 1.25 * target.Size then
				target:TakeDamage(0.5, 0, EntityRef(player), 0)
			end
		end	
	end
end
BLost:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, 'OnPlayerUpdate', 0)

--游戏更新
function BLost:OnUpdate()
	if game:GetFrameCount() % 30 ~= 0 then return end
	local isClear = (game:GetRoom():IsClear() or not self._Finds:ClosestEnemy(Vector.Zero))
	for i = 0, game:GetNumPlayers() - 1 do
		local player = Isaac.GetPlayer(i)
		if player:GetPlayerType() == self.ID then 
			local data = self:GetTempData(player)
			local mecha = self:GetMechaData(player)

			--武器和僚机在装备有妈箱护甲时耐久无限
			if mecha[2].Chest == "Mom" then
				--什么也不做
			else
				--消耗武器和僚机耐久(旧箱部件都会掉耐久)
				for slot,k in ipairs(mecha) do
					local old = (k.Chest == 'Old')
					if k.Chest ~= "None" and (not isClear or old) then
						--旧箱护甲19秒才掉一次耐久
						if slot == 2 and old then
							if k.Left > 1 then
								if data.OldArmorCounter < 19 then
									data.OldArmorCounter = data.OldArmorCounter + 1
								else
									data.OldArmorCounter = 0
									k.Left = k.Left - 1
								end
							end
						elseif slot ~= 2 then
							if k.Left > 0 then					
								k.Left = k.Left - 1
								
								--永恒箱子或贪婪模式概率不消耗耐久
								if k.Chest == 'Eternal' or (game:IsGreedMode() and k.Chest ~= 'Red') then
									local rng = player:GetCollectibleRNG(IBS_ItemID.ChestChest)
									if rng:RandomInt(100) < 50 then
										k.Left = k.Left + 1
									end
								end
								
								--贪婪红箱耐久消耗速度减半
								if game:IsGreedMode() and k.Chest == 'Red' and game:GetFrameCount() % 60 ~= 0 then
									k.Left = k.Left + 1
								end
							else
								--石僚机耗尽时生成金箱子道具和饰品
								if slot >= 4 and slot <= 6  and k.Chest == "Stone" then
									local itemPool = game:GetItemPool()
									local seed = self._Levels:GetRoomUniqueSeed()
									for i = 1,2 do
										local pos = game:GetRoom():FindFreePickupSpawnPosition(player.Position, 0, true)
										if i == 1 then
											Isaac.Spawn(5, 350, itemPool:GetTrinket(), pos, RandomVector() / 2, nil)									
										else		
											local id = itemPool:GetCollectible(ItemPoolType.POOL_GOLDEN_CHEST, true, seed)
											Isaac.Spawn(5, 100, id, pos, Vector.Zero, nil)							
										end
									end
								end
								
								--永恒箱子不消失
								if k.Chest ~= 'Eternal' then
									--鬼箱变为普通箱
									if k.Chest == 'Haunted' then
										local dura,init = self:GetChestDurability(slot, 'Common')
										k.Chest = "Common"
										k.Max = dura
										k.Left = math.floor(0.4*init)
									else
										k.Chest = "None"
									end
								end
								
								self:RefreshHUD(player)
								player:AddCacheFlags(CacheFlag.CACHE_ALL, true)
							end
						end
					end
						
				end
			end
		end
	end
end
BLost:AddCallback(ModCallbacks.MC_POST_UPDATE, 'OnUpdate')

--杀敌恢复旧箱耐久
function BLost:OnEntityKilled(ent)
	if not ent:IsEnemy() then return end
	for i = 0, game:GetNumPlayers() - 1 do
		local player = Isaac.GetPlayer(i)
		if player:GetPlayerType() == self.ID then 
			local mecha = self:GetMechaData(player)
			for slot,k in ipairs(mecha) do
				if k.Chest == 'Old' then
					local isArmor = (slot == 2)
					k.Left = math.min(k.Max, k.Left + ((isArmor and 0.05) or 2))
					
					--旧箱护甲耐久满时减少计时
					if isArmor and k.Left >= k.Max then
						local data = self:GetTempData(player)
						data.OldArmorCounter = math.max(0, data.OldArmorCounter - 2)
						if ent:IsBoss() then
							data.OldArmorCounter = math.max(0, data.OldArmorCounter - 19)
						end
					end
					
					--击杀boss额外恢复耐久
					if ent:IsBoss() then
						k.Left = math.min(k.Max, k.Left + ((isArmor and 1) or 8))
					end
				end
			end
		end
	end
end
BLost:AddCallback(ModCallbacks.MC_POST_ENTITY_KILL, 'OnEntityKilled')

--眼泪特效
function BLost:OnFireTear(tear)
	local player = self._Ents:IsSpawnerPlayer(tear, true)

    if player and player:GetPlayerType() == self.ID then
		local challengeMode = (Isaac.GetChallenge() == IBS_ChallengeID[11])
		local rng = player:GetCollectibleRNG(623)
		local chance = 10 + 4 * player.Luck
		if chance < 10 then chance = 10 end
		if chance > 50 then chance = 50 end
		
		--挑战概率上限降低
		if challengeMode and chance > 25 then
			chance = 25
		end
		
		if rng:RandomInt(100) < chance then
		
			--挑战改为变成炸弹
			if challengeMode then
				local bomb = player:FireBomb(tear.Position, 0.5 * tear.Velocity, player)
				tear:Remove()
			else
				tear:ChangeVariant(43)
				
				--硬核兼容增伤
				self:DelayFunction2(function()
					if tear:Exists() and not tear:IsDead() then				
						tear.CollisionDamage = tear.CollisionDamage + 1
					end
				end, 0)
				
				local scale = self._Maths:TearDamageToScale(tear.CollisionDamage+1)
				tear.SpriteScale = Vector(scale, scale)
				tear:Update()
			end
		end
    end
end
BLost:AddPriorityCallback(ModCallbacks.MC_POST_FIRE_TEAR, 200, 'OnFireTear')

--背景贴图
local weaponIconSpr = Sprite('gfx/ibs/ui/players/blost_hud.anm2')
weaponIconSpr:Play("Weapon")
local armorIconSpr = Sprite('gfx/ibs/ui/players/blost_hud.anm2')
armorIconSpr:Play("Armor")
local floatIconSpr = Sprite('gfx/ibs/ui/players/blost_hud.anm2')
floatIconSpr:Play("Float")

--获取图标渲染位置
function BLost:GetIconRenderPosition(idx)
	local screenSizeX, screenSizeY = Isaac.GetScreenWidth(), Isaac.GetScreenHeight()
	local X,Y = 0,0
	local offset = Options.HUDOffset

	if (idx == 0) then --P1
		X = 48 + 20*offset
		Y = 32 + 12*offset
	elseif (idx == 1) then --P2
		X = screenSizeX - 110 - 24*offset
		Y = 32 + 12*offset
	elseif (idx == 2) then --P3
		X = 80 + 22*offset
		Y = screenSizeY - 32 - 6*offset
	else --P4或其他
		X = screenSizeX - 80 - 16*offset
		Y = screenSizeY - 48 - 6*offset
	end
	
	return X,Y
end

--渲染
function BLost:OnHUDRender()
	if not game:GetHUD():IsVisible() then return end
	local controllers = {} --用于为控制器编号
	local index = 0
	
	for i = 0, game:GetNumPlayers() -1 do
		local player = Isaac.GetPlayer(i)
		local cid = player.ControllerIndex
		
		if (player.Variant == 0) and (player:GetPlayerType() == self.ID) and not player:IsCoopGhost() then
			if (not player.Parent) and (not controllers[cid]) then
				local mecha = BLost:GetMechaData(player)
				
				--显示箱子图标
				local X,Y = self:GetIconRenderPosition(index)
				local savedX = X
				local column = 1
				for k,spr in ipairs(BLost:GetHUDSpriteData(player)) do
					
					--背景贴图
					local percent = (mecha[k].Chest ~= "None" and mecha[k].Left/mecha[k].Max) or nil
					local color = Color(1,1,1,0.5)
					
					--颜色表示耐久损耗程度
					if percent then
						if percent > 0.7 then
							color = Color(0,1,0,0.5) --绿
						elseif percent > 0.35 and percent <= 0.7 then
							color = Color(1,1,0,0.5) --黄
						else
							color = Color(1,0,0,0.5) --红
						end
						
						--护甲耐久小于等于1直接显示红色
						if k == 2 then
							if mecha[k].Left <= 1 then
								color = Color(1,0,0,0.5)
							end
						elseif mecha[2].Chest == "Mom" then
							--武器和僚机在装备有妈箱护甲时耐久无限
							color = Color(1,0,1,0.5) --紫
						end
					end
					
					if k == 1 or k == 3 then
						weaponIconSpr.Color = color
						weaponIconSpr:Render(Vector(X,Y))
					end
					if k == 2 then
						armorIconSpr.Color = color
						armorIconSpr:Render(Vector(X,Y))
					end
					if k >= 4 and k <= 6 then
						floatIconSpr.Color = color
						floatIconSpr:Render(Vector(X,Y))
					end
				
					spr:Render(Vector(X,Y))
					
					X = X + 16
					column = column + 1
					
					if column > 3 then
						X = savedX
						Y = Y + 16
						column = 1
					end
				end

			end	
			controllers[cid] = true
			index = index + 1
		end
	end
	
	--EID显示位置稍微调下面一些
	if EID and game:GetRoom():GetFrameCount() > 0 then
		if EID.player and (EID.player:GetPlayerType() == self.ID) then
			EID:addTextPosModifier("IBS_BLost", Vector(0,32))
		else
			EID:removeTextPosModifier("IBS_BLost")
		end
	end	
end
BLost:AddCallback(ModCallbacks.MC_POST_HUD_RENDER, 'OnHUDRender')

--清除尿迹(十分生草)
local function ClearPee(_,effect)
	if game:GetRoom():GetFrameCount() > 0 then return end
	for i = 0, game:GetNumPlayers() - 1 do
		local player = Isaac.GetPlayer(i)
		if player:GetPlayerType() == BLost.ID then
			if effect.Position:Distance(player.Position) <= 1 then
				effect:Remove()
			end
		end
	end
end
mod:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, ClearPee, 7)


return BLost