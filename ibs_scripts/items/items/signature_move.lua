--招牌技

local mod = Isaac_BenightedSoul
local IBS_ItemID = mod.IBS_ItemID
local Pools = mod.IBS_Lib.Pools
local AbandonedItem = mod.IBS_Effect.AbandonedItem


local game = Game()
local config = Isaac.GetItemConfig()
local sfx = SFXManager()

local SignatureMove = mod.IBS_Class.Item(IBS_ItemID.SignatureMove)

--获取非攻击性道具ID
function SignatureMove:GetNonOffensiveItemID(seed)
	return Pools:GetCollectibleWithCondition(seed, function(itemConfig)
		return not itemConfig:HasTags(ItemConfig.TAG_OFFENSIVE)
	end, Pools:GetRoomPool(seed), true, 25)
end


--计算攻击性道具数量(仅计算真正持有的道具)
function SignatureMove:GetOffensiveNum(player)
	local result = 0
	local total = 0
	
	for id,num in pairs(player:GetCollectiblesList()) do
		local itemConfig = config:GetCollectible(id)
		if itemConfig and itemConfig:HasTags(ItemConfig.TAG_OFFENSIVE) then
			result = result + num
		end
		total = total + num
	end
	
	return result,total
end

--获得道具
function SignatureMove:OnGainItem(item, charge, first, slot, varData, player)
	if player:HasCollectible(self.ID) then
		player:AddCacheFlags(CacheFlag.CACHE_DAMAGE, true)
	end
end
SignatureMove:AddCallback(ModCallbacks.MC_POST_ADD_COLLECTIBLE, 'OnGainItem')

--失去道具
function SignatureMove:OnLoseItem(player, item)
	if player:HasCollectible(self.ID) then
		player:AddCacheFlags(CacheFlag.CACHE_DAMAGE, true)
	end
end
SignatureMove:AddCallback(ModCallbacks.MC_POST_TRIGGER_COLLECTIBLE_REMOVED, 'OnLoseItem')


--属性变动
function SignatureMove:OnEvalueateCache(player, flag)
	if player:HasCollectible(self.ID) and flag == CacheFlag.CACHE_DAMAGE then
		local damage = 30
		local offensive,total = self:GetOffensiveNum(player)
		local mult = offensive - (total - offensive)
		if mult <= 0 then
			damage = 30
		else
			damage = math.max(0, damage / mult)
		end
		self._Stats:Damage(player, damage)
	end	
end
SignatureMove:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, 'OnEvalueateCache')


--攻击性道具添加非攻击性选项
function SignatureMove:OnPickupFirstAppear(pickup)
	if not PlayerManager.AnyoneHasCollectible(self.ID) then return end
	if pickup.SubType <= 0 then return end
	local itemConfig = config:GetCollectible(pickup.SubType)
		
	--非任务道具
	if itemConfig and itemConfig:HasTags(ItemConfig.TAG_QUEST) then
		return
	end		
	
	if itemConfig and itemConfig:HasTags(ItemConfig.TAG_OFFENSIVE) then
		local id = self:GetNonOffensiveItemID(pickup.InitSeed)
		local seija = false
		
		--正邪削弱(东方mod)
		for i = 0, game:GetNumPlayers() -1 do
			local player = Isaac.GetPlayer(i)
			if player:HasCollectible(self.ID, true) and mod.IBS_Compat.THI:SeijaNerf(player) then
				seija = true
				break
			end
		end
		
		--正邪削弱,直接替换
		if seija then
			pickup:Morph(5, 100, id, true, true, true)
			
			--特效
			if itemConfig.GfxFileName then
				AbandonedItem:Spawn(pickup.Position, itemConfig.GfxFileName, RandomVector() * 0.1 * math.random(7, 12))
			end	
		else
			pickup:AddCollectibleCycle(id)
		end
		
	end
end
SignatureMove:AddCallback(mod.IBS_CallbackID.PICKUP_FIRST_APPEAR, 'OnPickupFirstAppear', 100)


return SignatureMove