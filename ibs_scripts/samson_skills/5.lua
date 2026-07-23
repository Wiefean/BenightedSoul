--参孙技能
--皇帝

local mod = Isaac_BenightedSoul

local game = Game()
local sfx = SFXManager()

local Skill = mod.IBS_Class.SamsonSkill(5, {
	WrathStateTrans = 0,
	
	CalmCost = 3,
	WrathCost = 1,
})

--颜色
Skill.SwingColor = Color(1,1,0.1,1)

--添加护盾
function Skill:Shield(player)
	local effects = player:GetEffects()
	local shield = effects:GetCollectibleEffect(CollectibleType.COLLECTIBLE_BOOK_OF_SHADOWS)
	if not shield or shield.Cooldown <= 0 then
		if not shield then		
			effects:AddCollectibleEffect(CollectibleType.COLLECTIBLE_BOOK_OF_SHADOWS)
			shield = effects:GetCollectibleEffect(CollectibleType.COLLECTIBLE_BOOK_OF_SHADOWS)
		end
		shield.Cooldown = 30 * Skill:GetCardNum(player)
	end
end

--准备攻击
Skill.PreAttack = function(player, compats, params)
	params.AttackDelay = math.max(1, math.floor(params.AttackDelay * 1.3))
	
	if not params._K5 then
		params._K5 = true
		params.Color = params.Color * Skill.SwingColor
	end
end

--攻击
Skill.OnAttack = function(player, compats, targets)
	local self = Skill
	
	for _,ent in ipairs(targets) do
		if ent:IsActiveEnemy() and self._Ents:IsEnemy(ent, true) then
			self:Shield(player)
			break
		end
	end
end

--平静使用
Skill.CalmOnUse = function(player, compats)
	Skill._Players:AddShield(player, 150)
	sfx:Play(594, 0.5, 10)
end


return Skill