--拉撒路的伪忆

local mod = Isaac_BenightedSoul

local game = Game()

local BLazarus = mod.IBS_Class.Pocket(mod.IBS_PocketID.BLazarus)

--目的地
BLazarus.Destination = {
	[RoomType.ROOM_SHOP] = RoomType.ROOM_TREASURE,
	[RoomType.ROOM_TREASURE] = RoomType.ROOM_SHOP,

	[RoomType.ROOM_SECRET] = RoomType.ROOM_SUPERSECRET,
	[RoomType.ROOM_SUPERSECRET] = RoomType.ROOM_SECRET,

	[RoomType.ROOM_ARCADE] = RoomType.ROOM_CURSE,
	[RoomType.ROOM_CURSE] = RoomType.ROOM_ARCADE,

	[RoomType.ROOM_ULTRASECRET] = RoomType.ROOM_PLANETARIUM,
	[RoomType.ROOM_PLANETARIUM] = RoomType.ROOM_ULTRASECRET,
}

--房间列表
BLazarus.RoomList = {
	[RoomType.ROOM_SHOP] = {4, 5, 10, 16, 17},
	[RoomType.ROOM_TREASURE] = {23, 33, 34, 35},
	[RoomType.ROOM_SECRET] = {0},
	[RoomType.ROOM_SUPERSECRET] = {7, 29, 30},
	[RoomType.ROOM_ARCADE] = {42, 43, 46, 50},
	[RoomType.ROOM_CURSE] = {3, 40},
	[RoomType.ROOM_ULTRASECRET] = {0, 1, 2, 6},
	[RoomType.ROOM_PLANETARIUM] = {0, 1, 2},
}

--贪婪模式房间列表
BLazarus.RoomList_Greed = {
	[RoomType.ROOM_SHOP] = {0, 1, 2, 3, 4, 6, 7, 8, 9, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 24},
	[RoomType.ROOM_TREASURE] = {11, 12, 13, 14, 15, 16},
	[RoomType.ROOM_SECRET] = {7250},
	[RoomType.ROOM_SUPERSECRET] = {22},
	[RoomType.ROOM_ARCADE] = {7250},
	[RoomType.ROOM_CURSE] = {23},	
	[RoomType.ROOM_ULTRASECRET] = {7250},
	[RoomType.ROOM_PLANETARIUM] = {7250, 7251, 7252},
}

local checkladder = false

--效果
function BLazarus:OnUse(card, player, flag)
	local SUCCESS = false

	if flag & UseFlag.USE_MIMIC <= 0 and game:GetLevel():GetCurrentRoomIndex() ~= -3 then
		local roomType = self.Destination[game:GetRoom():GetType()]
		local cmd = self._Levels:RoomTypeToCMD(roomType)
		
		if roomType and cmd then
			local list = (game:IsGreedMode() and self.RoomList_Greed[roomType]) or self.RoomList[roomType]
			if list then
				local variant = list[player:GetCardRNG(self.ID):RandomInt(1, #list)]
				if variant then
					checkladder = true
					Isaac.ExecuteCommand('goto s.'..cmd..'.'..variant)
					game:StartRoomTransition(-3, Direction.NO_DIRECTION, RoomTransitionAnim.TELEPORT, player)
					self._Levels:QuitDebugRoomWhenExit()
					SUCCESS = true
				end
			end
		end
	end

	--成功传送时获得1碎心,否则获得2魂心
	if SUCCESS then
		player:AddBrokenHearts(1)
	else
		player:AddSoulHearts(4)
	end
end
BLazarus:AddCallback(ModCallbacks.MC_USE_CARD, 'OnUse', BLazarus.ID)

--生成梯子防止回不去
mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, function()
	if checkladder and game:GetLevel():GetCurrentRoomIndex() == -3 then
		local room = game:GetRoom()
		if #Isaac.FindByType(1000, 156, 0) <= 0 then
			local pos = room:FindFreePickupSpawnPosition(room:GetGridPosition(26))
			Isaac.Spawn(1000, 156, 0, pos, Vector.Zero, nil)
		end
		checkladder = false
	end
end)

--符文佩剑(东方mod)
if mod.IBS_Compat.THI:IsEnabled() then
	local RuneSword = THI.Collectibles.RuneSword

	mod.IBS_Compat.THI:AddRuneSwordCompat(BLazarus.ID, {
		png = "gfx/ibs/items/pick ups/falsehoods/blazarus.png",
		textKey = "FALSEHOOD_BLAZARUS",
		name = {
			zh = "拉撒路的伪忆",
			en = "Falsehood of Lazarus",
		},
		desc = {
			zh = "特殊访问礼",
			en = "Special visit gift",
		}, 
	})
	
	--新房间触发
	function BLazarus:OnNewRoom()
		local room = game:GetRoom()
		if room:IsFirstVisit() and room:GetType() ~= RoomType.ROOM_DEFAULT then
			for i = 0, game:GetNumPlayers() - 1 do
				local player = Isaac.GetPlayer(i)
				local num = RuneSword:GetInsertedRuneNum(player, self.ID)
				if num > 0 then
					player:AddSoulHearts(num)
					Isaac.Spawn(1000, 49, 4, player.Position, Vector.Zero, nil)
					SFXManager():Play(54)
				end
			end
		end
	end
	BLazarus:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, 'OnNewRoom')
	
end

return BLazarus