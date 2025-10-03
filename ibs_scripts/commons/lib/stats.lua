--角色属性相关函数

--[[说明书:
此处的函数除了长久属性改动,都要参与刷新属性回调才有效
(ModCallbacks.MC_EVALUATE_CACHE)

由于技术力不足与官方接口缺失,属性倍率只能针对原版硬编码,
且对于射速,无法判断其上限变动,只能更改射速修正
]]

local mod = Isaac_BenightedSoul
local Players = mod.IBS_Lib.Players


local Stats = {}



--定义区开始--

--原版射速倍率
local VanillaTearsMultiples = {
    -- 1
    {	--眼药水
        function(player, tears)
            if (player:HasCollectible(CollectibleType.COLLECTIBLE_EYE_DROPS)) then
                tears = tears * 1.2
            end
            return tears
        end
    },
    -- 2
    {	
        function(player, tears)
			
			--碎王冠
            local crownCount = player:GetTrinketMultiplier(TrinketType.TRINKET_CRACKED_CROWN)
            if (crownCount > 0) then
                local multiplier = 0.2 * crownCount
                tears = tears + (multiplier * (tears - 30 / 11))
            end
			
			--里伯大尼
            if (player:GetPlayerType() == PlayerType.PLAYER_BETHANY_B) then
                local multiplier = -0.25
                tears = tears + (multiplier * (tears - 30 / 11))
            end

            return tears
        end
    },
    -- 3
    {
        function(player, tears)
            local effects = player:GetEffects()

			--大眼
			local polyphemus = player:HasCollectible(CollectibleType.COLLECTIBLE_POLYPHEMUS)

			--2020数量
			local num2020 = player:GetCollectibleNum(CollectibleType.COLLECTIBLE_20_20)
			
			--三眼和倒倒吊人
			local innereye = player:HasCollectible(CollectibleType.COLLECTIBLE_INNER_EYE) or effects:HasNullEffect(NullItemID.ID_REVERSE_HANGED_MAN)
			
			--四眼
			local mutantspider = player:HasCollectible(CollectibleType.COLLECTIBLE_MUTANT_SPIDER)
			
			
			--一堆兼容
            if (mutantspider) then
				if (num2020 > 0) then
					num2020 = num2020 - 1
					if (polyphemus) then
						tears = tears * 0.42
					elseif (innereye) and not (num2020 > 0) then
						tears = tears * 0.51
					end
				else
					tears = tears * 0.42
				end
			elseif (polyphemus) then
                tears = tears * 0.42	
            elseif (innereye) and not (num2020 > 0) then
                tears = tears * 0.51
            end
            
            return tears
        end
    },
    -- 4
    {
        function(player, tears)
            
			--血泪
			local haemolacria = player:HasCollectible(CollectibleType.COLLECTIBLE_HAEMOLACRIA)

			--硫磺火
            local brimstone = player:HasCollectible(CollectibleType.COLLECTIBLE_BRIMSTONE)

			--胎儿博士
            local drFetus = player:HasCollectible(CollectibleType.COLLECTIBLE_DR_FETUS)

			--剖腹产
            local cSection = player:HasCollectible(CollectibleType.COLLECTIBLE_C_SECTION)

			--萌肺
            local lung = player:HasCollectible(CollectibleType.COLLECTIBLE_MONSTROS_LUNG)

			--吐根
            local ipecac = player:HasCollectible(CollectibleType.COLLECTIBLE_IPECAC)

			--表骨和里骨
            local forgotten = playerType == PlayerType.PLAYER_THEFORGOTTEN or playerType == PlayerType.PLAYER_THEFORGOTTEN_B

            if (haemolacria) then
                if (cSection) then
                    tears = 30 * tears / (30 + 4 * tears)
                else
                    local playerType = player:GetPlayerType()
                    local multiplier = 1/3
                    local flat = 2
                    if (lung) then
                        multiplier = 4.3/3
                        flat = 4.3
                    elseif (ipecac) then
                        multiplier = 1/3
                        flat = 3
                    elseif (forgotten) then
                        multiplier = 2/3
                    elseif (drFetus) then
                        multiplier = 2/3
                    end

                    tears = tears / (multiplier * tears + flat)
                end
                if (brimstone) then
                    tears = 30 * tears / (30 + 20 * tears)
                end
            end
			
            return tears
        end
    },
    -- 5
    {
        function(player, tears)
            local playerType = player:GetPlayerType()
            local effects = player:GetEffects()
			
			--血泪
            local haemolacria = player:HasCollectible(CollectibleType.COLLECTIBLE_HAEMOLACRIA)

			--硫磺火
            local brimstone = player:HasCollectible(CollectibleType.COLLECTIBLE_BRIMSTONE)

			--胎儿博士
            local drFetus = player:HasCollectible(CollectibleType.COLLECTIBLE_DR_FETUS)

			--萌肺
            local lung = player:HasCollectible(CollectibleType.COLLECTIBLE_MONSTROS_LUNG)

			--吐根
            local ipecac = player:HasCollectible(CollectibleType.COLLECTIBLE_IPECAC)
			
			--狂暴
            local berserk = effects:HasCollectibleEffect(CollectibleType.COLLECTIBLE_BERSERK)
			
			--AZ
            local azazel = playerType == PlayerType.PLAYER_AZAZEL
			
			--里AZ
			local azazel_b = playerType == PlayerType.PLAYER_AZAZEL_B
			
			--表骨和里骨
            local forgotten = playerType == PlayerType.PLAYER_THEFORGOTTEN or playerType == PlayerType.PLAYER_THEFORGOTTEN_B
			
			--里夏娃
			local eve_b = playerType == PlayerType.PLAYER_EVE_B


            --一堆兼容
            if (azazel) then
                if (not drFetus and not brimstone and not haemolacria and not berserk) then
                    tears = tears * (4/15)
                end
            elseif (azazel_b) then
                if (not drFetus and not brimstone and not haemolacria and not berserk) then
                    tears = tears * (1/3)
                end
            elseif (forgotten) then
                if (not haemolacria and not berserk) then
                    tears = tears * (4/15)
                end
            elseif (eve_b) then
                tears = tears * 0.66
            end
            if (not haemolacria and not berserk and not forgotten) then
                if (drFetus) then
                    tears = tears * 0.4
                elseif (brimstone) then
                    tears = tears * (1/3)
                elseif (ipecac and not azazel) then
                    tears = tears * (1/3)
                end
            end
			

            --科技2
            if (player:HasCollectible(CollectibleType.COLLECTIBLE_TECHNOLOGY_2)) then
                tears = tears * (2/3)
            end
			
            --萌肺
            if (lung and not azazel and not forgotten and not berserk) then
                tears = tears * (10/43)
            end
			
            --睫毛膏
            if (player:HasCollectible(CollectibleType.COLLECTIBLE_EVES_MASCARA)) then
                tears = tears * 0.66
            end
			
            --杏仁奶与豆浆
            if (player:HasCollectible(CollectibleType.COLLECTIBLE_ALMOND_MILK)) then
                tears = tears * 4
            elseif (player:HasCollectible(CollectibleType.COLLECTIBLE_SOY_MILK)) then
                tears = tears * 5.5
            end

            --伯列恒之星
            for _, ent in ipairs(Isaac.FindByType(EntityType.ENTITY_EFFECT, EffectVariant.HALLOWED_GROUND)) do
                local playerPos = ent.Position + (player.Position - ent.Position) * Vector(1 /ent.SpriteScale.X, 1 /ent.SpriteScale.Y)
                if (ent.Position:Distance(playerPos) < 80) then
                    tears = tears * 2.5
                    break
                end
            end

            --倒战车
            if (effects:HasNullEffect(NullItemID.ID_REVERSE_CHARIOT) or effects:HasNullEffect(NullItemID.ID_REVERSE_CHARIOT_ALT)) then
                tears = tears * 2.5
            end
			
            return tears
        end
    },
    -- 6
    {	--狂暴
        function(player, tears)
            local effects = player:GetEffects()
            local berserk = effects:HasCollectibleEffect(CollectibleType.COLLECTIBLE_BERSERK)
            if (berserk) then
				tears = tears * 0.5 + 2
            end
            return tears
        end
    }
}

--原版攻击倍率角色
local VanillaPlayerDamageMultipliers = {
    [PlayerType.PLAYER_CAIN] = 1.2,
    [PlayerType.PLAYER_JUDAS] = 1.35,
    [PlayerType.PLAYER_BLUEBABY] = 1.05,
    [PlayerType.PLAYER_EVE] = function (player)
      if player:GetEffects():HasCollectibleEffect(CollectibleType.COLLECTIBLE_WHORE_OF_BABYLON) then return 1 end
      return 0.75
    end,
    [PlayerType.PLAYER_AZAZEL] = 1.5,
    [PlayerType.PLAYER_LAZARUS2] = 1.4,
    [PlayerType.PLAYER_BLACKJUDAS] = 2,
    [PlayerType.PLAYER_KEEPER] = 1.2,
    [PlayerType.PLAYER_THEFORGOTTEN] = 1.5,
  
    [PlayerType.PLAYER_MAGDALENA_B] = 0.75,
    [PlayerType.PLAYER_CAIN_B] = 1.2,
    [PlayerType.PLAYER_EVE_B] = 1.2,
    [PlayerType.PLAYER_AZAZEL_B] = 1.5,
    [PlayerType.PLAYER_THELOST_B] = 1.3,
    [PlayerType.PLAYER_THEFORGOTTEN_B] = 1.5,
	[PlayerType.PLAYER_BETHANY_B]=0.75,
    [PlayerType.PLAYER_LAZARUS2_B] = 1.5
}

--原版攻击倍率道具
local VanillaCollectibleDamageMultipliers = {
    [CollectibleType.COLLECTIBLE_MEGA_MUSH] = function (player)
      if not player:GetEffects():HasCollectibleEffect(CollectibleType.COLLECTIBLE_MEGA_MUSH) then return 1 end
      return 4
    end,
    [CollectibleType.COLLECTIBLE_MAXS_HEAD] = 1.5,
    [CollectibleType.COLLECTIBLE_MAGIC_MUSHROOM] = function (player)
      if player:HasCollectible(CollectibleType.COLLECTIBLE_MAXS_HEAD) then return 1 end
      return 1.5
    end,
    [CollectibleType.COLLECTIBLE_BLOOD_MARTYR] = function (player)
      if not player:GetEffects():HasCollectibleEffect(CollectibleType.COLLECTIBLE_BOOK_OF_BELIAL) then return 1 end
      if
        player:HasCollectible(CollectibleType.COLLECTIBLE_MAXS_HEAD) or
        player:GetEffects():HasCollectibleEffect(CollectibleType.COLLECTIBLE_MAGIC_MUSHROOM)
      then return 1 end
      return 1.5
    end,
    [CollectibleType.COLLECTIBLE_POLYPHEMUS] = 2,
    [CollectibleType.COLLECTIBLE_SACRED_HEART] = 2.3,
    [CollectibleType.COLLECTIBLE_EVES_MASCARA] = 2,
    [CollectibleType.COLLECTIBLE_ODD_MUSHROOM_RATE] = 0.9,
    [CollectibleType.COLLECTIBLE_20_20] = 0.8,
    [CollectibleType.COLLECTIBLE_EVES_MASCARA] = 2,
    [CollectibleType.COLLECTIBLE_SOY_MILK] = function (player)
      if player:HasCollectible(CollectibleType.COLLECTIBLE_ALMOND_MILK) then return 1 end
      return 0.2
    end,
    [CollectibleType.COLLECTIBLE_CROWN_OF_LIGHT] = function (player)
      if player:GetEffects():HasCollectibleEffect(CollectibleType.COLLECTIBLE_CROWN_OF_LIGHT) then return 2 end
      return 1
    end,
    [CollectibleType.COLLECTIBLE_ALMOND_MILK] = 0.33,
    [CollectibleType.COLLECTIBLE_IMMACULATE_HEART] = 1.2,
}

--定义区结束--



--移速
--[[输入:玩家(实体), 数值, 是否忽略原版倍率(是否)]]
function Stats:Speed(player, value, ignoreMultiples)
	if not ignoreMultiples then
	
		--里伯大尼
		if (player:GetPlayerType() == PlayerType.PLAYER_BETHANY_B) then
			value = value * 0.75
		end		
		
		--碎王冠
		local crownCount = player:GetTrinketMultiplier(TrinketType.TRINKET_CRACKED_CROWN)
		if (crownCount > 0) then
			local multiplier = 0.2 * crownCount
			value = value + (value * multiplier)
		end
	end
	
    player.MoveSpeed = player.MoveSpeed + value
end

--获取原版射速倍率
function Stats:GetVanillaTearsMult(player)
	local mult = 1
	
	for priority = 1, #VanillaTearsMultiples do
		local functionTable = VanillaTearsMultiples[priority]
		for i = 1, #functionTable do
			local func = functionTable[i]
			mult = func(player, mult)
		end
	end
	
	return mult
end

--射速修正(无视原版射速上限)
--[[输入:玩家(实体), 数值, 是否忽略原版倍率(是否)]]
function Stats:TearsModifier(player, value, ignoreMultiples)
	local firedelay = player.MaxFireDelay
	local tears = 30 / (firedelay + 1)
	
	if not ignoreMultiples then
		for priority = 1, #VanillaTearsMultiples do
			local functionTable = VanillaTearsMultiples[priority]
			for i = 1, #functionTable do
				local func = functionTable[i]
				value = func(player, value)
			end
		end
	end	
	
	local newtears = tears + value
	local newfiredelay = math.max((30 / newtears) - 1, -0.99)--射击延迟要大于-1

	player.MaxFireDelay = newfiredelay
end


--射速倍率
--[[输入:玩家(实体), 数值]]
function Stats:TearsMultiples(player, value)
	local firedelay = player.MaxFireDelay
	local tears = 30 / (firedelay + 1)
	local newtears = tears * value
	local newfiredelay = math.max((30 / newtears) - 1, -0.99)--射击延迟要大于-1

	player.MaxFireDelay = newfiredelay
end


--射速限制
--[[输入:玩家(实体), 数值, 是否为下限(是否)]]
function Stats:TearsLimit(player, value, isMin)
	local firedelay = player.MaxFireDelay
	local tears = 30 / (firedelay + 1)
	
	local newtears = tears
	local newfiredelay = firedelay
	
	if not isMin then
		if tears > value then
			newtears = value
			newfiredelay = math.max((30 / newtears) - 1, -0.99)--射击延迟要大于-1
			player.MaxFireDelay = newfiredelay
		end
	else
		if tears < value then
			newtears = value
			newfiredelay = math.max((30 / newtears) - 1, -0.99)--射击延迟要大于-1
			player.MaxFireDelay = newfiredelay	
		end
	end
end


--获取原版攻击力倍率
function Stats:GetVanillaDamageMult(player)
	local mult = 1
	
	--角色倍率
	local playerType = player:GetPlayerType()
	local playerMulti = VanillaPlayerDamageMultipliers[playerType]
	if (playerMulti) then
		if (type(playerMulti)== "function") then
			mult = mult * playerMulti(player)
		else
			mult = mult * playerMulti
		end
	end
	
	--道具倍率
	for id, multi in pairs(VanillaCollectibleDamageMultipliers) do
		if (multi) then
			if (player:HasCollectible(id)) then
				if (type(multi)== "function") then
					mult = mult * multi(player)
				else
					mult = mult * multi
				end
			end
		end
	end	
	
	--伯列恒之星
	for _, ent in ipairs(Isaac.FindByType(EntityType.ENTITY_EFFECT, EffectVariant.HALLOWED_GROUND)) do
		local playerPos = ent.Position + (player.Position - ent.Position) * Vector(1 /ent.SpriteScale.X, 1 /ent.SpriteScale.Y)
		if (ent.Position:Distance(playerPos) < 80) then
			mult = mult * 1.8
			break
		end
	end
	
	--碎王冠
	local crownCount = player:GetTrinketMultiplier(TrinketType.TRINKET_CRACKED_CROWN)
	if (crownCount > 0) then
		local multiplier = 0.2 * crownCount
		mult = mult + (mult * multiplier)
	end
	
	return mult
end

--攻击力
--[[输入:玩家(实体), 数值, 是否忽略原版倍率(是否)]]
function Stats:Damage(player, value, ignoreMultiples, balance)
	if not ignoreMultiples then
	
		--角色倍率
		local playerType = player:GetPlayerType()
		local playerMulti = VanillaPlayerDamageMultipliers[playerType]
		if (playerMulti) then
			if (type(playerMulti)== "function") then
				value = value * playerMulti(player)
			else
				value = value * playerMulti
			end
		end
		
		--道具倍率
		for id, multi in pairs(VanillaCollectibleDamageMultipliers) do
			if (multi) then
				if (player:HasCollectible(id)) then
					if (type(multi)== "function") then
						value = value * multi(player)
					else
						value = value * multi
					end
				end
			end
		end	
		
		--伯列恒之星
		for _, ent in ipairs(Isaac.FindByType(EntityType.ENTITY_EFFECT, EffectVariant.HALLOWED_GROUND)) do
			local playerPos = ent.Position + (player.Position - ent.Position) * Vector(1 /ent.SpriteScale.X, 1 /ent.SpriteScale.Y)
			if (ent.Position:Distance(playerPos) < 80) then
				value = value * 1.8
				break
			end
		end
		
		--碎王冠
		local crownCount = player:GetTrinketMultiplier(TrinketType.TRINKET_CRACKED_CROWN)
		if (crownCount > 0) then
			local multiplier = 0.2 * crownCount
			value = value + (value * multiplier)
		end
	end
	
    player.Damage = player.Damage + value
end


--射程
--[[输入:玩家(实体), 数值, 是否忽略原版倍率(是否)]]
function Stats:Range(player, value, ignoreMultiples)
	value = value * 40
	
	if not ignoreMultiples then
	
		--里伯大尼
		if (player:GetPlayerType() == PlayerType.PLAYER_BETHANY_B) then
			value = value * 0.75
		end		
		
		--碎王冠
		local crownCount = player:GetTrinketMultiplier(TrinketType.TRINKET_CRACKED_CROWN)
		if (crownCount > 0) then
			local multiplier = 0.2 * crownCount
			value = value + (value * multiplier)
		end
		
		--破镜子
		if (player:HasCollectible(CollectibleType.COLLECTIBLE_MY_REFLECTION)) then
			value = value * 2
		end

		--小号
		if (player:HasCollectible(CollectibleType.COLLECTIBLE_NUMBER_ONE)) then
			value = value * 0.8
		end	
	end
 
    player.TearRange = player.TearRange + value
end

--弹速
--[[输入:玩家(实体), 数值, 是否忽略原版倍率(是否)]]
function Stats:ShotSpeed(player, value, ignoreMultiples)
	if not ignoreMultiples then
	
		--里伯大尼
		if (player:GetPlayerType() == PlayerType.PLAYER_BETHANY_B) then
			value = value * 0.75
		end		
		
		--碎王冠
		local crownCount = player:GetTrinketMultiplier(TrinketType.TRINKET_CRACKED_CROWN)
		if (crownCount > 0) then
			local multiplier = 0.2 * crownCount
			value = value + (value * multiplier)
		end
		
		--破镜子
		if (player:HasCollectible(CollectibleType.COLLECTIBLE_MY_REFLECTION)) then
			value = value * 1.6
		end	
	end
	
    player.ShotSpeed = player.ShotSpeed + value
end


--幸运
--[[输入:玩家(实体), 数值, 是否忽略原版倍率(是否)]]
function Stats:Luck(player, value, ignoreMultiples)
	if not ignoreMultiples then
	
		--里伯大尼
		if (player:GetPlayerType() == PlayerType.PLAYER_BETHANY_B) then
			value = value * 0.75
		end		
		
		--碎王冠
		local crownCount = player:GetTrinketMultiplier(TrinketType.TRINKET_CRACKED_CROWN)
		if (crownCount > 0) then
			local multiplier = 0.2 * crownCount
			value = value + (value * multiplier)
		end
	end
	
    player.Luck = player.Luck + value
end



--以下更改属性函数不需要参与刷新属性回调,都不忽略原版倍率(因为我懒XD)--
--(可以满足大部分长久增加属性效果的需求,但对于特殊的还是要特殊处理)

--获取数据
local function GetStatsData(player)
	local data = Players:GetData(player)
	data.IBS_LIB_STATS = data.IBS_LIB_STATS or {
		spd = 0,
		tears = 0,
		tearsMulti = 0,
		dmg = 0,
		range = 0,
		sspd = 0,
		luck = 0
	}
	return data.IBS_LIB_STATS	
end	

--长久移速
function Stats:PersisSpeed(player, value, evaluate)
	local data = GetStatsData(player)
	data.spd = data.spd + value
	if evaluate then
		player:AddCacheFlags(CacheFlag.CACHE_SPEED)
		player:EvaluateItems()
	end	
end

--长久射速修正
function Stats:PersisTearsModifier(player, value, evaluate)
	local data = GetStatsData(player)
	data.tears = data.tears + value
	if evaluate then
		player:AddCacheFlags(CacheFlag.CACHE_FIREDELAY)
		player:EvaluateItems()
	end
end

--长久攻击力
function Stats:PersisDamage(player, value, evaluate)
	local data = GetStatsData(player)
	data.dmg = data.dmg + value
	if evaluate then
		player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
		player:EvaluateItems()
	end	
end

--长久射程
function Stats:PersisRange(player, value, evaluate)
	local data = GetStatsData(player)
	data.range = data.range + value
	if evaluate then
		player:AddCacheFlags(CacheFlag.CACHE_RANGE)
		player:EvaluateItems()
	end	
end

--长久弹速
function Stats:PersisShotSpeed(player, value, evaluate)
	local data = GetStatsData(player)
	data.sspd = data.sspd + value
	if evaluate then
		player:AddCacheFlags(CacheFlag.CACHE_SHOTSPEED)
		player:EvaluateItems()
	end	
end

--长久幸运
function Stats:PersisLuck(player, value, evaluate)
	local data = GetStatsData(player)
	data.luck = data.luck + value
	if evaluate then
		player:AddCacheFlags(CacheFlag.CACHE_LUCK)
		player:EvaluateItems()
	end	
end


--应用属性改动
mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, function(_,player, flag)
	local data = Players:GetData(player).IBS_LIB_STATS

	if data then	
		if flag == CacheFlag.CACHE_SPEED then
			Stats:Speed(player, data.spd)
		end
		if flag == CacheFlag.CACHE_FIREDELAY then
			Stats:TearsModifier(player, data.tears)
		end
		if flag == CacheFlag.CACHE_DAMAGE then
			Stats:Damage(player, data.dmg)
		end
		if flag == CacheFlag.CACHE_RANGE then
			Stats:Range(player, data.range)
		end
		if flag == CacheFlag.CACHE_SHOTSPEED then
			Stats:ShotSpeed(player, data.sspd)
		end
		if flag == CacheFlag.CACHE_LUCK then
			Stats:Luck(player, data.luck)
		end
	end	
end)

return Stats