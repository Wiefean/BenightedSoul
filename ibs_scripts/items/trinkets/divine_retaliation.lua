--神圣反击

local mod = Isaac_BenightedSoul

local game = Game()

local DivineRetaliation = mod.IBS_Class.Trinket(mod.IBS_TrinketID.DivineRetaliation)

--效果
function DivineRetaliation:OnTakeDMG(ent, dmg, flag, source)
	local player = ent:ToPlayer()
	
	if source and (source.Type == EntityType.ENTITY_PROJECTILE) then
		if player and player:HasTrinket(self.ID) then
			local rng = player:GetTrinketRNG(self.ID)
			local chance = math.min(90, 30 * player:GetTrinketMultiplier(self.ID))
			
			if rng:RandomInt(100) < chance then
				player:SetColor(Color(1,1,0,0.5,1,1,0),10,2,true)
				player:SetMinDamageCooldown(90)
				return false
			else
				for _,proj in pairs(Isaac.FindInRadius(player.Position, 100, EntityPartition.BULLET)) do
					local fire = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BLUE_FLAME, 0, proj.Position, 5*((proj.Position - player.Position):Normalized()), player):ToEffect()
					fire.Parent = player
					fire.Color = Color(1,1,1,0.5,2,2,0)
					fire.CollisionDamage = math.max(7, player.Damage)
					fire.Timeout = rng:RandomInt(180) + 120
					proj:Remove()
				end
			end
		end
	end	
end
DivineRetaliation:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, 'OnTakeDMG')



return DivineRetaliation