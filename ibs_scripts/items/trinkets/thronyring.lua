--荆棘指环

local mod = Isaac_BenightedSoul
local IBS_Trinket = mod.IBS_Trinket
local Ents = mod.IBS_Lib.Ents

local sfx = SFXManager()

--效果
local function TakeDMG(_,ent, amount, flag, source)
	local player = ent:ToPlayer()
	
	if player and player:HasTrinket(IBS_Trinket.thronyring) then
		local rng = player:GetTrinketRNG(IBS_Trinket.thronyring)
		local chance = player:GetTrinketMultiplier(IBS_Trinket.thronyring) * 9
		if chance > 27 then chance = 27 end

		if rng:RandomInt(99)+1 <= chance then
			local game = Game()
			local int = rng:RandomInt(99) + 1
			
			if int <= 25 then --25%魂心
				mod:DelayFunction(function() player:AddSoulHearts(2) end, 1)
				sfx:Play(SoundEffect.SOUND_HOLY)
			elseif int > 25 and int <= 35 then --10%白心
				mod:DelayFunction(function() player:AddEternalHearts(1) end, 1)
				sfx:Play(SoundEffect.SOUND_SUPERHOLY)
			elseif int > 35 and int <= 50 then --15%天使房转换率以及清诅咒
				local level = game:GetLevel()
				level:AddAngelRoomChance(0.1)
				
				--硬核清诅咒(实在想不到如何处理模组诅咒)
				for i = 1,31 do
					level:RemoveCurses(1 << i)
				end
				
				local text = "You Feel Blessed!"
				if mod.Language == "zh" then text = "你被祝福了 !" end
				Game():GetHUD():ShowFortuneText(text)
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
mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, TakeDMG)
