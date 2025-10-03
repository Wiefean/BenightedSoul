--谦逊之径

local mod = Isaac_BenightedSoul

local game = Game()
local config = Isaac.GetItemConfig()

local ROH = mod.IBS_Class.Item(mod.IBS_ItemID.ROH)

--获取数据
function ROH:GetData(player)
	local data = self._Players:GetData(player)
	data.RouteOfHumilityMult = data.RouteOfHumilityMult or {
		spd = 1,
		tears = 1,
		dmg = 1,
		range = 1,
		sspd = 1,
		luck = 1
	}

	return data.RouteOfHumilityMult	
end	

--用于抽取属性
ROH.StatsList = {
	'spd',
	'tears',
	'dmg',
	'range',
	'sspd',
	'luck'
}

--拾取道具提升属性倍率
function ROH:OnGainItem(item, charge, first, slot, varData, player)
	if slot > 1 then return end
	if first and player:HasCollectible(self.ID) then
		local itemConfig = config:GetCollectible(item)
		local quality = (itemConfig and itemConfig.Quality) or 0
		local data = self:GetData(player)
		local key = self.StatsList[player:GetCollectibleRNG(self.ID):RandomInt(1, #self.StatsList)] or 'dmg'
		data[key] = data[key] + 0.025 * (4-quality)
		player:AddCacheFlags(CacheFlag.CACHE_ALL, true)
	end
end
ROH:AddCallback(ModCallbacks.MC_POST_ADD_COLLECTIBLE, 'OnGainItem')

--属性变动
function ROH:OnEvaluateCache(player, flag)
	if player:HasCollectible(self.ID) then
		local data = self:GetData(player) 

		if flag == CacheFlag.CACHE_SPEED then
			player.MoveSpeed = player.MoveSpeed * data.spd
		end
		if flag == CacheFlag.CACHE_FIREDELAY then
			self._Stats:TearsMultiples(player, data.tears)
		end
		if flag == CacheFlag.CACHE_DAMAGE then
			player.Damage = player.Damage * data.dmg
		end		
		if flag == CacheFlag.CACHE_RANGE then
			player.TearRange = player.TearRange * data.range
		end
		if flag == CacheFlag.CACHE_SHOTSPEED then
			player.ShotSpeed = player.ShotSpeed * data.sspd
		end
		if flag == CacheFlag.CACHE_LUCK then
			player.Luck = player.Luck * data.luck
		end
	end	
end
ROH:AddPriorityCallback(ModCallbacks.MC_EVALUATE_CACHE, CallbackPriority.LATE, 'OnEvaluateCache')



return ROH