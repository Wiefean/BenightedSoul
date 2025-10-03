--妈妈的支票

local mod = Isaac_BenightedSoul

local game = Game()

local MomsCheque = mod.IBS_Class.Item(mod.IBS_ItemID.MomsCheque)

--直接使用无效
function MomsCheque:OnUse()
	return {ShowAnim = false, Discharge = false}
end
MomsCheque:AddCallback(ModCallbacks.MC_USE_ITEM, 'OnUse', MomsCheque.ID)

--新层给钱
function MomsCheque:OnNewLevel()
	for i = 0, game:GetNumPlayers() -1 do
		local player = Isaac.GetPlayer(i)
		if player:HasCollectible(self.ID) or player:VoidHasCollectible(self.ID) then
			player:AddCoins(10)
			player:AddCacheFlags(CacheFlag.CACHE_LUCK)
			SFXManager():Play(SoundEffect.SOUND_CASH_REGISTER)
		end
	end
end
MomsCheque:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, 'OnNewLevel')


--属性
function MomsCheque:OnEvaluateCache(player, flag)
	if player:HasCollectible(self.ID) or player:VoidHasCollectible(self.ID) then
		if flag == CacheFlag.CACHE_LUCK then
			self._Stats:Luck(player, 2)
		end
	end	
end
MomsCheque:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, 'OnEvaluateCache')


return MomsCheque