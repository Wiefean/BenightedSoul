--索多玛之灭

local mod = Isaac_BenightedSoul
local game = Game()
local sfx = SFXManager()

local DisasterOfSodom = mod.IBS_Class.Item(mod.IBS_ItemID.DisasterOfSodom)

function DisasterOfSodom:OnUseItem(item, rng, player, flag, slot)
    game:ShakeScreen(30)
    game:Darken(1, 120)
    sfx:Play(SoundEffect.SOUND_SUPERHOLY, 1, 2, false, 0.75, 0)
    sfx:Play(SoundEffect.SOUND_ROCK_CRUMBLE, 1, 2, false, 0.75, 0)

    local itemEachQuality = {}
    local itemPool = game:GetItemPool()
    local pool = self._Pools:GetRoomPool(rng:Next())
    
    for quality = 0, 4 do
        local itemID = self._Pools:GetCollectibleWithQuality(rng:Next(), quality, pool, false, 25, true, false, false)
        itemEachQuality[itemID] = true
    end

    for _, table in ipairs(itemPool:GetCollectiblesFromPool(pool)) do
        local ID = table.itemID
        if not itemEachQuality[ID] then
            itemPool:RemoveCollectible(ID)
        end
    end

    if player:HasCollectible(CollectibleType.COLLECTIBLE_BOOK_OF_VIRTUES) then
        player:AddWisp(CollectibleType.COLLECTIBLE_BOOK_OF_VIRTUES, player.Position)
    end
    local remove = not player:HasCollectible(59)
    return {ShowAnim = true, Discharge = true, Remove = remove}
end
DisasterOfSodom:AddCallback(ModCallbacks.MC_USE_ITEM, 'OnUseItem', DisasterOfSodom.ID)

return DisasterOfSodom