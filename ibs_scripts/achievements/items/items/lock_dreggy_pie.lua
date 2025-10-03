--解锁掉渣饼

local mod = Isaac_BenightedSoul
local IBS_ItemID = mod.IBS_ItemID
local Achievement = mod.IBS_Class.Achievement

local game = Game()
local sfx = SFXManager()

local DreggyPie = Achievement('dreggyPieUnlocked', {
	PaperNames = {'dreggy_pie'},
	Items = {IBS_ItemID.DreggyPie}
})


--拾取检测
--(雅阁持有红豆汤,以扫持有长子权时触发)
function DreggyPie:OnGainItem(item, charge, first, slot, varData, player)
	if self:IsLocked() and not game:AchievementUnlocksDisallowed() then
		local player2 = player:GetOtherTwin()
		local ready = false

		if player2 then
			local playerType = player:GetPlayerType()
			local player2Type = player2:GetPlayerType()
			
			if (playerType == PlayerType.PLAYER_JACOB) and player:HasCollectible(CollectibleType.COLLECTIBLE_RED_STEW, true) then					
				if (player2Type == PlayerType.PLAYER_ESAU) and player2:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT, true) then
					ready = true
					
					--红豆汤和饼换长子权
					player:QueueItem(Isaac.GetItemConfig():GetCollectible(IBS_ItemID.DreggyPie))
					player:AnimateCollectible(IBS_ItemID.DreggyPie)
					sfx:Play(SoundEffect.SOUND_POWERUP1)						
					
					player2:RemoveCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT, true)
					mod:DelayFunction(function() player2:AnimateSad() end, 60)
					if not player2:HasCollectible(CollectibleType.COLLECTIBLE_RED_STEW, true) then player2:AddCollectible(CollectibleType.COLLECTIBLE_RED_STEW) end
					if not player2:HasCollectible(IBS_ItemID.DreggyPie, true) then player2:AddCollectible(IBS_ItemID.DreggyPie) end
				end
			elseif (playerType == PlayerType.PLAYER_ESAU) and player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT, true) then					
				if (player2Type == PlayerType.PLAYER_JACOB) and player2:HasCollectible(CollectibleType.COLLECTIBLE_RED_STEW, true) then
					ready = true
					
					player2:QueueItem(Isaac.GetItemConfig():GetCollectible(IBS_ItemID.DreggyPie))
					player2:AnimateCollectible(IBS_ItemID.DreggyPie)
					sfx:Play(SoundEffect.SOUND_POWERUP1)						

					player:RemoveCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT, true)
					mod:DelayFunction(function() player:AnimateSad() end, 60)
					if not player:HasCollectible(CollectibleType.COLLECTIBLE_RED_STEW, true) then player:AddCollectible(CollectibleType.COLLECTIBLE_RED_STEW) end
					if not player:HasCollectible(IBS_ItemID.DreggyPie, true) then player:AddCollectible(IBS_ItemID.DreggyPie) end						
				end
			end
		end

		if ready then
			self:Unlock(true, true)
		end	
	end
end
DreggyPie:AddCallback(ModCallbacks.MC_POST_ADD_COLLECTIBLE, 'OnGainItem', CollectibleType.COLLECTIBLE_RED_STEW)
DreggyPie:AddCallback(ModCallbacks.MC_POST_ADD_COLLECTIBLE, 'OnGainItem', CollectibleType.COLLECTIBLE_BIRTHRIGHT)


return DreggyPie