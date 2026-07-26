--奥利哈铁

local mod = Isaac_BenightedSoul
local game = Game()
local config = Isaac.GetItemConfig()
local sfx = SFXManager()

local Orichaliron = mod.IBS_Class.Item(mod.IBS_ItemID.Orichaliron)
local AbandonedItem = mod.IBS_Effect.AbandonedItem

function Orichaliron:GetPlayerData(player)
	local data = self._Players:GetData(player)
	data.Orichaliron = data.Orichaliron or {
		PickedSoulHeart = nil
	}
	
	return data.Orichaliron
end

do
    function Orichaliron:IsPickedSoulHeart(player)
        local data = self:GetPlayerData(player)
        return not not data.PickedSoulHeart
    end

    function Orichaliron:SetPickedSoulHeart(player, value)
        local data = self:GetPlayerData(player)
        data.PickedSoulHeart = value
    end
end

function Orichaliron:PostNewLevel()
    for index, player in pairs(PlayerManager.GetPlayers()) do
        if player:HasCollectible(self.ID) then
            if not Orichaliron:IsPickedSoulHeart(player) then
                self:DelayFunction(function()
                    player:AddSoulHearts(8)
                    sfx:Play(SoundEffect.SOUND_THUMBSUP, 1, 2, false, 1, 0)
                    player:AnimateHappy()
                end, 9)
            end
            Orichaliron:SetPickedSoulHeart(player, nil)
        end
    end
end
Orichaliron:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, 'PostNewLevel')

function Orichaliron:PostPickupCollision(pickup, collider, low)
    local isSoul = pickup.SubType == HeartSubType.HEART_SOUL 
		or pickup.SubType == HeartSubType.HEART_HALF_SOUL

    if not isSoul then return end

    local player = collider:ToPlayer()
    if not player then return end
    if not player:HasCollectible(self.ID) then return end

    if self._Pickups:CanCollect(pickup, player) and not Orichaliron:IsPickedSoulHeart(player) then
        Orichaliron:SetPickedSoulHeart(player, true)
        sfx:Play(SoundEffect.SOUND_THUMBS_DOWN, 1, 2, false, 1, 0)
        local itemConfig = config:GetCollectible(self.ID)
        if itemConfig.GfxFileName then
            AbandonedItem:Spawn(player.Position, itemConfig.GfxFileName, RandomVector() * 0.1 * math.random(10, 15))
        end
    end
end
Orichaliron:AddCallback(ModCallbacks.MC_POST_PICKUP_COLLISION, 'PostPickupCollision', PickupVariant.PICKUP_HEART)

function Orichaliron:OnEvalueateCache(player, flag)
	if player:HasCollectible(self.ID) then
        local num = player:GetCollectibleNum(self.ID)
		self._Stats:Luck(player, 2 * num)
	end
end
Orichaliron:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, 'OnEvalueateCache', CacheFlag.CACHE_LUCK)

return Orichaliron