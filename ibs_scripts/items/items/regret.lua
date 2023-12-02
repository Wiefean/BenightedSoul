--死不瞑目

local mod = Isaac_BenightedSoul
local IBS_Item = mod.IBS_Item
local Stats = mod.IBS_Lib.Stats
local Players = mod.IBS_Lib.Players

local function GetRedeathData(player)
	local data = Players:GetData(player)
	data.Regret = data.Regret or {
		spd = 0,
		tears = 0,
		dmg = 0
	}

	return data.Regret	
end	

--死亡
local function OnKilled(_,ent)
	local player = ent:ToPlayer()
	
	if player and player:HasCollectible(IBS_Item.regret) then
		local data = GetRedeathData(player)
		data.spd = data.spd + 0.1
		data.tears = data.tears + 0.35
		data.dmg = data.dmg + 1
		
		player:AddCacheFlags(CacheFlag.CACHE_ALL)
		player:EvaluateItems()
	end
end
mod:AddCallback(ModCallbacks.MC_POST_ENTITY_KILL, OnKilled, EntityType.ENTITY_PLAYER)

--属性
mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, function(_,player, flag)
	local pdata = Players:GetData(player)
	if pdata.Regret then
		local data = pdata.Regret
		
		if flag == CacheFlag.CACHE_SPEED then
			Stats:Speed(player, data.spd)
		end
		if flag == CacheFlag.CACHE_FIREDELAY then
			Stats:TearsModifier(player, data.tears, true)
		end
		if flag == CacheFlag.CACHE_DAMAGE then
			Stats:Damage(player, data.dmg)
		end
	end	
end)

--正邪增强(东方mod)
mod:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, function()
	for i = 0, Game():GetNumPlayers() -1 do
		local player = Isaac.GetPlayer(i)
		if player:HasCollectible(IBS_Item.regret) and mod:THI_WillSeijaBuff(player) and not player:HasCollectible(11, true) then
			player:AddCollectible(11)
		end
	end
end)
