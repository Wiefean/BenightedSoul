--参孙技能
--太阳

local mod = Isaac_BenightedSoul

local game = Game()
local sfx = SFXManager()

local Skill = mod.IBS_Class.SamsonSkill(20, {
	CalmStateTrans = 1,
	WrathStateTrans = 1,
	
	CalmCost = 2,
	WrathCost = 2,
})

--颜色
Skill.SwingColor = Color(1,0.7,0,1,1)

--准备攻击
Skill.PreAttack = function(player, compats, params)
	if not params._K20 then
		params._K20 = true
		params.Color = params.Color * Skill.SwingColor
	end
end

--发射火焰
function Skill:FireFlame(player, compats, vec)
	local fire = Isaac.Spawn(1000, 52, 0, player.Position + vec:Resized(30), vec:Resized(math.random(4,7) * player.ShotSpeed), player):ToEffect()
	fire.Parent = player
	fire.CollisionDamage = math.max(2, player.Damage)
	
	local scale = self._Maths:TearDamageToScale(fire.CollisionDamage) / 1.2
	if scale > 2 then scale = 2 end
	if scale < 0.7 then scale = 0.7 end
	fire.Scale = scale

	if compats.HIGH then
		fire.Timeout = math.ceil(5*(player.TearRange / 40)) + math.random(0,12)
	else
		fire.Timeout = math.ceil(15*(player.TearRange / 40)) + math.random(0,120)
	end
	
	return fire
end

--攻击
Skill.OnAttack = function(player, compats, targets, effect, vec)
	local self = Skill

	for _,ent in ipairs(targets) do
		if self._Ents:IsEnemy(ent) then
			ent:SetBossStatusEffectCooldown(0)
			ent:AddBurn(EntityRef(player), 70, player.Damage)
			if ent:GetBurnCountdown() < 70 then
				ent:SetBurnCountdown(70)
			end
		end
	end
	
	local chance = 25 + 5 * player.Luck
	if chance > 100 then chance = 100 end
	
	if math.random(1,100) <= chance then	
		self:DelayFunction(function()		
			self:FireFlame(player, compats, vec)
		end, math.random(0,3))
	end
end

--平静使用
Skill.CalmOnUse = function(player, compats)
	local self = Skill
	local vec = Vector(0,1)

	for i = 1,12 do
		local angle = i * 30
		self:FireFlame(player, compats, vec:Rotated(angle))
	end
	
	game:GetLevel():RemoveCurses(LevelCurse.CURSE_OF_DARKNESS)
	
	sfx:Play(536, 1, 0, false, 2)
end

--暴怒使用
Skill.WrathOnUse = function(player, compats)
	local self = Skill
	local vec = Vector(0,1)

	for i = 1,12 do
		local angle = i * 30
		self:FireFlame(player, compats, vec:Rotated(angle))
	end
	
	game:GetLevel():RemoveCurses(LevelCurse.CURSE_OF_DARKNESS)
	
	sfx:Play(536, 1, 0, false, 2)
end

return Skill