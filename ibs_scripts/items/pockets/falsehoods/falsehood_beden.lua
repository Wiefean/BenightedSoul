--伊甸的伪忆

local mod = Isaac_BenightedSoul

local game = Game()

local BEden = mod.IBS_Class.Pocket(mod.IBS_PocketID.BEden)


--效果
function BEden:OnUse(card, player, flag)
	local room = game:GetRoom()

	self:GetIBSData('temp').BEdenFalsehoodUsed = true
	
	--已在错误房则生成道具,否则传送至错误房
	if room:GetType() == RoomType.ROOM_ERROR then
		local seed = player:GetCardRNG(self.ID):Next()
		local itemPool = game:GetItemPool()
		local pool = itemPool:GetPoolForRoom(RoomType.ROOM_ERROR, seed)
		local id = itemPool:GetCollectible(pool, true, seed)
		local pos = room:FindFreePickupSpawnPosition(room:GetCenterPos(), 0, true)
		Isaac.Spawn(5, 100, id, pos, Vector(0,0), nil)
	else
		game:StartRoomTransition(GridRooms.ROOM_ERROR_IDX, Direction.NO_DIRECTION, RoomTransitionAnim.TELEPORT, player, 0)
	end
end
BEden:AddCallback(ModCallbacks.MC_USE_CARD, 'OnUse', BEden.ID)

--错误房生成紫色传送门
function BEden:OnNewRoom()
	local room = game:GetRoom()
	if room:GetType() == RoomType.ROOM_ERROR and self:GetIBSData('temp').BEdenFalsehoodUsed then
		local pos = room:FindFreePickupSpawnPosition(room:GetCenterPos() + Vector(0,-120), 0, true)
		Isaac.Spawn(1000, 161, 3, pos, Vector.Zero, nil)
	end
end
BEden:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, 'OnNewRoom')

--符文佩剑(东方mod)
if mod.IBS_Compat.THI:IsEnabled() then
	local RuneSword = THI.Collectibles.RuneSword

	mod.IBS_Compat.THI:AddRuneSwordCompat(BEden.ID, {
		png = "gfx/ibs/items/pick ups/falsehoods/beden.png",
		textKey = "FALSEHOOD_BEDEN",
		name = {
			zh = "伊甸的伪忆",
			en = "Falsehood of Eden",
		},
		desc = {
			zh = "寻真",
			en = "Sought",
		}, 
	})
	
	--每层生成一个
	function BEden:OnNewLevel()
		if not RuneSword:HasGlobalRune(self.ID) then return end	
		local room = game:GetRoom()
		local pos = room:FindFreePickupSpawnPosition(room:GetCenterPos() + Vector(0,-80), 0, true)
		Isaac.Spawn(5, 300, self.ID, pos, Vector.Zero, nil)
	end
	BEden:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, 'OnNewLevel')	

end

return BEden