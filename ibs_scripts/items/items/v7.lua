--美德七面骰

local mod = Isaac_BenightedSoul
local IBS_Item = mod.IBS_Item
local Finds = mod.IBS_Lib.Finds
local Maths = mod.IBS_Lib.Maths

--节制
local Temperance = {
	Type = Isaac.GetEntityTypeByName("IBS_Temperance"),
	Variant = Isaac.GetEntityVariantByName("IBS_Temperance")
}

--坚韧
local Fortitude = {
	Type = Isaac.GetEntityTypeByName("IBS_Fortitude"),
	Variant = Isaac.GetEntityVariantByName("IBS_Fortitude")
}

--效果
local function Conjure(_,item, rng, player)
	local int = math.random(1,2)
	local pos = Game():GetRoom():FindFreePickupSpawnPosition(player.Position, 0, true)
	local type = Temperance.Type
	local variant = Temperance.Variant
	
	if int == 2 then
		type = Fortitude.Type
		variant = Fortitude.Variant
	end
	
	local ent = Isaac.Spawn(type, variant, 0, pos, Vector.Zero, nil)
	ent:AddCharmed(EntityRef(player), -1)
	ent:AddEntityFlags(EntityFlag.FLAG_NO_REWARD)
	ent:AddEntityFlags(EntityFlag.FLAG_NO_SPIKE_DAMAGE)
	
	return true	
end
mod:AddCallback(ModCallbacks.MC_USE_ITEM, Conjure, IBS_Item.v7)

