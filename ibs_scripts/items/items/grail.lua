--筵宴之杯

local mod = Isaac_BenightedSoul

local game = Game()

local Grail = mod.IBS_Class.Item(mod.IBS_ItemID.Grail)

--获取记录
function Grail:GetData()
	local data = self:GetIBSData('room')
	data.Grail = data.Grail or {Triggered = false}
	return data.Grail
end

--获得时生成恶魔卡
function Grail:OnGain(item, charge, first, slot, varData, player)
	if first then
		local room = game:GetRoom()
		local pos = room:FindFreePickupSpawnPosition(player.Position, 0, true)
		Isaac.Spawn(5, 300, 16, pos, Vector.Zero, nil)
	end
end
Grail:AddCallback(ModCallbacks.MC_POST_ADD_COLLECTIBLE, 'OnGain', Grail.ID)

--使用恶魔卡
function Grail:OnUseDevilCard(card, player)
	if player:HasCollectible(self.ID) then
		local data = self:GetData()
		data.Triggered = true
		self._Stats:PersisDamage(player, 0.15, true)
	end
end
Grail:AddCallback(ModCallbacks.MC_USE_CARD, 'OnUseDevilCard', 16)

--获取恶魔卡生成概率
function Grail:GetChanceToSpawn(player)
	local chance = 5

	if player:GetHearts() > 0 then chance = chance + 5 end
	if player:GetSoulHearts() > 0 then chance = chance + 5 end
	if player:GetEternalHearts() > 0 then chance = chance + 5 end
	if player:GetBlackHearts() > 0 then chance = chance + 5 end
	if player:GetGoldenHearts() > 0 then chance = chance + 5 end
	if player:GetBoneHearts() > 0 then chance = chance + 5 end
	if player:GetRottenHearts() > 0 then chance = chance + 5 end
	if player:GetBrokenHearts() > 0 then chance = chance + 5 end
	
	if game:IsGreedMode() then
		chance = math.ceil(chance / 2)
	end
	
	return chance
end

--清理房间
function Grail:OnRoomCleaned()
	for i = 0, game:GetNumPlayers() -1 do
		local player = Isaac.GetPlayer(i)
		if player:HasCollectible(self.ID) and player:GetCollectibleRNG(self.ID):RandomInt(100) < self:GetChanceToSpawn(player) then
			local room = game:GetRoom()
			local pos = room:FindFreePickupSpawnPosition(room:GetCenterPos(), 0, true)
			Isaac.Spawn(5, 300, 16, pos, Vector.Zero, nil):ToPickup()	
		end
	end
end
Grail:AddCallback(ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD, 'OnRoomCleaned')
Grail:AddCallback(mod.IBS_CallbackID.GREED_NEW_WAVE, 'OnRoomCleaned')

--杀敌掉心
function Grail:OnEntityKilled(ent)
	local data = self:GetIBSData('room')
	if self._Ents:IsEnemy(ent, true) and data.Grail and data.Grail.Triggered then
		local pickup = Isaac.Spawn(5, 10, 0, ent.Position, Vector.Zero, nil):ToPickup()
		if game:IsGreedMode() then
			pickup.Timeout = 33
		else
			pickup.Timeout = 60
		end
	end
end
Grail:AddCallback(ModCallbacks.MC_POST_ENTITY_KILL, 'OnEntityKilled')


return Grail