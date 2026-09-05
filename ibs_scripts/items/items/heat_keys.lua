--炽热钥匙

local mod = Isaac_BenightedSoul

local game = Game()
local sfx = SFXManager()

local HeatKeys = mod.IBS_Class.Item(mod.IBS_ItemID.HeatKeys)

--失去钥匙时触发
function HeatKeys:OnKeyNumChange(delta)
	if delta < 0 then
		for i = 0, game:GetNumPlayers() - 1 do
			local player = Isaac.GetPlayer(i)
			if player:HasCollectible(self.ID) then
				for i = 1,player:GetCollectibleRNG(self.ID):RandomInt(1,3) do				
					player:AddWisp(0, player.Position, true)
				end
			end
		end
	end
end
HeatKeys:AddCallback(mod.IBS_CallbackID.NUM_CHANGE_KEY,'OnKeyNumChange')

return HeatKeys