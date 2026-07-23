--参孙技能
--倒塔

local mod = Isaac_BenightedSoul

local game = Game()
local sfx = SFXManager()

local Skill = mod.IBS_Class.SamsonSkill(72, {
	IsReversed = true,
})

--爆炸免疫
function Skill:PrePlayerTakeDMG(player, dmg, flag, source)
	if (flag & DamageFlag.DAMAGE_EXPLOSION > 0) and self:HasCard(player) then
		if not player:HasFullHearts() then		
			player:AddHearts(1)
			Isaac.Spawn(1000, 49, 0, player.Position, Vector.Zero, nil)
		end
		return false
	end
end
Skill:AddPriorityCallback(ModCallbacks.MC_PRE_PLAYER_TAKE_DMG, -1001, 'PrePlayerTakeDMG')

return Skill