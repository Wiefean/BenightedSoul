--机制

local mod = Isaac_BenightedSoul

--虚空增强(吸收饰品)
local function VoidUp(_,col,rng,player,flags)
	if (flags & UseFlag.USE_OWNED > 0) then
		if IBS_Data.Setting["voidUp"] then
			player:UseActiveItem(479,false,false) --吞掉身上的饰品
		
			--吞掉地上的饰品
			local ts = Isaac.FindByType(5, 350)
			for i = 1, #ts do
				local item = ts[i]:ToPickup()
				if (item.SubType > 0) and (item.Price == 0) then
					player:AddTrinket(item.SubType, item.Touched)
					player:UseActiveItem(479,false,false)
					Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, item.Position, Vector.Zero, nil)						
					item:Remove()
				end
			end		
		end
	end
end
mod:AddCallback(ModCallbacks.MC_USE_ITEM, VoidUp, 477)


--无底坑增强(吸收饰品)
local function AbyssUp(_,col,rng,player,flags)
	if (flags & UseFlag.USE_OWNED > 0) then
		if IBS_Data.Setting["abyssUp"] then
			local ts = Isaac.FindByType(5, 350)
			
			for i = 1, #ts do
			local item = ts[i]:ToPickup()
				if (item.SubType > 0) and (item.Price == 0) then
					local locust = Isaac.Spawn(3, FamiliarVariant.ABYSS_LOCUST, 2, item.Position, Vector.Zero, player):ToFamiliar()
					locust.Player = player
					Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, item.Position, Vector.Zero, nil)						
					item:Remove()
				end
			end		
		end
	end
end
mod:AddCallback(ModCallbacks.MC_USE_ITEM, AbyssUp, 706)			