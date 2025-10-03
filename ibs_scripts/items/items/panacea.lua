--万能药

local mod = Isaac_BenightedSoul
local Pools = mod.IBS_Lib.Pools
local Stats = mod.IBS_Lib.Stats

local game = Game()

local Panacea = mod.IBS_Class.Item(mod.IBS_ItemID.Panacea)

--疾病道具
local function Disease(itemConfig)
	return Pools:IsDiseaseItem(itemConfig.ID)
end
local function Disease2(itemConfig)
	if not Pools:IsDiseaseItem(itemConfig.ID) then
		return 0
	end
end

--使用效果
function Panacea:OnUse(item, rng, player, flags, slot)
	if (flags & UseFlag.USE_OWNED > 0 or flags & UseFlag.USE_VOID > 0) and (flags & UseFlag.USE_CARBATTERY <= 0) then
		player:SetFullHearts()
		player:AddBrokenHearts(-player:GetBrokenHearts())
		self._Players:GetData(player).PanaceaUsed = true
		player:AddCacheFlags(CacheFlag.CACHE_ALL, true)
		
		local room = game:GetRoom()
		local itemPool = game:GetItemPool()
		
		--疾病道具移出道具池
		for _,item in pairs(Pools:GetCollectibles(Disease)) do
			itemPool:RemoveCollectible(item)
		end

		--默认宝箱房池,有美德书改为天使,彼列书恶魔,都有则抽一个
		local pool = ItemPoolType.POOL_TREASURE
		local virtue,belial = player:HasCollectible(584),player:HasCollectible(59)
		if virtue and belial then
			pool = ItemPoolType.POOL_ANGEL
			if rng:RandomInt(100) < 50 then
				pool = ItemPoolType.POOL_DEVIL
			end
		elseif virtue then
			pool = ItemPoolType.POOL_ANGEL
		elseif belial then
			pool = ItemPoolType.POOL_DEVIL
		end
		
		--移除疾病道具,并生成新的道具
		local seed = rng:Next()
		local items,totalNum = self._Players:GetPlayerCollectibles(player, Disease2)
		for id,num in pairs(items) do
			for i = 1,num do
				player:RemoveCollectible(id, true)
				local new = itemPool:GetCollectible(pool, true, seed)
				local pos = room:FindFreePickupSpawnPosition(player.Position, 0, true)
				Isaac.Spawn(5, 100, new, pos, Vector.Zero, nil)
			end	
		end
	
		--小贴士~
		local text1 = self:ChooseLanguage('良药苦口 , 请放心使用 !', 'Good medicine tastes bitter, please rest assured !')
		local text2 = self:ChooseLanguage('概不退款 !', 'No refund !')
		game:GetHUD():ShowItemText(text1, text2)
		SFXManager():Play(157)	
		
		return {ShowAnim = true, Remove = true}
	end
end
Panacea:AddCallback(ModCallbacks.MC_USE_ITEM, 'OnUse', Panacea.ID)

--属性不低于标准值
function Panacea:OnEvaluateCache(player, flag)
	if self._Players:GetData(player).PanaceaUsed then
		if flag & CacheFlag.CACHE_SPEED > 0 and player.MoveSpeed < 1 then
			player.MoveSpeed = 1
		end
		if flag & CacheFlag.CACHE_FIREDELAY > 0 and player.MaxFireDelay > 10 then
			player.MaxFireDelay = 10
		end
		if flag & CacheFlag.CACHE_DAMAGE > 0 and player.Damage < 3.5 then
			player.Damage = 3.5
		end
		if flag & CacheFlag.CACHE_RANGE > 0 and player.TearRange < (40 * 6.5) then
			player.TearRange = 40 * 6.5
		end
		if flag & CacheFlag.CACHE_SHOTSPEED > 0 and player.ShotSpeed < 1 then
			player.ShotSpeed = 1
		end
		if flag & CacheFlag.CACHE_LUCK > 0 and player.Luck < 0 then
			player.Luck = 0
		end
	end
end
Panacea:AddPriorityCallback(ModCallbacks.MC_EVALUATE_CACHE, 300, 'OnEvaluateCache')


return Panacea