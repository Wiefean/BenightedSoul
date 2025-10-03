--月桂枝

local mod = Isaac_BenightedSoul
local IronHeart = mod.IBS_Class.IronHeart()
local TempIronHeart = mod.IBS_Class.TempIronHeart()

local game = Game()

local LunarTwigs = mod.IBS_Class.Trinket(mod.IBS_TrinketID.LunarTwigs)


--新房间给予临时铁心
function LunarTwigs:AddIronHeart()
	if not game:GetRoom():IsFirstVisit() then return end
	for i = 0, game:GetNumPlayers() -1 do
		local player = Isaac.GetPlayer(i)
		if player:HasTrinket(self.ID) then
			local mult = player:GetTrinketMultiplier(self.ID)
			
			--表表抹
			if player:GetPlayerType() == (mod.IBS_PlayerID.BMaggy) then
				local data = IronHeart:GetData(player)
				data.Extra = data.Extra + mult
			else
				local data = TempIronHeart:GetData(player)
				data.Num = data.Num + mult
			end
		end
	end
end
LunarTwigs:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, 'AddIronHeart')


return LunarTwigs