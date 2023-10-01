--金针菇

local mod = Isaac_BenightedSoul
local IBS_Item = mod.IBS_Item
local Stats = mod.IBS_Lib.Stats

local function Drop(_,player)
	if player.FrameCount % 30 == 0 then
		if player:HasCollectible(IBS_Item.nm, true) and (player:GetFireDirection() ~= Direction.NO_DIRECTION) then
			local game = Game()
			local playerType = player:GetPlayerType()
			local rng = player:GetCollectibleRNG(IBS_Item.nm)
			local luck = player.Luck
			local chance = 6 - luck
			if chance < 1 then chance = 1 end


			if rng:RandomInt(99)+1 <= chance then
				player:RemoveCollectible(IBS_Item.nm, true, 0, false)
				
				local pos = game:GetRoom():FindFreePickupSpawnPosition(player.Position, 0, true)
				local item = Isaac.Spawn(5, 100, IBS_Item.nm, pos, Vector.Zero, player):ToPickup()
				item.Touched = true
				item:Morph(5, 100, IBS_Item.nm, false, false, true) --防止某些替换道具的效果
				item:SetColor(Color(92/255, 47/255, 22/255), 200, 2,true)
				item.Wait = 150 --等5秒才能再捡
				
				--里蓝人兼容
				if playerType == PlayerType.PLAYER_BLUEBABY_B then
					local variant = 0
					if rng:RandomInt(99) <= 25 then variant = 1 end
					local poop = Isaac.Spawn(5, 42, variant, player.Position, Vector.Zero, player):ToPickup()
					poop.Velocity = RandomVector() * 4
					poop.Wait = 30
				end
				
				game:Fart(player.Position, 85, player, 1, 0, Color(92/255, 47/255, 22/255))
			end
		end	
	end
end
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, Drop, 0)


mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, function(_,player, flag)
	if player:HasCollectible(IBS_Item.nm) then
		local num = player:GetCollectibleNum(IBS_Item.nm)
		if flag == CacheFlag.CACHE_SPEED then
			Stats:Speed(player, 0.3*num)
		end		
		if flag == CacheFlag.CACHE_FIREDELAY then
			Stats:TearsModifier(player, 0.7*num)
		end
		if flag == CacheFlag.CACHE_RANGE then
			Stats:Range(player, 1.25*num)
		end
	end	
end)

