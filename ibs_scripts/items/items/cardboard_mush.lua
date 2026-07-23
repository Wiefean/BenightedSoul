--纸板蘑菇

local mod = Isaac_BenightedSoul
local Stats = mod.IBS_Lib.Stats

local game = Game()
local config = Isaac.GetItemConfig()

local CardboardMush = mod.IBS_Class.Item(mod.IBS_ItemID.CardboardMush)

--获得时生成卡牌
function CardboardMush:OnGain(item, charge, first, slot, varData, player)
	if first then
		local room = game:GetRoom()
		local itemPool = game:GetItemPool()
		local rng = player:GetCollectibleRNG(self.ID)
		for i = 1,3 do
			local card = itemPool:GetCardEx(rng:Next(), 1, 0, 1, false)
			local pos = room:FindFreePickupSpawnPosition(player.Position, 0, true)
			Isaac.Spawn(5, 300, card, pos, Vector.Zero, nil)
		end
	end
end
CardboardMush:AddCallback(ModCallbacks.MC_POST_ADD_COLLECTIBLE, 'OnGain', CardboardMush.ID)

--消耗卡牌时触发力量卡效果
function CardboardMush:OnUseCard(id, player, flag)
	if (flag & UseFlag.USE_MIMIC > 0) or (flag & UseFlag.USE_NOANIM > 0) or (flag & UseFlag.USE_NOHUD > 0) then return end
	if not player:HasCollectible(self.ID) then return end
	local cardConfig = config:GetCard(id)
	if cardConfig  and cardConfig.CardType ~= 2 and cardConfig.CardType ~= 4 then
		self:DelayFunction(function()		
			player:UseCard(12, UseFlag.USE_NOANIM | UseFlag.USE_NOANNOUNCER | UseFlag.USE_MIMIC)
		end, 1)
	end
end
CardboardMush:AddCallback(ModCallbacks.MC_USE_CARD, 'OnUseCard')


return CardboardMush