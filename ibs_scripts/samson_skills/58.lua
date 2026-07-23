--参孙技能
--倒女祭司

local mod = Isaac_BenightedSoul

local game = Game()
local sfx = SFXManager()

local Skill = mod.IBS_Class.SamsonSkill(58, {
	IsReversed = true,
})


--发射震荡波(没错是从抹大拉复制过来的)
function Skill:FireShockWave(player, compats, vec)
	local ShockWave = mod.IBS_Effect.ShockWave
	local dir = self._Maths:VectorToDirection(vec)
	local offset = vec:Resized(35)
	
	local tearFlags = player.TearFlags
	local dmg = player.Damage
	local spreadNum = math.max(1, math.floor(player.TearRange / 40 - 2)) --传播次数
	local spreadTimeout = math.ceil(math.max(0, 9 - 3 * player.ShotSpeed)) --传播计时	
	local scale = math.max(0.5, player.SpriteScale.X, player.SpriteScale.Y)
	if scale > 7 then scale = 7 end
	
	--突眼增大初始体型和伤害
	if player:HasCollectible(261) then
		scale = scale + 0.4
		dmg = dmg * 3
	end
	
	for i = 0,player:GetMultiShotParams(WeaponType.WEAPON_TEARS):GetNumTears() - 1 do
		local angle = i * math.random(7,14)
		ShockWave:Spawn(player.Position + offset, player, 0, dmg, tearFlags, scale, vec:Rotated(angle*(-1)^i), spreadNum, spreadTimeout, "BMaggy")
	end
	
	--烟雾
	local poof = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF02, 1, player.Position + offset, Vector.Zero, player)				
	poof.SpriteScale = Vector(0.5*scale,0.5*scale)
	poof.Color = Color(0.5,0.5,0.5)
end

--攻击后
Skill.PostAttack = function(player, compats)
	local self = Skill
	local data = self:GetTempData(player)
	data.times = (data.times or 0) + self:GetCardNum(player)

	if data.times >= 5 then
		data.times = 0
		self:FireShockWave(player, compats, self._Players:GetAimingVector(player))
		sfx:Play(SoundEffect.SOUND_BLACK_POOF, 0.5)
		game:ShakeScreen(7)
	end
end


return Skill