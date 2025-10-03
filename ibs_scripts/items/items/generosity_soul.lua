--慷慨之魂

local mod = Isaac_BenightedSoul
local IBS_PlayerKey = mod.IBS_PlayerKey

local game = Game()
local sfx = SFXManager()
local config = Isaac.GetItemConfig()

local SOG = mod.IBS_Class.Item(mod.IBS_ItemID.SOG)

--获取记录
function SOG:GetData()
	local data = self:GetIBSData('temp')
	data.SOG = data.SOG or {Donations = 0}
	return data.SOG
end

--检查效果
local function Check()
	--符文佩剑(东方mod)
	if mod.IBS_Compat.THI:IsEnabled() then	
		local RuneSword = THI.Collectibles.RuneSword
		if RuneSword:HasGlobalRune(mod.IBS_PocketID.BKeeper) then
			return true
		end
	end
	return PlayerManager.AnyoneHasCollectible(SOG.ID)
end

--乞丐捐赠
function SOG:OnBumDonation(ent, pickup)
	if not Check() then return end
	local p = Isaac.GetPlayer(0)
	local data = self:GetData()

	--概率返还资源
	if p:GetCollectibleRNG(self.ID):RandomInt(100) < 42 then
		local variant = ent.Variant
		
		--可互动实体
		if ent:ToSlot() then
			
			--乞丐/电池乞丐/腐烂乞丐
			if variant == 4 or variant == 13 or variant == 18 then
				p:AddCoins(1)
			end

			--恶魔乞丐
			if variant == 5 then
				Isaac.Spawn(5,10,0, ent.Position, RandomVector(), nil)
			end		

			--钥匙乞丐
			if variant == 7 then
				p:AddKeys(1)
			end

			--炸弹乞丐
			if variant == 9 then
				p:AddBombs(1)
			end
		elseif ent:ToFamiliar() and pickup then --跟班
			
			--乞丐朋友
			if variant == 24 then
				p:AddCoins(1)
			end
			
			--黑暗乞丐
			if variant == 64 then
				local heart = Isaac.Spawn(5,10,0, ent.Position, RandomVector(), nil):ToPickup()
				heart.Wait = 60
			end		
		
			--钥匙乞丐
			if variant == 90 then
				p:AddKeys(1)
			end
			
			--超级乞丐
			if variant == 102 then
				if pickup.Variant == 10 then --心
					local heart = Isaac.Spawn(5,10,0, ent.Position, RandomVector(), nil):ToPickup()
					heart.Wait = 60
				end
				if pickup.Variant == 20 then --硬币
					p:AddCoins(1)
				end
					if pickup.Variant == 30 then --钥匙				
					p:AddKeys(1)
				end
			end
		end
	end

	--每达到一定次数时奖励
	data.Donations = data.Donations + 1
	if data.Donations >= 14 then
		data.Donations = data.Donations - 14
		for i = 0, game:GetNumPlayers() - 1 do
			local player = Isaac.GetPlayer(i)
			if player:HasCollectible(self.ID) then
				if player:GetBrokenHearts() > 0 then
					player:AddBrokenHearts(-1)				
				else
					self._Stats:PersisLuck(player, 0.5, true)
				end

				--神圣卡
				player:UseCard(51, UseFlag.USE_NOANIM | UseFlag.USE_NOANNOUNCER | UseFlag.USE_MIMIC)
				sfx:Play(268)
			end
		end
	end
end
SOG:AddCallback(mod.IBS_CallbackID.BUM_DONATION, 'OnBumDonation')

--特殊房间生成乞丐
function SOG:OnNewRoom()
	if not Check() then return end
	local room = game:GetRoom()
	if not room:IsFirstVisit() then return end
	local roomType = room:GetType()
	local variant = -1

	--宝箱房/天使/卧室/贪婪出口
	if roomType == RoomType.ROOM_TREASURE or roomType == RoomType.ROOM_ANGEL or roomType == RoomType.ROOM_ISAACS or roomType == RoomType.ROOM_GREED_EXIT then
		variant = 4 --普通乞丐
	end	

	--诅咒/恶魔/红隐
	if roomType == RoomType.ROOM_CURSE or roomType == RoomType.ROOM_DEVIL or roomType == RoomType.ROOM_ULTRASECRET then
		variant = 5 --恶魔乞丐
	end	

	--隐藏/超藏/图书馆
	if roomType == RoomType.ROOM_SECRET or roomType == RoomType.ROOM_SUPERSECRET or roomType == RoomType.ROOM_LIBRARY then
		variant = 7 --钥匙乞丐
	end

	--商店/赌博房/藏宝阁
	if roomType == RoomType.ROOM_SHOP or roomType == RoomType.ROOM_ARCADE or roomType == RoomType.ROOM_CHEST then
		variant = 13 --电池乞丐
	end

	--脏卧室/黑市
	if roomType == RoomType.ROOM_BARREN or roomType == RoomType.ROOM_BLACK_MARKET then
		variant = 18 --腐烂乞丐
	end	
	
	if variant > 0 then
		local gridIndex = room:GetGridWidth() + room:GetGridHeight()	
		local pos = room:FindFreePickupSpawnPosition(room:GetGridPosition(gridIndex), 0, true)		
		Isaac.Spawn(6, variant, 0, pos, Vector.Zero, nil)
	end
end
SOG:AddPriorityCallback(ModCallbacks.MC_POST_NEW_ROOM, CallbackPriority.LATE, 'OnNewRoom')


return SOG