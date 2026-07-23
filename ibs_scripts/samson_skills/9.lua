--参孙技能
--正义

local mod = Isaac_BenightedSoul

local game = Game()
local sfx = SFXManager()

local Skill = mod.IBS_Class.SamsonSkill(9, {
	CalmStateTrans = 1,
	WrathStateTrans = 0,
	
	CalmCost = 2,
	WrathCost = 1,
})

--颜色
Skill.SwingColor = Color(1,0.5,0.2,1)

--准备攻击
Skill.PreAttack = function(player, compats, params)
	if not params._K9 then
		params._K9 = true
		params.Damage = params.Damage * 0.5
		params.Color = params.Color * Skill.SwingColor
	end
end

--攻击
Skill.OnAttack = function(player, compats, targets, effect)
	local self = Skill

	--发射眼泪
	for _,ent in ipairs(targets) do
		if self._Ents:IsEnemy(ent) then
			local vec = (ent.Position - player.Position):Resized(player.ShotSpeed * 8)
		
			self:DelayFunction(function()		
				local tear = player:FireTear(player.Position, vec, true, true, false)
				tear.Color = tear.Color * self.SwingColor
				tear:Update()
			end, math.random(0,9))
		end
	end	
end

--平静使用
Skill.CalmOnUse = function(player, compats)
	local data = mod.IBS_Item.Posture:GetData(player)
	data.FreeTimes = data.FreeTimes + 1
end

--暴怒使用
Skill.WrathOnUse = function(player, compats, slot)
	local Posture = mod.IBS_Item and mod.IBS_Item.Posture
	if Posture then	
		Skill:DelayFunction(function()
			Posture:Charge(player, slot, 1)
		end, 1)
	end	
end

return Skill