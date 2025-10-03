--使者

local mod = Isaac_BenightedSoul
local IBS_SlotID = mod.IBS_SlotID

local game = Game()
local sfx = SFXManager()

local Envoy = mod.IBS_Class.Slot{
	Variant = IBS_SlotID.Envoy.Variant,
	SubType = IBS_SlotID.Envoy.SubType,
	Name = {zh = '使者', en = 'Envoy'},
}

--显形所需硬币
Envoy.Threshold = 30 

--是否显形
function Envoy:IsRevealed(slot)
	return (slot ~= nil and slot:GetPrizeType() == 114514)
end

--显形
function Envoy:Reveal(slot)
	slot:GetSprite():Play("Prize")
end

--移除被破坏时的默认掉落物
function Envoy:PreDrop()
	return false
end
Envoy:AddCallback(ModCallbacks.MC_PRE_SLOT_CREATE_EXPLOSION_DROPS, 'PreDrop', Envoy.Variant)

--获取上一个捐助的玩家
function Envoy:GetLastDonationPlayer(slot)
	return self._Ents:GetTempData(slot).ENVOY_DONATION_PLAYER
end

--概率替换普通乞丐
function Envoy:OnSlotInit2(slot)
	if not self:GetIBSData('persis')['slot_envoy'] then return end
	if not self:GetIBSData('temp').EnvoySpawned and RNG(slot.InitSeed):RandomInt(100) < 7 then		
		Isaac.Spawn(6, self.Variant, 0, slot.Position, Vector.Zero, nil)
		slot:Remove()
		self:GetIBSData('temp').EnvoySpawned = true
	end
end
Envoy:AddCallback(ModCallbacks.MC_POST_SLOT_INIT, 'OnSlotInit2', 4)

--初始化
function Envoy:OnSlotInit(slot)
	slot.SpriteOffset = Vector(0,5)
end
Envoy:AddCallback(ModCallbacks.MC_POST_SLOT_INIT, 'OnSlotInit', Envoy.Variant)

--更新
function Envoy:OnSlotUpdate(slot)
	local spr = slot:GetSprite()

	if spr:IsFinished('PayNothing') then	
		spr:Play('Idle')
	end

	--显形
	if not self:IsRevealed(slot) and slot:GetDonationValue() >= self.Threshold then				
		spr:Play("Prize")
	end

	--未显形时显形,否则生成奖励
	if spr:IsEventTriggered('Prize') then
		if self:IsRevealed(slot) then
			local player = self:GetLastDonationPlayer(slot) or Isaac.GetPlayer(0)
			player:UseActiveItem(585, false, false) --雪花盒
			
			--返还硬币
			for i = 1,self.Threshold do
				local pickup = Isaac.Spawn(5,20,1, slot.Position, 2 * RandomVector(), slot):ToPickup()
				pickup:Morph(5,20,1, false, true, true)
			end
			
			spr:Play("Teleport")
		else
			local spr = slot:GetSprite()
			spr:ReplaceSpritesheet(0, 'gfx/ibs/items/slots/envoy2.png')		
			spr:ReplaceSpritesheet(1, 'gfx/ibs/items/slots/envoy2.png')		
			spr:ReplaceSpritesheet(2, 'gfx/ibs/items/slots/envoy2.png', true)
			spr:Play("Idle", true)
			slot.SpriteOffset = Vector(0,4)	
			slot:SetPrizeType(114514)
			slot:SetTouch(0)
			Isaac.Spawn(1000,15,0, slot.Position, Vector.Zero, nil)
		end	
		sfx:Play(255)
	end
	
	--消失
	if spr:IsEventTriggered('Disappear') then
		slot:Remove()
	end

	--被破坏时
	if slot.GridCollisionClass == 5 then
		--生成会掉落钥匙碎片的天使
		self._Ents:SpawnKeyPieceAngel(slot.Position, slot.InitSeed)		
		slot:Remove()
	end	
end
Envoy:AddCallback(ModCallbacks.MC_POST_SLOT_UPDATE, 'OnSlotUpdate', Envoy.Variant)

--触碰
function Envoy:OnSlotCollision(slot, other)
	local player = other:ToPlayer()
	if not player then return end
	local spr = slot:GetSprite()

	if spr:IsPlaying('Idle') then

		--硬币数达标前计数
		if not self:IsRevealed(slot) then
			if player:GetNumCoins() > 0 then
				player:AddCoins(-1)
				spr:Play('PayNothing', true)
				sfx:Play(249)
				
				--没有犹大长子权时才计数
				if not player:HasCollectible(59) then		
					slot:SetDonationValue(slot:GetDonationValue()+1)
				end
			end
		elseif slot:GetTouch() > 15 and not player:HasCollectible(59) then
			self._Ents:GetTempData(slot).ENVOY_DONATION_PLAYER = player
			spr:Play("Prize", true)
		end

	end
end
Envoy:AddCallback(ModCallbacks.MC_POST_SLOT_COLLISION, 'OnSlotCollision', Envoy.Variant)



return Envoy