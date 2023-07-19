--发光的心

local mod = Isaac_BenightedSoul
local IBS_Callback = mod.IBS_Callback
local IBS_Item = mod.IBS_Item
local IBS_Player = mod.IBS_Player
local Players = mod.IBS_Lib.Players

local sfx = SFXManager()

--清理房间充能
local function Charge()
	for i = 0, Game():GetNumPlayers() -1 do
		local player = Isaac.GetPlayer(i)
		for slot = 0,2 do
			if player:GetActiveItem(slot) == (IBS_Item.gheart) then
				local charges = Players:GetSlotCharges(player, slot, true, true)
				if charges < 7 then
					Players:ChargeSlot(player, slot, 1, true)
					charges = charges + 1
					Game():GetHUD():FlashChargeBar(player, slot)
					
					if charges < 7 then
						sfx:Play(SoundEffect.SOUND_BEEP)
					elseif charges == 7 then
						sfx:Play(SoundEffect.SOUND_BATTERYCHARGE)
					end
				end					
			end
		end
	end	
end
mod:AddCallback(ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD, Charge)

--贪婪模式波次充能
mod:AddCallback(IBS_Callback.GREED_NEW_WAVE, Charge)

--使用效果
local function OnUse(_,col, rng, player, flags)

	--昧化抹大拉
	if player:GetPlayerType() == (IBS_Player.bmaggy) then
		local data = Players:GetData(player)
		if data.IronHeart then 
			data.IronHeart.Extra = data.IronHeart.Extra + 25
		end	
	end

	if player:GetBrokenHearts() > 0 then
		player:AddBrokenHearts(-1)
		sfx:Play(SoundEffect.SOUND_SUPERHOLY)
	elseif player:HasCollectible(59) then --彼列书
		player:AddBlackHearts(2)
		sfx:Play(SoundEffect.SOUND_UNHOLY)
	else
		player:AddSoulHearts(2)
		sfx:Play(SoundEffect.SOUND_HOLY)		
	end

	return true
end
mod:AddCallback(ModCallbacks.MC_USE_ITEM, OnUse, IBS_Item.gheart)

