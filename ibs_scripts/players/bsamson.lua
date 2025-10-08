--昧化参孙

local mod = Isaac_BenightedSoul
local IBS_CallbackID = mod.IBS_CallbackID
local CharacterLock = mod.IBS_Achiev.CharacterLock

local game = Game()
local sfx = SFXManager()

local BSamson = mod.IBS_Class.Character(mod.IBS_PlayerID.BSamson, {
	BossIntroName = 'bsamson',
})

--意义不明的火焰
function BSamson:OnPlayeUpdate(player)
	if player:IsFrame(10,0) and player:GetPlayerType() == self.ID and self._Players:IsShooting(player) then
		local fire = Isaac.Spawn(1000, 52, 0, player.Position, RandomVector(), player):ToEffect()
		fire.Parent = player
		fire.CollisionDamage = math.max(7, 2*player.Damage)
		fire.Timeout = math.random(90,180)
		fire.Scale = 1.2	
	end
end
BSamson:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, 'OnPlayeUpdate', 0)

return BSamson