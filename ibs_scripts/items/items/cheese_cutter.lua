--奶酪切片器

local mod = Isaac_BenightedSoul
local IBS_ItemID = mod.IBS_ItemID

local game = Game()
local config = Isaac.GetItemConfig()

local CheeseCutter = mod.IBS_Class.Item(IBS_ItemID.CheeseCutter)

--获取池中道具(地狱厨房同款)
function CheeseCutter:GetItemFromPool(seed, default, decrease)
	local HellKitchen = (mod.IBS_Item and mod.IBS_Item.HellKitchen)
	if HellKitchen then
		return HellKitchen.ItemPool:GetFromPool(seed, default, decrease)
	end
	return 25
end

--清理boss房
function CheeseCutter:OnRoomCleaned()
	if not PlayerManager.AnyoneHasCollectible(self.ID) then return end
	local room = game:GetRoom()
	local roomType = room:GetType()
	if roomType == RoomType.ROOM_BOSS or roomType == RoomType.ROOM_BOSSRUSH then
		local seed = self._Levels:GetRoomUniqueSeed()
		local id = self:GetItemFromPool(seed, 25, true)
		local price = 7
		
		--获取价格
		local itemConfig = config:GetCollectible(id)
		if itemConfig and itemConfig.ShopPrice then
			price = math.floor(itemConfig.ShopPrice / 2)
		end
		
		local pos = room:FindFreePickupSpawnPosition(room:GetCenterPos() + Vector(120,80), 0, true)
		local item = Isaac.Spawn(5, 100, id, pos, Vector.Zero, nil):ToPickup()
		item.ShopItemId = -1
		item.AutoUpdatePrice = false
		item.Price = price		
		
		--仰望星空彩蛋
		if item.SubType == (IBS_ItemID.SSG) then
			item:GetSprite():ReplaceSpritesheet(1, "gfx/ibs/items/collectibles/ssg_alt.png", true)
		end		
		
	end
end
CheeseCutter:AddCallback(ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD, 'OnRoomCleaned')

--boss波次
function CheeseCutter:OnWaveEndState(state)
	if state == 2 and PlayerManager.AnyoneHasCollectible(self.ID) then
		local room = game:GetRoom()
		local seed = self._Levels:GetRoomUniqueSeed()
		local id = self:GetItemFromPool(seed)
		local price = 7
		
		--获取价格
		local itemConfig = config:GetCollectible(id)
		if itemConfig and itemConfig.ShopPrice then
			price = math.floor(itemConfig.ShopPrice / 2)
		end
		
		local pos = room:FindFreePickupSpawnPosition(room:GetCenterPos() + Vector(120,80), 0, true)
		local item = Isaac.Spawn(5, 100, id, pos, Vector.Zero, nil):ToPickup()
		item.ShopItemId = -1
		item.AutoUpdatePrice = false
		item.Price = price		
		
		--仰望星空彩蛋
		if item.SubType == (IBS_ItemID.SSG) then
			item:GetSprite():ReplaceSpritesheet(1, "gfx/ibs/items/collectibles/ssg_alt.png", true)
		end
		
	end
end
CheeseCutter:AddCallback(mod.IBS_CallbackID.GREED_WAVE_END_STATE, 'OnWaveEndState')


--增伤
function CheeseCutter:OnTakeDMG(ent, dmg, flag, source, cd)
	if dmg <= 0 then return end
	if not ent:IsBoss() then return end
	local extra = 0
	for i = 0, game:GetNumPlayers() - 1 do
		local player = Isaac.GetPlayer(i)			
		if player:HasCollectible(self.ID) then
			for i = 1,player:GetCollectibleNum(self.ID) do
				local chance = 10 + player.Luck

				if chance < 5 then chance = 5 end
				if chance > 50 then chance = 50 end
				
				if player:GetCollectibleRNG(self.ID):RandomInt(100) < chance then
					extra = extra + 18
				end
			end
		end
	end
	return {Damage = dmg + extra, DamageFlags = flag, DamageCountdown = cd}
end
CheeseCutter:AddPriorityCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, -100000, 'OnTakeDMG')


return CheeseCutter