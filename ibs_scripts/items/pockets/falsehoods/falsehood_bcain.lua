--该隐的伪忆

local mod = Isaac_BenightedSoul

local game = Game()

local BCain = mod.IBS_Class.Pocket(mod.IBS_PocketID.BCain)

--效果
function BCain:OnUse(card, player, flag)
	for i = 1,4 do
		player:AddSmeltedTrinket(mod.IBS_TrinketID.WheatSeeds, false)
	end
	SFXManager():Play(157)
end
BCain:AddCallback(ModCallbacks.MC_USE_CARD, 'OnUse', BCain.ID)

--符文佩剑(东方mod)
if mod.IBS_Compat.THI:IsEnabled() then
	local RuneSword = THI.Collectibles.RuneSword
	local SeedBag = mod.IBS_Pickup.SeedBag

	mod.IBS_Compat.THI:AddRuneSwordCompat(BCain.ID, {
		png = "gfx/ibs/items/pick ups/falsehoods/bcain.png",
		textKey = "FALSEHOOD_BCAIN",
		name = {
			zh = "该隐的伪忆",
			en = "Falsehood of Cain",
		},
		desc = {
			zh = "播种",
			en = "Sow the seeds",
		}, 
	})
	
	--提升种子袋替换概率
	function BCain:OnPickupInit(pickup)
		local num = math.min(2, RuneSword:GetGlobalRuneCount(self.ID))
		if num > 0 and pickup.SubType <= 2 and RNG(pickup.InitSeed):RandomInt(100) < 40*num then
			pickup:Morph(5, SeedBag.Variant, SeedBag.SubType, true, true)
		end
	end
	BCain:AddCallback(ModCallbacks.MC_POST_PICKUP_INIT, 'OnPickupInit', 69)
	
end

return BCain