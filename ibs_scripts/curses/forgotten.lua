--遗忘诅咒

local mod = Isaac_BenightedSoul
local IBS_Curse = mod.IBS_Curse
local Ents = mod.IBS_Lib.Ents
local IBS_RNG = mod:GetUniqueRNG("Curse_Forgotten")
local IBS_RNG2 = mod:GetUniqueRNG("Curse_Forgotten_2")

--尝试添加诅咒
local function PreCurse(_,curse)
	if IBS_Data.Setting["curse_forgotten"] and (IBS_RNG:RandomInt(99) <= 9) then
		return IBS_Curse.forgotten
	end
end
mod:AddPriorityCallback(ModCallbacks.MC_POST_CURSE_EVAL, CallbackPriority.IMPORTANT, PreCurse)

--掉落物消失
local function Disappear()
	local game = Game()
	if (game:GetLevel():GetCurses() & IBS_Curse.forgotten > 0) and not game:GetRoom():IsFirstVisit() then
		for _,pickup in pairs(Isaac.FindByType(5))  do
			if IBS_RNG2:RandomInt(99) <= 49 then
				pickup:Remove()
			end
		end
	end		
end
mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, Disappear)
