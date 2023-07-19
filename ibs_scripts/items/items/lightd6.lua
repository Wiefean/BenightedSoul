--光D6

local mod = Isaac_BenightedSoul
local IBS_Callback = mod.IBS_Callback
local IBS_Item = mod.IBS_Item
local IBS_Player = mod.IBS_Player
local Players = mod.IBS_Lib.Players
local Pools = mod.IBS_Lib.Pools
local Finds = mod.IBS_Lib.Finds

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
local function GetDischarge(player, slot)
	local discharge = 3
	local quality = GetAverageQuality()
	if quality <= 0 then discharge = 0 end
	if quality == 1 then discharge = 1 end
	if quality == 2 then discharge = 3 end
	if quality == 3 then discharge = 4 end
	if quality >= 4 then discharge = 6 end
	if player:HasCollectible(116) then discharge = discharge - 1 end
	
	if discharge < 0 then discharge = 0 end
	
	return discharge,quality
end

--尝试使用
mod:AddCallback(IBS_Callback.TRY_USE_ITEM, function(_,item, player, slot, charges)
	local discharge,quality = GetDischarge(player, slot)
	return (charges >= discharge) and (charges < 12)
end, IBS_Item.ld6)

--使用效果
local function Roll(_,item, rng, player, flags, slot)
	if (flags & UseFlag.USE_CARBATTERY <= 0) and (flags & UseFlag.USE_VOID <= 0) then--拒绝车载电池和虚空
		local discharge,quality = GetDischarge(player, slot)
		local closestItem = Finds:ClosestCollectible(player.Position)
		
		if closestItem ~= nil then --禁空拍
		
			--成功消耗充能或者由其他方式触发效果时才重置道具
			if Players:DischargeSlot(player, slot, discharge) or (flags & UseFlag.USE_OWNED <= 0) then
				local pool = Pools:GetRoomPool(rng:GetSeed())
				
				--美德书
				local virtue = player:HasCollectible(584) and (flags & UseFlag.USE_NOANIM <= 0 or flags & UseFlag.USE_ALLOWWISPSPAWN > 0)
				if virtue then
					player:AddWisp(IBS_Item.ld6, player.Position)
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
						
						--美德书
						if virtue then
							player:AddWisp(IBS_Item.ld6, item.Position)
						end
						
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

