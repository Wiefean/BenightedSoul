--核能电罐

local mod = Isaac_BenightedSoul
local IBS_Item = mod.IBS_Item
local Ents = mod.IBS_Lib.Ents
local Players = mod.IBS_Lib.Players
local Maths = mod.IBS_Lib.Maths

local config = Isaac.GetItemConfig()

local sfx = SFXManager()

--临时数据
local function GetSuperBData(player)
	local data = Ents:GetTempData(player)
	data.SuperB = data.SuperB or {
		Damage = 0,
		LaserTimeOut = 0,
		LaserWait = 0
	}
	
	return data.SuperB
end

--消耗充能
local function ChainReaction(player)
	local data = GetSuperBData(player)
	local discharged = 0
	
	for slot = 0,2 do
		local item = player:GetActiveItem(slot)
		local itemConfig = config:GetCollectible(item)
		
		if itemConfig then
			local chargeType = itemConfig.ChargeType
			local charges = Players:GetSlotCharges(player, slot, true, true)
			local maxCharges = itemConfig.MaxCharges
			
			if charges > maxCharges then
				local cost = charges - maxCharges
				if chargeType == 0 then
					if Players:DischargeSlot(player, slot, cost, false, false, true, true) then
						discharged = discharged + cost
					end	
				elseif chargeType == 1 then	
					if Players:DischargeTimedSlot(player, slot, cost, false, true, true) then
						discharged = discharged + 0.05
					end	
				end	
			end	
			data.LaserTimeOut = data.LaserTimeOut + math.floor(60*discharged)
		end
	end
	
	return discharged
end

--受伤触发
local function OnTakeDamage(_,entity, dmg)
	local player = entity:ToPlayer()
	
	if player then
		if player:HasCollectible(IBS_Item.superb) then
			local data = GetSuperBData(player)
			
			if (data.LaserTimeOut <= 0) and (ChainReaction(player) > 0) then
				data.LaserTimeOut = data.LaserTimeOut + 400
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
	elseif Ents:IsEnemy(entity) then
		for i = 0, Game():GetNumPlayers() -1 do
			local player = Isaac.GetPlayer(i)
			if player:HasCollectible(IBS_Item.superb) then
				local data = GetSuperBData(player)
				
				if data.Damage > 200 then
					data.Damage = data.Damage - 200
					for slot = 0,2 do
						local item = player:GetActiveItem(slot)
						local itemConfig = config:GetCollectible(item)
						local chargeType = (itemConfig and itemConfig.ChargeType) or -1
						
						if chargeType == 0 then
							Players:ChargeSlot(player, slot, 1, false, true, true, true)
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
						Players:ChargeTimedSlot(player, slot, math.max(1, math.floor(dmg)), true)
					end
				end				
			end	
		end
	end	
end
mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, OnTakeDamage)

--更新状态
local function OnUpdate(_,player)
	local data = Ents:GetTempData(player).SuperB

	if data then
		if player:HasCollectible(IBS_Item.superb) then
			if data.LaserTimeOut > 0 then
				
				--爆炸
				if (player.FrameCount / 60) % 2 == 0 then
					if data.LaserTimeOut >= 1022 then
						data.LaserTimeOut = data.LaserTimeOut - 999
						
						local smoke = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.SMOKE_CLOUD, 0, player.Position, Vector.Zero, player):ToEffect()
						local game = Game()
						game:BombExplosionEffects(player.Position, 799, TearFlags.TEAR_BURN | TearFlags.TEAR_POISON, Color(0,1,0,1), player, 3, true, false, DamageFlag.DAMAGE_EXPLOSION | DamageFlag.DAMAGE_IGNORE_ARMOR)
						game:GetLevel():GetCurrentRoom():MamaMegaExplosion(player.Position)
						
						--正邪削弱(东方mod)
						if mod:THI_WillSeijaNerf(player) then
							player:TakeDamage(999, DamageFlag.DAMAGE_EXPLOSION, EntityRef(player), 0)
						end
					end
				end
			
				data.LaserTimeOut = data.LaserTimeOut - 1
				ChainReaction(player)
				
				if data.LaserWait > 0 then
					data.LaserWait = data.LaserWait - 1
				else
					data.LaserWait = math.random(3, math.max(5, 120 - math.floor(data.LaserTimeOut / 5)))
					
					for i = math.min(1, 1 + math.floor(data.LaserTimeOut / 60)),13 do 
						local laser = EntityLaser.ShootAngle(2, player.Position, RandomVector():GetAngleDegrees(), 2, Vector(0,-20), player)
						laser:SetMaxDistance(player.TearRange / 3)
						laser.LaserLength = 3
						laser.CollisionDamage = math.max(2, player.Damage / 2)
						laser:AddTearFlags(TearFlags.TEAR_SPECTRAL)
						laser:AddTearFlags(TearFlags.TEAR_POISON)
						laser:AddTearFlags(TearFlags.TEAR_SHIELDED)
						laser.Color = Color(1,1,1,0.5,2,2,0)
						laser:Update()
					end
				end	
					
			end	
		else
			Ents:GetTempData(player).SuperB = nil
		end
	end
end
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, OnUpdate)
