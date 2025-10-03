--核能电罐

local mod = Isaac_BenightedSoul
local Damage = mod.IBS_Class.Damage()

local game = Game()
local config = Isaac.GetItemConfig()
local sfx = SFXManager()

local SuperB = mod.IBS_Class.Item(mod.IBS_ItemID.SuperB)


--临时数据
function SuperB:GetData(player)
	local data = self._Ents:GetTempData(player)
	data.SuperB = data.SuperB or {
		Damage = 0,
		LaserTimeout = 0,
		LaserWait = 0
	}
	
	return data.SuperB
end

--消耗充能
function SuperB:ChainReaction(player)
	local data = self:GetData(player)
	local discharged = 0
	
	for slot = 0,2 do
		local item = player:GetActiveItem(slot)
		local itemConfig = config:GetCollectible(item)
		
		if itemConfig then
			local chargeType = itemConfig.ChargeType
			local charges = self._Players:GetSlotCharges(player, slot, true, true)

			if chargeType == 0 then
				if self._Players:DischargeSlot(player, slot, charges, false, false, true, true) then
					discharged = discharged + charges
				end	
			elseif chargeType == 1 then	
				local maxCharges = itemConfig.MaxCharges
				if charges >= maxCharges then
					if self._Players:DischargeTimedSlot(player, slot, maxCharges, false, true, true) then
						discharged = discharged + math.max(0.5, math.ceil(maxCharges / 300))
					end
				end
			end

			data.LaserTimeout = data.LaserTimeout + math.floor(60*discharged)
		end
	end
	
	return discharged
end

--受伤触发
function SuperB:OnTakeDamage(entity, dmg, flag, source)
	if dmg <= 0 then return end
	local player = entity:ToPlayer()
	
	if player and not Damage:IsPlayerSelfDamage(player, flag, source) then
		if player:HasCollectible(self.ID) then
			local data = self:GetData(player)
			
			if (data.LaserTimeout <= 0) and (self:ChainReaction(player) > 0) then
				data.LaserTimeout = data.LaserTimeout + 400
				Isaac.Explode(player.Position, player, 0)

				local smoke = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.SMOKE_CLOUD, 0, player.Position, Vector.Zero, player):ToEffect()
				local creep = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.PLAYER_CREEP_GREEN, 0, player.Position, Vector.Zero, player):ToEffect()
				creep.Parent = player
				creep.CollisionDamage = 0 --仍有伤害
				creep.Timeout = -1
				creep.Scale = 4
				creep.Color = Color(0,1,1,0.5)
				creep:Update()
			end	
		end	
	elseif self._Ents:IsEnemy(entity) then
		for i = 0, game:GetNumPlayers() -1 do
			local player = Isaac.GetPlayer(i)
			if player:HasCollectible(self.ID) then
				local data = self:GetData(player)

				if data.Damage > 200 then
					data.Damage = data.Damage - 200
					for slot = 0,2 do
						local item = player:GetActiveItem(slot)
						local itemConfig = config:GetCollectible(item)
						local chargeType = (itemConfig and itemConfig.ChargeType) or -1
						
						if chargeType == 0 then
							self._Players:ChargeSlot(player, slot, 1, false, true, true, true)
						end
					end
				else
					data.Damage = data.Damage + dmg
				end
				
				for slot = 0,2 do
					local item = player:GetActiveItem(slot)
					local itemConfig = config:GetCollectible(item)
					local chargeType = (itemConfig and itemConfig.ChargeType) or -1
					
					if chargeType == 1 then
						self._Players:ChargeTimedSlot(player, slot, math.max(1, math.floor(dmg)), true)
					end
				end				
			end	
		end
	end	
end
SuperB:AddCallback(ModCallbacks.MC_POST_ENTITY_TAKE_DMG, 'OnTakeDamage')

--更新状态
function SuperB:OnUpdate(player)
	local data = self._Ents:GetTempData(player).SuperB

	if data then
		if player:HasCollectible(self.ID) then
			if data.LaserTimeout > 0 then

				--爆炸
				if player:IsFrame(30,0) then
					if data.LaserTimeout >= 999 then
						data.LaserTimeout = math.max(10, data.LaserTimeout - 666)

						local smoke = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.SMOKE_CLOUD, 0, player.Position, Vector.Zero, player):ToEffect()
						game:BombExplosionEffects(player.Position, 466, TearFlags.TEAR_BURN | TearFlags.TEAR_POISON, Color(0,1,0,1), player, 3, true, false, DamageFlag.DAMAGE_EXPLOSION | DamageFlag.DAMAGE_IGNORE_ARMOR)
						game:GetLevel():GetCurrentRoom():MamaMegaExplosion(player.Position)
						
						--正邪削弱(东方mod)
						--炸死你
						if mod.IBS_Compat.THI:SeijaNerf(player) then
							player:TakeDamage(666, DamageFlag.DAMAGE_EXPLOSION, EntityRef(player), 0)
						end
					end
				end

				data.LaserTimeout = data.LaserTimeout - 1
				self:ChainReaction(player)
				
				if data.LaserWait > 0 then
					data.LaserWait = data.LaserWait - 1
				else
					data.LaserWait = math.random(3, math.max(5, 120 - math.floor(data.LaserTimeout / 5)))
					
					for i = math.min(1, 1 + math.floor(data.LaserTimeout / 60)),13 do 
						local laser = EntityLaser.ShootAngle(2, player.Position, RandomVector():GetAngleDegrees(), 2, Vector(0,-20), player)
						laser:SetMaxDistance(player.TearRange / 3)
						laser.LaserLength = 3
						laser.CollisionDamage = math.max(3.5, player.Damage)
						laser:AddTearFlags(TearFlags.TEAR_SPECTRAL)
						laser:AddTearFlags(TearFlags.TEAR_POISON)
						laser:AddTearFlags(TearFlags.TEAR_SHIELDED)
						laser.Color = Color(1,1,1,0.5,2,2,0)
						laser:Update()
					end
				end	
					
			end	
		else
			self._Ents:GetTempData(player).SuperB = nil
		end
	end
end
SuperB:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, 'OnUpdate')


return SuperB