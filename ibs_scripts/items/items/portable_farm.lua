--移动农场

local mod = Isaac_BenightedSoul
local IBS_TrinketID = mod.IBS_TrinketID

local game = Game()

local PortableFarm = mod.IBS_Class.Item(mod.IBS_ItemID.PortableFarm)


--使用
function PortableFarm:OnUse(item, rng, player, flag, slot)
	local id = IBS_TrinketID.WheatSeeds
	player:AddSmeltedTrinket(id, false)
	SFXManager():Play(157)
	return true
end
PortableFarm:AddCallback(ModCallbacks.MC_USE_ITEM, 'OnUse', PortableFarm.ID)

--魂火熄灭
function PortableFarm:OnWispKilled(familiar)
    if (familiar.Variant == FamiliarVariant.WISP and familiar.SubType == (self.ID)) then
		local room = game:GetRoom()
		local pos = room:FindFreePickupSpawnPosition(familiar.Position, 0, true)
		Isaac.Spawn(5,350, IBS_TrinketID.WheatSeeds, pos, Vector.Zero, nil)
    end
end
PortableFarm:AddCallback(ModCallbacks.MC_POST_ENTITY_KILL, 'OnWispKilled', EntityType.ENTITY_FAMILIAR)


return PortableFarm

