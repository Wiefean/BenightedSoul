--混沌信仰

local mod = Isaac_BenightedSoul
local IBS_Trinket = mod.IBS_Trinket

local function OnNewLevel()
	local game = Game()
	for i = 0, game:GetNumPlayers() -1 do
		local player = Isaac.GetPlayer(i)
		if player:HasTrinket(IBS_Trinket.chaoticbelief) then
			local mult = player:GetTrinketMultiplier(IBS_Trinket.chaoticbelief)
			local chance = 0.000001 --由于某些原因,天使转换率会自动加50%,并且第一个恶魔房会变成天使房
			if mult > 2 then chance = 1 end

			game:AddDevilRoomDeal()
			game:GetLevel():AddAngelRoomChance(chance)
		end
	end
end
mod:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, OnNewLevel)

local function CheckRedHeartFlag()
	local game = Game()
	for i = 0, game:GetNumPlayers() -1 do
		local player = Isaac.GetPlayer(i)
		if player:HasTrinket(IBS_Trinket.chaoticbelief) then
			local level = game:GetLevel()
			if level:GetStateFlag(LevelStateFlag.STATE_REDHEART_DAMAGED) then
				level:SetStateFlag(LevelStateFlag.STATE_REDHEART_DAMAGED, false)
			end	
			break
		end
	end	
end
mod:AddCallback(ModCallbacks.MC_POST_UPDATE, CheckRedHeartFlag)



