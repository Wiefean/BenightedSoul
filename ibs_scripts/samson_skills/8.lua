--参孙技能
--战车

local mod = Isaac_BenightedSoul

local game = Game()
local sfx = SFXManager()

local Skill = mod.IBS_Class.SamsonSkill(8, {
	CalmStateTrans = 1,
	WrathStateTrans = 1,
	
	CalmCost = 1,
	WrathCost = 1,
})

--准备攻击
Skill.PreAttack = function(player, compats, params)
	if not params._K8 then
		params._K8 = true
		
		local data = Skill:GetTempData(player)
		if data.Distance then		
			params.Damage = params.Damage * (1 + 0.001 *data.Distance)
			params.Size = params.Size * (1 + 0.001 *data.Distance)
			params.Distance = params.Distance * (1 + 0.01 *data.Distance)
			params.SelfBounceSpeed = 0
		end
	end
end

--攻击
Skill.OnAttack = function(player, compats, targets, effect)
	if not game:GetRoom():IsPositionInRoom(effect.Position, 20) then
		Skill:GetTempData(player).Distance = nil
	end
end

function Skill:OnPlayerUpdate(player)
	if self:HasCard(player) then
		local data = self:GetTempData(player)
		if self._Players:IsShooting(player) then
			data.Distance = (data.Distance or 0) + 2
		else
			data.Distance = nil
		end
	end
end
Skill:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, "OnPlayerUpdate", 0)


return Skill