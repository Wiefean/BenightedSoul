--参孙技能
--教皇

local mod = Isaac_BenightedSoul

local game = Game()
local sfx = SFXManager()

local Skill = mod.IBS_Class.SamsonSkill(6, {
	WrathStateTrans = 0,
	
	CalmCost = 3,
	WrathCost = 1,	
})

--颜色
Skill.SwingColor = Color(0.2,0.6,1,1)

--准备攻击
Skill.PreAttack = function(player, compats, params)
	if not params._K6 then
		params._K6 = true
		params.Color = params.Color * Skill.SwingColor
	end
end

--攻击
Skill.OnAttack = function(player, compats, targets)
	local self = Skill
	local num = self:GetCardNum(player)
	
	for _,ent in ipairs(targets) do
		if ent:IsActiveEnemy() and self._Ents:IsEnemy(ent, true) then
			local data = self:GetTempData(ent)
			if not data.Hit then
				data.Hit = true
				ent:SetBossStatusEffectCooldown(0)
				ent:AddFreeze(EntityRef(player), 30 * num)
			end
		end
	end
end

--平静使用
Skill.CalmOnUse = function(player, compats)
	local self = Skill
	for _,ent in ipairs(Isaac.GetRoomEntities()) do
		if ent:IsActiveEnemy() and self._Ents:IsEnemy(ent, true) then			
			ent:SetBossStatusEffectCooldown(0)
			ent:AddFreeze(EntityRef(player), 300)
		end
	end
	sfx:Play(594, 0.5, 10)
end


return Skill