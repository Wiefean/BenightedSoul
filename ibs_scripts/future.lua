--未来

local mod = Isaac_BenightedSoul


--虚空增强(吸收饰品)
local function VoidUp(_,item, rng, player, flags)
	if mod:GetIBSData('persis')["voidUp"] then
		for _,ent in ipairs(Isaac.FindByType(5, 350)) do
			local trinket = ent:ToPickup()
			if trinket.SubType > 0 and trinket.Price == 0 then
				player:AddSmeltedTrinket(trinket.SubType, trinket.Touched)
				Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, trinket.Position, Vector.Zero, nil)						
				trinket:Remove()
			end
		end
	end
end
mod:AddCallback(ModCallbacks.MC_USE_ITEM, VoidUp, 477)


--无底坑增强(吸收饰品)
local function AbyssUp(_,item, rng, player, flags)
	if mod:GetIBSData('persis')["abyssUp"] then
		for _,ent in ipairs(Isaac.FindByType(5, 350)) do
			local trinket = ent:ToPickup()
			if trinket.SubType > 0 and trinket.Price == 0 then
				local locust = Isaac.Spawn(3, FamiliarVariant.ABYSS_LOCUST, 2, trinket.Position, Vector.Zero, player):ToFamiliar()
				locust.Player = player
				Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, trinket.Position, Vector.Zero, nil)						
				trinket:Remove()
			end
		end		
	end
end
mod:AddCallback(ModCallbacks.MC_USE_ITEM, AbyssUp, 706)



