--对流层

local mod = Isaac_BenightedSoul

local game = Game()
local config = Isaac.GetItemConfig()

local Troposphere = mod.IBS_Class.Item(mod.IBS_ItemID.Troposphere)


--获得道具触发
function Troposphere:OnGainItem(item, charge, first, slot, varData, player)
	if item <= 0 then return end
	if slot > 1 then return end --忽略副手
	if not player:HasCollectible(item, true) then return end
	local has = false
	local whoHas = nil
	for i = 0, game:GetNumPlayers() - 1 do
		local p = Isaac.GetPlayer(i)
		if p:HasCollectible(self.ID, true) then
			has = true
			whoHas = p
			break
		end
	end
	if not has then return end
	
	--主动道具,非任务道具
	local itemConfig = config:GetCollectible(item)
	if not itemConfig then return end
	if itemConfig.Type ~= ItemType.ITEM_ACTIVE then return end
	if itemConfig:HasTags(ItemConfig.TAG_QUEST) then return end
	
	--移除并记录持有的主动,获得上一次记录的主动
	local data = self:GetIBSData('persis')
	player:RemoveCollectible(item, true)
	whoHas:RemoveCollectible(self.ID, true)
	if data.troposphere > 0 then
		player:AddCollectible(data.troposphere)
	end
	Isaac.Spawn(1000, 15, 0, player.Position, Vector.Zero, nil)
	data.troposphere = item
	self:SaveIBSData()
end
Troposphere:AddPriorityCallback(ModCallbacks.MC_POST_ADD_COLLECTIBLE, 999, 'OnGainItem')


return Troposphere
