--参孙技能
--倒力量

local mod = Isaac_BenightedSoul

local game = Game()
local sfx = SFXManager()

local Skill = mod.IBS_Class.SamsonSkill(67, {
	IsReversed = true,
})

--颜色
Skill.SwingColor = Color(0.3,0.3,0.6,0.7)

--准备攻击
Skill.PreAttack = function(player, compats, params)
	if not params._K67 then
		params._K67 = true
		params.Color = params.Color * Skill.SwingColor
	end
end

--攻击
Skill.OnAttack = function(player, compats, targets)
	local self = Skill
	
	for _,ent in ipairs(targets) do
		if self._Ents:IsEnemy(ent) then
			ent:SetBossStatusEffectCooldown(0)
			ent:AddWeakness(EntityRef(player), 30)
			if ent:GetWeaknessCountdown() < 30 then
				ent:SetWeaknessCountdown(30)
			end			
		end
	end
end

--属性
function Skill:OnEvalueateCache(player, flag)
	if self:HasCard(player) and flag == CacheFlag.CACHE_DAMAGE then
		player.Damage = player.Damage * 0.75
	end	
end
Skill:AddPriorityCallback(ModCallbacks.MC_EVALUATE_CACHE, 100, 'OnEvalueateCache')

return Skill