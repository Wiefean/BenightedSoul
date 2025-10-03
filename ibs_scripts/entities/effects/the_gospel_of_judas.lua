--犹大福音

local mod = Isaac_BenightedSoul
local IBS_EffectID = mod.IBS_EffectID
local IBS_PlayerID = mod.IBS_PlayerID
local BC4 = mod.IBS_Achiev.Challenge[4]

local game = Game()
local sfx = SFXManager()

local TGOJ = mod.IBS_Class.Effect{
	Variant = IBS_EffectID.TGOJ.Variant,
	SubType = IBS_EffectID.TGOJ.SubType,
	Name = {zh = '犹大福音', en = 'The Gospel Of Judas'}
}

--获取玩家数据
function TGOJ:GetPlayerData(player)
	return (mod.IBS_Item and mod.IBS_Item.TGOJ and mod.IBS_Item.TGOJ:GetPlayerData(player)) or {Points = 0, DMGUp = 0}
end

--书本数据
function TGOJ:GetBookData(effect)
	local data = self._Ents:GetTempData(effect)
	data.TGOJ_EFFECT = data.TGOJ_EFFECT or {
		State = "Go",
		Timeout = 270,
		Slot = nil,
		TargetPosition = Vector.Zero,
		DashLeft = 4
	}
	
	return data.TGOJ_EFFECT
end

--生成书本
function TGOJ:Spawn(player, spawnPos, targetPos, timeout, slot, flyingDMG)
	spawnPos = spawnPos or player.Position
	targetPos = targetPos or spawnPos
	timeout = timeout or 270
	flyingDMG = flyingDMG or 6.5

	local book = Isaac.Spawn(1000, self.Variant, 0, spawnPos, Vector.Zero, player):ToEffect()
	local data = self:GetBookData(book)
	data.Timeout = timeout
	data.TargetPosition = targetPos
	data.Slot = slot
	book.CollisionDamage = flyingDMG
	
	return book
end


--初始化
function TGOJ:OnEffectInit(effect)
	self._Ents:ApplyTrail(effect, Color(0.6,0.6,0.6,1), Vector(2,2)) --拖尾
	effect.DepthOffset = 70 --使图层处于上层
end
TGOJ:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, 'OnEffectInit', TGOJ.Variant)

--书本逻辑
function TGOJ:OnEffectUpdate(effect)
	local data = self._Ents:GetTempData(effect).TGOJ_EFFECT
	local player = self._Ents:IsSpawnerPlayer(effect)
	
	if data and player then
		local spr = effect:GetSprite()

		if data.State == "Go" then
			local vec = data.TargetPosition - effect.Position
			effect.Velocity = vec:Resized(15)
			spr:Play("Moving", false)
			spr.Rotation = spr.Rotation + 4
			
			--为了让旋转看起来更流畅，采用延迟触发的方式
			self:DelayFunction(function() spr.Rotation = spr.Rotation + 4 end ,1)
			self:DelayFunction(function() spr.Rotation = spr.Rotation + 4 end ,2)
			self:DelayFunction(function() spr.Rotation = spr.Rotation + 4 end ,3)
			
			if vec:Length() <= 10 then
				spr.Rotation = 0
				effect.Velocity = Vector.Zero
				data.State = "Opening"
			end
		elseif data.State == "Opening" then
			spr:Play("Opening", false)
			
			if spr:IsEventTriggered("sound") then
				sfx:Play(SoundEffect.SOUND_PAPER_IN, 1, 3, false, 0.666)
			end
			
			if spr:IsFinished("Opening") then 
				data.State = "Idle" 
			end
		elseif data.State == "Idle" then
			spr:Play("Idle", false)
			spr:PlayOverlay("Sparkle", false)
			
			local pos = effect.Position + Vector(0,20)
			local range = 90
			local pdata = self:GetPlayerData(player)
		
			--吸收敌弹
			for _,bullet in pairs(Isaac.FindInRadius(effect.Position, range, EntityPartition.BULLET)) do
				bullet.Velocity = (pos - bullet.Position):Resized(7)
				if bullet.Position:Distance(pos) <= 12 then
					pdata.Points = pdata.Points + 1
				
					if pdata.Points >= 13 then
						pdata.Points = pdata.Points - 13
						
						--我释放恶魂
						Isaac.Spawn(1000, 189, 0, player.Position, Vector.Zero, player)
		
						--美德书兼容
						if player:HasCollectible(584) then
							player:AddWisp(33, player.Position)
							player:AddWisp(34, player.Position)
						end					
					end					

					--彼列书兼容
					if player:HasCollectible(59) then
						pdata.DMGUp = pdata.DMGUp + 0.2
						player:AddCacheFlags(CacheFlag.CACHE_DAMAGE, true)
					end

					--昧化犹大长子权
					if (player:GetPlayerType() == IBS_PlayerID.BJudas) and player:HasCollectible(619) then
						local target = self._Finds:ClosestEnemy(pos)
						if target ~= nil then
							local tear = player:FireTear(pos, (target.Position - pos):Resized(13), true, false, false, player)
							tear.CollisionDamage = math.max(3.5, tear.CollisionDamage)
						end	
					end
					bullet:Remove()
				end
			end
			
			--虚弱敌人
			if BC4:IsFinished() or BC4:Challenging() then
				for _,target in pairs(Isaac.FindInRadius(effect.Position, range, EntityPartition.ENEMY)) do
					if self._Ents:IsEnemy(target) then
						target:AddWeakness(EntityRef(effect), 1)
					end
				end
			end
		elseif data.State == "Recycle" then
			local vec = player.Position - effect.Position
			effect.Velocity = vec:Resized(15)
			spr:Play("Closing", false)
			spr.Rotation = spr.Rotation + 4
			self:DelayFunction(function() spr.Rotation = spr.Rotation + 4 end ,1)
			self:DelayFunction(function() spr.Rotation = spr.Rotation + 4 end ,2)
			self:DelayFunction(function() spr.Rotation = spr.Rotation + 4 end ,3)
			
			if spr:IsEventTriggered("sound") then
				sfx:Play(SoundEffect.SOUND_PAPER_OUT, 1, 3, false, 0.777)
			end			

			if vec:Length() <= math.max(30, 30*(player.SpriteScale.X), 30*(player.SpriteScale.Y)) then
				effect:Remove()
				sfx:Play(SoundEffect.SOUND_BOOK_PAGE_TURN_12, 1, 3, false, 0.777)
			end			
		end

		--属性修正以及飞行时碰撞伤害
		if (data.State ~= "Go") and (data.State ~= "Recycle") then
			spr.Rotation = 0
			effect.Velocity = Vector.Zero
		elseif (data.State == "Go") or (data.State == "Recycle") then
			for _,target in pairs(Isaac.FindInRadius(effect.Position, 30, EntityPartition.ENEMY)) do
				if self._Ents:IsEnemy(target, true) then
					target:TakeDamage(effect.CollisionDamage, 0, EntityRef(effect), 0)
				end
			end
		end

		if data.Timeout > 0 then
			data.Timeout = data.Timeout - 1
		else
			data.State = "Recycle"
		end
	else
		effect:Remove()
	end		
end
TGOJ:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, 'OnEffectUpdate', TGOJ.Variant)


return TGOJ