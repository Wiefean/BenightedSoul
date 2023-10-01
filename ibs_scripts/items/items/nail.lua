--备用钉子

local mod = Isaac_BenightedSoul
local IBS_Item = mod.IBS_Item
local IBS_Sound = mod.IBS_Sound
local Ents = mod.IBS_Lib.Ents
local Players = mod.IBS_Lib.Players
local Maths = mod.IBS_Lib.Maths

local sfx = SFXManager()

--方向转向量
local DirectionToVector = {
	[Direction.LEFT] = Vector(-1, 0),
	[Direction.UP] = Vector(0, -1),
	[Direction.RIGHT] = Vector(1, 0),
	[Direction.DOWN] = Vector(0, 1)
}

--效果
local function OnUse(_,item, rng, player, flag, slot)
    local dir = player:GetFireDirection()
	if dir == Direction.NO_DIRECTION then
		dir = Direction.DOWN
	end
	
	local velocity = 20*(DirectionToVector[dir])
	local tear = player:FireTear(player.Position, velocity, false, true, false, player)
	local dmg = math.max(9, 2.5*(player.Damage))
	
	Ents:GetTempData(tear).ReservedNail = true
	
	-- 彼列书
	if player:HasCollectible(59) then
		tear:AddTearFlags(TearFlags.TEAR_BURN)
	end

	-- tear.FallingAcceleration = - 0.1
    -- tear.FallingSpeed = 0
	tear.CollisionDamage = dmg
    tear.Scale = Maths:TearDamageToScale(dmg)
	tear:ChangeVariant(13)
	tear:Update()
end
mod:AddCallback(ModCallbacks.MC_USE_ITEM, OnUse, IBS_Item.nail)

--控制
mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, function(_,target, dmg, flags, source)
	if Ents:IsEnemy(target) then
		if source.Entity then
			if source.Entity:ToTear() then
				local tear = source.Entity 
				if Ents:GetTempData(tear).ReservedNail then
					target:AddFreeze(EntityRef(player), 90)
					Ents:AddWeakness(target, 90)
				end
			end
		end
	end
end)

--额外充能
local function ExtraCharge(_,ent, dmg)
	dmg = math.max(1, math.floor(dmg))
	if Ents:IsEnemy(ent) then
		local game = Game()
		for i = 0, game:GetNumPlayers() -1 do
			local player = Isaac.GetPlayer(i)
			for slot = 0,2 do
				if player:GetActiveItem(slot) == (IBS_Item.nail) then
					Players:ChargeTimedSlot(player, slot, dmg)
				end	
			end
		end
	end	
end
mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, ExtraCharge)

--魂火熄灭
local function WispKilled(_,familiar)
    if (familiar.Variant == FamiliarVariant.WISP and familiar.SubType == (IBS_Item.nail)) then
		for _,ent in pairs(Isaac.FindInRadius(familiar.Position, 70, EntityPartition.ENEMY)) do
			target:AddFreeze(EntityRef(familiar), 45)
			Ents:AddWeakness(ent, 45)
		end
    end
end
mod:AddCallback(ModCallbacks.MC_POST_ENTITY_KILL, WispKilled, EntityType.ENTITY_FAMILIAR)

--清理魂火
local function CleanWisps()
	for _,wisp in pairs(Isaac.FindByType(3,206, IBS_Item.nail)) do
		wisp:Remove()	
	end
end
mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, CleanWisps)

