--箱子僚机

local mod = Isaac_BenightedSoul
local IBS_FamiliarID = mod.IBS_FamiliarID

local game = Game()
local sfx = SFXManager()
local config = Isaac.GetItemConfig()

local BLostFloat = mod.IBS_Class.Familiar{
	Variant = IBS_FamiliarID.BLostFloat.Variant,
	SubType = IBS_FamiliarID.BLostFloat.SubType,
	Name = {zh = '箱子僚机', en = 'Chest Float'}
}

--获取数据
function BLostFloat:GetData(familiar)
	local data = self._Ents:GetTempData(familiar)
	data.BLostFloat = data.BLostFloat or {
		CD = 0,
		
		--用于木箱
		OrbitDistance = 75,
		OrbitDistanceDelta = 1,
		OrbitDistanceUp = true,
	}
	return data.BLostFloat
end

--信息
BLostFloat.ChestInfo = {
	[BLostFloat.SubType.Common] = {
		Count = 2,
		Orbit = true,
		OrbitSpeed = 0.04,
		OrbitDistance = Vector(90,-30),
	},
	[BLostFloat.SubType.Stone] = {
		Count = 2,
		Orbit = true,
		OrbitSpeed = 0.01,
		OrbitDistance = Vector(30,30),
	},
	[BLostFloat.SubType.Spike] = {
		Count = 3,
		Follower = true,
	},
	[BLostFloat.SubType.Wooden] = {
		Count = 2,
		Orbit = true,
		OrbitSpeed = 0.03,
		OrbitDistance = Vector(75,75),
	},
	[BLostFloat.SubType.Haunted] = {
		Count = 2,
		Orbit = true,
		OrbitSpeed = 0.1,
		OrbitDistance = Vector(90,-30),
	},	
	[BLostFloat.SubType.Eternal] = {
		Count = 1,
	},
	[BLostFloat.SubType.Old] = {
		Count = 4,
	},
	[BLostFloat.SubType.Golden] = {
		Count = 1,
		Orbit = true,
		OrbitSpeed = 0.05,
		OrbitDistance = Vector(-30,90),		
	},
	[BLostFloat.SubType.Red] = {
		Count = 1,
		Orbit = true,
		OrbitSpeed = 0.1,
		OrbitDistance = Vector(90,90),		
	},

}

--查找僚机
function BLostFloat:FindFloats(player, subType)
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

--初始化
function BLostFloat:OnFamiliarInit(familiar)
	local spr = familiar:GetSprite()
	local subType = familiar.SubType
	local info = self.ChestInfo[subType]
	
	if info then
		if info.Orbit then		
			familiar:AddToOrbit(789 + familiar.SubType)
			familiar.OrbitDistance = info.OrbitDistance
			familiar.OrbitSpeed = info.OrbitSpeed
		end
		if info.Follower then
			familiar:AddToFollowers()
		end
	end

	--永恒箱光效
	if subType == self.SubType.Eternal then	
		self._Ents:ApplyLight(familiar, 1, Color(1,1,1,2))
	end

	familiar.DepthOffset = 1 --使图层处于上层
end
BLostFloat:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, 'OnFamiliarInit', BLostFloat.Variant)

--更新
function BLostFloat:OnFamiliarUpdate(familiar)
	local player = familiar.Player if not player then return end
	local room = game:GetRoom()
	local subType = familiar.SubType
	local info = self.ChestInfo[subType] if not info then return end
	local data = self:GetData(familiar)
	local spr = familiar:GetSprite()
	
	if data.CD > 0 then
		data.CD = data.CD - 1
	end
	
	--普通箱子
	if subType == self.SubType.Common then
		familiar.OrbitDistance = info.OrbitDistance
		familiar.OrbitSpeed = info.OrbitSpeed	
		familiar.Velocity = (familiar:GetOrbitPosition(player.Position + player.Velocity) - familiar.Position)

		local target = self._Finds:ClosestEntity(familiar.Position, 9, -1, -1, function(ent)
			local proj = ent:ToProjectile()
			if proj and not proj:HasProjectileFlags(ProjectileFlags.CANT_HIT_PLAYER) then
				return true
			end
			return false
		end)
	
		if target == nil then
			target = self._Finds:ClosestEnemy(familiar.Position)
		end
	
		if data.CD <= 0 and target ~= nil and familiar.Position:Distance(target.Position) <= 200 then
			spr:Play("Attack")
			data.CD = 20 + math.random(5,10)
		end
		
		if spr:IsFinished("Attack") then
			spr:Play("Float")
		end
		
		if spr:IsEventTriggered("Attack") and target then
			local vel = (target.Position - familiar.Position):Resized(20)
			local tear = Isaac.Spawn(2,43,0, familiar.Position, vel, player):ToTear()
			tear:AddTearFlags(TearFlags.TEAR_SHIELDED | TearFlags.TEAR_SPECTRAL)
			tear.CollisionDamage = math.max(1.5, player.Damage * 0.5)
			tear.Color = Color(1,1,1,0.5)
		end
	elseif subType == self.SubType.Stone then --石箱
		familiar.OrbitDistance = info.OrbitDistance
		familiar.OrbitSpeed = info.OrbitSpeed	
		familiar.Velocity = (familiar:GetOrbitPosition(player.Position) - familiar.Position)
	elseif subType == self.SubType.Spike then --刺箱
		familiar:FollowParent()
	
		--碰撞伤害
		for _,target in ipairs(Isaac.GetRoomEntities()) do
			if self._Ents:IsEnemy(target) and self._Ents:AreColliding(target, familiar) then
				target:TakeDamage(math.max(0.35, 0.1*player.Damage), 0, EntityRef(familiar), 0)
			end
		end
	elseif subType == self.SubType.Eternal then --永恒箱
		familiar:FollowPosition(room:FindFreePickupSpawnPosition(room:GetCenterPos(), 0, true))

		local target = self._Finds:ClosestEntity(familiar.Position, 9, -1, -1, function(ent)
			local proj = ent:ToProjectile()
			if proj and not proj:HasProjectileFlags(ProjectileFlags.CANT_HIT_PLAYER) then
				return true
			end
			return false
		end)
		
		if target == nil then
			target = self._Finds:ClosestEnemy(familiar.Position)
		end
	
		--进门4秒后才开始攻击
		if data.CD <= 0 and target ~= nil and room:GetFrameCount() > 120 then
			spr:Play("Attack")
			data.CD = 45 + math.random(15,30)
		end
		
		if spr:IsFinished("Attack") then
			spr:Play("Float")
		end
		
		if spr:IsEventTriggered("Attack") then
			local num = 0
			for _,target in pairs(Isaac.GetRoomEntities()) do
				if num >= 4 then --最多同时攻击4个目标
					break
				end
				local proj = target:ToProjectile()
				if self._Ents:IsEnemy(target) or (proj and not proj:HasProjectileFlags(ProjectileFlags.CANT_HIT_PLAYER)) then
					local vel = (target.Position - familiar.Position):Resized(20)
					local tear = Isaac.Spawn(2,35,0, familiar.Position, vel, player):ToTear()
					tear:AddTearFlags(TearFlags.TEAR_SHIELDED | TearFlags.TEAR_SPECTRAL | TearFlags.TEAR_PIERCING | TearFlags.TEAR_ACID | TearFlags.TEAR_LIGHT_FROM_HEAVEN)
					tear.Height = -40
					tear.FallingSpeed = -10
					tear.FallingAcceleration = 0.6
					tear.Scale = 0.7
					tear.CollisionDamage = math.max(3.5, player.Damage)
					tear.Color = Color(1, 1, 1, 1, 1, 1, 1)
					tear:Update()
					num = num + 1
				end
			end
		end
	elseif subType == self.SubType.Old then --旧箱
		
		local target = self._Finds:ClosestEntity(familiar.Position, 9, -1, -1, function(ent)
			local proj = ent:ToProjectile()
			if proj and not proj:HasProjectileFlags(ProjectileFlags.CANT_HIT_PLAYER) then
				return true
			end
			return false
		end)
	
		if target == nil then
			target = self._Finds:ClosestEnemy(familiar.Position)
		end
		
		--目标在附近时减速
		if target ~= nil and familiar.Position:Distance(target.Position) <= 120 then
			familiar:MoveDiagonally(0.5)
			if data.CD <= 0 then
				spr:Play("Attack")
				data.CD = math.random(10,15)
			end
		else
			local speed = (self._Levels:IsInBigRoom() and 3) or 1
			familiar:MoveDiagonally(speed)
		end
		
		if spr:IsFinished("Attack") then
			spr:Play("Float")
		end
		
		if spr:IsEventTriggered("Attack") and target then
			local num = 0
			for _,target in pairs(Isaac.GetRoomEntities()) do
				if num >= 3 then --最多同时攻击3个目标
					break
				end
				local proj = target:ToProjectile()
				if self._Ents:IsEnemy(target) or (proj and not proj:HasProjectileFlags(ProjectileFlags.CANT_HIT_PLAYER)) then
					if familiar.Position:Distance(target.Position) <= 140 then		
						local vel = (target.Position - familiar.Position):Resized(8)
						local tear = Isaac.Spawn(2,29,0, familiar.Position, vel, player):ToTear()
						tear:AddTearFlags(TearFlags.TEAR_SHIELDED | TearFlags.TEAR_SPECTRAL)
						tear.CollisionDamage = math.max(0.7, player.Damage * 0.25)
						tear.Color = Color(0.6,0.6,0.6,0.3)
						num = num + 1
					end
				end
			end
		end		
	elseif subType == self.SubType.Wooden then --木箱

		--调整环绕距离
		if data.OrbitDistanceUp then
			if data.OrbitDistance < 120 then
				data.OrbitDistance = data.OrbitDistance + data.OrbitDistanceDelta
			else
				data.OrbitDistanceUp = false
				data.OrbitDistanceDelta = math.random(2,4)
			end
		else
			if data.OrbitDistance > 45 then
				data.OrbitDistance = data.OrbitDistance - data.OrbitDistanceDelta
			else
				data.OrbitDistanceUp = true
				data.OrbitDistanceDelta = math.random(1,2)
			end		
		end
	
		familiar.OrbitDistance = Vector(data.OrbitDistance, data.OrbitDistance)
		familiar.OrbitSpeed = info.OrbitSpeed	
		familiar.Velocity = (familiar:GetOrbitPosition(player.Position) - familiar.Position)

		local target = self._Finds:ClosestEntity(familiar.Position, 9, -1, -1, function(ent)
			local proj = ent:ToProjectile()
			if proj and not proj:HasProjectileFlags(ProjectileFlags.CANT_HIT_PLAYER) then
				return true
			end
			return false
		end)		
		
		--找店长
		if target == nil then
			target = self._Finds:ClosestEntity(familiar.Position, 17)
		end
		
		if target == nil then
			target = self._Finds:ClosestEnemy(familiar.Position)
		end	

		if not room:IsClear() or target ~= nil then
			spr:PlayOverlay('Idle_Overlay')
		elseif spr:IsOverlayPlaying('Idle_Overlay') then
			spr:RemoveOverlay()
		end
	
		--碰撞判定(对店长也有效)
		for _,target in ipairs(Isaac.GetRoomEntities()) do
			if self._Ents:AreColliding(target, familiar) then
				local proj = target:ToProjectile()
				
				if proj or (self._Ents:IsEnemy(target) or target.Type == 17) then
					--敌弹
					if proj and not proj:HasProjectileFlags(ProjectileFlags.CANT_HIT_PLAYER) then
						--生成火焰
						local fire = Isaac.Spawn(1000, 10, 0, familiar.Position, (target.Position - familiar.Position):Resized(0.05*math.random(10,20)), player):ToEffect()
						fire.Parent = player
						fire.CollisionDamage = math.max(2, player.Damage * 0.5)
						fire.Timeout = math.random(30,60)
						fire.Scale = 0.75
						
						proj:Die()
					elseif familiar:IsFrame(7,0) then
						target:TakeDamage(math.max(2, player.Damage * 0.5), 0, EntityRef(familiar), 0)
						
						--生成火焰
						if data.CD <= 0 then
							local fire = Isaac.Spawn(1000, 10, 0, familiar.Position, (target.Position - familiar.Position):Resized(0.05*math.random(10,20)), player):ToEffect()
							fire.Parent = player
							fire.CollisionDamage = math.max(2, player.Damage * 0.5)
							fire.Timeout = math.random(60,120)
							fire.Scale = 0.75
							data.CD = math.random(20,30)
						end
						
						sfx:Play(43)
					end
				end
			end
		end
	elseif subType == self.SubType.Haunted then --鬼箱
		familiar.OrbitDistance = info.OrbitDistance
		familiar.OrbitSpeed = info.OrbitSpeed	
		familiar.Velocity = (familiar:GetOrbitPosition(player.Position + player.Velocity) - familiar.Position)

		local target = self._Finds:ClosestEntity(familiar.Position, 9, -1, -1, function(ent)
			local proj = ent:ToProjectile()
			if proj and not proj:HasProjectileFlags(ProjectileFlags.CANT_HIT_PLAYER) then
				return true
			end
			return false
		end)
	
		if target == nil then
			target = self._Finds:ClosestEnemy(familiar.Position)
		end
	
		if data.CD <= 0 and target ~= nil and familiar.Position:Distance(target.Position) <= 200 then
			spr:Play("Attack")
			data.CD = math.random(60,90)
		end
		
		if spr:IsFinished("Attack") then
			spr:Play("Float")
		end

		if spr:IsEventTriggered("Attack") and target then
			local effect = Isaac.Spawn(1000, 186, 1, familiar.Position, Vector.Zero, player):ToEffect()
			effect.Parent = player
			effect.CollisionDamage = 5 + math.max(3.5, player.Damage)
			effect.Timeout = math.random(90,180)
			effect.Color = Color(1,1,1,0.5)
		end		
	elseif subType == self.SubType.Golden then --金箱
		familiar.OrbitDistance = info.OrbitDistance
		familiar.OrbitSpeed = info.OrbitSpeed		
		familiar.Velocity = (familiar:GetOrbitPosition(player.Position + player.Velocity) - familiar.Position)

		local target = self._Finds:ClosestEntity(familiar.Position, 9, -1, -1, function(ent)
			local proj = ent:ToProjectile()
			if proj and not proj:HasProjectileFlags(ProjectileFlags.CANT_HIT_PLAYER) then
				return true
			end
			return false
		end)
		
		if target == nil then
			target = self._Finds:ClosestEnemy(familiar.Position)
		end
	
		if data.CD <= 0 and target ~= nil and familiar.Position:Distance(target.Position) <= 300 then
			spr:Play("Attack")
			data.CD = math.random(30,39)
		end
		
		if spr:IsFinished("Attack") then
			spr:Play("Float")
		end
		
		if spr:IsEventTriggered("Attack") and target then
			local num = 0
			for _,target in pairs(Isaac.GetRoomEntities()) do
				if num >= 3 then --最多同时攻击3个目标
					break
				end
				local proj = target:ToProjectile()
				if self._Ents:IsEnemy(target) or (proj and not proj:HasProjectileFlags(ProjectileFlags.CANT_HIT_PLAYER)) then
					if familiar.Position:Distance(target.Position) <= 300 then		
						local vec = (target.Position - familiar.Position)
						local laser = EntityLaser.ShootAngle(2, familiar.Position, vec:GetAngleDegrees(), 2, Vector(0,-26), familiar)
						laser:SetMaxDistance(vec:Length()+4)
						laser.LaserLength = 1
						laser.DisableFollowParent = true
						laser:AddTearFlags(TearFlags.TEAR_SPECTRAL)
						laser.CollisionDamage = math.max(1.5, player.Damage * 0.5)
						laser.Color = Color(1,1,1,0.5,2,2,0)
						num = num + 1
						
						--消除敌弹
						if target:ToProjectile() and not target:ToProjectile():HasProjectileFlags(ProjectileFlags.CANT_HIT_PLAYER) then
							target:Die()
						end
					end
				end
			end
		end	
	elseif subType == self.SubType.Red then --红箱
		local target = nil

		--进门3秒后才开始攻击
		if room:GetFrameCount() > 90 then
			target = self._Finds:ClosestEnemy(familiar.Position)
		end

		--模拟黑粉
		if target then
			familiar.OrbitSpeed = 0.06
			familiar.OrbitDistance = Vector(60,60)
			familiar:FollowPosition(familiar:GetOrbitPosition(target.Position))
			spr:Play('Float2')

			local effect = Isaac.Spawn(1000, 92, 0, familiar.Position, Vector.Zero, familiar):ToEffect()
			effect.Timeout = 3
			
			if familiar.Position:Distance(target.Position) <= 60 then
				--硫磺诅咒
				target:SetBossStatusEffectCooldown(0)
				if target:GetBrimstoneMarkCountdown() < 15 then
					target:AddBrimstoneMark(EntityRef(player), 15)
					target:SetBrimstoneMarkCountdown(15)
				end			
			
				if data.CD > 0 then
					data.CD = data.CD - 1
				else
					data.CD = 120
					local effect = Isaac.Spawn(1000, 93, 0, target.Position, Vector.Zero, familiar):ToEffect()
					effect.Timeout = 120
					effect.State = 1
					effect:SetSize(30, Vector(1,1), 0)
					effect.SpriteScale = Vector(0.2,0.2)
				end
			end
		else
			familiar.OrbitSpeed = 0.06
			familiar.OrbitDistance = Vector(90,90)
			familiar:FollowPosition(familiar:GetOrbitPosition(player.Position))
			spr:Play('Float')
			data.CD = 30
		end
		
		
	end
end
BLostFloat:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, 'OnFamiliarUpdate', BLostFloat.Variant)


return BLostFloat