-- 焚烧不焚之神

local mod = Isaac_BenightedSoul
local Stats = mod.IBS_Lib.Stats

local game = Game()
local itemPool = game:GetItemPool()
local itemConfig = Isaac.GetItemConfig()

local UnburntGod = mod.IBS_Class.Item(mod.IBS_ItemID.UnburntGod)

-- 饰品黑名单
UnburntGod.TrinketBlackList = {
    TrinketType.TRINKET_CURSED_SKULL, --诅咒头骨
    TrinketType.TRINKET_BUTT_PENNY, --屁股硬币
    TrinketType.TRINKET_CROW_HEART, --乌鸦的心
    TrinketType.TRINKET_TORN_CARD, --扑克牌残片
    TrinketType.TRINKET_ROSARY_BEAD, --念珠段
    TrinketType.TRINKET_M, --'M

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

-- 检测一共有多少个跟班
local function GetFamiliarNum()
    local num = 0
    for _, entity in pairs(Isaac.FindByType(EntityType.ENTITY_FAMILIAR)) do
        local familiar = entity:ToFamiliar()
        if familiar then
            num = num + 1
        end
    end
    return num
end

-- 使用主动道具时
function UnburntGod:OnUseItem(item, rng, player, flags, slot)
    if GetFamiliarNum() < 64 then
        player:AddSmeltedTrinket(self:GetTrinket(rng) + 32768)

		-- 如果没有美德书则手动生成一个魂火
		if not self._Players:CanSpawnWisp(player, flags) then
			player:AddWisp(self.ID, player.Position)
		end	
    end
	return true
end
UnburntGod:AddCallback(ModCallbacks.MC_USE_ITEM, 'OnUseItem', UnburntGod.ID)

-- 魂火初始化
function UnburntGod:OnFamiliarInit(familiar)
    if familiar.SubType ~= self.ID then return end
    local player = familiar.Player or Isaac.GetPlayer(0); if not player then return end
	
    familiar:AddToOrbit(0)
	familiar.OrbitDistance = Vector(40,40)
<<<<<<< Updated upstream
	familiar.OrbitSpeed = 0.1
=======
	familiar.OrbitSpeed = 0.05
>>>>>>> Stashed changes
	
	--美德书
    if player:HasCollectible(CollectibleType.COLLECTIBLE_BOOK_OF_VIRTUES) then
        familiar.MaxHitPoints = familiar.MaxHitPoints * 2
        familiar.HitPoints = familiar.MaxHitPoints
    end
end
UnburntGod:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, 'OnFamiliarInit', FamiliarVariant.WISP)

-- 魂火更新
function UnburntGod:OnFamiliarUpdate(familiar)
    if familiar.SubType ~= self.ID then return end
    local player = familiar.Player or Isaac.GetPlayer(0); if not player then return end
	
	--手动环绕
	familiar:AddToOrbit(0)
	familiar.OrbitDistance = Vector(40,40)
<<<<<<< Updated upstream
    familiar.OrbitSpeed = 0.1
=======
    familiar.OrbitSpeed = 0.05
	
    local wisps = Isaac.FindByType(EntityType.ENTITY_FAMILIAR, FamiliarVariant.WISP, self.ID)
    for index,entity in pairs(wisps) do
        if GetPtrHash(entity) == GetPtrHash(familiar) then
            familiar.OrbitAngleOffset = (index - 1) * 2 * math.pi / #wisps
        end
    end	
	
>>>>>>> Stashed changes
    familiar.Velocity = (familiar:GetOrbitPosition(player.Position) - familiar.Position)	
end
UnburntGod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, 'OnFamiliarUpdate', FamiliarVariant.WISP)

-- 该道具的火熄灭时移除最晚获得的金饰品
function UnburntGod:PostEntityKill(entity)
    if not entity then return end
    local familiar = entity:ToFamiliar(); if not familiar then return end
    if familiar.Variant ~= FamiliarVariant.WISP or familiar.SubType ~= self.ID then return end
    local player = familiar.Player; if not player then return end
    local trinket = self:GetLatestGoldenTrinket(player)
    if trinket then
        player:TryRemoveSmeltedTrinket(trinket)
    end
end
UnburntGod:AddCallback(ModCallbacks.MC_POST_ENTITY_KILL, 'PostEntityKill', EntityType.ENTITY_FAMILIAR)

return UnburntGod