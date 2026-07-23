--参孙技能
--倒战车

local mod = Isaac_BenightedSoul

local game = Game()
local sfx = SFXManager()

local Skill = mod.IBS_Class.SamsonSkill(63, {
	IsReversed = true,
})

--准备攻击
Skill.PreAttack = function(player, compats, params)
	if player.Velocity:Length() <= 1 then
		params.AttackDelay = math.max(1, math.floor(params.AttackDelay * 0.62))
		
		if not params._K63 then
			params._K63 = true
			params.BounceSpeed = params.BounceSpeed * 0.5
			params.SelfBounceSpeed = params.SelfBounceSpeed * 0
		end
	end
end


return Skill