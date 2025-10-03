--蝗虫领主

local mod = Isaac_BenightedSoul

local game = Game()

local LOL = mod.IBS_Class.Item(mod.IBS_ItemID.LOL)

--临时数据
function LOL:GetData(player)
	local data = self._Ents:GetTempData(player)
	data.LOL = data.LOL or {Damage = 0}
	
	return data.LOL
end

--生成蝗虫
function LOL:SpawnLocust(player)
	local rng = player:GetCollectibleRNG(self.ID)
	local locust = Isaac.Spawn(3, 43, (rng:RandomInt(5) + 1), player.Position + 30 * RandomVector(), Vector.Zero, player):ToFamiliar()
	locust:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
	locust:SetColor(Color(1,1,1,0), 45, 1, true, true)
	locust.Player = player
	return locust
end

--记录伤害
function LOL:OnTakeDamage(ent, dmg)
	if not self._Ents:IsEnemy(ent) then return end
	
	for i = 0, game:GetNumPlayers() -1 do
		local player = Isaac.GetPlayer(i)
		if player:HasCollectible(self.ID) then
			local data = self:GetData(player)
			local rng = player:GetCollectibleRNG(self.ID)
			
			if data.Damage > 50 then
				self:SpawnLocust(player)
				data.Damage = data.Damage - 50
			else
				data.Damage = data.Damage + dmg
			end
		end	
	end
end
LOL:AddPriorityCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, CallbackPriority.LATE, 'OnTakeDamage')

--清理新房间时生成蝗虫
function LOL:OnRoomCleaned()
	for i = 0, game:GetNumPlayers() -1 do
		local player = Isaac.GetPlayer(i)
		if player:HasCollectible(self.ID) then
			self:SpawnLocust(player)
		end
	end
end
LOL:AddCallback(ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD, 'OnRoomCleaned')
LOL:AddCallback(mod.IBS_CallbackID.GREED_NEW_WAVE, 'OnRoomCleaned')

--免疫蝗虫伤害(主要是爆炸)
function LOL:PrePlayerTakeDMG(player, dmg, flag, source)
	if player:HasCollectible(self.ID) and (source.Type == 3) and (source.Variant == 43) then
		return false
	end
end
LOL:AddPriorityCallback(ModCallbacks.MC_PRE_PLAYER_TAKE_DMG, -2333, 'PrePlayerTakeDMG')


return LOL