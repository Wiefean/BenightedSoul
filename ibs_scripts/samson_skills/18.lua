--参孙技能
--星星

local mod = Isaac_BenightedSoul

local game = Game()
local sfx = SFXManager()

local Skill = mod.IBS_Class.SamsonSkill(18, {
	CalmStateTrans = 1,
	WrathStateTrans = 0,
	
	CalmCost = 3,
	WrathCost = 0,
})

--颜色
Skill.SwingColor = Color(1,1,0.5,1)

--准备攻击
Skill.PreAttack = function(player, compats, params)
	params.Damage = params.Damage + 2 * math.max(0, player.Luck)

	if not params._K18 then
		params._K18 = true
		params.Color = params.Color * Skill.SwingColor
	end
end

--发射眼泪
function Skill:FireTear(player, vec)
	local tear = player:FireTear(player.Position, vec:Resized(player.ShotSpeed * 15), true, true, false)
	tear:ChangeVariant(18)
	tear.CollisionDamage = 2 * math.max(0, player.Luck)
	tear.Scale = 0.5 * self._Maths:TearDamageToScale(tear.CollisionDamage)
	tear.Color = Color(1,1,1,1,1,1,0.5)
	tear:Update()
	
	return tear
end

--攻击
Skill.OnAttack = function(player, compats, targets, effect, vec)
	if player.Luck >= 1 then		
		Skill:DelayFunction(function()		
			Skill:FireTear(player, vec)
		end, math.random(0,3))
	end
end

--平静使用
Skill.CalmOnUse = function(player, compats)
	Skill._Stats:LevelLuck(player, 1, true)
end

--属性
function Skill:OnEvalueateCache(player, flag)
	if self:HasCard(player) and flag == CacheFlag.CACHE_LUCK then
		self._Stats:Luck(player, self:GetCardNum(player))
	end	
end
Skill:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, 'OnEvalueateCache')

return Skill