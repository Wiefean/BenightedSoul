--灰白色母球

local mod = Isaac_BenightedSoul

local game = Game()
local sfx = SFXManager()

local WhiteQBall = mod.IBS_Class.Item(mod.IBS_ItemID.WhiteQBall)

--获得时
function WhiteQBall:OnGainItem(item, charge, first, slot, varData, player)
	if first then
		game:GetLevel():AddAngelRoomChance(1)
	end
end
WhiteQBall:AddCallback(ModCallbacks.MC_POST_ADD_COLLECTIBLE, 'OnGainItem', WhiteQBall.ID)

--新层
function WhiteQBall:OnNewLevel()
	if PlayerManager.AnyoneHasCollectible(self.ID) and not self:GetIBSData('temp').WhiteQBallTriggered then
		game:GetLevel():AddAngelRoomChance(1)
	end
end
WhiteQBall:AddPriorityCallback(ModCallbacks.MC_POST_NEW_LEVEL, CallbackPriority.LATE, 'OnNewLevel')

--检查恶魔天使房开启状态
function WhiteQBall:CheckDAOpen(devil, angel)
	if PlayerManager.AnyoneHasCollectible(self.ID) then
		if angel then
			self:GetIBSData('temp').WhiteQBallTriggered = true
		end
	end
end
WhiteQBall:AddCallback(mod.IBS_CallbackID.DEVIL_ANGEL_OPEN_STATE, 'CheckDAOpen')

--加房率
function WhiteQBall:OnDevilChance(chance)
	if PlayerManager.AnyoneHasCollectible(self.ID) and not self:GetIBSData('temp').WhiteQBallTriggered then
		return chance + 0.15
	end
end
WhiteQBall:AddCallback(ModCallbacks.MC_POST_DEVIL_CALCULATE, 'OnDevilChance')

--属性改动
function WhiteQBall:OnEvaluateCache(player, flag)
	if flag == CacheFlag.CACHE_SHOTSPEED and player:HasCollectible(self.ID) then
		local num = player:GetCollectibleNum(self.ID)
		self._Stats:ShotSpeed(player, -0.16*num)
	end
end
WhiteQBall:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, 'OnEvaluateCache')


return WhiteQBall