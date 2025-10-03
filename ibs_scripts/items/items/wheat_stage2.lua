--麦苗II

local mod = Isaac_BenightedSoul
local IBS_ItemID = mod.IBS_ItemID

local game = Game()

local GrowingWheatII = mod.IBS_Class.Item(IBS_ItemID.GrowingWheatII)


--效果
function GrowingWheatII:OnRoomCleaned()
	for i = 0, game:GetNumPlayers() - 1 do
		local player = Isaac.GetPlayer(i)
		if player:HasCollectible(self.ID, true) then
			for i = 1,player:GetCollectibleNum(self.ID, true) do
				player:RemoveCollectible(self.ID, true)
				player:AddCollectible(IBS_ItemID.GrowingWheatIII, 0, false)
			end
		end
	end
end
GrowingWheatII:AddPriorityCallback(ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD, -2, 'OnRoomCleaned')
GrowingWheatII:AddPriorityCallback(mod.IBS_CallbackID.GREED_NEW_WAVE, -2, 'OnRoomCleaned')




return GrowingWheatII