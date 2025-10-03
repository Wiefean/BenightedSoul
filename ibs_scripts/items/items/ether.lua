--以太

local mod = Isaac_BenightedSoul

local game = Game()

local Ether = mod.IBS_Class.Item(mod.IBS_ItemID.Ether)


--获取数据
function Ether:GetData(player)
	local data = self._Ents:GetTempData(player)
	data.Ether = data.Ether or {
		HurtTimes = 0,
		LightTimeout = 120,
		Flight = false
	}

	return data.Ether
end

--圣光
function Ether:OnPlayerUpdate(player)
	local data = self._Ents:GetTempData(player).Ether

	if data and (data.HurtTimes > 0) then
		if data.LightTimeout > 0 then
			data.LightTimeout = data.LightTimeout - 1
		else	
			data.LightTimeout = math.max(12, 240 - 30*(data.HurtTimes))
			for _,ent in pairs(Isaac.GetRoomEntities()) do
				if self._Ents:IsEnemy(ent) then
					local dmg = math.max(7, 2*(player.Damage))
					ent:TakeDamage(dmg ,DamageFlag.DAMAGE_IGNORE_ARMOR,EntityRef(player), 0)
					
					local light = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.CRACK_THE_SKY, 0, ent.Position, Vector.Zero, player)
					light:SetColor(Color(1, 1, 1, 1, 1, 0, 1),-1,0)				
				end
			end			
		end
	end	
end
Ether:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, 'OnPlayerUpdate')

--受伤
function Ether:OnTakeDMG(ent)
	local player = ent:ToPlayer()

	if player and player:HasCollectible(self.ID) then
		local data = self:GetData(player)
		data.HurtTimes = data.HurtTimes + 1
		data.Flight = true
	end
end
Ether:AddCallback(ModCallbacks.MC_POST_ENTITY_TAKE_DMG, 'OnTakeDMG')

--飞行
function Ether:OnEvaluateCache(player, flag)
	if flag == CacheFlag.CACHE_FLYING then
		local data = self._Ents:GetTempData(player).Ether
		if data and data.Flight then
			player.CanFly = true
		end
	end
end
Ether:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, 'OnEvaluateCache')

--翅膀装饰
function Ether:ApplyFlyCostume(player)
	local data = self._Ents:GetTempData(player).Ether
	
	if data and data.Flight then
		local effect = player:GetEffects()
		if not effect:HasCollectibleEffect(179) then
			effect:AddCollectibleEffect(179, true)
		end	
	end	
end
Ether:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, 'ApplyFlyCostume')

--重置数据
function Ether:Reset(player)
	if self._Ents:GetTempData(player).Ether then
		self._Ents:GetTempData(player).Ether = nil
		player:AddCacheFlags(CacheFlag.CACHE_FLYING, true)
	end	
end

--新房间重置数据
function Ether:OnNewRoom()
	for i = 0, game:GetNumPlayers() - 1 do
		self:Reset(Isaac.GetPlayer(i))
	end	
end
Ether:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, 'OnNewRoom')


return Ether