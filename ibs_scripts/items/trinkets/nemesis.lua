--天谴报应

local mod = Isaac_BenightedSoul

local sfx = SFXManager()

local Nemesis = mod.IBS_Class.Trinket(mod.IBS_TrinketID.Nemesis)

--效果
function Nemesis:OnTakeDMG(ent, dmg, flag, source)
	local player = ent:ToPlayer()
	
	if player and player:HasTrinket(self.ID) then
		local mult = player:GetTrinketMultiplier(self.ID)
		local target = self._Ents:GetSourceEnemy(source.Entity)
		if target ~= nil then
			target:TakeDamage(math.max(28, player.Damage * 7 * mult), DamageFlag.DAMAGE_IGNORE_ARMOR, EntityRef(player), 0)
			target:BloodExplode()
		end
	end
end
Nemesis:AddCallback(ModCallbacks.MC_POST_ENTITY_TAKE_DMG, 'OnTakeDMG')


return Nemesis