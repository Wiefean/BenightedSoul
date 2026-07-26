--根系之仪

local mod = Isaac_BenightedSoul

local game = Game()

local RitesOfTheRoots = mod.IBS_Class.Item(mod.IBS_ItemID.RitesOfTheRoots)

function RitesOfTheRoots:PostNewLevel()
    if not PlayerManager.AnyoneHasCollectible(self.ID) then return end

    local level = game:GetLevel()

    local dimension = -1
    local seed = level:GetDungeonPlacementSeed()
    local varint = 7250
    local roomConfig = RoomConfigHolder.GetRoomByStageTypeAndVariant(StbType.SPECIAL_ROOMS, RoomType.ROOM_SACRIFICE, varint, -1)

    local options = level:FindValidRoomPlacementLocations(roomConfig, dimension, true, false)

    for _, gridIndex in pairs(options) do
        local neighbors = level:GetNeighboringRooms(gridIndex, roomConfig.Shape, dimension)
        local onlySecretNeighbors = true

        for _, neighborDesc in pairs(neighbors) do
            if neighborDesc.Data and neighborDesc.Data.Type ~= RoomType.ROOM_SECRET then
                onlySecretNeighbors = false
            end
        end
        
        if not onlySecretNeighbors then
            local roomDesc = level:TryPlaceRoom(roomConfig, gridIndex, dimension, seed, true, false, false)
            if roomDesc then
                return
            end
        end
    end

    options = {}

    for gridIndex = 0, 168 do
        table.insert(options, gridIndex)
    end

    local rng = RNG(seed)
    for gridIndex = #options, 2, -1 do
        local index = rng:RandomInt(gridIndex) + 1
        options[gridIndex], options[index] = options[index], options[gridIndex]
    end

    for _, gridIndex in pairs(options) do
        local roomDesc = level:TryPlaceRoom(roomConfig, gridIndex, dimension, seed, true, false, true)
        if roomDesc then
            return
        end
    end
end
RitesOfTheRoots:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, 'PostNewLevel')

return RitesOfTheRoots