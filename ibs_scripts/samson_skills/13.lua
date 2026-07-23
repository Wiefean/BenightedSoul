--参孙技能
--倒吊人

local mod = Isaac_BenightedSoul

local game = Game()
local sfx = SFXManager()

local Skill = mod.IBS_Class.SamsonSkill(13, {
	WrathStateTrans = 1,
	
	CalmCost = 0,
	WrathCost = 0,
})

--装饰
function Skill:ApplyFlyCostume(player)
	if self:HasCard(player) then
		local effect = player:GetEffects()
		if not effect:HasCollectibleEffect(20) then
			effect:AddCollectibleEffect(20, true)
		end	
	end	
end
Skill:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, 'ApplyFlyCostume')

--切换至最后一张牌
function Skill:SwitchToLast(player)
	local data = self._Players:GetData(player).Posture
	if data then
		for i = 5,1,-1 do
			local id = data.Cards[i]
			if id and id > 0 then		
				data.DoingSelection = i
				break
			end
		end
		data.NextSelection = 1
	end
end

--平静使用
Skill.CalmOnUse = function(player, compats)
	Skill:SwitchToLast(player)
	sfx:Play(594, 0.5, 10)
end

--暴怒使用
Skill.WrathOnUse = function(player, compats)
	Skill:SwitchToLast(player)
end

return Skill