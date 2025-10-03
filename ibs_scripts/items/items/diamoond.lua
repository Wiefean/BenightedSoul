--钻石(dia-moon-d)

local mod = Isaac_BenightedSoul
local IBS_PlayerKey = mod.IBS_PlayerKey

local game = Game()

local Diamoond = mod.IBS_Class.Item(mod.IBS_ItemID.Diamoond)


--眼泪特效
function Diamoond:OnFireTear(tear)
	local player = self._Ents:IsSpawnerPlayer(tear, true)

    if player and player:HasCollectible(self.ID) then
		local rng = player:GetCollectibleRNG(self.ID)
		local chance = rng:RandomInt(100)
		local chance2 = rng:RandomInt(100)

		if chance < 33 then
			tear:ChangeVariant(18)
			tear:AddTearFlags(TearFlags.TEAR_BURN)
			tear:SetColor(Color(1,0.8,0,1,0.3,0,0),-1,0, false, true)
			tear.CollisionDamage = tear.CollisionDamage + 1
			tear:Update()
		end
		if chance2 < 33 then
			tear:ChangeVariant(18)
			local color = Color(1,1,1)
			color:SetColorize(1,1,1,1)
			tear:AddTearFlags(TearFlags.TEAR_SLOW | TearFlags.TEAR_ACID)
			tear:SetColor(color,-1,0, false, true)
			tear.CollisionDamage = tear.CollisionDamage + 1
			tear:Update()		
		end
    end
end
Diamoond:AddCallback(ModCallbacks.MC_POST_FIRE_TEAR, 'OnFireTear')

--冰冻判定
function Diamoond:OnNpcUpdate(npc)
	if self._Ents:IsEnemy(npc, true, false, true) and PlayerManager.AnyoneHasCollectible(self.ID) then
		if npc:HasEntityFlags(EntityFlag.FLAG_SLOW) and npc:HasEntityFlags(EntityFlag.FLAG_BURN) then 
			npc:AddEntityFlags(EntityFlag.FLAG_ICE)
			npc.HitPoints = 0
		end
	end
end
Diamoond:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, 'OnNpcUpdate')

--概率替换小石头或煤块
function Diamoond:OnPickupInit(pickup)
	if self:GetIBSData('persis')[IBS_PlayerKey.BMaggy].Beast then
		local data = self:GetIBSData('temp')
		if data.DiamoondReplac or PlayerManager.AnyoneHasCollectible(self.ID) then return end
		local id = pickup.SubType

		if (id == 90 or id == 132) and (pickup.SpawnerType ~= EntityType.ENTITY_PLAYER)  then
			local rng = RNG(pickup.InitSeed)
			if rng:RandomInt(100) < 7 then
				data.DiamoondReplac = true
				pickup:Morph(5,100, self.ID, true, true, true)
			end
		end
	end	
end
Diamoond:AddCallback(ModCallbacks.MC_POST_PICKUP_INIT, 'OnPickupInit', 100)

--爆炸免疫
function Diamoond:PrePlayerTakeDMG(player, dmg, flag, source)
	if player:HasCollectible(self.ID) and (flag & DamageFlag.DAMAGE_EXPLOSION > 0) then
		return false
	end
end
Diamoond:AddPriorityCallback(ModCallbacks.MC_PRE_PLAYER_TAKE_DMG, -800, 'PrePlayerTakeDMG')


return Diamoond