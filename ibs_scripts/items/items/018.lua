--018

local mod = Isaac_BenightedSoul

local game = Game()
local sfx = SFXManager()

local SCP018 = mod.IBS_Class.Item(mod.IBS_ItemID.SCP018)

SCP018Familiar = mod.IBS_Familiar.SCP018

--拾取对应道具生成跟班
function SCP018:OnEvaluateCache(player, flag)
    if flag == CacheFlag.CACHE_FAMILIARS then
		local num = 0
		
		if player:HasCollectible(self.ID, true) or player:VoidHasCollectible(self.ID) then
			num = 1
		end

		player:CheckFamiliar(SCP018Familiar.Variant, num, player:GetCollectibleRNG(self.ID), Isaac.GetItemConfig():GetCollectible(self.ID))
	end
end
SCP018:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, 'OnEvaluateCache')

--使用
function SCP018:OnUse(item, rng, player, flags)
	--增加体型
	for _,ent in ipairs(Isaac.FindByType(3, SCP018Familiar.Variant)) do
		SCP018Familiar:AddScale(ent, 1)
		
		--加速
		ent.Velocity = ent.Velocity * 2
		
		--大宝
		if player:HasCollectible(247) then
			SCP018Familiar:AddScale(ent, 1)
		end			
	end
	
	return {ShowAnim = false, Discharge = true}
end
SCP018:AddCallback(ModCallbacks.MC_USE_ITEM, 'OnUse', SCP018.ID)

--充能
function SCP018:Charge()
	for i = 0, game:GetNumPlayers() -1 do
		local player = Isaac.GetPlayer(i)	
		for slot = 0,2 do
			if player:GetActiveItem(slot) == (self.ID) then
				local charges = self._Players:GetSlotCharges(player, slot, true, true)
				local maxCharges = 540
			
				if charges < maxCharges then
					self._Players:ChargeSlot(player, slot, 1, true)
					
					if charges + 1 == maxCharges then
						sfx:Play(SoundEffect.SOUND_BEEP)
						game:GetHUD():FlashChargeBar(player, slot)
					end
				end
			end
		end
	end	
end
SCP018:AddCallback(ModCallbacks.MC_POST_UPDATE, 'Charge')

--魂火最多存在2秒
function SCP018:OnWispUpdate(wisp)
	if wisp.SubType == self.ID and wisp.FrameCount > 120 then
		wisp:Kill()
	end
end
SCP018:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, 'OnWispUpdate', 206)

--清理魂火
function SCP018:CleanWisps()
	for _,wisp in pairs(Isaac.FindByType(3,206, self.ID)) do
		wisp:Remove()	
	end
end
SCP018:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, 'CleanWisps')

return SCP018