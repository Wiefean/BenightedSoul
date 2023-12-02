--以撒的伪忆

local mod = Isaac_BenightedSoul
local IBS_Callback = mod.IBS_Callback
local IBS_Pocket = mod.IBS_Pocket
local Pools = mod.IBS_Lib.Pools

local sfx = SFXManager()

--平均品质
local function GetAverageQuality()
	local Q = 0
	local total = 0
	for _,item in pairs(Isaac.FindByType(5, 100)) do
		if item.SubType ~= 0 then
			total = total + 1
			local config = Isaac.GetItemConfig():GetCollectible(item.SubType)		
			if config and config.Quality then 
				Q = Q + (config.Quality)
			end		
		end
	end
	Q = math.floor((Q / total)+0.5)
	
	return Q
end

--重置道具
local function Roll(_,card, player, flag)
	local quality = GetAverageQuality()
	local pool = ItemPoolType.POOL_DEVIL
	local rng = player:GetCardRNG(IBS_Pocket.falsehood_bisaac)
	
	--调整道具池
	if rng:RandomInt(100) < 49 then
		pool = ItemPoolType.POOL_ANGEL
	end
	
	for _,ent in pairs(Isaac.FindByType(5, 100)) do
		local item = ent:ToPickup()
		if item and item.SubType ~= 0 then
			local newItem = 25

			newItem = Pools:GetCollectibleWithQuality(quality, pool, true, rng)
			item:Morph(5,100,newItem,true)
			item.Touched = false
			
			--烟雾特效
			Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, item.Position, Vector.Zero, nil)	
		end
	end	
end
mod:AddCallback(ModCallbacks.MC_USE_CARD, Roll, IBS_Pocket.falsehood_bisaac)

