--拒绝选择

local mod = Isaac_BenightedSoul

local game = Game()

local NoOptions = mod.IBS_Class.Item(mod.IBS_ItemID.NoOptions)


--拒绝选择
function NoOptions:NoOptions(pickup)
	local has = false
	local onlyLost = true

	for i = 0, game:GetNumPlayers() -1 do
		local player = Isaac.GetPlayer(i)
		local playerType = player:GetPlayerType()
		
		if player:HasCollectible(self.ID) then
			pickup.OptionsPickupIndex = 0
			has = true
			
			--游魂兼容
			if player:GetHealthType() ~= HealthType.LOST and not player:GetEffects():HasNullEffect(NullItemID.ID_LOST_CURSE) then
				onlyLost = false
				break
			end
		end
	end	
	
	if has and onlyLost and (pickup.Price < 0) and (pickup.Price ~= -1000) then
		pickup.AutoUpdatePrice = false
		pickup.Price = -1000
	end
end
NoOptions:AddCallback(ModCallbacks.MC_POST_PICKUP_UPDATE, 'NoOptions')


--双子拾取获得金选或白选
function NoOptions:JacobEsauCompatGain(item, charge, first, slot, varData, player)
	if first then
		local playerType = player:GetPlayerType()
		if playerType == PlayerType.PLAYER_JACOB then
			player:AddCollectible(249)
		elseif playerType == PlayerType.PLAYER_ESAU then
			player:AddCollectible(414)
		end
	end
end
NoOptions:AddCallback(ModCallbacks.MC_POST_ADD_COLLECTIBLE, 'JacobEsauCompatGain', NoOptions.ID)



return NoOptions