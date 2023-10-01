--拒绝选择

local mod = Isaac_BenightedSoul
local IBS_Callback = mod.IBS_Callback
local IBS_Curse = mod.IBS_Curse
local IBS_Item = mod.IBS_Item

--效果
mod:AddCallback(ModCallbacks.MC_POST_PICKUP_UPDATE, function(_,pickup)
	local has = false
	local onlyLost = true

	for i = 0, Game():GetNumPlayers() -1 do
		local player = Isaac.GetPlayer(i)
		local playerType = player:GetPlayerType()
		
		if player:HasCollectible(IBS_Item.nop) then
			pickup.OptionsPickupIndex = 0
			has = true
			
			--游魂兼容
			if (playerType ~= PlayerType.PLAYER_THELOST) and (playerType ~= PlayerType.PLAYER_THELOST_B) and not player:GetEffects():HasNullEffect(NullItemID.ID_LOST_CURSE) then
				onlyLost = false
				break
			end
		end
	end	
	
	if has and onlyLost and (pickup.Price < 0) and (pickup.Price ~= -1000) then
		pickup.AutoUpdatePrice = false
		pickup.Price = -1000
	end
end)

--双子拾取获得金选或白选
local function Gain(_,player, item, num, touched)
	if (not touched and player.Variant == 0 and not player:IsCoopGhost()) then
		for i = 1,1*num do
			local playerType = player:GetPlayerType()
			if playerType == PlayerType.PLAYER_JACOB then
				player:AddCollectible(249)
			elseif playerType == PlayerType.PLAYER_ESAU then
				player:AddCollectible(414)
			end
			
			--正邪削弱(东方mod)
			if player:HasCollectible(IBS_Item.nop) and mod:THI_WillSeijaNerf(player) then
				Game():GetLevel():AddCurse(IBS_Curse.forgotten)
			end
		end	
	end
end
mod:AddCallback(IBS_Callback.GAIN_COLLECTIBLE, Gain, IBS_Item.nop)

--正邪削弱(东方mod)
local function ApplyCurse(_,curse)
	for i = 0, Game():GetNumPlayers() -1 do
		local player = Isaac.GetPlayer(i)
		if player:HasCollectible(IBS_Item.nop) and mod:THI_WillSeijaNerf(player) then
			Game():GetLevel():AddCurse(IBS_Curse.forgotten)
		end
	end
end
mod:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, ApplyCurse)

