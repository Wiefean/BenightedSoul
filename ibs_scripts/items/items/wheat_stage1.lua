--麦苗I

local mod = Isaac_BenightedSoul
local IBS_ItemID = mod.IBS_ItemID

local game = Game()

local GrowingWheatI = mod.IBS_Class.Item(IBS_ItemID.GrowingWheatI)


--效果
function GrowingWheatI:OnRoomCleaned()
	for i = 0, game:GetNumPlayers() - 1 do
		local player = Isaac.GetPlayer(i)
		if player:HasCollectible(self.ID, true) then
			for i = 1,player:GetCollectibleNum(self.ID, true) do
				player:RemoveCollectible(self.ID, true)
				player:AddCollectible(IBS_ItemID.GrowingWheatII, 0, false)
			end
		end
	end
end
GrowingWheatI:AddPriorityCallback(ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD, -1, 'OnRoomCleaned')
GrowingWheatI:AddPriorityCallback(mod.IBS_CallbackID.GREED_NEW_WAVE, -1, 'OnRoomCleaned')




return GrowingWheatI