--掉渣饼

local mod = Isaac_BenightedSoul

local game = Game()
local config = Isaac.GetItemConfig()
local sfx = SFXManager()

local DreggyPie = mod.IBS_Class.Item(mod.IBS_ItemID.DreggyPie)


--临时数据
function DreggyPie:GetData(player)
	local data = self._Ents:GetTempData(player)
	data.DreggyPie = data.DreggyPie or {TearsUp = 0}

	return data.DreggyPie
end

--拾取效果
function DreggyPie:OnGainItem(item, charge, first, slot, varData, player)
	if first then
		local data = self:GetData(player)
		data.TearsUp = data.TearsUp + 5
		player:AddCacheFlags(CacheFlag.CACHE_FIREDELAY, true)
		player:SetFullHearts()
	end
end
DreggyPie:AddCallback(ModCallbacks.MC_POST_ADD_COLLECTIBLE, 'OnGainItem', DreggyPie.ID)

--射速加成
function DreggyPie:OnEvaluateCache(player, flag)
	local data = self._Ents:GetTempData(player).DreggyPie
	if data and (data.TearsUp > 0) then
		if flag == CacheFlag.CACHE_FIREDELAY then
			self._Stats:TearsModifier(player, data.TearsUp)
		end
	end	
end
DreggyPie:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, 'OnEvaluateCache')

--加成衰减以及红豆汤和饼换长子权
function DreggyPie:OnPlayerUpdate(player)
	if player:IsFrame(120,0) then
		local data = self._Ents:GetTempData(player).DreggyPie
		if data then
			if data.TearsUp >= 0.1 then
				data.TearsUp = data.TearsUp - 0.1
				player:AddCacheFlags(CacheFlag.CACHE_FIREDELAY, true)
			end
		end
	end

	--防止双子无限循环
	local playerType = player:GetPlayerType()
	if player:IsExtraAnimationFinished() and (playerType ~= PlayerType.PLAYER_ESAU) then
		if (playerType ~= PlayerType.PLAYER_JACOB) or not player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT, true) then
			if player:HasCollectible(CollectibleType.COLLECTIBLE_RED_STEW, true) and player:HasCollectible(self.ID, true) then
				player:RemoveCollectible(CollectibleType.COLLECTIBLE_RED_STEW, true)
				player:RemoveCollectible(self.ID, true)
				player:QueueItem(Isaac.GetItemConfig():GetCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT))
				player:AnimateCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT)

				sfx:Play(SoundEffect.SOUND_POWERUP1)
			end
		end	
	end	
end
DreggyPie:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, 'OnPlayerUpdate')


return DreggyPie