--硬的心

local mod = Isaac_BenightedSoul
local IBS_Trinket = mod.IBS_Trinket
local Ents = mod.IBS_Lib.Ents
local rng = mod:GetUniqueRNG("Trinket_ToughHeart")

local sfx = SFXManager()


--临时玩家数据
local function GetPlayerData(player)
	local data = Ents:GetTempData(player)
	data.ToughHeart = data.ToughHeart or {chance = 90}

	return data.ToughHeart
end

--是否应该保护
local function ShouldProtect(flag, source)
	if (flag & DamageFlag.DAMAGE_NO_PENALTIES > 0) then
		if (flag & DamageFlag.DAMAGE_RED_HEARTS > 0) or ((flag & DamageFlag.DAMAGE_CURSED_DOOR <= 0) and (flag & DamageFlag.DAMAGE_CHEST <= 0)) then 
			return false
		end
	end

	if (flag & DamageFlag.DAMAGE_IV_BAG > 0) then
		return false
	end

	if (flag & DamageFlag.DAMAGE_FAKE > 0) then
		return false
	end
	
	if source and source.Type == EntityType.ENTITY_SLOT then
		return false
	end

	return true
end

--效果
local function PreTakeDMG(_,ent, amount, flag, source)
	local player = ent:ToPlayer()
	
	if player and player:HasTrinket(IBS_Trinket.toughheart) and ShouldProtect(flag, source) then
		local data = GetPlayerData(player)
		local extra = 10*(player:GetTrinketMultiplier(IBS_Trinket.toughheart) - 1)
		if extra > 30 then extra = 30 end
		
		if (rng:RandomInt(99)+1) + extra >= data.chance then
			local effect = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.IMPACT, 0, player.Position+Vector(0,-20), Vector(0,0), nil):ToEffect()
			effect.Timeout = 60
			effect.SpriteScale = player.SpriteScale
			effect:GetSprite().Color = Color(1,1,1,1,0.5,0.5,0.5)
			effect:FollowParent(player)	
			effect.ParentOffset = Vector(0,-20)
			
			player:SetMinDamageCooldown(90)
			SFXManager():Play(SoundEffect.SOUND_SCYTHE_BREAK, 1, 2, false, 0.8)
			data.chance = 90
			
			return false
		else
			data.chance = math.max(0, (data.chance)-15)
		end
	end
end
mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, PreTakeDMG)