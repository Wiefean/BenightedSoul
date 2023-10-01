--迷你霍恩

local mod = Isaac_BenightedSoul
local IBS_Item = mod.IBS_Item
local Ents = mod.IBS_Lib.Ents


local function OnUpdate(_,player)
	if player:HasCollectible(IBS_Item.minihorn) and (player:GetFireDirection() ~= Direction.NO_DIRECTION) then
		local game = Game()
		local rng = player:GetCollectibleRNG(IBS_Item.minihorn)
		local data = Ents:GetTempData(player)
		if not data.MiniHornTimeOut then data.MiniHornTimeOut = 360 + rng:RandomInt(420) end
			
		if data.MiniHornTimeOut > 0 then
			data.MiniHornTimeOut = data.MiniHornTimeOut - 1
		else
			data.MiniHornTimeOut = 180 + rng:RandomInt(210)
			local variant = BombVariant.BOMB_TROLL
			local seija = false
			
			--正邪增强(东方mod)
			if mod:THI_WillSeijaBuff(player) then
				seija = true
				variant = BombVariant.BOMB_THROWABLE
				data.MiniHornTimeOut = 180
			end
			
			local bomb = Isaac.Spawn(EntityType.ENTITY_BOMB, variant, 0, player.Position, Vector.Zero, nil):ToBomb()
			bomb:SetExplosionCountdown(45)
			bomb.ExplosionDamage = 60
			bomb.RadiusMultiplier = 0.6
			bomb.SpriteScale = Vector(0.5,0.5)
			
			--正邪举起炸弹
			if seija then player:TryHoldEntity(bomb) end
			
			--烟雾提醒
			local poof = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, bomb.Position, Vector.Zero, nil)
			poof.SpriteScale = Vector(0.5,0.5)
			
			SFXManager():Play(SoundEffect.SOUND_LITTLE_HORN_COUGH)
		end
	end	
end
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, OnUpdate, 0)


