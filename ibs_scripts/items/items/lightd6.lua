--光D6

local mod = Isaac_BenightedSoul
local IBS_Item = mod.IBS_Item
local IBS_Player = mod.IBS_Player
local Pools = mod.IBS_Lib.Pools

--效果
local function roll(_,col,rng,player,flags)
	local itemPool = Game():GetItemPool()					
	local items = Isaac.FindByType(5, 100)
	
	--眛化以撒
	-- if player:GetPlayerType() == (IBS_Player.bisaac) then
		-- if player:GetSoulHearts() > 0 then
			-- player:AddSoulHearts(-1)
		-- else
			-- return {ShowAnim = false, Discharge = false}
		-- end
	-- end
	
	--计算平均品质
	local averageQ = 0
	for i = 1, #items do
		if items[i].SubType ~= 0 then
			local config = Isaac.GetItemConfig():GetCollectible(items[i].SubType)
			
			if config and config.Quality then 
				averageQ = averageQ + (config.Quality)
			end		
		end
	end
	averageQ = math.floor((averageQ / (#items))+0.5) --四舍五入
	if averageQ < 0 then averageQ = 0 end
	if averageQ > 4 then averageQ = 4 end
	
	--roll
	for i = 1, #items do
		if items[i].SubType ~= 0 then
			local seed = rng:GetSeed()
			local pool = Pools:GetRoomPool(seed)
			local newitem = 25
			local quality = averageQ
	
			--彼列书
			local state = rng:RandomInt(2)
			if player:HasCollectible(59) then
				if state == 1 then
					quality = quality + 1
				end
				if state == 2 then
					quality = quality - 1
				end				
			end
	
			--品质超出范围会自动调整,无需操心
			newitem = Pools:GetCollectibleWithQuality(quality, pool, true, rng)
			items[i]:ToPickup():Morph(5,100,newitem,true)
			items[i]:ToPickup().Touched = false
			
			--美德书
			if player:HasCollectible(584) then
				player:AddWisp(IBS_Item.ld6, items[i].Position)
			end
			
			--烟雾特效
			Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, items[i].Position, Vector.Zero, nil)	
		end
	end
	
	return true
end
mod:AddCallback(ModCallbacks.MC_USE_ITEM, roll, IBS_Item.ld6)

