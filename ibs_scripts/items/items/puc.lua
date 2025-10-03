--杯水

local mod = Isaac_BenightedSoul
local IBS_ItemID = mod.IBS_ItemID

local game = Game()
local config = Isaac.GetItemConfig()

local PUC = mod.IBS_Class.Item(IBS_ItemID.PUC)

--抽取愚昧道具
function PUC:GetItem(seed)
	local itemPool = game:GetItemPool()
	local cache = {}
	local result = 25

	for k,id in pairs(IBS_ItemID) do
		local itemConfig = config:GetCollectible(id)
		if itemConfig and itemConfig:IsAvailable() and itemPool:HasCollectible(id) then
			table.insert(cache, id)
		end
	end
	
	if #cache > 0 then
		result = cache[RNG(seed):RandomInt(1, #cache)] or 25
		itemPool:RemoveCollectible(result)
	end	
	
	return result
end

function PUC:OnPickupFirstAppear(pickup)
	if not PlayerManager.AnyoneHasCollectible(self.ID) then return end
	if pickup.SubType <= 0 then return end
	local room = game:GetRoom()
	local seed = pickup.InitSeed
	local chance = 35; if PlayerManager.AnyoneHasCollectible(IBS_ItemID.Goatify) then chance = chance * 2 end
	if RNG(seed):RandomInt(100) < chance then
		pickup:AddCollectibleCycle(self:GetItem(seed))
	end
end
PUC:AddCallback(mod.IBS_CallbackID.PICKUP_FIRST_APPEAR, 'OnPickupFirstAppear', 100)



return PUC