-- 力量就是金钱

local mod = Isaac_BenightedSoul
local game = Game()
local itemConfig = Isaac.GetItemConfig()

local PowerisMoney = mod.IBS_Class.Item(mod.IBS_ItemID.PowerisMoney)



function PowerisMoney:PostAddCollectible(item, charge, firstTime, slot, varData, player)
    if not firstTime then return end
    local config = itemConfig:GetCollectible(item)
    if config and config.CacheFlags & CacheFlag.CACHE_DAMAGE > 0 then
        for frame = 1, 10 do
            self:DelayFunction(function()
                local room = game:GetRoom()
                local position = room:FindFreePickupSpawnPosition(player.Position, 20, true, false)
                local pickup = Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, 0, position, Vector.Zero, player):ToPickup()
            end, frame)
        end
    end
end
PowerisMoney:AddCallback(ModCallbacks.MC_POST_ADD_COLLECTIBLE, 'PostAddCollectible')

return PowerisMoney