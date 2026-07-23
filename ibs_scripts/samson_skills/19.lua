--参孙技能
--月亮

local mod = Isaac_BenightedSoul

local game = Game()
local sfx = SFXManager()

local Skill = mod.IBS_Class.SamsonSkill(19, {
	WrathStateTrans = 0,
	
	CalmCost = 0,
	WrathCost = 1,
})

--颜色
Skill.SwingColor = Color(0.8,0.9,1,1,0,0,1)

--准备攻击
Skill.PreAttack = function(player, compats, params)
	if not params._K19 then
		params._K19 = true
		params.Color = params.Color * Skill.SwingColor
	end
end

--减速
function Skill:AddSlowing(player, ent)
	ent:SetBossStatusEffectCooldown(0)
	ent:AddSlowing(EntityRef(player), 120, 0.5, Color(1,1,1,1,0.3,0.3,0.3))
	if ent:GetSlowingCountdown() < 120 then
		ent:SetSlowingCountdown(120)
	end	
	
	ent:SetBossStatusEffectCooldown(0)
	ent:AddIce(EntityRef(player), 120)
	if ent:GetIceCountdown() < 120 then
		ent:SetIceCountdown(120)
	end		
end

--冻结
function Skill:Freeze(ent)
	ent:AddEntityFlags(EntityFlag.FLAG_ICE)
	ent.HitPoints = 0
	ent:TakeDamage(ent.MaxHitPoints, 0, EntityRef(nil), 0)
end

--攻击
Skill.OnAttack = function(player, compats, targets)
	local self = Skill
	local data = self:GetTempData(player)
	
	local chance = 18 + 2 * player.Luck
	if chance > 100 then chance = 100 end

	for _,ent in ipairs(targets) do
		if self._Ents:IsEnemy(ent) then
			if not ent:IsBoss() and (data.Freeze or math.random(1,100) <= chance) then
				self:Freeze(ent)
			else
				self:AddSlowing(player, ent)
			end
		end
	end
end

--攻击后
Skill.PostAttack = function(player, compats)
	Skill:GetTempData(player).Freeze = nil
end

--平静使用
Skill.CalmOnUse = function(player, compats)
	mod.IBS_Item.Posture:GetTempData(player).AttackDelay = 0 --刷新近战冷却
	Skill:GetTempData(player).Freeze = true
	sfx:Play(496, 1, 10)
end

return Skill