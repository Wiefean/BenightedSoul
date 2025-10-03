--冷静头脑

local mod = Isaac_BenightedSoul

local game = Game()
local sfx = SFXManager()

local ChillMind = mod.IBS_Class.Item(mod.IBS_ItemID.ChillMind)

--商店额外道具
function ChillMind:OnNewRoom()
	if not PlayerManager.AnyoneHasCollectible(self.ID) then return end
	local room = game:GetRoom()
	
	if room:IsFirstVisit() and (room:GetType() == RoomType.ROOM_SHOP) then
		
		--X光透视
		local pos = room:FindFreePickupSpawnPosition((room:GetCenterPos()), 0, true)
		local item = Isaac.Spawn(5, 100, 76, pos, Vector(0,0), nil):ToPickup()
		item.ShopItemId = -1
		item.Price = 1
		
		local seed = self._Levels:GetRoomUniqueSeed()
		for i = 1,2 do
			local id = game:GetItemPool():GetCollectible(ItemPoolType.POOL_SHOP, true, seed)
			local pos = room:FindFreePickupSpawnPosition((room:GetCenterPos() + Vector((-1)^i*40,80)), 0, true)
			local item = Isaac.Spawn(5, 100, id, pos, Vector(0,0), nil):ToPickup()
			item.ShopItemId = -1
			item.Price = 1
		end
	end
end
ChillMind:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, 'OnNewRoom')

--都给我战未来
function ChillMind:PrePickupCollision(pickup, other)
	if pickup.Price <= 0 then return end
	if pickup.SubType == 76 then return end
	if game:GetRoom():GetType() ~= RoomType.ROOM_SHOP then return end
	local player = other:ToPlayer()
	if player and player:HasCollectible(self.ID) then
		local items = Isaac.FindByType(5,100,76)
	
		if #items > 0 then
			if pickup:IsFrame(10,0) then
				--神秘音效
				sfx:Play(mod.IBS_Sound.ChillMind, 1, 30, false, 0.01*math.random(120,150))				
				for _,ent in ipairs(items) do
					ent:SetColor(Color(1,1,1,1,1,1,1),6,100,true)
				end
			end
			return false
		end
	end	
end
ChillMind:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, 'PrePickupCollision', PickupVariant.PICKUP_COLLECTIBLE)

--属性变动
function ChillMind:OnEvalueateCache(player, flag)
	if player:HasCollectible(self.ID) then
		if flag == CacheFlag.CACHE_SHOTSPEED then
			player.ShotSpeed = player.ShotSpeed - (player.ShotSpeed * 0.112345)
		end
	end	
end
ChillMind:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, 'OnEvalueateCache')

return ChillMind