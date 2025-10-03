--解锁昧化犹大

local mod = Isaac_BenightedSoul
local IBS_ItemID = mod.IBS_ItemID
local CharacterLock = mod.IBS_Class.CharacterLock

local game = Game()
local sfx = SFXManager()
local music = MusicManager()

local BJudas = CharacterLock(mod.IBS_PlayerID.BJudas, {'bjudas_unlock', 'bc4'} )

--一层隐藏房3块钱圣经
function BJudas:OnNewRoom()
	if self:IsUnlocked() then return end
	if game:AchievementUnlocksDisallowed() then return end
	if game:GetLevel():GetStage() ~= 1 then return end
	if not PlayerManager.AnyoneIsPlayerType(3) then return end --检测犹大
	local room = game:GetRoom()
	local data = self:GetIBSData('temp')
	
	if room:GetType() == RoomType.ROOM_SECRET and not data.BibleForBJudas then
		local pos = room:FindFreePickupSpawnPosition(room:GetCenterPos(), 0, true)
		local item = Isaac.Spawn(5, 100, 33, pos, Vector(0,0), nil):ToPickup()
		item.ShopItemId = -1
		item.AutoUpdatePrice = false
		item.Price = 3
		
		sfx:Play(mod.IBS_Sound.SecretFound, 1.3)
		data.BibleForBJudas = true
	end
end
BJudas:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, 'OnNewRoom')


--撒旦房间用圣经检测
function BJudas:OnUseBible(item, rng, player, flag, slot)
	if self:IsUnlocked() then return end
	local room = game:GetRoom()
	if game:AchievementUnlocksDisallowed() then return end
	if slot ~= 0 or room:GetBossID() ~= BossType.SATAN or room:IsClear() then return end
	local data = self:GetIBSData('temp')
	if (not data.BibleForBJudas) or data.ReviveForBjudas then return end

	player:GetEffects():AddNullEffect(NullItemID.ID_LAZARUS_SOUL_REVIVE) --用于复活
	self:DelayFunction(function()
		player:RemoveCollectible(33, true, slot, false)
		player:AddCollectible(IBS_ItemID.TGOJ, 135, true, slot)
		player:AnimateCollectible(IBS_ItemID.TGOJ)
		player:AddCollectible(20) --超凡升天
		player:AddCollectible(641) --血田
		sfx:Play(266)
		data.ReviveForBjudas = true
	end, 60)
	self:DelayFunction(function() player:AddSoulHearts(1300) end, 61)
	
	self:Unlock(true, true)
end
BJudas:AddCallback(ModCallbacks.MC_USE_ITEM, 'OnUseBible', 33)


return BJudas