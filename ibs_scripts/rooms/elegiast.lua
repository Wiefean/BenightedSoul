--悼歌之冬特殊商店

local mod = Isaac_BenightedSoul
local CustomPool = mod.IBS_Class.CustomPool

local game = Game()
local config = Isaac.GetItemConfig()

local Elegiast = mod.IBS_Class.Room{
	Type = RoomType.ROOM_SHOP,
	Variant = 7250
}

--按格子位置生成实体
local function SpawnOnGrid(T,V,S, grid)
	local room = game:GetRoom()
	local pos = room:GetGridPosition(grid)
	return Isaac.Spawn(T,V,S, pos, Vector.Zero, nil)
end

--名单
local NameList = {
	'isaac',
	'magdalene',
	'maggy',
	'cain',
	'judas',
	'blue_baby',
	'eve',
	'samson',
	'azazel',
	'lazarus',
	'eden',
	'the lost',
	'the_lost',
	'lilith',
	'the keeper',
	'the_keeper',
	'apollyon',
	'the forgotten',
	'the_forgotten',
	'bethany',
	"beth's",
	"jacob",
	"esau",
	
	'以撒',
	'抹大拉',
	'该隐',
	'犹大',
	'???',
	'？？？',
	'夏娃',
	'参孙',
	'阿撒泻勒',
	'伊甸',
	'游魂',
	'莉莉丝',
	'店主',
	'亚玻伦',
	'遗骸',
	'伯大尼',
	'雅各',
	'以扫',
}

--道具池
Elegiast.ItemPool = CustomPool('Elegiast')
Elegiast:DelayFunction2(function()
	--记录名字包含名单内名字的道具
	for id = 1,config:GetCollectibles().Size - 1 do
		if id ~= 67 then --排除红温版波比弟弟
			local itemConfig = config:GetCollectible(id)
			if itemConfig and itemConfig.Name and not itemConfig:HasTags(ItemConfig.TAG_QUEST) then
				for _,name in ipairs(NameList) do	
					local str = string.lower(itemConfig.Name)
					if string.match(str, name) then
						Elegiast.ItemPool:AddToInitPool(id, 1)
						Elegiast.ItemPool:Initialize()
						break
					end
				end
			end
		end
	end
end, 1)

--抽取物品
local oldfn = Elegiast.ItemPool.GetFromPool
function Elegiast.ItemPool:GetFromPool(seed, default, decrease)
	local result = oldfn(self, seed, default, decrease)
	if result and decrease then
		game:GetItemPool():RemoveCollectible(result)
	end
	return result
end	

--水量(用于特效控制)
local waterAmount = 7
local waterAmountDown = true

--房间初始化
Elegiast.EnterFunc = function(self, first, room, roomData)
	if first then
		local idx = self._Pickups:GetUniqueOptionsIndex()
		local seed = self._Levels:GetRoomUniqueSeed()
	
		--魂心/骨心
		local subType = 3
		if RNG(seed):RandomInt(100) < 50 then
			subType = 11
		end
		local heart = SpawnOnGrid(5,10,subType, 65):ToPickup()
		heart.Price = 1
		heart.ShopItemId = -1
		heart.OptionsPickupIndex = idx
	
		--道具
		local id = self.ItemPool:GetFromPool(seed, 25, true)
		local item = SpawnOnGrid(5,100,id, 67):ToPickup()
		item.Price = 1
		item.ShopItemId = -1
		item.OptionsPickupIndex = idx
		
		--伪忆
		local falsehood = SpawnOnGrid(5,300,self._Pools:GetRandomFalsehood(RNG(seed)), 69):ToPickup()
		falsehood.Price = 1
		falsehood.ShopItemId = -1
		falsehood.OptionsPickupIndex = idx
	end

	--移除梯子
	for _,ent in pairs(Isaac.FindByType(1000, 156, 0)) do
		ent:Remove()
	end

	waterAmount = 0.01 * math.random(400, 700)
	room:SetBackdropType(29, 1) --更换房间背景
	room:SetWaterAmount(waterAmount) --水加多的奇怪特效

	--音乐
	local music = Isaac.GetMusicIdByName('悼歌之冬商店')
	if music then
		self:DelayFunction2(function()
			if Isaac.IsInGame() and self:IsInRoom() then
				MusicManager():Crossfade(music, 0.005)
				MusicManager():PitchSlide(0.9)
			end
		end, 0)
	end
end

--房间更新
function Elegiast:OnUpdate()
	if self:IsInRoom() then
		if waterAmountDown then
			waterAmount = waterAmount - 0.002
			if waterAmount <= 4 then
				waterAmountDown = false
			end
		else
			waterAmount = waterAmount + 0.002
			if waterAmount >= 7 then
				waterAmountDown = true
			end			
		end
		game:GetRoom():SetWaterAmount(waterAmount)
	end
end
Elegiast:AddCallback(ModCallbacks.MC_POST_UPDATE, 'OnUpdate')

--禁止补货
function Elegiast:PreRestock()
	if self:IsInRoom() then
		return false
	end
end
Elegiast:AddCallback(ModCallbacks.MC_PRE_RESTOCK_SHOP, 'PreRestock')

return Elegiast