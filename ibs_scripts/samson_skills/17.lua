--参孙技能
--塔

local mod = Isaac_BenightedSoul

local game = Game()
local sfx = SFXManager()

local Skill = mod.IBS_Class.SamsonSkill(17, {
	CalmStateTrans = 1,
	WrathStateTrans = 1,
	
	CalmCost = 2,
	WrathCost = 2,
})

--颜色
Skill.SwingColor = Color(0.3,0.3,0.3,1)

--准备攻击
Skill.PreAttack = function(player, compats, params)
	if not params._K17 then
		params._K17 = true
		params.Color = params.Color * Skill.SwingColor
	end
end

--爆炸
function Skill:Explode(player, pos)
	local scale = player.SpriteScale.X
	local hurtSelf = self:HasCard(player, 72) --有倒塔时开启自伤(因为倒塔可以爆炸回血)
	game:BombExplosionEffects(pos, player.Damage * 2, player.TearFlags, self.SwingColor, player, 0.8*scale, true, hurtSelf)
end

--攻击
Skill.OnAttack = function(player, compats, targets)
	local self = Skill
	
	local chance = 16 + 2 * player.Luck
	if chance < 6 then chance = 6 end
	if chance > 50 then chance = 50 end
	
	for _,ent in ipairs(targets) do
		if self._Ents:IsEnemy(ent) and math.random(1,100) <= chance then
			self:Explode(player, ent.Position)
		end
	end
end

--平静使用
Skill.CalmOnUse = function(player, compats)
	Skill:Explode(player, player.Position)
end

--暴怒使用
Skill.WrathOnUse = function(player, compats)
	Skill:Explode(player, player.Position)
end

--爆炸免疫
function Skill:PrePlayerTakeDMG(player, dmg, flag, source)
	if (flag & DamageFlag.DAMAGE_EXPLOSION > 0) and self:HasCard(player) then
		return false
	end
end
Skill:AddPriorityCallback(ModCallbacks.MC_PRE_PLAYER_TAKE_DMG, -1000, 'PrePlayerTakeDMG')

return Skill