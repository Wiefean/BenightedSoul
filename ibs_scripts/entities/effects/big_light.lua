--大光柱

local mod = Isaac_BenightedSoul
local IBS_EffectID = mod.IBS_EffectID

local game = Game()
local sfx = SFXManager()

local BigLight = mod.IBS_Class.Effect{
	Variant = IBS_EffectID.BigLight.Variant,
	SubType = IBS_EffectID.BigLight.SubType,
	Name = {zh = '大光柱', en = 'Big Light'}
}

--临时数据
function BigLight:GetLightData(effect)
	local data = self._Ents:GetTempData(effect)
	data.BigLight_Effect = data.BigLight_Effect or {
		HurtPlayer = false,
		FollowEnemy = false,
		FollowPlayer = false,
		Volume = 1,
		Timeout = 135
	}
	
	return data.BigLight_Effect
end

--生成
function BigLight:Spawn(spawner, dmg, scale, hurtPlayer, followEnemy, followPlayer, timeout, pos, volume)
	pos = pos or spawner.Position

	local light = Isaac.Spawn(1000, self.Variant, 0, pos, Vector.Zero, spawner):ToEffect()
	local data = self:GetLightData(light)
	light.CollisionDamage = dmg
	light.Scale = scale
		
	--伤害玩家
	if hurtPlayer then data.HurtPlayer = true end
	
	--跟随敌人
	if followEnemy then data.FollowEnemy = true end

	--跟随玩家
	if followPlayer then data.FollowPlayer = true end

	data.Timeout = timeout or 135
	data.Volume = volume or 1

	return light
end

--初始化
function BigLight:OnInit(effect)
	effect:GetSprite():Play('Appear', true)
	effect.DepthOffset = 70 --使图层处于上层
	
	--光效
	self._Ents:ApplyLight(effect, effect.Scale * 4, Color(1,1,1,3))
end
BigLight:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, 'OnInit', BigLight.Variant)


--逻辑
function BigLight:OnUpdate(effect)
	local data = self._Ents:GetTempData(effect).BigLight_Effect

	if data then
		local game = Game()
		local room = game:GetRoom()
		local spr = effect:GetSprite()
		
		spr.Scale = Vector(effect.Scale, effect.Scale) --调整贴图大小
		
		--出现音效
		if spr:IsEventTriggered("sound") then
			sfx:Play(SoundEffect.SOUND_DOGMA_LIGHT_APPEAR, 1 * data.Volume, 30, false, 0.7)
		end

		--切换状态至静止
		if spr:IsFinished("Appear") then 
			spr:Play("Idle", true)
			
			--爆炸
			game:BombExplosionEffects(effect.Position, 100, TearFlags.TEAR_NORMAL, Color(1,1,1,0.5,0.5,0.5,0.5), self._Ents:IsSpawnerPlayer(effect), effect.Scale / 1.5, true, data.HurtPlayer, DamageFlag.DAMAGE_EXPLOSION | DamageFlag.DAMAGE_IGNORE_ARMOR)
		end

		if spr:IsPlaying("Idle") then
			sfx:Play(SoundEffect.SOUND_HAND_LASERS, 0.5 * data.Volume, 9, false, 2, 9)
			
			--对敌人造成伤害
			for _,ent in pairs(Isaac.FindInRadius(effect.Position, effect.Scale * 20, EntityPartition.ENEMY)) do
				if self._Ents:IsEnemy(ent, true) then
					ent:TakeDamage(effect.CollisionDamage, 0, EntityRef(effect), 1)
				end
			end
			
			--清除敌弹
			for _,ent in ipairs(Isaac.FindInRadius(effect.Position, effect.Scale * 20 + 10, EntityPartition.BULLET)) do
				local proj = ent:ToProjectile()
				if proj and not proj:HasProjectileFlags(ProjectileFlags.CANT_HIT_PLAYER) then
					proj:Die()
				end	
			end
			
			--摧毁障碍物
			for gridIdx,gridEnt in pairs(self._Finds:GridEntInRadius(effect.Position, effect.Scale * 30)) do
				room:DestroyGrid(gridIdx, true)
			end
			
			--对玩家造成伤害
			if data.HurtPlayer then
				for _,ent in pairs(Isaac.FindInRadius(effect.Position, effect.Scale * 15, EntityPartition.PLAYER)) do
					local player = ent:ToPlayer()
					player:TakeDamage(2, 0, EntityRef(effect), 120)
				end
			end			
			
			--追踪
			local target = nil
			if data.FollowEnemy then
				target = self._Finds:ClosestEnemy(effect.Position)
			elseif data.FollowPlayer then
				target = self._Finds:ClosestPlayer(effect.Position)	
			end
			if target ~= nil then 
				effect.Position = effect.Position + (target.Position - effect.Position):Resized(5.6)
			end
			
			
			if data.Timeout > 0 then
				data.Timeout = data.Timeout - 1
			else
				spr:Play("Disappear", true)
			end
		end
		
		if spr:IsFinished("Disappear") then
			effect:Remove()
		end	
	else
		effect:Remove()
	end
end
BigLight:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, 'OnUpdate', BigLight.Variant)



return BigLight