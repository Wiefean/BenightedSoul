--悠悠

local mod = Isaac_BenightedSoul

local game = Game()

local MM = mod.IBS_Class.Item(mod.IBS_ItemID.MM)

--在天使房拾取额外获得两个
function MM:OnPickItem(player, item, touched)
	if touched then return end 
	if game:GetRoom():GetType() == RoomType.ROOM_ANGEL then 
		player:AddCollectible(self.ID)
		player:AddCollectible(self.ID)
	end
end
MM:AddPriorityCallback(mod.IBS_CallbackID.PICK_COLLECTIBLE, CallbackPriority.LATE, 'OnPickItem', MM.ID)

--属性
function MM:OnEvalueateCache(player, flag)
	if player:HasCollectible(self.ID) then
		local num = player:GetCollectibleNum(self.ID)
		if flag == CacheFlag.CACHE_DAMAGE then
			self._Stats:Damage(player, 0.3*num)
		end
		if flag == CacheFlag.CACHE_SPEED then
			self._Stats:Speed(player, 0.1*num)
		end
	end	
end
MM:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, 'OnEvalueateCache')

return MM