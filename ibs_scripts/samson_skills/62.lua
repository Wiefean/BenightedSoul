--参孙技能
--倒恋人

local mod = Isaac_BenightedSoul

local game = Game()
local sfx = SFXManager()

local Skill = mod.IBS_Class.SamsonSkill(62, {
	IsReversed = true,
})

--准备攻击
Skill.PreAttack = function(player, compats, params)
	if not params._K62 then
		params._K62 = true
		params.Num = params.Num - 2
		
		--每种心提升伤害和范围
		local mult = 1
		local mult2 = 1
		if player:GetHearts() > 0 then 
			mult = mult * 1.2 
			mult2 = mult2 * 1.05
		end
		if player:GetSoulHearts() > 0 then 
			mult = mult * 1.2
			mult2 = mult2 * 1.05
		end
		if player:GetEternalHearts() > 0 then 
			mult = mult * 1.2 
			mult2 = mult2 * 1.05
		end
		if player:GetBlackHearts() > 0 then 
			mult = mult * 1.2 
			mult2 = mult2 * 1.05
		end
		if player:GetGoldenHearts() > 0 then 
			mult = mult * 1.2 
			mult2 = mult2 * 1.05
		end
		if player:GetBoneHearts() > 0 then 
			mult = mult * 1.2
			mult2 = mult2 * 1.05
		end
		if player:GetRottenHearts() > 0 then
			mult = mult * 1.2
			mult2 = mult2 * 1.05
		end
		if player:GetBrokenHearts() > 0 then 
			mult = mult * 1.2
			mult2 = mult2 * 1.05
		end

		params.Damage = params.Damage * mult
		params.Size = params.Size * mult2
	end	
end

return Skill