--备用钉子

local mod = Isaac_BenightedSoul

local game = Game()
local sfx = SFXManager()

local ReservedNail = mod.IBS_Class.Item(mod.IBS_ItemID.ReservedNail)


--效果
function ReservedNail:OnUse(item, rng, player, flag, slot)
	local velocity = 20*(self._Maths:DirectionToVector(player:GetFireDirection()))
	local tear = player:FireTear(player.Position, velocity, false, true, false, player)
	local dmg = math.max(9, 2.5*(player.Damage))
	
	self._Ents:GetTempData(tear).ReservedNail = true
	
	--彼列书
	if player:HasCollectible(59) then
		tear:AddTearFlags(TearFlags.TEAR_BURN)
	end

	tear.CollisionDamage = dmg
    tear.Scale = self._Maths:TearDamageToScale(dmg)
	tear:ChangeVariant(13)
	tear:Update()
end
ReservedNail:AddCallback(ModCallbacks.MC_USE_ITEM, 'OnUse', ReservedNail.ID)

--命中判定
function ReservedNail:OnEntityTakeDMG(target, dmg, flag, source)
	if dmg <= 0 then return end

	if self._Ents:IsEnemy(target) then
		--额外充能
		for i = 0, game:GetNumPlayers() -1 do
			local player = Isaac.GetPlayer(i)			
			for slot = 0,2 do
				if player:GetActiveItem(slot) == (self.ID) then
					self._Players:ChargeTimedSlot(player, slot, math.ceil(dmg))
				end	
			end
		end	
	
		--控制
		if source.Entity and source.Entity:ToTear() then
			local tear = source.Entity 
			if self._Ents:GetTempData(tear).ReservedNail then
				target:AddFreeze(EntityRef(tear), 90)
				target:AddWeakness(EntityRef(tear), 90)
			end
		end
	end
end
ReservedNail:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, 'OnEntityTakeDMG')

--魂火熄灭
function ReservedNail:OnWispKilled(familiar)
    if (familiar.Variant == FamiliarVariant.WISP and familiar.SubType == (self.ID)) then
		for _,ent in pairs(Isaac.FindInRadius(familiar.Position, 40, EntityPartition.ENEMY)) do
			ent:AddFreeze(EntityRef(familiar), 45)
			ent:AddWeakness(EntityRef(familiar), 45)
		end
    end
end
ReservedNail:AddCallback(ModCallbacks.MC_POST_ENTITY_KILL, 'OnWispKilled', EntityType.ENTITY_FAMILIAR)

--清理魂火
function ReservedNail:CleanWisps()
	for _,wisp in pairs(Isaac.FindByType(3,206, self.ID)) do
		wisp:Remove()	
	end
end
ReservedNail:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, 'CleanWisps')


return ReservedNail