--昧化店主

local mod = Isaac_BenightedSoul
local IBS_CallbackID = mod.IBS_CallbackID
local IBS_TrinketID = mod.IBS_TrinketID
local Stats = mod.IBS_Lib.Stats
local CharacterLock = mod.IBS_Achiev.CharacterLock
local Damage = mod.IBS_Class.Damage()

local game = Game()
local sfx = SFXManager()

local BKeeper = mod.IBS_Class.Character(mod.IBS_PlayerID.BKeeper, {
	SpritePath = 'gfx/ibs/characters/player_bkeeper.anm2',
	SpritePathFlight = 'gfx/ibs/characters/player_bkeeper.anm2',
	PocketActive = mod.IBS_ItemID.AnotherKarma,
})

--获取数据
function BKeeper:GetData()
	local data = self:GetIBSData('temp')
	data.BKeeper =  data.BKeeper or {Donations = 0, HeartTokens = 0}
	return data.BKeeper
end

--更改道具价格
function BKeeper:OnPriceUpdate(variant, subType, shopItemID, price)
	if price <= 0 then return end
	if not PlayerManager.AnyoneIsPlayerType(self.ID) then return end
	local newPrice = price
	
	if variant == 100 and subType ~= 0 then
		--长子权
		if subType == 619 then
			newPrice = 0
		else
			local data = self:GetData()
			newPrice = math.ceil(newPrice * math.max(0, 3 - (3/700) * data.Donations))		
		end
	end	

	--0元购
	if newPrice <= 0 then newPrice = -1000 end

	if newPrice ~= price then	
		return newPrice
	end
end
BKeeper:AddPriorityCallback(ModCallbacks.MC_GET_SHOP_ITEM_PRICE, CallbackPriority.IMPORTANT, 'OnPriceUpdate')

--变身
function BKeeper:Benighted(player, fromMenu)
	local CAN = false
	
	--检测木头币
	for slot = 0,1 do
		if player:GetActiveItem(slot) == CollectibleType.COLLECTIBLE_WOODEN_NICKEL then
			player:RemoveCollectible(CollectibleType.COLLECTIBLE_WOODEN_NICKEL, true, slot)
			CAN = true
			break
		end	
	end	
	if player:GetActiveItem(2) == CollectibleType.COLLECTIBLE_WOODEN_NICKEL then CAN = true end
	for slot = 0,1 do
		if player:GetTrinket(slot) == TrinketType.TRINKET_STORE_KEY then
			player:TryRemoveTrinket(TrinketType.TRINKET_STORE_KEY)
			break
		end
	end
	player:AddBombs(-1)

	if CAN or fromMenu then
		player:ChangePlayerType(self.ID)
		player:SetPocketActiveItem(self.Info.PocketActive, ActiveSlot.SLOT_POCKET, false)

		local data = BKeeper:GetData()
		data.HeartTokens = data.HeartTokens + 14

		local coin = player:GetNumCoins()
		if coin < 70 then
			player:AddCoins(70-coin)
		end
		
		--完成挑战后自带审判
		if self:GetIBSData('persis')['bc13'] then
			player:AddCard(21)
		end
		
		player:AddControlsCooldown(90)
		self:DelayFunction2(function() player:AnimateAppear() end, 3)
	end	
end
BKeeper:AddCallback(IBS_CallbackID.BENIGHTED, 'Benighted', PlayerType.PLAYER_KEEPER)

--更新
function BKeeper:OnPlayerUpdate(player)
	if player:GetPlayerType() ~= self.ID then return end
	local tData = self._Ents:GetTempData(player)
	
	tData.BKeeperHurtCoinHeart = false
	
	--自动吞下硬币饰品
	for _,id in ipairs(self._Pools.PennyTrinketList) do
		for slot = 0,1 do
			if player:GetTrinket(slot) == id then
				player:TryRemoveTrinket(id)
				player:AddSmeltedTrinket(id, false)
				sfx:Play(157)
			end

			--金饰品
			local golden = id + 32768
			if player:GetTrinket(slot) == golden then
				player:TryRemoveTrinket(golden)
				player:AddSmeltedTrinket(golden, false)
				sfx:Play(157)
			end		
		end	
	end
end
BKeeper:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, 'OnPlayerUpdate', 0)

--受伤判定
function BKeeper:OnTakeDMG(ent, dmg, flag, source, cd)
	if dmg <= 0 then return end
	local player = ent:ToPlayer()
	if player and player:GetPlayerType() == self.ID then
		local data = self:GetData()
		local tData = self._Ents:GetTempData(player)
		
		tData.BKeeperHurtCoinHeart = true	
	
		--可互动实体优先消耗心币
		if source and source.Type == 6 then
			if data.HeartTokens >= 2 then
				data.HeartTokens = data.HeartTokens - 2
				return {Damage = 1, DamageFlags = flag | DamageFlag.DAMAGE_FAKE | DamageFlag.DAMAGE_NO_PENALTIES, DamageCountdown = cd}
			end
		end
		
		--硬核不掉房率
		if game:GetDebugFlags() & DebugFlag.INFINITE_HP <= 0 then --检测debug3
			--致命伤优先消耗心币
			if player:GetHearts() <= 2 and data.HeartTokens >= 14 then
				data.HeartTokens = data.HeartTokens - 14
				return {Damage = 1, DamageFlags = flag | DamageFlag.DAMAGE_FAKE, DamageCountdown = cd}
			else	
				if not Damage:IsPlayerSelfDamage(player, flag, source) then
					player:AddHearts(-2)
					return {Damage = 1, DamageFlags = flag | DamageFlag.DAMAGE_FAKE, DamageCountdown = cd}
				end
			end
		end
	end	
end
BKeeper:AddPriorityCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, 7777777, 'OnTakeDMG')


--尝试移除玩家生成的硬币
function BKeeper:OnCoinInit(pickup)
	local player = self._Ents:IsSpawnerPlayer(pickup, true)
	if player and player:GetPlayerType() == self.ID then
		if self._Ents:GetTempData(player).BKeeperHurtCoinHeart then
			local rng = RNG(pickup.InitSeed)
			if rng:RandomFloat() < 0.4 then
				pickup:Remove()
			end
		end	
	end
end
BKeeper:AddCallback(ModCallbacks.MC_POST_PICKUP_INIT, 'OnCoinInit', PickupVariant.PICKUP_COIN)

--心免费
function BKeeper:OnHeartUpdate(pickup)
	if PlayerManager.AnyoneIsPlayerType(self.ID) and pickup.Price ~= 0 and pickup.Price ~= -1000 then
		pickup.AutoUpdatePrice = false
		pickup.Price = -1000
	end
end
BKeeper:AddCallback(ModCallbacks.MC_POST_PICKUP_UPDATE, 'OnHeartUpdate', PickupVariant.PICKUP_HEART)

--长子权
--硬币饰品有概率变为金色
function BKeeper:OnPennyTrinketInit(pickup)
	if self._Pools:IsPennyTrinket(pickup.SubType, true) then
		for i = 0, game:GetNumPlayers() - 1 do
			local player = Isaac.GetPlayer(i)
			if player:GetPlayerType() == self.ID and player:HasCollectible(619) then
				if RNG(pickup.InitSeed):RandomInt(3) == 0 then
					pickup:Morph(5, 350, pickup.SubType + 32768, true, true, true)
				end
				break
			end
		end
	end
end
BKeeper:AddCallback(ModCallbacks.MC_POST_PICKUP_INIT, 'OnPennyTrinketInit', PickupVariant.PICKUP_TRINKET)


--硬币饰品对应的道具池
BKeeper.PoolForPennyTrinket = {

	--普通乞丐
	[ItemPoolType.POOL_BEGGAR] = {
		[TrinketType.TRINKET_SWALLOWED_PENNY] = {
			{Pool = ItemPoolType.POOL_TREASURE, Times = 10},
		},
		[TrinketType.TRINKET_BUTT_PENNY] = {
			{Pool = ItemPoolType.POOL_BOSS, Times = 10},
		},
		[TrinketType.TRINKET_BLOODY_PENNY] = {
			{Pool = ItemPoolType.POOL_ULTRA_SECRET, Times = 5},
			{Pool = ItemPoolType.POOL_DEVIL, Times = 3},
		},
		[TrinketType.TRINKET_BURNT_PENNY] = {
			{Pool = ItemPoolType.POOL_BOMB_BUM, Times = 1},
			{Pool = ItemPoolType.POOL_SECRET, Times = 3},
		},
		[TrinketType.TRINKET_FLAT_PENNY] = {
			{Pool = ItemPoolType.POOL_KEY_MASTER, Times = 1},
			{Pool = ItemPoolType.POOL_GOLDEN_CHEST, Times = 5},
			{Pool = ItemPoolType.POOL_OLD_CHEST, Times = 1},
		},
		[TrinketType.TRINKET_COUNTERFEIT_PENNY] = {
			{Pool = ItemPoolType.POOL_SHOP, Times = 5},
		},
		[TrinketType.TRINKET_ROTTEN_PENNY] = {
			{Pool = ItemPoolType.POOL_ROTTEN_BEGGAR, Times = 1},
			{Pool = ItemPoolType.POOL_RED_CHEST, Times = 2},
			{Pool = ItemPoolType.POOL_CURSE, Times = 2},
		},
		[TrinketType.TRINKET_BLESSED_PENNY] = {
			{Pool = ItemPoolType.POOL_ANGEL, Times = 7},
		},
		[TrinketType.TRINKET_CHARGED_PENNY] = {
			{Pool = ItemPoolType.POOL_BATTERY_BUM, Times = 3},
		},
		[TrinketType.TRINKET_CURSED_PENNY] = {
			{Pool = ItemPoolType.POOL_DEVIL, Times = 6},
			{Pool = ItemPoolType.POOL_RED_CHEST, Times = 3},
			{Pool = ItemPoolType.POOL_CURSE, Times = 3},
		},
		[IBS_TrinketID.GlitchedPenny] = {
			{Pool = "Random", Times = 10},
		},
		[IBS_TrinketID.StarryPenny] = {
			{Pool = ItemPoolType.POOL_PLANETARIUM, Times = 8},
		},
		[IBS_TrinketID.PaperPenny] = {
			{Pool = ItemPoolType.POOL_LIBRARY, Times = 8},
		},
		[IBS_TrinketID.OldPenny] = {
			{Pool = ItemPoolType.POOL_OLD_CHEST, Times = 8},
		},
	},
	
	--恶魔乞丐
	[ItemPoolType.POOL_DEMON_BEGGAR] = {
		[TrinketType.TRINKET_BLOODY_PENNY] = {
			{Pool = ItemPoolType.POOL_DEVIL, Times = 24},
		},
		[TrinketType.TRINKET_COUNTERFEIT_PENNY] = {
			{Pool = ItemPoolType.POOL_SHOP, Times = 2},
		},
		[TrinketType.TRINKET_CURSED_PENNY] = {
			{Pool = ItemPoolType.POOL_DEVIL, Times = 24},
			{Pool = ItemPoolType.POOL_RED_CHEST, Times = 6},
		},
		[IBS_TrinketID.GlitchedPenny] = {
			{Pool = "Random", Times = 5},
		},	
	},

	--钥匙乞丐
	[ItemPoolType.POOL_KEY_MASTER] = {
		[TrinketType.TRINKET_BLOODY_PENNY] = {
			{Pool = ItemPoolType.POOL_ULTRA_SECRET, Times = 4},
			{Pool = ItemPoolType.POOL_DEVIL, Times = 6},
		},
		[TrinketType.TRINKET_BURNT_PENNY] = {
			{Pool = ItemPoolType.POOL_SECRET, Times = 5},
		},
		[TrinketType.TRINKET_FLAT_PENNY] = {
			{Pool = ItemPoolType.POOL_GOLDEN_CHEST, Times = 10},
			{Pool = ItemPoolType.POOL_OLD_CHEST, Times = 3},
		},
		[TrinketType.TRINKET_COUNTERFEIT_PENNY] = {
			{Pool = ItemPoolType.POOL_SHOP, Times = 2},
		},
		[TrinketType.TRINKET_ROTTEN_PENNY] = {
			{Pool = ItemPoolType.POOL_RED_CHEST, Times = 4},
		},
		[TrinketType.TRINKET_BLESSED_PENNY] = {
			{Pool = ItemPoolType.POOL_ANGEL, Times = 4},
		},
		[TrinketType.TRINKET_CHARGED_PENNY] = {
			{Pool = ItemPoolType.POOL_BATTERY_BUM, Times = 2},
		},
		[TrinketType.TRINKET_CURSED_PENNY] = {
			{Pool = ItemPoolType.POOL_RED_CHEST, Times = 4},
		},
		[IBS_TrinketID.GlitchedPenny] = {
			{Pool = "Random", Times = 5},
		},
		[IBS_TrinketID.StarryPenny] = {
			{Pool = ItemPoolType.POOL_PLANETARIUM, Times = 5},
		},
		[IBS_TrinketID.PaperPenny] = {
			{Pool = ItemPoolType.POOL_LIBRARY, Times = 3},
		},		
		[IBS_TrinketID.OldPenny] = {
			{Pool = ItemPoolType.POOL_OLD_CHEST, Times = 2},
		},
	},

	--炸弹乞丐
	[ItemPoolType.POOL_BOMB_BUM] = {
		[TrinketType.TRINKET_BLOODY_PENNY] = {
			{Pool = ItemPoolType.POOL_ULTRA_SECRET, Times = 4},
			{Pool = ItemPoolType.POOL_DEVIL, Times = 6},
		},
		[TrinketType.TRINKET_BURNT_PENNY] = {
			{Pool = ItemPoolType.POOL_SECRET, Times = 5},
		},
		[TrinketType.TRINKET_FLAT_PENNY] = {
			{Pool = ItemPoolType.POOL_OLD_CHEST, Times = 3},
		},
		[TrinketType.TRINKET_COUNTERFEIT_PENNY] = {
			{Pool = ItemPoolType.POOL_SHOP, Times = 2},
		},
		[TrinketType.TRINKET_ROTTEN_PENNY] = {
			{Pool = ItemPoolType.POOL_CURSE, Times = 4},
		},
		[TrinketType.TRINKET_BLESSED_PENNY] = {
			{Pool = ItemPoolType.POOL_ANGEL, Times = 4},
		},
		[TrinketType.TRINKET_CHARGED_PENNY] = {
			{Pool = ItemPoolType.POOL_BATTERY_BUM, Times = 2},
		},
		[TrinketType.TRINKET_CURSED_PENNY] = {
			{Pool = ItemPoolType.POOL_CURSE, Times = 4},
		},
		[IBS_TrinketID.GlitchedPenny] = {
			{Pool = "Random", Times = 5},
		},
		[IBS_TrinketID.StarryPenny] = {
			{Pool = ItemPoolType.POOL_PLANETARIUM, Times = 3},
		},
		[IBS_TrinketID.PaperPenny] = {
			{Pool = ItemPoolType.POOL_LIBRARY, Times = 3},
		},
		[IBS_TrinketID.OldPenny] = {
			{Pool = ItemPoolType.POOL_OLD_CHEST, Times = 2},
		},		
	},
	
	--电池乞丐
	[ItemPoolType.POOL_BATTERY_BUM] = {
		[TrinketType.TRINKET_BLOODY_PENNY] = {
			{Pool = ItemPoolType.POOL_DEVIL, Times = 3},
		},	
		[TrinketType.TRINKET_COUNTERFEIT_PENNY] = {
			{Pool = ItemPoolType.POOL_SHOP, Times = 2},
		},
		[TrinketType.TRINKET_BLESSED_PENNY] = {
			{Pool = ItemPoolType.POOL_ANGEL, Times = 3},
		},
		[TrinketType.TRINKET_CURSED_PENNY] = {
			{Pool = ItemPoolType.POOL_DEVIL, Times = 3},
		},
		[IBS_TrinketID.GlitchedPenny] = {
			{Pool = "Random", Times = 1},
		},
		[IBS_TrinketID.StarryPenny] = {
			{Pool = ItemPoolType.POOL_PLANETARIUM, Times = 2},
		},	
	},

	--腐烂乞丐
	[ItemPoolType.POOL_ROTTEN_BEGGAR] = {
		[TrinketType.TRINKET_BLOODY_PENNY] = {
			{Pool = ItemPoolType.POOL_DEVIL, Times = 4},
		},	
		[TrinketType.TRINKET_COUNTERFEIT_PENNY] = {
			{Pool = ItemPoolType.POOL_SHOP, Times = 2},
		},
		[TrinketType.TRINKET_BLESSED_PENNY] = {
			{Pool = ItemPoolType.POOL_ANGEL, Times = 8},
		},
		[TrinketType.TRINKET_CURSED_PENNY] = {
			{Pool = ItemPoolType.POOL_DEVIL, Times = 8},
		},
		[IBS_TrinketID.GlitchedPenny] = {
			{Pool = "Random", Times = 2},
		},
	},

}

--尝试更改乞丐道具池
function BKeeper:TryChangeBeggerPool(pool, seed)
	local itemPool = game:GetItemPool()
	local cache = {}
	local info = self.PoolForPennyTrinket[pool]

	for i = 1,28 do
		table.insert(cache, pool)
	end

	if info then
		for trinket,pools in pairs(info) do
			local mult = PlayerManager.GetTotalTrinketMultiplier(trinket)
			if mult > 0 then
				for i2 = 1,mult do	
					for _,v in ipairs(pools) do
						if v.Pool == 'Random' then
							for times = 1,v.Times do
								table.insert(cache, itemPool:GetRandomPool(RNG(seed)))
							end								
						else
							for times = 1,v.Times do
								table.insert(cache, v.Pool)
							end					
						end
					end
				end
			end
		end
	end

	--抽取一个
	if #cache > 0 then
		return self._Pools:ToGreed(cache[RNG(seed):RandomInt(1, #cache)] or cache[1])
	else
		return self._Pools:ToGreed(pool)
	end
end

--获取更改后的道具
function BKeeper:GetModifieredCollectible(pool, seed, shouldRemove)
	pool = self:TryChangeBeggerPool(pool, seed)

	local itemPool = game:GetItemPool()
	local result = {}
	
	for _,v in ipairs(itemPool:GetCollectiblesFromPool(pool)) do
		local id = v.itemID
		if itemPool:HasCollectible(id) then
			table.insert(result, id)
		end
	end
	
	--抽取一个
	if #result > 0 then
		local id = result[RNG(seed):RandomInt(1, #result)] or result[1]

		--移出道具池
		if shouldRemove then
			itemPool:RemoveCollectible(id)
		end

		return id
	else
		return 0
	end
end

function BKeeper:PrePoolGetCollectible(pool, decrease, seed)
	if not PlayerManager.AnyoneIsPlayerType(self.ID) then return end

	--混沌
	if PlayerManager.AnyoneHasCollectible(402) then return end
	
	if self.PoolForPennyTrinket[pool] then
		return self:GetModifieredCollectible(pool, seed, decrease)
	end
end
BKeeper:AddCallback(ModCallbacks.MC_PRE_GET_COLLECTIBLE, 'PrePoolGetCollectible')

--心数阶段
BKeeper.HeartLimitStage = {
	[28] = 2,
	[70] = 3,
	[128] = 4,
	[192] = 5,
	[262] = 6,
	[332] = 7,
	
	--长子权部分
	[402] = 8,
	[472] = 9,
	[542] = 10,
	[612] = 11,
	[682] = 12,
}
BKeeper.HeartLimitStage2 = {}
for k,_ in pairs(BKeeper.HeartLimitStage) do
	table.insert(BKeeper.HeartLimitStage2, k)
end

--心数限制
function BKeeper:HeartLimit(player)
	local limit = 2
	local donations = self:GetData().Donations

	for level = #self.HeartLimitStage2,1,-1 do
		if donations >= self.HeartLimitStage2[level] then
			limit = 2 * self.HeartLimitStage[self.HeartLimitStage2[level]]
		end
	end

	--最多7个,有长子权则为12个
	if player:HasCollectible(619) then
		if limit > 24 then limit = 24 end
	else
		if limit > 14 then limit = 14 end
	end

	return limit
end
BKeeper:AddCallback(ModCallbacks.MC_PLAYER_GET_HEART_LIMIT, 'HeartLimit', BKeeper.ID)

--持有诅咒硬币时尝试返还
function BKeeper:TryReturn(player, ent, pickup)
	if player:GetPlayerType() ~= self.ID then return false end
	if not player:HasTrinket(TrinketType.TRINKET_CURSED_PENNY) then return false end
	local mult = player:GetTrinketMultiplier(TrinketType.TRINKET_CURSED_PENNY)
	local chance = math.min(60, 24*mult)

	if chance > player:GetTrinketRNG(TrinketType.TRINKET_CURSED_PENNY):RandomInt(100) then
		local variant = ent.Variant
		
		--可互动实体
		if ent:ToSlot() then
			--乞丐/电池乞丐/腐烂乞丐
			if variant == 4 or variant == 13 or variant == 18 then
				player:AddCoins(1)
			end

			--恶魔乞丐
			if variant == 5 then
				local data = self:GetData()
				data.HeartTokens = math.min(99, data.HeartTokens + 2)
			end		
			
			--钥匙乞丐
			if variant == 7 then
				player:AddKeys(1)
			end

			--炸弹乞丐
			if variant == 9 then
				player:AddBombs(1)
			end
		elseif ent:ToFamiliar() and pickup then --跟班
			
			--乞丐朋友
			if variant == 24 then
				player:AddCoins(1)
			end
			
			--黑暗乞丐
			if variant == 64 then
				local heart = Isaac.Spawn(5,10,0, ent.Position, RandomVector(), nil):ToPickup()
				heart.Wait = 60
			end		
		
			--钥匙乞丐
			if variant == 90 then
				player:AddKeys(1)
			end
			
			--超级乞丐
			if variant == 102 then
				if pickup.Variant == 10 then --心
					local heart = Isaac.Spawn(5,10,0, ent.Position, RandomVector(), nil):ToPickup()
					heart.Wait = 60
				end
				if pickup.Variant == 10 then --硬币				
					player:AddCoins(1)
				end
					if pickup.Variant == 30 then --钥匙				
					player:AddKeys(1)
				end
			end		
		end

		return true
	end
	
	return false
end

--记录乞丐捐赠
function BKeeper:OnBumDonation(ent, pickup)
	local data = self:GetData()
	local times = (game:IsGreedMode() and 2) or 1
	
	for i = 1,times do
		data.Donations = data.Donations + 1

		--每达到一定次数时给予一个心容
		if self.HeartLimitStage[data.Donations] then
			for i = 0, game:GetNumPlayers() - 1 do
				local player = Isaac.GetPlayer(i)
				if player:GetPlayerType() == self.ID then
					player:AddMaxHearts(2, true)
					player:AddHearts(2, true)
					sfx:Play(268)
				end
			end
		end
	end
	
	--尝试返还
	for i = 0, game:GetNumPlayers() - 1 do
		local player = Isaac.GetPlayer(i)
		if player:GetPlayerType() == self.ID then
			BKeeper:TryReturn(player, ent, pickup)
		end
	end
end
BKeeper:AddCallback(IBS_CallbackID.BUM_DONATION, 'OnBumDonation')

--心币价值
BKeeper.HeartTokenValue = {
	[HeartSubType.HEART_FULL] = 2,
	[HeartSubType.HEART_HALF] = 1,
	[HeartSubType.HEART_SOUL] = 3,
	[HeartSubType.HEART_ETERNAL] = 7,
	[HeartSubType.HEART_DOUBLEPACK] = 4,
	[HeartSubType.HEART_BLACK] = 4,
	[HeartSubType.HEART_GOLDEN] = 7,
	[HeartSubType.HEART_HALF_SOUL] = 2,
	[HeartSubType.HEART_SCARED] = 2,
	[HeartSubType.HEART_BLENDED] = 4,
	[HeartSubType.HEART_BONE] = 6,
	[HeartSubType.HEART_ROTTEN] = 2,
}

--获取心币价值
function BKeeper:GetHeartTokenValue(pickup)
	if pickup.Type ~= 5 then return 0 end
	if pickup.Variant ~= 10 then return 0 end
	return self.HeartTokenValue[pickup.SubType] or 4
end

--心币
function BKeeper:PreHeartCollision(pickup, other)
	local player = other:ToPlayer()
	if player and player:GetPlayerType() == self.ID then
		local data = self:GetData()
		data.HeartTokens = math.min(99, data.HeartTokens + self:GetHeartTokenValue(pickup))

		--特效
		local effect = self._Pickups:PlayCollectAnim(pickup, 30)
		effect.Color = Color(1,1,1,1,0.7,0.7)
		--Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, pickup.Position, Vector.Zero, nil)
		pickup:Remove()		
		sfx:Play(234, 1, 2, false, 0.7)
		
		return false
	end	
end
BKeeper:AddPriorityCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, -777, 'PreHeartCollision', PickupVariant.PICKUP_HEART)

function BKeeper:OnPEffectUpdate(player)
	if player:GetPlayerType() == self.ID then
		local effect = player:GetEffects()
		
		--双发
		if not effect:HasCollectibleEffect(245) then
			effect:AddCollectibleEffect(245, false)
		end				
	end	
end
BKeeper:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, 'OnPEffectUpdate')

--属性(部分已在zml中)
function BKeeper:OnEvaluateCache(player, flag)
	if player:GetPlayerType() ~= self.ID then return end

	if flag == CacheFlag.CACHE_DAMAGE then
		player.Damage = player.Damage * 0.8
	end

	--硬核大三四眼兼容
	if flag == CacheFlag.CACHE_FIREDELAY then
		local mult = 1

		--大眼
		local polyphemus = player:HasCollectible(CollectibleType.COLLECTIBLE_POLYPHEMUS)

		--2020数量(自带一个)
		local num2020 = player:GetCollectibleNum(CollectibleType.COLLECTIBLE_20_20)
		
		--三眼和倒倒吊人
		local innereye = player:HasCollectible(CollectibleType.COLLECTIBLE_INNER_EYE) or player:GetEffects():HasNullEffect(NullItemID.ID_REVERSE_HANGED_MAN)
		
		--四眼
		local mutantspider = player:HasCollectible(CollectibleType.COLLECTIBLE_MUTANT_SPIDER)
		
		--一堆兼容
		if (mutantspider) then
			if (num2020 > 0) then
				num2020 = num2020 - 1
				if (polyphemus) then
					mult = 1 / 0.42
				elseif (innereye) and not (num2020 > 0) then
					mult = 1 / 0.51
				end
			else
				mult = 1 / 0.42
			end
		elseif (polyphemus) then
			mult = 1 / 0.42	
		elseif (innereye) and not (num2020 > 0) then
			mult = 1 / 0.51
		end

		Stats:TearsMultiples(player, mult)
	end	

	--飞行
	if flag == CacheFlag.CACHE_FLYING then
		player.CanFly = true
	end
end
BKeeper:AddPriorityCallback(ModCallbacks.MC_EVALUATE_CACHE, CallbackPriority.LATE, 'OnEvaluateCache')

--获取心币显示位置
function BKeeper:GetHeartTokenRenderPosition(idx)
	local X,Y = Isaac.GetScreenWidth(), Isaac.GetScreenHeight()
	local offset = Options.HUDOffset
	
	if (idx == 0) then --P1
		X = 48 + 20*offset
		Y = 40 + 12*offset
	elseif (idx == 1) then --P2
		X = screenSizeX - 116 - 24*offset
		Y = 54 + 12*offset
	elseif (idx == 2) then --P3
		X = 100 + 22*offset
		Y = screenSizeY - 33 - 6*offset
	else --P4或其他
		X = screenSizeX - 80 - 16*offset
		Y = screenSizeY - 58 - 6*offset
	end
	
	return X,Y
end


--图标
local spr = Sprite('gfx/ibs/ui/hearttoken.anm2')
spr:Play(spr:GetDefaultAnimation())

--字体
fnt = Font('font/pftempestasevencondensed.fnt')

--渲染心币
function BKeeper:OnHUDRender()
	if not game:GetHUD():IsVisible() then return end

	local controllers = {} --用于为控制器编号
	local index = 0
	
	for i = 0, game:GetNumPlayers() -1 do
		local player = Isaac.GetPlayer(i)
		local cid = player.ControllerIndex

		if (not controllers[cid]) and player:GetPlayerType() == self.ID and (player.Variant == 0) and not player:IsCoopGhost() and not player.Parent then
			local X,Y = self:GetHeartTokenRenderPosition(index)
			local data = self:GetData()
			local inum = tostring(data.HeartTokens)
			if data.HeartTokens < 10 then inum = "0"..inum end
			if data.HeartTokens > 99 then data.HeartTokens = 99 end

			--未知诅咒兼容
			if (game:GetLevel():GetCurses() & LevelCurse.CURSE_OF_THE_UNKNOWN > 0) then
				inum = " ?"
			end
	
			spr:Render(Vector(X,Y))
			fnt:DrawString(inum, X+12, Y-8, KColor(1,1,1,1))
		end

		controllers[cid] = true
		index = index + 1
	end
	
	--EID显示位置稍微调下面一些
	if EID and game:GetRoom():GetFrameCount() > 0 then
		if EID.player and EID.player:GetPlayerType() == self.ID then
			EID:addTextPosModifier("IBS_BKEEPER", Vector(0,22))
		else
			EID:removeTextPosModifier("IBS_BKEEPER")
		end
	end		
end
BKeeper:AddPriorityCallback(ModCallbacks.MC_POST_HUD_RENDER, CallbackPriority.EARLY, 'OnHUDRender')



return BKeeper