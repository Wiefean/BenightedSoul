--炖蛇汤

local mod = Isaac_BenightedSoul

local game = Game()

local Ssstew = mod.IBS_Class.Item(mod.IBS_ItemID.Ssstew)


--临时数据
function Ssstew:GetData(player)
	local data = self._Ents:GetTempData(player)
	data.Ssstew = data.Ssstew or {TearFired = 0}
	return data.Ssstew
end

--获得
function Ssstew:OnGain(item, charge, first, slot, varData, player)
	--忽略表里店长游魂
	local playerType = player:GetPlayerType() if (playerType == 10) or (playerType == 31) or (playerType == 14) or (playerType == 33) then return end
	if first then
		if player:GetHealthType() == HealthType.RED then --红心角色
			--心容变骨心
			local h = player:GetHearts()
			local hc = player:GetMaxHearts()
			player:AddMaxHearts(-hc)
			player:AddBoneHearts(math.ceil(hc/2))
			player:AddHearts(h)
		end

		--魂心变黑心
		local soul = player:GetSoulHearts()
		player:AddSoulHearts(-soul)
		player:AddBlackHearts(soul)
	end
end
Ssstew:AddCallback(ModCallbacks.MC_POST_ADD_COLLECTIBLE, 'OnGain', Ssstew.ID)

--眼泪特效
function Ssstew:OnFireTear(tear)
	local player = self._Ents:IsSpawnerPlayer(tear, true)

    if player and player:HasCollectible(self.ID) then
		local data = self:GetData(player)
		data.TearFired = data.TearFired + 1
		
		local cost = 6 - (self._Players:GetBlackHearts(player) / 2)
		if data.TearFired >= cost then
			data.TearFired = 0
			local color = Color(1,1,1)
			color:SetColorize(0,0,0,1)
			tear:SetColor(color,-1,0, false, true)
			tear:AddTearFlags(TearFlags.TEAR_SLOW | TearFlags.TEAR_POISON | TearFlags.TEAR_PIERCING)
			tear.CollisionDamage = tear.CollisionDamage + 2
			tear.Scale = self._Maths:TearDamageToScale(tear.CollisionDamage)
			tear:Update()				
		end
    end
end
Ssstew:AddCallback(ModCallbacks.MC_POST_FIRE_TEAR, 'OnFireTear')


--魂心变黑心
function Ssstew:PreHeartCollision(pickup, other)
	if pickup.Wait > 0 then return end
	local player = other:ToPlayer()
	if player and player:HasCollectible(self.ID) then
		if pickup.SubType == HeartSubType.HEART_SOUL or pickup.SubType == HeartSubType.HEART_HALF_SOUL then 
			pickup:Morph(5,10, HeartSubType.HEART_BLACK)
			pickup.Wait = 15

			--烟雾特效
			Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, pickup.Position, Vector.Zero, nil)
			return false
		end
	end	
end
Ssstew:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, 'PreHeartCollision', PickupVariant.PICKUP_HEART)




return Ssstew