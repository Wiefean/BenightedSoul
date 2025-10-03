--对峙的G

local mod = Isaac_BenightedSoul

local game = Game()
local sfx = SFXManager()

local ConfrontingC = mod.IBS_Class.Item(mod.IBS_ItemID.ConfrontingC)

--生成蝗虫
function ConfrontingC:SpawnLocust(player)
	local rng = player:GetCollectibleRNG(self.ID)
	local locust = Isaac.Spawn(3, 43, (rng:RandomInt(5) + 1), player.Position + 30 * RandomVector(), Vector.Zero, player):ToFamiliar()
	locust:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
	locust:SetColor(Color(1,1,1,0), 45, 1, true, true)
	locust.Player = player
	return locust
end

--新生成敌人时生成蝗虫
function ConfrontingC:OnNpcInit(npc)
	if game:GetRoom():GetFrameCount() < 3 then return end
	if not self._Ents:IsEnemy(npc, true) then return end
	for i = 0, game:GetNumPlayers() - 1 do
		local player = Isaac.GetPlayer(i)
		if player:HasCollectible(self.ID) then
			for i = 1,2 do
				self:SpawnLocust(player)
			end
		end
	end
end
ConfrontingC:AddPriorityCallback(ModCallbacks.MC_POST_NPC_INIT, CallbackPriority.LATE, 'OnNpcInit')

--蝗虫和蓝苍蝇抵挡敌弹
function ConfrontingC:OnFamiliarCollision(familiar, other)
	if not PlayerManager.AnyoneHasCollectible(self.ID) then return end
	local proj = other:ToProjectile()
	if proj and not proj:HasProjectileFlags(ProjectileFlags.CANT_HIT_PLAYER) then
		proj:Die()
	end	
end
ConfrontingC:AddCallback(ModCallbacks.MC_POST_FAMILIAR_COLLISION, 'OnFamiliarCollision', 43)
ConfrontingC:AddCallback(ModCallbacks.MC_POST_FAMILIAR_COLLISION, 'OnFamiliarCollision', 231)


return ConfrontingC