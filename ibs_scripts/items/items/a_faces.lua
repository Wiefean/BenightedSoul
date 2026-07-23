--一张张脸

local mod = Isaac_BenightedSoul
local IBS_ItemID = mod.IBS_ItemID
local IBS_TrinketID = mod.IBS_TrinketID

local game = Game()

local AFaces = mod.IBS_Class.Item(IBS_ItemID.AFaces)

--饰品池
AFaces.TrinketList = {
	IBS_TrinketID.CultistMask,
	IBS_TrinketID.SsserpentHead,
	IBS_TrinketID.ClericFace,
	IBS_TrinketID.NlothsMask,
	IBS_TrinketID.GremlinMask,
}

--获得时触发
function AFaces:OnGain(item, charge, first, slot, varData, player)
	if first then
		local rng = player:GetCollectibleRNG(self.ID)
		local id = self.TrinketList[rng:RandomInt(1,#self.TrinketList)] or IBS_TrinketID.CultistMask
		
		--5%概率金饰品
		if rng:RandomInt(100) < 5 then
			id = id + 32768
		end		
		
		player:AddSmeltedTrinket(id)
	end
end
AFaces:AddCallback(ModCallbacks.MC_POST_ADD_COLLECTIBLE, 'OnGain', AFaces.ID)

return AFaces