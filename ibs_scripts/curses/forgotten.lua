--遗忘诅咒

local mod = Isaac_BenightedSoul
local IBS_Curse = mod.IBS_Curse
local Ents = mod.IBS_Lib.Ents
local IBS_RNG = mod:GetUniqueRNG("Curse_Forgotten")

--掉落物消失
local function Disappear()
	local game = Game()
	if not game:IsGreedMode() then
		if (game:GetLevel():GetCurses() & IBS_Curse.forgotten > 0) and not game:GetRoom():IsFirstVisit() then
			for _,pickup in pairs(Isaac.FindByType(5))  do
				if IBS_RNG:RandomInt(99) <= 49 then
					pickup:Remove()
				end
			end
		end	
	end
end
mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, Disappear)
