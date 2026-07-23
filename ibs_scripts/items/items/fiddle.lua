--小提琴

local mod = Isaac_BenightedSoul
local IBS_ItemID = mod.IBS_ItemID

local game = Game()
local config = Isaac.GetItemConfig()

local Fiddle = mod.IBS_Class.Item(IBS_ItemID.Fiddle)

--非主动道具
local function Condition(itemConfig)
	if itemConfig.Type ~= ItemType.ITEM_ACTIVE then
		return true
	end
	return false
end

--获取道具
function Fiddle:GetItem(seed)
	return self._Pools:GetCollectibleWithCondition(seed, Condition, game:GetItemPool():GetRandomPool(RNG(seed)), true)
end 

--每层生成两个随机道具
function Fiddle:OnNewLevel()
	if not PlayerManager.AnyoneHasCollectible(self.ID) then return end
	local room = game:GetRoom()
	local itemPool = game:GetItemPool()
	local seed = self._Levels:GetLevelUniqueSeed()

	for i = 1,2 do	
		local pos = room:FindFreePickupSpawnPosition(room:GetCenterPos() + Vector(-160,-80), 0, true)
		local id = self:GetItem(seed)
		Isaac.Spawn(5, 100, id, pos, Vector.Zero, nil)
	end
end
Fiddle:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, 'OnNewLevel')


--阻止进入房间0.1秒后生成的道具
function Fiddle:OnPickupInit(pickup)
	if not PlayerManager.AnyoneHasCollectible(self.ID) then return end
	if pickup.SubType == 0 then return end
	local room = game:GetRoom()
	
	if room:GetFrameCount() > 4 and room:GetType() ~= RoomType.ROOM_BOSS then
	
		--任务道具检测
		local itemConfig = config:GetCollectible(pickup.SubType)
		if itemConfig and itemConfig:HasTags(ItemConfig.TAG_QUEST) then
			return
		end
		
		Isaac.Spawn(1000,15,0, pickup.Position, Vector.Zero, nil)
		pickup:Remove()
	end
end
Fiddle:AddCallback(ModCallbacks.MC_POST_PICKUP_INIT, 'OnPickupInit', 100)


return Fiddle
