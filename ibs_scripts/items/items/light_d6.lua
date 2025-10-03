--光D6

local mod = Isaac_BenightedSoul

local game = Game()

local LightD6 = mod.IBS_Class.Item(mod.IBS_ItemID.LightD6)


--获取房间道具平均品质
function LightD6:GetAverageQuality()
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
function LightD6:GetDischarge(player, slot, isOwned, cost)
	local quality = self:GetAverageQuality()
	if slot < 0 or slot > 2 then return 0,quality end
	
	if isOwned then --拥有才计算充能消耗
		local discharge = 3

		if quality <= 0 then discharge = 0 end
		if quality == 1 then discharge = 1 end
		if quality == 2 then discharge = 2 end
		if quality == 3 then discharge = 3 end
		if quality >= 4 then discharge = 6 end
		if player:HasCollectible(116) then discharge = discharge - 1 end --9伏特
		if discharge < 0 then discharge = 0 end
		
		local soul = player:GetSoulHearts() --包括魂心和黑心
		
		--正邪(东方mod)
		if mod.IBS_Compat.THI:SeijaNerf(player) then
			if soul > 0 then
				discharge = 6
				soul = soul - 1
				
				--消耗半魂心或半黑心
				if cost then
					player:AddSoulHearts(-1)
				end

				if player:HasCollectible(116) then discharge = 5 end --9伏特
			else --心不够不准用
				return 666666,quality
			end	
		end
		
		return discharge,quality
	end
	
	return 666666,quality
end

--尝试使用
function LightD6:OnTryUse(slot, player)
	local closestItem = self._Finds:ClosestCollectible(player.Position)
	if closestItem == nil then
		return 6
	end
	local discharge,quality = self:GetDischarge(player, slot, true)
	return discharge
end
LightD6:AddCallback(ModCallbacks.MC_PLAYER_GET_ACTIVE_MIN_USABLE_CHARGE, 'OnTryUse', LightD6.ID)


--使用效果
function LightD6:OnUse(item, rng, player, flags, slot)
	if (flags & UseFlag.USE_CARBATTERY <= 0) and (flags & UseFlag.USE_VOID <= 0) then--拒绝车载电池和虚空
		local owned = (flags & UseFlag.USE_OWNED > 0) --是否拥有
		local discharge,quality = self:GetDischarge(player, slot, owned, true)
		local closestItem = self._Finds:ClosestCollectible(player.Position)
		
		if closestItem ~= nil then --禁空拍
		
			--成功消耗充能或者由其他方式触发效果时才重置道具
			if (not owned) or self._Players:DischargeSlot(player, slot, discharge) then
				local pool = self._Pools:GetRoomPool(self._Levels:GetRoomUniqueSeed())

				--美德书
				if player:HasCollectible(584) and (flags & UseFlag.USE_NOANIM <= 0 or flags & UseFlag.USE_ALLOWWISPSPAWN > 0) then
					for w = 1,discharge do
						player:AddWisp(self.ID, player.Position)
					end
				end
				
				for _,ent in pairs(Isaac.FindByType(5, 100)) do
					local item = ent:ToPickup()
					if item and item.SubType ~= 0 and item.SubType ~= 668 then
						local newItem = 25
						
						--彼列书
						local state = rng:RandomInt(1,2)
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

						newItem = self._Pools:GetCollectibleWithQuality(rng:Next(), quality, pool, true)
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
LightD6:AddCallback(ModCallbacks.MC_USE_ITEM, 'OnUse', LightD6.ID)


return LightD6