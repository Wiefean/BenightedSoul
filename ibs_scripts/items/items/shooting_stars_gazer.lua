--仰望星空

local mod = Isaac_BenightedSoul
local IBS_Sound = mod.IBS_Sound

local game = Game()
local sfx = SFXManager()
local config = Isaac.GetItemConfig()

local SSG = mod.IBS_Class.Item(mod.IBS_ItemID.SSG)


--临时眼泪数据
function SSG:GetTearData(tear)
	local data = self._Ents:GetTempData(tear)
	data.SHOOTINGSTARS_TEAR = data.SHOOTINGSTARS_TEAR or {
		Other = false,
		First = false,
		Player = nil
	}

	return data.SHOOTINGSTARS_TEAR
end

--临时玩家数据
function SSG:GetPlayerData(player)
	local data = self._Ents:GetTempData(player)
	data.SHOOTINGSTARS_PLAYER = data.SHOOTINGSTARS_PLAYER or {
		CD = 0,
		Ready = true,
		KnifeWait = 0,
		Area = {}
	}

	return data.SHOOTINGSTARS_PLAYER
end

--临时马刀数据
function SSG:GetKnifeData(knife)
	local data = self._Ents:GetTempData(knife)
	data.SHOOTINGSTARS_KNIFE = data.SHOOTINGSTARS_KNIFE or {Wait = 0}

	return data.SHOOTINGSTARS_KNIFE
end

--临时敌人数据
function SSG:GetNpcData(npc)
	local data = self._Ents:GetTempData(npc)
	data.SHOOTINGSTARS_TARGET = data.SHOOTINGSTARS_TARGET or {HitCD = 0}

	return data.SHOOTINGSTARS_TARGET
end

--调整命中冷却
function SSG:OnNpcUpdate(npc)
	local data = self._Ents:GetTempData(npc).SHOOTINGSTARS_TARGET
	if data then
		if data.HitCD > 0 then
			data.HitCD = data.HitCD - 1
		else
			data.HitCD = 0
		end
	end
end
SSG:AddCallback(ModCallbacks.MC_NPC_UPDATE,  'OnNpcUpdate')

--设置掉落眼泪
function SSG:SetFallingTear(tear)
	local data = self:GetTearData(tear)
	data.Other = true
end

--是否为掉落眼泪
function SSG:IsFallingTear(tear)
	local data = self._Ents:GetTempData(tear).SHOOTINGSTARS_TEAR
	if data and data.Other then
		return true
	end
	
	return false
end

--模拟眼泪掉落
function SSG:OnFallingTearCollision(tear, target)
    if self:IsFallingTear(tear) and (-tear.Height > 1.2*(target.Size)) then
		return true
    end
end
SSG:AddCallback(ModCallbacks.MC_PRE_TEAR_COLLISION, 'OnFallingTearCollision')


--硫磺火兼容,生成硫磺火柱(借用死寂的)
function SSG:SpawnBrimeStonePillar(player, timeout, pos)
	local effect = Isaac.Spawn(EntityType.ENTITY_EFFECT, 101, 0, pos, Vector.Zero, player):ToEffect()
	self:SetFallingTear(effect)  --(这里tear直接写effect,反正数据是通用的)
	effect.Timeout = timeout + 60
	effect.CollisionDamage = math.max(player.Damage / 2, 2)
	effect.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ENEMIES
	effect:SetColor(Color(0.75, 0.75, 1, 1, 0, 0, 1),-1,0)	
	sfx:Play(7,0.5)
end

--查找仰望星空硫磺火柱
function SSG:FindBrimestonePillars(player)
	local result = {}
	
	for _,effect in pairs(Isaac.FindByType(1000, 101, 0)) do
		if self:IsFallingTear(effect) and (not player or self._Ents:IsTheSame(effect.SpawnerEntity, player)) then
			table.insert(result, effect)
		end	
	end
	
	return result
end

--硫磺火住更新
function SSG:OnBrimeStonePillarUpdate(effect)
	if effect.FrameCount % 2 == 0 and self:IsFallingTear(effect) then
		for _,target in pairs(Isaac.FindInRadius(effect.Position, 10, EntityPartition.ENEMY)) do
			if self._Ents:IsEnemy(target) then
				target:TakeDamage(effect.CollisionDamage, 0, EntityRef(effect), 0)
			end
		end
	end
	if effect.Timeout <= 0 and effect.Timeout ~= -1 then
		effect:Die()
	end
end
SSG:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, 'OnBrimeStonePillarUpdate', 101)

--设置引物
function SSG:SetFirstTear(tear)
	local data = self:GetTearData(tear)
	data.First = true
end

--是否为引物
function SSG:IsFirstTear(tear)
	local data = self._Ents:GetTempData(tear).SHOOTINGSTARS_TEAR
	if data and data.First then
		return true
	end

	return false
end

--引物命中检测
function SSG:OnHit(target, dmg, flags, source)
	if self._Ents:IsEnemy(target, true) and source.Entity and self:IsFirstTear(source.Entity) then
		local data = self:GetTearData(source.Entity)
		local player = data.Player
		local ndata = self:GetNpcData(target)
	
		--要求目标不在命中CD，生成引物的玩家存在
		if (ndata.HitCD <= 0) and player then
			local pdata = self:GetPlayerData(player)	
			local pos = target.Position
			local timer = math.floor(math.max(4*60, 60*((player.TearRange / 40) - 2)))
			if timer > 12*60 then timer = 12*60 end
			table.insert(pdata.Area, {Timeout = timer, Wait = 0, Pos = pos})
			ndata.HitCD = 60
			
			--硫磺火兼容
			if player:HasCollectible(118) then
				self:SpawnBrimeStonePillar(player, timer, pos)
			end
		end	
	end
end
SSG:AddPriorityCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, -300, 'OnHit')

--设置生成引物的玩家(针对原版激光有生成者时伤害来源变为生产者的问题)
function SSG:SetTearPlayer(tear, player)
	local data = self:GetTearData(tear)
	data.Player = player
end

--双击发射引物
function SSG:OnDoubleTap(player, type, dir)
	if (type == 1) and not Input.IsActionPressed(ButtonAction.ACTION_MAP, player.ControllerIndex) then
		if player:HasCollectible(self.ID) and player:IsExtraAnimationFinished() and not player:IsCoopGhost() then
			local data = self:GetPlayerData(player)
			if data.CD <= 0 then
				data.CD = 240
				
				--科技/II/0.5/X/0.5兼容(引物变为激光)
				--激光有生成者时对敌人造成伤害,伤害来源是生成者,所以这里生成者是空值
				--设置生成引物的玩家直接用自定义函数
				if player:HasCollectible(68) or player:HasCollectible(152) or player:HasCollectible(244) or player:HasCollectible(395) or player:HasCollectible(524) then
					local laser = EntityLaser.ShootAngle(2, player.Position, self._Maths:DirectionToVector(dir):GetAngleDegrees(), 2, Vector(0,-20), nil)
					self:SetTearPlayer(laser, player)
					self:SetFirstTear(laser)
					laser.Parent = player
					laser.TearFlags = TearFlags.TEAR_HOMING
					laser:AddTearFlags(TearFlags.TEAR_SPECTRAL)
					laser.CollisionDamage = 7
					laser:SetColor(Color(0.1, 0.1, 0.8, 0.5, 0.25, 0.25, 1),-1,0)
					laser:Update()
				else
					local tear = Isaac.Spawn(EntityType.ENTITY_TEAR, 18, 0, player.Position, self._Maths:DirectionToVector(dir)*20, player):ToTear()
					self:SetTearPlayer(tear, player)
					self:SetFirstTear(tear)
					tear.TearFlags = TearFlags.TEAR_HOMING
					tear:AddTearFlags(TearFlags.TEAR_PIERCING)
					tear:AddTearFlags(TearFlags.TEAR_SPECTRAL)
					tear.CollisionDamage = 7
					tear:SetColor(Color(1, 1, 1, 1, 0, 0, 1),-1,0)
					tear:Update()
				end	
				sfx:Play(IBS_Sound.SSG_Fire,0.6)
			end
		end
	end	
end
SSG:AddCallback(mod.IBS_CallbackID.DOUBLE_TAP, 'OnDoubleTap')


--生成流星泪
function SSG:SpawnFalingTear(player, pos)
	--local tear = Isaac.Spawn(EntityType.ENTITY_TEAR, 18, 0, v.Pos, Vector.Zero, player):ToTear()
	local tear = player:FireTear(pos, Vector.Zero, false, true, false, player)
	local dmg = math.max(7, player.Damage)
	local scale = self._Maths:TearDamageToScale(dmg)
	local fallingSpd = player.ShotSpeed * 2
	if fallingSpd > 10 then fallingSpd = 10 end
	
	--剖腹产兼容
	if player:HasCollectible(678) then
		tear:ChangeVariant(50)
		tear:SetColor(Color(0, 0, 1, 0.5, 0.25, 0.25, 1),-1,0)
	else
		tear:ChangeVariant(18)
		tear:SetColor(Color(1, 1, 1, 1, 0, 0, 1),-1,0)
	end
	
	--突眼不兼容
	if tear:HasTearFlags(TearFlags.TEAR_SHRINK) then
		tear:ClearTearFlags(TearFlags.TEAR_SHRINK) 
	end

	--眼球不兼容
	if tear:HasTearFlags(TearFlags.TEAR_POP) then
		tear:ClearTearFlags(TearFlags.TEAR_POP) 
	end
	
	--三圣颂不兼容
	if tear:HasTearFlags(TearFlags.TEAR_LASERSHOT) then
		tear:ClearTearFlags(TearFlags.TEAR_LASERSHOT) 
	end	
	
	self:SetFallingTear(tear)
	tear.CollisionDamage = dmg
	tear.Scale = scale
	tear.Height = -800
	tear:AddTearFlags(TearFlags.TEAR_HOMING)
	tear:AddTearFlags(TearFlags.TEAR_SPECTRAL)
	tear.FallingAcceleration = fallingSpd
	tear:Update()
	
	sfx:Stop(153)
end

--射速转流星间隔
function SSG:GetWaitTime(firedelay)
	local tears = 30 / (firedelay + 1)
	local wait = 30 - math.floor(2.5*tears + 0.5)
	if wait < 7 then wait = 7 end
	return wait
end

--冷却以及流星点位更新
function SSG:OnPlayerUpdate(player)
	if player:HasCollectible(self.ID) then
		local data = self:GetPlayerData(player)
		
		--冷却
		if data.CD > 0 then
			data.Ready = false
			data.CD = data.CD - 1
		elseif data.Ready == false then
			data.Ready = true
			sfx:Play(IBS_Sound.SSG_Ready,0.6)
			player:SetColor(Color(1, 1, 1, 1, 0,0.25,1),15,2,true)
		end

		--生成落泪
		for k,v in pairs(data.Area) do
			if v.Timeout > 0 then
				if v.Wait > 0 then
					v.Wait = v.Wait - 1
				else
					v.Wait = self:GetWaitTime(player.MaxFireDelay)
					self:SpawnFalingTear(player, v.Pos)
				end		
				v.Timeout = v.Timeout - 1
			else
				data.Area[k] = nil
			end 
		end
	end
end
SSG:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, 'OnPlayerUpdate', 0)

--新房间清除点位以及彩蛋
function SSG:OnNewRoom()
	for i = 0, game:GetNumPlayers() -1 do
		local player = Isaac.GetPlayer(i)
		local data = self:GetPlayerData(player)
		for k,_ in pairs(data.Area) do
			data.Area[k] = nil
		end
	end

	local chance = math.random(1,100)
	if (chance > 80) and not game:GetRoom():IsFirstVisit() then
		for _,item in pairs(Isaac.FindByType(5,100)) do
			if item.SubType == (self.ID) then
				item:GetSprite():ReplaceSpritesheet(1, "gfx/ibs/items/collectibles/ssg_alt.png", true)
			end
		end
	end	
end
SSG:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, 'OnNewRoom')


--妈刀等兼容
function SSG:OnKnifeUpdate(knife)
	local player = self._Ents:IsSpawnerPlayer(knife, true)
	
	if player and player:HasCollectible(self.ID) then
		local data = self:GetKnifeData(knife)

		if data.Wait > 0 then
			data.Wait = data.Wait - 1
		else
			data.Wait = math.floor(self:GetWaitTime(player.MaxFireDelay) / 1.5)
			if knife:IsFlying() then
				self:SpawnFalingTear(player, knife.Position)
			end
		end
		knife:SetColor(Color(1, 1, 1, 1, 0, 0, 1),-1,0,false,true)
	end
end
SSG:AddCallback(ModCallbacks.MC_POST_KNIFE_UPDATE, 'OnKnifeUpdate')



return SSG