--真理小子

local mod = Isaac_BenightedSoul
local IBS_ItemID = mod.IBS_ItemID
local IBS_SlotID = mod.IBS_SlotID

local game = Game()
local sfx = SFXManager()

local Albern = mod.IBS_Class.Slot{
	Variant = IBS_SlotID.Albern.Variant,
	SubType = IBS_SlotID.Albern.SubType,
	Name = {zh = '真理小子', en = 'Brother Albern'},
}

--箱子池(没错写这么长就是故意的)
Albern.ChestList = {
	PickupVariant.PICKUP_ETERNALCHEST,
	PickupVariant.PICKUP_ETERNALCHEST,
	PickupVariant.PICKUP_ETERNALCHEST,
	PickupVariant.PICKUP_ETERNALCHEST,
	PickupVariant.PICKUP_ETERNALCHEST,
	PickupVariant.PICKUP_ETERNALCHEST,
	PickupVariant.PICKUP_ETERNALCHEST,
	PickupVariant.PICKUP_ETERNALCHEST,
	PickupVariant.PICKUP_ETERNALCHEST,
	PickupVariant.PICKUP_ETERNALCHEST,
	PickupVariant.PICKUP_ETERNALCHEST,
	PickupVariant.PICKUP_ETERNALCHEST,
	PickupVariant.PICKUP_ETERNALCHEST,
	PickupVariant.PICKUP_ETERNALCHEST,	
	PickupVariant.PICKUP_ETERNALCHEST,
	PickupVariant.PICKUP_ETERNALCHEST,
	PickupVariant.PICKUP_ETERNALCHEST,
	PickupVariant.PICKUP_ETERNALCHEST,
	PickupVariant.PICKUP_ETERNALCHEST,
	PickupVariant.PICKUP_ETERNALCHEST,
	PickupVariant.PICKUP_ETERNALCHEST,
	PickupVariant.PICKUP_ETERNALCHEST,
	PickupVariant.PICKUP_ETERNALCHEST,
	PickupVariant.PICKUP_ETERNALCHEST,
	PickupVariant.PICKUP_ETERNALCHEST,
	PickupVariant.PICKUP_ETERNALCHEST,
	PickupVariant.PICKUP_ETERNALCHEST,
	PickupVariant.PICKUP_ETERNALCHEST,		
	PickupVariant.PICKUP_OLDCHEST,
	PickupVariant.PICKUP_OLDCHEST,
	PickupVariant.PICKUP_OLDCHEST,
	PickupVariant.PICKUP_OLDCHEST,
	PickupVariant.PICKUP_OLDCHEST,
	PickupVariant.PICKUP_OLDCHEST,
	PickupVariant.PICKUP_OLDCHEST,
	PickupVariant.PICKUP_OLDCHEST,
	PickupVariant.PICKUP_OLDCHEST,
	PickupVariant.PICKUP_OLDCHEST,
	PickupVariant.PICKUP_OLDCHEST,
	PickupVariant.PICKUP_OLDCHEST,
	PickupVariant.PICKUP_OLDCHEST,
	PickupVariant.PICKUP_OLDCHEST,
	PickupVariant.PICKUP_OLDCHEST,
	PickupVariant.PICKUP_OLDCHEST,
	PickupVariant.PICKUP_OLDCHEST,
	PickupVariant.PICKUP_OLDCHEST,
	PickupVariant.PICKUP_OLDCHEST,
	PickupVariant.PICKUP_OLDCHEST,	
	PickupVariant.PICKUP_WOODENCHEST,
	PickupVariant.PICKUP_WOODENCHEST,
	PickupVariant.PICKUP_WOODENCHEST,
	PickupVariant.PICKUP_WOODENCHEST,
	PickupVariant.PICKUP_WOODENCHEST,
	PickupVariant.PICKUP_WOODENCHEST,
	PickupVariant.PICKUP_WOODENCHEST,
	PickupVariant.PICKUP_WOODENCHEST,
	PickupVariant.PICKUP_WOODENCHEST,
	PickupVariant.PICKUP_WOODENCHEST,
	PickupVariant.PICKUP_WOODENCHEST,
	PickupVariant.PICKUP_WOODENCHEST,
	PickupVariant.PICKUP_WOODENCHEST,
	PickupVariant.PICKUP_WOODENCHEST,
	PickupVariant.PICKUP_WOODENCHEST,
	PickupVariant.PICKUP_WOODENCHEST,
	PickupVariant.PICKUP_WOODENCHEST,
	PickupVariant.PICKUP_WOODENCHEST,
	PickupVariant.PICKUP_WOODENCHEST,
	PickupVariant.PICKUP_WOODENCHEST,
	PickupVariant.PICKUP_WOODENCHEST,
	PickupVariant.PICKUP_WOODENCHEST,
	PickupVariant.PICKUP_WOODENCHEST,
	PickupVariant.PICKUP_WOODENCHEST,
	PickupVariant.PICKUP_WOODENCHEST,
	PickupVariant.PICKUP_WOODENCHEST,
	PickupVariant.PICKUP_WOODENCHEST,
	PickupVariant.PICKUP_WOODENCHEST,	
	PickupVariant.PICKUP_MEGACHEST,
}

--移除被破坏时的默认掉落物
function Albern:PreDrop()
	return false
end
Albern:AddCallback(ModCallbacks.MC_PRE_SLOT_CREATE_EXPLOSION_DROPS, 'PreDrop', Albern.Variant)


--更新
function Albern:OnSlotUpdate(slot)
	local spr = slot:GetSprite()

	--触碰音效
	if spr:IsEventTriggered('Sound') then
		sfx:Play(268)
	end
	
	--触碰后生成奖励并消失
	if spr:IsEventTriggered('Disappear') then
		local seed = slot.InitSeed
		local rng = RNG(seed)
		
		--生成钥匙乞丐池道具,否则生成箱子
		if rng:RandomInt(100) < 30 then
			local itemPool = game:GetItemPool()
			local id = itemPool:GetCollectible(ItemPoolType.POOL_KEY_MASTER, true, seed)
			local pickup = Isaac.Spawn(5, 100, id, slot.Position, Vector.Zero, nil):ToPickup()
			pickup.Wait = 45			
		else		
			local pool = self.ChestList
			local variant = pool[rng:RandomInt(1,#pool)] or PickupVariant.PICKUP_ETERNALCHEST
			local pickup = Isaac.Spawn(5,variant,0, slot.Position, RandomVector(), nil):ToPickup()
			pickup.Wait = 45
		end
		
		slot:Remove()
	end

	--被破坏时
	if slot.GridCollisionClass == 5 then
		--生成触碰过的棕色粪块
		local pickup = Isaac.Spawn(5,100,504, slot.Position, Vector.Zero, slot):ToPickup()
		pickup.Touched = true
		
		slot:BloodExplode()
		slot:Remove()
	end	
end
Albern:AddCallback(ModCallbacks.MC_POST_SLOT_UPDATE, 'OnSlotUpdate', Albern.Variant)

--触碰
function Albern:OnSlotCollision(slot, other)
	local player = other:ToPlayer()
	if not player then return end
	local spr = slot:GetSprite()
	
	--概率唤醒(有真理箱则必定唤醒)
	if slot:IsFrame(3,0) then
		if PlayerManager.AnyoneHasCollectible(IBS_ItemID.TruthChest) 
			or slot:GetDropRNG():RandomInt(200) < 1 + player.Velocity:Length()
		then	
			if not spr:IsPlaying('Touch') then
				spr:Play('Touch', true)
			end
		end
	end
end
Albern:AddCallback(ModCallbacks.MC_PRE_SLOT_COLLISION, 'OnSlotCollision', Albern.Variant)


--新房间
function Albern:OnNewRoom()
	local room = game:GetRoom()
	local level= game:GetLevel()

	--在超隐尝试生成
	if self:GetIBSData('persis')['slot_albern'] then	
		if self:GetIBSData('persis')["BLost"].MegaSatan and (room:GetType() == RoomType.ROOM_SUPERSECRET) and room:IsFirstVisit() and level:GetCurrentRoomIndex() > 0 then
			local chance = 12
			
			--有真理箱则必定生成
			if PlayerManager.AnyoneHasCollectible(IBS_ItemID.TruthChest) then
				chance = chance + 100
			end
			
			if RNG(self._Levels:GetRoomUniqueSeed()):RandomInt(100) < chance then
				Isaac.Spawn(6, self.Variant, 0, room:FindFreePickupSpawnPosition(room:GetGridPosition(117), 0, true), Vector.Zero, nil)
			end
		end
	end

end
Albern:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, 'OnNewRoom')

return Albern