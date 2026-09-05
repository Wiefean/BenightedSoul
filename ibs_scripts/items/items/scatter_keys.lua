--分裂钥匙

local mod = Isaac_BenightedSoul

local game = Game()
local sfx = SFXManager()

local ScatterKeys = mod.IBS_Class.Item(mod.IBS_ItemID.ScatterKeys)

--箱子列表
ScatterKeys.ChestList = {
	[PickupVariant.PICKUP_ETERNALCHEST] = true,
	[PickupVariant.PICKUP_OLDCHEST] = true,
	--[PickupVariant.PICKUP_MEGACHEST] = true,
	[PickupVariant.PICKUP_LOCKEDCHEST] = true,
}

--失去钥匙时触发
function ScatterKeys:OnKeyNumChange(delta)
	if delta < 0 then
		for i = 0, game:GetNumPlayers() - 1 do
			local player = Isaac.GetPlayer(i)
			if player:HasCollectible(self.ID) then
				player:UseActiveItem(175, false, false)
				sfx:Stop(204)
			
				--打开上锁的箱子
				for _,ent in ipairs(Isaac.FindByType(5)) do
					local pickup = ent:ToPickup()
				
					if pickup and self.ChestList[pickup.Variant] then
						pickup:TryOpenChest(player)
					end
				end
			
				break
			end
		end	
	end
end
ScatterKeys:AddCallback(mod.IBS_CallbackID.NUM_CHANGE_KEY,'OnKeyNumChange')


return ScatterKeys