--帘锁挖掘

local mod = Isaac_BenightedSoul
local Pools = mod.IBS_Lib.Pools
local IBS_CallbackID = mod.IBS_CallbackID

local game = Game()
local config = Isaac.GetItemConfig()

local VainMiner = mod.IBS_Class.Item(mod.IBS_ItemID.VainMiner)

--获取道具结果
function VainMiner:GetItem(selectedID, seed)
	local rng = RNG(seed)

	if selectedID > 0 and rng:RandomInt(1000) > 109 then
		for i = 1,2 do
			local id = selectedID + (-1)^i
			local itemConfig = config:GetCollectible(id)
			if itemConfig and itemConfig:IsAvailable() and not itemConfig:HasTags(ItemConfig.TAG_QUEST) then			
				return id
			end
		end
	end

	--返回-1表示错误道具
	return -1
end

--拾取道具时触发
function VainMiner:OnPickItem(player, item, touched, pickup)
	if touched then return end 
	if not PlayerManager.AnyoneHasCollectible(self.ID) then return end
	local data = self:GetIBSData('level')
	data.VainMinerCount = data.VainMinerCount or 0
	if data.VainMinerCount >= 1 then return end
	
	--仅对空底座生效
	if pickup.SubType == 0 then
	
		--重置为id相邻的道具
		local id = self:GetItem(item, pickup.InitSeed)
		if id > 0 then
			pickup:Morph(5, 100, id, true)
		else
			--失败则变为错误道具
			self._Pickups:MorphToErrorItem(pickup, true)
		end

		data.VainMinerCount = data.VainMinerCount + 1
	end
end
VainMiner:AddCallback(IBS_CallbackID.PICK_COLLECTIBLE, 'OnPickItem')


return VainMiner