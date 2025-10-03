--麦苗V

local mod = Isaac_BenightedSoul
local IBS_ItemID = mod.IBS_ItemID

local game = Game()

local GrowingWheatV = mod.IBS_Class.Item(IBS_ItemID.GrowingWheatV)


--效果
function GrowingWheatV:OnRoomCleaned()
	for i = 0, game:GetNumPlayers() - 1 do
		local player = Isaac.GetPlayer(i)
		if player:HasCollectible(self.ID, true) then
			for i = 1,player:GetCollectibleNum(self.ID, true) do
				player:RemoveCollectible(self.ID, true)
				player:AddCollectible(IBS_ItemID.GrowingWheatVI, 0, false)
			end
		end
	end
end
GrowingWheatV:AddPriorityCallback(ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD, -5, 'OnRoomCleaned')
GrowingWheatV:AddPriorityCallback(mod.IBS_CallbackID.GREED_NEW_WAVE, -5, 'OnRoomCleaned')




return GrowingWheatV