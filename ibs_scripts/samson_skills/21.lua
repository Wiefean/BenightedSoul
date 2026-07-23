--参孙技能
--审判

local mod = Isaac_BenightedSoul

local game = Game()
local sfx = SFXManager()

local Skill = mod.IBS_Class.SamsonSkill(21, {
	CalmStateTrans = 1,
	WrathStateTrans = 0,
	
	CalmCost = 0,
	WrathCost = 0,
})

--颜色
Skill.SwingColor = Color(0.7,0.7,0,1)

--准备攻击
Skill.PreAttack = function(player, compats, params)
	if not params._K21 then
		params._K21 = true
		params.Damage = params.Damage * 0.5
		params.Color = params.Color * Skill.SwingColor
	end
end

--攻击
Skill.OnAttack = function(player, compats, targets, effect, vec, params)
	local self = Skill
	for _,ent in ipairs(targets) do
		if ent:IsActiveEnemy() and self._Ents:IsEnemy(ent, true) then
			local data = self:GetTempData(ent)
			
			if not data.FrameCount or data.FrameCount <= 0 then			
				data.FrameCount = 1
				
				if ent.HitPoints < 0.2 * ent.MaxHitPoints then
					if self._Ents:LoseHP(ent, ent.MaxHitPoints, true) then					
						Isaac.Spawn(1000, 19, 0, ent.Position, Vector.Zero, player)
					end
				else
					self._Ents:LoseHP(ent, params.Damage, true)
				end
			end
		end
	end
end

function Skill:OnNpcUpdate(npc)
	local data = self:GetTempData(npc, true)
	
	if data and data.FrameCount and data.FrameCount > 0 then
		data.FrameCount = data.FrameCount - 1
		if data.FrameCount <= 0 then
			data.FrameCount = nil
		end
	end
end
Skill:AddCallback(ModCallbacks.MC_NPC_UPDATE, "OnNpcUpdate")

--平静使用
Skill.CalmOnUse = function(player, compats)
	local Posture = mod.IBS_Item and mod.IBS_Item.Posture
	if Posture then
		Posture:SetCD(player, 120)
	end	
end

--暴怒使用
Skill.WrathOnUse = function(player, compats)
	local Posture = mod.IBS_Item and mod.IBS_Item.Posture
	if Posture then
		Posture:SetCD(player, 120)
	end	
end

return Skill