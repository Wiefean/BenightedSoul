--偷来的十年

local mod = Isaac_BenightedSoul
local Stats = mod.IBS_Lib.Stats

local game = Game()
local sfx = SFXManager()

local StolenDecade = mod.IBS_Class.Item(mod.IBS_ItemID.StolenDecade)

--尝试使用
function StolenDecade:OnTryUse(slot, player)
	return 0
end
StolenDecade:AddCallback(ModCallbacks.MC_PLAYER_GET_ACTIVE_MIN_USABLE_CHARGE, 'OnTryUse', StolenDecade.ID)

--寻找有价格的掉落物
function StolenDecade:FindPricedItems()
	local result = {}

	for _,ent in ipairs(Isaac.FindByType(5)) do
		local pickup = ent:ToPickup()
		if pickup and pickup.Price ~= 0 and pickup.Price ~= -5 then
			table.insert(result, pickup)
		end
	end
	
	return result
end

--寻找单选掉落物
function StolenDecade:FindOptionalItems()
	local result = {}

	for _,ent in ipairs(Isaac.FindByType(5)) do
		local pickup = ent:ToPickup()
		if pickup and pickup.OptionsPickupIndex ~= 0 then
			table.insert(result, pickup)
		end
	end
	
	return result
end

--使用
function StolenDecade:OnUse(item, rng, player, flags, slot)
	--只能由主动本体触发
	if (flags & UseFlag.USE_CARBATTERY > 0) or (flags & UseFlag.USE_VOID > 0) or (flags & UseFlag.USE_OWNED <= 0) then
		return
	end

	--消耗1格充能
	if not self._Players:DischargeSlot(player, slot, 1, true, false, true, true) then
		--尝试恢复上限骰(东方mod)
		if slot ~= 2 then
			mod.IBS_Compat.THI:TryRestoreDice(player, self.ID, slot)
		end	
		return {ShowAnim = false, Discharge = false}
	end

	local level = game:GetLevel()
	local pickups = self:FindPricedItems()
	local pickups2 = self:FindOptionalItems()

	if #pickups > 0 then
		--掉落物免费
		local pickup = self._Finds:ClosestEntityInTable(player.Position, pickups)
		if pickup then
			pickup.Price = 0
		end
	elseif #pickups2 > 0 then
		--拒绝选择
		for _,pickup in ipairs(pickups2) do
			pickup.OptionsPickupIndex = 0
		end
		self:DelayFunction(function()
			player:AnimateCollectible(mod.IBS_ItemID.NoOptions)
			sfx:Play(128)
		end, 15)
	elseif level:GetStartingRoomIndex() == level:GetCurrentRoomDesc().SafeGridIndex then
		--朝夕符文,诸神符文,透视隐藏房
		player:UseCard(35, UseFlag.USE_NOANIM | UseFlag.USE_NOANNOUNCER | UseFlag.USE_MIMIC)
		player:UseCard(36, UseFlag.USE_NOANIM | UseFlag.USE_NOANNOUNCER | UseFlag.USE_MIMIC)
		level:SetCanSeeEverything(true)	
	else
		--消除碎心+神圣卡
		player:AddBrokenHearts(-1)
		player:UseCard(51, UseFlag.USE_NOANIM | UseFlag.USE_NOANNOUNCER | UseFlag.USE_MIMIC)
	end

	--美德书
	if player:HasCollectible(584) then
		player:AddWisp(self.ID, player.Position)
	end	

	--彼列书
	if player:HasCollectible(59) then
		player:AddBlackHearts(2)
	end

	sfx:Play(268)

	return {ShowAnim = true, Discharge = false}
end
StolenDecade:AddCallback(ModCallbacks.MC_USE_ITEM, 'OnUse', StolenDecade.ID)


return StolenDecade