--解锁昧化伊甸

local mod = Isaac_BenightedSoul
local CharacterLock = mod.IBS_Class.CharacterLock

local game = Game()
local sfx = SFXManager()

local BEden = CharacterLock(mod.IBS_PlayerID.BEden, {'beden_unlock'} )


--一层初始房间等待2分钟8秒解锁
function BEden:OnUpdate()
	local data = self:GetIBSData('temp')
	
	--解锁时时间锁定
	if data.TimerForBEden and data.TimerForBEden >= 128*30 then
		game.TimeCounter = 128*30
	end		
	
	if self:IsUnlocked() then return end
	if game:AchievementUnlocksDisallowed() then return end
	
	--检测伊甸
	if not (PlayerManager.AnyoneIsPlayerType(9) or PlayerManager.AnyoneIsPlayerType(30)) then return end

	if game:GetLevel():GetStage() ~= 1 then return end
	local level = game:GetLevel()

	if (not data.CantUnlcokBEden) and level:GetStartingRoomIndex() == level:GetCurrentRoomDesc().SafeGridIndex then
		data.TimerForBEden = data.TimerForBEden or 0
		data.TimerForBEden = data.TimerForBEden + 1
		
		if data.TimerForBEden == 128*30 then
			sfx:Play(mod.IBS_Sound.SecretFound, 1.3)
			BEden:Unlock(true, true)

			--伊甸变化
			for i = 0, game:GetNumPlayers() - 1 do
				local player = Isaac.GetPlayer(i)
				local playerType = player:GetPlayerType()
				
				if playerType == 9 or playerType == 30 then
					--移除道具
					for id,num in pairs(self._Players:GetPlayerCollectibles(player)) do
						for i = 1,num do
							player:RemoveCollectible(id, true)
						end
					end
					
					--移除饰品
					for slot = 0,1 do
						local trinket = player:GetTrinket(slot)
						if trinket > 0 then
							player:TryRemoveTrinket(trinket)
						end
					end
					
					--移除口袋物品
					for slot = 0,3 do
						player:RemovePocketItem(slot)
					end

					--更改初始资源
					player:AddCoins(-player:GetNumCoins())
					player:AddBombs(-player:GetNumBombs())
					player:AddKeys(-player:GetNumKeys())
					
					--更改血量
					player:AddSoulHearts(-player:GetSoulHearts())
					player:AddMaxHearts(-player:GetMaxHearts())	
					player:AddMaxHearts(6)
					player:AddHearts(6)

					--更改属性
					player:SetEdenSpeed(0)
					player:SetEdenFireDelay(0)
					player:SetEdenDamage(0)
					player:SetEdenShotSpeed(0)
					player:SetEdenRange(0)
					player:SetEdenLuck(0)

					player:AddCollectible(mod.IBS_ItemID.Defined, 6)

					--里伊甸关怀
					if playerType == 30 then
						player:AddCollectible(619)
					end

					player:AddCacheFlags(CacheFlag.CACHE_ALL, true)
				end
			end

		end
	end
end
BEden:AddCallback(ModCallbacks.MC_POST_UPDATE, 'OnUpdate')

--切换房间后不能进入解锁流程
function BEden:OnNewRoom()
	if self:IsUnlocked() then return end
	if game:AchievementUnlocksDisallowed() then return end

	--检测伊甸
	if not (PlayerManager.AnyoneIsPlayerType(9) or PlayerManager.AnyoneIsPlayerType(30)) then return end


	local level = game:GetLevel()
	local data = self:GetIBSData('temp')
	
	if level:GetStartingRoomIndex() ~= level:GetCurrentRoomDesc().SafeGridIndex then
		data.CantUnlcokBEden = true
	end
end
BEden:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, 'OnNewRoom')



return BEden