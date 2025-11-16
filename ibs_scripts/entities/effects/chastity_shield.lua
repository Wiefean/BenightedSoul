--贞洁护盾

local mod = Isaac_BenightedSoul
local IBS_EffectID = mod.IBS_EffectID

local game = Game()
local sfx = SFXManager()

local ChastityShield = mod.IBS_Class.Effect{
	Variant = IBS_EffectID.ChastityShield.Variant,
	SubType = IBS_EffectID.ChastityShield.SubType,
	Name = {zh = '贞洁护盾', en = 'Chastity Shield'}
}

--生成
function ChastityShield:Spawn(pos, vel, timeout, spawner, friendly)
	local effect

	--友好状态改为生成真正的神圣干预
	if friendly then
		effect = Isaac.Spawn(1000, 188, 1, pos, vel, spawner):ToEffect()

		--调整动画方向
		local spr = effect:GetSprite()
		local dir = self._Maths:VectorToDirection(vel:Normalized())
		if dir == Direction.LEFT then 
			effect.Rotation = 180
		elseif dir == Direction.RIGHT then		
			effect.Rotation = 0
		elseif dir == Direction.UP then
			effect.Rotation = -90
		elseif dir == Direction.DOWN then
			effect.Rotation = 90
		end	
	else	
		effect = Isaac.Spawn(1000, self.Variant, 0, pos, vel, spawner):ToEffect()

		--调整动画方向
		local spr = effect:GetSprite()
		local dir = self._Maths:VectorToDirection(vel:Normalized())
		if dir == Direction.LEFT then 
			spr:Play("AppearLeft", true)
			spr.FlipX = false
		elseif dir == Direction.RIGHT then		
			spr:Play("AppearLeft", true)
			spr.FlipX = true
		elseif dir == Direction.UP then
			spr:Play("AppearUp", true)
		elseif dir == Direction.DOWN then
			spr:Play("AppearDown", true)
		end	
	end

	effect.Timeout = timeout
	effect.Parent = spawner
	
	return effect
end

--初始化
function ChastityShield:OnEffectInit(effect)
	effect:GetSprite().Color = Color(1,1,1,0.7,0,0.5,0.7)
	effect.DepthOffset = 11 --使图层处于上层
end
ChastityShield:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, 'OnEffectInit', ChastityShield.Variant)

--更新
function ChastityShield:OnEffectUpdate(effect)
	local spr = effect:GetSprite()

	--循环动画
	if spr:IsFinished('AppearLeft') then
		spr:Play('IdleLeft')
	end
	if spr:IsFinished('AppearUp') then
		spr:Play('IdleUp')
	end
	if spr:IsFinished('AppearDown') then
		spr:Play('IdleDown')
	end


	local READY = effect:IsFrame(3,0)
	
	for _,ent in ipairs(Isaac.GetRoomEntities()) do
		--推走玩家和炸弹
		if (ent:ToPlayer() or ent:ToBomb()) and ent.Position:Distance(effect.Position) < 15 then
			ent:AddVelocity(effect.Velocity)
		end
		
		--眼泪
		if ent:ToTear() and ent.Position:Distance(effect.Position) < 20 then
			local proj = Isaac.Spawn(9,4,0, ent.Position, (effect.Velocity - ent.Velocity):Resized(math.random(20,30)), effect)
			proj:SetColor(Color(1,1,1,1,0,0.5,0.5), -1, 1, false, true)
			ent:Remove()
		end
		
		--激光
		if READY then		
			if ent:ToLaser()
				and (ent.Variant ~= 7) --牵引光束
				and (ent.Parent and ent.Parent:ToPlayer())
			then
				if ent:ToLaser():IsCircleLaser() then
					--圆形
					if ent.Position:Distance(effect.Position) < 20 + ent:ToLaser().Radius then	
						local proj = Isaac.Spawn(9,4,0, effect.Position, (ent.Parent.Position - effect.Position):Resized(math.random(20,30)), effect)
						proj:SetColor(Color(1,1,1,1,0,0.5,0.5), -1, 1, false, true)
					end
				else
					--直线
					local vec = ent:ToLaser():GetEndPoint() - ent.Position
					local vec2 = effect.Position - ent.Position
					local dist = vec2:Length()^2 - (vec:Dot(vec2) / vec:Length())^2
					if dist < 20^2 then
						local proj = Isaac.Spawn(9,4,0, effect.Position, (ent.Parent.Position - effect.Position):Resized(math.random(20,30)), effect)
						proj:SetColor(Color(1,1,1,1,0,0.5,0.5), -1, 1, false, true)
					end
				end
			end
		end
	end	

	--消失
	if effect.Timeout == 0 then
		if spr:IsPlaying('IdleLeft') then
			spr:Play('DisappearLeft', true)
		end
		if spr:IsPlaying('IdleUp') then
			spr:Play('DisappearUp', true)
		end
		if spr:IsPlaying('IdleDown') then
			spr:Play('DisappearDown', true)
		end		
	end
	if spr:IsFinished('DisappearLeft') or spr:IsFinished('DisappearUp') or spr:IsFinished('DisappearDown') then
		effect:Remove()
	end
end
ChastityShield:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, 'OnEffectUpdate', ChastityShield.Variant)


--撞墙伤害
function ChastityShield:OnPlayerGridCollision(player, gridIdx, gridEnt)
	if not gridEnt then return end
	local shouldCheck = false
	
	--不能飞时检测障碍物
	if (not player.CanFly) and gridEnt.CollisionClass == GridCollisionClass.COLLISION_SOLID then
		shouldCheck = true
	end

	--墙
	if gridEnt.CollisionClass == GridCollisionClass.COLLISION_WALL then
		shouldCheck = true
	end

	if shouldCheck then	
		for _,ent in ipairs(Isaac.FindByType(1000, self.Variant, 0)) do
			if ent.Position:Distance(player.Position) < 40 then
				player:TakeDamage(2, 0, EntityRef(ent), 120)
				break
			end
		end
	end
end
ChastityShield:AddCallback(ModCallbacks.MC_PLAYER_GRID_COLLISION, 'OnPlayerGridCollision', 0)


return ChastityShield