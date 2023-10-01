--亚波伦之翼

local mod = Isaac_BenightedSoul
local IBS_Item = mod.IBS_Item
local Stats = mod.IBS_Lib.Stats

--频率限制(防止循环刷新属性)
local TimeOut = 0
mod:AddCallback(ModCallbacks.MC_POST_UPDATE, function()
	if TimeOut > 0 then
		TimeOut = TimeOut - 1
	end
end)

--属性
mod:AddPriorityCallback(ModCallbacks.MC_EVALUATE_CACHE, 200, function(_,player, flag)
	if player:HasCollectible(IBS_Item.woa) then
		if flag == CacheFlag.CACHE_SHOTSPEED then
			Stats:ShotSpeed(player, 0.16)
			
			if TimeOut <= 0 then
				TimeOut = 1
				player:AddCacheFlags(CacheFlag.CACHE_DAMAGE | CacheFlag.CACHE_FIREDELAY | CacheFlag.CACHE_RANGE | CacheFlag.CACHE_SPEED | CacheFlag.CACHE_LUCK)
				player:EvaluateItems()
			end
		end
		
		local mult = player.ShotSpeed - 1
		if mult > 1.5 then mult = 1.5 end
		
		if mult > 1 then
			if flag == CacheFlag.CACHE_SPEED then
				player.MoveSpeed = player.MoveSpeed * mult
			end
			if flag == CacheFlag.CACHE_FIREDELAY then
				Stats:TearsMultiples(player, mult)
			end
			if flag == CacheFlag.CACHE_DAMAGE then
				player.Damage = player.Damage * mult
			end
			if flag == CacheFlag.CACHE_RANGE then
				player.TearRange = player.TearRange * mult
			end
			if flag == CacheFlag.CACHE_LUCK then
				player.Luck = player.Luck * mult
			end
		end	
	end	
end)

--亚波伦飞行
local function ApollyonsFly(_,player, flag)
	if (flag == CacheFlag.CACHE_FLYING) then
		local playerType = player:GetPlayerType()
		if (playerType == PlayerType.PLAYER_APOLLYON) or (playerType == PlayerType.PLAYER_APOLLYON_B) then
			if player:HasCollectible(IBS_Item.woa) then
				player.CanFly = true
			end	
		end
	end	
end
mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, ApollyonsFly)

--翅膀装饰
local function FlyCostume(_,player)
	local playerType = player:GetPlayerType()
	if (playerType == PlayerType.PLAYER_APOLLYON) or (playerType == PlayerType.PLAYER_APOLLYON_B) then
		if player:HasCollectible(IBS_Item.woa) then
			local effect = player:GetEffects()
			if not effect:HasCollectibleEffect(179) then
				effect:AddCollectibleEffect(179, true)
			end
		end	
	end
end
mod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, FlyCostume)
