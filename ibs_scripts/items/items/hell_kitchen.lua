--地狱厨房

local mod = Isaac_BenightedSoul
local IBS_ItemID = mod.IBS_ItemID
local CustomPool = mod.IBS_Class.CustomPool

local game = Game()

local HellKitchen = mod.IBS_Class.Item(IBS_ItemID.HellKitchen)

--道具池
HellKitchen.ItemPool = CustomPool('HellKitchen')
for _,id in ipairs{
	1, --悲伤洋葱
	11, --1up
	12, --魔法蘑菇
	16, --生肝
	25, --早餐
	56, --柠檬
	69, --巧克力牛奶
	71, --小蘑菇
	73, --肉块
	111, --豆子
	120, --小怪异蘑菇
	121, --大怪异蘑菇
	180, --黑豆
	193, --肉
	197, --耶稣果汁
	294, --棉豆
	330, --豆浆
	336, --烂洋葱
	342, --蓝盖蘑菇
	351, --超级豆子
	418, --水果蛋糕
	421, --腰豆
	436, --牛奶
	443, --苹果
	447, --流连豆
	457, --蛋头
	484, --等等啥
	495, --断魂椒
	561, --杏仁奶
	616, --鸟眼椒
	618, --烂番茄
	621, --红豆汤
	669, --腊肠
	690, --肚肚软糖

	--愚昧
	IBS_ItemID.SSG, --仰望星空
	IBS_ItemID.PurpleBubbles, --紫色泡泡水
	IBS_ItemID.Chocolate, --瓦伦丁巧克力
	IBS_ItemID.DreggyPie, --掉渣饼
	IBS_ItemID.NeedleMushroom, --金针菇
	IBS_ItemID.ForbiddenFruit, --禁断之果
	IBS_ItemID.ChubbyCookbook, --蛆虫食谱
	IBS_ItemID.Molekale, --分子植物
	IBS_ItemID.Ssstew, --炖蛇羹
	IBS_ItemID.Alms, --施粥处
	IBS_ItemID.CheeseCutter, --奶酪切片器
} do
	HellKitchen.ItemPool:AddToInitPool(id, 1)
end

--抽取物品
local oldfn = HellKitchen.ItemPool.GetFromPool
function HellKitchen.ItemPool:GetFromPool(seed, default, decrease)
	local result = oldfn(self, seed, default, decrease)
	if result and decrease then
		game:GetItemPool():RemoveCollectible(result)
	end
	return result
end	


--恶魔房额外生成特定交易
function HellKitchen:OnNewRoom()
	local room = game:GetRoom()
	
	if room:IsFirstVisit() and (room:GetType() == RoomType.ROOM_DEVIL) then
		local num = 0

		for i = 0, game:GetNumPlayers() -1 do
			local player = Isaac.GetPlayer(i)
			num = num + player:GetCollectibleNum(self.ID)
		end
		
		if num > 0 then
			local seed = self._Levels:GetRoomUniqueSeed()
			for i = 1,num do
				local id = self.ItemPool:GetFromPool(seed, 25, true)
				local pos = room:FindFreePickupSpawnPosition((room:GetCenterPos()), 0, true)
				local item = Isaac.Spawn(5, 100, id, pos, Vector(0,0), nil):ToPickup()
				
				--仰望星空彩蛋
				if item.SubType == (IBS_ItemID.SSG) then
					item:GetSprite():ReplaceSpritesheet(1, "gfx/ibs/items/collectibles/ssg_alt.png", true)
				end
				
				self._Pickups:SetSpikePrice(item)
			end
		end
	end
end
HellKitchen:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, 'OnNewRoom')

--获得时,如果在恶魔房,立刻触发一次效果
function HellKitchen:OnGainItem(item, charge, first, slot, varData, player)
	local room = game:GetRoom()
	if first and (room:GetType() == RoomType.ROOM_DEVIL) then
		local id = self.ItemPool:GetFromPool(self._Levels:GetRoomUniqueSeed(), 25, true)
		local pos = room:FindFreePickupSpawnPosition((room:GetCenterPos()), 0, true)
		local item = Isaac.Spawn(5, 100, id, pos, Vector(0,0), nil):ToPickup()

		--仰望星空彩蛋
		if item.SubType == (IBS_ItemID.SSG) then
			item:GetSprite():ReplaceSpritesheet(1, "gfx/ibs/items/collectibles/ssg_alt.png", true)
		end

		self._Pickups:SetSpikePrice(item)
	end
end
HellKitchen:AddCallback(ModCallbacks.MC_POST_ADD_COLLECTIBLE, 'OnGainItem', HellKitchen.ID)



return HellKitchen