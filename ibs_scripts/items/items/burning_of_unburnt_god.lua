-- 焚烧不焚之神

local mod = Isaac_BenightedSoul
local Stats = mod.IBS_Lib.Stats

local game = Game()
local itemPool = game:GetItemPool()
local itemConfig = Isaac.GetItemConfig()

local UnburntGod = mod.IBS_Class.Item(mod.IBS_ItemID.UnburntGod)
-- 饰品黑名单
UnburntGod.TrinketBlackList = {
    -- M'
    TrinketType.TRINKET_M,
    -- 蠕虫系列
    TrinketType.TRINKET_PULSE_WORM,
    TrinketType.TRINKET_WIGGLE_WORM,
    TrinketType.TRINKET_RING_WORM,
    TrinketType.TRINKET_FLAT_WORM,
    TrinketType.TRINKET_HOOK_WORM,
    TrinketType.TRINKET_WHIP_WORM,
    TrinketType.TRINKET_RAINBOW_WORM,
    TrinketType.TRINKET_TAPE_WORM,
    TrinketType.TRINKET_LAZY_WORM,
    TrinketType.TRINKET_OUROBOROS_WORM,
    TrinketType.TRINKET_BRAIN_WORM,
}

-- 判断是否是黑名单饰品
function UnburntGod:IsBlackListTrinket(trinket)
    for _, id in pairs(self.TrinketBlackList) do
        if trinket == id then
            return true
        end
    end
    return false
end

-- 获取饰品池
function UnburntGod:GetTrinketPool()
    local trinkets = {}
    for id = 1, itemConfig:GetTrinkets().Size - 1 do
        local config = itemConfig:GetTrinket(id)
        if config and config:IsTrinket() and not self:IsBlackListTrinket(id) and itemPool:HasTrinket(id) then
            table.insert(trinkets, id)
        end
    end
    return trinkets
end

-- 从饰品池中获取饰品
function UnburntGod:GetTrinket(rng)
    local trinkets = self:GetTrinketPool()
    local trinket = TrinketType.TRINKET_CRACKED_CROWN
    if #trinkets > 0 then
        trinket = trinkets[rng:RandomInt(#trinkets) + 1]
    end
    return trinket
end

-- 检测一共有多少个来自该道具的魂火
function UnburntGod:GetWispNum(player)
    local num = 0
    for _, entity in pairs(Isaac.FindByType(EntityType.ENTITY_FAMILIAR, FamiliarVariant.WISP, self.ID)) do
        local familiar = entity:ToFamiliar()
        if familiar and familiar.Player and GetPtrHash(familiar.Player) == GetPtrHash(player) then
            num = num + 1
        end
    end
    return num
end

-- 获取最晚获得的金饰品
function UnburntGod:GetLatestGoldenTrinket(player)
    local history = player:GetHistory():GetCollectiblesHistory()
    for idx = #history, 1, -1 do
        local item = history[idx]
        if item:IsTrinket() and item:GetItemID() > 32768 then
            return item:GetItemID()
        end
    end
end

-- 使用主动道具时
function UnburntGod:UseItem(item, rng, player, flags, slot)
    if self:GetWispNum(player) < 6 then
        player:AddSmeltedTrinket(self:GetTrinket(rng) + 32768)
    else
        return {
            ShowAnim = false,
            Remove = false,
            Discharge = false,
        }
    end
    -- 如果没有美德书则手动生成一个魂火
    if not player:HasCollectible(CollectibleType.COLLECTIBLE_BOOK_OF_VIRTUES) then
        player:AddWisp(self.ID, player.Position, false, false)
    end
    if player:HasCollectible(CollectibleType.COLLECTIBLE_BOOK_OF_BELIAL_PASSIVE) then
        -- 一个邪门的不触发犹大长子权自动兼容的方法
        self:DelayFunction(function()
            player:AddCacheFlags(CacheFlag.CACHE_DAMAGE, true)
        end, 1)
        player:AddActiveCharge(-itemConfig:GetCollectible(self.ID).MaxCharges, slot, true, false, false)
        return {
            ShowAnim = true,
            Remove = false,
            Discharge = false,
        }
    else
        return {
            ShowAnim = true,
            Remove = false,
            Discharge = true,
        }
    end
end
UnburntGod:AddCallback(ModCallbacks.MC_USE_ITEM, 'UseItem', UnburntGod.ID)

-- 强制调整魂火血量
function UnburntGod:FamiliarInit(familiar)
    if familiar.SubType ~= self.ID then return end
    local player = familiar.Player
    if not player then
        player = game:GetNearestPlayer(familiar.Position)
    end
    if player:HasCollectible(CollectibleType.COLLECTIBLE_BOOK_OF_VIRTUES) then
        familiar.HitPoints = 4
    else
        familiar.HitPoints = 2
    end
end
UnburntGod:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, 'FamiliarInit', FamiliarVariant.WISP)

-- 该道具的火熄灭时移除最晚获得的金饰品
function UnburntGod:PostEntityKill(entity)
    if not entity then return end
    local familiar = entity:ToFamiliar()
    if not familiar then return end
    if familiar.SubType ~= self.ID then return end
    local player = familiar.Player
    if not player then return end
    local trinket = self:GetLatestGoldenTrinket(player)
    if trinket then
        player:TryRemoveSmeltedTrinket(trinket)
    end
    if player:HasCollectible(CollectibleType.COLLECTIBLE_BOOK_OF_BELIAL_PASSIVE) then
        self:DelayFunction(function()
            player:AddCacheFlags(CacheFlag.CACHE_DAMAGE, true)
        end, 1)
    end
end
UnburntGod:AddCallback(ModCallbacks.MC_POST_ENTITY_KILL, 'PostEntityKill', EntityType.ENTITY_FAMILIAR)

--当玩家有犹大长子权时更新玩家的属性数值
function UnburntGod:EvaluateCache(player, flag)
    if not player:HasCollectible(CollectibleType.COLLECTIBLE_BOOK_OF_BELIAL_PASSIVE) then return end
    local DamageUp = self:GetWispNum(player) * 0.6
    Stats:Damage(player, DamageUp)
end
UnburntGod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, 'EvaluateCache', CacheFlag.CACHE_DAMAGE)

return UnburntGod