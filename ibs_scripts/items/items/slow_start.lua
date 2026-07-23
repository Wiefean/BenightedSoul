--慢启动

local mod = Isaac_BenightedSoul
local IBS_ItemID = mod.IBS_ItemID

local game = Game()

local SlowStart = mod.IBS_Class.Item(IBS_ItemID.SlowStart)

--开始计时
function SlowStart:StartCounter(evaluate)
	local stage = game:GetLevel():GetStage()
	local data = mod:GetIBSData("level")
	data.SlowStartCounter = math.max(1, 9000 - 600 * stage)
	
	if evaluate then
		for i = 0, game:GetNumPlayers() - 1 do
			local player = Isaac.GetPlayer(i)
			if player:HasCollectible(self.ID) then
				player:AddCacheFlags(CacheFlag.CACHE_SPEED | CacheFlag.CACHE_DAMAGE, true)
			end
		end	
	end
end

--游戏更新
function SlowStart:OnUpdate()
	local data = mod:GetIBSData("level")
	if data.SlowStartCounter and data.SlowStartCounter > 0 then
		data.SlowStartCounter = data.SlowStartCounter - 1
		
		if data.SlowStartCounter <= 0 then
			data.SlowStartCounter = nil
		
			for i = 0, game:GetNumPlayers() - 1 do
				local player = Isaac.GetPlayer(i)
				if player:HasCollectible(self.ID) then
					player:AddCacheFlags(CacheFlag.CACHE_SPEED | CacheFlag.CACHE_DAMAGE, true)
				end
			end
		end
	end
end
SlowStart:AddCallback(ModCallbacks.MC_POST_UPDATE, "OnUpdate")

--获得时
function SlowStart:OnGainItem(item, charge, first, slot, varData, player)
	if first then
		self:StartCounter(true)
	end
end
SlowStart:AddCallback(ModCallbacks.MC_POST_ADD_COLLECTIBLE, 'OnGainItem', SlowStart.ID)

--新层
function SlowStart:OnNewLevel()
	if PlayerManager.AnyoneHasCollectible(self.ID) then
		self:StartCounter(true)
	end
end
SlowStart:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, 'OnNewLevel', SlowStart.ID)


--属性
function SlowStart:OnEvalueateCache(player, flag)
	if player:HasCollectible(self.ID) then
		local data = mod:GetIBSData("level")
	
		if data.SlowStartCounter and data.SlowStartCounter > 0 then
			if flag == CacheFlag.CACHE_SPEED then
				self._Stats:Speed(player, -0.5)
			end
		else		
			if flag == CacheFlag.CACHE_DAMAGE then
				player.Damage = player.Damage * 1.5
			end
		end
	end	
end
SlowStart:AddPriorityCallback(ModCallbacks.MC_EVALUATE_CACHE, -100, 'OnEvalueateCache')


return SlowStart