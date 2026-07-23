--对流层

local mod = Isaac_BenightedSoul

local game = Game()
local config = Isaac.GetItemConfig()

local Troposphere = mod.IBS_Class.Item(mod.IBS_ItemID.Troposphere)

--交换黑名单
Troposphere.BlackListForSwap = {
	[42] = true, --鲍勃的烂头
	[49] = true, --嗖-哒-呜！
	[164] = true, --蓝蜡烛
	[289] = true, --红蜡烛
	[352] = true, --玻璃大炮
	[382] = true, --友好球
	[489] = true, --无限面骰
	[512] = true, --黑洞
	[623] = true, --尖头钥匙
	[638] = true, --橡皮擦
	[640] = true, --灵魂之瓮
	[728] = true, --格罗
}

--抽取黑名单(包含交换黑名单)
Troposphere.BlackListForGet = {
	[263] = true, --透明符文
	[286] = true, --空白卡牌
	[290] = true, --罐子
	[348] = true, --安慰剂
	[474] = true, --损坏的玻璃大炮
	[523] = true, --搬家盒
	[703] = true, --小以扫
	[720] = true, --百宝罐
}
for k,v in pairs(Troposphere.BlackListForSwap) do
	Troposphere.BlackListForGet[k] = v
end

--是否可交换
function Troposphere:CanSwap(id)
	if id > 732 then return false end
	if self.BlackListForSwap[id] then return false end
	
	local itemConfig = config:GetCollectible(id)
	if itemConfig and itemConfig.Type == ItemType.ITEM_ACTIVE
		and not itemConfig:HasTags(ItemConfig.TAG_QUEST)
		and itemConfig.ChargeType == ItemConfig.CHARGE_NORMAL
		and itemConfig.MaxCharges >= 1
		and itemConfig.MaxCharges <= 12
	then
		return true
	end
	
	return false
end

--获取主动道具
function Troposphere:GetItem(seed)
	local result = {}
	
	local MAX = config:GetCollectibles().Size - 1
	for id = 1, MAX do
		local itemConfig = config:GetCollectible(id)
		if itemConfig and itemConfig:IsAvailable()
			and self:CanSwap(id)
			and not self.BlackListForGet[id]
		then	
			table.insert(result, id)
		end
	end
	
	--抽取一个
	if #result > 0 then
		return result[RNG(seed):RandomInt(1, #result)] or result[1] or 33
	end
	
	--默认圣经
	return 33
end

--新房间触发
function Troposphere:OnNewRoom()
	if not game:GetRoom():IsFirstVisit() then return end
	local seed = self._Levels:GetRoomUniqueSeed()
	if RNG(seed):RandomInt(3) ~= 1 then return end
	for i = 0, game:GetNumPlayers() - 1 do
		local player = Isaac.GetPlayer(i)
		if player:HasCollectible(self.ID, true) and player:GetActiveItem(3) == 0 then
			player:SetPocketActiveItem(self:GetItem(seed - i), 3, true)
		end
	end		
end
Troposphere:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, 'OnNewRoom')

--受伤交换主动
function Troposphere:OnTakeDMG(ent, dmg, flag, source)
	local player = ent:ToPlayer()
	if player and player:HasCollectible(self.ID, true) then
		if player:GetCollectibleRNG(self.ID):RandomInt(3) == 0 then
			local first = player:GetActiveItem(0)
			local extra = player:GetActiveItem(3)
			if first > 0 and extra > 0 then
				player:RemoveCollectible(first, true, 0, false)
				player:AddCollectible(extra)
				player:SetPocketActiveItem(first, 3, true)
				
				player:RemoveCollectible(self.ID, true)
			end			
		end
	end
end
Troposphere:AddCallback(ModCallbacks.MC_POST_ENTITY_TAKE_DMG, 'OnTakeDMG')

return Troposphere
