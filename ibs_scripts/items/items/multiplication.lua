--只剩亿点

local mod = Isaac_BenightedSoul
local IBS_PlayerID = mod.IBS_PlayerID

local game = Game()

local Multiplication = mod.IBS_Class.Item(mod.IBS_ItemID.Multiplication)

--效果
function Multiplication:OnPlayerUpdate(player)
	if game:GetFrameCount() < 1 then return end --稍微等待
	if not player:HasCollectible(self.ID) then return end
	local playerType = player:GetPlayerType()
	local seija = mod.IBS_Compat.THI:SeijaNerf(player) --正邪削弱(东方mod)

	--硬币,炸弹,钥匙下限改为1
	if player:GetNumCoins() <= 0 then player:AddCoins(1) end
	if player:GetNumBombs() <= 0 and playerType ~= PlayerType.PLAYER_BLUEBABY_B then player:AddBombs(1) end
	if player:GetNumKeys() <= 0 then player:AddKeys(1) end

	--正邪削弱,上限也改为1(东方mod)
	if seija then
		local coin = player:GetNumCoins()
		local bomb = player:GetNumBombs()
		local key = player:GetNumKeys()
		
		if coin > 1 then player:AddCoins(-coin) player:AddCoins(1) end
		if bomb > 1 then player:AddBombs(-bomb) player:AddBombs(1) end
		if key > 1 then player:AddKeys(-key) player:AddKeys(1) end
		
		--心容
		if player:GetMaxHearts() > 2 then player:AddMaxHearts(-1) end
	end

	--一堆角色兼容
	if (playerType == PlayerType.PLAYER_BLUEBABY_B) then --里蓝大便
		local poop = player:GetPoopMana()
		if poop <= 0 then
			player:AddPoopMana(1)
		elseif (poop > 1) and seija then
			player:AddPoopMana(-poop)
			player:AddPoopMana(1)
		end
	elseif (playerType == PlayerType.PLAYER_BETHANY) then --伯大尼魂充
		local sc = player:GetSoulCharge()
		if sc <= 0 then
			player:AddSoulCharge(1)
		elseif (sc > 1)	and seija then
			player:SetSoulCharge(1)
		end
	elseif (playerType == PlayerType.PLAYER_BETHANY_B) then --里伯红充	
		local bc = player:GetBloodCharge()
		if bc <= 0 then
			player:AddBloodCharge(1)
		elseif (bc > 1)	and seija then
			player:SetBloodCharge(1)
		end
	end
end
Multiplication:AddCallback(ModCallbacks.MC_POST_PLAYER_RENDER, 'OnPlayerUpdate')



return Multiplication