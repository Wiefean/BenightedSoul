--麦苗III

local mod = Isaac_BenightedSoul
local IBS_ItemID = mod.IBS_ItemID

local game = Game()

local GrowingWheatIII = mod.IBS_Class.Item(IBS_ItemID.GrowingWheatIII)


--效果
function GrowingWheatIII:OnRoomCleaned()
	for i = 0, game:GetNumPlayers() - 1 do
		local player = Isaac.GetPlayer(i)
		if player:HasCollectible(self.ID, true) then
			for i = 1,player:GetCollectibleNum(self.ID, true) do
				player:RemoveCollectible(self.ID, true)
				player:AddCollectible(IBS_ItemID.GrowingWheatIV, 0, false)	
			end
		end
	end
end
GrowingWheatIII:AddPriorityCallback(ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD, -3, 'OnRoomCleaned')
GrowingWheatIII:AddPriorityCallback(mod.IBS_CallbackID.GREED_NEW_WAVE, -3, 'OnRoomCleaned')




return GrowingWheatIII