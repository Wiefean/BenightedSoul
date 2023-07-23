--以太

local mod = Isaac_BenightedSoul
local IBS_Item = mod.IBS_Item
local Ents = mod.IBS_Lib.Ents


--获取数据
local function GetEtherData(player)
	local data = Ents:GetTempData(player)
	data.Ether = data.Ether or {
		HurtTimes = 0,
		LightTimeOut = 120,
		Flight = false
	}
	
	return data.Ether
end

--圣光
local function Light(_,player)
	local data = Ents:GetTempData(player).Ether

	if data and (data.HurtTimes > 0) then
		if data.LightTimeOut > 0 then
			data.LightTimeOut = data.LightTimeOut - 1
		else	
			data.LightTimeOut = math.max(12, 240 - 30*(data.HurtTimes))
			for _,ent in pairs(Isaac.GetRoomEntities()) do
				if ent:IsEnemy() and ent:IsVulnerableEnemy() and not ent:HasEntityFlags(EntityFlag.FLAG_FRIENDLY) then
					local dmg = math.max(7, 2*(player.Damage))
					ent:TakeDamage(dmg ,DamageFlag.DAMAGE_IGNORE_ARMOR,EntityRef(player),0)
					
					local light = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.CRACK_THE_SKY, 0, ent.Position, Vector.Zero, player)
					light:SetColor(Color(1, 1, 1, 1, 1, 0, 1),-1,0)				
				end
			end			
		end
	end	
end
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, Light)

--受伤
local function OnHurt(_,ent)
	local player = ent:ToPlayer()

	if player then
		if player:HasCollectible(IBS_Item.ether) then
			local data = GetEtherData(player)
			data.HurtTimes = data.HurtTimes + 1
			data.Flight = true
		end
	end
end
mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, OnHurt)

--飞行
local function Fly(_,player, flag)
	local data = Ents:GetTempData(player).Ether
	if data and (flag == CacheFlag.CACHE_FLYING) and data.Flight then
		player.CanFly = true
	end	
end
mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, Fly)

--翅膀装饰
local function FlyCostume(_,player)
	local data = Ents:GetTempData(player).Ether
	
	if data and data.Flight then
		local effect = player:GetEffects()
		if not effect:HasCollectibleEffect(179) then
			effect:AddCollectibleEffect(179, true)
		end	
	end	
end
mod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, FlyCostume)

--重置房间临时数据
local function Reset()
	for i = 0, Game():GetNumPlayers() -1 do
		local player = Isaac.GetPlayer(i)
	
		if Ents:GetTempData(player).Ether then
			Ents:GetTempData(player).Ether = nil
			player:AddCacheFlags(CacheFlag.CACHE_FLYING)
			player:EvaluateItems()
		end	
	end
end
mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, Reset)

