--原初之爪

local mod = Isaac_BenightedSoul

local game = Game()

local SereTalon = mod.IBS_Class.Item(mod.IBS_ItemID.SereTalon)

--黑名单
SereTalon.BlackList = {
	[258] = true, --编号丢失
	[721] = true, --错误技
}

--获得
function SereTalon:OnGain(item, charge, first, slot, varData, player)
	if first then
		local room = game:GetRoom()
		for i = 1,3 do
			local pos = room:FindFreePickupSpawnPosition(player.Position, 0, true)
			Isaac.Spawn(5,300,49, pos, Vector.Zero, nil)
		end
	end
end
SereTalon:AddCallback(ModCallbacks.MC_POST_ADD_COLLECTIBLE, 'OnGain', SereTalon.ID)

--非黑名单,品质0,非主动
local function Condition(itemConfig)
	if SereTalon.BlackList[itemConfig.ID] == nil and itemConfig.Quality == 0 and itemConfig.Type ~= ItemType.ITEM_ACTIVE then
		return true
	end
	return false
end

--修改骰子碎片效果
function SereTalon:PreUseCard(id, player, flag)
	if not player:HasCollectible(self.ID) then return end
	
	local rng = player:GetCollectibleRNG(self.ID)
	local seed = rng:Next()
	local pool = self._Pools:GetRoomPool(seed)
	
	for _,ent in pairs(Isaac.FindByType(5, 100)) do
		local pickup = ent:ToPickup()
		if pickup and pickup.SubType ~= 0 then
			local id = self._Pools:GetCollectibleWithQuality(seed, 2, pool, true, 1, false, true)
			pickup:Morph(5,100,id,true)
			pickup.Touched = false
			Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, pickup.Position, Vector.Zero, nil)	
		end
	end		
	
	--塞0级道具
	do
		local pool = game:GetItemPool():GetRandomPool(RNG(seed))
		local id = self._Pools:GetCollectibleWithCondition(seed, Condition, pool, true, 19)
		player:AddCollectible(id)
		player:AnimateCollectible(id)
		SFXManager():Play(316)
	end

	return true
end
SereTalon:AddPriorityCallback(ModCallbacks.MC_PRE_USE_CARD, -1, 'PreUseCard', 49)

return SereTalon