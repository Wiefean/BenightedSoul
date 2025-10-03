--源数之力

local mod = Isaac_BenightedSoul

local game = Game()
local config = Isaac.GetItemConfig()

local NumeronForce = mod.IBS_Class.Trinket(mod.IBS_TrinketID.NumeronForce)

--根据血量获取当前可用卡牌
function NumeronForce:GetCards(player)
	local h = player:GetHearts() + player:GetSoulHearts()
	
	if h >= 8 and h < 12 then
		return {14, 69}
	elseif h >= 6 and h < 8 then
		return {4, 16}
	elseif h >= 4 and h < 6 then
		return {12, 52}
	elseif h >= 0 and h < 4 then
		return {51, 54}
	end
	
	return {}
end

--效果
function NumeronForce:PreUseCard(id, player, flag)
	if (flag & UseFlag.USE_MIMIC > 0) or (flag & UseFlag.USE_NOANIM > 0) or (flag & UseFlag.USE_NOHUD > 0) then return end
	if not player:HasTrinket(self.ID) then return end

	local cardConfig = config:GetCard(id)
	if cardConfig  and cardConfig.CardType ~= 2 and cardConfig.CardType ~= 4 then
		local cards = self:GetCards(player)
		local double = (player:GetTrinketMultiplier(self.ID) > 1)
		
		if #cards > 0 then
			for _,card in ipairs(cards) do
				for i = 1, ((double and 2) or 1) do
					if card == 69 then --倒死亡延迟触发
						self:DelayFunction(function()		
							player:UseCard(69, UseFlag.USE_NOANIM | UseFlag.USE_NOANNOUNCER | UseFlag.USE_MIMIC)		
						end, 1)
					else					
						player:UseCard(card, UseFlag.USE_NOANIM | UseFlag.USE_NOANNOUNCER | UseFlag.USE_MIMIC)
					end
				end
			end
			player:AnimateCard(id, 'UseItem')
			return true
		else
			if double then
				player:UseCard(id, UseFlag.USE_NOANIM | UseFlag.USE_NOANNOUNCER | UseFlag.USE_MIMIC)
			end
		end
	end
end
NumeronForce:AddPriorityCallback(ModCallbacks.MC_PRE_USE_CARD, -150, 'PreUseCard')


return NumeronForce