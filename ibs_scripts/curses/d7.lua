--七面骰诅咒

local mod = Isaac_BenightedSoul
local IBS_Curse = mod.IBS_Curse
local Ents = mod.IBS_Lib.Ents
local IBS_RNG = mod:GetUniqueRNG("Curse_D7")
local IBS_RNG2 = mod:GetUniqueRNG("Curse_D7_2")

--尝试添加诅咒
local function PreCurse(_,curse)
	if (not Game():IsGreedMode()) and IBS_Data.Setting["curse_d7"] and (IBS_RNG:RandomInt(99) <= 9) then
		return IBS_Curse.d7
	end
end
mod:AddPriorityCallback(ModCallbacks.MC_POST_CURSE_EVAL, CallbackPriority.IMPORTANT, PreCurse)

--重置房间
local function Reroll()
	local game = Game()
	if (game:GetLevel():GetCurses() & IBS_Curse.d7 > 0) then
		if IBS_RNG2:RandomInt(99) <= 24 then
			game:GetRoom():RespawnEnemies()
		end
	end		
end
mod:AddCallback(ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD, Reroll)
