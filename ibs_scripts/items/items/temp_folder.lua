--临时文件夹

local mod = Isaac_BenightedSoul
local Stats = mod.IBS_Lib.Stats

local game = Game()

local TempFolder = mod.IBS_Class.Item(mod.IBS_ItemID.TempFolder)

--获得时
function TempFolder:OnGainItem(item, charge, first, slot, varData, player)
	if first then
		player:AddBoneHearts(1)
		for slot = 0,1 do
			local trinket = player:GetTrinket(slot)
			if trinket > 0 then
				player:AddSmeltedTrinket(trinket)
			end
		end	
	end
end
TempFolder:AddCallback(ModCallbacks.MC_POST_ADD_COLLECTIBLE, 'OnGainItem', TempFolder.ID)


--修改基础掉落上限
function TempFolder:OnEvaluateCustomCache(player, flag, value)
	if player:HasCollectible(self.ID) then
		if flag == "maxcoins" or flag == "maxkeys" or flag == "maxbombs" then
			return value + 49
		end
	end	
end
TempFolder:AddCallback(ModCallbacks.MC_EVALUATE_CUSTOM_CACHE, 'OnEvaluateCustomCache')

--新层
function TempFolder:OnNewLvel()
	for i = 0, game:GetNumPlayers() - 1 do
		local player = Isaac.GetPlayer(i)
		if player:HasCollectible(self.ID) then
			local room = game:GetRoom()

			--硬币
			local coins = player:GetNumCoins()
			if coins > 99 then
				local extra = math.min(49, coins-99)
				player:AddCoins(-extra)
				
				--25美分
				if extra > 25 then
					local pos = room:FindFreePickupSpawnPosition(room:GetGridPosition(17), 0, true)					
					local pickup = Isaac.Spawn(5,100,74, pos, Vector.Zero, nil):ToPickup()
					pickup.Wait = 90
					extra = extra - 25
				end

				for i = 1,extra do
					local pickup = Isaac.Spawn(5,20,0, player.Position, 10*RandomVector(), nil):ToPickup()
					pickup.Wait = 90			
				end
			end
			
			--炸弹
			local bombs = player:GetNumBombs()
			if bombs > 99 then
				local extra = math.min(49, bombs-99)
				player:AddBombs(-extra)
				player:SetMinDamageCooldown(360)
				
				--轰
				if extra > 10 then
					local pos = room:FindFreePickupSpawnPosition(room:GetGridPosition(17), 0, true)					
					local pickup = Isaac.Spawn(5,100,19, pos, Vector.Zero, nil):ToPickup()
					pickup.Wait = 90
					extra = extra - 10
				end

				for i = 1,extra do
					local pickup = Isaac.Spawn(5,40,0, player.Position, 10*RandomVector(), nil):ToPickup()
					pickup.Wait = 90			
				end				
			end			
			
			--钥匙
			local keys = player:GetNumKeys()
			if keys > 99 then
				local extra = math.min(49, keys-99)
				player:AddKeys(-extra)
				
				--25美分
				if extra > 5 then
					local pos = room:FindFreePickupSpawnPosition(room:GetGridPosition(17), 0, true)					
					local pickup = Isaac.Spawn(5,100,623, pos, Vector.Zero, nil):ToPickup()
					pickup.Wait = 90
					extra = extra - 5
				end

				for i = 1,extra do
					local pickup = Isaac.Spawn(5,30,0, player.Position, 10*RandomVector(), nil):ToPickup()
					pickup.Wait = 90			
				end				
			end			
			
			break
		end
	end	
end
TempFolder:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, 'OnNewLvel')

return TempFolder
