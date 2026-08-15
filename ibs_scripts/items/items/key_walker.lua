--钥匙行者

local mod = Isaac_BenightedSoul
local IBS_PickupID = mod.IBS_PickupID

local game = Game()
local sfx = SFXManager()

local KeyWalker = mod.IBS_Class.Item(mod.IBS_ItemID.KeyWalker)

--角色更新
function KeyWalker:OnPlayerUpdate(player)
	if player:IsFrame(180,0) and player:HasCollectible(self.ID) then	
		local target = self._Finds:ClosestEnemy(player.Position)
		if target then
			local num = player:GetCollectibleRNG(self.ID):RandomInt(3) + 1
			for i = 1,num do
				--金钥匙
				if player:HasGoldenKey() then
					player:RemoveGoldenKey()
					Isaac.Spawn(5, IBS_PickupID.KeyWalker.Variant, IBS_PickupID.KeyWalker.SubType.Golden, player.Position, (target.Position - player.Position):Resized(math.random(4,8)) + 2 * RandomVector(), nil)
				else
					if player:GetNumKeys() > 0 then
						player:AddKeys(-1)
						Isaac.Spawn(5, IBS_PickupID.KeyWalker.Variant, IBS_PickupID.KeyWalker.SubType.Common, player.Position, (target.Position - player.Position):Resized(math.random(4,8)) + 2 * RandomVector(), nil)
					end
				end			
			end
		end
	end
end
KeyWalker:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, 'OnPlayerUpdate', 0)


return KeyWalker