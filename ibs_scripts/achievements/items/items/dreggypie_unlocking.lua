--解锁掉渣饼

local mod = Isaac_BenightedSoul
local IBS_Callback = mod.IBS_Callback
local IBS_Item = mod.IBS_Item
local EggBlackList = mod.EggBlackList
local BigBooks = mod.IBS_Lib.BigBooks

local LANG = mod.Language


--播放成就纸张动画
local function ShowPaper()
	local paper = "dreggypie"

	--检测语言
	if LANG == "zh" then
		paper = paper.."_zh"
	end
	
	paper = paper..".png"	
	BigBooks:PlayPaper(paper)
end

--检测解锁条件
local function IsUnlockable()
	local notInChallenge = Isaac.GetChallenge() <= 0
	local notCustomSeed = Game():GetSeeds():IsCustomRun() == false
	local notInLap = Game():GetVictoryLap() <= 0
	
	--考虑不能达成成就的彩蛋种子
	for _,egg in ipairs(EggBlackList) do
		if (Game():GetSeeds():HasSeedEffect(egg)) then
			return false
		end
	end
	
	--非自定种子,非挑战,非跑圈
	if notCustomSeed and notInChallenge and notInLap then
		return true
	end

	return false
end

--拾取检测
--雅阁持有红豆汤,以扫持有长子权时触发
local function GainItem(_,player, item, num, touched)
	if (not touched and player.Variant == 0 and not player:IsCoopGhost()) then
		if not IBS_Data.Setting["dreggypieUnlocked"] and IsUnlockable() then
			local player2 = player:GetOtherTwin()
			local ready = false

			if player2 then
				local playerType = player:GetPlayerType()
				local player2Type = player2:GetPlayerType()
				
				if (playerType == PlayerType.PLAYER_JACOB) and player:HasCollectible(CollectibleType.COLLECTIBLE_RED_STEW, true) then					
					if (player2Type == PlayerType.PLAYER_ESAU) and player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT, true) then
						ready = true
						
						--红豆汤和饼换长子权
						player:QueueItem(Isaac.GetItemConfig():GetCollectible(IBS_Item.dreggypie))
						player:AnimateCollectible(IBS_Item.dreggypie)
						SFXManager():Play(SoundEffect.SOUND_POWERUP1)						
						
						player2:RemoveCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT, true)
						mod:DelayFunction(function() player2:AnimateSad() end, 60)
						if not player2:HasCollectible(CollectibleType.COLLECTIBLE_RED_STEW, true) then player2:AddCollectible(CollectibleType.COLLECTIBLE_RED_STEW) end
						if not player2:HasCollectible(IBS_Item.dreggypie, true) then player2:AddCollectible(IBS_Item.dreggypie) end
					end
				elseif (playerType == PlayerType.PLAYER_ESAU) and player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT, true) then					
					if (player2Type == PlayerType.PLAYER_JACOB) and player2:HasCollectible(CollectibleType.COLLECTIBLE_RED_STEW, true) then
						ready = true
						
						player2:QueueItem(Isaac.GetItemConfig():GetCollectible(IBS_Item.dreggypie))
						player2:AnimateCollectible(IBS_Item.dreggypie)
						SFXManager():Play(SoundEffect.SOUND_POWERUP1)						
						
						player:RemoveCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT, true)
						mod:DelayFunction(function() player:AnimateSad() end, 60)
						if not player:HasCollectible(CollectibleType.COLLECTIBLE_RED_STEW, true) then player:AddCollectible(CollectibleType.COLLECTIBLE_RED_STEW) end
						if not player:HasCollectible(IBS_Item.dreggypie, true) then player:AddCollectible(IBS_Item.dreggypie) end						
					end
				end
			end
			
			if ready then
				ShowPaper()
				IBS_Data.Setting["dreggypieUnlocked"] = true
				mod:SaveIBSData()
			end	
		end
	end
end
mod:AddCallback(IBS_Callback.GAIN_COLLECTIBLE, GainItem, CollectibleType.COLLECTIBLE_RED_STEW)
mod:AddCallback(IBS_Callback.GAIN_COLLECTIBLE, GainItem, CollectibleType.COLLECTIBLE_BIRTHRIGHT)
