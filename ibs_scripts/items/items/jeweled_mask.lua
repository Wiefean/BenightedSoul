--宝石面具

local mod = Isaac_BenightedSoul

local game = Game()
local config = Isaac.GetItemConfig()

local JeweledMask = mod.IBS_Class.Item(mod.IBS_ItemID.JeweledMask)

--获取一个角色身上的道具
function JeweledMask:GetItem(player, seed)
	local result = {}

	local MAX = config:GetCollectibles().Size - 1
	for id = 1, MAX do
		local itemConfig = config:GetCollectible(id)
		if itemConfig and player:HasCollectible(id) 
			and itemConfig.Type ~= ItemType.ITEM_ACTIVE
			and not itemConfig:HasTags(ItemConfig.TAG_QUEST)
		then
			table.insert(result, id)
		end
	end

	--抽取一个
	if #result > 0 then
		return result[RNG(seed):RandomInt(1, #result)] or result[1]
	end
end

--新层
function JeweledMask:OnNewLevel()
	local room = game:GetRoom()
	for i = 0, game:GetNumPlayers() - 1 do
		local player = Isaac.GetPlayer(i)
		if player:HasCollectible(self.ID) then
			local num = player:GetCollectibleNum(self.ID)
			for i2 = 1, num do			
				local seed = player:GetCollectibleRNG(self.ID):Next()
				local id = self:GetItem(player, seed)
				local pos = room:FindFreePickupSpawnPosition(room:GetCenterPos() + Vector(-160,-80), 0, true)
				Isaac.Spawn(5, 100, id, pos, Vector.Zero, nil)
			end
		end
	end
end
JeweledMask:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, 'OnNewLevel')


return JeweledMask