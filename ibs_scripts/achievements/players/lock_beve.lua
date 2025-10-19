--解锁昧化夏娃

local mod = Isaac_BenightedSoul
local CharacterLock = mod.IBS_Class.CharacterLock

local game = Game()
local sfx = SFXManager()

local BEve = CharacterLock(mod.IBS_PlayerID.BEve, {'beve_unlock'} )

--死在以撒房间判定
function BEve:OnPlayerKilled(ent)
	local player = ent:ToPlayer()
	if not player then return end
	if not self:IsLocked() then return end
	if player:GetPlayerType() ~= PlayerType.PLAYER_EVE then return end

	--检测巴比伦
	if not player:GetEffects():HasCollectibleEffect(122) then
		self:Unlock(true, true)
		SUCCESS = true
		self:DelayFunction(function()		
			game:GetHUD():ShowFortuneText(self:ChooseLanguage(
				'只是一个罪人',
				'Only a sinner'
			))
		end, 1)
		sfx:Play(mod.IBS_Sound.SecretFound, 1.5)
	else
		game:GetHUD():ShowFortuneText(self:ChooseLanguage(
			'你的灵魂深藏于黑暗中',
			'Your soul is hidden deep within the darkness'
		))
	end
end
BEve:AddCallback(ModCallbacks.MC_POST_ENTITY_KILL, 'OnPlayerKilled', EntityType.ENTITY_PLAYER)


return BEve