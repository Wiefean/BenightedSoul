--死亡回放

local mod = Isaac_BenightedSoul

local game = Game()
local sfx = SFXManager()

local ThreeWishes = mod.IBS_Class.Item(mod.IBS_ItemID.ThreeWishes)

--优先级列表
ThreeWishes.PriorityList = {
	"Trinket", --饰品
	"Card", --卡牌/符文
	"SoulHeart", --魂心
	"EternalHeart", --白心
	"Luck", --幸运币
	"Coin", --金硬币
	"Bomb", --双炸弹
	"Key", --双钥匙
	"Gulp", --吞饰品药
	"Deal", --血量代价的道具,有犹大长子权才能生成
	"RockChest", --石箱子
	"GoldenChest", --金箱子
}

--生成
local function Spawn(T,V,S, player)
	return Isaac.Spawn(T,V,S, game:GetRoom():FindFreePickupSpawnPosition(player.Position, 0, true), Vector.Zero, player)
end

--使用效果
function ThreeWishes:OnUse(item, rng, player, flags, slot)
	local list = {}
	for _,v in ipairs(self.PriorityList) do
		table.insert(list, v)
	end

	local itemPool = game:GetItemPool()
	local playerType = player:GetPlayerType()
	local healthType = player:GetHealthType()
	local level = game:GetLevel()

	for i = 1,3 do
		for k,v in ipairs(list) do
			
			--饰品
			if v == "Trinket" and player:GetTrinket(0) == 0 and player:GetTrinket(1) == 0 then
				Spawn(5,350, itemPool:GetTrinket(), player)
				table.remove(list, k)
				break
			end
			
			--卡牌/符文
			if v == "Card"  
				and player:GetCard(0) == 0  
				and player:GetCard(1) == 0  
				and player:GetCard(2) == 0  
				and player:GetCard(3) == 0
				and player:GetPill(0) == 0
				and player:GetPill(1) == 0
				and player:GetPill(2) == 0
				and player:GetPill(3) == 0
			then
				Spawn(5,300, itemPool:GetCard(rng:Next(), true, true, false), player)
				table.remove(list, k)
				break
			end
		
			--魂心
			if v == "SoulHeart" 
				and healthType ~= 2 --非游魂角色
				and healthType ~= 3 --非硬币心角色
				and player:CanPickSoulHearts()
				and player:GetSoulHearts() < 8
			then
				Spawn(5,10,3, player)
				table.remove(list, k)
				break				
			end
			
			--白心
			if v == "EternalHeart" 
				and healthType ~= 1 --魂心角色
				and healthType ~= 2 --游魂角色
				and healthType ~= 3 --硬币心角色
				and player:GetMaxHearts() < 8
			then
				Spawn(5,10,4, player)
				table.remove(list, k)
				break
			end
			
			--幸运币
			if v == "Luck" and player.Luck < 1 then
				Spawn(5,20,5, player)
				table.remove(list, k)
				break
			end
			
			--金硬币
			if v == "Coin"
				and player:GetNumCoins() < 15
				and (
					level:GetStage() < 7 or 
					(level:GetStage() == 7 and level:GetStageType() == 5)
					) --7层之前或陵墓层
				and not level:IsAscent() --非回溯线
			then
				Spawn(5,20,7, player)
				table.remove(list, k)
				break
			end
			
			--双炸弹
			if v == "Bomb" and player:GetNumBombs() < 5 then
				Spawn(5,40,2, player)
				table.remove(list, k)
				break
			end			
			
			--双钥匙
			if v == "Key" and player:GetNumKeys() < 5 then
				Spawn(5,30,3, player)
				table.remove(list, k)
				break
			end	

			--吞饰品药
			if v == "Gulp" and (player:GetTrinket(0) ~= 0 or player:GetTrinket(1) ~= 0) then
				local pillColor = itemPool:ForceAddPillEffect(43)
				itemPool:IdentifyPill(pillColor)			
				Spawn(5,70, pillColor, player)
				table.remove(list, k)
				break
			end

			--随机血量交易道具
			if v == "Deal" 
				and player:HasCollectible(59)
				and game:GetRoom():GetType() ~= 14 --不在恶魔房
				and player:GetMaxHearts() >= 8
			then
				local seed = rng:Next()
				local pool = itemPool:GetPoolForRoom(RoomType.ROOM_ERROR, seed)
				local pickup = Spawn(5,100, itemPool:GetCollectible(pool, true, seed), player):ToPickup()
				pickup.ShopItemId = -2
				pickup.Price = -1	
				table.remove(list, k)
				break
			end
			
			--石箱子
			if v == "RockChest" and player:GetNumBombs() >= 5 then
				Spawn(5,51,1, player)
				table.remove(list, k)
				break
			end
			
			--金箱子
			if v == "GoldenChest" and player:GetNumKeys() >= 5 then
				Spawn(5,60,1, player)
				table.remove(list, k)
				break
			end
			
		end
	end
	
	--神秘音效
	sfx:Play(mod.IBS_Sound.ThreeWishes, 1.5, 0, false, 0.01*math.random(120,150))
	
	return true
end
ThreeWishes:AddCallback(ModCallbacks.MC_USE_ITEM, 'OnUse', ThreeWishes.ID)


return ThreeWishes