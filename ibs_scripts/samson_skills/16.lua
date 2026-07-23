--参孙技能
--恶魔

local mod = Isaac_BenightedSoul

local game = Game()
local sfx = SFXManager()

local Skill = mod.IBS_Class.SamsonSkill(16, {
	CalmStateTrans = 1,
	WrathStateTrans = 1,
	
	CalmCost = 1,
	WrathCost = 2,
})

--颜色
Skill.SwingColor = Color(0.6,0,0,1)

--准备攻击
Skill.PreAttack = function(player, compats, params)
	if not params._K16 and not compats.Brimstone then
		params._K16 = true
		params.AttackDelay = math.max(1, math.floor(params.AttackDelay * 1.5))
		params.Color = params.Color * Skill.SwingColor
	end
end

--攻击
Skill.OnAttack = function(player, compats, targets)
	if not compats.Brimstone then
		local self = Skill
		
		for _,ent in ipairs(targets) do
			if self._Ents:IsEnemy(ent) then
				ent:SetBossStatusEffectCooldown(0)
				ent:AddBrimstoneMark(EntityRef(player), 180)
				if ent:GetBrimstoneMarkCountdown() < 180 then
					ent:SetBrimstoneMarkCountdown(180)
				end	
			end
		end
	end
end

--增伤
function Skill:OnTakeDMG(ent, dmg, flag, source, cd)
	if dmg <= 0 then return end
	if self._Ents:IsEnemy(ent, true) and ent:GetBrimstoneMarkCountdown() > 0 and self:AnyHasCard() then	
		return {Damage = dmg * 1.666}
	end
end
Skill:AddPriorityCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, -666, 'OnTakeDMG')

--暴怒使用
Skill.WrathOnUse = function(player, compats)
	player:GetEffects():AddCollectibleEffect(34)
end

return Skill