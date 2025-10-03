--免茶

local mod = Isaac_BenightedSoul
local Stats = mod.IBS_Lib.Stats

local LownTea = mod.IBS_Class.Item(mod.IBS_ItemID.LownTea)

--角色更新
function LownTea:OnPlayerUpdate(player)
	if not player:IsFrame(30,0) then return end
	if not player:HasCollectible(CollectibleType.COLLECTIBLE_BINGE_EATER) then return end
	local num = 4 * player:GetCollectibleNum(self.ID)
	if player:GetNumBlueFlies() < num then
		player:AddBlueFlies(1, player.Position, nil)
	end
end
LownTea:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, 'OnPlayerUpdate', 0)

--属性
function LownTea:OnEvaluateCache(player, flag)
    if player:HasCollectible(CollectibleType.COLLECTIBLE_BINGE_EATER) and player:HasCollectible(self.ID) then
        local num = player:GetCollectibleNum(self.ID)
        if (flag == CacheFlag.CACHE_DAMAGE) then
            Stats:Damage(player, 0.5*num)
		end
        if (flag == CacheFlag.CACHE_SPEED) then
            Stats:Speed(player, -0.03*num)
        end
    end
end
LownTea:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, 'OnEvaluateCache')


return LownTea
