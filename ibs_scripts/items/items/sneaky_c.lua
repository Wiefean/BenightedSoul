--潜伏的G

local mod = Isaac_BenightedSoul

local game = Game()
local sfx = SFXManager()

local SneakyC = mod.IBS_Class.Item(mod.IBS_ItemID.SneakyC)

--生成战争蝗虫
function SneakyC:SpawnLocust(player, pos)
	local locust = Isaac.Spawn(3, 43, 1, pos + 30 * RandomVector(), Vector.Zero, player):ToFamiliar()
	locust:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
	locust:SetColor(Color(1,1,1,0), 45, 1, true, true)
	locust.Player = player
	return locust
end

--获得
function SneakyC:OnGain(item, charge, first, slot, varData, player)
	if first then
		local room = game:GetRoom()
		local pos = room:FindFreePickupSpawnPosition(player.Position, 0, true)
		Isaac.Spawn(5,350,113, pos, Vector.Zero, player)
	end
end
SneakyC:AddCallback(ModCallbacks.MC_POST_ADD_COLLECTIBLE, 'OnGain', SneakyC.ID)

--对应饰品自动生成战争蝗虫
function SneakyC:OnTrinketUpdate(pickup)
	if game:GetRoom():IsClear() then return end
	if pickup.SubType == 113 and pickup:IsFrame(120,0) then
		for i = 0, game:GetNumPlayers() - 1 do
			local player = Isaac.GetPlayer(i)
			if player:HasCollectible(self.ID) then
				self:SpawnLocust(player, pickup.Position)
			end
		end
	end
end
SneakyC:AddCallback(ModCallbacks.MC_POST_PICKUP_UPDATE, 'OnTrinketUpdate', 350)

--新生成敌人时生成战争蝗虫
function SneakyC:OnNpcInit(npc)
	if game:GetRoom():GetFrameCount() < 3 then return end
	if not self._Ents:IsEnemy(npc, true) then return end
	for i = 0, game:GetNumPlayers() - 1 do
		local player = Isaac.GetPlayer(i)
		if player:HasCollectible(self.ID) and RNG(npc.InitSeed):RandomInt(100) < 25 then
			self:SpawnLocust(player, player.Position)
		end
	end
end
SneakyC:AddPriorityCallback(ModCallbacks.MC_POST_NPC_INIT, CallbackPriority.LATE, 'OnNpcInit')

--自动吞下战争蝗虫饰品
function SneakyC:OnPlayerUpdate(player)
	if not player:HasCollectible(self.ID) then return end
	for slot = 0,1 do
		if player:GetTrinket(slot) == 113 then
			player:TryRemoveTrinket(113)
			player:AddSmeltedTrinket(113, false)
			sfx:Play(157)
		end

		--金饰品
		local golden = 113 + 32768
		if player:GetTrinket(slot) == golden then
			player:TryRemoveTrinket(golden)
			player:AddSmeltedTrinket(golden, false)
			sfx:Play(157)
		end		
	end	
end
SneakyC:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, 'OnPlayerUpdate', 0)

--双击扔下吞下的战争蝗虫饰品
function SneakyC:OnDoubleTap(player, type, action)
	if (type == 2) and (action == ButtonAction.ACTION_DROP) and player:HasCollectible(self.ID) then		
		local tbl = player:GetSmeltedTrinkets()[113]
		if tbl then
			for i = 1,tbl.trinketAmount do
				local room = game:GetRoom()
				local pos = room:FindFreePickupSpawnPosition(player.Position, 0, true)
				local pickup = Isaac.Spawn(5,350,113, pos, Vector.Zero, player):ToPickup()
				pickup.Wait = 60
				pickup.Touched = true
				player:TryRemoveSmeltedTrinket(113)
			end
			for i = 1,tbl.goldenTrinketAmount do
				local golden = 113 + 32768
				local room = game:GetRoom()
				local pos = room:FindFreePickupSpawnPosition(player.Position, 0, true)
				local pickup = Isaac.Spawn(5,350,golden, pos, Vector.Zero, player):ToPickup()
				pickup.Wait = 60
				pickup.Touched = true
				player:TryRemoveSmeltedTrinket(golden)
			end
		end		
	end
end
SneakyC:AddCallback(mod.IBS_CallbackID.DOUBLE_TAP, 'OnDoubleTap')

--快速拾取战争蝗虫饰品
function SneakyC:OnPickTrinket(player, trinket)
	if player:HasCollectible(self.ID) then
		player:AnimateTrinket(113, 'UseItem')
	end
end
SneakyC:AddCallback(mod.IBS_CallbackID.PICK_TRINKET, 'OnPickTrinket', 113)


return SneakyC