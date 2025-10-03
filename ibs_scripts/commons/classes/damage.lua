--伤害Class

local mod = Isaac_BenightedSoul

local Component = mod.IBS_Class.Component

local Damage = mod.Class(Component, function(self)
	Component._ctor(self)

	--是否能伤害角色
	function self:CanHurtPlayer(player, flag, source)
		if player:GetDamageCooldown() > 0 and (flag & DamageFlag.DAMAGE_INVINCIBLE <= 0) then return false end	

		--免伤判断
		if player:HasInvincibility(flag) then
			return false
		end

		--忽略友好怪来源伤害
		local enemy = self._Ents:GetSourceEnemy(source.Entity)
		if enemy and enemy:HasEntityFlags(EntityFlag.FLAG_FRIENDLY) then
			return false
		end	

		--效果实体(希望大部分情况下有用)
		if source.Entity and source.Entity.Type == 1000 then
			local ent = source.Entity
		
			--圣光
			if ent.Variant == EffectVariant.CRACK_THE_SKY and self._Ents:GetSourcePlayer(source.Entity) then
				return false
			end		
		
			--愚昧特供版震荡波
			local ShockWave = (mod.IBS_Effect and mod.IBS_Effect.ShockWave)
			if ent.Variant == ShockWave.Variant and ent.SubType == 0 then
				return false
			end
			
			--东方mod落石陷阱
			if mod.IBS_Compat.THI:IsEnabled() then
				if ent.Variant == THI.Effects.Boulder.Variant then
					return false
				end
			end
			
		end
		
		
		--忽略白火伤害
		if source.Type == 33 and source.Variant == 4 then
			return false
		end

		--爆炸
		if (flag & DamageFlag.DAMAGE_EXPLOSION > 0) then 
			--原版防爆目前只能硬核判断(纵火狂和寄生帽)
			if player:HasCollectible(223) or player:HasCollectible(375) then
				return false
			end
		end

		return true
	end
	
	--是否为惩罚性
	function self:IsPenalt(player, flag, source)
		--非惩罚性标签
		if (flag & DamageFlag.DAMAGE_NO_PENALTIES > 0) then
			return false
		end	

		--里雅阁被以扫创
		if player:GetPlayerType() == PlayerType.PLAYER_JACOB_B and source.Type == EntityType.ENTITY_DARK_ESAU then
			return false
		end

		--卖血袋等
		if (flag & DamageFlag.DAMAGE_IV_BAG > 0) then
			return false
		end

		--钝刀片等
		if (flag & DamageFlag.DAMAGE_FAKE > 0) then
			return false
		end
		
		--献血机等
		if source and source.Type == EntityType.ENTITY_SLOT then
			return false
		end	
		
		return true	
	end
	
	--是否为自伤
	function self:IsPlayerSelfDamage(player, flag, source)
		--不影响房率的伤害,排除诅咒房门和刺箱
		if (flag & DamageFlag.DAMAGE_NO_PENALTIES > 0) then
			if (flag & DamageFlag.DAMAGE_RED_HEARTS > 0) or ((flag & DamageFlag.DAMAGE_CURSED_DOOR <= 0) and (flag & DamageFlag.DAMAGE_CHEST <= 0)) then 
				return true
			end
		end	
	
		--里雅阁被以扫创
		if player:GetPlayerType() == PlayerType.PLAYER_JACOB_B and source.Type == EntityType.ENTITY_DARK_ESAU then
			return true
		end
	
		--卖血袋等
		if (flag & DamageFlag.DAMAGE_IV_BAG > 0) then
			return true
		end

		--钝刀片等
		if (flag & DamageFlag.DAMAGE_FAKE > 0) then
			return true
		end
		
		--献血机等
		if source and source.Type == EntityType.ENTITY_SLOT then
			return true
		end

		return false
	end


end)

return Damage