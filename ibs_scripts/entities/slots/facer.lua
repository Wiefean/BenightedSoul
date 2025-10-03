--换脸商

local mod = Isaac_BenightedSoul
local IBS_PlayerKey = mod.IBS_PlayerKey
local IBS_TrinketID = mod.IBS_TrinketID
local IBS_SlotID = mod.IBS_SlotID

local game = Game()
local sfx = SFXManager()

local Facer = mod.IBS_Class.Slot{
	Variant = IBS_SlotID.Facer.Variant,
	SubType = IBS_SlotID.Facer.SubType,
	Name = {zh = '换脸商', en = 'Facer'},
}

--装扮
local Costume = Isaac.GetCostumeIdByPath('gfx/ibs/characters/no_face.anm2')

--饰品池
Facer.TrinketList = {
	IBS_TrinketID.CultistMask,
	IBS_TrinketID.SsserpentHead,
	IBS_TrinketID.ClericFace,
	IBS_TrinketID.NlothsMask,
	IBS_TrinketID.GremlinMask,
}

--概率替换隐藏或超隐中的卖血机
function Facer:OnSlotInit2(slot)
	if not self:GetIBSData('persis')['slot_facer'] then return end
	if not self:GetIBSData('persis')[IBS_PlayerKey.BKeeper].BossRush then return end
	local roomType = game:GetRoom():GetType()
	if roomType == RoomType.ROOM_SECRET or roomType == RoomType.ROOM_SUPERSECRET then
		if RNG(slot.InitSeed):RandomInt(100) < 24 then		
			Isaac.Spawn(6, self.Variant, 0, slot.Position, Vector.Zero, nil)
			slot:Remove()
		end
	end
end
Facer:AddCallback(ModCallbacks.MC_POST_SLOT_INIT, 'OnSlotInit2', 2)

--初始化
function Facer:OnSlotInit(slot)
	slot.SpriteOffset = Vector(0,5)
end
Facer:AddCallback(ModCallbacks.MC_POST_SLOT_INIT, 'OnSlotInit', Facer.Variant)

--更新
function Facer:OnSlotUpdate(slot)
	local spr = slot:GetSprite()

	if spr:IsFinished('Pay') then	
		spr:Play('Prize')
	end
	
	if spr:IsFinished('Prize') then	
		spr:Play('Idle')
	end

	--生成奖励
	if spr:IsEventTriggered('Prize') then
		local rng = slot:GetDropRNG()
		if rng:RandomInt(100) < 36 or slot:GetPrizeType() >= 4 then
			--生成脸饰品,然后跑路
			local rng2 = RNG(slot.InitSeed)
			local id = self.TrinketList[rng2:RandomInt(1,#self.TrinketList)] or IBS_TrinketID.CultistMask
			
			--5%概率金饰品
			if rng2:RandomInt(100) < 5 then			
				id = id + 32768
			end

			Isaac.Spawn(5,350,id, slot.Position, 2*RandomVector(), slot)
			spr:Play('Teleport', true)
		end
		for i = 1,5 do			
			Isaac.Spawn(5,20,0, slot.Position, 2*RandomVector(), slot)
		end
		sfx:Play(255)
	end
	
	--消失
	if spr:IsEventTriggered('Disappear') then
		slot:Remove()
	end

	--被破坏时
	if slot.GridCollisionClass == 5 then
		slot:BloodExplode()
		slot:Remove()
	end	
	
	slot.SizeMulti = Vector(1, 0.5) --椭圆型碰撞体积
end
Facer:AddCallback(ModCallbacks.MC_POST_SLOT_UPDATE, 'OnSlotUpdate', Facer.Variant)

--触碰
function Facer:OnSlotCollision(slot, other)
	local player = other:ToPlayer()
	if not player then return end
	local spr = slot:GetSprite()
	
	--扣血交易
	if spr:IsPlaying('Idle') and slot:GetTouch() > 20 and player:GetDamageCooldown() <= 0 then
		player:TakeDamage(2, DamageFlag.DAMAGE_RED_HEARTS | DamageFlag.DAMAGE_NO_PENALTIES, EntityRef(player), 0)
		player:AddNullCostume(Costume)
		
		--计数
		slot:SetPrizeType(slot:GetPrizeType()+1)
		
		spr:Play('Pay', true)
	end
end
Facer:AddCallback(ModCallbacks.MC_POST_SLOT_COLLISION, 'OnSlotCollision', Facer.Variant)

--新层移除装扮
function Facer:OnNewLevel()
	for i = 0, game:GetNumPlayers() - 1 do
		local player = Isaac.GetPlayer(i)
		player:TryRemoveNullCostume(Costume)
	end
end
Facer:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, 'OnNewLevel')


return Facer