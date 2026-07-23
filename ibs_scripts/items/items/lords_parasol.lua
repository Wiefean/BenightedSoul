--领主阳伞

local mod = Isaac_BenightedSoul
local AbandonedItem = mod.IBS_Effect.AbandonedItem

local game = Game()
local config = Isaac.GetItemConfig()
local sfx = SFXManager()

local LordsParasol = mod.IBS_Class.Item(mod.IBS_ItemID.LordsParasol)


function LordsParasol:OnPlayerUpdate(player)
	if player:IsFrame(15,0) and player:HasCollectible(self.ID, true) then
		
		--进入商店检测
		local room = game:GetRoom()
		if room:GetType() == RoomType.ROOM_SHOP and room:IsFirstVisit() and room:GetFrameCount() > 10 then	
			local pickup = self._Finds:ClosestCollectible(player.Position)
			if pickup and pickup.SubType > 0 and pickup.Price ~= 0 then
				local id = pickup.SubType
				local itemConfig = config:GetCollectible(id)
				if itemConfig then
					--主动
					if itemConfig.Type == ItemType.ITEM_ACTIVE then
						local slot = 0
						
						--移除原来的主动
						local oldactive = player:GetActiveItem(slot)
						if oldactive then
							player:RemoveCollectible(oldactive, true, slot, false)
						end
						
						--特效
						local itemConfig2 = config:GetCollectible(oldactive)
						if itemConfig2 and itemConfig2.GfxFileName then
							AbandonedItem:Spawn(player.Position, itemConfig2.GfxFileName, 2*RandomVector())
							sfx:Play(267)
						end
						
						player:AddCollectible(id, itemConfig.InitCharge)
					else
						player:AddCollectible(id)
					end
					pickup:Remove()
					Isaac.Spawn(1000,15,0, pickup.Position, Vector.Zero, nil)
				end			
			end
		end
		
	end
end
LordsParasol:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, 'OnPlayerUpdate')


return LordsParasol