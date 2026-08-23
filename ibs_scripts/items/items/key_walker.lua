--钥匙行者

local mod = Isaac_BenightedSoul
local IBS_PickupID = mod.IBS_PickupID

local game = Game()
local sfx = SFXManager()

local KeyWalker = mod.IBS_Class.Item(mod.IBS_ItemID.KeyWalker)

--获取数据
function KeyWalker:GetData(player)
	local data = self._Ents:GetTempData(player)
	data.KeyWalker = data.KeyWalker or {
		CD = 0,
	}
	return data.KeyWalker
end

--角色更新
function KeyWalker:OnPlayerUpdate(player)
	if not player:HasCollectible(self.ID) then return end
	local data = self:GetData(player)

	if data.CD > 0 then
		data.CD = data.CD - 1
	else		
		local target = self._Finds:ClosestEnemy(player.Position)
		if target then
			data.CD = 360
		
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


--钥匙更新
function KeyWalker:OnPickupUpdate(pickup)
	if not PlayerManager.AnyoneHasCollectible(self.ID) then return end
	if pickup.FrameCount < 30 then return end
	
	--金钥匙检测
	if Isaac.GetPlayer(0):HasGoldenKey() and pickup.SubType == 2 then return end

	local ent = self._Finds:ClosestEntity(pickup.Position, 1, 0, -1, function(ent)
		local player = ent and ent:ToPlayer()
		if player and player:HasCollectible(self.ID) and self._Players:IsShooting(player) then
			return true
		end
	end)
	
	if ent then
		pickup.Velocity = pickup.Velocity + (ent.Position - pickup.Position):Resized(1)
	end
end
KeyWalker:AddCallback(ModCallbacks.MC_POST_PICKUP_UPDATE, 'OnPickupUpdate', 30)

--钥匙忽略障碍物碰撞
function KeyWalker:PrePickupGridCollision()
	if game:GetRoom():GetType() ~= RoomType.ROOM_DUNGEON and PlayerManager.AnyoneHasCollectible(self.ID) then
		return true
	end
end
KeyWalker:AddCallback(ModCallbacks.MC_PRE_PICKUP_GRID_COLLISION, 'PrePickupGridCollision', 30)


return KeyWalker