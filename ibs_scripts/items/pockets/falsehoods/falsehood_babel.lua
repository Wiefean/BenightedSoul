--亚伯的伪忆

local mod = Isaac_BenightedSoul

local game = Game()

local BAbel = mod.IBS_Class.Pocket(mod.IBS_PocketID.BAbel)

--效果
function BAbel:OnUse(card, player, flag)
	for i = 1,3 do
		local pos = game:GetRoom():FindFreePickupSpawnPosition(player.Position, 0, true)
		local goat = Isaac.Spawn(EntityType.ENTITY_GOAT, 0, 0, pos, Vector.Zero, player)
		goat:AddCharmed(EntityRef(player), -1)
		goat:AddEntityFlags(EntityFlag.FLAG_NO_SPIKE_DAMAGE)
		goat:AddEntityFlags(EntityFlag.FLAG_NO_REWARD)
		goat.MaxHitPoints = goat.MaxHitPoints * 7
		goat.HitPoints = goat.HitPoints * 7
	end
end
BAbel:AddCallback(ModCallbacks.MC_USE_CARD, 'OnUse', BAbel.ID)

--符文佩剑(东方mod)
if mod.IBS_Compat.THI:IsEnabled() then
	local RuneSword = THI.Collectibles.RuneSword

	mod.IBS_Compat.THI:AddRuneSwordCompat(BAbel.ID, {
		png = "gfx/ibs/items/pick ups/falsehoods/babel.png",
		textKey = "FALSEHOOD_BABEL",
		name = {
			zh = "亚伯的伪忆",
			en = "Falsehood of Abel",
		},
		desc = {
			zh = "变羊术",
			en = "Goatify",
		}, 
	})
	
	--受伤将攻击者变成山羊
	function BAbel:OnTakeDMG(ent, dmg, flag, source)
		local player = ent:ToPlayer()
		if player and RuneSword:HasInsertedRune(player, self.ID) then
			local target = self._Ents:GetSourceEnemy(source.Entity)
			if target ~= nil and target:IsVulnerableEnemy() and not target:IsBoss() then
				local goat = Isaac.Spawn(891,0,0, target.Position, Vector.Zero, player)
				goat:AddCharmed(EntityRef(player), -1)
				target:Remove()
			end
		end
	end
	BAbel:AddCallback(ModCallbacks.MC_POST_ENTITY_TAKE_DMG, 'OnTakeDMG')
	
end

return BAbel