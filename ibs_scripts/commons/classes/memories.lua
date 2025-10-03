--记忆碎片Class

local mod = Isaac_BenightedSoul
local Component = mod.IBS_Class.Component

local game = Game()
local sfx = SFXManager()
local config = Isaac.GetItemConfig()

local MemoryVariant = Isaac.GetEntityVariantByName('IBS_Memory')
local MemorySubType = Isaac.GetEntitySubTypeByName('IBS_Memory')
local MemorySubTypeBig = Isaac.GetEntitySubTypeByName('IBS_MemoryBig')

--掉落物记忆碎片价值
local PickupMemoryValue = {

	[PickupVariant.PICKUP_HEART] = {
		[HeartSubType.HEART_FULL] = 1,
		[HeartSubType.HEART_HALF] = 1,
		[HeartSubType.HEART_SOUL] = 3,
		[HeartSubType.HEART_ETERNAL] = 7,
		[HeartSubType.HEART_DOUBLEPACK] = 2,
		[HeartSubType.HEART_BLACK] = 3,
		[HeartSubType.HEART_GOLDEN] = 7,
		[HeartSubType.HEART_HALF_SOUL] = 2,
		[HeartSubType.HEART_SCARED] = 1,
		[HeartSubType.HEART_BLENDED] = 3,
		[HeartSubType.HEART_BONE] = 4,
		[HeartSubType.HEART_ROTTEN] = 2,
		["Other"] = 4
	},

	[PickupVariant.PICKUP_COIN] = {
		[CoinSubType.COIN_PENNY] = function(pickup)
			local rng = RNG() 
			rng:SetSeed(pickup.InitSeed, 35)
			return rng:RandomInt(2)
		end,
		[CoinSubType.COIN_NICKEL] = 3,
		[CoinSubType.COIN_DIME] = 6,
		[CoinSubType.COIN_DOUBLEPACK] = 1,
		[CoinSubType.COIN_LUCKYPENNY] = 7,
		[CoinSubType.COIN_STICKYNICKEL] = 6,
		[CoinSubType.COIN_GOLDEN] = function(pickup)
			local rng = RNG() 
			rng:SetSeed(pickup.InitSeed, 35)
			return rng:RandomInt(21) + 1
		end,
		["Other"] = 4
	},

	[PickupVariant.PICKUP_KEY] = {
		[KeySubType.KEY_NORMAL] = 2,
		[KeySubType.KEY_GOLDEN] = 17,
		[KeySubType.KEY_DOUBLEPACK] = 4,
		[KeySubType.KEY_CHARGED] = 10,
		["Other"] = 5
	},

	[PickupVariant.PICKUP_BOMB] = {
		[BombSubType.BOMB_NORMAL] = 2,
		[BombSubType.BOMB_DOUBLEPACK] = 4,
		[BombSubType.BOMB_TROLL] = -1,
		[BombSubType.BOMB_GOLDEN] = 21,
		[BombSubType.BOMB_SUPERTROLL] = -1,
		[BombSubType.BOMB_GOLDENTROLL] = -1,
		[BombSubType.BOMB_GIGA] = 10,
		["Other"] = 5
	},

	[PickupVariant.PICKUP_POOP] = {
		[PoopPickupSubType.POOP_SMALL] = 1,
		[PoopPickupSubType.POOP_BIG] = 3,
		["Other"] = 5
	},

	[PickupVariant.PICKUP_PILL] = 2,

	[PickupVariant.PICKUP_LIL_BATTERY] = {
		[BatterySubType.BATTERY_NORMAL] = 3,
		[BatterySubType.BATTERY_MICRO] = 1,
		[BatterySubType.BATTERY_MEGA] = 12,
		[BatterySubType.BATTERY_GOLDEN] = 21,
		["Other"] = 5
	},

	[PickupVariant.PICKUP_COLLECTIBLE] = function(pickup)
		local level = game:GetLevel()
		if level:GetCurrentRoomIndex() == -12 then return -1 end --创世纪房间禁拆
		if level:GetDimension() == Dimension.DEATH_CERTIFICATE then return -1 end --死亡证明房间禁拆		
		
		local id = pickup.SubType
		if id == 0 then return -1 end --空底座
		if id == 668 then return -1 end --便条
		if id < 0 then return 2 end
		local itemConfig = config:GetCollectible(id)
		local quality = (itemConfig and itemConfig.Quality) or 0
		
		if (quality <= 0) then
			return 2
		elseif (quality == 1) then
			return 7
		elseif (quality == 2) then
			return 14
		elseif (quality == 3) then
			return 28
		elseif (quality >= 4) then
			return 63
		end
		
		return 1
	end,

	[PickupVariant.PICKUP_TAROTCARD] = function(pickup)
		local cardConfig = config:GetCard(pickup.SubType)
		local cardType = (cardConfig and cardConfig.CardType) or ItemConfig.CARDTYPE_SPECIAL_OBJECT
		
		if (cardType == ItemConfig.CARDTYPE_TAROT) then
			return 2
		elseif (cardType == ItemConfig.CARDTYPE_SUIT) then
			return 7
		elseif (cardType == ItemConfig.CARDTYPE_RUNE) then
			return 5
		elseif (cardType == ItemConfig.CARDTYPE_SPECIAL) then
			return 4
		elseif (cardType == ItemConfig.CARDTYPE_SPECIAL_OBJECT) then
			return 5
		elseif (cardType == ItemConfig.CARDTYPE_TAROT_REVERSE) then
			return 7
		end	

		return 4
	end,

	[PickupVariant.PICKUP_TRINKET] = 5,

}

local Memories = mod.Class(Component, function(self)
	Component._ctor(self)

	--获取数据
	function self:GetData()
		local data = self:GetIBSData('temp')

		data.Memories = data.Memories or {
			Num = 0,
			Max = 99
		}

		return data.Memories
	end
	
	--获取数量
	function self:GetNum()
		local data = self:GetIBSData('temp').Memories
		return (data and data.Num) or 0
	end

	--获取上限
	function self:GetMax()
		local data = self:GetIBSData('temp').Memories
		return (data and data.Max) or 99
	end

	--增加数量
	function self:Add(num)
		local data = self:GetData()
		data.Num = math.min(data.Max, data.Num + num)
		if data.Num < 0 then data.Num = 0 end
	end

	--获取掉落物记忆碎片价值
	function self:GetPickupMemoryValue(pickup)
		local result = -1
		local info = PickupMemoryValue[pickup.Variant] or PickupMemoryValue["Other"]
		local typ = type(info)

		if (typ == "number") then
			result = info
		elseif (typ == "table") then
			local value = info[pickup.SubType]
			if type(value) == "number" then
				result = value
			elseif type(value) == "function" then
				result = value(pickup)
			end
		elseif (typ == "function") then
			result = info(pickup)
		end

		--贪婪模式价值翻倍
		if game:IsGreedMode() then
			result = result * 2
		end

		return result
	end

	--设置掉落物记忆碎片价值
	--(没有输入"subType"时,价值将为"variant"的)
	--(价值可以是自然数,或带有掉落物实体输入的函数)
	--(价值为函数时,需要返回自然数)
	function self:SetPickupMemoryValue(variant, subType, value)
		if (subType == nil) then
			if not PickupMemoryValue[variant] then PickupMemoryValue[variant] = value end
		else
			if not PickupMemoryValue[variant] then PickupMemoryValue[variant] = {} end
			if not PickupMemoryValue[variant][subType] then
				PickupMemoryValue[variant][subType] = value
			end
		end
	end

	--分解掉落物
	--(成功分解掉落物时,返回true,否则返回false)
	--(removeOptions为true时,将移除掉落物组中的其他掉落物)
	function self:DecomposePickup(pickup, removeOptions)
		if pickup.Price ~= 0 then return false end
		local SUCCESS = false
		local value = self:GetPickupMemoryValue(pickup)
		
		if value >= 0 then
			--优先分解出大记忆碎片,除非分解的是记忆碎片
			if (pickup.Variant ~= MemoryVariant) then
				while value - 5 >= 0 do
					local memory = Isaac.Spawn(5, MemoryVariant, MemorySubTypeBig, pickup.Position, Vector.Zero, nil):ToPickup()
					memory:SetColor(Color(1,1,1,1,1,1,1),30,1,true)
					memory.Wait = 30
					memory.Velocity = RandomVector()
					value = value - 5
				end
			end	
			if value > 0 then
				for i = 1,value do
					local memory = Isaac.Spawn(5, MemoryVariant, MemorySubType, pickup.Position, Vector.Zero, nil):ToPickup()
					memory:SetColor(Color(1,1,1,1,1,1,1),30,1,true)
					memory.Wait = 30
					memory.Velocity = RandomVector()
				end	
			end

			--尝试移除组中其他掉落物
			local idx = pickup.OptionsPickupIndex
			if removeOptions and (idx ~= 0) then
				for _,p in pairs(self._Pickups:GetPickupsByOptionsIndex(idx)) do
					p:Remove()
					Isaac.Spawn(1000, EffectVariant.POOF01, 0, p.Position, Vector.Zero, nil)
				end			
			else
				pickup:Remove()
				Isaac.Spawn(1000, EffectVariant.POOF01, 0, pickup.Position, Vector.Zero, nil)
			end	
				
			SUCCESS = true
		end

		return SUCCESS
	end

	--分解范围内掉落物
	--(位置和半径任意一个没有输入时,范围为一个房间)
	--(对于多选一的掉落物组,优先分解离输入位置最近的掉落物)
	--(removeOptions为true时,将移除掉落物组中的其他掉落物)
	--(成功分解任意掉落物时,返回true,否则返回false)
	function self:DecomposePickupsInRadius(position, radius, removeOptions)
		local pickups = nil
		
		if position and radius then
			pickups = Isaac.FindInRadius(position, radius, EntityPartition.PICKUP)
		else
			pickups = Isaac.FindByType(5)
		end
		
		position = position or Vector.Zero
		
		local SUCCESS = false
		local cachedPickups = {}

		for _,ent in ipairs(pickups) do
			local pickup = ent:ToPickup()
			if pickup then
				local idx = pickup.OptionsPickupIndex
				
				if (idx == 0) and not cachedPickups[idx] then
					if self:DecomposePickup(pickup) then SUCCESS = true end
				else
					cachedPickups[idx] = cachedPickups[idx] or {}
					for _,p in pairs(self._Pickups:GetPickupsByOptionsIndex(idx)) do
						table.insert(cachedPickups[idx], p)
					end
				end	
			end
		end

		--对于多选一的掉落物组,优先分解离输入位置最近的掉落物

		for _,Table in pairs(cachedPickups) do
			local closestPickup = self._Finds:ClosestEntityInTable(position, Table, function(pickup)
				return (self:GetPickupMemoryValue(pickup) >= 0)
			end)
			
			--尝试移除组中其他掉落物
			if self:DecomposePickup(closestPickup) then
				if removeOptions then
					for _,p in pairs(Table) do
						p:Remove()
						Isaac.Spawn(1000, EffectVariant.POOF01, 0, p.Position, Vector.Zero, nil)
					end
				end
				SUCCESS = true
			end
		end
		
		return SUCCESS
	end
	
end)


return Memories
