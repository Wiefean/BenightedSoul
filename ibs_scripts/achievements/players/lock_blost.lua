--解锁昧化游魂

local mod = Isaac_BenightedSoul
local CharacterLock = mod.IBS_Class.CharacterLock

local game = Game()
local sfx = SFXManager()

local BLost = CharacterLock(mod.IBS_PlayerID.BLost, {'blost_unlock'} )

--检测下一局玩家一是否为表里游魂
function BLost:SeeLost(isContinue)
	if (not isContinue) and self:IsLocked() and not game:AchievementUnlocksDisallowed() then
		local data = mod:GetIBSData("persis")

		if data.lostDeath > 0 then
			local playerType = Isaac.GetPlayer(0):GetPlayerType()

			if (playerType ~= PlayerType.PLAYER_THELOST) and (playerType ~= PlayerType.PLAYER_THELOST_B) then
				data.lostDeath = 0
				mod:SaveIBSData()
			end
		end
	end	
end
BLost:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, 'SeeLost')

--受伤判定
function BLost:OnTakeDamage(ent, dmg, flag, source)
	if dmg <= 0 then return end
	if self:IsUnlocked() then return end
	local player = ent:ToPlayer()
	if not player then return end
	local playerType = player:GetPlayerType()
	
	--检测表里游魂
	if (playerType == PlayerType.PLAYER_THELOST) or (playerType == PlayerType.PLAYER_THELOST_B) then
		local data = mod:GetIBSData("persis")
		local stage = game:GetLevel():GetStage()
	
		--一层炸弹棉花怪
		if stage == 1 and data.lostDeath == 0 then
			if source.Type == 16 and source.Variant == 2 then
				data.lostDeath = 1
				mod:SaveIBSData()
				sfx:Play(mod.IBS_Sound.SecretFound, 2)
			end
		end
		
		--三层炸弹
		if stage == 3 and data.lostDeath == 1 then
			if source.Type == 4 then
				data.lostDeath = 2
				mod:SaveIBSData()
				sfx:Play(mod.IBS_Sound.SecretFound, 2)
			end
		end
		
		--六层妈腿
		if stage == 6 and data.lostDeath == 2 then
			if source.Type == 45 then
				data.lostDeath = 3
				mod:SaveIBSData()
				sfx:Play(mod.IBS_Sound.SecretFound, 2)
			end
		end
		
		--十层撒但(不能用种子)
		if stage == 10 and data.lostDeath == 3 and not game:AchievementUnlocksDisallowed() then
			if source.Type == 84 then
				data.lostDeath = 0
				self:Unlock(true, true)
				sfx:Play(mod.IBS_Sound.SecretFound, 2)
			end
		end

	end
end
BLost:AddCallback(ModCallbacks.MC_POST_ENTITY_TAKE_DMG, 'OnTakeDamage')




return BLost