--晦涩之心

local mod = Isaac_BenightedSoul

local Tenebrosity = mod.IBS_Class.Item(mod.IBS_ItemID.Tenebrosity)

--获得心时概率触发死灵书效果
function Tenebrosity:OnGainHeart(player, num, flag)
	if num > 0 and (flag & AddHealthType.NONE <= 0) and (flag & AddHealthType.MAX <= 0) and (flag & AddHealthType.BONE <= 0) and (flag & AddHealthType.BROKEN <= 0) and player:HasCollectible(self.ID) then
		local rng = player:GetCollectibleRNG(self.ID)
		local chance = math.max(22, 22 + 6 * player.Luck)
		local seija = mod.IBS_Compat.THI:SeijaBuff(player)
		local seijaBLevel = mod.IBS_Compat.THI:GetSeijaBLevel(player)

		for i = 1, num do
			if rng:RandomInt(100) < chance then
				player:UseActiveItem(35, false, false)

				--正邪增强(东方mod)
				if seija then
					self._Stats:PersisDamage(player, 0.5 + 0.5 * seijaBLevel, true)
				end
			end
		end
	end
end
Tenebrosity:AddCallback(ModCallbacks.MC_POST_PLAYER_ADD_HEARTS, 'OnGainHeart')


return Tenebrosity
