--参孙技能
--力量

local mod = Isaac_BenightedSoul

local game = Game()
local sfx = SFXManager()

local Skill = mod.IBS_Class.SamsonSkill(12, {
	CalmStateTrans = 1,
	WrathStateTrans = 1,
	
	CalmCost = 1,
	WrathCost = 3,
})


--暴怒使用
Skill.WrathOnUse = function(player, compats)
	local effects = player:GetEffects()
	local num = effects:GetCollectibleEffectNum(12)
	if num < 2 then	
		effects:AddCollectibleEffect(12)
	end
end

--属性
function Skill:OnEvalueateCache(player, flag)
	if self:HasCard(player) and flag == CacheFlag.CACHE_SIZE then
		local scale = player.SpriteScale
		player.SpriteScale = Vector(scale.X * 1.1, scale.Y * 1.1)
	end	
end
Skill:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, 'OnEvalueateCache')

return Skill