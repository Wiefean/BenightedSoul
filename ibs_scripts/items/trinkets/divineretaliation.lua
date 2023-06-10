--神圣反击

local mod = Isaac_BenightedSoul
local IBS_Trinket = mod.IBS_Trinket
local Ents = mod.IBS_Lib.Ents
local rng = mod:GetUniqueRNG("Trinket_DivineRetaliation")

local sfx = SFXManager()

--效果
local function PreTakeDMG(_,ent, amount, flag, source)
	local player = ent:ToPlayer()
	
	if source and (source.Type == EntityType.ENTITY_PROJECTILE) then
		if player and player:HasTrinket(IBS_Trinket.divineretaliation) then
			local extra = 0.15*(player:GetTrinketMultiplier(IBS_Trinket.divineretaliation) - 1)
			if extra > 0.45 then extra = 0.45 end
			
			if (rng:RandomFloat()) + extra >= 0.85 then
				player:SetColor(Color(1, 1, 1, 1, 0, 0.7, 0.7),10,2,true)
				return false
			else
				for _,proj in pairs(Isaac.FindInRadius(player.Position, 100, EntityPartition.BULLET)) do
					local fire = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BLUE_FLAME, 0, proj.Position, 5*((proj.Position - player.Position):Normalized()), player):ToEffect()
					fire.Parent = player
					fire.CollisionDamage = math.max(3.5, player.Damage)
					fire.Timeout = rng:RandomInt(180) + 120
					proj:Remove()
				end
			end
		end
	end	
end
mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, PreTakeDMG)