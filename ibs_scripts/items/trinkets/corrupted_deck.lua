--腐蚀套牌

local mod = Isaac_BenightedSoul

local game = Game()
local config = Isaac.GetItemConfig()

local CorruptedDeck = mod.IBS_Class.Trinket(mod.IBS_TrinketID.CorruptedDeck)

--获得时生成三张塔罗牌
function CorruptedDeck:OnGain(player, trinket, first)
	if first then
		local room = game:GetRoom()
		for i = 1,2 do
			local pos = room:FindFreePickupSpawnPosition(player.Position, 0, true)
			Isaac.Spawn(5, 300, player:GetTrinketRNG(self.ID):RandomInt(1,22), pos, Vector.Zero, nil)	
		end
	end
end
CorruptedDeck:AddCallback(ModCallbacks.MC_POST_TRIGGER_TRINKET_ADDED, 'OnGain', CorruptedDeck.ID)
CorruptedDeck:AddCallback(ModCallbacks.MC_POST_TRIGGER_TRINKET_ADDED, 'OnGain', CorruptedDeck.ID+32768)

--清理房间时概率生成塔罗牌
function CorruptedDeck:OnRoomCleaned()
	local room = game:GetRoom()
	for i = 0, game:GetNumPlayers() - 1 do
		local player = Isaac.GetPlayer(i)
		if player:HasTrinket(self.ID) then
			local rng = player:GetTrinketRNG(self.ID)
			local chance = 6 * player:GetTrinketMultiplier(self.ID)
			if rng:RandomInt(100) < chance then
				local pos = room:FindFreePickupSpawnPosition(room:GetCenterPos(), 0, true)
				Isaac.Spawn(5, 300, rng:RandomInt(1,22), pos, Vector.Zero, nil)			
			end
		end
	end
end
CorruptedDeck:AddCallback(ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD, 'OnRoomCleaned')

--根据塔罗牌获取逆位塔罗牌ID,或反之
function CorruptedDeck:GetReversedTarot(id)
	if id >= 1 and id <= 22 then
		return id + 55
	end
	if id >= 56 and id <= 77 then
		return id - 55
	end
end

--获取塔罗牌点数
function CorruptedDeck:GetTarotNumber(id, alsoReversed)
	if id >= 1 and id <= 22 then
		return id - 1
	end
	if alsoReversed and id >= 56 and id <= 77 then
		return id - 56
	end
end

--使用塔罗牌时尝试将点数更低的塔罗牌变为逆位塔罗牌
function CorruptedDeck:OnUseCard(id, player, flag)
	if (flag & UseFlag.USE_MIMIC > 0) or (flag & UseFlag.USE_NOANIM > 0) or (flag & UseFlag.USE_NOHUD > 0) then return end
	if not player:HasTrinket(self.ID) then return end
	local number = self:GetTarotNumber(id, true)
	if number then
		for _,ent in ipairs(Isaac.FindByType(5,300)) do
			local pickup = ent:ToPickup()
			if pickup then
				local number2 = self:GetTarotNumber(pickup.SubType)
				if number2 and number2 < number then
					local reversed = self:GetReversedTarot(pickup.SubType)
					if reversed then
						pickup:Morph(5, 300, reversed, true)
					end
				end
			end
		end
	end
end
CorruptedDeck:AddCallback(ModCallbacks.MC_USE_CARD, 'OnUseCard')


return CorruptedDeck