--以撒的伪忆

local mod = Isaac_BenightedSoul

local BIsaac = mod.IBS_Class.Pocket(mod.IBS_PocketID.BIsaac)

local game = Game()

--平均品质
function BIsaac:GetAverageQuality()
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

--重置道具
function BIsaac:OnUse(card, player, flag)
	local quality = self:GetAverageQuality()
	local pool = ItemPoolType.POOL_DEVIL
	local rng = player:GetCardRNG(self.ID)
	
	--调整道具池
	if rng:RandomInt(100) < 49 then
		pool = ItemPoolType.POOL_ANGEL
	end
	
	for _,ent in pairs(Isaac.FindByType(5, 100)) do
		local item = ent:ToPickup()
		if item and item.SubType ~= 0 then
			local newItem = 25

			newItem = self._Pools:GetCollectibleWithQuality(rng:Next(), quality, pool, true)
			item:Morph(5,100,newItem,true)
			item.Touched = false
			
			--烟雾特效
			Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, item.Position, Vector.Zero, nil)	
		end
	end	
end
BIsaac:AddCallback(ModCallbacks.MC_USE_CARD, 'OnUse', BIsaac.ID)

--符文佩剑(东方mod)
if mod.IBS_Compat.THI:IsEnabled() then
	local RuneSword = THI.Collectibles.RuneSword

	mod.IBS_Compat.THI:AddRuneSwordCompat(BIsaac.ID, {
		png = "gfx/ibs/items/pick ups/falsehoods/bisaac.png",
		textKey = "FALSEHOOD_BISAAC",
		name = {
			zh = "以撒的伪忆",
			en = "Falsehood of Isaac",
		},
		desc = {
			zh = "更多选择 , 仅限二元",
			en = "More options, dualism only",
		}, 
	})
	
	--恶魔/天使更多选择
	function BIsaac:OnPickupFirstAppear(pickup)
		local itemPool = game:GetItemPool()
		local roomType = game:GetRoom():GetType()
		local devilRoom = roomType == RoomType.ROOM_DEVIL
		local angelRoom = roomType == RoomType.ROOM_ANGEL
		if (devilRoom or angelRoom) and RuneSword:HasGlobalRune(self.ID) then
			for i = 1,2 do
				local id = itemPool:GetCollectible(self._Pools:GetRoomPool(), true, pickup.InitSeed, 25)
				pickup:AddCollectibleCycle(id)
			end
		end
	end
	BIsaac:AddCallback(mod.IBS_CallbackID.PICKUP_FIRST_APPEAR, 'OnPickupFirstAppear', 100)

end

return BIsaac