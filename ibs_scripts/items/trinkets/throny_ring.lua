--荆棘指环

local mod = Isaac_BenightedSoul

local game = Game()
local sfx = SFXManager()

local ThronyRing = mod.IBS_Class.Trinket(mod.IBS_TrinketID.ThronyRing)

--效果
function ThronyRing:OnTakeDMG(ent, amount, flag, source)
	local player = ent:ToPlayer()

	if player and player:HasTrinket(self.ID) then
		local rng = player:GetTrinketRNG(self.ID)
		local chance = player:GetTrinketMultiplier(self.ID) * 13
		if chance > 39 then chance = 39 end

		if rng:RandomInt(100) < chance then
			local int = rng:RandomInt(99) + 1
			
			if int <= 25 then --25%魂心
				mod:DelayFunction(function() player:AddSoulHearts(2) end, 1)
				sfx:Play(SoundEffect.SOUND_HOLY)
			elseif int > 25 and int <= 35 then --10%白心
				mod:DelayFunction(function() player:AddEternalHearts(1) end, 1)
				sfx:Play(SoundEffect.SOUND_SUPERHOLY)
			elseif int > 35 and int <= 50 then --15%天使房转换率以及清诅咒
				local level = game:GetLevel()
				level:AddAngelRoomChance(0.15)
				level:RemoveCurses(level:GetCurses())
				game:GetHUD():ShowFortuneText(self:ChooseLanguage('你被祝福了 !', 'You Feel Blessed!'))
			else --50%清碎心，没有则加魂心
				if player:GetBrokenHearts() > 0 then
					player:AddBrokenHearts(-1)
					sfx:Play(SoundEffect.SOUND_SUPERHOLY)
				else
					mod:DelayFunction(function() player:AddSoulHearts(2) end, 1)
					sfx:Play(SoundEffect.SOUND_HOLY)
				end
			end
		end
	end
end
ThronyRing:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, 'OnTakeDMG')



return ThronyRing