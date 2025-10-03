--变羊术

local mod = Isaac_BenightedSoul
local IBS_ItemID = mod.IBS_ItemID

local game = Game()
local sfx = SFXManager()

local Goatify = mod.IBS_Class.Item(mod.IBS_ItemID.Goatify)

--使用
function Goatify:OnUse(item, rng, player, flag, slot)
	local room = game:GetRoom()

	--挑战特殊规则
	if Isaac.GetChallenge() == mod.IBS_ChallengeID[3] then
		local pos = room:FindFreePickupSpawnPosition(player.Position, 0, true)	
		local goat = Isaac.Spawn(891,0,0, pos, Vector.Zero, player):ToNPC()
		goat:AddCharmed(EntityRef(player), -1)
		goat:MakeChampion(goat.InitSeed, ChampionColor.TINY)
		goat.MaxHitPoints = 36
		goat.HitPoints = goat.MaxHitPoints
	else
		for i = 1,rng:RandomInt(1,2) do
			local pos = room:FindFreePickupSpawnPosition(player.Position, 0, true)	
			local goat = Isaac.Spawn(891,0,0, pos, Vector.Zero, player)
			goat:AddCharmed(EntityRef(player), -1)
			goat.MaxHitPoints = goat.MaxHitPoints * 2
			goat.HitPoints = goat.MaxHitPoints
		end
	end
	
	if player:HasCollectible(IBS_ItemID.Wheat, true) then
		local num = player:GetCollectibleNum(IBS_ItemID.Wheat, true)

		for i = 1,num do
			player:RemoveCollectible(IBS_ItemID.Wheat, true)
		end
		
		for _,goat in pairs(Isaac.FindByType(891,0,0)) do
			goat:AddCharmed(EntityRef(player), -1)
			goat.MaxHitPoints = goat.MaxHitPoints + 30*num
			goat.HitPoints = goat.MaxHitPoints
			goat:SetColor(Color(0, 1, 0, 1, 0, 0.25, 0),30,2,true)
		end
	end
	
	return true
end
Goatify:AddCallback(ModCallbacks.MC_USE_ITEM, 'OnUse', Goatify.ID)

--山羊友好
function Goatify:OnNpcUpdate(npc)
	if npc.Variant == 0 and not npc:HasEntityFlags(EntityFlag.FLAG_FRIENDLY) then
		for i = 0, game:GetNumPlayers() - 1 do
			local player = Isaac.GetPlayer(i)
			if player:HasCollectible(self.ID) then
				npc:AddCharmed(EntityRef(player), -1)
				break
			end
		end	
	end
end
Goatify:AddCallback(ModCallbacks.MC_NPC_UPDATE, 'OnNpcUpdate', 891)

--山羊免疫部分伤害
function Goatify:PreTakeDMG(ent, dmg, flag, source)
	if Isaac.GetChallenge() == mod.IBS_ChallengeID[3] then return end --挑战3
	if ent.Variant == 0 and ent:HasEntityFlags(EntityFlag.FLAG_FRIENDLY) and PlayerManager.AnyoneHasCollectible(self.ID) then
		if game:GetRoom():IsClear() then
			return false
		elseif flag & DamageFlag.DAMAGE_FIRE > 0 or flag & DamageFlag.DAMAGE_SPIKES > 0 or flag & DamageFlag.DAMAGE_EXPLOSION > 0 then 
			return false
		end
	end
end
Goatify:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, 'PreTakeDMG', 891)

--受伤将攻击者变成山羊
function Goatify:OnTakeDMG(ent, dmg, flag, source)
	local player = ent:ToPlayer()
	
	if player and player:HasCollectible(self.ID) then
		local target = self._Ents:GetSourceEnemy(source.Entity)
		if target ~= nil and target:IsVulnerableEnemy() and not target:IsBoss() then
			local goat = Isaac.Spawn(891,0,0, target.Position, Vector.Zero, player)
			goat:AddCharmed(EntityRef(player), -1)
			target:Remove()
		end
	end
end
Goatify:AddCallback(ModCallbacks.MC_POST_ENTITY_TAKE_DMG, 'OnTakeDMG')


--魂火熄灭
function Goatify:OnWispKilled(familiar)
    if (familiar.Variant == FamiliarVariant.WISP and familiar.SubType == (self.ID)) then
		local player = self._Ents:IsSpawnerPlayer(familiar)
		
		if player then	
			local room = game:GetRoom()
			local pos = room:FindFreePickupSpawnPosition(familiar.Position, 0, true)
			local goat = Isaac.Spawn(891,0,0, pos, Vector.Zero, player)
			goat:AddCharmed(EntityRef(player), -1)
		end
    end
end
Goatify:AddCallback(ModCallbacks.MC_POST_ENTITY_KILL, 'OnWispKilled', EntityType.ENTITY_FAMILIAR)



return Goatify