--污浊饼

local mod = Isaac_BenightedSoul
local IBS_Callback = mod.IBS_Callback
local IBS_Item = mod.IBS_Item
local Stats = mod.IBS_Lib.Stats
local Ents = mod.IBS_Lib.Ents

--临时数据
local function GetPieData(player)
	local data = Ents:GetTempData(player)
	data.DreegyPie = data.DreegyPie or {TearsUp = 0}
	
	return data.DreegyPie
end

--拾取效果
local function GainItem(_,player, item, num, touched)
	if (not touched and player.Variant == 0 and not player:IsCoopGhost()) then
		local data = GetPieData(player)
		data.TearsUp = data.TearsUp + 5*num
		player:AddCacheFlags(CacheFlag.CACHE_FIREDELAY)
		player:EvaluateItems()
	end
end
mod:AddCallback(IBS_Callback.GAIN_COLLECTIBLE, GainItem, IBS_Item.dreggypie)

--射速加成
mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, function(_,player, flag)
	local data = Ents:GetTempData(player).DreegyPie
	if data and (data.TearsUp > 0) then
		if flag == CacheFlag.CACHE_FIREDELAY then
			Stats:TearsModifier(player, data.TearsUp)
		end
	end	
end)

--加成衰减以及红豆汤和饼换长子权
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, function(_,player)
	if player.FrameCount % 120 == 0 then
		local data = Ents:GetTempData(player).DreegyPie
		if data then
			if data.TearsUp >= 0.1 then
				data.TearsUp = data.TearsUp - 0.1
				player:AddCacheFlags(CacheFlag.CACHE_FIREDELAY)
				player:EvaluateItems()
			end
		end
	end
	
	--防止双子无限循环
	local playerType = player:GetPlayerType()
	if player:IsExtraAnimationFinished() and (playerType ~= PlayerType.PLAYER_ESAU) then
		if (playerType ~= PlayerType.PLAYER_JACOB) or not player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT, true) then
			if player:HasCollectible(CollectibleType.COLLECTIBLE_RED_STEW, true) and player:HasCollectible(IBS_Item.dreggypie, true) then
				player:RemoveCollectible(CollectibleType.COLLECTIBLE_RED_STEW, true)
				player:RemoveCollectible(IBS_Item.dreggypie, true)
				player:QueueItem(Isaac.GetItemConfig():GetCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT))
				player:AnimateCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT)
				
				SFXManager():Play(SoundEffect.SOUND_POWERUP1)
			end
		end	
	end	
end)

