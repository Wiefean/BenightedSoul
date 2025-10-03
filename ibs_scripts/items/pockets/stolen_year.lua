--偷来的一年

local mod = Isaac_BenightedSoul
local StolenDecade = mod.IBS_Item.StolenDecade

local game = Game()
local sfx = SFXManager()

local StolenYear = mod.IBS_Class.Pocket(mod.IBS_PocketID.StolenYear)

--使用效果(照搬偷来的十年)
function StolenYear:OnUse(card,player,flag)	
	local level = game:GetLevel()
	local pickups = StolenDecade:FindPricedItems()
	local pickups2 = StolenDecade:FindOptionalItems()

	if #pickups > 0 then
		--掉落物免费
		local pickup = self._Finds:ClosestEntityInTable(player.Position, pickups)
		if pickup then
			pickup.Price = 0
		end
	elseif #pickups2 > 0 then
		--拒绝选择
		for _,pickup in ipairs(pickups2) do
			pickup.OptionsPickupIndex = 0
		end
		self:DelayFunction(function()
			player:AnimateCollectible(mod.IBS_ItemID.NoOptions)
			sfx:Play(128)
		end, 15)
	elseif level:GetStartingRoomIndex() == level:GetCurrentRoomDesc().SafeGridIndex then
		--朝夕符文,诸神符文,透视隐藏房
		player:UseCard(35, UseFlag.USE_NOANIM | UseFlag.USE_NOANNOUNCER | UseFlag.USE_MIMIC)
		player:UseCard(36, UseFlag.USE_NOANIM | UseFlag.USE_NOANNOUNCER | UseFlag.USE_MIMIC)
		level:SetCanSeeEverything(true)	
	else
		--消除碎心+神圣卡
		player:AddBrokenHearts(-1)
		player:UseCard(51, UseFlag.USE_NOANIM | UseFlag.USE_NOANNOUNCER | UseFlag.USE_MIMIC)
	end

	sfx:Play(268)
end
StolenYear:AddCallback(ModCallbacks.MC_USE_CARD, 'OnUse', StolenYear.ID)


return StolenYear