--鲍勃的祝福

local mod = Isaac_BenightedSoul
local IBS_PlayerKey = mod.IBS_PlayerKey

local game = Game()

local BobsBlessing = mod.IBS_Class.Item(mod.IBS_ItemID.BobsBlessing)

--爆炸免疫
function BobsBlessing:PrePlayerTakeDMG(player, dmg, flag, source)
	if player:HasCollectible(self.ID) and (flag & DamageFlag.DAMAGE_EXPLOSION > 0) and player:GetNumKeys() > 0 then
		player:AddKeys(-1)

		--毒雾
		local smoke = Isaac.Spawn(1000, 141, 0, player.Position, Vector.Zero, player):ToEffect()
		smoke.Timeout = 180

		return false
	end
end
BobsBlessing:AddPriorityCallback(ModCallbacks.MC_PRE_PLAYER_TAKE_DMG, -999, 'PrePlayerTakeDMG')


return BobsBlessing