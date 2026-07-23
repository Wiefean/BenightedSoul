--参孙技能
--皇后

local mod = Isaac_BenightedSoul

local game = Game()
local sfx = SFXManager()

local Skill = mod.IBS_Class.SamsonSkill(4, {
	CalmStateTrans = 1,
	WrathStateTrans = 1,
	
	CalmCost = function(player)
		if player:GetEffects():HasCollectibleEffect(122) then
			return 1
		end
		return 2
	end,
	WrathCost = 0,
})

--颜色
Skill.SwingColor = Color(1,0.1,0.1,1)

--准备攻击
Skill.PreAttack = function(player, compats, params)
	params.AttackDelay = math.max(1, math.floor(params.AttackDelay * 0.8))
	params.Size = params.Size * 0.9
	
	if not params._K4 then
		params._K4 = true
		params.BounceSpeed = params.BounceSpeed * 0.5
		params.SelfBounceSpeed = params.SelfBounceSpeed * 0.5
		params.Color = params.Color * Skill.SwingColor
		params.SoundID = 540
	end
end

--攻击
Skill.OnAttack = function(player, compats, targets)
	local self = Skill
	
	for _,ent in ipairs(targets) do
		if self._Ents:IsEnemy(ent) then
			ent:SetBossStatusEffectCooldown(0)
			ent:AddBleeding(EntityRef(player), 120)
			if ent:GetBleedingCountdown() < 120 then
				ent:SetBleedingCountdown(120)
			end			
		end
	end
end


--平静使用
Skill.CalmOnUse = function(player, compats)
	local effects = player:GetEffects()
	if not effects:HasCollectibleEffect(122) then	
		effects:AddCollectibleEffect(122)
	end
end

return Skill