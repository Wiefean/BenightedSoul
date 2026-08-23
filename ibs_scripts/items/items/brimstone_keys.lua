--硫磺火钥匙

local mod = Isaac_BenightedSoul

local game = Game()

local BrimstoneKeys = mod.IBS_Class.Item(mod.IBS_ItemID.BrimstoneKeys)

--失去钥匙时触发
function BrimstoneKeys:OnKeyNumChange(delta)
	if delta < 0 then
		for i = 0, game:GetNumPlayers() - 1 do
			local player = Isaac.GetPlayer(i)
			if player:HasCollectible(self.ID) then
				local vec = Vector(0,1)
				local angle = 0
				for i = 0,3 do
					angle = 90 * i
					local laser = player:FireBrimstone(vec:Rotated(angle), player)
					laser:SetTimeout(33)
				end
				
				--正邪增强
				--给半黑心
				if mod.IBS_Compat.THI:SeijaBuff(player) then
					if mod.IBS_Compat.THI:SeijaBuff(player)	then
						local seijaBLevel = mod.IBS_Compat.THI:GetSeijaBLevel(player)
						local num = math.max(1, seijaBLevel)
						player:AddBlackHearts(num)
					end
				end
			end
		end
	end
end
BrimstoneKeys:AddCallback(mod.IBS_CallbackID.NUM_CHANGE_KEY,'OnKeyNumChange')


return BrimstoneKeys
