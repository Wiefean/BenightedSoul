--解锁昧化该隐&亚伯

local mod = Isaac_BenightedSoul
local CharacterLock = mod.IBS_Class.CharacterLock
local IBS_ItemID = mod.IBS_ItemID
local IBS_PlayerID = mod.IBS_PlayerID
local IBS_Sound = mod.IBS_Sound

local game = Game()
local sfx = SFXManager()

local BCBA = CharacterLock(IBS_PlayerID.BCain, {'bcain_babel_unlock'} )

--解锁后该隐自带亚伯
function BCBA:OnCainInit(player)
	if self:IsUnlocked() and player:GetPlayerType() == PlayerType.PLAYER_CAIN then
		self:DelayFunction2(function()
			if not self:IsGameContinued() and player:GetPlayerType() == PlayerType.PLAYER_CAIN then
				player:AddCollectible(CollectibleType.COLLECTIBLE_ABEL)
				game:GetItemPool():RemoveCollectible(CollectibleType.COLLECTIBLE_ABEL)
			end
		end,1)
	end
end
BCBA:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, 'OnCainInit')

--该隐一层内踩献祭12次后进入解锁流程
function BCBA:OnTakeDMG(ent, amount, flag)
	local player = ent:ToPlayer()

	if player and (game:GetRoom():GetType() == RoomType.ROOM_SACRIFICE) and (flag & DamageFlag.DAMAGE_SPIKES) then
		if self:IsUnlocked() then return end
		if game:AchievementUnlocksDisallowed() then return end
		local playerType = player:GetPlayerType()
		if (playerType == 2) or (playerType == 23) then
			local data = self:GetIBSData('level')
			data.cainSacrifice = data.cainSacrifice or 0
			data.cainSacrifice = data.cainSacrifice + 1

			if data.cainSacrifice >= 12 then 
				self:GetIBSData('temp').cainSacrificeDone = true
			end
			if data.cainSacrifice == 12 then
				player:AddCollectible(CollectibleType.COLLECTIBLE_ABEL)
				sfx:Play(IBS_Sound.SecretFound)
			end
		end
	end
end
BCBA:AddCallback(ModCallbacks.MC_POST_ENTITY_TAKE_DMG, 'OnTakeDMG')

--给予死亡回放
function BCBA:OnPlayerUpdate(player)
	if self:IsUnlocked() then return end
	if not self:GetIBSData('temp').cainSacrificeDone then return end
	local playerType = player:GetPlayerType()
	if (playerType == 2 or playerType == 23) and player:HasCollectible(CollectibleType.COLLECTIBLE_ABEL, true) and (player:GetActiveItem(ActiveSlot.SLOT_POCKET2) == 0) then
		player:SetPocketActiveItem(IBS_ItemID.Redeath, ActiveSlot.SLOT_POCKET2, false)
	end
end	
BCBA:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, 'OnPlayerUpdate')		

--死亡回放尝试解锁
function BCBA:OnUseItem(item, rng, player, flags, slot)
	if self:IsUnlocked() then return end
	if game:AchievementUnlocksDisallowed() then return end
	if (game:GetLevel():GetStage() == 11) and (#Isaac.FindByType(EntityType.ENTITY_EFFECT, EffectVariant.DIRT_PATCH) > 0) then
		if self:GetIBSData('temp').cainSacrificeDone and (player:GetPlayerType() == 2) and player:HasCollectible(CollectibleType.COLLECTIBLE_ABEL, true) then
			player:RemoveCollectible(CollectibleType.COLLECTIBLE_ABEL, true)
			player:ChangePlayerType(IBS_PlayerID.BAbel)
			self:Unlock(true, true)
		end
	end	
end
BCBA:AddCallback(ModCallbacks.MC_USE_ITEM, 'OnUseItem', IBS_ItemID.Redeath)


return BCBA