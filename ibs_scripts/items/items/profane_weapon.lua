--俗世的武器

local mod = Isaac_BenightedSoul

local game = Game()

local ProfaneWeapon = mod.IBS_Class.Item(mod.IBS_ItemID.ProfaneWeapon)


--受伤增加
function ProfaneWeapon:OnTakeDMG(ent, dmg, flag, source, cd)
	if dmg <= 0 then return end

	if self._Ents:IsEnemy(ent, false, false, true) and PlayerManager.AnyoneHasCollectible(self.ID) then
		return {Damage = dmg * 1.5, DamageFlags = flag | DamageFlag.DAMAGE_IGNORE_ARMOR, DamageCountdown = cd}
	end
end
ProfaneWeapon:AddPriorityCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, 100000, 'OnTakeDMG')


return ProfaneWeapon