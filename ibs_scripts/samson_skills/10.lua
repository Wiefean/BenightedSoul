--参孙技能
--隐者

local mod = Isaac_BenightedSoul

local game = Game()
local sfx = SFXManager()

local Skill = mod.IBS_Class.SamsonSkill(10, {
	WrathStateTrans = 0,
	
	CalmCost = 3,
	WrathCost = 0,
})

--准备攻击
Skill.PreAttack = function(player, compats, params)
	if not params._K10 then
		params._K10 = true
		params.Num = params.Num + 2
		params.AttackDelay = math.max(1, math.floor(params.AttackDelay * 2))
	end
end


--发射眼泪
function Skill:FireTear(player, compats, vec)
	local percent = ((player.TearRange / 40) / 6.5)
	local A = math.max(0.1, 0.2 - 0.1 * percent)
	
	local tear = player:FireTear(player.Position, vec:Resized(player.ShotSpeed * 9), true, true, false)
	tear:ChangeVariant(20)
	tear.Scale = self._Maths:TearDamageToScale(player.Damage)
	tear.CollisionDamage = player.Damage
	tear.TearFlags = TearFlags.TEAR_HYDROBOUNCE | TearFlags.TEAR_BOUNCE
	tear.FallingSpeed = -10
	tear.FallingAcceleration = A
	tear.Height = -15	
	
	local color = Color(115/255, 99/255, 122/255, 0.25, 0, 0, 1)
	color:SetColorize(1,1,1,2)	
	tear.Color = color
	tear:Update()
	
	return tear
end

--平静使用
Skill.CalmOnUse = function(player, compats)
	local self = Skill
	
	for i = 1,30 do
		self:FireTear(player, compats, RandomVector())
	end
	
	sfx:Play(594, 0.5, 10)
end

return Skill