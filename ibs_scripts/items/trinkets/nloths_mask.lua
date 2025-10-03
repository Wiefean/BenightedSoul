--恩洛斯的脸

local mod = Isaac_BenightedSoul
local IBS_CallbackID = mod.IBS_CallbackID
local AbandonedItem = mod.IBS_Effect.AbandonedItem

local game = Game()
local config = Isaac.GetItemConfig()

local NlothsMask = mod.IBS_Class.Trinket(mod.IBS_TrinketID.NlothsMask)

--道具首次出现时触发
function NlothsMask:OnPickupFirstAppear(pickup)
	if pickup.SubType <= 0 then return end --非错误道具和空底座
	if pickup.SubType == 515 then return end --非礼物
	local itemConfig = config:GetCollectible(pickup.SubType)
		
	--非任务道具
	if itemConfig and itemConfig:HasTags(ItemConfig.TAG_QUEST) then
		return
	end

	local room = game:GetRoom()
	for i = 0, game:GetNumPlayers() -1 do
		local player = Isaac.GetPlayer(i)
		if player:HasTrinket(self.ID) then
			local mult = player:GetTrinketMultiplier(self.ID)
			if mult > 3 then mult = 3 end
			player:TryRemoveTrinket(self.ID)
			
			Isaac.Spawn(5, 100, 515, pickup.Position, Vector.Zero, nil)
			
			if mult > 1 then
				for i = 1,mult-1 do
					local pos = room:FindFreePickupSpawnPosition(pickup.Position, 0, true)
					Isaac.Spawn(5, 100, 515, pos, Vector.Zero, nil)
				end	
			end
			
			--特效
			if itemConfig.GfxFileName then
				AbandonedItem:Spawn(pickup.Position, itemConfig.GfxFileName, RandomVector() * 0.1 * math.random(7, 12))
			end	
			
			pickup:Remove()
		end
	end
end
NlothsMask:AddCallback(IBS_CallbackID.PICKUP_FIRST_APPEAR, 'OnPickupFirstAppear', 100)

return NlothsMask