--参孙技能
--节制

local mod = Isaac_BenightedSoul

local game = Game()
local sfx = SFXManager()

local Skill = mod.IBS_Class.SamsonSkill(15, {
	WrathStateTrans = 0,

	CalmCost = 0,
	WrathCost = 0,
})

--准备攻击
Skill.PreAttack = function(player, compats, params)
	local data = Skill:GetTempData(player)
	
	if not params._K15 and data.Times and data.Times > 0 then	
		params._K15 = true
		params.Damage = params.Damage * (2 ^ data.Times)
		params.Size = params.Size * (1.25 ^ data.Times)
	end
	
	data.Wait = 0
	data.Times = 0
end

function Skill:OnPlayerUpdate(player)
	if self:HasCard(player) then
		local data = self:GetTempData(player)
		data.Wait = (data.Wait or 0) + 1
		data.Times = data.Times or 0
		if data.Wait > 180 then
			data.Times = self:GetCardNum(player)
			data.Wait = 0
		end
	end
end
Skill:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, "OnPlayerUpdate", 0)

--平静使用
Skill.CalmOnUse = function(player, compats, slot)
	local Posture = mod.IBS_Item and mod.IBS_Item.Posture
	if Posture then
		Posture:SetCD(player, 240)
		
		Skill:DelayFunction(function()
			Posture:Charge(player, slot, 1)
		end, 1)
	end	
	sfx:Play(594, 0.5, 10)
end

--暴怒使用
Skill.WrathOnUse = function(player, compats, slot)
	local Posture = mod.IBS_Item and mod.IBS_Item.Posture
	if Posture then
		Posture:SetCD(player, 180)
		
		Skill:DelayFunction(function()
			Posture:Charge(player, slot, 1)
		end, 1)
	end	
end

return Skill