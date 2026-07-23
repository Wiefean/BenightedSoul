--扫荡特效
--(30为默认尺寸,大约距离为0.75个格子)
--(没想到吧,伤害范围判定是手动计算,特效也是手动计算)

local mod = Isaac_BenightedSoul
local IBS_EffectID = mod.IBS_EffectID

local game = Game()

local Swing = mod.IBS_Class.Effect{
	Variant = IBS_EffectID.Swing.Variant,
	SubType = IBS_EffectID.Swing.SubType,
	Name = {zh = '扫荡', en = 'Swing'}
}

--生成
function Swing:Spawn(pos, rotation, spawner)
	local effect = Isaac.Spawn(1000, self.Variant, 0, pos, Vector.Zero, spawner):ToEffect()
	effect:GetSprite().Rotation = rotation
	return effect
end

--获取攻击位置
--[[
--位置修正示例
{
	Up = Vector(0,-10),
	Down = Vector(0,-15),
	Left = Vector(0,-10),
	Right = Vector(0,-10),
}
]]
function Swing:GetAttackPos(pos, vec, dist, scale, offsets)
	dist = dist or 30
	scale = scale or 1
	local offset = vec:Resized(dist*scale)
	local offset2 = Vector.Zero
	
	--调整位置,让位置看起来不那么偏
	if offsets then
		local _offsets = {}
	
		for k,v in pairs(offsets) do
			_offsets[k] = Vector(v.X * scale, v.Y * scale)
		end
		
		local dir = self._Maths:VectorToDirection(vec)
		if dir == Direction.UP then
			offset2 = offset2 + _offsets.Up
		elseif dir == Direction.DOWN then
			offset2 = offset2 + _offsets.Down
		elseif dir == Direction.LEFT then
			offset2 = offset2 + _offsets.Left
		elseif dir == Direction.RIGHT then
			offset2 = offset2 + _offsets.Right
		end
	end

	return pos + offset + offset2
end

--寻找目标(包括敌人,炸弹,掉落物,敌弹)
function Swing:FindTargets(pos, radius, vec)
	local result = {}

	for _,ent in ipairs(Isaac.GetRoomEntities()) do
		local typ = ent.Type
		if (
				self._Ents:IsEnemy(ent, true)
				or typ == 4
				or typ == 5
				or typ == 9
			)
			and (ent.Position:Distance(pos) - ent.Size) <= radius
		then
			table.insert(result, ent)
		end
	end

	return result
end

--位置修正
Swing.DefaultPositionOffsets = {
	Up = Vector(0,-10),
	Down = Vector(0,-15),
	Left = Vector(0,-15),
	Right = Vector(0,-15),
}

--扫荡
--[[
填表示例:
{
	Spawner = Isaac.GetPlayer(0),
	AimingVector = Vector(0,1),
	Position = Vector(0,0),
	PositionOffsets = {
		Up = Vector(0,-10),
		Down = Vector(0,-15),
		Left = Vector(0,-10),
		Right = Vector(0,-10),	
	},
	Color = Color(1,1,1,1),
	Size = 30,
	Distance = 30,
	Scale = 1,
	Damage = 3.5,
	BounceSpeed = 10,
	SelfBounceSpeed = 5,
	FollowSpawner = true,
	CollectPickup = false,
	ClearProj = false,
	HurtGrid = true,
	DestroyGrid = false,
	DestroyDoor = false,
}
]]
function Swing:DoSwing(tbl)
	local spawner = tbl.Spawner
	local pos = tbl.Position
	local vec = tbl.AimingVector
	local size = tbl.Size or 30
	local dist = tbl.Distance or 30
	local scale = tbl.Scale or 1
	local dmg = tbl.Damage or 0
	local bounceSpd = tbl.BounceSpeed or 10
	local selfBounceSpd = tbl.SelfBounceSpeed or 5
	local offsets = tbl.PositionOffsets or self.DefaultPositionOffsets
	local radius = size * scale
	local attackPos = self:GetAttackPos(pos, vec, dist, scale, offsets)
	
	--查找目标
	local targets = self:FindTargets(attackPos, radius, vec)
	local selfBounced = false
	
	for _,ent in ipairs(targets) do
		local T = ent.Type
		local V = ent.Variant
	
		--敌人检测
		if self._Ents:IsEnemy(ent, true) then
			
			--篝火或店长或触手或爆桶(触手其实包括测伤假人模组的人偶)
			if T == 17 or T == 33 or T == 231 or T == 292 then
				if dmg > 0 then				
					ent:TakeDamage(dmg, 0, EntityRef(spawner), 0)
				end
			else
				--可受伤的敌人
				--if ent:IsVulnerableEnemy() then
					if dmg > 0 then				
						ent:TakeDamage(dmg, 0, EntityRef(spawner), 0)
					end
					
					--给予速度
					if bounceSpd > 0 then				
						ent:AddVelocity((ent.Position - spawner.Position):Resized(bounceSpd))
					end
					if selfBounceSpd > 0 and not selfBounced then
						selfBounced = true
						spawner:AddVelocity((spawner.Position - ent.Position):Resized(selfBounceSpd))
					end
				--end
			end
		end
	
		--掉落物
		if T == 5 then
			local pickup = ent:ToPickup()
		
			--收集掉落物(不包括饰品和口袋物品,原版的这个设定烂透了)
			if pickup and tbl.CollectPickup
				and not pickup:GetSprite():IsPlaying("Appear")
				and V ~= 70
				and V ~= 100
				and V ~= 300
				and V ~= 350
				and pickup.Price == 0
				and self._Pickups:CanCollect(pickup, spawner)
			then
				self._Pickups:TryCollect(pickup, spawner)
			else				
				--给予速度
				if bounceSpd > 0 and pickup and pickup.Wait <= 0 and not pickup:GetSprite():IsPlaying("Appear") then
					ent:AddVelocity((ent.Position - spawner.Position):Resized(bounceSpd / 2))
				end			
			end
		end
		
		--敌弹
		if tbl.ClearProj and T == 9 then
			local proj = ent:ToProjectile()
			if proj and not proj:HasProjectileFlags(ProjectileFlags.CANT_HIT_PLAYER) then
				proj:Die()
			end
		end
	end
	
	local room = game:GetRoom()
	
	--摧毁障碍物
	if (tbl.HurtGrid == nil or tbl.HurtGrid ~= false) or tbl.DestroyGrid then	
		for gridIdx,gridEnt in pairs(self._Finds:GridEntInRadius(attackPos, 10 + radius)) do
			if tbl.HurtGrid == nil or tbl.HurtGrid ~= false then
				gridEnt:Hurt(10)
			end
			if tbl.DestroyGrid then				
				room:DestroyGrid(gridIdx, false)
			end	
		end
	end
	
	--破门效果
	if tbl.DestroyDoor then	
		for slot = 0,7 do
			local door = room:GetDoor(slot)
			if door ~= nil and door.Position:Distance(attackPos) <= 10 + radius then
				door:TryBlowOpen(true, spawner)
			end
		end	
	end
	
	--生成特效
	local angle = vec:GetAngleDegrees() - 90
	local sprScale = (size / 30) * scale
	local effect = self:Spawn(attackPos - sprScale * vec:Resized(30), angle, spawner)
	local spr = effect:GetSprite()
	spr.Scale = Vector(sprScale, sprScale)
	spr.Color = tbl.Color or Color(1,1,1,1)	
	
	--跟随
	if tbl.FollowSpawner == nil or tbl.FollowSpawner ~= false then
		if tbl.FollowEntity == nil then
			effect:FollowParent(spawner)
		else
			effect:FollowParent(tbl.FollowEntity)
		end
	end
	
	return targets, effect
end

--用于测试攻击范围
-- mod:AddCallback(ModCallbacks.MC_POST_RENDER, function()
	-- local player = Isaac.GetPlayer(0)
	-- local vec = Swing._Players:GetAimingVector(player)
	-- local pos1 = Isaac.WorldToScreen(player.Position)
	-- local pos2 = Isaac.WorldToScreen(player.Position + vec:Resized(30)) 

	-- Isaac.DrawLine(pos1, pos2, KColor(1,1,1,1), KColor(1,0,1,1), 5)
-- end)

--初始化
function Swing:OnEffectInit(effect)
	effect:GetSprite():Play('Swing'..math.random(1,2), true)
	effect.DepthOffset = 10 --使图层处于上层
end
Swing:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, 'OnEffectInit', Swing.Variant)

--更新
function Swing:OnEffectUpdate(effect)
	local spr = effect:GetSprite()
	if spr:IsFinished('Swing1') or spr:IsFinished('Swing2') then
		effect:Remove()
	end
end
Swing:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, 'OnEffectUpdate', Swing.Variant)

return Swing