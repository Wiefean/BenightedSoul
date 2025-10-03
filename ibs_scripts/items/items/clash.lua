--交锋

local mod = Isaac_BenightedSoul
local Stats = mod.IBS_Lib.Stats

local game = Game()
local config = Isaac.GetItemConfig()

local Clash = mod.IBS_Class.Item(mod.IBS_ItemID.Clash)


--获得道具时刷新属性
function Clash:OnGainItem(item, charge, first, slot, varData, player)
	if player:HasCollectible(self.ID) then
		player:AddCacheFlags(CacheFlag.CACHE_DAMAGE, true)
	end
end
Clash:AddCallback(ModCallbacks.MC_POST_ADD_COLLECTIBLE, 'OnGainItem')

--计数
function Clash:CountItems(player)
	local offensive = 0
	local nonOffensive = 0
	
	for id,num in pairs(player:GetCollectiblesList()) do
		if num > 0 then
			local itemConfig = config:GetCollectible(id)
			if itemConfig and itemConfig:HasTags(ItemConfig.TAG_OFFENSIVE) then
				offensive = offensive + num
			else
				nonOffensive = nonOffensive + num
			end
		end
	end
	
	return offensive,nonOffensive
end

--属性
function Clash:OnEvaluateCache(player, flag)
	if player:HasCollectible(self.ID) and flag == CacheFlag.CACHE_DAMAGE then
		local offensive,nonOffensive = self:CountItems(player)
		self._Stats:Damage(player, player:GetCollectibleNum(self.ID) * math.max(0, 0.3*offensive - nonOffensive))
	end	
end
Clash:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, 'OnEvaluateCache')


return Clash