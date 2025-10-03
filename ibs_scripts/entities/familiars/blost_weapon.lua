--箱子武器

local mod = Isaac_BenightedSoul
local IBS_FamiliarID = mod.IBS_FamiliarID

local game = Game()
local sfx = SFXManager()
local config = Isaac.GetItemConfig()

local BLostWeapon = mod.IBS_Class.Familiar{
	Variant = IBS_FamiliarID.BLostWeapon.Variant,
	SubType = IBS_FamiliarID.BLostWeapon.SubType,
	Name = {zh = '箱子武器', en = 'Chest Weapon'}
}

--获取数据
function BLostWeapon:GetData(familiar)
	local data = self._Ents:GetTempData(familiar)
	
	if not data.BLostWeapon then
		local spr = Sprite()
		local bar = Sprite('gfx/ibs/ui/chargebar.anm2')
		bar:SetFrame("Disappear", 99)	
	
		data.BLostWeapon = {
			Directional = false,
			OverHeat = false,
			CD = 0,
			Wait = 0,
			Charge = 0,
			ChargeBar = bar,
			CachedLasers = {},
		}
	end
		
	return data.BLostWeapon
end

--获取激光数据
function BLostWeapon:GetLaserData(laser)
	local data = self._Ents:GetTempData(laser)
	data.BLostWeaponLaser = data.BLostWeaponLaser or {Player = nil}
	return data.BLostWeaponLaser
end


--信息
BLostWeapon.ChestInfo = {
	[BLostWeapon.SubType.Common] = {
		MaxCharge = 45,
		ShotSpeedMult = 3,
		AutoTargetRadius = 150,
		Directional = true,
		OffestUp = Vector(0,-15),
		OffestDown = Vector(0,-15),
		OffestLeft = Vector(0,-25),
		OffestRight = Vector(0,-25),
	},
	[BLostWeapon.SubType.Stone] = {
		MaxCharge = 90,
		ShotSpeedMult = 5,
		MaxShotSpeed = 20,
		Directional = true,
		OffestUp = Vector(0,-15),
		OffestDown = Vector(0,-15),
		OffestLeft = Vector(0,-25),
		OffestRight = Vector(0,-25),
	},
	[BLostWeapon.SubType.Spike] = {
		MaxCharge = 75,
		AutoTargetRadius = 160,
		MaxShotSpeed = 15,
		Directional = true,
		DirectionalShootingVelMult = 2,
		DirectionalIdleVelMult = 1,
		OffestUp = Vector(0,-15),
		OffestDown = Vector(0,-15),
		OffestLeft = Vector(0,-25),
		OffestRight = Vector(0,-25),
	},
	[BLostWeapon.SubType.Eternal] = {
		MaxCharge = 119,
		ClearChargeInNewRoom = true,
		ShotSpeedMult = 2,
		MaxShotSpeed = 20,
		Directional = true,
		OffestUp = Vector(0,-15),
		OffestDown = Vector(0,-15),
		OffestLeft = Vector(0,-25),
		OffestRight = Vector(0,-25),
	},
	[BLostWeapon.SubType.Old] = {
		MaxCharge = 160,
		ShotSpeedMult = 4,
		AutoTargetRadius = 200,
		Directional = true,
		OffestUp = Vector(0,-15),
		OffestDown = Vector(0,-15),
		OffestLeft = Vector(0,-25),
		OffestRight = Vector(0,-25),
	},	
	[BLostWeapon.SubType.Wooden] = {
		MaxCharge = 60,
		MaxShotSpeed = 12,
		Directional = true,
		OffestUp = Vector(0,-15),
		OffestDown = Vector(0,-15),
		OffestLeft = Vector(0,-25),
		OffestRight = Vector(0,-25),
	},	
	[BLostWeapon.SubType.Haunted] = {
		MaxCharge = 60,
		ShotSpeedMult = 2,
		MaxShotSpeed = 15,
		AutoTargetRadius = 150,
		Directional = true,
		OffestUp = Vector(0,-15),
		OffestDown = Vector(0,-15),
		OffestLeft = Vector(0,-25),
		OffestRight = Vector(0,-25),
	},	
	[BLostWeapon.SubType.Golden] = {
		MaxCharge = 100,
		ClearChargeInNewRoom = true,
		AutoTargetRadius = 200,
		Directional = true,
		OffestUp = Vector(0,-15),
		OffestDown = Vector(0,-15),
		OffestLeft = Vector(0,-25),
		OffestRight = Vector(0,-25),
	},
	[BLostWeapon.SubType.Red] = {
		MaxCharge = 66,
		Directional = true,
		OffestUp = Vector(0,-10),
		OffestDown = Vector(0,-20),
		OffestLeft = Vector(10,-25),
		OffestRight = Vector(-10,-25),
	},

}

--查找武器
function BLostWeapon:FindWeapons(player, subType)
	if player:GetPlayerType() ~= mod.IBS_PlayerID.BLost then return {} end
	local result = {}
	
	for _,ent in pairs(Isaac.FindByType(3, self.Variant, subType)) do
		local familiar = ent:ToFamiliar()
		if familiar and self._Ents:IsTheSame(familiar.Player, player) then
			table.insert(result, familiar)
		end	
	end
	
	return result
end

--获取每帧蓄力量
function BLostWeapon:GetFrameCharge(playerFireDelay)
	local standard = (30/11)+0.35 --约为表表罗初始射速
	local tears = 30 / (playerFireDelay + 1)
	local charge = (tears/standard)
	return math.max(0.75, charge)
end 

--是否启用高射速模式(射速达到设定值时启用)
function BLostWeapon:IsHighTearsMode(playerFireDelay)
	local tears = 30 / (playerFireDelay + 1)
	return (tears >= 10)
end 

--获取弹速(简易计算)
function BLostWeapon:GetShotSpeed(playerShotSpeed, subType)
	local info = self.ChestInfo[subType]
	return math.min(info.MaxShotSpeed or 40, 5 * playerShotSpeed * (info.ShotSpeedMult or 1))
end 

--初始化
function BLostWeapon:OnFamiliarInit(familiar)
	local spr = familiar:GetSprite()
	local subType = familiar.SubType
	local info = self.ChestInfo[subType] if not info then return end
	local data = self:GetData(familiar)
	
	--方向操作类型
	if info.Directional then
		data.Directional = true
	end
	
	--永恒箱光效
	if subType == self.SubType.Eternal then	
		self._Ents:ApplyLight(familiar, 1, Color(1,1,1,2))
	end
end
BLostWeapon:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, 'OnFamiliarInit', BLostWeapon.Variant)


--游戏更新
function BLostWeapon:OnUpdate()
	for i = 0, game:GetNumPlayers() - 1 do
		local player = Isaac.GetPlayer(i)
		local weapons = self:FindWeapons(player)
		local shouldSeparate = (#weapons>1)
		local index = 0
		
		for _,familiar in ipairs(weapons) do
			local subType = familiar.SubType
			local info = self.ChestInfo[subType] if not info then return end
			local charge = self:GetFrameCharge(player.MaxFireDelay)
			local HIGH = self:IsHighTearsMode(player.MaxFireDelay)
			local data = self:GetData(familiar)
			local spr = familiar:GetSprite()
			
			local vec = self._Players:GetAimingVector(player)
			local isShooting = self._Players:IsShooting(player)
			local dir = -1
			local offset = vec:Resized(35)
			local shotSpeed = self:GetShotSpeed(player.ShotSpeed, subType)

			--方向操作类型
			if info.Directional and data.Directional then
				index = index + 1
				--攻击动画
				if isShooting then
					familiar.DepthOffset = -100
					dir = self._Maths:VectorToDirection(vec)
					
					if dir == Direction.UP then
						spr:SetFrame("Up", 0)
						offset = offset + info.OffestUp
					elseif dir == Direction.DOWN then
						spr:SetFrame("Down", 0)
						offset = offset + info.OffestDown
					elseif dir == Direction.LEFT then		
						spr:SetFrame("Left", 0)
						offset = offset + info.OffestLeft
					elseif dir == Direction.RIGHT then			
						spr:SetFrame("Right", 0)
						offset = offset + info.OffestRight
					end			
					
					--多武器位置修正
					if shouldSeparate then
						local offset2 = Vector(0,15)
						
						if dir == Direction.UP then
							offset2 = Vector(0,-15)
						elseif dir == Direction.LEFT then
							offset2 = Vector(-15,0)
						elseif dir == Direction.RIGHT then
							offset2 = Vector(15,0)
						end
					
						if index ~= 1 then
							offset = offset + offset2
						else
							offset = offset - offset2
						end
					end
					
					familiar:FollowPosition(player.Position + offset)
					familiar.Velocity = familiar.Velocity * (info.DirectionalShootingVelMult or 10)
				else --待机动画
					spr:SetFrame("Down", 0)
					vec = player.Velocity
					familiar:FollowPosition(player.Position + Vector(0,-25))
					familiar.Velocity = familiar.Velocity * (info.DirectionalIdleVelMult or 3)
					if subType ~= self.SubType.Spike and familiar.Position:Distance(player.Position) <= 40 then
						familiar.Position = player.Position + Vector(0,-25)
					end
					dir = (vec:Length() > 1 and self._Maths:VectorToDirection(vec:Normalized())) or Direction.DOWN
					
					if dir == Direction.UP then
						familiar.DepthOffset = 100
					else				
						familiar.DepthOffset = -100
					end
				end			
			end
			
			--普通箱子
			if subType == self.SubType.Common then
				data.Directional = true
				
				--高射速模式
				if HIGH then
					if isShooting and familiar:IsFrame(3,0) then
						data.Charge = 0
						local vel = vec:Resized(shotSpeed)
						local target = self._Finds:ClosestEnemy(familiar.Position)
						
						--自瞄
						if target and target.Position:Distance(familiar.Position) <= info.AutoTargetRadius then
							vel = (target.Position - familiar.Position):Resized(shotSpeed)
						end
						
						self._Players:FireTears(player, function(tear)
							if tear.Variant ~= 43 then
								tear:ChangeVariant(43)
							end
							local scale = self._Maths:TearDamageToScale(tear.CollisionDamage)
							tear.SpriteScale = Vector(scale, scale)
							tear:AddTearFlags(TearFlags.TEAR_SPECTRAL | TearFlags.TEAR_QUADSPLIT | TearFlags.TEAR_PERSISTENT)
							tear.CollisionDamage = math.max(1, player.Damage)
							tear.Color = Color(1,1,1,0.5)			
						end, familiar.Position + Vector(0,15) - offset:Resized(20), vel, false, false, false, familiar, 1)
						
						--硬核后座
						familiar.Position = familiar.Position - 0.1*offset
						
						sfx:Play(830, 1, 2, false, 3)
					end	
				else
					if isShooting then
						data.Charge = data.Charge + charge
						data.Wait = 0
						if data.Charge >= info.MaxCharge then
							data.Charge = 0
							local vel = vec:Resized(shotSpeed)
							local target = self._Finds:ClosestEnemy(familiar.Position)
							
							--自瞄
							if target and target.Position:Distance(familiar.Position) <= info.AutoTargetRadius then
								vel = (target.Position - familiar.Position - Vector(0,25)):Resized(shotSpeed)
							end
							
							self._Players:FireTears(player, function(tear)
								if tear.Variant ~= 43 then
									tear:ChangeVariant(43)
								end
								local scale = self._Maths:TearDamageToScale(tear.CollisionDamage)
								tear.SpriteScale = Vector(scale, scale)
								tear:AddTearFlags(TearFlags.TEAR_SPECTRAL | TearFlags.TEAR_QUADSPLIT | TearFlags.TEAR_PERSISTENT)
								tear.CollisionDamage = math.max(10, player.Damage * 3)
								tear.FallingAcceleration = 0.08
								tear.Color = Color(1,1,1,0.5)			
							end, familiar.Position + Vector(0,15) - offset:Resized(20), vel, false, false, false, familiar, 3)
							
							--硬核后座
							familiar.Position = familiar.Position - 0.3*offset
							
							sfx:Play(826)
						end
					else
						if data.Wait < 20 then
							data.Wait = data.Wait + 1
						else		
							data.Charge = math.max(0, data.Charge - 1)
						end
					end
				end
			elseif subType == self.SubType.Stone then --石箱
				data.Directional = true
				
				--高射速模式
				if HIGH then
					if isShooting and familiar:IsFrame(5,0) then
						data.Charge = 0

						for i = 0,6+player:GetMultiShotParams(WeaponType.WEAPON_TEARS):GetNumTears() do
							local angle = i * math.random(2,3)
							local tear = player:FireTear(familiar.Position + Vector(0,15) - offset:Resized(10), vec:Rotated(angle*(-1)^i):Resized(shotSpeed), false, false, false, familiar, 1)
							tear:AddTearFlags(TearFlags.TEAR_SPECTRAL)
							tear.CollisionDamage = math.max(1, player.Damage)
							tear.FallingAcceleration = 0.5
							tear.Color = Color(1,1,1,0.5)
						end
						
						--硬核后座
						familiar.Position = familiar.Position - 0.1*offset
						
						sfx:Play(827, 1, 2, false, 2)
					end
				else
					if isShooting then
						data.Charge = data.Charge + charge
						data.Wait = 0
						if data.Charge >= info.MaxCharge then
							data.Charge = 0
			
							for i = 0,6+player:GetMultiShotParams(WeaponType.WEAPON_TEARS):GetNumTears() do
								local angle = i * math.random(2,3)
								local tear = player:FireTear(familiar.Position + Vector(0,15) - offset:Resized(10), vec:Rotated(angle*(-1)^i):Resized(shotSpeed), true, false, false, familiar, 1)
								tear:AddTearFlags(TearFlags.TEAR_SPECTRAL)
								tear.CollisionDamage = math.max(3.5, player.Damage)
								tear.FallingAcceleration = 1
								tear.Color = Color(1,1,1,0.5)
							end
							
							--二次攻击
							self:DelayFunction(function()
								if familiar and familiar:Exists() and not familiar:IsDead() then
									for i = 0,6+player:GetMultiShotParams(WeaponType.WEAPON_TEARS):GetNumTears() do
										local angle = i * math.random(2,3)
										local tear = player:FireTear(familiar.Position + Vector(0,15) - offset:Resized(10), vec:Rotated(angle*(-1)^i):Resized(shotSpeed), true, false, false, familiar, 1)
										tear:AddTearFlags(TearFlags.TEAR_SPECTRAL)
										tear.CollisionDamage = math.max(3.5, player.Damage)
										tear.FallingAcceleration = 1
										tear.Color = Color(1,1,1,0.5)
									end
									familiar.Position = familiar.Position - 0.5*offset									
									sfx:Play(827, 2, 2, false, 0.6)
									game:ShakeScreen(6)
								end
							end, 6)
							
							--震荡波
							local wave = Isaac.Spawn(1000, EffectVariant.SHOCKWAVE, 0, familiar.Position + Vector(0,25) + offset:Resized(20), Vector.Zero, familiar):ToEffect()
							wave.Parent = player
							wave:SetTimeout(1)
							wave:SetRadii(6,6)
							
							local poof = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF02, 1, familiar.Position + Vector(0,25) + offset:Resized(30), Vector.Zero, player)				
							poof.SpriteScale = Vector(0.5,0.5)
							
							--硬核后座
							familiar.Position = familiar.Position - 0.5*offset
							
							sfx:Play(827, 2, 2, false, 0.6)
							game:ShakeScreen(6)
						end
					else
						if data.Wait < 20 then
							data.Wait = data.Wait + 1
						else		
							data.Charge = math.max(0, data.Charge - 1)
						end
					end
				end
			elseif subType == self.SubType.Spike then --刺箱
				--翻转
				do
					local dir = self._Maths:VectorToDirection(familiar.Velocity:Normalized())
					if dir == Direction.UP or dir == Direction.LEFT then
						spr.FlipX = true
						spr.FlipY = true
					else
						spr.FlipX = false
						spr.FlipY = false
					end
					spr.Rotation = familiar.Velocity:GetAngleDegrees()
				end
			
				if isShooting and data.Directional then
					data.Charge = data.Charge + charge
					data.Wait = 0
					
					--高射速模式
					if HIGH then
						data.Charge = info.MaxCharge
					end
					
					if data.Charge >= info.MaxCharge then
						data.Directional = false				
						data.FlyingA = vec:Resized(1)
					end
				else
					if data.Wait < 10 then
						data.Wait = data.Wait + 1
					else
						if data.Charge > 0 then
							data.Charge = data.Charge - 2
						else
							data.Directional = true
						end
					end
				end	
				
				--在房间外立刻回手
				if not game:GetRoom():IsPositionInRoom(familiar.Position, 1) then
					data.Directional = true
				end
				
				--飞行
				if not data.Directional then
					local dir = self._Maths:VectorToDirection(familiar.Velocity:Normalized())
					local target = self._Finds:ClosestEnemy(familiar.Position)
					
					if data.FlyingA then
						familiar.Velocity = familiar.Velocity + data.FlyingA
					end

					--自瞄
					local target = self._Finds:ClosestEnemy(familiar.Position)
					if target and target.Position:Distance(familiar.Position) <= info.AutoTargetRadius then
						local vec = (target.Position - familiar.Position)
						if data.CD > 0 then
							data.CD = data.CD - 1
						else
							data.CD = (HIGH and 1) or math.max(1, math.ceil(player.MaxFireDelay / 2))
							self._Players:FireTears(player, function(tear)
								tear:AddTearFlags(TearFlags.TEAR_SPECTRAL | TearFlags.TEAR_HOMING)
								tear.CollisionDamage = math.max(2, player.Damage * 0.5)
								tear.Color = Color(1,1,1,0.5)			
							end, familiar.Position, vec:Resized(shotSpeed), true, false, false, familiar, 0.5)
						end
						data.FlyingA = vec:Resized(1)
					end

					--碰撞判定
					for _,ent in ipairs(Isaac.GetRoomEntities()) do
						if self._Ents:AreColliding(ent, familiar) then
							if self._Ents:IsEnemy(ent) then
								target:TakeDamage(math.max(3, player.Damage * 0.5), 0, EntityRef(familiar), 0)
							elseif ent:ToProjectile() then
								if not ent:ToProjectile():HasProjectileFlags(ProjectileFlags.CANT_HIT_PLAYER) then
									ent:Die()
								end	
							end
						end
					end

					--攻击动画
					spr:SetFrame(1)
				end
			elseif subType == self.SubType.Eternal then --永恒箱
				data.Directional = true
				
				--高射速模式
				if HIGH then
					--蓄力动画固定为满
					local percent = 100
					if dir == Direction.UP then
						spr:SetOverlayFrame("Up_Overlay", percent)
					elseif dir == Direction.DOWN then
						spr:SetOverlayFrame("Down_Overlay", percent)
					elseif dir == Direction.LEFT then		
						spr:SetOverlayFrame("Left_Overlay", percent)
					elseif dir == Direction.RIGHT then			
						spr:SetOverlayFrame("Right_Overlay", percent)
					end				
				
					if isShooting and familiar:IsFrame(12,0) then

						--天 堂 之 小 拳
						for i = 0,6+player:GetMultiShotParams(WeaponType.WEAPON_TEARS):GetNumTears() do
							local angle = i * 7
							local tear = player:FireTear(familiar.Position + Vector(0,40), Vector.FromAngle(vec:GetAngleDegrees() + angle*(-1)^i):Resized(shotSpeed), false, false, false, familiar, 1)
							tear:AddTearFlags(TearFlags.TEAR_PIERCING | TearFlags.TEAR_BOUNCE | TearFlags.TEAR_LIGHT_FROM_HEAVEN)
							tear.FallingSpeed = 0
							tear.FallingAcceleration = -0.1	
							tear.Height = -15
							tear.CollisionDamage = math.max(1, player.Damage)
							tear.Color = Color(1,1,1,0.5,1,1,1)
							tear:Update()
							self:DelayFunction(function()
								tear:Die()
							end, 5*math.floor(math.max(6, player.TearRange/40)))
						end
						
						--硬核后座
						familiar.Position = familiar.Position - 0.25*offset
						
						sfx:Play(832, 0.5, 2, false, 3)
					end				
				else
					--蓄力动画
					local percent = math.floor(100*(data.Charge)/info.MaxCharge)
					if dir == Direction.UP then
						spr:SetOverlayFrame("Up_Overlay", percent)
					elseif dir == Direction.DOWN then
						spr:SetOverlayFrame("Down_Overlay", percent)
					elseif dir == Direction.LEFT then		
						spr:SetOverlayFrame("Left_Overlay", percent)
					elseif dir == Direction.RIGHT then			
						spr:SetOverlayFrame("Right_Overlay", percent)
					end
				
					if isShooting then
						data.Charge = data.Charge + charge
						data.Wait = 0
						if data.Charge >= info.MaxCharge then
							data.Charge = 0

							--天 堂 之 拳
							for i = 0,6+player:GetMultiShotParams(WeaponType.WEAPON_TEARS):GetNumTears() do
								local angle = i * 7
								local tear = player:FireTear(familiar.Position + Vector(0,40), Vector.FromAngle(vec:GetAngleDegrees() + angle*(-1)^i):Resized(shotSpeed), false, false, false, familiar, 0.7)
								tear:AddTearFlags(TearFlags.TEAR_PIERCING | TearFlags.TEAR_BOUNCE | TearFlags.TEAR_LIGHT_FROM_HEAVEN)
								tear.FallingSpeed = 0
								tear.FallingAcceleration = -0.1	
								tear.Height = -15
								tear.CollisionDamage = math.max(2.1, player.Damage*0.7)
								tear.Color = Color(1,1,1,0.5,1,1,1)
								tear:Update()
								self:DelayFunction(function()
									tear:Die()
								end, 15*math.floor(math.max(4, player.TearRange/40)))
							end
							
							--硬核后座
							familiar.Position = familiar.Position - 0.4*offset
							
							sfx:Play(832, 1, 2, false, 2.1)
						end
					else
						if data.Wait < 20 then
							data.Wait = data.Wait + 1
						else		
							data.Charge = math.max(0, data.Charge - 1)
						end
					end
				end
			elseif subType == self.SubType.Old then --旧箱
				data.Directional = true

				--蓄力条反色
				local color = Color(1,1,1,1)
				color:SetColorize(1,1,1,2)
				data.ChargeBar.Color = color

				--过热判定
				if data.Charge >= info.MaxCharge then
					data.OverHeat = true
				end
				if data.Charge <= 0 then
					data.OverHeat = false
				end

				if isShooting and not data.OverHeat then
					--高射速模式不会过热
					if HIGH then
						data.Charge = 0
					else
						data.Charge = data.Charge + 1
					end
					
					if familiar:IsFrame(3,0) then
						local minDMG = (HIGH and 0.2) or 0.7
					
						for i = 0,1+player:GetMultiShotParams(WeaponType.WEAPON_TEARS):GetNumTears() do
							local angle = i*math.random(2,6)
							local tear = player:FireTear(familiar.Position + Vector(0,15) - offset:Resized(10), vec:Rotated(angle*(-1)^i):Resized(shotSpeed), false, false, false, familiar, 1)
							if tear.Variant ~= 43 then
								tear:ChangeVariant(29)
							end
							local scale = self._Maths:TearDamageToScale(tear.CollisionDamage)
							tear.Scale = scale
							tear:AddTearFlags(TearFlags.TEAR_SPECTRAL)
							tear.CollisionDamage = math.max(minDMG, player.Damage * 0.25)
							tear.FallingAcceleration = 0.4
							tear.Color = Color(0.6,0.6,0.6,0.3)	
						end
						
						if not HIGH then
							game:ShakeScreen(1)
						end
						
						--硬核后座
						familiar.Position = familiar.Position - 0.3*offset						
						
						sfx:Play(830, 0.5, 2, false, 0.01 * math.random(50,200))
					end
				else
					local down = (data.OverHeat and 0.7*charge) or charge
					data.Charge = math.max(0, data.Charge - down)
				end

			elseif subType == self.SubType.Wooden then --木箱
				data.Directional = true
				
				--高射速模式
				if HIGH then
					if isShooting then
						data.Charge = math.max(0, data.Charge - 0.75)
						if data.Charge > 0 and familiar:IsFrame(3,0) then
						
							for i = 0,1+player:GetMultiShotParams(WeaponType.WEAPON_TEARS):GetNumTears() do
								local angle = i * math.random(0,20)
								local fire = Isaac.Spawn(1000, 10, 0, familiar.Position + Vector(0,25) + offset:Resized(15), vec:Rotated(angle*(-1)^i):Resized(shotSpeed), player):ToEffect()
								fire.Parent = player
								fire.CollisionDamage = math.max(0.5, player.Damage)
								fire.Timeout = math.ceil(2*(player.TearRange / 40)) + math.random(0,6)
								fire.Scale = self._Maths:TearDamageToScale(fire.CollisionDamage)
							end
							
							sfx:Play(536, 1, 0, false, 2)
						end
					else
						data.Charge = math.min(info.MaxCharge, data.Charge + math.ceil((30 / (player.MaxFireDelay + 1))/10))
					end
				else
					if isShooting then
						data.Charge = data.Charge + charge
						data.Wait = 0
						if data.Charge >= info.MaxCharge then
							data.Charge = 0

							for i = 0,1+player:GetMultiShotParams(WeaponType.WEAPON_TEARS):GetNumTears() do
								local angle = i * math.random(4,8)
								local fire = Isaac.Spawn(1000, 10, 0, familiar.Position + Vector(0,25) + offset:Resized(15), vec:Rotated(angle*(-1)^i):Resized(shotSpeed), player):ToEffect()
								fire.Parent = player
								fire.CollisionDamage = math.max(1.5, player.Damage * 0.5)
								fire.Timeout = math.ceil(15*(player.TearRange / 40)) + math.random(0,120)
								fire.Scale = self._Maths:TearDamageToScale(fire.CollisionDamage)
							end					
							
							--硬核后座
							familiar.Position = familiar.Position - 0.3*offset
							
							sfx:Play(536, 3)
						end
					else
						if data.Wait < 20 then
							data.Wait = data.Wait + 1
						else		
							data.Charge = math.max(0, data.Charge - 1)
						end
					end
				end	
			elseif subType == self.SubType.Haunted then --鬼箱
				data.Directional = true
				
				--高射速模式
				if HIGH then
					if isShooting and familiar:IsFrame(10,0) then
						data.Charge = 0
						local vel = vec:Resized(shotSpeed)
						local target = self._Finds:ClosestEnemy(familiar.Position)
						
						--自瞄
						if target and target.Position:Distance(familiar.Position) <= info.AutoTargetRadius then
							vel = (target.Position - familiar.Position):Resized(shotSpeed)
						end
						
						self._Players:FireTears(player, function(tear)
							self._Tears:ToFetus(tear, player)
							tear:AddTearFlags(TearFlags.TEAR_SPECTRAL)
							local color = Color(1,1,1,0.5,1,1,1)
							color:SetColorize(1,1,1,1)
							tear.Color = color
							tear.CollisionDamage = math.max(0.6, player.Damage)
							tear:GetSprite():ReplaceSpritesheet(0, 'gfx/ibs/tears/blost_weapon_haunted.png', true)
						end, familiar.Position + Vector(0,25), vel, false, false, false, familiar, 1)

						
						--硬核后座
						familiar.Position = familiar.Position - 0.1*offset
						
						sfx:Play(830, 1, 2, false, 3)
					end	
				else
					if isShooting then
						data.Charge = data.Charge + charge
						data.Wait = 0
						if data.Charge >= info.MaxCharge then
							data.Charge = 0
							local vel = vec:Resized(shotSpeed)
							local target = self._Finds:ClosestEnemy(familiar.Position)
							
							--自瞄
							if target and target.Position:Distance(familiar.Position) <= info.AutoTargetRadius then
								vel = (target.Position - familiar.Position - Vector(0,25)):Resized(shotSpeed)
							end
							
							self._Players:FireTears(player, function(tear)
								self._Tears:ToFetus(tear, player)
								tear:AddTearFlags(TearFlags.TEAR_SPECTRAL)
								local color = Color(1,1,1,0.5,1,1,1)
								color:SetColorize(1,1,1,1)
								tear.Color = color
								tear.CollisionDamage = math.max(3.5, player.Damage)
								tear:GetSprite():ReplaceSpritesheet(0, 'gfx/ibs/tears/blost_weapon_haunted.png', true)
							end, familiar.Position + Vector(0,25), vel, false, false, false, familiar, 1)
							
							
							--硬核后座
							familiar.Position = familiar.Position - 0.3*offset
							
							sfx:Play(826)
						end
					else
						if data.Wait < 20 then
							data.Wait = data.Wait + 1
						else		
							data.Charge = math.max(0, data.Charge - 1)
						end
					end
				end
			elseif subType == self.SubType.Golden then --金箱
				data.Directional = true
				
				--高射速模式
				if HIGH then
					--蓄力动画固定为满
					local percent = 100
					if dir == Direction.UP then
						spr:SetOverlayFrame("Up_Overlay", percent)
					elseif dir == Direction.DOWN then
						spr:SetOverlayFrame("Down_Overlay", percent)
					elseif dir == Direction.LEFT then		
						spr:SetOverlayFrame("Left_Overlay", percent)
					elseif dir == Direction.RIGHT then			
						spr:SetOverlayFrame("Right_Overlay", percent)
					end
					
					if isShooting then
						data.Charge = 0
					
						local laserOffset = Vector.Zero --激光位置修正
						if dir == Direction.UP then
							laserOffset = Vector(-8,-20)
						elseif dir == Direction.DOWN then
							laserOffset = Vector(5,20)
						elseif dir == Direction.LEFT then		
							laserOffset = Vector(-20,-2)
						elseif dir == Direction.RIGHT then			
							laserOffset = Vector(20,-2)
						end
						
						--检测缓存的激光是否存在
						for k,laser in ipairs(data.CachedLasers) do
							if not laser:Exists() or laser:IsDead() then
								table.remove(data.CachedLasers, k)
							end
						end
						
						if #data.CachedLasers > 0 then
							local params = player:GetMultiShotParams(WeaponType.WEAPON_LASER)
							for k,laser in ipairs(data.CachedLasers) do
								local posVel = player:GetMultiShotPositionVelocity(k-1, WeaponType.WEAPON_LASER, vec:Normalized(), player.ShotSpeed, params)
								laser.Position = familiar.Position
								laser.PositionOffset = laserOffset
								laser.AngleDegrees = posVel.Velocity:GetAngleDegrees()
								laser:SetTimeout(2)
							end
						else--否则重新生成
							if data.CD > 0 then
								data.CD = data.CD - 1
							else
								data.CD = 4
								self._Players:FireTechLasers(player, function(laser)
									laser:AddTearFlags(TearFlags.TEAR_SPECTRAL)
									laser.PositionOffset = laserOffset
									laser.Color = Color(1,1,1,0.5,2,2,0)
									self:GetLaserData(laser).Player = player
									table.insert(data.CachedLasers, laser)
								end, familiar.Position, 0, vec:Normalized(), false, false, familiar, 2)
							end
						end
					end
				else
					--蓄力动画
					local percent = math.floor(100*(data.Charge)/info.MaxCharge)
					if dir == Direction.UP then
						spr:SetOverlayFrame("Up_Overlay", percent)
					elseif dir == Direction.DOWN then
						spr:SetOverlayFrame("Down_Overlay", percent)
					elseif dir == Direction.LEFT then		
						spr:SetOverlayFrame("Left_Overlay", percent)
					elseif dir == Direction.RIGHT then			
						spr:SetOverlayFrame("Right_Overlay", percent)
					end
					
					if isShooting then
						data.Charge = data.Charge + charge
						data.Wait = 0
						
						local vel = vec:Resized(1)
						local pos = familiar.Position
						
						local target = self._Finds:ClosestEnemy(familiar.Position)
						
						--蓄力期间不断发射小激光
						if data.CD > 0 then
							data.CD = data.CD - 1
						else
							if data.Charge > 15 then
								local laserOffset = Vector.Zero --激光位置修正
								if dir == Direction.UP then
									laserOffset = Vector(14,-20)
								elseif dir == Direction.DOWN then
									laserOffset = Vector(-15,20)
								elseif dir == Direction.LEFT then		
									laserOffset = Vector(-20,9)
								elseif dir == Direction.RIGHT then			
									laserOffset = Vector(20,9)
								end	

								--自瞄
								if target and target.Position:Distance(familiar.Position) <= info.AutoTargetRadius then
									vel = (target.Position - pos):Resized(1)
								end
							
								--偏移
								local bia = Vector.FromAngle(vel:GetAngleDegrees() + (-1)^math.random(1,2)*math.random(0,7))
							
								self._Players:FireTechLasers(player, function(laser)
									laser:SetMaxDistance(player.TearRange/2)
									laser:AddTearFlags(TearFlags.TEAR_SPECTRAL)
									laser.PositionOffset = laserOffset
									laser.Color = Color(1,1,1,0.5,2,2,0)
									familiar.Position = familiar.Position - 0.05*offset
								end, pos, 0, bia, false, false, familiar, 0.25)
							
								data.CD = math.random(3,6)
							end
						end
						
						
						--蓄力结束发射大激光
						if data.Charge >= info.MaxCharge then
							data.Charge = 0
							
							local laserOffset = 0.5*offset --激光位置修正
							if dir == Direction.UP then
								laserOffset = Vector(3,-20)
							elseif dir == Direction.DOWN then
								laserOffset = Vector(-3,20)
							elseif dir == Direction.LEFT then		
								laserOffset = Vector(-20,-2)
							elseif dir == Direction.RIGHT then			
								laserOffset = Vector(20,-2)
							end							
							
							--自瞄
							if target and target.Position:Distance(familiar.Position) <= 1.5*info.AutoTargetRadius then
								vel = (target.Position - pos):Resized(1)
							end
							
							self._Players:FireTechLasers(player, function(laser)
								laser:AddTearFlags(TearFlags.TEAR_SPECTRAL)
								laser.PositionOffset = laserOffset
								laser.Color = Color(1,1,1,0.5,2,2,0)	
							end, pos, 0, vel, false, false, familiar, 6)
							
							--硬核后座
							familiar.Position = familiar.Position - 0.3*offset
						end
					else
						if data.Wait < 20 then
							data.Wait = data.Wait + 1
						else		
							data.Charge = math.max(0, data.Charge - 1)
						end
					end
				end
			elseif subType == self.SubType.Red then --红箱
				data.Directional = true
				
				--检测缓存的激光是否存在
				for k,laser in ipairs(data.CachedLasers) do
					if not laser:Exists() or laser:IsDead() then
						table.remove(data.CachedLasers, k)
					end
				end
				
				--用于缓冲蓄力动画
				local percent = math.floor(100*(data.Charge)/info.MaxCharge)
				local cachedLaser = data.CachedLasers[1]
				if cachedLaser and cachedLaser:Exists() and not cachedLaser:IsDead() then
					if HIGH then
						percent = 100
					else					
						percent = 100 - math.floor(100*(cachedLaser.FrameCount/24))
					end
				end
				
				--蓄力动画
				if dir == Direction.UP then
					spr:SetOverlayFrame("Up_Overlay", percent)
				elseif dir == Direction.DOWN then
					spr:SetOverlayFrame("Down_Overlay", percent)
				elseif dir == Direction.LEFT then		
					spr:SetOverlayFrame("Left_Overlay", percent)
				elseif dir == Direction.RIGHT then			
					spr:SetOverlayFrame("Right_Overlay", percent)
				end	

				--高射速模式
				if HIGH then			
					if isShooting then
						data.Charge = 0
						local laserOffset = Vector.Zero --激光位置修正
						if dir == Direction.UP then
							laserOffset = Vector(0,-20)
						elseif dir == Direction.DOWN then
							laserOffset = Vector(0,20)
						elseif dir == Direction.LEFT then		
							laserOffset = Vector(-20,-2)
						elseif dir == Direction.RIGHT then			
							laserOffset = Vector(20,-2)
						end							
					
						--检测缓存的激光是否存在
						if #data.CachedLasers > 0 then
							local params = player:GetMultiShotParams(WeaponType.WEAPON_BRIMSTONE)
							for k,laser in ipairs(data.CachedLasers) do
								local posVel = player:GetMultiShotPositionVelocity(k-1, WeaponType.WEAPON_BRIMSTONE, vec:Normalized(), player.ShotSpeed, params)
								laser.Position = familiar.Position
								laser.PositionOffset = laserOffset
								laser.AngleDegrees = posVel.Velocity:GetAngleDegrees()
								laser:SetTimeout(2)
							end
						else--否则重新生成
							self._Players:FireBrimstones(player, function(laser)
								laser.Parent = familiar
								laser.PositionOffset = laserOffset
								laser:AddTearFlags(TearFlags.TEAR_SPECTRAL)
								laser:SetScale(math.min(1.5, self._Maths:TearDamageToScale(player.Damage)))
								laser:SetMaxDistance(player.TearRange/5)
								self:GetLaserData(laser).Player = player
								table.insert(data.CachedLasers, laser)
							end, familiar.Position, vec:Normalized(), source, 1)
						end
					end				
				else
					if isShooting then
						local laserOffset = Vector.Zero --激光位置修正
						if dir == Direction.UP then
							laserOffset = Vector(0,-20)
						elseif dir == Direction.DOWN then
							laserOffset = Vector(0,20)
						elseif dir == Direction.LEFT then		
							laserOffset = Vector(-20,-2)
						elseif dir == Direction.RIGHT then			
							laserOffset = Vector(20,-2)
						end	
						
						--检测缓存的激光是否存在
						if #data.CachedLasers > 0 then
							local params = player:GetMultiShotParams(WeaponType.WEAPON_BRIMSTONE)
							for k,laser in ipairs(data.CachedLasers) do
								local posVel = player:GetMultiShotPositionVelocity(k-1, WeaponType.WEAPON_BRIMSTONE, vec:Normalized(), player.ShotSpeed, params)
								laser.Position = familiar.Position
								laser.PositionOffset = laserOffset
								laser.AngleDegrees = posVel.Velocity:GetAngleDegrees()
							end
						else--否则重新生成
							data.Charge = data.Charge + charge
							data.Wait = 0

							if data.Charge >= info.MaxCharge then
								data.Charge = 0
								
								self._Players:FireBrimstones(player, function(laser)
									laser.Parent = familiar
									laser.PositionOffset = laserOffset
									laser:AddTearFlags(TearFlags.TEAR_SPECTRAL)
									laser:SetScale(math.min(1.5, self._Maths:TearDamageToScale(player.Damage)))
									laser:SetTimeout(15)
									laser:SetMaxDistance(player.TearRange/5)
									table.insert(data.CachedLasers, laser)
								end, familiar.Position, vec:Normalized(), source, 1)								
								
								--硬核后座
								familiar.Position = familiar.Position - 0.3*offset
							end
						end
					else
						if data.Wait < 20 then
							data.Wait = data.Wait + 1
						else		
							data.Charge = math.max(0, data.Charge - 1)
						end
					end			
				end
				
			end
		end
	end
end
BLostWeapon:AddCallback(ModCallbacks.MC_POST_UPDATE, 'OnUpdate')

--高射速模式激光兼容
function BLostWeapon:OnLaserUpdate(laser)
	local data = self._Ents:GetTempData(laser).BLostWeaponLaser
	if data then
		if data.Player and not self._Players:IsShooting(data.Player) then
			laser:Die()
		end
	end
end
BLostWeapon:AddCallback(ModCallbacks.MC_POST_LASER_UPDATE, 'OnLaserUpdate')

--新房间调整
function BLostWeapon:OnNewRoom()
	for i = 0, game:GetNumPlayers() - 1 do
		local player = Isaac.GetPlayer(i)
		for _,familiar in ipairs(BLostWeapon:FindWeapons(player)) do
			local data = self:GetData(familiar)
			local info = self.ChestInfo[familiar.SubType]
			
			--新房间清空充能
			if info and info.ClearChargeInNewRoom then
				data.Charge = 0
			end
			
			familiar.Position = player.Position + Vector(0,-25)
		end
	end
end
BLostWeapon:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, 'OnNewRoom')

--渲染蓄力条
function BLostWeapon:OnHUDRender()
	if not game:GetHUD():IsVisible() then return end
	if game:GetRoom():GetFrameCount() <= 0 then return end
	for i = 0, game:GetNumPlayers() - 1 do
		local player = Isaac.GetPlayer(i)
		local HIGH = self:IsHighTearsMode(player.MaxFireDelay)

		
		for _,familiar in ipairs(self:FindWeapons(player)) do
			local subType = familiar.SubType
			
			--高射速模式不显示蓄力条
			--木箱依旧显示
			if not HIGH or subType == self.SubType.Wooden then
				local info = self.ChestInfo[subType] if not info then return end
				local data = self:GetData(familiar)

				local pos = self._Screens:WorldToScreen(familiar.Position, Vector(0,-16), true)
				if data.Charge > 0 then
					data.ChargeBar:SetFrame("Charging", math.floor(100*(data.Charge)/info.MaxCharge))
				else
					data.ChargeBar:Play("Disappear")
					if not game:IsPaused() then
						data.ChargeBar:Update()
					end
				end
				data.ChargeBar.Scale = Vector(1,1)
				data.ChargeBar:Render(pos)
			end
			
		end
	end
end
BLostWeapon:AddCallback(ModCallbacks.MC_POST_HUD_RENDER, 'OnHUDRender')

return BLostWeapon