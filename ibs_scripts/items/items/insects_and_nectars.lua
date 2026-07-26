--昆虫与花蜜

local mod = Isaac_BenightedSoul

local Nectars = mod.IBS_Class.Item(mod.IBS_ItemID.Nectars)

local game = Game()

function Nectars:PostNewRoom()
    if not game:GetRoom():IsFirstVisit() then return end
    for index, player in pairs(PlayerManager.GetPlayers()) do
        if player:HasCollectible(self.ID) then
            local num = player:GetPlayerFormCounter(PlayerForm.PLAYERFORM_LORD_OF_THE_FLIES)
            player:AddBlueFlies(num, player.Position, nil)
        end
    end
end
Nectars:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, 'PostNewRoom')

function Nectars:PostFamiliarRemove(entity, source)
    if entity.Variant ~= FamiliarVariant.BLUE_FLY then return end

    local familiar = entity:ToFamiliar()
    if not familiar then return end

    local player = familiar.Player or (familiar.SpawnerEntity and familiar.SpawnerEntity:ToPlayer() or nil)
    if not player then return end
    if not player:HasCollectible(self.ID) then return end

    if RNG(familiar.InitSeed):RandomInt(10) < 1 then
        local pickup = Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_HEART, HeartSubType.HEART_HALF, familiar.Position, Vector.Zero, nil):ToPickup()
        pickup.Timeout = 60
    end
end
Nectars:AddCallback(ModCallbacks.MC_POST_ENTITY_REMOVE, 'PostFamiliarRemove', EntityType.ENTITY_FAMILIAR)

return Nectars