--移动农场

local mod = Isaac_BenightedSoul
local IBS_TrinketID = mod.IBS_TrinketID

local game = Game()

local PortableFarm = mod.IBS_Class.Item(mod.IBS_ItemID.PortableFarm)


--使用
function PortableFarm:OnUse(item, rng, player, flag, slot)
	local id = IBS_TrinketID.WheatSeeds
	local smelted = false

	--吞下小麦种子
	for slot = 0,1 do
		if player:GetTrinket(slot) == id then
			player:TryRemoveTrinket(id)
			player:AddSmeltedTrinket(id, false)
			smelted = true
			SFXManager():Play(157)
		end

		--金饰品
		golden = id + 32768
		if player:GetTrinket(slot) == golden then
			player:TryRemoveTrinket(golden)
			player:AddSmeltedTrinket(golden, false)
			smelted = true
			SFXManager():Play(157)
		end		
	end

	if not smelted then
		for i = 1,rng:RandomInt(1,2) do
			Isaac.Spawn(5,350, id, player.Position, RandomVector() * 2, player)
		end
	end

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

