--蜕变之蛾

local mod = Isaac_BenightedSoul

local game = Game()
local config = Isaac.GetItemConfig()

local Moth = mod.IBS_Class.Item(mod.IBS_ItemID.Moth)

--获取记录
function Moth:GetData(getOnly)
	local data = self:GetIBSData('level')
	
	if getOnly then
		return data.Moth
	end
	
	data.Moth = data.Moth or {Times = 0}
	return data.Moth
end

--获得时生成愚者卡
function Moth:OnGain(item, charge, first, slot, varData, player)
	if first then
		local room = game:GetRoom()
		local pos = room:FindFreePickupSpawnPosition(player.Position, 0, true)
		Isaac.Spawn(5, 300, 1, pos, Vector.Zero, nil)
	end
end
Moth:AddCallback(ModCallbacks.MC_POST_ADD_COLLECTIBLE, 'OnGain', Moth.ID)

--更改愚者卡的效果
function Moth:PreUseFoolCard(card, player)
	if player:HasCollectible(self.ID) and card == 1 then
		local data = self:GetData(true)
		if data and data.Times >= 4 then
			player:UseActiveItem(105, false, false) --D6
			player:AnimateCard(1, "UseItem")
			return true
		end
	end
end
Moth:AddCallback(ModCallbacks.MC_PRE_USE_CARD, 'PreUseFoolCard')

--使用卡牌
function Moth:OnUseCard(card, player)
	if not player:HasCollectible(self.ID) then return end
	if card == 1 then
		local data = self:GetData()
		data.Times = data.Times + 1
		
		if data.Times > 1 and  data.Times < 5 then
			local level = game:GetLevel()
			local roomType = RoomType.ROOM_SECRET

			if data.Times == 3 then
				roomType = RoomType.ROOM_SUPERSECRET
			elseif data.Times == 4 then
				roomType = RoomType.ROOM_ULTRASECRET	
			end

			--只会传送至主世界或镜世界
			local idx = level:QueryRoomTypeIndex(roomType, false, player:GetCollectibleRNG(self.ID), true)
			if idx then
				game:StartRoomTransition(idx, Direction.NO_DIRECTION, RoomTransitionAnim.TELEPORT, player, (level:GetDimension() == Dimension.MIRROR and -1) or 0)
			end	
		end
	else--使用塔罗牌时生成愚者
		local cardConfig = config:GetCard(card)
		if cardConfig and cardConfig.CardType == 0 or cardConfig.CardType == 5 then
			local room = game:GetRoom()
			local pos = room:FindFreePickupSpawnPosition(player.Position, 0, true)		
			Isaac.Spawn(5, 300, 1, pos, Vector.Zero, nil)
		end
	end
end
Moth:AddCallback(ModCallbacks.MC_USE_CARD, 'OnUseCard')


return Moth