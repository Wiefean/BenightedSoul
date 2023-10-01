--七面骰诅咒

local mod = Isaac_BenightedSoul
local IBS_Curse = mod.IBS_Curse
local Ents = mod.IBS_Lib.Ents
local IBS_RNG = mod:GetUniqueRNG("Curse_D7")

--重置房间
local function Reroll()
	local game = Game()
	if not game:IsGreedMode() then
		local room = game:GetRoom()
		if (game:GetLevel():GetCurses() & IBS_Curse.d7 > 0) and (room:GetType() == RoomType.ROOM_DEFAULT) then
			if IBS_RNG:RandomInt(99) <= 24 then
				room:RespawnEnemies()
			end
		end		
	end	
end
mod:AddCallback(ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD, Reroll)
