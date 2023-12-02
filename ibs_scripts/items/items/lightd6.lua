--光D6

local mod = Isaac_BenightedSoul
local IBS_Callback = mod.IBS_Callback
local IBS_Item = mod.IBS_Item
local IBS_Player = mod.IBS_Player
local Players = mod.IBS_Lib.Players
local Pools = mod.IBS_Lib.Pools
local Finds = mod.IBS_Lib.Finds

--用于昧化该隐&亚伯
mod.IBS_API.BCBA:AddExcludedActiveItem(IBS_Item.ld6)

--获取房间道具平均品质
local function GetAverageQuality()
	local Q = 0
	local total = 0
	for _,item in pairs(Isaac.FindByType(5, 100)) do
		if item.SubType ~= 0 then
			total = total + 1
			local config = Isaac.GetItemConfig():GetCollectible(item.SubType)		
			if config and config.Quality then 
				Q = Q + (config.Quality)
			end		
		end
	end
	Q = math.floor((Q / total)+0.5)
	
	return Q
end

--计算充能消耗和品质
local function GetDischarge(player, slot, isOwned, costSoul)
	local quality = GetAverageQuality()
	
	if isOwned then --拥有才计算充能消耗
		local discharge = 3
		local soulCost = 0

		if quality <= 0 then discharge = 0 end
		if quality == 1 then discharge = 1 end
		if quality == 2 then discharge = 2 end
		if quality == 3 then discharge = 3 end
		if quality >= 4 then discharge = 6 end
		if player:HasCollectible(116) then discharge = discharge - 1 end --9伏特
		if discharge < 0 then discharge = 0 end
		
		local soul = player:GetSoulHearts() --包括魂心和黑心
		
		--正邪(东方mod)
		if mod:THI_WillSeijaNerf(player) then
			if soul > 0 then
				discharge = 6
				soul = soul - 1
				soulCost = soulCost + 1
				if player:HasCollectible(116) then discharge = 5 end --9伏特
			else --心不够不准用
				return 666666,quality
			end	
		end
		
		--昧化以撒
		if player:GetPlayerType() == (IBS_Player.bisaac) then
			if (soul > 0) and not player:HasCollectible(CollectibleType.COLLECTIBLE_SHARP_PLUG) then
				local charges = Players:GetSlotCharges(player, slot, true, true)
				local lack = discharge - charges
				
				--以魂或黑心代替缺少的充能
				if (lack > 0) and (soul >= lack) then
					discharge = charges
					soulCost = soulCost + lack
				end
			end	
		end
			
			if costSoul and (soulCost > 0) then
				player:AddSoulHearts(-soulCost)
			end
		
		return discharge,quality
	end
	
	return 666666,quality
end

--尝试使用
mod:AddCallback(IBS_Callback.TRY_USE_ITEM, function(_,item, player, slot, charges, maxCharges)
	local discharge,quality = GetDischarge(player, slot, true)
	return {
		CanUse = (charges >= discharge) and (charges < maxCharges),
		IgnoreSharpPlug = (charges >= discharge)
	}
end, IBS_Item.ld6)

--使用效果
local function Roll(_,item, rng, player, flags, slot)
	if (flags & UseFlag.USE_CARBATTERY <= 0) and (flags & UseFlag.USE_VOID <= 0) then--拒绝车载电池和虚空
		local owned = (flags & UseFlag.USE_OWNED > 0) --是否拥有
		local discharge,quality = GetDischarge(player, slot, owned, true)
		local closestItem = Finds:ClosestCollectible(player.Position)
		
		if closestItem ~= nil then --禁空拍
		
			--成功消耗充能或者由其他方式触发效果时才重置道具
			if (not owned) or Players:DischargeSlot(player, slot, discharge) then
				local pool = Pools:GetRoomPool(rng:GetSeed())
				
				--美德书
				if player:HasCollectible(584) and (flags & UseFlag.USE_NOANIM <= 0 or flags & UseFlag.USE_ALLOWWISPSPAWN > 0) then
					for w = 1,discharge do
						player:AddWisp(IBS_Item.ld6, player.Position)
					end
				end
				
				for _,ent in pairs(Isaac.FindByType(5, 100)) do
					local item = ent:ToPickup()
					if item and item.SubType ~= 0 then
						local newItem = 25
						
						--彼列书
						local state = rng:RandomInt(2)
						if player:HasCollectible(59) then
							if state == 1 then
								quality = quality + 1
							end
							if state == 2 then
								quality = quality - 1
							end
							if discharge > 0 then
								player:UseActiveItem(34, false, false)
							end
						end

						newItem = Pools:GetCollectibleWithQuality(quality, pool, true, rng)
						item:Morph(5,100,newItem,true)
						item.Touched = false
						
						--烟雾特效
						Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, item.Position, Vector.Zero, nil)	
					end
				end
				return {ShowAnim = true, Discharge = false}
			end
		end	
	end	
	
	return {ShowAnim = false, Discharge = false}
end
mod:AddCallback(ModCallbacks.MC_USE_ITEM, Roll, IBS_Item.ld6)

