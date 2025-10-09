--可悲的疯人

local mod = Isaac_BenightedSoul
local IBS_CallbackID = mod.IBS_CallbackID

local game = Game()
local config = Isaac.GetItemConfig()

local TheLunatic = mod.IBS_Class.Trinket(mod.IBS_TrinketID.TheLunatic)

--道具首次出现时触发
function TheLunatic:OnPickupFirstAppear(pickup)
	if pickup.SubType <= 0 then return end --非错误道具和空底座
	local mult = PlayerManager.GetTotalTrinketMultiplier(self.ID); if mult <= 0 then return end
	local itemConfig = config:GetCollectible(pickup.SubType)
	
	--非任务道具
	if itemConfig and itemConfig:HasTags(ItemConfig.TAG_QUEST) then
		return
	end
	
	--概率替换为蠢巫帽
	if RNG(pickup.InitSeed):RandomInt(100) < 10*mult then		
		pickup:AddCollectibleCycle(358)
	end
end
TheLunatic:AddCallback(IBS_CallbackID.PICKUP_FIRST_APPEAR, 'OnPickupFirstAppear', 100)

return TheLunatic