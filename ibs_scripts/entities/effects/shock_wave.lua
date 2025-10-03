--震荡波特供版
--[[
SubType = {
	OnlyHurtEnemy = 0, --针对敌人
	HurtEnemyAndPlayer = 1, --伤害敌人和玩家
	OnlyHurtPlayer = 2, --针对玩家
},
]]

local mod = Isaac_BenightedSoul
local IBS_EffectID = mod.IBS_EffectID
local IronHeart = mod.IBS_Class.IronHeart()

local game = Game()
local sfx = SFXManager()

local ShockWave = mod.IBS_Class.Effect{
	Variant = IBS_EffectID.ShockWave.Variant,
	SubType = IBS_EffectID.ShockWave.SubType,
	Name = {zh = '震荡波', en = 'Shock Wave'}
}

--临时数据
function ShockWave:GetData(effect)
	local data = self._Ents:GetTempData(effect)
	data.ShockWave_Effect = data.ShockWave_Effect or {
		Damage = 0,
		TearFlags = 0, --眼泪特效(位运算)
		HasSpread = false, --是否已传播过
		SpreadDir = Vector.Zero, --传播方向
		SpreadNum = 0, --最大传播数量
		
		--以下主要用于内部
		SpreadLeft = 0, --传播剩余数量
		SpreadInterval = 24, --传播距离间隔
		SpreadMaxTimeout = 30, --传播最大计时
		SpreadTimeout = 30, --传播计时
		GroupName = '', --组名,方便后期判断
		Index = '', --编号,方便后期判断
	}
	
	return data.ShockWave_Effect
end

--生成
function ShockWave:Spawn(pos, spawner, subType, dmg, tearFlags, scale, spreadDir, spreadNum, spreadTimeout, groupName, index, spreadLeft, spreadInterval)
	scale = scale or 1
	pos = game:GetRoom():GetClampedPosition(pos, scale*20)
	local effect = Isaac.Spawn(1000, self.Variant, subType or 0, pos, Vector.Zero, spawner):ToEffect()
	local data = self:GetData(effect)
	effect.Scale = scale
	data.Damage = dmg or 0
	data.TearFlags = tearFlags or 0
	data.SpreadDir = (spreadDir and spreadDir:Normalized()) or Vector.Zero
	data.SpreadNum = spreadNum or 0
	data.SpreadLeft = spreadLeft or spreadNum or 0
	data.SpreadInterval = spreadInterval or 24
	data.SpreadMaxTimeout = spreadTimeout or 30
	data.SpreadTimeout = data.SpreadMaxTimeout or 30
	data.GroupName = groupName or 'i have no group =('
	data.Index = index or 0
	
	return effect
end


--初始化
function ShockWave:OnInit(effect)
	local room = game:GetRoom()
	local spr = effect:GetSprite()
	local anim = 'Break'
	local path = ''
	local womb = false
	
	--根据背景调整贴图和动画
	local bg = room:GetBackdropType()
	if bg == BackdropType.CAVES or bg == BackdropType.CATACOMBS then
		path = 'gfx/ibs/effects/effect_062_groundbreakcaves.png'
	elseif bg == BackdropType.MINES then
		path = 'gfx/ibs/effects/effect_062_groundbreakmines.png'

		--检测岩浆池
		local width = room:GetGridWidth()
		local height = room:GetGridHeight()		
		for x = 1, width - 1 do
			for y = 1, height - 1 do
				local gridIndex = x + y * width
				local gridEnt = room:GetGridEntity(gridIndex)
				if gridEnt and gridEnt:ToPit() then
					path = 'gfx/ibs/effects/effect_062_groundbreakmineslava.png'
					break
				end
			end
		end		
	elseif bg == BackdropType.ASHPIT then
		path = 'gfx/ibs/effects/effect_062_groundbreakmineslava.png'
	elseif bg == BackdropType.DEPTHS or bg == BackdropType.NECROPOLIS or bg == BackdropType.DANK_DEPTHS then
		path = 'gfx/ibs/effects/effect_062_groundbreakdepths.png'
	elseif bg == BackdropType.MAUSOLEUM then
		path = 'gfx/ibs/effects/effect_062_groundbreakmausoleum.png'
	elseif bg == BackdropType.WOMB or bg == BackdropType.UTERO or bg == BackdropType.SCARRED_WOMB or bg == BackdropType.CORPSE3 then
		path = 'gfx/ibs/effects/effect_062_groundbreakwomb.png'
		womb = true
	elseif bg == BackdropType.BLUE_WOMB then
		path = 'gfx/ibs/effects/effect_062_groundbreakbluewomb.png'
		womb = true
	elseif bg == BackdropType.CORPSE then
		path = 'gfx/ibs/effects/effect_062_groundbreakcorpse.png'
		womb = true
	elseif bg == BackdropType.CORPSE2 then
		path = 'gfx/ibs/effects/effect_062_groundbreakcorpse2.png'
		womb = true
	end
	
	if path ~= '' then
		spr:ReplaceSpritesheet(0, path, true)
	end

	if womb then
		anim = 'WombBreak'..math.random(1,3)
	end
	
	spr:Play(anim, true)
end
ShockWave:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, 'OnInit', ShockWave.Variant)


--逻辑
function ShockWave:OnUpdate(effect)
	local room = game:GetRoom()
	local spr = effect:GetSprite()
	local data = self._Ents:GetTempData(effect).ShockWave_Effect
	if not data then return end
	local scale = effect.Scale or 1
	local subType = effect.SubType
	local HIT = false

	spr.Scale = Vector(scale, scale) --调整贴图大小

	--碰撞判定
	if not HIT then
		if subType ~= 2 then --对敌人
			for _,ent in pairs(Isaac.GetRoomEntities()) do
				if (self._Ents:IsEnemy(ent, true) or ent.Type == 17) and effect.Position:Distance(ent.Position) <= 30*scale + 1.2*ent.Size then
					HIT = true
					break
				end
			end
		end
		if subType ~= 0 then --对玩家
			for _,ent in pairs(Isaac.FindInRadius(effect.Position, scale * 15, EntityPartition.PLAYER)) do
				HIT = true
				break
			end
		end
	end

	--伤害判定
	if spr:IsEventTriggered('Damage') then
		local player = self._Ents:IsSpawnerPlayer(effect)
		
		--推开掉落物
		for _,ent in pairs(Isaac.FindInRadius(effect.Position, scale * 15, EntityPartition.PICKUP)) do
			ent.Velocity = ent.Velocity + data.SpreadDir:Resized((3 - 0.1*data.SpreadMaxTimeout) * 0.01*math.random(100,200))
		end		
		
		--对敌人造成伤害(包括背景店长)
		if subType ~= 2 then
			local sinData = (mod.IBS_Player and mod.IBS_Player.BMaggy:GetSinData())
		
			for _,ent in pairs(Isaac.GetRoomEntities()) do
				if effect.Position:Distance(ent.Position) <= 30*scale + 1.2*ent.Size then				
					if (self._Ents:IsEnemy(ent, true) or ent.Type == 17) then
						if data.Damage > 0 then					
							ent:TakeDamage(data.Damage, 0, EntityRef(effect.SpawnerEntity), 1)

							--恢复铁心
							if player and IronHeart:Check(player) and (room:GetType() ~= RoomType.ROOM_DEFAULT or room:IsFirstVisit() or game:IsGreedMode()) then
								local IHData = IronHeart:GetData(player)
								local recover = math.min(1, 0.07*data.Damage)
								
								--贪婪达4则恢复更多
								if sinData and sinData.Greed >= 4 then
									recover = recover + 0.3
								end
								
								IHData.Recover = IHData.Recover + recover
							end
						end
						
						--吐根爆炸
						if data.TearFlags & TearFlags.TEAR_EXPLOSIVE > 0 then
							local color = Color(1,1,1,1)
							if player then
								color = player.TearColor
							end
							game:BombExplosionEffects(effect.Position, 0.5*data.Damage, data.TearFlags, color, effect.SpawnerEntity, 0.75*scale)
						end	
					elseif ent:ToProjectile() then
						--清除敌弹
						local proj = ent:ToProjectile()
						if proj and not proj:HasProjectileFlags(ProjectileFlags.CANT_HIT_PLAYER) then
							proj:Die()
						end
					elseif ent:ToPickup() and ent.Variant == 51 then
						--开石箱
						if player then
							ent:ToPickup():TryOpenChest(player)
						end
					end
				end
			end
		end
		
		--破门效果
		for slot = 0,7 do
			local door = room:GetDoor(slot)
			if door ~= nil and effect.Position:Distance(door.Position) <= 70*scale then
				door:TryBlowOpen(true, effect)
			end
		end
		
		--摧毁障碍物
		local width = room:GetGridWidth()
		local height = room:GetGridHeight()
		for x = 1, width - 1 do
			for y = 1, height - 1 do
				local gridIndex = x + y * width
				local gridEnt = room:GetGridEntity(gridIndex)
				
				if gridEnt and (gridEnt.Position:Distance(effect.Position) <= scale * 30) then
					if gridEnt:ToPit() then
						--排除大撒旦房间
						if room:GetBossID() ~= 55 then						
							gridEnt:ToPit():MakeBridge(nil)
						end
					else					
						gridEnt:Hurt(7)
						room:DestroyGrid(gridIndex, false)
					end
				end
			end
		end

		if subType ~= 0 then
			--对玩家造成伤害
			for _,ent in pairs(Isaac.FindInRadius(effect.Position, scale * 15, EntityPartition.PLAYER)) do
				local player = ent:ToPlayer()
				player:TakeDamage(1, 0, EntityRef(effect.SpawnerEntity), 60)
				player:SetMinDamageCooldown(60)
			end
		end
		
		--音效
		sfx:Play(137, 0.5)
	end
	
	--传播
	if data.SpreadTimeout > 0 then
		data.SpreadTimeout = data.SpreadTimeout - 1
	else
		if data.SpreadLeft > 0 and not data.HasSpread then
			data.HasSpread = true
			
			local spreadLeft = data.SpreadLeft - 1
			
			
			--追踪效果
			if data.TearFlags & TearFlags.TEAR_HOMING > 0 then
				local target = self._Finds:ClosestEnemy(effect.Position)
				if target ~= nil and target.Position:Distance(effect.Position) <= 90 then				
					data.SpreadDir = (target.Position - effect.Position):Normalized()
				end
			end
			
			--如果下一个位置超出房间,则停止
			local nextPos = effect.Position + scale * data.SpreadInterval * data.SpreadDir
			if not room:IsPositionInRoom(nextPos, scale*20) then
				spreadLeft = 0
			end			
			
			--分裂弹
			if HIT or data.Index >= math.floor(data.SpreadNum / 3) then			
				if data.TearFlags & TearFlags.TEAR_SPLIT > 0 or data.TearFlags & TearFlags.TEAR_QUADSPLIT > 0 then
					data.TearFlags = data.TearFlags &~ TearFlags.TEAR_SPLIT
					data.TearFlags = data.TearFlags &~ TearFlags.TEAR_QUADSPLIT
					
					--中途分裂		
					for i = 0,3 do
						local angle = i*math.random(7,14)
						self:Spawn(nextPos, effect.SpawnerEntity, subType, data.Damage * 0.5, data.TearFlags, scale * 0.5, data.SpreadDir:Rotated((-1)^i * angle), data.SpreadNum, data.SpreadMaxTimeout, data.GroupName, 0, spreadLeft)		
					end
					
					--原震荡波停止
					spreadLeft = 0
					data.TearFlags = data.TearFlags &~ TearFlags.TEAR_BOOMERANG	
					data.TearFlags = data.TearFlags &~ TearFlags.TEAR_BOUNCE
				end
			end
			
			--煤块成长
			if data.TearFlags & TearFlags.TEAR_GROW > 0 then
				scale = scale + 0.02
				data.Damage = data.Damage + 0.56
			end
			
			--突眼衰减
			if data.TearFlags & TearFlags.TEAR_SHRINK > 0 then
				scale = scale - 0.2
				data.Damage = data.Damage - 0.15 * data.Damage
				
				--衰减完毕
				if scale <= 0 or data.Damage <= 0 then
					spreadLeft = 0
					data.TearFlags = data.TearFlags &~ TearFlags.TEAR_BOOMERANG	
					data.TearFlags = data.TearFlags &~ TearFlags.TEAR_BOUNCE				
				end
			end
			
			--传播
			self:Spawn(nextPos, effect.SpawnerEntity, subType, data.Damage, data.TearFlags, scale, data.SpreadDir, data.SpreadNum, data.SpreadMaxTimeout, data.GroupName, data.Index + 1, spreadLeft)
			
			if spreadLeft == 0 then
				--镜子或橡胶回返
				if data.TearFlags & TearFlags.TEAR_BOOMERANG > 0 or data.TearFlags & TearFlags.TEAR_BOUNCE > 0 then
					data.TearFlags = data.TearFlags &~ TearFlags.TEAR_BOOMERANG
					data.TearFlags = data.TearFlags &~ TearFlags.TEAR_BOUNCE
					self:Spawn(nextPos, effect.SpawnerEntity, subType, data.Damage, data.TearFlags, scale, data.SpreadDir:Rotated(180), data.SpreadNum, data.SpreadMaxTimeout, data.GroupName)
				end	
			end
			
		end
	end
	
	--移除
	if data.SpreadTimeout <= 0 then
		if spr:IsFinished("Break") or spr:IsFinished("WombBreak1") or spr:IsFinished("WombBreak2") or spr:IsFinished("WombBreak3") then
			effect:Remove()
		end
	end		
end
ShockWave:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, 'OnUpdate', ShockWave.Variant)



return ShockWave