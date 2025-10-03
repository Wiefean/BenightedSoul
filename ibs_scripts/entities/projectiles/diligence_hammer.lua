--劳锤

local mod = Isaac_BenightedSoul
local IBS_ProjID = mod.IBS_ProjID
local Pickups = mod.IBS_Lib.Pickups

local game = Game()
local sfx = SFXManager()

local DiligenceHammer = mod.IBS_Class.Pickup{
	Variant = IBS_ProjID.DiligenceHammer.Variant,
	SubType = IBS_ProjID.DiligenceHammer.SubType,
	Name = {zh = '劳锤', en = 'Diligence Hammer'}
}

--初始化
function DiligenceHammer:OnProjInit(proj)
	proj:GetSprite():Play("Idle")
	proj.CollisionDamage = 2
end
DiligenceHammer:AddCallback(ModCallbacks.MC_POST_PROJECTILE_INIT, 'OnProjInit', DiligenceHammer.Variant)

--更新
function DiligenceHammer:OnProjUpdate(proj)
	local spr = proj:GetSprite()
	spr.Rotation = spr.Rotation + 4
	
	--根据方向决定是否翻转
	local dir = -1
	dir = self._Maths:VectorToDirection(proj.Velocity:Normalized())

	if dir == Direction.LEFT or dir == Direction.UP then 
		proj.FlipX = true
	else
		proj.FlipX = false
	end		
end
DiligenceHammer:AddCallback(ModCallbacks.MC_POST_PROJECTILE_UPDATE, 'OnProjUpdate', DiligenceHammer.Variant)


--落地释放震荡波
function DiligenceHammer:OnRemove(ent)
	if (ent.Variant ~= DiligenceHammer.Variant or game:GetRoom():GetFrameCount() <= 0) then return end
	local proj = ent:ToProjectile()

	local shockwave = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.SHOCKWAVE, 0, proj.Position, Vector.Zero, proj.SpawnerEntity):ToEffect()
	shockwave:SetRadii(0, 35)
	shockwave:SetTimeout(10)
	shockwave.Parent = proj.SpawnerEntity
	game:ShakeScreen(10)

	--特效
	local effect = Isaac.Spawn(1000, 97, 0, proj.Position, Vector.Zero, proj):ToEffect()
	effect.SpriteScale = Vector(proj.Scale, proj.Scale)
	effect:GetSprite().Color = Color(1,1,0,1)
	sfx:Play(SoundEffect.SOUND_SCYTHE_BREAK, 1, 2, false, 0.5)
end
DiligenceHammer:AddCallback(ModCallbacks.MC_POST_ENTITY_REMOVE, 'OnRemove', EntityType.ENTITY_PROJECTILE)


return DiligenceHammer