--坚韧面罩

local mod = Isaac_BenightedSoul

local sfx = SFXManager()
local game = Game()

local GOF = mod.IBS_Class.Item(mod.IBS_ItemID.GOF)


--临时玩家数据,用于防止伤害无限循环
function GOF:GetData(player)
	local data = self._Ents:GetTempData(player)
	data.GuardOfFortitude = data.GuardOfFortitude or {TakingDMG = false}
	
	return data.GuardOfFortitude
end

--抵挡面前子弹,受伤清除子弹,爆炸伤害以半心替代
function GOF:PrePlayerTakeDMG(player, dmg, flag, source, cd)
	if dmg <= 0 then return end
	if player:GetDamageCooldown() > 0 and (flag & DamageFlag.DAMAGE_INVINCIBLE <= 0) then return end
	if not player:HasCollectible(self.ID) then return end 

	if source.Entity and (source.Type == EntityType.ENTITY_PROJECTILE) then
		local dir = self._Maths:VectorToDirection((player.Position - source.Entity.Position):Normalized())

		if player:GetHeadDirection() ~= dir then
			source.Entity:Die()
			return false
		else	
			for _,proj in ipairs(Isaac.FindByType(EntityType.ENTITY_PROJECTILE)) do
				Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, proj.Position, Vector.Zero, nil)	
				proj:Remove()
			end
			sfx:Play(267)
			game:ShakeScreen(30)				
		end	
	end

	if (flag & DamageFlag.DAMAGE_EXPLOSION > 0) then
		local data = self:GetData(player)
		if not data.TakingDMG then
			data.TakingDMG = true
			player:TakeDamage(1, flag | DamageFlag.DAMAGE_NO_MODIFIERS, source, cd)
			data.TakingDMG = false
		end	
	end
end
GOF:AddPriorityCallback(ModCallbacks.MC_PRE_PLAYER_TAKE_DMG, 700, 'PrePlayerTakeDMG')


return GOF