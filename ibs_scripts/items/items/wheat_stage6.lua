--麦苗VI

local mod = Isaac_BenightedSoul
local IBS_ItemID = mod.IBS_ItemID

local game = Game()

local GrowingWheatVI = mod.IBS_Class.Item(IBS_ItemID.GrowingWheatVI)


--效果
function GrowingWheatVI:OnRoomCleaned()
	for i = 0, game:GetNumPlayers() - 1 do
		local player = Isaac.GetPlayer(i)
		if player:HasCollectible(self.ID, true) then
			for i = 1,player:GetCollectibleNum(self.ID, true) do
				player:RemoveCollectible(self.ID, true)
				player:AddCollectible(IBS_ItemID.Wheat, 0, false)
			end
		end
	end
end
GrowingWheatVI:AddPriorityCallback(ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD, -6, 'OnRoomCleaned')
GrowingWheatVI:AddPriorityCallback(mod.IBS_CallbackID.GREED_NEW_WAVE, -6, 'OnRoomCleaned')




return GrowingWheatVI