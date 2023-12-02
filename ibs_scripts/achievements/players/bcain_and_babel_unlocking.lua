--解锁昧化该隐&亚伯

local mod = Isaac_BenightedSoul
local IBS_Callback = mod.IBS_Callback
local IBS_Item = mod.IBS_Item
local IBS_Player = mod.IBS_Player
local IBS_Sound = mod.IBS_Sound
local EggBlackList = mod.EggBlackList
local BigBooks = mod.IBS_Lib.BigBooks

local sfx = SFXManager()

local LANG = Options.Language


--播放成就纸张动画
local function ShowPaper()
	--for i = 1,2 do
		local paper = "bcain_and_babel_unlock"
		--if i == 2 then paper = "bc3" end

		--检测语言
		if LANG == "zh" then
			paper = paper.."_zh"
		end
		
		paper = paper..".png"	
		BigBooks:PlayPaper(paper)
	--end
end

--检测解锁条件
local function IsUnlockable()
	local notInChallenge = Isaac.GetChallenge() <= 0
	local notCustomSeed = Game():GetSeeds():IsCustomRun() == false
	local notInLap = Game():GetVictoryLap() <= 0
	local level = Game():GetLevel():GetStage()
	
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

--该隐踩献祭刺12次进入解锁流程
local function CainTakeDMG(_,ent, amount, flag, source)
	if not IBS_Data.Setting["bcain_and_babel"]["Unlocked"] then
		local player = ent:ToPlayer()
		
		if player and (Game():GetRoom():GetType() == RoomType.ROOM_SACRIFICE) and (flag & DamageFlag.DAMAGE_SPIKES) then
			local playerType = player:GetPlayerType()
			local data = mod:GetIBSData("Persis")
			
			if (playerType == 2) and IsUnlockable() then
				if data.cainTimes < 11 then
					data.cainTimes = data.cainTimes + 1
				elseif data.cainTimes == 11 then
					data.cainTimes = data.cainTimes + 1
					sfx:Play(IBS_Sound.secretfound)
				end
			end
		end
	end	
end
mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, CainTakeDMG)

--给予死亡回放
local function OnUpdate(_,player)
	if not IBS_Data.Setting["bcain_and_babel"]["Unlocked"] then
		local data = mod:GetIBSData("Persis")

		if (data.cainTimes >= 12) and (player:GetPlayerType() == 2) then
			if (player:GetActiveItem(ActiveSlot.SLOT_POCKET2) == 0) then
				player:SetPocketActiveItem(IBS_Item.redeath, ActiveSlot.SLOT_POCKET2, false)
			end	
		end
	end	
end	
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, OnUpdate)		

--死亡回放尝试解锁
local function OnUss(_,item, rng, player, flags, slot)
	if (Game():GetLevel():GetStage() == 11) and (#Isaac.FindByType(EntityType.ENTITY_EFFECT, EffectVariant.DIRT_PATCH) > 0) then
		local data = mod:GetIBSData("Persis")

		if IsUnlockable() and (data.cainTimes >= 12) and (player:GetPlayerType() == 2) and player:HasCollectible(CollectibleType.COLLECTIBLE_ABEL) then
			data.cainTimes = 0
			player:RemoveCollectible(CollectibleType.COLLECTIBLE_ABEL, true)
			player:ChangePlayerType(IBS_Player.babel)
		
			if not IBS_Data.Setting["bcain_and_babel"]["Unlocked"] then
				ShowPaper()
			end
			IBS_Data.Setting["bcain_and_babel"]["Unlocked"] = true
			mod:SaveIBSData()	
			
			return {ShowAnim = false, Discharge = true}
		end
	end	
end
mod:AddCallback(ModCallbacks.MC_USE_ITEM, OnUss, IBS_Item.redeath)
