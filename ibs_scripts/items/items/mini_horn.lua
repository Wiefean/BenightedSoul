--迷你霍恩

local mod = Isaac_BenightedSoul

local game = Game()

local MiniHorn = mod.IBS_Class.Item(mod.IBS_ItemID.MiniHorn)

function MiniHorn:OnPlayerUpdate(player)
	if player:HasCollectible(self.ID) and self._Players:IsShooting(player) then

		local rng = player:GetCollectibleRNG(self.ID)
		local data = self._Ents:GetTempData(player)
		if not data.MiniHornTimeout then data.MiniHornTimeout = 360 + rng:RandomInt(420) end
			
		if data.MiniHornTimeout > 0 then
			data.MiniHornTimeout = data.MiniHornTimeout - 1
		else
			data.MiniHornTimeout = 180 + rng:RandomInt(210)
			local variant = BombVariant.BOMB_TROLL
			local cd = 45
			local seija = false
			
			--正邪增强(东方mod)
			--红炸弹
			if mod.IBS_Compat.THI:SeijaBuff(player) then
				seija = true
				variant = BombVariant.BOMB_THROWABLE
				data.MiniHornTimeout = 180
				cd = 30
			end

			local bomb = Isaac.Spawn(EntityType.ENTITY_BOMB, variant, 0, player.Position, Vector.Zero, nil):ToBomb()
			bomb:SetExplosionCountdown(cd)
			bomb.ExplosionDamage = 60
			bomb.RadiusMultiplier = 0.6
			bomb.SpriteScale = Vector(0.5,0.5)
			
			--正邪举起炸弹
			if seija then player:TryHoldEntity(bomb) end
			
			--里正邪额外生成炸弹
			local seijaBLevel = mod.IBS_Compat.THI:GetSeijaBLevel(player)
			if seijaBLevel >= 2 then
				for i = 1,(seijaBLevel-1)*3 do
					local bomb = Isaac.Spawn(EntityType.ENTITY_BOMB, variant, 0, player.Position, RandomVector() * math.random(20, 30), nil):ToBomb()
					bomb:SetExplosionCountdown(math.random(45, 60))
					bomb.ExplosionDamage = 60
					bomb.RadiusMultiplier = 0.6
					bomb.SpriteScale = Vector(0.5,0.5)
				end
			end

			--烟雾提醒
			local poof = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, bomb.Position, Vector.Zero, nil)
			poof.SpriteScale = Vector(0.5,0.5)
			
			SFXManager():Play(SoundEffect.SOUND_LITTLE_HORN_COUGH)
		end
	end	
end
MiniHorn:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, 'OnPlayerUpdate', 0)

--里正邪防爆
function MiniHorn:PrePlayerTakeDMG(player, dmg, flag)
	if player:HasCollectible(self.ID) and (flag & DamageFlag.DAMAGE_EXPLOSION > 0) and mod.IBS_Compat.THI:GetSeijaBLevel(player) > 1 then
		return false
	end
end
MiniHorn:AddPriorityCallback(ModCallbacks.MC_PRE_PLAYER_TAKE_DMG, -800, 'PrePlayerTakeDMG')


return MiniHorn