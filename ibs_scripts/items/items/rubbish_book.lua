--惊天秘密

local mod = Isaac_BenightedSoul

local RubbishBook = mod.IBS_Class.Item(mod.IBS_ItemID.RubbishBook)

--使用
function RubbishBook:OnUse(item, rng, player, flag, slot)
	SFXManager():Play(mod.IBS_Sound.RubbishBook, 1, 0, false, 0.01*math.random(130,300))

	--正邪增强(东方mod)
	if mod.IBS_Compat.THI:SeijaBuff(player) then
		if mod.IBS_Compat.THI:SeijaBuff(player)	then
			local seijaBLevel = mod.IBS_Compat.THI:GetSeijaBLevel(player)
			local num = math.max(1, seijaBLevel)
			player:AddCoins(num)
		end
	end

	return true
end
RubbishBook:AddCallback(ModCallbacks.MC_USE_ITEM, 'OnUse', RubbishBook.ID)


return RubbishBook
