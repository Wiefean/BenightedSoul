--宝库钥匙

local mod = Isaac_BenightedSoul

local game = Game()
local sfx = SFXManager()

local TreasureKey = mod.IBS_Class.Item(mod.IBS_ItemID.TreasureKey)

--宝库房间列表
TreasureKey.RoomList = {
	3,
	4,
	5,
	6,
	7,
	12,
	13,
	14,
	19,
	20,
	27,
	28,
	29,
	36,
	38,
	39,
	40,
	43,
	45,
	46,
	47,
}

--犹大长子权房间列表
TreasureKey.RoomList_JudasBr = {
	31,
	32,
	33,
	34,
	35,
	36,
	37,
	38,
	39,
	40,
}

--使用效果
function TreasureKey:OnUse(item, rng, player, flags, slot)
	if (flags & UseFlag.USE_CARBATTERY <= 0) and (flags & UseFlag.USE_VOID <= 0) then--拒绝车载电池和虚空
		local room = game:GetRoom()
		
		--贪婪模式改为传送到错误房
		if game:IsGreedMode() then
			game:StartRoomTransition(GridRooms.ROOM_ERROR_IDX, Direction.NO_DIRECTION, RoomTransitionAnim.TELEPORT, player, 0)

			--举起道具动画
			self:DelayFunction(function()
				player:AnimateCollectible(self.ID)
			end,1)			
		else
			--彼列书改为传送到诅咒房
			if player:HasCollectible(59) then
				local list = self.RoomList_JudasBr
				local variant = list[rng:RandomInt(1, #list)] or 3
				Isaac.ExecuteCommand('goto s.curse.'..variant)	
			else
				local list = self.RoomList
				local variant = list[rng:RandomInt(1, #list)] or 3
				Isaac.ExecuteCommand('goto s.chest.'..variant)
			end
			game:StartRoomTransition(-3, Direction.NO_DIRECTION, RoomTransitionAnim.TELEPORT, player)
			self._Levels:QuitDebugRoomWhenExit()
			
			--举起道具动画
			self:DelayFunction(function()
				player:AnimateCollectible(self.ID)
			end,1)
		end
	end
	
	--金钥匙
	if not player:HasGoldenKey() then
		player:AddGoldenKey()
		sfx:Play(204)
	end
	
	return {Discharge = true, ShowAnim = false}
end
TreasureKey:AddCallback(ModCallbacks.MC_USE_ITEM, 'OnUse', TreasureKey.ID)


--魂火熄灭
function TreasureKey:OnWispKilled(familiar)
    if (familiar.Variant == FamiliarVariant.WISP and familiar.SubType == (self.ID)) then
		local room = game:GetRoom()
		local pos = room:FindFreePickupSpawnPosition(familiar.Position, 0, true)
		Isaac.Spawn(5,50,0, pos, Vector.Zero, nil)
    end
end
TreasureKey:AddCallback(ModCallbacks.MC_POST_ENTITY_KILL, 'OnWispKilled', EntityType.ENTITY_FAMILIAR)



return TreasureKey