--表观思维

local mod = Isaac_BenightedSoul

local game = Game()

local PresentationalMind = mod.IBS_Class.Trinket(mod.IBS_TrinketID.PresentationalMind)

--获得
function PresentationalMind:OnDevilChance(chance)
	if PlayerManager.AnyoneHasTrinket(self.ID) then
		local mult = PlayerManager.GetTotalTrinketMultiplier(self.ID)
		local extra = 0
		local coin = Isaac.GetPlayer(0):GetNumCoins()

		while coin >= 3 do
			coin = coin - 3
			extra = extra + 0.013
		end

		return chance + extra*mult
	end
end
PresentationalMind:AddCallback(ModCallbacks.MC_POST_DEVIL_CALCULATE, 'OnDevilChance')


return PresentationalMind