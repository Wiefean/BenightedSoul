--参孙技能
--死亡

local mod = Isaac_BenightedSoul
local Swing = mod.IBS_Effect.Swing

local game = Game()
local sfx = SFXManager()

local Skill = mod.IBS_Class.SamsonSkill(14, {	
	CalmCost = 2,
	WrathCost = 2,
})

--生成特效
function Skill:FX(player, target)
	local angle = 90 + (player.Position - target.Position):GetAngleDegrees()
	local offset = (target.Position - player.Position):Resized(40)
	local effect = Swing:Spawn(target.Position - offset, angle, player)
	local spr = effect:GetSprite()
	
	spr.Scale = Vector(0.5,1)
	spr.Color = Color(0,0,0,1)
	
	return effect
end

--攻击
Skill.OnAttack = function(player, compats, targets)
	local self = Skill
	
	local dmg = player.Damage * 0.13
	
	for _,ent in ipairs(Isaac.GetRoomEntities()) do
		if self._Ents:IsEnemy(ent) and ent.Position:Distance(player.Position) <= player.TearRange then
			self:DelayFunction(function()
				if ent:Exists() and not ent:IsDead() then				
					ent:TakeDamage(dmg, 0, EntityRef(player), 0)
					self:FX(player, ent)
				end
			end, math.random(0,6))
		end
	end
end

--平静使用
Skill.CalmOnUse = function(player, compats)
	player:UseCard(14, UseFlag.USE_NOANIM | UseFlag.USE_NOANNOUNCER | UseFlag.USE_MIMIC)
end

--暴怒使用
Skill.WrathOnUse = function(player, compats)
	player:UseCard(14, UseFlag.USE_NOANIM | UseFlag.USE_NOANNOUNCER | UseFlag.USE_MIMIC)
end

return Skill