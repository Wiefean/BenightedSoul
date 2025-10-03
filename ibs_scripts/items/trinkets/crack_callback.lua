--踩背腿

local mod = Isaac_BenightedSoul

local sfx = SFXManager()

local CrackCallback = mod.IBS_Class.Trinket(mod.IBS_TrinketID.CrackCallback)

--受伤召妈腿
function CrackCallback:OnTakeDMG(ent, dmg, flag, source)
	local player = ent:ToPlayer()
	
	if player and player:HasTrinket(self.ID) then
		local chance = 30 + 30*(player:GetTrinketMultiplier(self.ID)-1)
		if player:GetTrinketRNG(self.ID):RandomInt(100) < chance then
			player:UseCard(3, UseFlag.USE_NOANIM | UseFlag.USE_NOANNOUNCER | UseFlag.USE_MIMIC)
		end
	end
end
CrackCallback:AddCallback(ModCallbacks.MC_POST_ENTITY_TAKE_DMG, 'OnTakeDMG')

--角色践踏免疫
function CrackCallback:PrePlayerTakeDMG(player, dmg, flag)
	if player:HasTrinket(self.ID) and (flag & DamageFlag.DAMAGE_CRUSH > 0) then
		return false
	end
end
CrackCallback:AddPriorityCallback(ModCallbacks.MC_PRE_PLAYER_TAKE_DMG, -800, 'PrePlayerTakeDMG')


return CrackCallback