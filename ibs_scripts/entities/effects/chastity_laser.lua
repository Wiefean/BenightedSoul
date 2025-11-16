--贞洁激光

local mod = Isaac_BenightedSoul
local IBS_EffectID = mod.IBS_EffectID

local game = Game()
local sfx = SFXManager()

local ChastityLaser = mod.IBS_Class.Effect{
	Variant = IBS_EffectID.ChastityLaser.Variant,
	SubType = IBS_EffectID.ChastityLaser.SubType,
	Name = {zh = '贞洁激光', en = 'Chastity Laser'}
}

--生成
function ChastityLaser:Spawn(pos, vel, timeout, spawner)
	local effect = Isaac.Spawn(1000, self.Variant, 0, pos, vel, spawner):ToEffect()
	effect.Timeout = timeout
	effect.Parent = spawner
	return effect
end

--初始化
function ChastityLaser:OnEffectInit(effect)
	local spr = effect:GetSprite()
	spr:Play('Start', true)
	spr.Rotation = (effect.Velocity):Normalized():GetAngleDegrees() + 90
	spr.Scale = Vector(0.75,0.75)
	spr.Color = Color(1,1,1,0.7,0,0.5,0.5)
	effect.DepthOffset = 10 --使图层处于上层
end
ChastityLaser:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, 'OnEffectInit', ChastityLaser.Variant)

--更新
function ChastityLaser:OnEffectUpdate(effect)
	local spr = effect:GetSprite()

	spr.Rotation = (effect.Velocity):Normalized():GetAngleDegrees() + 90

	if spr:IsFinished('Start') then
		spr:Play('Idle')
	end
	
	if not effect.Parent or effect.Timeout == 0 then
		spr:Play('End')
	end

	if spr:IsPlaying('Idle') then
		local friendly = false
		local ent = effect.Parent
		
		--主人为玩家
		if ent:ToPlayer() then
			friendly = true
		end
		
		--友好状态的敌人
		if ent:IsEnemy() and ent:HasEntityFlags(EntityFlag.FLAG_FRIENDLY) then
			friendly = true
		end
		
		if friendly then
		
			--对敌人造成伤害
			for _,ent in ipairs(Isaac.GetRoomEntities()) do
				if self._Ents:IsEnemy(ent) and ent.Position:Distance(effect.Position) <= 8 + ent.Size then
					ent:TakeDamage(2, 0, EntityRef(deligence), 0)
				end
			end	
		else
			--对玩家造成伤害
			for _,ent in ipairs(Isaac.FindInRadius(effect.Position, 10, EntityPartition.PLAYER)) do
				if ent:ToPlayer() and not ent:ToPlayer():IsCoopGhost() then
					ent:TakeDamage(1, 0, EntityRef(effect), 60)
				end
			end
		end
	end

	if spr:IsFinished('End') then
		effect:Remove()
	end
end
ChastityLaser:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, 'OnEffectUpdate', ChastityLaser.Variant)


return ChastityLaser