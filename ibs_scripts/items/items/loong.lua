--龙

local mod = Isaac_BenightedSoul

local game = Game()

local Loong = mod.IBS_Class.Item(mod.IBS_ItemID.Loong)

--意义不明的火焰
function Loong:OnPlayeUpdate(player)
	if player:IsFrame(15,0) and player:HasCollectible(self.ID) and self._Players:IsShooting(player) then
		local fire = Isaac.Spawn(1000, 52, 0, player.Position, 0.5*RandomVector(), player):ToEffect()
		fire.Parent = player
		fire.CollisionDamage = math.max(3.5, player.Damage)
		fire.Timeout = math.random(90,180)
		fire.Scale = 0.5
		fire:Update()
	end
end
Loong:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, 'OnPlayeUpdate', 0)


--飞行
function Loong:OnEvaluateCache(player, flag)
	if flag == CacheFlag.CACHE_FLYING and player:HasCollectible(self.ID) then
		player.CanFly = true
	end
end
Loong:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, 'OnEvaluateCache')


return Loong