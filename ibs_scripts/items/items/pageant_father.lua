--盛装教父

local mod = Isaac_BenightedSoul

local game = Game()
local config = Isaac.GetItemConfig()
local sfx = SFXManager()

local PageantFather = mod.IBS_Class.Item(mod.IBS_ItemID.PageantFather)


--拾取效果
function PageantFather:OnGainItem(item, charge, first, slot, varData, player)
	if not first then return end
	
	--吞下硬币饰品
	for i = 1,6 do
		local id = self._Pools:GetRandomPennyTrinket(player:GetCollectibleRNG(self.ID), {
			[TrinketType.TRINKET_BUTT_PENNY] = 0,
			[TrinketType.TRINKET_CURSED_PENNY] = 0,
		})
		player:AddSmeltedTrinket(id+32768)
	end
	Isaac.Spawn(5, 20, 7, player.Position, Vector.Zero, player)
	
	sfx:Play(157)
end
PageantFather:AddCallback(ModCallbacks.MC_POST_ADD_COLLECTIBLE, 'OnGainItem', PageantFather.ID)


return PageantFather