--参孙技能
--恋人

local mod = Isaac_BenightedSoul

local game = Game()
local sfx = SFXManager()

local Skill = mod.IBS_Class.SamsonSkill(7, {
	CalmStateTrans = 1,
	WrathStateTrans = 1,
	
	CalmCost = 1,
	WrathCost = 3,
})

--颜色
Skill.SwingColor = Color(1,0.4,0.4,1)

--准备攻击
Skill.PreAttack = function(player, compats, params)
	params.Num = params.Num + 1
	params.AngleBetween = 90
	
	if not params._K7 then
		params._K7 = true
		params.Color = params.Color * Skill.SwingColor
	end
end

--攻击
Skill.OnAttack = function(player, compats, targets)
	local self = Skill
	
	local chance = 6 + player.Luck
	if chance < 1 then chance = 1 end
	if chance > 12 then chance = 12 end
	
	for _,ent in ipairs(targets) do
		if self._Ents:IsEnemy(ent) then
			local data = self:GetTempData(ent)
			
			if data.FrameCount then
				if math.random(1,100) <= chance then
					local pickup = Isaac.Spawn(5,10,2, ent.Position, 2*RandomVector(), player):ToPickup()
					pickup.Wait = 10
					pickup.Timeout = 60
				end
			end
			
			data.FrameCount = 1
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

--暴怒使用
Skill.WrathOnUse = function(player, compats)
	local pickup = Isaac.Spawn(5,10,0, player.Position, 6*RandomVector(), player):ToPickup()
	pickup.Wait = 10
	pickup.Timeout = 60
end


return Skill