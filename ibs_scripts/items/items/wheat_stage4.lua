--麦苗IV

local mod = Isaac_BenightedSoul
local IBS_ItemID = mod.IBS_ItemID

local game = Game()

local GrowingWheatIV = mod.IBS_Class.Item(IBS_ItemID.GrowingWheatIV)


--效果
function GrowingWheatIV:OnRoomCleaned()
	for i = 0, game:GetNumPlayers() - 1 do
		local player = Isaac.GetPlayer(i)
		if player:HasCollectible(self.ID, true) then
			for i = 1,player:GetCollectibleNum(self.ID, true) do
				player:RemoveCollectible(self.ID, true)
				player:AddCollectible(IBS_ItemID.GrowingWheatV, 0, false)
			end
		end
	end
end
GrowingWheatIV:AddPriorityCallback(ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD, -4, 'OnRoomCleaned')
GrowingWheatIV:AddPriorityCallback(mod.IBS_CallbackID.GREED_NEW_WAVE, -4, 'OnRoomCleaned')




return GrowingWheatIV