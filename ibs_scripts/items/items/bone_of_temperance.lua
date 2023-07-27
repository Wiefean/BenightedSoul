--节制之骨

local mod = Isaac_BenightedSoul
local IBS_Callback = mod.IBS_Callback
local IBS_Item = mod.IBS_Item
local IBS_Sound = mod.IBS_Sound
local Ents = mod.IBS_Lib.Ents
local Maths = mod.IBS_Lib.Maths
local Stats = mod.IBS_Lib.Stats

local sfx = SFXManager()

--临时眼泪数据(科X激光也可使用)
local function GetTearData(tear)
	local data = Ents:GetTempData(tear)
	data.BoneOfTemperance_Tear = data.BoneOfTemperance_Tear or {
		Stop = false,
		Recycle = false,
		TimeOut = 210
	}
	return data.BoneOfTemperance_Tear
end

--临时妈刀数据(常规激光也可使用)
local function GetKnifeData(knife)
	local data = Ents:GetTempData(knife)
	data.BoneOfTemperance_Knife = data.BoneOfTemperance_Knife or {Wait = 0}

	return data.BoneOfTemperance_Knife
end

--判断是否为仰望星空的下落眼泪
local function IsSSGFallingTear(tear)
	local data = Ents:GetTempData(tear).SHOOTINGSTARS_TEAR

	if data and data.Other then
		return true
	end
	
	return false
end

--眼泪
mod:AddCallback(ModCallbacks.MC_POST_FIRE_TEAR, function(_,tear)
    local ent = tear.SpawnerEntity
	local player = (ent and ent:ToPlayer())
	
    if player and player:HasCollectible(IBS_Item.bone) and not IsSSGFallingTear(tear) then
		local data = GetTearData(tear)
		if player:HasCollectible(678) then
			data.TimeOut = 600
		else
			data.TimeOut = 210
		end

		tear:AddTearFlags(TearFlags.TEAR_SPECTRAL)
		tear:AddTearFlags(TearFlags.TEAR_PIERCING)
    end
end)
mod:AddCallback(ModCallbacks.MC_POST_TEAR_UPDATE, function(_,tear)
	if not IsSSGFallingTear(tear) then
		local ent = tear.SpawnerEntity
		if ent then
			local player = ent:ToPlayer()
			
			if player and player:HasCollectible(IBS_Item.bone) then
				local data = GetTearData(tear)
				tear.FallingSpeed = 0
				tear.FallingAcceleration = -0.1
				
				if data.Stop and not data.Recycle then
					tear.Velocity = Vector.Zero
				elseif data.Recycle then
					tear.Velocity = 30*((player.Position - tear.Position):Normalized())
					if (tear.Position - player.Position):Length() <= 2*(player.Size) then
						tear:Remove()
					end
				end
				
				if data.TimeOut > 0 then
					data.TimeOut = data.TimeOut - 1
				elseif not data.Recycle then
					data.Recycle = true
				end
			end	
		end
	end	
end)

--常规激光兼容(包括硫磺火)
mod:AddCallback(ModCallbacks.MC_POST_LASER_UPDATE, function(_,laser)
	if laser.SubType == 0 then
		local player = nil

		if laser.SpawnerEntity then
			player = laser.SpawnerEntity:ToPlayer()
		end
		
		if player and player:HasCollectible(IBS_Item.bone) then
			local data = GetKnifeData(laser)

			if data.Wait > 0 then
				data.Wait = data.Wait - 1
			else
				data.Wait = 6
				local tear = player:FireTear(laser.EndPoint + 20 * RandomVector(), Vector.Zero, false, true, false)
				local tdata = GetTearData(tear)
				local dmg = math.max(3.5, player.Damage)
				
				tdata.Stop = true
				if player:HasCollectible(678) then
					tdata.TimeOut = 600
				else
					tdata.TimeOut = 210
				end
				
				tear.CollisionDamage = dmg
				tear.Scale = Maths:TearDamageToScale(dmg)
				tear.FallingSpeed = 0
				tear.FallingAcceleration = -0.1	
				tear:ChangeVariant(37)
				tear:Update()
				
				sfx:Stop(153)
			end			
		end	
	end
end)

--科技X兼容
mod:AddCallback(ModCallbacks.MC_POST_LASER_UPDATE, function(_,laser)
	if laser.SubType == 2 then
		local ent = laser.SpawnerEntity
		if ent then
			local player = ent:ToPlayer()
			
			if player and player:HasCollectible(IBS_Item.bone) then
				local data = GetTearData(laser)			
				
				if data.Stop and not data.Recycle then
					laser.Velocity = Vector.Zero
				elseif data.Recycle then
					laser.Velocity = 30*((player.Position - laser.Position):Normalized())
					if (laser.Position - player.Position):Length() <= 2*(player.Size) then
						laser:Remove()
					end
				end
				
				if data.TimeOut > 0 then
					data.TimeOut = data.TimeOut - 1
				elseif not data.Recycle then
					data.Recycle = true
				end
			end	
		end
	end	
end)

--妈刀等兼容
mod:AddCallback(ModCallbacks.MC_POST_KNIFE_UPDATE, function(_,knife)
	local player = nil

	if knife.SpawnerEntity then
		player = knife.SpawnerEntity:ToPlayer()
	end
	
	if player and player:HasCollectible(IBS_Item.bone) then
		local data = GetKnifeData(knife)

		if data.Wait > 0 then
			data.Wait = data.Wait - 1
		else
			data.Wait = 9
			if knife:IsFlying() then
			local tear = player:FireTear(knife.Position, Vector.Zero, false, true, false)
			local tdata = GetTearData(tear)
			local dmg = math.max(3.5, player.Damage)
			
			tdata.Stop = true
			if player:HasCollectible(678) then
				tdata.TimeOut = 600
			else
				tdata.TimeOut = 210
			end
	
			tear.CollisionDamage = dmg
			tear.Scale = Maths:TearDamageToScale(dmg)
			tear.FallingSpeed = 0
			tear.FallingAcceleration = -0.1
			
			if (knife.Variant == 0) then --经典妈刀对应金属子弹
				tear:ChangeVariant(3)
			elseif (knife.Variant == 2) then --骨刀棒对应镰刀子弹(骨棒对应骨头子弹，不知为何自动设置了)
				tear:ChangeVariant(8)
			elseif (knife.Variant == 3) or (knife.Variant == 5) then --驴骨棒和血吸管对应血泪
				tear:ChangeVariant(1)
			elseif (knife.Variant == 10) then --妈刀配英灵剑对应剑气
				tear:ChangeVariant(47)
			elseif (knife.Variant == 11) then --妈刀配英灵剑配科技对应激光剑气
				tear:ChangeVariant(49)	
			end	
			
			tear:Update()
			
			sfx:Stop(153)
			end			
		end
	end
end)

--为悬浮加射速和弹速
mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, function(_,player, flag)
	if player:HasCollectible(IBS_Item.bone) and player:HasCollectible(329) then
		if flag == CacheFlag.CACHE_SHOTSPEED then
			Stats:ShotSpeed(player, 1)
		end
		if flag == CacheFlag.CACHE_FIREDELAY then
			Stats:TearsModifier(player, 1, true)
		end		
	end	
end)

--双击
mod:AddCallback(IBS_Callback.PLAYER_DOUBLE_TAP, function(_,player, type, action)
	if (type == 2) and (action == ButtonAction.ACTION_DROP) then
		if player:HasCollectible(IBS_Item.bone) then
			local game = Game()
			if (not game:IsPaused()) and (player:AreControlsEnabled()) then
				for _,tear in pairs(Isaac.FindByType(EntityType.ENTITY_TEAR)) do
					local ent = tear.SpawnerEntity
					local entPlayer = (ent and ent:ToPlayer())
					
					if entPlayer and GetPtrHash(entPlayer) == GetPtrHash(player) then
						local data = GetTearData(tear)
						if not data.Stop then
							data.Stop = true
							if player:HasCollectible(678) then
								data.TimeOut = 600
							else
								data.TimeOut = 210
							end
						end
					end	
				end	
				for _,laser in pairs(Isaac.FindByType(EntityType.ENTITY_LASER)) do
					local ent = laser.SpawnerEntity
					local entPlayer = (ent and ent:ToPlayer())
					
					if entPlayer and GetPtrHash(entPlayer) == GetPtrHash(player) then
						local data = GetTearData(laser)
						if not data.Stop then
							data.Stop = true
							if player:HasCollectible(678) then
								data.TimeOut = 600
							else
								data.TimeOut = 210
							end
						end
					end	
				end					
			end
		end
	end	
end)



