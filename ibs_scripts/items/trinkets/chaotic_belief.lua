--混沌信仰

local mod = Isaac_BenightedSoul

local game = Game()
local sfx = SFXManager()

local ChaoticBelief = mod.IBS_Class.Trinket(mod.IBS_TrinketID.ChaoticBelief)

--获得
function ChaoticBelief:OnGainTrinket(player, trinket, first)
	if first then
		player:AddBlackHearts(2)
		player:AddEternalHearts(1)
		game:AddDevilRoomDeal()
		game:GetLevel():AddAngelRoomChance(1)
		sfx:Play(316)
	end
end
ChaoticBelief:AddCallback(ModCallbacks.MC_POST_TRIGGER_TRINKET_ADDED, 'OnGainTrinket', ChaoticBelief.ID)

--新层加天使房率
function ChaoticBelief:OnNewLevel()
	local mult = PlayerManager.GetTotalTrinketMultiplier(self.ID)
	if mult > 0 then
		local chance = 10^(-7) --由于某些原因,天使转换率会自动加50%,并且第一个恶魔房会变成天使房
		if mult > 2 then chance = 1 end		
		game:GetLevel():AddAngelRoomChance(chance)
	end
end
ChaoticBelief:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, 'OnNewLevel')

--普通房间红心受伤不扣房率
function ChaoticBelief:CheckRedHeartFlag()
	if PlayerManager.AnyoneHasTrinket(self.ID) then
		local level = game:GetLevel()
		if level:GetStateFlag(LevelStateFlag.STATE_REDHEART_DAMAGED) then
			level:SetStateFlag(LevelStateFlag.STATE_REDHEART_DAMAGED, false)
		end
	end	
end
ChaoticBelief:AddCallback(ModCallbacks.MC_POST_RENDER, 'CheckRedHeartFlag')


return ChaoticBelief