--破碎之秘

local mod = Isaac_BenightedSoul
local Stats = mod.IBS_Lib.Stats

local game = Game()
local config = Isaac.GetItemConfig()

local Edge3 = mod.IBS_Class.Item(mod.IBS_ItemID.Edge3)

--获取数据
function Edge3:GetData(player, onlyGet)
	local data = self._Players:GetData(player)
	
	if onlyGet then
		return data.Edge3
	end
	
	data.Edge3 = data.Edge3 or {dmgMult = 1, tearsMult = 1}

	return data.Edge3
end

--获得时生成力量卡
function Edge3:OnGain(item, charge, first, slot, varData, player)
	if first then
		local room = game:GetRoom()
		local pos = room:FindFreePickupSpawnPosition(player.Position, 0, true)
		Isaac.Spawn(5, 300, 12, pos, Vector.Zero, nil)
	end
end
Edge3:AddCallback(ModCallbacks.MC_POST_ADD_COLLECTIBLE, 'OnGain', Edge3.ID)

--使用力量卡
function Edge3:OnUseCard(card, player)
	if player:HasCollectible(self.ID) then
		local data = self:GetData(player)
		data.dmgMult = data.dmgMult + 0.08
		player:AddSoulHearts(2)
		player:AddCacheFlags(CacheFlag.CACHE_DAMAGE, true)
		
		--清碎心
		player:AddBrokenHearts(-1)
		
		--正邪削弱(东方mod)
		if mod.IBS_Compat.THI:SeijaNerf(player) then
			data.tearsMult = math.max(0, data.tearsMult - 0.025)
			player:AddCacheFlags(CacheFlag.CACHE_FIREDELAY, true)
		end
	end
end
Edge3:AddCallback(ModCallbacks.MC_USE_CARD, 'OnUseCard', 12)

--新层生成力量卡
function Edge3:OnNewLevel()
	if PlayerManager.AnyoneHasCollectible(self.ID) then
		local room = game:GetRoom()
		local pos = room:FindFreePickupSpawnPosition(room:GetCenterPos() + Vector(0,80), 0, true)
		Isaac.Spawn(5, 300, 12, pos, Vector.Zero, nil)	
	end
end
Edge3:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, 'OnNewLevel')

--属性
function Edge3:OnEvaluateCache(player, flag)
	if player:HasCollectible(self.ID) then
		local data = self:GetData(player)
		if flag == CacheFlag.CACHE_DAMAGE then
			player.Damage = player.Damage * data.dmgMult
		end
		if flag == CacheFlag.CACHE_FIREDELAY then
			Stats:TearsMultiples(player, data.tearsMult)
		end		
	end	
end
function Edge3:OnEvaluateCache2(player, flag)
	if player:HasCollectible(self.ID) then	
		if flag == CacheFlag.CACHE_DAMAGE then
			--正邪削弱(东方mod)
			if mod.IBS_Compat.THI:SeijaNerf(player) then
				player.Damage = player.Damage + 0.8
			else
				player.Damage = player.Damage + 8
			end		
		end
	end	
end
Edge3:AddPriorityCallback(ModCallbacks.MC_EVALUATE_CACHE, 100, 'OnEvaluateCache')
Edge3:AddPriorityCallback(ModCallbacks.MC_EVALUATE_CACHE, 200, 'OnEvaluateCache2')

return Edge3