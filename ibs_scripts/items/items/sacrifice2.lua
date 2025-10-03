--亚伯的祭品

local mod = Isaac_BenightedSoul

local game = Game()
local config = Isaac.GetItemConfig()

local Sacrifice2 = mod.IBS_Class.Item(mod.IBS_ItemID.Sacrifice2)


--使用
function Sacrifice2:OnUse(item, rng, player, flags)
	if (flags & UseFlag.USE_CARBATTERY <= 0) and (flags & UseFlag.USE_OWNED > 0 or flags & UseFlag.USE_VOID > 0) then
		local data = mod:GetIBSData('temp')
		
		--记录使用
		data.welcomSacrificeUsed = true

		game:GetHUD():ShowFortuneText(self:ChooseLanguage('你被祝福了 !', 'You Feel Blessed!'))
		
		return {ShowAnim = true, Remove = true}
	end
end
Sacrifice2:AddCallback(ModCallbacks.MC_USE_ITEM, 'OnUse', Sacrifice2.ID)

--充能
function Sacrifice2:Charge(player)
	for slot = 0,2 do
		if player:GetActiveItem(slot) == (self.ID) then
			self._Players:ChargeSlot(player, slot, 1, true, false, true, true)
		end	
	end
end

--自动充能判定
function Sacrifice2:OnUpdate()
	local unwelcomSacrifice = self:GetIBSData('temp').unwelcomSacrificeUsed
	for i = 0, game:GetNumPlayers() -1 do
		local player = Isaac.GetPlayer(i)
	
		--使用过该隐祭品或美德书或犹大长子权
		if unwelcomSacrifice or player:HasCollectible(584) or player:HasCollectible(59) then	
			self:Charge(player)
		end
	end	
end
Sacrifice2:AddCallback(ModCallbacks.MC_POST_UPDATE, 'OnUpdate')


--找到符合要求的道具(品质最高,非任务道具)
function Sacrifice2:FindItem()
	local pickup = nil
	local highestQ = 0

	for _,ent in ipairs(Isaac.FindByType(5, 100, -1, true)) do
		if (ent.SubType > 0) then
			local itemConfig = config:GetCollectible(ent.SubType)
			if itemConfig and not itemConfig:HasTags(ItemConfig.TAG_QUEST) then
				local quality = itemConfig.Quality
				if quality >= highestQ then
					pickup = ent:ToPickup()
					highestQ = quality
				end
			end
		end	
	end

	return pickup, highestQ
end

--新房间
function Sacrifice2:OnNewRoom()
	local dimension = game:GetLevel():GetDimension()
	if dimension ~= 0 and dimension ~= 1 then return end
	
	local room = game:GetRoom()
	local roomType = room:GetType()
	
	--进入恶魔/天使房充能
	if (roomType == RoomType.ROOM_DEVIL) or (roomType == RoomType.ROOM_ANGEL) then
		for i = 0, game:GetNumPlayers() -1 do
			self:Charge(Isaac.GetPlayer(i))
		end
	end

	--新房间额外道具选择
	--(延迟触发,以实现视觉效果和模组兼容)
	if room:IsFirstVisit() then
		self:DelayFunction(function()
			if not self:GetIBSData('temp').welcomSacrificeUsed then return end

			local pickup, quality = self:FindItem()
			
			if pickup then
				local seed = self._Levels:GetRoomUniqueSeed()
				local pos1 = room:FindFreePickupSpawnPosition(pickup.Position - Vector(80,0), 0, true)
				local pos2 = room:FindFreePickupSpawnPosition(pickup.Position + Vector(80,0), 0, true)
				local id1 = self._Pools:GetCollectibleWithQuality(seed, quality, ItemPoolType.POOL_ANGEL, true)
				local id2 = self._Pools:GetCollectibleWithQuality(seed, quality, ItemPoolType.POOL_DEVIL, true)
				local item1 = Isaac.Spawn(5, 100, id1, pos1, Vector.Zero, nil):ToPickup()
				local item2 = Isaac.Spawn(5, 100, id2, pos2, Vector.Zero, nil):ToPickup()
				
				--设置价格(游戏会自动调整,无需操心)
				item1.ShopItemId = -1
				item2.ShopItemId = -2 -- -2表示血量交易
				item1.Price = 1
				item2.Price = -1
				
				--恶魔房的自动调整会把金钱交易变成血量交易,所以这里不开自动调整
				if (roomType == RoomType.ROOM_DEVIL) then
					item1.AutoUpdatePrice = false
					local itemConfig = config:GetCollectible(id1)
					item1.Price = (itemConfig and itemConfig.ShopPrice) or 15
				end

				--设置单选
				local index = pickup.OptionsPickupIndex
				if index == 0 then
					local newIndex = self._Pickups:GetUniqueOptionsIndex()
					item1.OptionsPickupIndex = newIndex
					item2.OptionsPickupIndex = newIndex
					pickup.OptionsPickupIndex = newIndex					
				else
					item1.OptionsPickupIndex = index	
					item2.OptionsPickupIndex = index
				end
			end
		end, 3)
	end	
end
Sacrifice2:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, 'OnNewRoom')


return Sacrifice2