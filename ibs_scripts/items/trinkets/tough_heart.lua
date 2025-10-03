--硬的心

local mod = Isaac_BenightedSoul
local Damage = mod.IBS_Class.Damage()

local game = Game()

local ToughHeart = mod.IBS_Class.Trinket(mod.IBS_TrinketID.ToughHeart)


--临时玩家数据
function ToughHeart:GetData(player)
	local data = self._Ents:GetTempData(player)
	data.ToughHeart = data.ToughHeart or {chance = 15}

	return data.ToughHeart
end

--是否应该保护
function ToughHeart:ShouldProtect(player, flag, source)
	return Damage:CanHurtPlayer(player, flag, source) and not Damage:IsPlayerSelfDamage(player, flag, source)
end

--效果
function ToughHeart:PrePlayerTakeDMG(player, dmg, flag, source)
	if dmg <= 0 then return end

	if player:HasTrinket(self.ID) and self:ShouldProtect(player, flag, source) then
		local data = self:GetData(player)

		if player:GetTrinketRNG(self.ID):RandomInt(100) < data.chance then
			local effect = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.IMPACT, 0, player.Position+Vector(0,-20), Vector(0,0), nil):ToEffect()
			effect.Timeout = 60
			effect.SpriteScale = player.SpriteScale
			effect:GetSprite().Color = Color(1,1,1,1,0.5,0.5,0.5)
			effect:FollowParent(player)	
			effect.ParentOffset = Vector(0,-20)
			
			player:SetMinDamageCooldown(90)
			SFXManager():Play(SoundEffect.SOUND_SCYTHE_BREAK, 1, 2, false, 0.8)
			data.chance = 15

			return false
		else
			data.chance = data.chance + 25*player:GetTrinketMultiplier(self.ID)
		end
	end
end
ToughHeart:AddCallback(ModCallbacks.MC_PRE_PLAYER_TAKE_DMG, 'PrePlayerTakeDMG')


return ToughHeart