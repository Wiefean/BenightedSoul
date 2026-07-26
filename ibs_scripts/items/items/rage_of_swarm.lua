-- 虫群之怒

local mod = Isaac_BenightedSoul

local RageOfSwarm = mod.IBS_Class.Item(mod.IBS_ItemID.RageOfSwarm)

local game = Game()
local sfx = SFXManager()
local config = Isaac.GetItemConfig()

function RageOfSwarm:AddBestFriend(player)
    player:AddSmeltedTrinket(TrinketType.TRINKET_APOLLYONS_BEST_FRIEND + 32768)
end

RageOfSwarm.FlyItems = {}

mod:AddCallback(ModCallbacks.MC_POST_MODS_LOADED, function()
	for itemID = 1, config:GetCollectibles().Size - 1 do
		local itemConfig = config:GetCollectible(itemID)
		if itemConfig and itemConfig.ID ~= RageOfSwarm.ID
			and itemConfig:HasTags(ItemConfig.TAG_FLY)
			and itemConfig.Quality <= 2
		then
			RageOfSwarm.FlyItems[itemID] = true
		end
	end
end)

function RageOfSwarm:IsFlyItem(item)
    return not not RageOfSwarm.FlyItems[item]
end

RageOfSwarm.LocustTrinkets = {
    [TrinketType.TRINKET_LOCUST_OF_WRATH] = true,
    [TrinketType.TRINKET_LOCUST_OF_PESTILENCE] = true,
    [TrinketType.TRINKET_LOCUST_OF_FAMINE] = true,
    [TrinketType.TRINKET_LOCUST_OF_DEATH] = true,
    [TrinketType.TRINKET_LOCUST_OF_CONQUEST] = true,
    [TrinketType.TRINKET_CRICKET_LEG] = true,
}

for trinketID,_ in pairs(RageOfSwarm.LocustTrinkets) do
    RageOfSwarm.LocustTrinkets[trinketID + 32768] = true
end

function RageOfSwarm:IsLocustTrinket(trinket)
    return self.LocustTrinkets[trinket] ~= nil
end

function RageOfSwarm:PostAddCollectible(item, charge, firstTime, solt, varData, player)
    if not (player:HasCollectible(self.ID) or item == self.ID) then return end

    local history = player:GetHistory():GetCollectiblesHistory()
    for _, item in pairs(history) do
        if item:IsTrinket() then
            local trinketID = item:GetItemID()
            if self:IsLocustTrinket(trinketID) then
                player:TryRemoveSmeltedTrinket(trinketID)
                self:AddBestFriend(player)
            end
        else
            local itemID = item:GetItemID()
            if self:IsFlyItem(itemID) then
                player:RemoveCollectible(itemID, false, ActiveSlot.SLOT_PRIMARY, false)
                self:AddBestFriend(player)
            end
        end
    end

    for trinketIndex = 0, 1 do
        local trinketID = player:GetTrinket(trinketIndex)
        if self:IsLocustTrinket(trinketID) then
            player:TryRemoveTrinket(trinketID)
            self:AddBestFriend(player)
        end
    end
end
RageOfSwarm:AddCallback(ModCallbacks.MC_POST_ADD_COLLECTIBLE, 'PostAddCollectible')


function RageOfSwarm:PostCollectibleInit(pickup)
    if not PlayerManager.AnyoneHasCollectible(self.ID) then return end
    local itemID = pickup.SubType
    if self:IsFlyItem(itemID) then
        pickup:Morph(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TRINKET, TrinketType.TRINKET_APOLLYONS_BEST_FRIEND + 32768, false, false, true)
    end
end
RageOfSwarm:AddCallback(ModCallbacks.MC_POST_PICKUP_INIT, 'PostCollectibleInit', PickupVariant.PICKUP_COLLECTIBLE)

function RageOfSwarm:PostTrinketInit(pickup)
    if not PlayerManager.AnyoneHasCollectible(self.ID) then return end
    local trinketID = pickup.SubType
    if self:IsLocustTrinket(trinketID) then
        pickup:Morph(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TRINKET, TrinketType.TRINKET_APOLLYONS_BEST_FRIEND + 32768, false, false, true)
    end
end
RageOfSwarm:AddCallback(ModCallbacks.MC_POST_PICKUP_INIT, 'PostTrinketInit', PickupVariant.PICKUP_TRINKET)

--自动吞下亚波伦挚友
function RageOfSwarm:OnPlayerUpdate(player)
	if not player:HasCollectible(self.ID) then return end
	for slot = 0,1 do
		local id = player:GetTrinket(slot)
		if id == TrinketType.TRINKET_APOLLYONS_BEST_FRIEND
			or id == TrinketType.TRINKET_APOLLYONS_BEST_FRIEND + 32768
		then
			player:TryRemoveTrinket(id)
			player:AddSmeltedTrinket(TrinketType.TRINKET_APOLLYONS_BEST_FRIEND + 32768, false)
			sfx:Play(157)
		end
	end	
end
RageOfSwarm:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, 'OnPlayerUpdate', 0)

function RageOfSwarm:PreEntitySpawn(entityType, variant, subType, position, velocity, spawner, seed)
    if not PlayerManager.AnyoneHasCollectible(self.ID) then return end
    if entityType ~= EntityType.ENTITY_FAMILIAR then return end
    if variant ~= FamiliarVariant.BLUE_FLY then return end
    if subType ~= 0 then return end

    if RNG(seed):RandomInt(2) > 0 then
        return {
            entityType,
            variant,
            LocustSubtypes.LOCUST_OF_WRATH,
            seed,
        }
    end

end
RageOfSwarm:AddCallback(ModCallbacks.MC_PRE_ENTITY_SPAWN, 'PreEntitySpawn', PickupVariant.PICKUP_TRINKET)

return RageOfSwarm
